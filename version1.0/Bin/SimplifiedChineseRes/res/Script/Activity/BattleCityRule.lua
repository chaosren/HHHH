BattleCityRule = {}
local p = BattleCityRule

local rule_info = "參加條件：只有軍團成員才能參與《攻城略地》活動。\n\n活動規則：\n  1.《攻城略地》活動每3日重置一次，每次重置后城池為無人占領狀態。\n  2.攻擊城池時，若守城方隊列無任何玩家駐守，將直接攻擊守城NPC，擊敗守城NPC后，城池防御度下降。\n  3.若守城方隊列有玩家駐守，攻擊方可以自行選擇目標攻擊，失敗的一方將退出戰斗隊列并累積一段CD時間內，CD時間達到30分鐘后將無法繼續參戰。（防守方規則相同）\n  4.第一個將城池防御度降為0的玩家所屬軍團成為該城池的擁有者。同時該城池半小時內無法被攻擊。\n  5.占領城池的軍團所屬玩家，將持續獲得占領獎勵，直到城池被其他軍團奪取或者活動重置。（每個軍團只能占領一個城池）\n  6.活動周期內，軍團首次攻占城池將會獲得一次性獎勵。\n  7.占領城池的時間越久，將會累積防守疲勞狀態，使防守難度加大。\n  8.在戰斗隊列中連勝多次的玩家，將會得到額外的個人疲勞狀態。\n"

local ctrl_tag = {btn_close=49,txt_rule=87}
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
	scene:AddChildZ(layer,UILayerZOrder.ActivityLayer );
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("city_battle/city_battle_rule.ini", layer, p.OnUIEvent, 0, 0);
	local label_rule = GetLabel(layer,ctrl_tag.txt_rule)
	label_rule:SetText(rule_info)
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

