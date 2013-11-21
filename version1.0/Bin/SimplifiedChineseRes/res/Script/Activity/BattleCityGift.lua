---------------------------------------------------
--描述: 城市争夺战界面
--时间: 2013.5.31
--作者: sjt
---------------------------------------------------
BattleCityGift = {}
local p = BattleCityGift
local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local ctrl_tag = {btn_close=23,btn_get=21,txt_gain=128}

local function GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattlecityGiftUI);
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
	layer:SetTag(NMAINSCENECHILDTAG.BattlecityGiftUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("city_battle/city_battle_gift.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ctrl_tag.btn_close == tag then                   --关闭
            CloseUI(NMAINSCENECHILDTAG.BattlecityGiftUI);
		elseif ctrl_tag.btn_get == tag then
			MsgBattleCity.GetStorage()
			CloseUI(NMAINSCENECHILDTAG.BattlecityGiftUI);
		end
	end
	return true
end

function p.HandleBattleCityStorageInfo(money,stone,shenma)
	if(IsUIShow(NMAINSCENECHILDTAG.BattlecityGiftUI))then
		local txt = string.format(GetTxtPri("BattleCityGift"),money,shenma,stone)
		local label_txt = GetLabel(GetParent(),ctrl_tag.txt_gain)
		label_txt:SetText(txt)
	end
end

print("BattleCityGiftEnd")