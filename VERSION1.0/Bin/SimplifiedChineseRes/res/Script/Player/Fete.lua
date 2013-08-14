---------------------------------------------------
--描述: 祭祀界面
--时间: 2012.4.6
--作者: cl

---------------------------------------------------
local _G = _G;

Fete={}
local p=Fete;

p.mList = {};

--是否消费提示
p.bTwiceConfirm = false;

p.TagClose = 3;

p.TagBtn = {
    106,
    107,
    108,
    109,
};

--增強的圖片按鈕 神農 伏羲 女媧
p.tbIntenceBtnInfo = {};

p.EMoneys = {11,16,17,18,};

p.textEPEnum = {};


function p.LoadUI()
    local scene=GetSMGameScene();
    if scene == nil then
        LogInfo("scene = nil,load BattleFail failed!");
        return;
    end
    local layer = createNDUILayer();
    if layer == nil then
        LogInfo("scene = nil,2");
        return  false;
    end
    
    layer:SetPopupDlgFlag( true );
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Fete);
    local winsize = GetWinSize();
    layer:SetFrameRect(RectFullScreenUILayer);
    --layer:SetBackgroundColor(ccc4(125,125,125,125));
    scene:AddChildZ(layer,145);

    local uiLoad=createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        LogInfo("scene = nil,4");
        return false;
    end
    uiLoad:Load("Fete.ini",layer,p.OnUIEvent,0,0);
    
	p.EpinitData();
    uiLoad:Free();
    p.refreshBtn();
    --p.refresh(0,0,0,0);
    p.refresh();
    
    --设置关闭音效
   	local closeBtn=GetButton(layer,  p.TagClose);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    p.refreshMoney();
    
    --註冊精英特權免費次數變化刷新
    MsgElitePrivilege.EPListener = p.refresh;
end

