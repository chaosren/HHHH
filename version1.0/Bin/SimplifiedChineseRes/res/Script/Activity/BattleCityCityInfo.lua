---------------------------------------------------
--描述: 城市争夺战城市界面
--时间: 2013.5.28
--作者: sjt
---------------------------------------------------
BattleCityCity = {}
local p = BattleCityCity;
local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local ctrl_tag = {btn_close=23,btn_history=21,btn_enter=22,txt_cityname=13,txt_citydesc=14,txt_synname=18,txt_attcount=20,txt_defcount=19}

local city_descs = {"天下之奇峻，地扼蜀陇咽喉；势控攻守要冲，兵家必争之地。","许都之北，从河北进军河南地界的军事要冲之地。","曾是兵家逐鹿的战场。东汉末年东吴水军都督周瑜在此操练水师。","蜀汉国都，商业发达，乃三国时期六大都市之一。"}

local city_gain = {{70000,5,4},{50000,4,3},{40000,3,2},{30000,2,1}}
local city_gain_time = {1,3,1}

local self_cityID = 0
local self_synID = 0
local self_enterType = "enter"
local function GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleCityCityUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI (cityID,cityName,synName,attCount,defCount)
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
	layer:SetTag(NMAINSCENECHILDTAG.BattleCityCityUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);

    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("city_battle/city_battle_info.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
	return true;
end

function p.RefreshData(cityID,cityName,synName,attCount,defCount,synID)
	LogInfo("BattleCityCity:InitData()，cityID=%d,cityName=%s,synname=%s,attcount=%d,defcount=%d",cityID,cityName,synName,attCount,defCount)
	self_cityID = cityID;
	self_synID = synID;
	local layer = GetParent()
    local label_cityname = GetLabel(layer,ctrl_tag.txt_cityname)
	label_cityname:SetText(cityName)
    local label_citydesc = GetLabel(layer,ctrl_tag.txt_citydesc)
    local txt1 = string.format(GetTxtPri("BattleCitySilverGain"),city_gain[cityID][1],city_gain_time[1])
    local txt2 = string.format(GetTxtPri("BattleCityStoneGain"),city_gain[cityID][2],city_gain_time[2])
    local txt3 = string.format(GetTxtPri("BattleCitySMGain"),city_gain[cityID][3],city_gain_time[3])
    --label_citydesc:SetText(city_descs[cityID])
    label_citydesc:SetText(txt1.."\n"..txt2.."\n"..txt3)
	local label_synname = GetLabel(layer,ctrl_tag.txt_synname)
	label_synname:SetText(synName)
	local label_attcount = GetLabel(layer,ctrl_tag.txt_attcount)
	label_attcount:SetText(tostring(attCount))
	local label_defcount = GetLabel(layer,ctrl_tag.txt_defcount)
	label_defcount:SetText(tostring(defCount))
	local btn_attordef = GetButton(layer,ctrl_tag.btn_enter)
	if(BattleCity.playerInfo.cityID==cityID)then	--所在的城池
		btn_attordef:SetTitle(GetTxtPri("ENTER_BTN_TEXT_ENTER"));
		self_enterType = "enter"
	else
		if(BattleCity.playerInfo.synID==self_synID and self_synID~=0)then	--自己的军团领地
			btn_attordef:SetTitle(GetTxtPri("ENTER_BTN_TEXT_DEF"));
			self_enterType = "def"
		else
			btn_attordef:SetTitle(GetTxtPri("ENTER_BTN_TEXT_ATT"));
			self_enterType = "att"
		end
	end
	p.CheckEnterState()
end

local function DoEnter(nId,param)
	if (CommonDlgNew.BtnOk == nId ) then
		ShowLoadBar()
		MsgBattleCity.EnterList(self_cityID)
	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ctrl_tag.btn_close == tag then                   --关闭    
            CloseUI(NMAINSCENECHILDTAG.BattleCityCityUI);
		elseif ctrl_tag.btn_enter == tag then
			--发送进入
			--MsgBattleCity.EnterList(self_cityID)
			if(self_enterType=="att")then
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("MSG_ASK_FOR_ATT"),BattleCity.cityInfos[self_cityID].cityName),DoEnter, true );
			elseif(self_enterType=="def")then
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("MSG_ASK_FOR_DEF"),BattleCity.cityInfos[self_cityID].cityName),DoEnter, true );
			else
				ShowLoadBar()
				MsgBattleCity.EnterList(self_cityID)
			end
		elseif ctrl_tag.btn_history == tag then
			MsgBattleCity.GetBattleHistory(self_cityID)
			ShowLoadBar()
			BattleCityRecord.LoadUI()
		end
	end
	return true;
end

function p.CheckEnterState()
    return
    --[[
	LogInfo("BattleCity:CheckEnterState self_cityID=%d",self_cityID)
	local btn = GetButton(GetParent(),ctrl_tag.btn_enter)
	btn:EnalbeGray(false)
    if(self_synID==0)then
        btn:EnableGray(true)
        return
    end
	if(BattleCity.debuff_timer_tag~=nil)then
		btn:EnalbeGray(true)
	elseif(BattleCity.playerInfo.cityID~=0 and BattleCity.playerInfo.cityID~=self_cityID)then
		btn:EnalbeGray(true)
	elseif(BattleCity.protect_timer_tag[self_cityID]~=nil and BattleCity.playerInfo.synID~=self_synID)then
		btn:EnalbeGray(true)
	end
    --]]
end

print("BattleCityCityInfo end")