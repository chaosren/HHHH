---------------------------------------------------
--描述: 日常任务
--时间: 2013.3.12
--作者: chh
---------------------------------------------------
MissionUI = {}
local p = MissionUI;

local TAG_CLOSE         = 3;

local TAG_TASK_COUNT = 159;


local TAG_TASK01 = 11001;
local TAG_TASK_BG = 156;
local TAG_TASK_REFRESH_COMBO = 168;

local TAG_COMBO_IMGS = {
    165,166,167
}
local TAG_COMBO_BOXS = {
    265,266,267
}
local TAG_COMBO_WC = {
    30,31,32
}
local TAG_EXP = 177;

local TAG_BOXS = {
    171,172,173,174,175,176,
};

local JL_TYPE = {
    {DB_DAILYTASK_LEVEL_CONFIG.MONEY,GetTxtPri("ZJ_T02")},
    {DB_DAILYTASK_LEVEL_CONFIG.STAMINA,GetTxtPri("ZJ_T03")},
    {DB_DAILYTASK_LEVEL_CONFIG.SOPH,GetTxtPri("ZJ_T04")},
    {DB_DAILYTASK_LEVEL_CONFIG.REPUTE,GetTxtPri("ZJ_T05")},
    {DB_DAILYTASK_LEVEL_CONFIG.ITEMTYPE,GetTxtPri("ZJ_T06"),DB_DAILYTASK_LEVEL_CONFIG.ITEMTYPE_COUNT},
    {DB_DAILYTASK_LEVEL_CONFIG.DAILYTASK_NUM,GetTxtPri("ZJ_T07")},
};

local TAG_TASKS = {
    {
        TAG_TYPE_IMG = 12,
        TAG_UPGRADE_BTN = 106,
        TAG_NAME_LAB = 152,
        TAG_DESC_LAB = 153,
        TAG_SCORE_LAB = 154,
        TAG_JL_LAB = 155,
    },
    {
        TAG_TYPE_IMG = 13,
        TAG_UPGRADE_BTN = 107,
        TAG_NAME_LAB = 240,
        TAG_DESC_LAB = 241,
        TAG_SCORE_LAB = 242,
        TAG_JL_LAB = 243,
    },
    {
        TAG_TYPE_IMG = 14,
        TAG_UPGRADE_BTN = 108,
        TAG_NAME_LAB = 244,
        TAG_DESC_LAB = 245,
        TAG_SCORE_LAB = 246,
        TAG_JL_LAB = 247,
    },
    {
        TAG_TYPE_IMG = 15,
        TAG_UPGRADE_BTN = 109,
        TAG_NAME_LAB = 248,
        TAG_DESC_LAB = 249,
        TAG_SCORE_LAB = 250,
        TAG_JL_LAB = 251,
    }
}
local TAG_REFRESH_EMONEY = 164;
local TAG_REFRESH_TASK_BTN = 162;
local TAG_CLOSE = 3;

local TAG_LJWC = 356;
local TAG_FQRW = 162;


local TAG_TASK02 = 11002;
local TAG_COMBO_ZJ = 161;


local TAG_ACCESS_TASK1 = 7; 
local TAG_ACCESS_TASK2 = 8;
local TAG_ACCESS_TASK3 = 9;
local TAG_ACCESS_TASK4 = 10; 


local TAG_TASK02_PIC = 12;
local TAG_TASK02_NAME = 346;
local TAG_TASK02_STATU = 347;

local TAG_TASK02_ZJ = 351;
local TAG_TASK02_JL = 352;
local TAG_TASK02_MB = 353;
local TAG_TASK02_RD = 355;

local TAG_INFO = 28;
local TAG_INFO_CLOSE = 533;
local TAG_CONTAINER_DESC = 101;

