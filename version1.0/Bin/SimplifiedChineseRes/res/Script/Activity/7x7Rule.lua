SG7x7Rule = {}
local p = SG7x7Rule

local ctrl_tag = {btn_close=49,txt_rule=87}
local info_txt="玩法：在一块 7×7 的方格棋盘上，你要做的就是横向、纵向、斜向连接四个相同颜色的方块，以完成消除。每次移动方块后，都会有新的方块出现；只要一个回合中有方块被消除，这一回合就不会有新方块出现。连续消除会有额外的分数奖励，游戏难度会随着分数慢慢加大，主要是每一回合新增的方块数目会增加。\n\n奖励：玩家获取的最高积分将被记录，每日22:00结算，排名前二十的玩家将会获得奖励。"
local function GetParent()
    local scene = GetSMGameScene()
    if nil==scene then
        return nil
    end
    
    local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.SG7x7RuleUI)
    if nil==layer then
        return nil
    end
    
	local label_txt = GetLabel(layer,ctrl_tag.txt_rule)
	label_txt:SetText(GetTxtPri("SG7x7Rule"))
	
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

