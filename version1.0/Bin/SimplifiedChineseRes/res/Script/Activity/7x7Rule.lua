SG7x7Rule = {}
local p = SG7x7Rule

local ctrl_tag = {btn_close=49,txt_rule=87}
local info_txt="玩法：在一塊 7×7 的方格棋盤上，你要做的就是橫向、縱向、斜向連接四個相同顏色的方塊，以完成消除。每次移動方塊後，都會有新的方塊出現；只要一個回合中有方塊被消除，這一回合就不會有新方塊出現。連續消除會有額外的分數獎勵，遊戲難度會隨著分數慢慢加大，主要是每一回合新增的方塊數目會增加。\n\n獎勵：玩家獲取的最高積分將被記錄，每日22:00結算，排名前二十的玩家將會獲得獎勵。"
local function GetParent()
    local scene = GetSMGameScene()
    if nil==scene then
        return nil
    end
    
    local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.SG7x7RuleUI)
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
	layer:SetTag(NMAINSCENECHILDTAG.SG7x7RuleUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,5001 );
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("7x7_rule.ini", layer, p.OnUIEvent, 0, 0);
    
    local label_txt = GetLabel(layer,ctrl_tag.txt_rule)
    label_txt:SetText(info_txt)
    return true
end

function p.OnUIEvent(uiNode, uEventType, param)
    local layer = GetParent()
    local tag = uiNode:GetTag()
    if uEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ctrl_tag.btn_close == tag then
            CloseUI(NMAINSCENECHILDTAG.SG7x7RuleUI)
        end
    end
    return true
end