local DesInfos2 = {
    GetTxtPri("ZJ_T25"),
    GetTxtPri("ZJ_T26"),
    GetTxtPri("ZJ_T27"),
    GetTxtPri("ZJ_T28"),
    GetTxtPri("ZJ_T29"),
    GetTxtPri("ZJ_T30"),
    GetTxtPri("ZJ_T31"),
    GetTxtPri("ZJ_T32"),
    GetTxtPri("ZJ_T33"),
    GetTxtPri("ZJ_T34"),
    GetTxtPri("ZJ_T35"),
    GetTxtPri("ZJ_T36"),
    GetTxtPri("ZJ_T37"),
    GetTxtPri("ZJ_T38"),
    GetTxtPri("ZJ_T39"),
    GetTxtPri("ZJ_T40"),
    GetTxtPri("ZJ_T41"),
    GetTxtPri("ZJ_T42"),
    GetTxtPri("ZJ_T43"),
    GetTxtPri("ZJ_T44"),
    GetTxtPri("ZJ_T45"),
    GetTxtPri("ZJ_T46"),
    GetTxtPri("ZJ_T47"),
    GetTxtPri("ZJ_T48"),
    GetTxtPri("ZJ_T49"),
    GetTxtPri("ZJ_T50"),
    GetTxtPri("ZJ_T51"),
    GetTxtPri("ZJ_T52"),
    GetTxtPri("ZJ_T53"),
    GetTxtPri("ZJ_T54"),
    GetTxtPri("ZJ_T55"),
    GetTxtPri("ZJ_T56"),
    GetTxtPri("ZJ_T57"),
    GetTxtPri("ZJ_T58"),
};

function p.LoadUI()
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    

--------------------添加礼包层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.MissionUI );
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
    

-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("mission/mission.ini", layer, p.OnUIEvent, 0, 0);
    
    
    
    
    --初始化任务1面板
    local pParent = p.GetLayer();
--------------------添加礼包层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(TAG_TASK01);
	pParent:AddChild(layer);
    

-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("mission/mission_1.ini", layer, p.OnUIEventTask01, 0, 0);
    
    local pBgPic = GetImage(layer, TAG_TASK_BG);
    local winsize = GetWinSize();
    layer:SetFrameRect(CGRectMake(0, winsize.h-pBgPic:GetFrameRect().size.h, winsize.w, winsize.h));
    local closeBtn=GetButton(layer,TAG_CLOSE);
    closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    
    
    
    
    
    --初始化任务2面板
    local pParent = p.GetLayer();
--------------------添加礼包层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(TAG_TASK02);
	pParent:AddChild(layer);
    

-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("mission/mission_2.ini", layer, p.OnUIEventTask02, 0, 0);
    
    local pBgPic = GetImage(layer, TAG_TASK_BG);
    local winsize = GetWinSize();
    layer:SetFrameRect(CGRectMake(0, winsize.h-pBgPic:GetFrameRect().size.h, winsize.w, winsize.h));

    
    
    

    
    p.RefreshCombo();

    p.RefreshTask();
    
-------------------------------初始化数据------------------------------------    

    p.refreshMoney();

    return true;
end

p.pLayerInfo = nil;
function p.ViewInfo()
    local ppLayer = p.GetLayer();
--------------------添加礼包层（窗口）---------------------------------------
    p.pLayerInfo = createNDUILayer();
	if p.pLayerInfo == nil then
		return false;
	end
	p.pLayerInfo:Init();
	p.pLayerInfo:SetFrameRect(RectFullScreenUILayer);
	ppLayer:AddChildZ(p.pLayerInfo,UILayerZOrder.NormalLayer);
    

-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		p.pLayerInfo:Free();
		return false;
	end

	uiLoad:Load("mission/missionl_Intro.ini", p.pLayerInfo, p.OnUIEventInfo, 0, 0);
    
    
    
    
    local containter = RecursiveSVC(p.pLayerInfo, {TAG_CONTAINER_DESC});
    containter:RemoveAllView();
    containter:EnableScrollBar(true);
    local size = containter:GetFrameRect().size;
    containter:SetViewSize(CGSizeMake(size.w, 24*CoordScaleY_960));
	for i,v in ipairs(DesInfos2) do
        local view = createUIScrollView();
        view:Init(false);
        view:SetScrollStyle(UIScrollStyle.Verical);
        view:SetViewId(i);
        view:SetTag(i);
        view:SetMovableViewer(containter);
        view:SetScrollViewer(containter);
        view:SetContainer(containter);
        containter:AddView(view);
        
        --local pLabelTips = _G.CreateColorLabel( v, 10, size.w );
        local pLabelTips = CreateLabel(v,CGRectMake(0, 0, size.w, 24*CoordScaleY_960), 12, ccc4(255,255,255,255));
        view:AddChild(pLabelTips);
    end
    
