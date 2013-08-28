---------------------------------------------------
--����: ��������ս����
--ʱ��: 2013.5.28
--����: sjt
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

--ս��ʤ����ʱ��
p.suc_cd_timer_tag = nil
suc_cd_timer_time = 0

--db battlecity_config
p.DbBattleCityData = {};

--Ҫ�õ����ݶ�Ӧ��idö��  
p.DATA_CONFIG_ID =
{
    RESET_SPRIER_EMONEY = 15;   --���ù����������
    UNLOCK_SPRIER_EMONEY  = 16;   --���i����������

	MAX_FAILE_CD_TIME  = 30;  --ս��CDʱ���ۼ�����(��)
	RESET_CD_EMONEY_FIRST = 31; --��һ������CDÿ������Ҫ�Ľ��
	RESET_CD_EMONEY_GROW = 32; --����CDÿ���ۼӵĽ��
	
};

-----------------------------��ȡ����layer---------------------------------
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
    --------------------�����Ϸ������------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end

--------------------��ӳ�������ս����Ϣ�����ڣ�---------------------------------------
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
    
    --��ȡ���ݿ�battlecity_config�е�����
    p.InitDbData();
    
    return true;
end

function p.InitDbData()
    --��ȡid����
    local ids = GetDataBaseIdList("battlecity_config");
    p.DbBattleCityData = {};

    for i,v in ipairs(ids) do
		p.DbBattleCityData[v] = GetDataBaseDataN("battlecity_config", v, DB_BATTLECITY_CONFIG.CONFIG_VALUE); 
    end
end


function p.GetDbConfigValue(nId)
    --��ȡid����
    local nRet = p.DbBattleCityData[nId];
	
	if nRet == nil then
		nRet = 0;
	end

    return nRet;
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
		if ctrl_tag.btn_close == tag then                   --�ر�    
			MsgBattleCity.Leave()
			p.LeaveBattleCity();
           CloseUI(NMAINSCENECHILDTAG.BattleCityUI);
		elseif tag>=ctrl_tag.btn_city1 and tag<=ctrl_tag.btn_city4 then
			--�򿪳��н���
			BattleCityCity.LoadUI()
			MsgBattleCity.GetCityInfo(tag-ctrl_tag.btn_city1+1)
			ShowLoadBar()
		elseif tag==ctrl_tag.btn_inspire then   --ս����
			MsgBattleCity.GetEncourageInfo()
			BattleCityInspire.LoadUI()
			ShowLoadBar()
		elseif tag==ctrl_tag.btn_gift then
			MsgBattleCity.GetStorageInfo()
			BattleCityGift.LoadUI()
			ShowLoadBar()
		elseif tag==ctrl_tag.btn_reset_debuff then
			local nFirstNeed = p.GetDbConfigValue(p.DATA_CONFIG_ID.RESET_CD_EMONEY_FIRST);
			local nGrowNeed = p.GetDbConfigValue(p.DATA_CONFIG_ID.RESET_CD_EMONEY_GROW);
			local nTimeMinute = 0;
			if p.debuff_timer_time > 0 then
				nTimeMinute = math.floor((p.debuff_timer_time - 1)/60 + 1);
			end
			local nNeedEMoney = (nFirstNeed + nGrowNeed * p.playerInfo.HasCdTimes)/10 * nTimeMinute;
			
			CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("BattleCityResetDebuff"), nNeedEMoney), DoUseResetDebuff, true );
		elseif tag==ctrl_tag.btn_gzsm then   --����˵��
			BattleCityRule.LoadUI()
		end
	end
    
	return true;
end

function p.LeaveBattleCity()

	if p.debuff_timer_tag ~= nil then
		UnRegisterTimer(p.debuff_timer_tag);
		p.debuff_timer_tag = nil;
	end
	
	if reset_timer_tag ~= nil then
		UnRegisterTimer(reset_timer_tag);
		reset_timer_tag = nil
	end
	reset_timer_time = 0;
	
	for i,v in pairs(p.protect_timer_tag) do
		if v ~= nil then
			UnRegisterTimer(v);
		end
	end	
	
