---------------------------------------------------
--描述: 城市争夺战防守界面
--时间: 2013.5.31
--作者: sjt
---------------------------------------------------
BattleCityRecord = {}
local p = BattleCityRecord;
local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local ctrl_tag = {btn_close=23,txt_record=7,list_records=17}
local ViewSize = CGSizeMake(220*ScaleFactor, 44*ScaleFactor)

local function GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleCityRecordUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI ()
	--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end

    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleCityRecordUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);

    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("city_battle/city_battle_news.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
	local ListContainer  = GetScrollViewContainer(layer, ctrl_tag.list_records);
    if (ListContainer == nil) then 
        return true;
    end

    ListContainer:SetViewSize(ViewSize);
    ListContainer:RemoveAllView();
    return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ctrl_tag.btn_close == tag then                   --关闭
            CloseUI(NMAINSCENECHILDTAG.BattleCityRecordUI);
		end
	end
	return true;
end

local function FormatTime(rectime)
	local cur = os.time()
	if(rectime>cur)then
		return GetTxtPri("BattleCityInvalidTime")
	elseif((cur-rectime)/(3600*24)>=1)then
		return string.format(GetTxtPri("BattleCityDay"),math.floor((cur-rectime)/(3600*24)))
	elseif((cur-rectime)/3600>=1)then
		return string.format(GetTxtPri("BattleCityHour"),math.floor((cur-rectime)/3600))
	elseif((cur-rectime)/60>=6)then
		return string.format(GetTxtPri("BattleCityMin"),math.floor((cur-rectime)/60))
	else
		--return string.format(GetTxtPri("BattleCitySecond"),math.floor((cur-rectime)+1))
        return GetTxtPri("BattleCityInvalidTime")
	end
end

function p.HandleBattleCityHistory(cityId,historys)
	local ListContainer  = GetScrollViewContainer(GetParent(), ctrl_tag.list_records);
	ListContainer:RemoveAllView();
	LogInfo("BattleCity:HandleBattleCityHistory");
	for _,history in pairs(historys) do
		LogInfo("BattleCity:HandleBattleCityHistory,attId=%d,defid=%d,attname=%s,defname=%s,side=%d,state=%d,synname=%s,rectime",history.attID,history.defID,history.attname,history.defname,history.side,history.state,history.synname,history.rectime)
		local view = createUIScrollView();
		ListContainer:SetViewSize(ViewSize);
		view:Init(false);
		ListContainer:AddView(view);
		
		--初始化ui
		local uiLoad = createNDUILoad();
		uiLoad:Load("city_battle/city_battle_news_list.ini", view, p.OnUIEvent, 0, 0);
		local label_record = GetLabel(view, ctrl_tag.txt_record);
		if(history.defID==0)then
			if((history.state==1 and history.side==1) or
				(history.state==0 and history.side==2)) then--防守方赢
				local sfmt = GetTxtPri("BattleCityRecordAttNpcLose")
				local record = string.format(sfmt,FormatTime(history.rectime),history.attname)
				label_record:SetText(record)
			elseif((history.state==0 and history.side==1) or
				(history.state==1 and history.side==2)) then--防守方输
				local sfmt = GetTxtPri("BattleCityRecordAttNpcWin")
				local record = string.format(sfmt,FormatTime(history.rectime),history.attname)
				label_record:SetText(record)
			else
				local sfmt = GetTxtPri("BattleCityRecordAttNpcOccupy")
				local record = string.format(sfmt,FormatTime(history.rectime),history.attname,history.synname)
				label_record:SetText(record)
			end
		else
			if((history.state==1 and history.side==1) or
				(history.state==0 and history.side==2)) then--防守方赢
				local sfmt = GetTxtPri("BattleCityRecordDefWin")
				local record = string.format(sfmt,FormatTime(history.rectime),history.defname,history.attname,history.attname)
				label_record:SetText(record)
			elseif((history.state==0 and history.side==1) or
				(history.state==1 and history.side==2)) then--防守方输
				local sfmt = GetTxtPri("BattleCityRecordAttWin")
				local record = string.format(sfmt,FormatTime(history.rectime),history.attname,history.defname,history.defname)
				label_record:SetText(record)
			else
				local sfmt = GetTxtPri("BattleCityRecordOccupy")
				local record = string.format(sfmt,FormatTime(history.rectime),history.attname,history.defname,history.synname)
				label_record:SetText(record)
			end
		end
	end
end

print("BattleCityGuardInfo end")