end

function p.CloseViewInfo()
    if(p.pLayerInfo) then
        p.pLayerInfo:RemoveFromParent( true );
        p.pLayerInfo = nil;
    end
end

function p.OnUIEventInfo(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_INFO_CLOSE) then
            p.CloseViewInfo();
        end
    end
    return true;
end

function p.OnUIEventTask02(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_LJWC) then
            
            local pTaskInfo = MsgRankList.GetTaskInfo();
            local nLevel = Num1(pTaskInfo.nTaskType);
            local nType = math.floor(pTaskInfo.nTaskType/10);
            local nCount = nLevel*GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.GROW_VALUE)+GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.BASE_VALUE);

            if(pTaskInfo.nDoItemCount>=nCount) then
                MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.FINISH_TASK);
            else
                p.FastTaskTip();
            end
            
        elseif(tag == TAG_FQRW) then
            p.FQRWTip();
        elseif(tag == TAG_CLOSE) then
            CloseUI(NMAINSCENECHILDTAG.MissionUI);
        end
        
    end
    return true;
end

function p.FQRWTip()
    CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("ZJ_T17"), p.FQRWCallback);
end

function p.FQRWCallback(eventType, param)
    if(eventType == CommonDlgNew.BtnOk) then
        MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.GIVEUP_TASK);
    end
end





function p.OnUIEventTask01(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEventTask01 tag:[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_REFRESH_TASK_BTN) then
            p.RefreshTaskTip();
        elseif(tag == TAG_ACCESS_TASK1) then
            local bFlag = p.TaskCountFullPD();
            if(bFlag == false) then
                return true;
            end
            MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.ACCEPT_TASK, 1);
        elseif(tag == TAG_ACCESS_TASK2) then
            local bFlag = p.TaskCountFullPD();
            if(bFlag == false) then
                return true;
            end
            MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.ACCEPT_TASK, 2);
        elseif(tag == TAG_ACCESS_TASK3) then
            local bFlag = p.TaskCountFullPD();
            if(bFlag == false) then
                return true;
            end
            MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.ACCEPT_TASK, 3);
        elseif(tag == TAG_ACCESS_TASK4) then
            local bFlag = p.TaskCountFullPD();
            if(bFlag == false) then
                return true;
            end
            MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.ACCEPT_TASK, 4);
        
        --升级任务
        elseif(tag == TAG_TASKS[1].TAG_UPGRADE_BTN) then
            p.UpgrudeTaskTip( 1 );
        elseif(tag == TAG_TASKS[2].TAG_UPGRADE_BTN) then
            p.UpgrudeTaskTip( 2 );
        elseif(tag == TAG_TASKS[3].TAG_UPGRADE_BTN) then
            p.UpgrudeTaskTip( 3 );
        elseif(tag == TAG_TASKS[4].TAG_UPGRADE_BTN) then
            p.UpgrudeTaskTip( 4 );
            
        elseif(tag == TAG_CLOSE) then
            CloseUI(NMAINSCENECHILDTAG.MissionUI);
        end
    end
    return true;
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEven1t[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_BOXS[1]) then
            p.IsGetBX(1)
        elseif(tag == TAG_BOXS[2]) then
            p.IsGetBX(2)
        elseif(tag == TAG_BOXS[3]) then
            p.IsGetBX(3)
        elseif(tag == TAG_BOXS[4]) then
            p.IsGetBX(4)
        elseif(tag == TAG_BOXS[5]) then
            p.IsGetBX(5)
        elseif(tag == TAG_BOXS[6]) then
            p.IsGetBX(6)
        elseif(tag == TAG_TASK_REFRESH_COMBO) then
            p.RefreshComboTip();
        elseif(tag == TAG_INFO) then
            p.ViewInfo();
        end
	end
	return true;
end