end


function p.HandleBattleCityInfo(cityID,synID,attCount,defCount,synname)
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityCityUI))then
		BattleCityCity.RefreshData(cityID,p.cityInfos[cityID].cityName,synname,attCount,defCount,synID)
	end
end

--UINT32 unAttID;
--UINT32 unDefID;
--BYTE btState;	//0��1Ӯ2����
--BYTE btAttSide;	//��������Ӫ,0פ��,1����
--attname
--defname
function p.HandleBattleCityHistory(cityID,historys)
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityRecordUI))then
		BattleCityRecord.HandleBattleCityHistory(cityId,historys)
	end
end

p.debuff_timer_tag = nil
p.debuff_timer_time = 0
p.protect_timer_tag = {}
local protect_timer_time  = {}
local function OnTimer(tag)
	if(tag==p.debuff_timer_tag)then
		p.debuff_timer_time = p.debuff_timer_time-1
		if(p.debuff_timer_time>0)then
			local label_debuff_time = GetLabel(GetParent(),ctrl_tag.txt_debuff_time)
			label_debuff_time:SetText(string.format("%02d:%02d:%02d",math.floor(p.debuff_timer_time/3600),math.floor((p.debuff_timer_time%3600)/60),p.debuff_timer_time%60))
		
			local nMaxCdTime = p.GetDbConfigValue(p.DATA_CONFIG_ID.MAX_FAILE_CD_TIME);
			if p.debuff_timer_time >= nMaxCdTime then
				label_debuff_time:SetFontColor(ccc4(255,0,0,255));
			else
				label_debuff_time:SetFontColor(ccc4(251, 165, 46, 255));
			end
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
		if reset_timer_time > 1 then
			reset_timer_time = reset_timer_time-1
		else
			reset_timer_time = 0;
		end

		local label_reset_time = GetLabel(GetParent(),ctrl_tag.txt_reset_time)
		if(label_reset_time~=nil)then
			label_reset_time:SetText(string.format("%02d:%02d:%02d",math.floor(reset_timer_time/3600),math.floor((reset_timer_time%3600)/60),reset_timer_time%60))
		end
		
	elseif (tag== p.suc_cd_timer_tag) then
		if suc_cd_timer_time > 1 then
			suc_cd_timer_time = suc_cd_timer_time - 1;
		else
			suc_cd_timer_time = 0;
			UnRegisterTimer(p.suc_cd_timer_tag);
			p.suc_cd_timer_tag = nil
		end
	else
		for k,v in pairs(p.protect_timer_tag) do
			
			if(p.protect_timer_tag[k] ~= nil and tag==p.protect_timer_tag[k])then
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


