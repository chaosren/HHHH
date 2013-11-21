---------------------------------------------------
--描述: 跨服竞技场奖励查看页面
--时间: 2013.9.10
--作者: tzq
---------------------------------------------------
CrossArenaReward = {}
local p = CrossArenaReward;

local ID_BTN_OK = 38;
local ID_TEXT_REWARD = 39;
p.DbCrossArenaAwardData = {};

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
	
	p.InitDbData();
	p.RefreshUI();

	return true;
end

function p.InitDbData()
    local ids = GetDataBaseIdList("worldbattle_award_config");
    p.DbCrossArenaAwardData = {};

    for i,v in ipairs(ids) do
		local record = {};
		record.id = v;
		record.nMinRank = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.RANK_MIN);  
		record.nMaxRank = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.RANK_MAX);  
		record.nMoney = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.MONEY);  	
		record.nEMoney = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.EMONEY); 
		record.nExploit = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.EXPLOIT); 
		record.nRepute = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.REPUTE); 
		record.nSope = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.SOPH); 	
		table.insert(p.DbCrossArenaAwardData, record);
    end
end
	
	
function p.RefreshUI()
	local layer = GetSMGameSceneLayerByTag(NMAINSCENECHILDTAG.CrossArenaReward);
	
	for i, v in ipairs(p.DbCrossArenaAwardData) do
		if CrossArenaUI.UserInfo.usRank >= v.nMinRank and
		   CrossArenaUI.UserInfo.usRank <= v.nMaxRank then
				local ShowText = "";
				--ShowText = ShowText..GetTxtPri("CrossArena_02").."\n";
				if v.nMoney ~= 0 then
					ShowText = ShowText .."  "..GetTxtPub("coin").."X"..v.nMoney.."\n";
				end
				
				if v.nEMoney ~= 0 then
					ShowText = ShowText .."  "..GetTxtPub("shoe").."X"..v.nEMoney.."\n";
				end	

				if v.nExploit ~= 0 then
					ShowText = ShowText .."  "..GetTxtPub("Exploit").."X"..v.nExploit.."\n";
				end	

				if v.nRepute ~= 0 then
					ShowText = ShowText .."  "..GetTxtPub("ShenWan").."X"..v.nRepute.."\n";
				end	

				if v.nSope ~= 0 then
					ShowText = ShowText .."  "..GetTxtPub("JianHun").."X"..v.nSope.."\n";
				end	
				
				SetLabel(layer, ID_TEXT_REWARD, ShowText);	
		   return;
		end 
	end
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