--宝箱是否可打开
function p.IsGetBX(nIdx)
    local pComboInfo = MsgRankList.GetComboInfo();
    local pBoxList = {
        Num1(pComboInfo.nScorePrize),
        Num2(pComboInfo.nScorePrize),
        Num3(pComboInfo.nScorePrize),
        Num4(pComboInfo.nScorePrize),
        Num5(pComboInfo.nScorePrize),
        Num6(pComboInfo.nScorePrize),
    };
    if(pBoxList[nIdx] == 0) then
        local nLen = p.GetOpenBoxIdx(pComboInfo.nUserScore);
        if(nLen>=nIdx) then
            MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.GET_SCORE_PRIZE, nIdx);
        end
    end
end


function p.RefreshCombo()
    local pLayer = p.GetLayer();
    if(pLayer == nil) then
        return;
    end
    local pComboInfo = MsgRankList.GetComboInfo();
    if(pComboInfo == nil) then
        LogInfo("err, p.RefreshCombo pComboInfo==nil");
        return;
    end
    
    local nIcon = {
        Num1(pComboInfo.nComboSelect),
        Num2(pComboInfo.nComboSelect),
        Num3(pComboInfo.nComboSelect),
        Num4(pComboInfo.nComboSelect),
    }
    
    local nIconB = {
        Num1(pComboInfo.nComboxDone),
        Num2(pComboInfo.nComboxDone),
        Num3(pComboInfo.nComboxDone),
        Num4(pComboInfo.nComboxDone),
    }
    
    --刷新combo奖励图片
    for i,v in ipairs(TAG_COMBO_IMGS) do
        local pImg = GetImage(pLayer, v);
        
        if(pImg) then
            local nIdx = nIcon[i];
            local pPic = nil;
            if(nIdx~=0) then
                pPic = GetComboImg(nIdx);
            end
            pImg:SetPicture(pPic);
            
            
        end
        
        local pImgB = GetImage(pLayer, TAG_COMBO_BOXS[i]);
        local pImgB2 = GetImage(pLayer, TAG_COMBO_WC[i]);
        
        if(pImgB) then
            local nIdxB = nIconB[i];
            local pPicB = nil;
            if(nIdxB~=0) then
                pPicB = GetComboImgB(nIdxB);
                pImgB2:SetVisible(true);
            else
                pImgB2:SetVisible(false);
            end
            pImgB:SetPicture(pPicB);
        end

    end
    
    
    --经验条
    local expUI	= RecursivUIExp(pLayer, {TAG_EXP});
    if(expUI) then
        local nCurExp = pComboInfo.nUserScore;
        local nTotExp = p.GetMaxExp();
        
        if(nCurExp>nTotExp) then
            nCurExp = nTotExp;
        end
        expUI:SetProcess(nCurExp);
        expUI:SetTotal(nTotExp);
    end
    
    local pBoxList = {
        Num1(pComboInfo.nScorePrize),
        Num2(pComboInfo.nScorePrize),
        Num3(pComboInfo.nScorePrize),
        Num4(pComboInfo.nScorePrize),
        Num5(pComboInfo.nScorePrize),
        Num6(pComboInfo.nScorePrize),
    };
    
   
    --打开的宝箱
    local nIdx = p.GetOpenBoxIdx(pComboInfo.nUserScore);
    LogInfo("nIdx:[%d]",nIdx);
    for i,v in ipairs(TAG_BOXS) do
        LogInfo("i:[%d],nIdx:[%d]",i,nIdx);
        local pImg = GetButton(pLayer, v);
        local pPic = nil;
        if(i>nIdx) then
            LogInfo("GetBoxGray");
            pPic = GetBoxGray(i);
        else
            if(pBoxList[i]==1) then
                LogInfo("GetBoxOpen");
                pPic = GetBoxOpen(i);
            else
                LogInfo("GetBoxColor");
                pPic = GetBoxColor(i);
            end
        end
        if(pImg) then
            pImg:SetImage(pPic);
        end
    end
    

end

function p.GetOpenBoxIdx( nScore )
    local pList = GetDataBaseIdList("dailytask_score_config");
    for i,v in ipairs(pList) do
        local nDBScore = GetDataBaseDataN("dailytask_score_config",v,DB_DAILYTASK_SCORE_CONFIG.SCORE);
        LogInfo("i:[%d] nScore:[%d]<nDBScore:[%d]",i,nScore,nDBScore);
        if(nScore+1<=nDBScore) then
            LogInfo("nScore<nDBScore == true"); 
            return i-1;
        end
    end
    LogInfo("nScore<nDBScore ~= true"); 
    return #pList;
