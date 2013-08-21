---------------------------------------------------
--描述: 城市争夺战防守界面
--时间: 2013.5.31
--作者: sjt
---------------------------------------------------
BattleCityGuardInfo = {}
local p = BattleCityGuardInfo;
local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local ctrl_tag = {btn_close=15,btn_leave=23,btn_enter=22,txt_defvalue=21,txt_weak=25,list_guard=17,txt_player_name=3,txt_player_level=4,btn_attack=2,txt_title=14}
local ViewSize = CGSizeMake(240*ScaleFactor, 35*ScaleFactor)

local self_cityID = 0

local function GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleCityGuardInfoUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI (cityID,defValue,weak)
	LogInfo("BattleCityGuardInfo:LoadUI()，cityID=%d,defValue=%d,weak=%d",cityID,defValue,weak)
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
	layer:SetTag(NMAINSCENECHILDTAG.BattleCityGuardInfoUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);

    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	self_cityID = cityID;

	uiLoad:Load("city_battle/city_battle_list1.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
	local label_defvalue = GetLabel(layer,ctrl_tag.txt_defvalue)
	local label_weak = GetLabel(layer,ctrl_tag.txt_weak)
	LogInfo("%s",tostring(label_weak))
	label_defvalue:SetText(tostring(defValue))
	label_weak:SetText(tostring(weak/100).."%");
	
	local label_title = GetLabel(layer,ctrl_tag.txt_title)
	if(BattleCity.playerInfo.side==1)then
		label_title:SetText(GetTxtPri("GUARD_TITLE_ATT"))
	else
		label_title:SetText(GetTxtPri("GUARD_TITLE_DEF"))
	end
	
	local ListContainer  = GetScrollViewContainer(layer, ctrl_tag.list_guard);
    if (ListContainer == nil) then 
        return true;
    end
    ListContainer:EnableScrollBar(true);
    ListContainer:SetViewSize(ViewSize);
    ListContainer:RemoveAllView();
    return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ctrl_tag.btn_close == tag then                   --关闭    
            CloseUI(NMAINSCENECHILDTAG.BattleCityGuardInfoUI);
		elseif ctrl_tag.btn_leave == tag then
			--发送进入
			ShowLoadBar()
			MsgBattleCity.LeaveList()
			CloseUI(NMAINSCENECHILDTAG.BattleCityGuardInfoUI);
		else
			local btn = ConverToButton(uiNode);
			if(btn == nil) then
                return true;
            end
            if ctrl_tag.btn_attack == tag then
				ShowLoadBar()       
                local nId = btn:GetParam1();
                MsgBattleCity.Attack(nId)
				CloseUI(NMAINSCENECHILDTAG.BattleCityGuardInfoUI);
            end
		end
	end
	return true;
end

function p.HandleBattleCityPlayerList(cityID,side,players)
	local ListContainer  = GetScrollViewContainer(GetParent(), ctrl_tag.list_guard);
	ListContainer:RemoveAllView();
	LogInfo("BattleCity:HandleBattleCityPlayerList");
	if(#players==0 and side==1)then
		--只要显示一行
		local view = createUIScrollView();
		ListContainer:SetViewSize(ViewSize);
		view:Init(false);
		view:SetViewId(0);
		view:SetTag(0);  
		ListContainer:AddView(view);
		
		--初始化ui
		local uiLoad = createNDUILoad();
		uiLoad:Load("city_battle/city_battle_listitem1.ini", view, p.OnUIEvent, 0, 0);
		
		local btn = GetButton(view, ctrl_tag.btn_attack);
		btn:SetParam1(0)
		SetLabel(view, ctrl_tag.txt_player_name, GetTxtPri("BattleCity_GuardNPC"));
		SetLabel(view, ctrl_tag.txt_player_level, "--")
	end
	for _,player in pairs(players) do
		LogInfo("playerID=%d,name=%s,level=%d",player.playerID,player.name,player.level)
		local view = createUIScrollView();
		ListContainer:SetViewSize(ViewSize);
		view:Init(false);
		view:SetViewId(player.playerID);
		view:SetTag(player.playerID);  
		ListContainer:AddView(view);
		
		--初始化ui
		local uiLoad = createNDUILoad();
		uiLoad:Load("city_battle/city_battle_listitem1.ini", view, p.OnUIEvent, 0, 0);
		
		local btn = GetButton(view, ctrl_tag.btn_attack);
		btn:SetParam1(player.playerID)
		SetLabel(view, ctrl_tag.txt_player_name, player.name);
		SetLabel(view, ctrl_tag.txt_player_level, tostring(player.level))
	end
end

print("BattleCityGuardInfo end")