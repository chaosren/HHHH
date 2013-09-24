---------------------------------------------------
--描述: 新每日签到功能
--时间: 2013.7.31
--作者: tzq
---------------------------------------------------
CheckInReward = {}
local p = CheckInReward;

local ID_BTN_CLOSE = 80;
local ID_TEXT_DAY = 51;
local ID_TEXT_LAST = 60;
local ID_TEXT_TODAY_AWARD = 61; 
local ID_RIGHT_UI = {ID_LIST = 1001, ID_BTN_VIP = 4, ID_BTN_CHECK_IN = 81, ID_TEXT_1 = 10, ID_TEXT_2 = 20, ID_TEXT_3 = 21, ID_TEXT_4 = 22,};
local TEXT_TIP_WORD = {"一", "二", "三",  "四",  "五",  "六",  
                     "七",  "八",  "九",  "十",  "十一",  "十二", 
                     "十三",  "十四",  "十五",  "十六",  "十七",  "十八", };   
                     
                     


local BUTTON_ID_LIST = {101, 102, 103, 104, 105, 106, 107, 
						   201, 202, 203, 204, 205, 206, 207, 
						   301, 302, 303, 304, 305, 306, 307, 
						   401, 402, 403, 404, 405, 406, 407, 
						   501, 502, 503, 504, 505, 506, 507, 
						   601, 602, 603, 604, 605, 606, 607,};
						   

					   
						   
p.nCurYear = 2013;
p.nCurMonth = 2;
p.nCurDay = 1;
p.nPreChkDay = 1;   --上次签到的日期
p.nPreChkYear = 2013;   --上次签到的年
p.nPreChkMonth = 1;   --上次签到的月

p.nLastChkNum = 0;  
local nDaysPerStage = 5;  --每個階段天數

p.CheckInAwardInfo = {}; 
p.VipStageAwardInfo = {};


--for test begin
--[[
p.VipStageAwardInfo = { {Id = 1, nStage = 1, nVipLevel = 1,}, 
						{Id = 2, nStage = 2, nVipLevel = 1,},
						{Id = 3, nStage = 3, nVipLevel = 1,},
						{Id = 4, nStage = 4, nVipLevel = 1,},
						{Id = 5, nStage = 5, nVipLevel = 1,},
						{Id = 6, nStage = 6, nVipLevel = 1,},
						{Id = 7, nStage = 7, nVipLevel = 1,},
						{Id = 8, nStage = 8, nVipLevel = 1,},};
						]]
--for test end

--加载龙将兵法主界面
function p.LoadUI()
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加龙将兵法层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.CheckInReward);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("CheckIn/CheckIn.ini", layer, p.OnUIEvent, 0, 0);
	
	uiLoad:Free(); 
	
	--初始化数据
	p.InitData();
	
	--刷新页面
	p.RefreshUI(); 
	return true;
end

--初始化每日奖励的数据
function  p.InitDataDailyAward()
    p.CheckInAwardInfo.Normal = {};
    
    if RechargeReward.EventConfig ~= nil then
        table.sort(RechargeReward.EventConfig, function(a,b) return a.Id < b.Id   end);
    end 
    
    if RechargeReward.EventReward ~= nil then
        table.sort(RechargeReward.EventReward, function(a,b) return a.Id < b.Id   end);
    end 
    
    for i, v in pairs(RechargeReward.EventConfig) do
       --获取活动的类型
       local nType = v.Type;
		--获取其他的奖励
		if nType == MsgPlayerAction.PLAYER_ACTION_TYPE.CHECK_IN  then  --登入签到
			for j, k in pairs(RechargeReward.EventReward) do
				local Config_id = k.IdEventConfig;

				if v.Id == Config_id then
					table.insert(p.CheckInAwardInfo.Normal, k);
				end
			end  
		end
    end
end







