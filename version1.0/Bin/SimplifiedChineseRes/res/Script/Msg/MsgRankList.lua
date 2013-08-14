---------------------------------------------------
--描述: 名人堂消息处理
--时间: 2013.1.9
--作者: CHH
---------------------------------------------------

MsgRankList = {}
local p = MsgRankList;

local PACKAGE_CONTINUE  = 0;
local PACKAGE_BEGIN     = 1;
local PACKAGE_END       = 2;
local PACKAGE_SINGLE    = 3;

p.mUIListener = nil;

p.RANKING_ACT = {
    ACT_NONE        = 0,
    ACT_PET_LEVEL   = 1,    --等级排名
    ACT_MOUNT_LEVEL = 2,    --坐骑排名
    ACT_SOPH        = 3,    --将魂排名
    ACT_STAGE       = 4,    --进度排名
    ACT_REPUTE      = 5,    --声望排名
    ACT_MONEY       = 6,    --银币排名
    ACT_EMONEY      = 7,    --金币排名
    ACT_ELITE_STAGE = 8,    --精英副本
    ACT_REFRESHTIME = 9,    --剩余刷新时间
    ATC_ACTIVITY_CODE = 10, --激活码获取礼包接口
    
    RANKING_ACT_CURRENT_EVENT = 11,  --当前活动查询
    ATC_RANK_COMMON_INFO = 12, --公共数据接收
}
p.Action = p.RANKING_ACT.ACT_NONE;
p.btActionType = p.RANKING_ACT.ACT_NONE;

--名人堂的图标
p.nRankIcon = 0;

function p.SendGetListInfoMsg( nRankingAct, val )
    LogInfo("p.SendGetListInfoMsg nRankingAct:[%d]",nRankingAct);
    ShowLoadBar();
    local netdata = createNDTransData(NMSG_Type._MSG_RANKING);
    if nil == netdata then
        return false;
    end
    netdata:WriteByte(nRankingAct);
    if( CheckS(val) ) then
        netdata:WriteStr(val);
    end
    SendMsg(netdata);
    netdata:Free();
    return true;
end

function p.GetRankIcon()
	return p.nRankIcon;
end
function p.GetRankType()
	return p.btActionType;
end


function p.ProcessGetListInfo(netdata) 
    CloseLoadBar();
    --获取活动类型
    local btAction = netdata:ReadByte();
    
    if(btAction == p.RANKING_ACT.ACT_REFRESHTIME) then
        local nTime = netdata:ReadInt();
        RankListUI.RefreshTime(nTime);
        return;
    --激活码礼包使用接口
    elseif(btAction == p.RANKING_ACT.ATC_ACTIVITY_CODE) then
        local nStatus = netdata:ReadInt();
        if(nStatus == 0) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T8"));
        elseif(nStatus == 1) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T9"));
        elseif(nStatus == 2) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T10"));
        elseif(nStatus == 3) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T11"));
        elseif(nStatus == 4) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T12"));
        end
        CloseLoadBar();
        return;
    end
    
    --当前名人堂活动   只是爲了區別顯示主界面中名人堂的按鈕
    if btAction == p.RANKING_ACT.RANKING_ACT_CURRENT_EVENT then
		p.btActionType = netdata:ReadByte();
		p.nRankIcon = netdata:ReadInt();     --主界面显示的icon
		
		--获取名人堂公共的数据
		RankListUI.tbRankInfo = {};
		RankListUI.tbRankInfo.nBgIcon = netdata:ReadInt();		 --名人堂背景图片
		RankListUI.tbRankInfo.nBeginTime = netdata:ReadInt();	 --活动开始时间
		RankListUI.tbRankInfo.nEndTime = netdata:ReadInt();	     --活动结束时间
		RankListUI.tbRankInfo.strDec = netdata:ReadUnicodeString(); --活动描述
		RankListUI.tbRankInfo.tbRankList = {};	--保存记录数据
        
        MainUI.RefreshFuncIsOpen();
       return;
    end
    
    --包类型
    local btPackageType = netdata:ReadByte();   
    --初始包数据清空
    if btPackageType == PACKAGE_BEGIN or btPackageType == PACKAGE_SINGLE then
		RankListUI.tbRankInfo.tbRankList = {};
    end
    
	--记录条数
    local nRecordCount = netdata:ReadShort();
    
    local nt = #RankListUI.tbRankInfo.tbRankList;
    for i=1,nRecordCount do
        local tbRank = {};
        tbRank.nRank = nt + i;    --获取排名
        tbRank.nNum = netdata:ReadInt();
               
        if (p.btActionType == p.RANKING_ACT.ACT_SOPH) then
            if(tbRank.nNum == 0) then
                tbRank.nNum = 1;
            end
            tbRank.nStar = netdata:ReadInt();  --点亮的个数
            tbRank.nSoph = netdata:ReadInt();  --
            tbRank.nAddSoph = netdata:ReadInt(); 
        elseif  (p.btActionType == p.RANKING_ACT.ACT_REPUTE) then
            tbRank.nAddRepute = netdata:ReadInt(); 
        end
        
        tbRank.sName = netdata:ReadUnicodeString();  --获取玩家名字
        
        table.insert(RankListUI.tbRankInfo.tbRankList, tbRank);
    end
    
    --收包结束显示数据
    if btPackageType == PACKAGE_END or btPackageType == PACKAGE_SINGLE then
        RankListUI.LoadUI(); 
    end

