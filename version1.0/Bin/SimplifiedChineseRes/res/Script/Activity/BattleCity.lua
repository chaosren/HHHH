---------------------------------------------------
--描述: 城市争夺战界面
--时间: 2013.5.28
--作者: sjt
---------------------------------------------------
BattleCity = {}
local p = BattleCity;
local CONTAINTER_X = 0
local CONTAINTER_Y = 0

local ctrl_tag = {btn_gzsm=8,btn_close=7,btn_inspire=6,btn_city1=101,btn_city2=102,
	btn_city3=103,btn_city4=104,txt_city1_name=31,txt_city1_synname=41,
	txt_capture_city=22,txt_debuff_time=30,txt_city1_protect_time=24,txt_encourage=23,btn_gift=28,btn_reset_debuff=35,
    txt_reset_time=37}
p.playerInfo = {}
p.cityInfos = {}
reset_timer_tag = nil
reset_timer_time = 0
-----------------------------获取父层layer---------------------------------
local function GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleCityUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI ()
	LogInfo("BattleCity:LoadUI()")
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end

--------------------添加城市争夺战主信息（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleCityUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);

    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
    
    p.playerInfo = {}
    p.cityInfos = {}

	uiLoad:Load("city_battle/city_battle.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
	local BtnClose = GetButton(layer, ctrl_tag.btn_close);
    BtnClose:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    return true;
end

local function DoUseResetDebuff(id,param)
    if (CommonDlgNew.BtnOk == id ) then
        MsgBattleCity.ResetDebuff()
        ShowLoadBar()
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ctrl_tag.btn_close == tag then                   --关闭    
			MsgBattleCity.Leave()
            CloseUI(NMAINSCENECHILDTAG.BattleCityUI);
		elseif tag>=ctrl_tag.btn_city1 and tag<=ctrl_tag.btn_city4 then
			--打开城市界面
			MsgBattleCity.GetCityInfo(tag-ctrl_tag.btn_city1+1)
			BattleCityCity.LoadUI()
			ShowLoadBar()
		elseif tag==ctrl_tag.btn_inspire then
			MsgBattleCity.GetEncourageInfo()
			BattleCityInspire.LoadUI()
			ShowLoadBar()
		elseif tag==ctrl_tag.btn_gift then
			MsgBattleCity.GetStorageInfo()
			BattleCityGift.LoadUI()
			ShowLoadBar()
        elseif tag==ctrl_tag.btn_reset_debuff then
            CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("ResetDebuff"),10),DoUseResetDebuff, true );
        elseif tag==ctrl_tag.btn_gzsm then
            BattleCityRule.LoadUI()
        end
	end
    
	return true;
end

function p.HandleBattleCityInfo(cityID,synID,attCount,defCount,synname)
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityCityUI))then
		BattleCityCity.RefreshData(cityID,p.cityInfos[cityID].cityName,synname,attCount,defCount,synID)
	end
end

--UINT32 unAttID;
--UINT32 unDefID;
--BYTE btState;	//0输1赢2易主
--BYTE btAttSide;	//攻击方阵营,0驻守,1攻击
--attname
--defname
function p.HandleBattleCityHistory(cityID,historys)
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityRecordUI))then
		BattleCityRecord.HandleBattleCityHistory(cityId,historys)
	end
end

