---------------------------------------------------
--描述: 血战跳關提示
--时间: 2012.12.2
--作者: tzq
---------------------------------------------------
---------------------------------------------------

BloodBattleJump = {}
local p = BloodBattleJump;
local UI_ZORDER				= 5010;	--UILayerZOrder.ActivityLayer--盖在聊天按钮上的ZORDER

local ID_BTN_CLOSE = 49;
local ID_BTN_CHOICE = 36;
local ID_TEXT_MONEY_JUMP = 88;
local ID_TEXT_EMONEY_JUMP = 89;
local ID_CHECK_FST = 32;
local ID_CHECK_SND = 33;
local ID_CHECK_TRD = 34;

p.tbJumpStatic = {};
p.Layer = {};
p.nSelFlag = 0;

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
	layer:SetTag(NMAINSCENECHILDTAG.BloodBattleJumpUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UI_ZORDER + 1);
	p.Layer = layer;
	
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("blood_battle/bb_choose.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free(); 
	
	p.InitData();
	p.RefreshUI();   
	
	return true;
end


function p.InitData()
	p.nSelFlag = 0;
	p.tbJumpStatic = {};  
 
    local Idlist = GetDataBaseIdList("bloodbattle_config");
    
    for i, v in pairs(Idlist) do
        local Record = {}; 
        Record.id = v;
        Record.nReqMoney = GetDataBaseDataN("bloodbattle_config", v, DB_BLOODBATTLE_CONFIG.REQ_MONEY);                --截粮次数上限
        Record.nJumpLayer1 = GetDataBaseDataN("bloodbattle_config", v, DB_BLOODBATTLE_CONFIG.JUMP_LAYER1);           --单次被截上限       
        Record.nReqEmoney = GetDataBaseDataN("bloodbattle_config", v, DB_BLOODBATTLE_CONFIG.REQ_EMONEY);                --护送次数上限 
        Record.nJumpLayer2 = GetDataBaseDataN("bloodbattle_config", v, DB_BLOODBATTLE_CONFIG.JUMP_LAYER2);                --刷新粮车品质次数上限
		 table.insert(p.tbJumpStatic, Record);        
    end
end


function p.GetDataFromId(nId)
	if not CheckN(nId) then
		return;
	end
	
    for i, v in pairs(p.tbJumpStatic) do
		if v.id ==  nId then
			return v.nReqMoney, v.nJumpLayer1, v.nReqEmoney, v.nJumpLayer2;
		end     
    end
end


function p.RefreshUI()
	if not CheckP(p.Layer) then
		return false;
	end
	
	local nReqMoney, nJumpLayer1, nReqEmoney, nJumpLayer2 = p.GetDataFromId(BloodBattle.tUserInfor.nJumpId);
	if not CheckN(nReqMoney) or not CheckN(nJumpLayer1) or not CheckN(nReqEmoney) or not CheckN(nJumpLayer2) then
		return false
	end
	
	--顯示提示語
	local strPmt1 = string.format(GetTxtPri("BB_I10"), nReqMoney, nJumpLayer1);
	local strPmt2 = string.format(GetTxtPri("BB_I11"), nReqEmoney, nJumpLayer2);
	
	SetLabel(p.Layer, ID_TEXT_MONEY_JUMP, strPmt1);
	SetLabel(p.Layer, ID_TEXT_EMONEY_JUMP, strPmt2);
	
	--設置選中狀態
	local pChkFst = RecursiveCheckBox ( p.Layer, {ID_CHECK_FST} );
	local pChkSnd = RecursiveCheckBox ( p.Layer, {ID_CHECK_SND} );	
	local pChkTrd = RecursiveCheckBox ( p.Layer, {ID_CHECK_TRD} );
	if not CheckP(pChkFst) or not CheckP(pChkSnd) or not CheckP(pChkTrd) then
		return false
	end	
		
	pChkFst:SetSelect(true);
	pChkSnd:SetSelect(false);
	pChkTrd:SetSelect(false);	
end

function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_CLOSE == tag then   
			CloseUI(NMAINSCENECHILDTAG.BloodBattleJumpUI);
		elseif ID_BTN_CHOICE == tag then  
			if 	p.nSelFlag == 0 then
				CloseUI(NMAINSCENECHILDTAG.BloodBattleJumpUI);
				MsgBloodBattle.SendMsgChallenge( BloodBattle.nDifficulty );
			end
			
			local nReqMoney, nJumpLayer1, nReqEmoney, nJumpLayer2 = p.GetDataFromId(BloodBattle.tUserInfor.nJumpId);
			if not CheckN(nReqMoney) or not CheckN(nJumpLayer1) or not CheckN(nReqEmoney) or not CheckN(nJumpLayer2) then
				return true;
			end

			--花銷判斷
			if p.nSelFlag == 1 then
				local nMoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY);
				if nMoney < nReqMoney then
					CommonDlgNew.ShowYesDlg( GetTxtPri("EM_I1"), nil, nil, 10 );
					return true;
				end
			elseif p.nSelFlag == 2 then
				local nEmoney= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_EMONEY );
				if nEmoney < nReqEmoney then
					CommonDlgNew.ShowYesDlg( GetTxtPri("CUSU_T8"), nil, nil, 10 );
					return true;
				end
			end
			
			CloseUI(NMAINSCENECHILDTAG.BloodBattleJumpUI);
			MsgBloodBattle.SendMsgJump(p.nSelFlag);
		end
		
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		local pChkFst = RecursiveCheckBox ( p.Layer, {ID_CHECK_FST} );
		local pChkSnd = RecursiveCheckBox ( p.Layer, {ID_CHECK_SND} );	
		local pChkTrd = RecursiveCheckBox ( p.Layer, {ID_CHECK_TRD} );
		if not CheckP(pChkFst) or not CheckP(pChkSnd) or not CheckP(pChkTrd) then
			return true;
		end	
		
		if ( ID_CHECK_FST == tag ) then
			pChkFst:SetSelect(true);
			pChkSnd:SetSelect(false);
			pChkTrd:SetSelect(false);	
			p.nSelFlag = 0;
		elseif ( ID_CHECK_SND == tag ) then 
			pChkFst:SetSelect(false);
			pChkSnd:SetSelect(true);
			pChkTrd:SetSelect(false);	
			p.nSelFlag = 1;
		elseif ( ID_CHECK_TRD == tag ) then
			pChkFst:SetSelect(false);
			pChkSnd:SetSelect(false);
			pChkTrd:SetSelect(true);
			p.nSelFlag = 2;	
		end
	end
	
	return true;
end