end

--[[
function p.ProcessGetListInfo(netdata) 
    LogInfo("p.ProcessGetListInfo");
    local nAction = netdata:ReadByte();
    
    if(nAction == p.RANKING_ACT.ACT_REFRESHTIME) then
        local nTime = netdata:ReadInt();
        LogInfo("p.ProcessGetListInfo ACT_REFRESHTIME:[%d]",nTime);
        RankListUI.RefreshTime(nTime);
        return;
    elseif(nAction == p.RANKING_ACT.ATC_ACTIVITY_CODE) then
        local nStatus = netdata:ReadInt();
        if(nStatus == 0) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T8"));
        elseif(nStatus == 1) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T9"));
        elseif(nStatus == 2) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T10"));
        elseif(nStatus == 3) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T11"));
        elseif(nStatus == 4) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("RLUI_T12"));
        end
        CloseLoadBar();
        return;
    end
    
    
    local nPackageType = netdata:ReadByte();
    local nRecordCount = netdata:ReadShort();
    LogInfo("nAction:[%d],nPackageType:[%d],nRecordCount:[%d]",nAction,nPackageType,nRecordCount);
    p.Action = nAction;
    
    if nPackageType == PACKAGE_BEGIN or nPackageType == PACKAGE_SINGLE then
        LogInfo("p.RankLists clear");
        p.RankLists = {};
    end
    local nt = #p.RankLists;
    for i=1,nRecordCount do
        local pRank = {};
        
        pRank.nRank = nt + i;
        pRank.nNum = netdata:ReadInt();
        
        LogInfo("pRank.nRank:[%d],pRank.nNum:[%d]",pRank.nRank,pRank.nNum);
        if(p.RANKING_ACT.ACT_SOPH == nAction) then
            if(pRank.nNum == 0) then
                pRank.nNum = 1;
            end
            pRank.nStar = netdata:ReadInt();
            pRank.nSoph = netdata:ReadInt();
            
            LogInfo("pRank.nStar:[%d],pRank.nSoph:[%d]",pRank.nStar,pRank.nSoph);
        end
        
        pRank.sName = netdata:ReadUnicodeString();
        
        LogInfo("pRank.sName:[%s]",pRank.sName);
        
        table.insert(p.RankLists, pRank);
    end
    
    if nPackageType == PACKAGE_END or nPackageType == PACKAGE_SINGLE then
        if(p.mUIListener) then
            p.mUIListener(NMSG_Type._MSG_RANKING,p.RankLists);
        end
    end
    
    CloseLoadBar();
end
]]



DAILYTASK_ACTION = {
    OPEN = 1,               --打开界面
    REFRESH_TASK = 2,       --刷新任务
    REFRESH_COMBO = 3,      --刷新政绩
    GET_SCORE_PRIZE = 4,    --获取积分
    UPDATE_TASK = 5,        --升级任务
    GIVEUP_TASK = 6,        --放弃任务
    ACCEPT_TASK = 7,        --接受任务
    FINISH_TASK = 8,        --完成任务
    FAST_FINISH_TASK = 9,   --立即完成
    USER_COMBO_IFNO = 10,   --积分信息
    USER_TASK_INFO = 11,    --任务信息
    USER_STATIC_INFO = 12,  --服务端静态数据
    GIFT_RESPONE = 13,      --礼包反馈
    REFRESH_COMBOXDOME  = 14,--完成combo
}

function p.SendDailytaskMsg( nAction, nData )
    LogInfo("p.SendDailytaskMsg nAction:[%d]",nAction);
    ShowLoadBar();
    local netdata = createNDTransData(NMSG_Type._MSG_DAILYTASK);
    if nil == netdata then
        return false;
    end
    netdata:WriteByte(nAction);
    
    if(DAILYTASK_ACTION.GET_SCORE_PRIZE == nAction or DAILYTASK_ACTION.ACCEPT_TASK == nAction or DAILYTASK_ACTION.UPDATE_TASK == nAction) then
        netdata:WriteByte(nData);
    end
    
    SendMsg(netdata);
    netdata:Free();
    return true;