end

function p.GetMaxExp()
    local pList = GetDataBaseIdList("dailytask_score_config");
    local nMaxScore = GetDataBaseDataN("dailytask_score_config",pList[#pList],DB_DAILYTASK_SCORE_CONFIG.SCORE);
    return nMaxScore;
end


p.nScore = nil;
p.nTimerID = nil;


function p.RefreshTask()
    p.RefreshTask01();
    p.RefreshTask02();
    p.RefreshLayerShow();
end

function p.RefreshLayerShow()
    local pTaskInfo = MsgRankList.GetTaskInfo();
    local layer1 = p.GetTask01();
    local layer2 = p.GetTask02();
    if(layer1 and layer2) then
        if(pTaskInfo.nTaskType == 0) then
            layer1:SetVisible(true);
            layer2:SetVisible(false);
        else
            layer1:SetVisible(false);
            layer2:SetVisible(true);
        end
    end
end


--定时查看combo完成
function p.SetAward(nScore)
    if(p.nTimerID == nil) then
        p.nScore=nScore;
        p.nTimerID = RegisterTimer( p.OnTimer, 2 );
    end
end
function p.OnTimer()
    if(p.nTimerID) then
        UnRegisterTimer( p.nTimerID );
        p.nTimerID = nil;
    end
    if(p.nScore) then
        local infos = {{string.format(GetTxtPri("ZJ_T22"),p.nScore),FontColor.Text}};
        CommonDlgNew.ShowTipsDlg(infos);
    end
    
    p.RefreshCombo();
    p.RefreshTask();
end


function p.RefreshTask01()
    if(p.nTimerID) then
        return;
    end
    local player = p.GetLayer();
    if(player == nil) then
        return;
    end
    local pTaskCount = GetLabel(player, TAG_TASK_COUNT);
    if(pTaskCount) then
        pTaskCount:SetText(string.format("%d%s",MsgRankList.GetStaticInfo().nMaxTaskNum - MsgRankList.GetTaskInfo().nDoneTaskNum,GetTxtPri("MS_T23")));
    end
    
    local pComboZj = GetLabel(player, TAG_COMBO_ZJ);
    if(pComboZj) then
        local pComboInfo = MsgRankList.GetComboInfo();
        local nScore = 0;
        if(math.floor(pComboInfo.nComboSelect/1000)>0) then
            nScore = MsgRankList.GetStaticInfo().nComboAwardScore4;
        elseif(math.floor(pComboInfo.nComboSelect/100)>0) then
            nScore = MsgRankList.GetStaticInfo().nComboAwardScore3;
        elseif(math.floor(pComboInfo.nComboSelect/10)>0) then
            nScore = MsgRankList.GetStaticInfo().nComboAwardScore2;
        elseif(math.floor(pComboInfo.nComboSelect/1)>0) then
            nScore = MsgRankList.GetStaticInfo().nComboAwardScore1;
        end
        pComboZj:SetText(string.format("%d%s",nScore, GetTxtPri("ZJ_T01")));
    end
    
    
    
    
    local pEmoney = GetLabel(p.GetTask01(), TAG_REFRESH_EMONEY);
    if(pEmoney) then
        pEmoney:SetText(string.format("%d%s",MsgRankList.GetStaticInfo().nRefreshTaskEmoney,GetTxtPub("shoe")));
    end
    
    
    
    
    --TAG_TASKS
    local pTaskInfo = MsgRankList.GetTaskInfo();
    p.RefreshOneTask(pTaskInfo.nTaskSelect1,pTaskInfo.nTaskType1, 1);
    p.RefreshOneTask(pTaskInfo.nTaskSelect2,pTaskInfo.nTaskType2, 2);
    p.RefreshOneTask(pTaskInfo.nTaskSelect3,pTaskInfo.nTaskType3, 3);
    p.RefreshOneTask(pTaskInfo.nTaskSelect4,pTaskInfo.nTaskType4, 4);
    
end

function p.RefreshOneTask(nt, ntType, nIdx)
    local nLevel = Num1(nt);
    local nType = math.floor(nt/10);
    
    local tags = TAG_TASKS[nIdx];
    local player =  p.GetTask01();
    local pTypeImg = GetImage(player, tags.TAG_TYPE_IMG);
    local pNameLal = GetLabel(player, tags.TAG_NAME_LAB);
    local pDescLal = GetLabel(player, tags.TAG_DESC_LAB);
    local pScoreLab = GetLabel(player, tags.TAG_SCORE_LAB);
    local pJlLab = GetLabel(player, tags.TAG_JL_LAB);
    local pbtn = GetButton(player, tags.TAG_UPGRADE_BTN);

    local nBigType = GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.COMBO_TYPE);
    local sName = GetDataBaseDataS("dailytask_config", nType, DB_DAILYTASK_CONFIG.TYPE_NAME);
    local sDes = GetDataBaseDataS("dailytask_config", nType, DB_DAILYTASK_CONFIG.COMMENT);
	
	local nGrowValue = GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.GROW_VALUE);
	local nBaseValue = GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.BASE_VALUE);
	if nBaseValue > 1000000 then
		nBaseValue = nBaseValue - 4294967296;
	end
	
    local nCount = nLevel*nGrowValue+nBaseValue;

    local nScore =  GetDataBaseDataN("dailytask_level_config", nLevel, DB_DAILYTASK_LEVEL_CONFIG.SCORE);
    
    
    pTypeImg:SetPicture(GetComboImg(nBigType));
    pNameLal:SetText(string.format("[%s] %d%s",sName,nLevel,GetTxtPub("Level")));
    pDescLal:SetText(string.format(sDes,nCount));
    pScoreLab:SetText(nScore..GetTxtPri("ZJ_T01"));
    
    local sSm = GetTxtPub("wu");
    if(ntType>0) then
        local nJl = GetDataBaseDataN("dailytask_level_config", nLevel, JL_TYPE[ntType][1]);
        
        if(ntType == 5) then
            local sName = ItemFunc.GetName(nJl);
            local nCount = GetDataBaseDataN("dailytask_level_config", nLevel, JL_TYPE[ntType][3]);
            sSm = string.format(JL_TYPE[ntType][2],sName,nCount);
        else
            sSm = string.format(JL_TYPE[ntType][2],nJl);
        end
    end
    pJlLab:SetText(sSm);
    
    if(pbtn) then
        pbtn:EnalbeGray(nLevel>=MsgRankList.GetStaticInfo().nMasTaskLevel);
    end
