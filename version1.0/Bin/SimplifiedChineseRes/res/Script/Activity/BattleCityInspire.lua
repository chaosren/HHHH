---------------------------------------------------
--描述: 城市争夺战鼓舞界面
--时间: 2013.5.31
--作者: sjt
---------------------------------------------------
BattleCityInspire = {}
local p = BattleCityInspire
local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;
local self_leftCount = 0
local ctrl_tag = {txt_free_rest=17,btn_reset=18,btn_close=23,btn_inspire_1=7,btn_inspire_2=8,
	btn_inspire_3=9,btn_inspire_4=10,btn_inspire_5=11,txt_describe=13,btn_use=15,txt_name_1=61}

local defaultCount = 2
local maxCount = 5
local self_encInfo = {}
local self_lastChecked = 1

local function GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattlecityInspireUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end


local function GetENIconPic(icon)
    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "city_battle/inspire1.png" ), false);
    Pic:Cut( _G.CGRectMake( 0+80*icon, 0, 80, 80) );
    return Pic
end

local function GetENLockPic()
    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "city_battle/inspire2.png" ), false);
    return Pic
end

local function GetENInvalidPic()
    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "city_battle/inspire3.png" ), false);
    return Pic
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
	layer:SetTag(NMAINSCENECHILDTAG.BattlecityInspireUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);

    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("city_battle/city_battle_inspire.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
    local btn_reset = GetButton(layer,ctrl_tag.btn_reset)
    btn_reset:SetTitle(GetTxtPri("UNLOCK_RESET"))
	return true;
end

local function DoUseEN(id,param)
    if (CommonDlgNew.BtnOk == id ) then
        MsgBattleCity.Encourage(self_lastChecked-1)
        ShowLoadBar()
    end
end

local function DoUseENReset(id,param)
    if (CommonDlgNew.BtnOk == id ) then
        MsgBattleCity.ResetEncourageByGold()
        ShowLoadBar()
    end
end

local function DoUseENUnlock(id,param)
    if (CommonDlgNew.BtnOk == id ) then
        MsgBattleCity.UnlockEncourage(self_lastChecked-1)
        ShowLoadBar()
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ctrl_tag.btn_close == tag then                   --关闭
            CloseUI(NMAINSCENECHILDTAG.BattlecityInspireUI);
		elseif ctrl_tag.btn_use == tag then
			if(self_encInfo[self_lastChecked]==nil)then
				--解锁
				  local nNeedEMoney = BattleCity.GetDbConfigValue(BattleCity.DATA_CONFIG_ID.UNLOCK_SPRIER_EMONEY);
				   --要用的数据对应的id枚举  
                CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("BattleCityUnlockEN"), nNeedEMoney),DoUseENUnlock, true );
				
			else
                if(BattleCity.playerInfo.encourageID~=0)then
                    CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("BattleCityReplaceEN"),self_encInfo[self_lastChecked].name),DoUseEN, true );
                else
                    CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("BattleCityAskUseEN"),self_encInfo[self_lastChecked].name),DoUseEN, true );
                end
			end
		elseif ctrl_tag.btn_reset == tag then
            if(self_leftCount==0)then
				  local nNeedEMoney = BattleCity.GetDbConfigValue(BattleCity.DATA_CONFIG_ID.RESET_SPRIER_EMONEY);
                CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("BattleCityUseGoldENReset"), nNeedEMoney),DoUseENReset, true );
            else
                MsgBattleCity.ResetEncourageByGold()
                ShowLoadBar()
            end
		elseif(tag>=ctrl_tag.btn_inspire_1 and tag<=ctrl_tag.btn_inspire_5) then
			local btnLast = GetButton(GetParent(),ctrl_tag.btn_inspire_1+self_lastChecked-1)
			btnLast:SetChecked(false)
			local btn = GetButton(GetParent(),tag)
			btn:SetChecked(true)
			local idx = tag-ctrl_tag.btn_inspire_1+1
			self_lastChecked = idx
			local label_desc = GetLabel(GetParent(),ctrl_tag.txt_describe)
			local btn_use = GetButton(GetParent(),ctrl_tag.btn_use)
			if(self_encInfo[idx]==nil)then
				--解锁
				--label_desc:SetText("UNLOCK")
				btn_use:SetTitle(GetTxtPri("UNLOCK_ENCOURAGE"))
				btn_use:EnalbeGray(false)
			elseif(self_encInfo[idx].id==0)then
				label_desc:SetText("")
				btn_use:SetTitle(GetTxtPri("USE_ENCOURAGE"))
				btn_use:EnalbeGray(true)
			else
				label_desc:SetText(self_encInfo[tag-ctrl_tag.btn_inspire_1+1].desc)
				btn_use:SetTitle(GetTxtPri("USE_ENCOURAGE"))
				btn_use:EnalbeGray(false)
			end
		end
	end
	return true