--初始化阶段性奖励的数据
function p.InitStageAward()
	local userContainer = p.GetStageAwardContainer();
	if userContainer == nil then
		return;
	end
	
	userContainer:RemoveAllView();
	local rectview = userContainer:GetFrameRect();
	userContainer:SetViewSize(rectview.size);
	
	if p.VipStageAwardInfo ~= nil then
        table.sort(p.VipStageAwardInfo, function(a,b) return a.nStage < b.nStage   end);
    end 
    
	--获取当前等级
	local CurVipLev = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
    for i, v in ipairs(p.VipStageAwardInfo) do
		if v.nVipLevel == CurVipLev then    --每个vip都有多个阶段
			p.AddStageViewItem(v);
		end
    end

	userContainer:ShowViewByIndex(p.nLastChkNum / nDaysPerStage);
end


--
function p.AddStageViewItem(Info)
	local container = p.GetStageAwardContainer();
 
    local view = createUIScrollView();
    if view == nil then
        return;
    end
    view:Init(false);
    view:SetViewId(Info.nStage);
    view:SetTag(Info.nStage);
    container:AddView(view);
        
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        return false;
    end
	
    uiLoad:Load("CheckIn/CheckIn_list.ini", view, p.OnUIEvent, 0, 0);
	if Info.nStage > #TEXT_TIP_WORD then
		return;
	end
	
   SetLabel(view, ID_RIGHT_UI.ID_TEXT_1, string.format(GetTxtPri("CHECKIN_01"), TEXT_TIP_WORD[Info.nStage]));
	
	--奖励物品	
	local ShowText = "";   
    if (Info.ItemType ~= 0) and  (Info.ItemCount ~= 0) then
        ShowText = ShowText .. ItemFunc.GetName(Info.ItemType) .."X"..Info.ItemCount.."\n";
    end
    SetLabel(view, ID_RIGHT_UI.ID_TEXT_3, ShowText);  
	
	--金幣獎勵
	ShowText = "";
	 --vip加成
	 --获取当前等级
	 local CurVipLev = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
	 if CurVipLev == 0 then
		if Info.Emoney ~= 0 then
			 ShowText = ShowText ..GetTxtPub("shoe").."X"..Info.Emoney.."\n";
		end
		SetLabel(view, ID_RIGHT_UI.ID_TEXT_2, ShowText); 
		--無
		SetLabel(view, ID_RIGHT_UI.ID_TEXT_4, GetTxtPri("CHECKIN_02")); 
	 else
		local nEmoney = 0;
		for i, v in ipairs(p.VipStageAwardInfo) do
			if v.nVipLevel == 0 then
				nEmoney = v.Emoney;
			end
		end
		
		if nEmoney ~= 0 then
			 ShowText = ShowText ..GetTxtPub("shoe").."X"..nEmoney.."\n";
		end
		SetLabel(view, ID_RIGHT_UI.ID_TEXT_2, ShowText); 
		
		ShowText = "";
		if Info.Emoney - nEmoney > 0 then
			ShowText = ShowText ..GetTxtPub("shoe").."X"..Info.Emoney - nEmoney.."\n";
			SetLabel(view, ID_RIGHT_UI.ID_TEXT_4, ShowText); 
		end
	 end
	
    uiLoad:Free();
end

--刷新右侧奖励部分数据
function p.RefreshRightUI()
	local pLayer = p.GetParent();
	if pLayer == nil then
		return;
	end
	
	--显示今日签到奖励数据
	local strTodayAward = "";
	
	local nShowRewardDay = p.nLastChkNum;
	
	if p.nPreChkDay ~= p.nCurDay 
		or p.nLastChkNum == 0 then
		nShowRewardDay = nShowRewardDay + 1;
	end
	
	strTodayAward = p.GetAwardStr(nShowRewardDay);
	
	--当天可以领取阶段性奖励
	if math.fmod(nShowRewardDay , 5) == 0 then
		local  strInfo = nil;
		local CurVipLev = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
		for i, v in ipairs(p.VipStageAwardInfo) do
			if v.nVipLevel == CurVipLev 
			   and (nShowRewardDay) / nDaysPerStage == v.nStage then   
				strInfo = v;
				break;
			end
		end
	
		if strInfo ~= nil then
			strTodayAward = strTodayAward .. p.GetAwardStrFromInfo(strInfo);
		end
	end

	SetLabel(pLayer, ID_TEXT_TODAY_AWARD, strTodayAward);
	
	--刷新階段獎勵數據
	local userContainer = p.GetStageAwardContainer();
	if userContainer == nil then
		return;
	end
	userContainer:ShowViewByIndex(p.nLastChkNum / nDaysPerStage);