--���빥���Եص������Ϣ
function p.HandleBattleCityPlayerInfo(cityID,side,encourageID,encourageLevel,debufferTime,synID,debufferCanReset, hasCdTimes)
	p.playerInfo.cityID = cityID
	p.playerInfo.side = side
	p.playerInfo.encourageID = encourageID
	p.playerInfo.debufferTime = debufferTime
	p.playerInfo.synID = synID
	p.playerInfo.HasCdTimes = hasCdTimes;
	
	if(IsUIShow(NMAINSCENECHILDTAG.BattleCityUI)) then --�����ӵؽ����Ƿ��
		LogInfo("BattleCity:HandleBattleCityPlayerInfo,debufferTime=%d",debufferTime)
	
		--��ʾ������ڳǳ�
		local label_capture_city = GetLabel(GetParent(),ctrl_tag.txt_capture_city)
		if(cityID==0)then
			label_capture_city:SetText(GetTxtPri("Common_wu"))
		else
			label_capture_city:SetText(p.cityInfos[cityID].cityName)
		end
		
		--�ٴβ�ս��ȴʱ���������ȴʱ�䰴ť����
		local label_debuff_time = GetLabel(GetParent(),ctrl_tag.txt_debuff_time)
		label_debuff_time:SetFontColor(ccc4(251, 165, 46, 255));
		
		local btn_reset = GetButton(GetParent(),ctrl_tag.btn_reset_debuff)
		
		
       if(debufferTime==0)then
            if(p.debuff_timer_tag~=nil)then
                UnRegisterTimer(p.debuff_timer_tag);
                p.debuff_timer_tag = nil
            end
			label_debuff_time:SetText(GetTxtPri("Common_wu"))
            btn_reset:EnalbeGray(true)
		else
			p.debuff_timer_time = debufferTime
			label_debuff_time:SetText(string.format("%02d:%02d:%02d",math.floor(debufferTime/3600),math.floor((debufferTime%3600)/60),debufferTime%60))
			
			local nMaxCdTime = p.GetDbConfigValue(p.DATA_CONFIG_ID.MAX_FAILE_CD_TIME);
			if debufferTime >= nMaxCdTime then
				label_debuff_time:SetFontColor(ccc4(255,0,0,255));
			else
				label_debuff_time:SetFontColor(ccc4(251, 165, 46, 255));
			end
			
    
			if(p.debuff_timer_tag==nil)then
				p.debuff_timer_tag = RegisterTimer(OnTimer, 1)
			end
   
           btn_reset:EnalbeGray(false)
		end
		
		--����ʹ�õ�ս���� ��ʾ����
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
	--ֻ�ᷢ��һ��,��Ϊ����򿪵��ж�����
	CloseUI(NMAINSCENECHILDTAG.BattleCityCityUI);
	--�򿪶�ս����
	BattleCityGuardInfo.LoadUI(cityID,defValue,weak)
end

--playerid
--level
--name
function p.HandleBattleCityPlayerList(cityID,side,players)
	BattleCityGuardInfo.HandleBattleCityPlayerList(cityID,side,players)
end

--change 0����,1ɾ��,2,���
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
		--�򿪽���
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

--����˽��յ��Ĺ����Ե�������Ϣ
function p.HandleBattleCityMapInfo(resetLeftTime,citys)

	if not IsUIShow(NMAINSCENECHILDTAG.BattleCityUI) then
		return;
	end
	
    reset_timer_time = resetLeftTime
    
    --��ʾ����ʱ����Ϣ���Լ������ͻ��˶�ʱ��
    local label_reset_time = GetLabel(GetParent(),ctrl_tag.txt_reset_time)
    label_reset_time:SetText(string.format("%02d:%02d:%02d", math.floor(reset_timer_time/3600), math.floor((reset_timer_time%3600)/60), reset_timer_time%60))
    reset_timer_tag = RegisterTimer(OnTimer,1)
    
    
	p.cityInfos = citys
	for _,city in pairs(citys) do
		LogInfo("BattleCity:HandleBattleCityMapInfo cityID=%d,protectTime=%d",city.cityID,city.protectTime)
		
		--���ó������ƣ�����ռ����ţ������ܱ���ʱ��
		local label_name = GetLabel(GetParent(),ctrl_tag.txt_city1_name+city.cityID-1);
		local label_synname = GetLabel(GetParent(),ctrl_tag.txt_city1_synname+city.cityID-1)
		local label_protectTime = GetLabel(GetParent(),ctrl_tag.txt_city1_protect_time+city.cityID-1)
		label_name:SetText(city.cityName)
		label_synname:SetText(city.synName)
		
		protect_timer_time[city.cityID] = city.protectTime
		
		--��ʱ��
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


function p.HandleSucCdTime(nTimes)
	if p.suc_cd_timer_tag ~= nil then
		UnRegisterTimer(p.suc_cd_timer_tag);
		p.suc_cd_timer_tag = nil;
	end

	suc_cd_timer_time = nTimes;
	if nTimes ~= 0 then
	   p.suc_cd_timer_tag = RegisterTimer(OnTimer,1)
	end
end

function p.GetSucCdTime()
	return suc_cd_timer_time;
end