--for ep begin
function p.EpinitData()
	p.textEPEnum = {};
	
	----祭祀免費功能
	p.textEPEnum[1] = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_SHENNONG_TIME;
	p.textEPEnum[2] = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_PANGU_TIME;
	p.textEPEnum[3] = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_FUXI_TIME;
	p.textEPEnum[4] = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_NVWA_TIME;
	
	--祭祀增強功能
	p.tbIntenceBtnInfo = {};
	--神農 伏羲 女媧 增強按鈕
	p.tbIntenceBtnInfo = { {tag = 102, txt = GetTxtPri("EP_TXT_001"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_SHENNONG_MONEY,}, 
	                     {tag = 103, txt = GetTxtPri("EP_TXT_002"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_FUXI_REPUTE,}, 
	                     {tag = 104, txt = GetTxtPri("EP_TXT_003"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_SACRIFICE_NVWA_STONE,}, };


	--判斷這些增強按鈕是否存在
	for i, v in pairs(p.tbIntenceBtnInfo) do
		local nFreeTime = EPDataConfig.GetEPValue(v.epnum);
	
       local btn = GetButton(p.getUiLayer(), v.tag);
       if nFreeTime > 0 then
			btn:SetVisible(true);
		else
			btn:SetVisible(false);
       end
	end
end
--for ep end


function p.refreshBtn()

     for i,v in ipairs(p.TagBtn) do
        local btn = GetButton(p.getUiLayer(), v);
        local id = p.GetFeteIdByType(i);
        btn:SetParam1(id);
     end
     
end


--获得祭祀ID根据类型
function p.GetFeteIdByType( nType )
    for i,v in ipairs(p.mList) do
        if( v.type == nType ) then
            return v.id;
        end
    end
    return 0;
end

--获得祭祀数据根据ID
function p.GetFeteDataById( nId )
    for i,v in ipairs(p.mList) do
        if( v.id == nId ) then
            return v;
        end
    end
    return nil;
end

function p.OnUIEvent(uiNode,uiEventType,param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        if p.TagClose == tag then                --关闭页面
            CloseUI(NMAINSCENECHILDTAG.Fete);
            return true;
        end
        
        --點擊祭祀的幾個button的处理
        for i, v in pairs(p.TagBtn) do
        
            if v == tag then
              local btn = ConverToButton(uiNode);
				local data = p.GetFeteDataById( btn:GetParam1() );
				
				if data == nil then
					return true;
				end
            
				--先判斷祭祀女媧獲取寶石背包情況
				if data.type == 4 then
					--判断背包是否已满
					if (ItemFunc.IsBagFull(1)) then
						CommonDlgNew.ShowYesDlg(GetTxtPri("EP_TXT_004"), nil, nil, 3);
						return true;
					end
				end

				--判斷是否精英特权免费
				local nEPType = p.textEPEnum[i];
				local nFreeTime = EPDataConfig.GetEPValue(nEPType);
				--非免費
				if nFreeTime == 0 then
				     --金币不足判断
					 local nMoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
					 local nReqMoney = data.reqEMoney;
					 if nMoney < nReqMoney then
						  CommonDlgNew.ShowTipDlg(GetTxtPub("JinBiBuZhu"));
						  return true;
					 end
					 
					 --非免費需要二次確認
					 p.TwiceConfirm( data );
				else
					--免費直接發送請求
					p.SendMsgFete(data.id);
				
				end
				return true;
            end
        end   --end for
        
        
        --点击祭祀增強按鈕的处理(显示提示)
		for i, v in pairs(p.tbIntenceBtnInfo) do
			local nValue = EPDataConfig.GetEPValue(v.epnum);	

			if v.tag == tag then
				if i < 3 then
					nValue = nValue/10;
				end
				
				CommonDlgNew.ShowYesDlg(string.format(v.txt, nValue), nil, nil, 3);
			end
		end
		
			for i, v in pairs(p.tbIntenceBtnInfo) do
		local nFreeTime = EPDataConfig.GetEPValue(v.epnum);
	
       local btn = GetButton(p.getUiLayer(), v.tag);
       if nFreeTime > 0 then
			btn:SetVisible(true);
		else
			btn:SetVisible(false);
       end
	end
		
		
		return true;
    end
end

function p.getUiLayer()
    local scene = GetSMGameScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end

    return layer;
end
function p.processSacrificeList(netdata)
    local nAction = netdata:ReadByte(); --类型：1.取列表 2.返回结果
    
    if nAction == 1 then
        local count	= netdata:ReadByte();
        p.mList = {};
        for i = 1, count do
            local t = {};
            t.id	= netdata:ReadInt();                
            t.type  = netdata:ReadInt();            --祭祀类型:1,2,3,4
            t.num   = netdata:ReadInt();            --祭祀次数
            t.reqEMoney = netdata:ReadInt();        --祭祀金额
            LogInfo("t.id:[%d],t.type:[%d],t.num:[%d],t.reqEMoney:[%d]",t.id,t.type,t.num,t.reqEMoney);
            table.insert( p.mList, t );
        end
        p.refresh();
    elseif nAction == 2 then
        local count	= netdata:ReadByte();
        local nKnocking     = netdata:ReadByte();   --爆击类型
        local nEMoney       = netdata:ReadInt();    --暴击金额
        local nType         = netdata:ReadInt();    --祭祀类型:1,2,3,4
        
        local sTxt1 = GetTxtPri("PLAYER_T5");
        local sTxt2 = GetTxtPri("PLAYER_T6");
        local sTxt3;
        if nType == 1 then
            sTxt3 = GetTxtPub("coin");
        elseif nType == 2 then
            sTxt3 = GetTxtPub("JianHun");
        elseif nType == 3 then
            sTxt3 = GetTxtPub("ShenWan");
        elseif nType == 4 then
            sTxt3 = GetTxtPri("PUIA_T8");
        end
        
        local sTxt;
        if( nKnocking > 1 ) then
            sTxt = string.format("%d%s%d%s", nKnocking, sTxt1,nEMoney,sTxt3);
        else
            sTxt = string.format("%s%d%s", sTxt2,nEMoney,sTxt3);
        end
        
        CommonDlgNew.ShowTipsDlg({{sTxt,FeteColor[nKnocking]}});
    end
    
    CloseLoadBar();
end



function p.SendMsgFete(nTypeId)
    LogInfo("p.SendMsgFete");
    ShowLoadBar();
    local netdata = createNDTransData(NMSG_Type._MSG_CONFIRM_SACRIFICE);
    netdata:WriteInt(nTypeId);
    SendMsg(netdata);
    netdata:Free();
    
    return true;
end

function p.TwiceConfirm( data )
    LogInfo("p.TwiceConfirm");
    if(p.bTwiceConfirm == false) then
        CommonDlgNew.ShowNotHintDlg(string.format(GetTxtPri("PLAYER_T4"),data.reqEMoney), p.TwiceConfirmCallBack, data.id);
    else
        p.SendMsgFete(data.id);
    end
end


function p.TwiceConfirmCallBack(nEventType, param, val)
    LogInfo("p.TwiceConfirmCallBack");
    if(nEventType == CommonDlgNew.BtnOk) then
        LogInfo("p.TwiceConfirmCallBack true:param:[%d]",param);
        p.SendMsgFete(param);
        p.bTwiceConfirm = val;
    elseif(nEventType == CommonDlgNew.BtnNo) then
        p.bTwiceConfirm = val;
    end
end

function p.refresh()
    local nLayer = p.getUiLayer();
    if ( nLayer == nil ) then
        return;
    end
    for i,v in ipairs(p.mList) do
        LogInfo("v.type:[%d],p.EMoneys[v.type]:[%d]",v.type,p.EMoneys[v.type])
        local lblEMoneyTxt = GetLabel(nLayer, p.EMoneys[v.type]);
      
        if( lblEMoneyTxt ) then
        
			--获取精英特权免费次数
			local nEPType = p.textEPEnum[v.type];
			local nFreeTime = EPDataConfig.GetEPValue(nEPType);
			
			if nFreeTime ~= 0 then
				local sTxt = string.format(GetTxtPri("EP_FREE_TIMES"), nFreeTime);
				lblEMoneyTxt:SetText(sTxt);		
			else
				local sTxt = string.format("%d%s", v.reqEMoney,GetTxtPub("shoe"));
				lblEMoneyTxt:SetText(sTxt);
			end 

        end
    end
    
end

local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --
local TAG_E_TJIANHUN    = 245;  --
local TAG_E_TSHENWAN    = 247;  --

--刷新金钱
function p.refreshMoney()
    LogInfo("p.refreshMoney BEGIN");
    local nPlayerId     = GetPlayerId();
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    if(layer == nil) then
        return;
    end
    
    local nmoney        = MoneyFormat(GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY));
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    
    local njh        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_SOPH).."";
    local nsw        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_REPUTE).."";
    
    _G.SetLabel(layer, TAG_E_TMONEY, nmoney);
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
    _G.SetLabel(layer, TAG_E_TJIANHUN, njh);
    _G.SetLabel(layer, TAG_E_TSHENWAN, nsw);
end

GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"Fete.refreshMoney",p.refreshMoney);
RegisterNetMsgHandler(NMSG_Type._MSG_SACRIFICE_INFO_LIST, "p.processSacrificeList", p.processSacrificeList);