end


p.ComboInfo = nil;
p.TaskInfo = nil;
p.StaticInfo = nil;

function p.GetComboInfo()
    return p.ComboInfo;
end

function p.GetTaskInfo()
    return p.TaskInfo;
end

function p.GetStaticInfo()
    return p.StaticInfo;
end

function p.ProcessSendDailytaskMsg(netdata) 
    LogInfo("p.ProcessGetListInfo");
    local nAction = netdata:ReadByte();
    LogInfo("nAction:[%d]",nAction);
    
    if(nAction == DAILYTASK_ACTION.OPEN) then
        MissionUI.LoadUI();
    elseif(nAction == DAILYTASK_ACTION.REFRESH_TASK) then
        
    elseif(nAction == DAILYTASK_ACTION.REFRESH_COMBO) then
        
    elseif(nAction == DAILYTASK_ACTION.GET_SCORE_PRIZE) then
        
    elseif(nAction == DAILYTASK_ACTION.UPDATE_TASK) then
        
    elseif(nAction == DAILYTASK_ACTION.GIVEUP_TASK) then
        
    elseif(nAction == DAILYTASK_ACTION.ACCEPT_TASK) then
        
    elseif(nAction == DAILYTASK_ACTION.FINISH_TASK) then
        
    elseif(nAction == DAILYTASK_ACTION.FAST_FINISH_TASK) then
        
    elseif(nAction == DAILYTASK_ACTION.USER_COMBO_IFNO) then
        p.ComboInfo = {};
        p.ComboInfo.nComboSelect = netdata:ReadInt();
        p.ComboInfo.nComboxDone = netdata:ReadInt();
        p.ComboInfo.nUserScore = netdata:ReadInt();
        p.ComboInfo.nScorePrize = netdata:ReadInt();
        
        LogInfo("nComboSelect:[%d],nComboxDone:[%d],nUserScore:[%d],nScorePrize:[%d]",p.ComboInfo.nComboSelect,p.ComboInfo.nComboxDone,p.ComboInfo.nUserScore,p.ComboInfo.nScorePrize);
        
        MissionUI.RefreshCombo();
    elseif(nAction == DAILYTASK_ACTION.USER_TASK_INFO) then
        p.TaskInfo = {};
        p.TaskInfo.nDoneTaskNum = netdata:ReadInt();
        p.TaskInfo.nTaskType = netdata:ReadInt();
        p.TaskInfo.nTaskStatus = netdata:ReadInt();
        p.TaskInfo.nTaskTask = netdata:ReadInt();
        p.TaskInfo.nDoItemCount = netdata:ReadInt();

        p.TaskInfo.nTaskSelect1 = netdata:ReadInt();
        p.TaskInfo.nTaskSelect2 = netdata:ReadInt();
        p.TaskInfo.nTaskSelect3 = netdata:ReadInt();
        p.TaskInfo.nTaskSelect4 = netdata:ReadInt();
        
        p.TaskInfo.nTaskType1 = netdata:ReadInt();
        p.TaskInfo.nTaskType2 = netdata:ReadInt();
        p.TaskInfo.nTaskType3 = netdata:ReadInt();
        p.TaskInfo.nTaskType4 = netdata:ReadInt();
        
        LogInfo("p.TaskInfo.nTaskTask:[%d]",p.TaskInfo.nTaskTask);
        LogInfo("nDoneTaskNum:[%d],nTaskType:[%d],nTaskStatus:[%d],nDoItemCount:[%d],nTaskSelect1:[%d],nTaskSelect2:[%d],nTaskSelect3:[%d],nTaskSelect4:[%d]",p.TaskInfo.nDoneTaskNum,p.TaskInfo.nTaskType,p.TaskInfo.nTaskStatus,p.TaskInfo.nTaskStatus,p.TaskInfo.nTaskStatus,p.TaskInfo.nDoItemCount,p.TaskInfo.nTaskSelect1,p.TaskInfo.nTaskSelect2,p.TaskInfo.nTaskSelect3,p.TaskInfo.nTaskSelect4);
        
        
        MissionUI.RefreshTask();
    elseif(nAction == DAILYTASK_ACTION.USER_STATIC_INFO) then
        p.StaticInfo = {};
        p.StaticInfo.nMaxTaskNum = netdata:ReadInt();           --最大任务数量
        p.StaticInfo.nRandomTaskNum = netdata:ReadInt();        --
        p.StaticInfo.nMasTaskLevel = netdata:ReadInt();
        p.StaticInfo.nRefreshTaskEmoney = netdata:ReadInt();
        p.StaticInfo.nUpdateTaskEmoney = netdata:ReadInt();
        p.StaticInfo.nFastFinishEmoney = netdata:ReadInt();
        p.StaticInfo.nRefreshComboEmoney = netdata:ReadInt();
        p.StaticInfo.nComboAwardScore1 = netdata:ReadInt();
        p.StaticInfo.nComboAwardScore2 = netdata:ReadInt();
        p.StaticInfo.nComboAwardScore3 = netdata:ReadInt();
        p.StaticInfo.nComboAwardScore4 = netdata:ReadInt();
    elseif(nAction == DAILYTASK_ACTION.GIFT_RESPONE) then
        
        local infos = {};
        local nYinBi = netdata:ReadInt();
        local nJinBi = netdata:ReadInt();
        local nRepute = netdata:ReadInt();
        local nStamina = netdata:ReadInt();
        local nSoph = netdata:ReadInt();
        local nExp = netdata:ReadInt();
        
        local nSpirit = netdata:ReadInt();
        local nScore = netdata:ReadInt();
        local nTaskNum = netdata:ReadInt();
        
        if(nYinBi>0) then
            table.insert(infos,{string.format(GetTxtPub("coin").." +%d",nYinBi),FontColor.Silver});
        end
        if(nJinBi>0) then
            table.insert(infos,{string.format(GetTxtPub("shoe").." +%d",nJinBi),FontColor.Coin});
        end
        if(nRepute>0) then
            table.insert(infos,{string.format(GetTxtPub("ShenWan").." +%d",nRepute),FontColor.Reput});
        end
        if(nStamina>0) then
            table.insert(infos,{string.format(GetTxtPub("Stamina").." +%d",nStamina),FontColor.Stamina});
        end
        if(nSoph>0) then
            table.insert(infos,{string.format(GetTxtPub("JianHun").." +%d",nSoph),FontColor.Soul});
        end
        if(nExp>0) then
            table.insert(infos,{string.format(GetTxtPub("exp").." +%d",nExp),FontColor.Exp});
        end
        
        if(nSpirit>0) then
            table.insert(infos,{string.format(GetTxtPri("ZJ_T19").." +%d",nSpirit),FontColor.Spirit});
        end
        if(nScore>0) then
            table.insert(infos,{string.format(GetTxtPri("ZJ_T20").." +%d",nScore),FontColor.Score});
        end
        if(nTaskNum>0) then
            table.insert(infos,{string.format(GetTxtPri("ZJ_T21").." +%d",nTaskNum),FontColor.TaskNum});
        end

        
        LogInfo("nYinBi:[%d],nJinBi:[%d],nRepute:[%d],nStamina:[%d],nSoph:[%d],nExp:[%d]",nYinBi,nJinBi,nRepute,nStamina,nSoph,nExp);
        
        local nItemCount = netdata:ReadInt();
        
        LogInfo("nItemCount:[%d]",nItemCount);
        
        for i=1,nItemCount do
            local nItemType = netdata:ReadInt();
            local nNum = netdata:ReadInt();
            if(nNum>0) then
                local n7 = Num7(nItemType);
                local n8 = Num8(nItemType);
                
                if(n7 == 3 and n8 == 0) then
                    table.insert(infos,{string.format(ItemFunc.GetName(nItemType).." x%d",nNum),ItemFunc.GetDaoFaItemColor(nItemType)});
                else
                    table.insert(infos,{string.format(ItemFunc.GetName(nItemType).." x%d",nNum),ItemFunc.GetItemColor(nItemType)});
                end
            end
        end
        
        CommonDlgNew.ShowTipsDlg(infos);
    elseif(nAction == DAILYTASK_ACTION.REFRESH_COMBOXDOME) then
        p.ComboInfo.nComboxDone = netdata:ReadInt();
        
        LogInfo("DAILYTASK_ACTION.REFRESH_COMBOXDOME p.ComboInfo.nComboxDone:[%d]",p.ComboInfo.nComboxDone);
        
        local nScore = netdata:ReadInt();
        MissionUI.RefreshCombo();
        MissionUI.SetAward(nScore);
    end
    
    CloseLoadBar();
end



RegisterNetMsgHandler(NMSG_Type._MSG_DAILYTASK, "p.ProcessSendDailytaskMsg", p.ProcessSendDailytaskMsg);



RegisterNetMsgHandler(NMSG_Type._MSG_RANKING, "p.ProcessGetListInfo", p.ProcessGetListInfo);