end


--鼓舞的信息显示等
function p.HandleEncourageInfo(leftCount,encourages)
    self_leftCount = leftCount
    
	for i=1,maxCount,1 do
		LogInfo("id=%d,level=%d",encourages[i][1],encourages[i][2])
		local btn = GetButton(GetParent(),ctrl_tag.btn_inspire_1+i-1)
		 btn:SetFocus(false);
		 --默认设置第一项为焦点项
        if(i==1)then
            btn:SetFocus(true)
        end
        if(encourages[i][1]==65535)then    
			--btn:SetTitle("LOCK")
            btn:SetImage(GetENLockPic())
			self_encInfo[i] = nil
            local label_name = GetLabel(GetParent(),ctrl_tag.txt_name_1+i-1)
            label_name:SetText("")
		elseif(encourages[i][1]==0)then
			self_encInfo[i] = {}
			self_encInfo[i].id = encourages[i][1]
			self_encInfo[i].level = encourages[i][2]
		    btn:SetImage(GetENInvalidPic())
			--btn:SetTitle("EMPTY")
            local label_name = GetLabel(GetParent(),ctrl_tag.txt_name_1+i-1)
            label_name:SetText("")
		else
			self_encInfo[i] = {}
			self_encInfo[i].icon = GetDataBaseDataN("encourage_config",encourages[i][1],DB_ENCOURAGE_CONFIG.ICON);
			self_encInfo[i].name = GetDataBaseDataS("encourage_config",encourages[i][1],DB_ENCOURAGE_CONFIG.NAME);
			self_encInfo[i].desc = GetDataBaseDataS("encourage_config",encourages[i][1],DB_ENCOURAGE_CONFIG.INFO);
			self_encInfo[i].id = encourages[i][1]
			self_encInfo[i].level = encourages[i][2]
			LogInfo("name=%s,desc=%s",self_encInfo[i].name,self_encInfo[i].desc)
			--btn:SetTitle(self_encInfo[i].name)
            btn:SetImage(GetENIconPic(self_encInfo[i].icon-1))
            local label_name = GetLabel(GetParent(),ctrl_tag.txt_name_1+i-1)
            label_name:SetText(string.format(GetTxtPri("BattleCityCurEN"),self_encInfo[i].level,self_encInfo[i].name))
		end
	end
	
	--免费重置次数
    local label_free_reset = GetLabel(GetParent(),ctrl_tag.txt_free_rest)
    LogInfo("BattleCity:label free reset=%s",string.format(GetTxtPri("BattleCityResetENCount"),leftCount))
    
    if leftCount == 0 then
		 local nNeedEMoney = BattleCity.GetDbConfigValue(BattleCity.DATA_CONFIG_ID.RESET_SPRIER_EMONEY);
        label_free_reset:SetText(string.format(GetTxtPri("BattleCityUseGoldENResetTip"), nNeedEMoney))
    else
        label_free_reset:SetText(string.format(GetTxtPri("BattleCityResetENCount"),leftCount))
    end
    
	--默认选择第一个
	local btn = GetButton(GetParent(),ctrl_tag.btn_inspire_1)
	btn:SetChecked(true)
	self_lastChecked = 1
	local label_desc = GetLabel(GetParent(),ctrl_tag.txt_describe)
	local btn_use = GetButton(GetParent(),ctrl_tag.btn_use)
	btn_use:SetTitle(GetTxtPri("USE_ENCOURAGE"))
	if(self_encInfo[1].id==0)then
		label_desc:SetText("")
		btn_use:EnalbeGray(true)
	else
		label_desc:SetText(self_encInfo[1].desc)
		btn_use:EnalbeGray(false)
	end
end

print("BattleCityInspire end")