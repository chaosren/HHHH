---------------------------------------------------
--描述: 跨服竞技场规则说明页
--时间: 2013.8.30
--作者: tzq
---------------------------------------------------
CrossArenaRule = {}
local p = CrossArenaRule;

local ID_BTN_CLOSE = 49;
local ID_CONTAINER = 6;
local ID_TEXT_RULE = 87;



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
	layer:SetTag(NMAINSCENECHILDTAG.CrossArenaRule);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);

	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("DragonRank/DragonRank_rule.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free(); 
	
	--初始化
	p.InitData();

	return true;
end


function p.InitData()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.CrossArenaRule);
	if nil == layer then
		return nil;
	end
    
	local Container = GetScrollViewContainer(layer, ID_CONTAINER);
	Container:EnableScrollBar(true);

	local ListViewSize = CGSizeMake(430*CoordScaleX, 3000*CoordScaleY);
	local view = createUIScrollView();
	Container:SetViewSize(ListViewSize);
	view:Init(false);
	view:SetViewId(1);
	view:SetTag(1);  
	--local str = "哪里来的已大队1哪里来的已大队2哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队61\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队62\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队63\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队64\n哪里来的已大队1\n哪里来的已大队25\n哪里来的已大队35\n哪里来的已大队45\n哪里来的已大队55\n哪里来的已大队65\n";
  	local str = "哪里来的已大队1\n哪里来的已大队25\n哪里来的已大队35\n哪里来的已大队45\n哪里来的已大队55\n哪里来的已大队65\n";

	pLabelTips = _G.CreateColorLabel( str, 10, 430*CoordScaleX );
	pLabelTips:SetFrameRect(CGRectMake(0, 0, 430*CoordScaleX, 3000 * CoordScaleY));
	view:AddChild(pLabelTips);	

	Container:AddView(view);



	local RuleLable = GetLabel(layer, ID_TEXT_RULE);
	--RuleLable:SetText("哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n哪里来的已大队1\n哪里来的已大队2\n哪里来的已大队3\n哪里来的已大队4\n哪里来的已大队5\n哪里来的已大队6\n");

end
	




function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_CLOSE == tag then   
			CloseUI(NMAINSCENECHILDTAG.CrossArenaRule);
		end
	end
	
	return true;
end