end


function p.RefreshTask02()
    local player = p.GetTask02();
    if(player == nil) then
        return;
    end
    
    local pTaskInfo = MsgRankList.GetTaskInfo();
    local nLevel = Num1(pTaskInfo.nTaskType);
    local nType = math.floor(pTaskInfo.nTaskType/10);
    
    if(nType<=0) then
        return;
    end

    local layer =  p.GetTask02();
    
    local pTypeImg = GetImage(player, TAG_TASK02_PIC);
    local pNameLal = GetLabel(player, TAG_TASK02_NAME);
    local pDescLal = GetLabel(player, TAG_TASK02_MB);
    local pScoreLab = GetLabel(player, TAG_TASK02_ZJ);
    local pJlLab = GetLabel(player, TAG_TASK02_JL);
    local pJDLab = GetLabel(player, TAG_TASK02_RD);
    local pStatusLab = GetLabel(player, TAG_TASK02_STATU);
    local pBtnWCRW = GetButton(player, TAG_LJWC);
    
    
    local nBigType = GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.COMBO_TYPE);
    local sName = GetDataBaseDataS("dailytask_config", nType, DB_DAILYTASK_CONFIG.TYPE_NAME);
    local sDes = GetDataBaseDataS("dailytask_config", nType, DB_DAILYTASK_CONFIG.COMMENT);
    
    local nGrowValue = GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.GROW_VALUE);
	local nBaseValue = GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.BASE_VALUE);
	if nBaseValue > 1000000 then
		nBaseValue = nBaseValue - 4294967296;
	end
	
    local nCount = nLevel*nGrowValue+nBaseValue;
   
   -- local nCount = nLevel*GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.GROW_VALUE)+GetDataBaseDataN("dailytask_config", nType, DB_DAILYTASK_CONFIG.BASE_VALUE);
    local nScore =  GetDataBaseDataN("dailytask_level_config", nLevel, DB_DAILYTASK_LEVEL_CONFIG.SCORE);
    
    
    
    pTypeImg:SetPicture(GetComboImg(nBigType));
    pNameLal:SetText(sName);
    pDescLal:SetText(string.format(sDes,nCount));
    pScoreLab:SetText(nScore..GetTxtPri("ZJ_T01"));
    pJDLab:SetText(string.format("%d/%d",pTaskInfo.nDoItemCount,nCount));
    if(pTaskInfo.nDoItemCount>=nCount) then
        pStatusLab:SetText(GetTxtPri("ZJ_T08"));
        pBtnWCRW:SetTitle(GetTxtPri("ZJ_T09"));
    else
        pStatusLab:SetText(GetTxtPri("ZJ_T23"));
        pBtnWCRW:SetTitle(GetTxtPri("ZJ_T24"));
    end
    
    
    local sSm = GetTxtPub("wu");
    if(pTaskInfo.nTaskTask>0) then
        local nJl = GetDataBaseDataN("dailytask_level_config", nLevel, JL_TYPE[pTaskInfo.nTaskTask][1]);
        if(pTaskInfo.nTaskTask == 5) then
            local sName = ItemFunc.GetName(nJl);
            local nCount = GetDataBaseDataN("dailytask_level_config", nLevel, JL_TYPE[pTaskInfo.nTaskTask][3]);
            sSm = string.format(JL_TYPE[pTaskInfo.nTaskTask][2],sName,nCount);
        else
            sSm = string.format(JL_TYPE[pTaskInfo.nTaskTask][2],nJl);
        end
    end
    pJlLab:SetText(sSm);