end

function p.GetStageAwardContainer()
    local pLayer = p.GetParent();
    if pLayer == nil then
		return;
    end
    
    local container = GetScrollViewContainer(pLayer, ID_RIGHT_UI.ID_LIST);
    return container;
end


function p.RefreshWeekDayUI()
	local pLayer = p.GetParent();
	if pLayer == nil then
		return;
	end
	
	--显示日期
	SetLabel(pLayer, ID_TEXT_DAY, CheckInCommon.GetDayStr(p.nCurYear, p.nCurMonth, p.nCurDay));
	--显示连续签到次数
	SetLabel(pLayer, ID_TEXT_LAST, p.nLastChkNum.."次");
	
	local nNum = CheckInCommon.GetWeekFromYearAndMonth(p.nCurYear, p.nCurMonth);
	local nMonDays = CheckInCommon.GetDaysFromMonth(p.nCurYear, p.nCurMonth);
	local pool = _G.DefaultPicPool();
	
	if p.nPreChkMonth ~= p.nCurMonth then
		local nPreMonDays = CheckInCommon.GetDaysFromMonth(p.nPreChkYear, p.nPreChkMonth);  --获取上次签到月的天数
		if p.nPreChkDay ~= nPreMonDays then  --上个月的最后一天没有签到
			if nNum == 0 then
				nNum = 7;  --nNum为0 不会显示上个月的最后一天,其他时候会显示
			end
		end
	end

	--显示当前月前面的内容
	for i = 1, nNum do
		local nYear = p.nCurYear;
		local nMonth = p.nCurMonth - 1;
		if p.nCurMonth == 1 then
			nMonth = 12;
			nYear = p.nCurYear - 1;
		end
		local nMDays = CheckInCommon.GetDaysFromMonth(nYear, nMonth);
	
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[i]);
		if pBtnWeekDay ~= nil then
			local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button3.png" ), false);  
			pBtnWeekDay:SetImage(Pic);
			pBtnWeekDay:SetTitle(SafeN2S(nMDays - nNum + i));
			pBtnWeekDay:SetFontColor(ccc4(178,0,6,255));
		end
	end
	
	--设置当前月数字
	for i = 1, nMonDays do
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[i + nNum]);
		
		--设置数字
		if pBtnWeekDay ~= nil then
			pBtnWeekDay:SetTitle(SafeN2S(i));
			pBtnWeekDay:SetVisible(true);
			pBtnWeekDay:SetChecked(false);
			local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button2.png" ), false);  
			pBtnWeekDay:SetImage(Pic);
		end
	end

	--设置当前月中已签到的
	local nHasChkDay = math.min(p.nPreChkDay, p.nLastChkNum);
	if p.nPreChkDay <= p.nCurDay then  --p.nPreChkDay为上个月  p.nCurDay为下个月
		for i = nHasChkDay, 1, -1 do
			local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[p.nPreChkDay + nNum + i - nHasChkDay]);
			
			if pBtnWeekDay ~= nil then
				local Pic = nil;
				if math.fmod(i + p.nLastChkNum - nHasChkDay, 5) == 0 then
					Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button6.png" ), false);
				else
					Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button1.png" ), false);			
				end
				
				pBtnWeekDay:SetImage(Pic);
			end
		end
	end
	
	
	
	--显示未签到中的礼包图片
	local nBDay = p.nPreChkDay + 1;
	if p.nPreChkDay > p.nCurDay then
		nBDay = p.nCurDay;
	end
	
    --获取开始签到的日期
	local nBegin = 0;
	if p.nPreChkDay > p.nCurDay then
		local nPreMonDays = CheckInCommon.GetDaysFromMonth(p.nPreChkYear, p.nPreChkMonth);  --获取上次签到月的天数
		nBegin = p.nPreChkDay - nPreMonDays - p.nLastChkNum;
	else
		nBegin = p.nPreChkDay - (p.nLastChkNum - 1);
	end
	
	if p.nLastChkNum == 0 then
		nBegin = p.nCurDay;        --从未签到
	end
		
	for i = nMonDays, nBDay, - 1 do
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[i + nNum]);
	
		--显示礼包图片
		if pBtnWeekDay ~= nil then
			if i > nBegin
			   and math.fmod(i - nBegin + 1 , 5) == 0 then
				local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button5.png" ), false);
				pBtnWeekDay:SetImage(Pic);	
			end
		end
	end 
	
	
	

	local btnChk = GetButton(pLayer, ID_RIGHT_UI.ID_BTN_CHECK_IN);
	btnChk:EnalbeGray(false);
	

	if p.nCurDay - p.nPreChkDay == 0 then
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[p.nCurDay + nNum]);
		if  p.nLastChkNum ~= 0  then --今天刚签到过的处理
			if pBtnWeekDay ~= nil then
				--签到按钮置灰
				if btnChk ~= nil then
					btnChk:EnalbeGray(true);
				end 
			end
		else                       --从未签到过
			local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button7.png" ), false);
			pBtnWeekDay:SetImage(Pic);	
		end
		
		--設置簽到按鈕為簽到
		if btnChk ~= nil then
			btnChk:SetTitle(GetTxtPri("DCI_Sign"));
		end 
	elseif p.nCurDay - p.nPreChkDay == 1 then --本月昨天签到过
		--设置当前天为焦点图片
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[p.nCurDay + nNum]);
		if math.fmod(p.nLastChkNum + 1 , 5) == 0 then
			local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button8.png" ), false);
			pBtnWeekDay:SetImage(Pic);	
		else
			local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button7.png" ), false);
			pBtnWeekDay:SetImage(Pic);	
		end
		--設置簽到按鈕為簽到
		if btnChk ~= nil then
			btnChk:SetTitle(GetTxtPri("DCI_Sign"));
		end 
	elseif p.nCurDay - p.nPreChkDay == 2 then --本月前天签到过
		--设置昨天焦点显示
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[p.nCurDay + nNum - 1]);
		if pBtnWeekDay ~= nil then
			--设置当前天为焦点图片
			if math.fmod(p.nLastChkNum + 1 , 5) == 0 then
				local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button8.png" ), false);
				pBtnWeekDay:SetImage(Pic);	
			else
				local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button7.png" ), false);
				pBtnWeekDay:SetImage(Pic);	
			end

		end
		--設置簽到按鈕為續簽
		if btnChk ~= nil then
			btnChk:SetTitle(GetTxtPri("DCI_Renewal"));
		end 
	elseif p.nCurDay - p.nPreChkDay < 0 then
		local nPreMonDays = CheckInCommon.GetDaysFromMonth(p.nPreChkYear, p.nPreChkMonth);  --获取上次签到月的天数
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[p.nCurDay + nNum]);
		if p.nCurDay + (nPreMonDays - p.nPreChkDay) == 1 then  --昨天签到
			--设置当前天为焦点图片
			if math.fmod(p.nLastChkNum + 1 , 5) == 0 then
				local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button8.png" ), false);
				pBtnWeekDay:SetImage(Pic);	
			else
				local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button7.png" ), false);
				pBtnWeekDay:SetImage(Pic);	
			end
			--設置簽到按鈕為簽到
			if btnChk ~= nil then
				btnChk:SetTitle(GetTxtPri("DCI_Sign"));
			end 
		elseif p.nCurDay + (nPreMonDays - p.nPreChkDay) == 2 then --前天签到
			--设置昨天焦点显示
			local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[p.nCurDay + nNum - 1]);
			if pBtnWeekDay ~= nil then
				--设置当前天为焦点图片
				if math.fmod(p.nLastChkNum + 1 , 5) == 0 then
					local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button8.png" ), false);
					pBtnWeekDay:SetImage(Pic);	
				else
					local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button7.png" ), false);
					pBtnWeekDay:SetImage(Pic);	
				end

			end
			--設置簽到按鈕為續簽
			if btnChk ~= nil then
				btnChk:SetTitle(GetTxtPri("DCI_Renewal"));
			end 
		end
	end
	
	
	--显示当前月后面的内容
	for i = nMonDays + nNum + 1, #BUTTON_ID_LIST do
		local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[i]);
		if pBtnWeekDay ~= nil then
			local Pic = pool:AddPicture(GetSMImgPath( "CheckIn/CheckIn_button3.png" ), false);  
			pBtnWeekDay:SetImage(Pic);
			pBtnWeekDay:SetTitle(SafeN2S(i - nMonDays - nNum));
			pBtnWeekDay:SetVisible(true);
			pBtnWeekDay:SetFontColor(ccc4(178,0,6,255));
		end
	end	

	--去掉不不要的行
	if nMonDays + nNum <= 35 then
		for i = 36, #BUTTON_ID_LIST do
			local pBtnWeekDay = GetButton( pLayer, BUTTON_ID_LIST[i]);
			if pBtnWeekDay ~= nil then
				pBtnWeekDay:SetVisible(false);
			end
		end
	end
