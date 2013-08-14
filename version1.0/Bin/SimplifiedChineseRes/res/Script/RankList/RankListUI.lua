---------------------------------------------------
--描述: 名人堂界面
--时间: 2013.1.9
--作者: chh
---------------------------------------------------
RankListUI = {}
local p = RankListUI;

--名人堂数据记录表
p.tbRankInfo = {};
p.tbCtrlId = {bgPicId = 1, desTextId = 7, rankListContainerId = 19, timeTextId = 20,};
p.tbCtrlView = {viewPic = 1, rankText = 2, nameText = 3, desText = 4,};

local RANK_BG_ICON_FILE = "/Ranklist/Ranklist";
local PLAYER_COLOR = { ccc4(251,165,46,255), ccc4(255,0,0,255), };
local TAG_CLOSE = 3;

local STAR_DES = {
    GetTxtPri("RLUI_T1"),
    GetTxtPri("RLUI_T2"),
    GetTxtPri("RLUI_T3"),
    GetTxtPri("RLUI_T4"),
    GetTxtPri("RLUI_T5"),
}

--for test  begin
--[[
RankListUI.tbRankInfo.nBgIcon = 1;
RankListUI.tbRankInfo.nBeginTime = 20130528;	 --活动开始时间
RankListUI.tbRankInfo.nEndTime = 20130605;	     --活动结束时间
RankListUI.tbRankInfo.strDec = "这是个非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常长文字的测试";        --活动描述
MsgRankList.btActionType = 1;
RankListUI.tbRankInfo.tbRankList = {{nRank = 1, nNum = 20, sName = "路人甲"}, 
                                 {nRank = 2, nNum = 19, sName = "路人乙"}, 
                                 {nRank = 3, nNum = 18, sName = "路人丙"},
                                 {nRank = 4, nNum = 17, sName = "路人丁"}, 
                                 {nRank = 5, nNum = 16, sName = "路人戊"}, 
                                 {nRank = 6, nNum = 15, sName = "路人庚"},};
                                 ]]
                                 
--for test end

function p.LoadUI()

	if IsUIShow(NMAINSCENECHILDTAG.RankListUI) then
		--p.RefreshUI();
		return;
	end
	
	-----------------获得游戏主场景------------------------------------------
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
	layer:SetTag(NMAINSCENECHILDTAG.RankListUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);
    
	-----------------初始化ui添加到 layer 层上----------------------------------
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("Ranklist/Ranklist_Main.ini", layer, p.OnUIEvent, 0, 0);
	
	--刷新时间
    MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_REFRESHTIME);
	--刷新数据
	p.RefreshUI()

	local closeBtn=GetButton(layer,TAG_CLOSE);
	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    CloseLoadBar();
	return true;
end


function p.RefreshUI()
	local layer = p.GetLayer();
	if layer == nil then
		return;
	end
	local nBgIcon = RankListUI.tbRankInfo.nBgIcon;
	if nBgIcon <= 0 then
		return;
	end
	
	--显示背景图片
	local ctrBgImg = GetImage(layer, p.tbCtrlId.bgPicId);  
	if  ctrBgImg ~= nil then
		local nBgIcon = RankListUI.tbRankInfo.nBgIcon;
		local pool = DefaultPicPool();
		local bgPic = nil;
		if nBgIcon ~= nil then
			if nBgIcon < 10 then
				bgPic = pool:AddPicture(GetSMImg00Path(RANK_BG_ICON_FILE.."0"..nBgIcon..".png"), false);
			else
				bgPic = pool:AddPicture(GetSMImg00Path(RANK_BG_ICON_FILE..nBgIcon..".png"), false);
			end
			
			if bgPic ~= nil then
				ctrBgImg:SetPicture(bgPic, true);
			end
		end
	end 
	
	--显示描述文字
	local ctrDesText = GetLabel(layer, p.tbCtrlId.desTextId); 
	if ctrDesText ~= nil then
		local strDes = ""; 
		if RankListUI.tbRankInfo.nBeginTime ~= nil and
			RankListUI.tbRankInfo.nEndTime ~= nil then
			strDes = strDes..GetTxtPri("RANK_01");
			strDes = strDes..ConvertIntTimeToString(RankListUI.tbRankInfo.nBeginTime, RankListUI.tbRankInfo.nEndTime);

			if RankListUI.tbRankInfo.strDec ~= nil then
				strDes = strDes.."\r\n";
				strDes = strDes..GetTxtPri("RANK_02");
				strDes = strDes..RankListUI.tbRankInfo.strDec;
			end
			ctrDesText:SetText(strDes);
		end
	end
	
	--显示排行的数据
	p.ShowRankData();
end






--获得当前窗口层
function p.GetLayer()
	local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankListUI);
	return layer;
end

--显示排行的数据
function p.ShowRankData()
	local layer = p.GetLayer();
	local container = GetScrollViewContainer(layer, p.tbCtrlId.rankListContainerId);
	if container == nil then
		return;
	end
	
	container:RemoveAllView();
	container:EnableScrollBar(true);
    
    for i, v in ipairs(RankListUI.tbRankInfo.tbRankList) do
        p.CreateRankItem(container, v);
	end
end