end


------------------------------------------------------------------------------
--升级任务提示
function p.UpgrudeTaskTip( param )
    LogInfo("p.UpgrudeTaskTip:[%d]",param);
    local bFlag = p.TaskCountFullPD();
    if(bFlag == false) then
        return true;
    end 
    
    local nReqMoney = MsgRankList.GetStaticInfo().nUpdateTaskEmoney;
    local sTip = string.format(GetTxtPri("ZJ_T13"),nReqMoney);
    CommonDlgNew.ShowYesOrNoDlg(sTip, p.UpgrudeTaskCallback, param);
end
function p.UpgrudeTaskCallback(eventType, param)
    if(eventType == CommonDlgNew.BtnOk) then
        local bFlag = p.TasLevelMaxPD(param);
        if(bFlag == false) then
            return true;
        end
    
        local bFlag = p.UpgrudeTaskEMoneyPD();
        if(bFlag == false) then
            return true;
        end
        MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.UPDATE_TASK, param);
    end
end



------------------------------------------------------------------------------
function p.RefreshTaskTip()
    local bFlag = p.TaskCountFullPD();
    if(bFlag == false) then
        return true;
    end 

    local nReqMoney = MsgRankList.GetStaticInfo().nRefreshTaskEmoney;
    local sTip = string.format(GetTxtPri("ZJ_T14"),nReqMoney);
    CommonDlgNew.ShowYesOrNoDlg(sTip, p.RefreshTaskCallback);
end
function p.RefreshTaskCallback(eventType, param)
    if(eventType == CommonDlgNew.BtnOk) then
        local bFlag = p.RefreshTaskEMoneyPD();
        if(bFlag == false) then
            return true;
        end
        MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.REFRESH_TASK);
    end
end





------------------------------------------------------------------------------
function p.FastTaskTip()
    local nReqMoney = MsgRankList.GetStaticInfo().nFastFinishEmoney;
    local sTip = string.format(GetTxtPri("ZJ_T15"),nReqMoney);
    CommonDlgNew.ShowYesOrNoDlg(sTip, p.FastTaskCallback);
end
function p.FastTaskCallback(eventType, param)
    if(eventType == CommonDlgNew.BtnOk) then
        local bFlag = p.FastTaskEMoneyPD();
        if(bFlag == false) then
            return true;
        end
        MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.FAST_FINISH_TASK);
    end
end