end




function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_CLOSE == tag then   
			CloseUI(NMAINSCENECHILDTAG.CheckInReward);
			
		elseif ID_RIGHT_UI.ID_BTN_VIP == tag then   
			PlayerVIPUI.LoadUI(); 
			
		elseif ID_RIGHT_UI.ID_BTN_CHECK_IN == tag then	 
			p.SendCheckIn(p.nLastChkNum + 1);
		end
	end
	
	return true;
end


function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.CheckInReward);
	if nil == layer then
		return nil;
	end
    
	return layer;
end

--获取某天签到的奖励
function  p.GetAwardStr(nDayIndex)
    LogInfo("p.GetAwardStr  nDayIndex = %d", nDayIndex);
    
    local Info = {};
    
	if nDayIndex <= 60 then
		 Info = p.CheckInAwardInfo.Normal[nDayIndex];
	end
	
	if Info == nil then
        return "";
   end
   
   return p.GetAwardStrFromInfo(Info);
end

function  p.GetAwardStrFromInfo(Info)
    local ShowText = "";

    --奖励物品
    if (Info.ItemType ~= 0) and  (Info.ItemCount ~= 0) then
        ShowText = ShowText .. ItemFunc.GetName(Info.ItemType) .."X"..Info.ItemCount.."\n";
    end
    --金币
    if Info.Emoney ~= 0 then
        ShowText = ShowText ..GetTxtPub("shoe").."X"..Info.Emoney.."\n";
    end
    --军令
    if Info.Stamina ~= 0 then
        ShowText = ShowText ..GetTxtPub("Stamina").."X"..Info.Stamina.."\n";
    end
    --银币
    if Info.Money ~= 0 then
        ShowText = ShowText ..GetTxtPub("coin").."X"..Info.Money.."\n";
    end
    --将魂
    if Info.Soph ~= 0 then
        ShowText = ShowText ..GetTxtPub("JianHun").."X"..Info.Soph.."\n";
    end
    --声望
    if Info.Repute ~= 0 then
        ShowText = ShowText ..GetTxtPub("ShenWan").."X"..Info.Repute.."\n";
    end  
    
    --武魂
    if Info.Spirit ~= nil and Info.Spirit ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("Spirit").."X"..Info.Spirit.."\n";
    end
    --军功
    if Info.Exploits ~= nil and Info.Exploits ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("Exploit").."X"..Info.Exploits.."\n";
    end  
    
    return ShowText;
