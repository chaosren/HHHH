---------------------------------------------------
--描述: 跨服竞技场奖励查看页面
--时间: 2013.9.10
--作者: tzq
---------------------------------------------------
CrossArenaReward = {}
local p = CrossArenaReward;

local ID_BTN_OK = 38;


function p.LoadUI()
	local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.CrossArenaReward);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);

	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("DragonRank/DragonRank_1.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free(); 
	


	return true;
end




function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_OK == tag then   
			CloseUI(NMAINSCENECHILDTAG.CrossArenaReward);
		end
	end
	
	return true;
end