------------------------------------------------------------------------------
function p.RefreshComboTip()
    if(MsgRankList.GetStaticInfo().nMaxTaskNum - MsgRankList.GetTaskInfo().nDoneTaskNum == 0) then
        CommonDlgNew.ShowYesDlg(GetTxtPri("ZJ_T12"));
        return;
    end
    local nReqMoney = MsgRankList.GetStaticInfo().nRefreshComboEmoney;
    local sTip = string.format(GetTxtPri("ZJ_T18"),nReqMoney);
    CommonDlgNew.ShowYesOrNoDlg(sTip, p.RefreshComboCallback);
end
function p.RefreshComboCallback(eventType, param)
    if(eventType == CommonDlgNew.BtnOk) then
        local bFlag = p.RefreshComboEMoneyPD();
        if(bFlag == false) then
            return true;
        end
        MsgRankList.SendDailytaskMsg(DAILYTASK_ACTION.REFRESH_COMBO);
    end
end


------------------------------------------------------------------------------
--刷新任务的金币判断
function p.RefreshTaskEMoneyPD()
    local ngmoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
    if(ngmoney<MsgRankList.GetStaticInfo().nRefreshTaskEmoney) then
        CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("ZJ_T10"),MsgRankList.GetStaticInfo().nRefreshTaskEmoney));
        return false;
    end
    return true;
end

--立即完成任务金币判断
function p.FastTaskEMoneyPD()
    local ngmoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
    if(ngmoney<MsgRankList.GetStaticInfo().nFastFinishEmoney) then
        CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("ZJ_T10"),MsgRankList.GetStaticInfo().nFastFinishEmoney));
        return false;
    end
    return true;
end

--升级任务金币判断
function p.UpgrudeTaskEMoneyPD()
    local ngmoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
    if(ngmoney<MsgRankList.GetStaticInfo().nUpdateTaskEmoney) then
        CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("ZJ_T10"),MsgRankList.GetStaticInfo().nUpdateTaskEmoney));
        return false;
    end
    return true;
end

--任务次数已判断
function p.TaskCountFullPD()
    if(MsgRankList.GetTaskInfo().nDoneTaskNum>=MsgRankList.GetStaticInfo().nMaxTaskNum) then
        CommonDlgNew.ShowYesDlg(GetTxtPri("ZJ_T12"));
        return false;
    end
    return true;
end


--刷新Combo金币判断
function p.RefreshComboEMoneyPD()
    local ngmoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
    if(ngmoney<MsgRankList.GetStaticInfo().nRefreshComboEmoney) then
        CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("ZJ_T10"),MsgRankList.GetStaticInfo().nRefreshComboEmoney));
        return false;
    end
    return true;
end


--任务等级最大判断
function p.TasLevelMaxPD( nIdx )
    local nTypes = {
        MsgRankList.GetTaskInfo().nTaskSelect1,
        MsgRankList.GetTaskInfo().nTaskSelect2,
        MsgRankList.GetTaskInfo().nTaskSelect3,
        MsgRankList.GetTaskInfo().nTaskSelect4,
    }

    if(nTypes[nIdx]%10>=MsgRankList.GetStaticInfo().nMasTaskLevel) then
        CommonDlgNew.ShowYesDlg(GetTxtPri("ZJ_T16"));
        return false;
    end
    return true;
end

------------------------------------------------------------------------------





--获得礼包列表
function p.GetRankListContainer()
	local layer = p.GetLayer()
	local container = GetScrollViewContainer(layer, TAG_RANK_LIST);
	return container;
end


function p.GetTask01()
    local player = p.GetLayer();
    local layer = GetUiLayer(player, TAG_TASK01);
    return layer;
end

function p.GetTask02()
    local player = p.GetLayer();
    local layer = GetUiLayer(player, TAG_TASK02);
    return layer;
end

--获得当前窗口层
function p.GetLayer()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MissionUI);
    return layer;
end


local TAG_E_TEMONEY     = 242;  --
--刷新金钱
function p.refreshMoney()
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MissionUI);
    if(layer == nil) then
        return;
    end
    local ngmoney        = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY).."";
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end

GameDataEvent.Register(GAMEDATAEVENT.USERATTR, "p.refreshMoney", p.refreshMoney);