end



--发送签到消息   iDayIndex哪一天签到
function p.SendCheckIn(iDayIndex)  

	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);

	--签到的类型是1
	netdata:WriteByte(1);
	netdata:WriteInt(iDayIndex);	

	SendMsg(netdata);	
	netdata:Free();	
	return true;	
end

function p.IsCanCheckIn()
	if p.nPreChkDay ~= p.nCurDay 
	   or p.nLastChkNum == 0 then
	   return true;
	end

	return false;
end

function p.CheckInStarTip()
	if p.IsCanCheckIn() then
		local btn = MainUI.GetBnttonByTag(29);
		
		if btn == nil then

			return;
		end
		
       local pSpriteNode = ConverToSprite( GetUiNode( btn, 99 ) );
    	if ( pSpriteNode ~= nil ) then
    		return;
    	end  

		local pSpriteNode	= createUISpriteNode();
		
		local btnrect = btn:GetFrameRect();
		local btnWidth =btnrect.size.w;
		local btnHeight = btnrect.size.h;

		pSpriteNode:Init();
		local szAniPath		= NDPath_GetAnimationPath();
		local szSprFile		= "gongn01.spr";
		
		pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
		--pSpriteNode:SetFrameRect( CGRectMake(-btnWidth*0.1,0,btnWidth,btnHeight) );
		pSpriteNode:SetFrameRect( CGRectMake(0, 0, btnWidth, btnHeight) );
		pSpriteNode:SetScale(0.7);
		
		pSpriteNode:SetTag( 99 );
	
		--加到星星node上
    	btn:AddChild( pSpriteNode );
    	p.EffectSprite = pSpriteNode;
	else
		p.RemoveEffect();
	end
