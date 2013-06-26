SG7x7Board = {}
local p = SG7x7Board

local ctrl_tag = {btn_close=49,txt_score=84,txt_name=79,txt_rank=5,list_container=50}

local function GetParent()
    local scene = GetSMGameScene()
    if nil==scene then
        return nil
    end
    
    local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.SG7x7BoardUI)
    if nil==layer then
        return nil
    end
    
    return layer
end

function p.LoadUI()
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加每日签到层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SG7x7BoardUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,5001 );
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("7x7_rank.ini", layer, p.OnUIEvent, 0, 0);
    
    local listContainer = GetScrollViewContainer(layer,ctrl_tag.list_container)
    listContainer:SetViewSize(CGSizeMake(260*ScaleFactor,25*ScaleFactor))
    listContainer:RemoveAllView()
    return true
end

function p.OnUIEvent(uiNode, uEventType, param)
    local layer = GetParent()
    local tag = uiNode:GetTag()
    if uEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ctrl_tag.btn_close == tag then
            CloseUI(NMAINSCENECHILDTAG.SG7x7BoardUI)
        end
    end
    return true
end

function p.ClearBoard()
    local listContainer = GetScrollViewContainer(GetParent(),ctrl_tag.list_container)
    listContainer:SetViewSize(CGSizeMake(260*ScaleFactor,25*ScaleFactor))
    listContainer:RemoveAllView()
end

function p.SetBoard(ranks)
    local listContainer = GetScrollViewContainer(GetParent(),ctrl_tag.list_container)
    listContainer:SetViewSize(CGSizeMake(260*ScaleFactor,25*ScaleFactor))
    listContainer:RemoveAllView()
    
    for i,rank in ipairs(ranks) do
        local view = createUIScrollView()
        view:Init(false);
        listContainer:AddView(view)
    
        local uiLoad = createNDUILoad()
        uiLoad:Load("7x7_L.ini",view,p.OnUIEvent,0,0)

        local label_name = GetLabel(view,ctrl_tag.txt_name)
        local label_rank = GetLabel(view,ctrl_tag.txt_rank)
        local label_score = GetLabel(view,ctrl_tag.txt_score)
        label_name:SetText(rank.name)
        label_score:SetText(tostring(rank.score))
        label_rank:SetText(tostring(i))
    end
end