p.debuff_timer_tag = nil
local debuff_timer_time = 0
p.protect_timer_tag = {}
local protect_timer_time  = {}
local function OnTimer(tag)
	if(tag==p.debuff_timer_tag)then
		debuff_timer_time = debuff_timer_time-1
		if(debuff_timer_time>0)then
			local label_debuff_time = GetLabel(GetParent(),ctrl_tag.txt_debuff_time)
			label_debuff_time:SetText(string.format("%02d:%02d:%02d",math.floor(debuff_timer_time/3600),math.floor((debuff_timer_time%3600)/60),debuff_timer_time%60))
		else
			UnRegisterTimer(p.debuff_timer_tag);
            p.debuff_timer_tag = nil
			local label_debuff_time = GetLabel(GetParent(),ctrl_tag.txt_debuff_time)
			label_debuff_time:SetText(GetTxtPri("Common_wu"))
            local btn_reset = GetButton(GetParent(),ctrl_tag.btn_reset_debuff)
            btn_reset:EnalbeGray(true)
			if(IsUIShow(NMAINSCENECHILDTAG.BattleCityCityUI))then
				BattleCityCity.CheckEnterState()
			end
		end
    elseif(tag==reset_timer_tag)then
        reset_timer_time = reset_timer_time-1
        local label_reset_time = GetLabel(GetParent(),ctrl_tag.txt_reset_time)
        if(label_reset_time~=nil)then
            label_reset_time:SetText(string.format("%02d:%02d:%02d",math.floor(reset_timer_time/3600),math.floor((reset_timer_time%3600)/60),reset_timer_time%60))
        end
	else
		for k,v in pairs(p.protect_timer_tag) do
			if(tag==p.protect_timer_tag[k])then
				protect_timer_time[k] = protect_timer_time[k]-1
				if(protect_timer_time[k]>0)then
					local label_protectTime = GetLabel(GetParent(),ctrl_tag.txt_city1_protect_time+k-1)
					label_protectTime:SetText(string.format("%02d:%02d:%02d",math.floor(protect_timer_time[k]/3600),math.floor((protect_timer_time[k]%3600)/60),protect_timer_time[k]%60))
				else
					UnRegisterTimer(p.protect_timer_tag[k]);
					p.protect_timer_tag = nil
					local label_protectTime = GetLabel(GetParent(),ctrl_tag.txt_city1_protect_time+k-1)
					label_protectTime:SetText("")
					if(IsUIShow(NMAINSCENECHILDTAG.BattleCityCityUI))then
						BattleCityCity.CheckEnterState()
					end
				end
				break;
			end
		end
	end
end

function p.HandleBattleCityPlayerInfo(cityID,side,encourageID,encourageLevel,debufferTime,synID,debufferCanReset)
	p.playerInfo.cityID = cityID
	p.playerInfo.side = side
	p.playerInfo.encourageID = encourageID
	p.playerInfo.debufferTime = debufferTime
	p.playerInfo.debufferCanReset = debufferCanReset
	p.playerInfo.synID = synID
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityUI)) then --界面是否打开
		LogInfo("BattleCity:HandleBattleCityPlayerInfo,debufferTime=%d",debufferTime)
	
		local label_capture_city = GetLabel(GetParent(),ctrl_tag.txt_capture_city)
		local label_debuff_time = GetLabel(GetParent(),ctrl_tag.txt_debuff_time)
		if(cityID==0)then
			label_capture_city:SetText(GetTxtPri("Common_wu"))
		else
			label_capture_city:SetText(p.cityInfos[cityID].cityName)
		end
		local btn_reset = GetButton(GetParent(),ctrl_tag.btn_reset_debuff)
        if(debufferTime==0)then
            if(p.debuff_timer_tag~=nil)then
                UnRegisterTimer(p.debuff_timer_tag);
                p.debuff_timer_tag = nil
            end
			label_debuff_time:SetText(GetTxtPri("Common_wu"))
            btn_reset:EnalbeGray(true)
		else
			debuff_timer_time = debufferTime
			label_debuff_time:SetText(string.format("%02d:%02d:%02d",math.floor(debufferTime/3600),math.floor((debufferTime%3600)/60),debufferTime%60))
			if(p.debuff_timer_tag==nil)then
				p.debuff_timer_tag = RegisterTimer(OnTimer, 1)
			end
            if(debufferCanReset~=0)then
                btn_reset:EnalbeGray(false)
            else
                btn_reset:EnalbeGray(true)
            end
		end
		local label_enc = GetLabel(GetParent(),ctrl_tag.txt_encourage)
		if(encourageID~=0)then
			local name = string.format(GetTxtPri("BattleCityCurEN"),encourageLevel,GetDataBaseDataS("encourage_config",encourageID,DB_ENCOURAGE_CONFIG.NAME));
			label_enc:SetText(name)
		else
			label_enc:SetText(GetTxtPri("Common_wu"))
		end
		return
	end
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityCityUI))then
		BattleCityCity.CheckEnterState()
	end