end

p.EffectSprite	= nil;
function p.RemoveEffect()
	if p.EffectSprite == nil then
		return;
	end
    
    local effectspr = p.EffectSprite;
    effectspr:RemoveFromParent( true );
    p.EffectSprite	= nil;
end


--iPreTime最近一个的签到时间, iData标示已续签天数  iCurTime服务器当前时间
function p.SetUiInfo(iPreTime, iData, iCurTime)

	if not CheckN(iPreTime)
	   or not CheckN(iData)
	   or not CheckN(iCurTime) then
	   return;
	end
	
	p.nCurYear = SafeS2N(os.date("%Y", iCurTime));
	p.nCurMonth = SafeS2N(os.date("%m", iCurTime));
	p.nCurDay = SafeS2N(os.date("%d", iCurTime)); 
	
	p.nLastChkNum = iData;
	if iPreTime ~= 0 then
		p.nPreChkYear = SafeS2N(os.date("%Y", iPreTime));  --上次签到的年
		p.nPreChkMonth = SafeS2N(os.date("%m", iPreTime));   --上次签到的月
		p.nPreChkDay = SafeS2N(os.date("%d", iPreTime)); 
	else
		p.nPreChkDay = p.nCurDay;
		p.nPreChkYear = p.nCurYear;
		p.nPreChkMonth = p.nCurMonth;
		p.nLastChkNum = 0;
	end
	
	p.CheckInStarTip();
	p.RefreshUI();
end

--初始化奖励数据，服务器下发
function  p.InitData()
	--初始化每日奖励的数据
	p.InitDataDailyAward();
	
	--初始化阶段性奖励的数据
	p.InitStageAward();
end


function p.RefreshUI()
	--刷新日期对应星期的数据
	p.RefreshWeekDayUI();
	
	--刷新右侧奖励部分数据
	p.RefreshRightUI();
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "CheckInReward.CheckInStarTip", p.CheckInStarTip);