function p.CreateRankItem(ctrContainer, info)

    local view = createUIScrollView();
  
    view:Init(false);
    view:SetViewId(info.nRank);
    view:SetTag(info.nRank);
    view:SetMovableViewer(ctrContainer);
    view:SetScrollViewer(ctrContainer);
    view:SetContainer(ctrContainer);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        return false;
    end

    uiLoad:Load("Ranklist/Ranklist_L.ini", view, nil, 0, 0);
    
    --设置大小
    local pic = GetImage(view, p.tbCtrlView.viewPic);
    ctrContainer:SetViewSize(pic:GetFrameRect().size);
       
    --实例化每一项
    p.RefreshRankItem(view, info);
    ctrContainer:AddView(view);
    uiLoad:Free();
end

function p.RefreshRankItem(view, v)
    local desc = "";
    local rankType = MsgRankList.GetRankType();
    
    --p.tbCtrlView = {viewPic = 1, rankText = 2, nameText = 3, desText = 4,};
    
	if(rankType == MsgRankList.RANKING_ACT.ACT_PET_LEVEL) then    --等级排行
		desc = string.format("%d%s", v.nNum, GetTxtPub("Level"));
    elseif(rankType == MsgRankList.RANKING_ACT.ACT_REPUTE) then
        if v.nAddRepute > 0 then
                desc = string.format("%s:%d",GetTxtPub("ShenWan"), v.nAddRepute);
        else
                desc = string.format("%s:%d",GetTxtPub("ShenWan"),v.nNum);
        end
    elseif(rankType == MsgRankList.RANKING_ACT.ACT_SOPH) then
        if v.nAddSoph > 0 then
                desc = string.format("%d", v.nAddSoph);
        else
                desc = string.format("%s%d%s",STAR_DES[v.nNum], v.nStar, GetTxtPri("BB2_T5"),GetTxtPub("JianHun"));
        end
    elseif(rankType == MsgRankList.RANKING_ACT.ACT_STAGE) then
        local nTaskId = 50000+math.floor(v.nNum/10);
        local nTitle = GetDataBaseDataS("task_type", nTaskId, DB_TASK_TYPE.NAME);
        desc = string.format("%s",nTitle);
    elseif(rankType == MsgRankList.RANKING_ACT.ACT_MONEY) then
        desc = string.format("%s:%d",GetTxtPub("coin"),v.nNum);
    elseif(rankType == MsgRankList.RANKING_ACT.ACT_MOUNT_LEVEL) then
        desc = string.format(GetTxtPri("RLUI_TURN"),p.GetTurn(v.nNum),p.GetStar(v.nNum));
    elseif(rankType == MsgRankList.RANKING_ACT.ACT_ELITE_STAGE) then
		local nTitle	= AffixBossFunc.findName(v.nNum);
		desc = string.format("%s",nTitle);
    end
    
    --排名
    local l_rank = SetLabel(view, p.tbCtrlView.rankText, string.format("%d",v.nRank));
   
    
    local sName 		= GetRoleBasicDataS(GetPlayerId(), USER_ATTR.USER_ATTR_NAME);
    local l_name = SetLabel(view, p.tbCtrlView.nameText, v.sName);
    local l_desc = SetLabel(view, p.tbCtrlView.desText, desc);
    if(v.sName == sName) then
        l_rank:SetFontColor(PLAYER_COLOR[2]);
        l_name:SetFontColor(PLAYER_COLOR[2]);
        l_desc:SetFontColor(PLAYER_COLOR[2]);
    else
        l_rank:SetFontColor(PLAYER_COLOR[1]);
        l_name:SetFontColor(PLAYER_COLOR[1]);
        l_desc:SetFontColor(PLAYER_COLOR[1]);
    end
end

local nTimeSeconds = 0;
local TIMETIMER = nil;
function p.RefreshTime(nTime)
    nTimeSeconds = nTime;
    if(TIMETIMER == nil) then
        TIMETIMER = RegisterTimer(p.TimeTimer, 1, "RankListUI.TimeTimer");
    end
end


function p.TimeTimer()

    nTimeSeconds = nTimeSeconds - 1;
    
    local layer = p.GetLayer();
    if(layer == nil or nTimeSeconds<0) then
        UnRegisterTimer(TIMETIMER);
        TIMETIMER = nil;
    end
    
    if(layer) then
        local label = GetLabel(layer, p.tbCtrlId.timeTextId);
        
        if(label) then
            local h = nTimeSeconds / 3600;
            local m = nTimeSeconds % 3600 / 60;
            local s = nTimeSeconds % 60;
            if(nTimeSeconds <= 0) then
                m = 0;
                s = 0;
                local rankType = MsgRankList.GetRankType();
                MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_REFRESHTIME);
                MsgRankList.SendGetListInfoMsg(rankType);
            end
            label:SetText(string.format("%02d:%02d:%02d",h,m,s));
        end
    end
end

--获得转数
function p.GetTurn(star)
    if(star==0) then
        return 0;
    end
    local starS = math.ceil(star/10) - 1;
    return starS;
end

--获得星级
function p.GetStar(star)
    if(star == 0) then
        return 0;
    end
    
    local starG = star%10;
    if(starG==0) then
        starG = 10; 
    end
    return starG;
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    
		if TAG_CLOSE == tag then                           
			CloseUI(NMAINSCENECHILDTAG.RankListUI);
		end
        
	end
	return true;
end