end

function p.HandleBattleCityBattleInfo(cityID,defValue,weak)
	--只会发送一次,作为界面打开的判定条件
	CloseUI(NMAINSCENECHILDTAG.BattleCityCityUI);
	--打开对战界面
	BattleCityGuardInfo.LoadUI(cityID,defValue,weak)
end

--playerid
--level
--name
function p.HandleBattleCityPlayerList(cityID,side,players)
	BattleCityGuardInfo.HandleBattleCityPlayerList(cityID,side,players)
end

--change 0增加,1删除,2,清除
function p.HandleBattleCityChangePlayerList(cityID,change,playerID,level,name)
	
end

function p.HandleBattleCityEncourageInfo(leftCount,encourages)
	BattleCityInspire.HandleEncourageInfo(leftCount,encourages)
end

function p.HandleBattleCityStorageInfo(money,stone,shenMa)
	BattleCityGift.HandleBattleCityStorageInfo(money,stone,shenMa)
end

function p.HandleBattleCityActionRet(action,ret)
	if(action==MsgBattleCity.ActionType.ActionGetBattleHistory)then
		--打开界面
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionGetCityInfo)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionEnterList)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionLeaveList)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionAttack)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionGetEncourageInfo)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionUnlockEncourage)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionEncourage)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionResetEncourageByGold)then
		CloseLoadBar()
	elseif(action==MsgBattleCity.ActionType.ActionGetStorageInfo)then
		CloseLoadBar()
    elseif(action==MsgBattleCity.ActionType.ActionResetDebuff)then
        CloseLoadBar()
	end
end

function p.HandleBattleCityMapInfo(resetLeftTime,citys)
    reset_timer_time = resetLeftTime
    local label_reset_time = GetLabel(GetParent(),ctrl_tag.txt_reset_time)
    label_reset_time:SetText(string.format("%02d:%02d:%02d",math.floor(reset_timer_time/3600),math.floor((reset_timer_time%3600)/60),reset_timer_time%60))
    reset_timer_tag = RegisterTimer(OnTimer,1)
	p.cityInfos = citys
	for _,city in pairs(citys) do
		LogInfo("BattleCity:HandleBattleCityMapInfo cityID=%d,protectTime=%d",city.cityID,city.protectTime)
		local label_name = GetLabel(GetParent(),ctrl_tag.txt_city1_name+city.cityID-1)
		local label_synname = GetLabel(GetParent(),ctrl_tag.txt_city1_synname+city.cityID-1)
		local label_protectTime = GetLabel(GetParent(),ctrl_tag.txt_city1_protect_time+city.cityID-1)
		label_name:SetText(city.cityName)
		label_synname:SetText(city.synName)
		protect_timer_time[city.cityID] = city.protectTime
		p.protect_timer_tag[city.cityID] = nil
		if(protect_timer_time[city.cityID]>0)then
			label_protectTime:SetText(string.format("%02d:%02d:%02d",math.floor(protect_timer_time[city.cityID]/3600),math.floor((protect_timer_time[city.cityID]%3600)/60),protect_timer_time[city.cityID]%60))
			if(p.protect_timer_tag[city.cityID]==nil)then
				p.protect_timer_tag[city.cityID] = RegisterTimer(OnTimer, 1)
			end
		else
			if(p.protect_timer_tag[city.cityID]~=nil)then
				UnRegisterTimer(p.protect_timer_tag[city.cityID])
				p.protect_timer_tag[city.cityID] = nil
			end
			label_protectTime:SetText("")
		end
	end
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityCityUI))then
		BattleCityCity.CheckEnterState()
	end
	for k,v in pairs(p.protect_timer_tag) do
		LogInfo("k=%d,v=%d",k,v)
	end
	LogInfo("########FFFF%d",#p.protect_timer_tag)
end