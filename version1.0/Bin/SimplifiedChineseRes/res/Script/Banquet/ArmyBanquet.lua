---------------------------------------------------
--描述: 军团宴会
--时间: 2013.11.25
--作者: QBW
---------------------------------------------------
-- 进入界面接口：		ArmyBanquet.Entry()
---------------------------------------------------

--本地化


ArmyBanquet = {}
local p = ArmyBanquet;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 4;	-- X
local ID_LABEL_SELVER				= 243;	-- 银币值
local ID_LABEL_GOLD					= 242;	-- 金币值
local ID_PIC_LEFT_ZONE				= 2;	-- 左侧区域
local ID_PIC_RIGHTT_ZONE			= 3;	-- 右侧区域

-- 宴会说明界面控件
local ID_LABEL_PLAYERINFOR			= 30;	-- 玩家信息标签
local ID_BTN_PREPARE				= 817;	-- 筹备宴会按钮

-- 宴会界面控件-主办
local ID_BTN_CACEL					= 59;	-- 取消宴会按钮
local ID_BTN_START					= 58;	-- 开席按钮
local ID_BTN_GOLDSTART				= 817;	-- 金币开席按钮

-- 出席者列表项控件
local ID_LIST_ATTENDEE				= 148;	-- 出席者列表控件
local ID_BTN_SHOWTHEDOOR			= 4;	-- 驱逐按钮--
local ID_LEBEL_PLAYER_NAME			= 6;	-- 玩家名标签
local ID_LEBEL_PLAYER_LEVEL			= 7;	-- 等级标签

-- 宴会界面控件-宾客
local ID_BTN_LEAVE					= 58;	-- 离开按钮

-- 宴会列表界面控件
local ID_LIST_ArmyBanquet				= 29;	-- 宴会列表控件
local ID_LABEL_HOSTNAME				= 5;	-- 主人名标签
local ID_LABEL_NUMBER				= 6;	-- 人数标签
local ID_BTN_JOIN					= 7;	-- 参加按钮
local ID_PIC_LIST_ITEM_BORDER		= 1;	-- 列表项的边框
local ID_LEBEL_ArmyBanquet				= 2;	-- “宴会”静态标签
local ID_LEBEL_HOST					= 3;	-- “发起者”静态标签
local ID_LEBEL_ATTENDEE				= 4;	-- “参加人数”静态标签


---------------------------------------------------
local LEVEL_LIMIT					= 40;	-- 等级限制


---------------------------------------------------
local SZ_ERROR_00				= GetTxtPri("ARMYBANQUET_09");
local SZ_ERROR_06				= GetTxtPri("ARMYBANQUET_10");


---------------------------------------------------

---------------------------------------------------
local SZ_START_SUCCEED			= GetTxtPri("MB_T20");
local SZ_GOLD_START_SUCCEED		= GetTxtPri("MB_T21");
local SZ_CANCEL_SUCCEED			= GetTxtPri("ARMYBANQUET_07");
local SZ_TIME_OUT				= GetTxtPri("MB_T23");
local SZ_SHOW_THE_DOOR			= GetTxtPri("ARMYBANQUET_08");



---------------------------------------------------

---------------------------------------------------
p.pLayerNotice				= nil;	-- 左侧公告（未到宴会时间才显示）
p.pLayerArmyBanquetList			= nil;	-- 左侧宴会列表（到宴会时间才显示）
p.pLayerPlayerInfor			= nil;	-- 右侧提示（未到宴会时间不显示按钮）
p.pLayerArmyBanquetInfor_Host	= nil;	-- 右侧宴会详细信息--主办
p.pLayerArmyBanquetInfor_Guest	= nil;	-- 右侧宴会详细信息--来宾
p.tArmyBanquetList				= nil;	-- 宴会列表--
p.ArmyBanquetStatus				= nil;	-- 宴会状态--
p.tArmyBanquetInfor				= nil;	-- 宴会信息(包含出席者列表 tAttendeeList)
p.nTimerID					= nil;	-- 定时器
p.nFreeArmyBanquetAmount		= nil;	-- 免费宴会次数
p.PrePareGrade					= nil;--籌備宴會等級

--精英特權數據
p.EpBtnInfo = {};

---------------------------------------------------
-- 进入--时间点到才可以
function p.Entry()
p.pLayerNotice				= nil;
p.pLayerArmyBanquetList			= nil;
p.pLayerPlayerInfor			= nil;
p.pLayerArmyBanquetInfor_Host	= nil;
p.pLayerArmyBanquetInfor_Guest	= nil;
p.tArmyBanquetList				= nil;
p.ArmyBanquetStatus				= nil;
p.tArmyBanquetInfor				= nil;
p.nTimerID					= nil;
p.nFreeArmyBanquetAmount		= nil;
	local nUserID		= GetPlayerId();
	local nPlayerPetID	= RolePetFunc.GetMainPetId( nUserID );
	local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	if ( nPlayerLevel < LEVEL_LIMIT ) then
		CommonDlgNew.ShowYesDlg( SZ_ERROR_00, nil, nil, 3 );
		return;
	end

	p.ShowArmyBanquetMainUI();
end



---------------------------------------------------
-- 显示宴会主界面
function p.ShowArmyBanquetMainUI()

	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "ArmyBanquet: ShowArmyBanquetMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyBanquet: ShowArmyBanquetMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.ArmyBanquet );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UILayerZOrder.ActivityLayer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyBanquet: ShowArmyBanquetMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_Main.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	p.RefreshMoney();--显示银币与金币
	
	local pLeftBoder	= GetImage( layer, ID_PIC_LEFT_ZONE );
	local tLeftRect		= pLeftBoder:GetFrameRect();
	local pRightBoder	= GetImage( layer, ID_PIC_RIGHTT_ZONE );
	local tRightRect	= pRightBoder:GetFrameRect();
	
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
	p.CreateNoticeLayer( layer, tLeftRect );
	p.CreateArmyBanquetListLayer( layer, tLeftRect );
	p.CreatePlayerInforLayer( layer, tRightRect );
	p.CreateArmyBanquetInforLayer_Host( layer, tRightRect );
	p.CreateArmyBanquetInforLayer_Guest( layer, tRightRect );
	p.pLayerNotice:SetVisible( false );
	p.pLayerArmyBanquetInfor_Host:SetVisible( false );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
	
	p.EpinitData();
end


--精英特權增加功能
function p.EpinitData()
	p.EpBtnInfo = {};
	
	--特權按鈕
	p.EpBtnInfo.CtrId = 38;
	p.EpBtnInfo.tbInfo = {{ txt = GetTxtPri("EP_TXT_015"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_DINNER_STAMINA, },
							{ txt = GetTxtPri("EP_TXT_016"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_DINNER_MONEY, },
							{ txt = GetTxtPri("EP_TXT_017"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_DINNER_STAMINA_FIRST, },
							{ txt = GetTxtPri("EP_TXT_017"), epnum = EPDataConfig.E_EP_TYPE.EP_TYPE_DINNER_STAMINA_SECOND, },};
                  
	--顯示特權按鈕的判斷
	local btnExitFlag = false;		
	for i, v in pairs(p.EpBtnInfo.tbInfo) do
		local nValue = EPDataConfig.GetEPValue(v.epnum);
		if nValue ~= 0 then
			btnExitFlag = true;
			break;
		end
	end
	
	local pScene = GetSMGameScene();
	if( pScene == nil ) then
		return;
	end
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.ArmyBanquet );
	local btnEP = GetButton(pLayer, p.EpBtnInfo.CtrId);
	if btnEP ~= nil then
		btnEP:SetVisible(btnExitFlag);
	end
end


-- 关闭宴会界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.ArmyBanquet, true );--p.pLayerMainUI:RemoveFromParent( true );
	end
	if ( p.nTimerID ~= nil ) then
		UnRegisterTimer( p.nTimerID );
	end
p.pLayerNotice				= nil;
p.pLayerArmyBanquetList			= nil;
p.pLayerPlayerInfor			= nil;
p.pLayerArmyBanquetInfor_Host	= nil;
p.pLayerArmyBanquetInfor_Guest	= nil;
p.tArmyBanquetList				= nil;
p.ArmyBanquetStatus				= nil;
p.tArmyBanquetInfor				= nil;
p.nTimerID					= nil;
p.nFreeArmyBanquetAmount		= nil;
end

---------------------------------------------------
-- 宴会界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			if ( p.ArmyBanquetStatus ~= ArmyBanquetStatus.BS_NONE ) then
				MsgArmyBanquet.SendMsgLeaveBanquet();
			end
			p.CloseUI();
			
		elseif p.EpBtnInfo.CtrId == tag then
			local str = "";
			
			local nValue1 = EPDataConfig.GetEPValue(p.EpBtnInfo.tbInfo[1].epnum)/10;
			local nValue2 = EPDataConfig.GetEPValue(p.EpBtnInfo.tbInfo[2].epnum)/10;	
			local nValue3 = EPDataConfig.GetEPValue(p.EpBtnInfo.tbInfo[3].epnum)/10;
			local nValue4 = EPDataConfig.GetEPValue(p.EpBtnInfo.tbInfo[4].epnum)/10;		
			
			if nValue1 > 0 then
				str = str .. string.format(p.EpBtnInfo.tbInfo[1].txt, nValue1);
			end
			
			if nValue2 > 0 then
				if str ~= nil then
					str = str .. "\r\n";
				end
				str = str .. string.format(p.EpBtnInfo.tbInfo[2].txt, nValue2);
			end
			
			if nValue3 > 0 then
				if str ~= nil then
					str = str .. "\r\n";
				end
				
				if nValue4 > 0 then
					str = str .. string.format(p.EpBtnInfo.tbInfo[4].txt, nValue4 + nValue3);
				else
					str = str .. string.format(p.EpBtnInfo.tbInfo[3].txt, nValue3);
				end
			elseif nValue4 > 0 then
				if str ~= nil then
					str = str .. "\r\n";
				end
				str = str .. string.format(p.EpBtnInfo.tbInfo[4].txt, nValue4);
			end

						
			if str ~= nil then
				CommonDlgNew.ShowYesDlg(str, nil, nil, 10);
			end

		end
		
	end
	return true;
end

---------------------------------------------------
-- 创建左侧公告层
function p.CreateNoticeLayer( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyBanquet: CreateNoticeLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyBanquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyBanquet: CreateNoticeLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_Notice.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	p.pLayerNotice = layer;
end

---------------------------------------------------
-- 创建左侧宴会列表层
function p.CreateArmyBanquetListLayer( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyBanquet: CreateNoticeLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyBanquet: CreateNoticeLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_BanquetList.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	p.pLayerArmyBanquetList = layer;

	MsgArmyBanquet.SendMsgGetBanquetList();
	p.nTimerID = RegisterTimer( p.OnTimer_SendMsgGetArmyBanquetList, 5 );--定时器-每5秒定时发送获取宴会列表消息
end


---------------------------------------------------
-- 创建右侧玩家信息层
function p.CreatePlayerInforLayer( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyBanquet: CreatePlayerInforLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyBanquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyBanquet: CreatePlayerInforLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_PlayerInfor.ini", layer, p.OnUIEventPlayerInforLayer, 0, 0 );
	uiLoad:Free();
	
	p.pLayerPlayerInfor = layer;
	p.InitPlayerInforLayer();
end

---------------------------------------------------
	

local tTagGradeInfo = {43,44,45}
function p.InitPlayerInforLayer()
	local layer = p.pLayerPlayerInfor
   
	for i,v in pairs(tTagGradeInfo) do
		local dinnername = GetDataBaseDataS("syndicate_dinner_config",i,DB_SYNDICATE_DINNER_CONFIG.DINNER_NAME);
		local goldneed =  GetDataBaseDataN("syndicate_dinner_config",i,DB_SYNDICATE_DINNER_CONFIG.LAUNCH_MONEY_NEED);
		local maxnum =  GetDataBaseDataN("syndicate_dinner_config",i,DB_SYNDICATE_DINNER_CONFIG.MAX_NUM);
		
		local l_txt = GetLabel(layer, v);
		l_txt:SetText(string.format( GetTxtPri("ARMYBANQUET_03"), dinnername,goldneed,maxnum));
		
	end
end


---------------------------------------------------
p.TagGrade = {
    [1]    = 41,
    [2]   = 40,
    [3]   = 42,
};

function p.getCheckByTag(tag)
    local layer = p.pLayerPlayerInfor
    local nod = GetUiNode(layer, tag);
    local check = ConverToCheckBox(nod);
    return check;
end

--选中单选框
function p.setOpenBanquetGrade(tag)
    for k, v in pairs(p.TagGrade) do
        if(v ~= tag) then
            local checkbox = p.getCheckByTag(v);
            checkbox:SetSelect(false);
        end
	end
    local checkbox = p.getCheckByTag(tag);
    checkbox:SetSelect(true);
end

--獲取宴會檔次
function p.getSelectGrade()
	for i,v in pairs(p.TagGrade)do
		local checkbox = p.getCheckByTag(v);
		if checkbox:IsSelect() then
			return i;
		end
	end
	
	return 0;
end

-- 右侧玩家信息界面的事件响应
function p.OnUIEventPlayerInforLayer( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_PREPARE ) then
			local nUserID		= GetPlayerId();
			
			local grade = p.getSelectGrade()
			if grade == 0 then
				return true
			end	
			
			--發起金幣判定
			local playergold = GetRoleBasicDataN(nUserID,USER_ATTR.USER_ATTR_EMONEY);           
			local goldneed =  GetDataBaseDataN("syndicate_dinner_config",grade,DB_SYNDICATE_DINNER_CONFIG.LAUNCH_MONEY_NEED);
			
			if ( playergold < goldneed ) then
				CommonDlgNew.ShowYesDlg(string.format( GetTxtPri("ARMYBANQUET_01"), goldneed), nil, nil, 3 );
				return true;
			end
			
			
			local nRepute	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_REPUTE );
			
			local nReputeneed =  GetDataBaseDataN("syndicate_dinner_config",grade,DB_SYNDICATE_DINNER_CONFIG.REPUTE_NEED);
			
			
			if ( nRepute < nReputeneed ) then
				CommonDlgNew.ShowYesDlg(string.format( GetTxtPri("ARMYBANQUET_04"), nReputeneed), nil, nil, 3 );
				return true;
			end	
			
			local	synid = MsgArmyGroup.GetUserArmyGroupID( nUserID );
			ShowLoadBar();--
			MsgArmyBanquet.SendMsgPrepareBanquet(synid,grade);
			p.PrePareGrade= grade;
		end
	elseif 	 uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		--設置宴會等級
            p.setOpenBanquetGrade(tag);
	end
	return true;
end

---------------------------------------------------
-- 筹备成功回调
function p.CallBack_PrepareSucceed()
	CloseLoadBar();	--	
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_HOST;
	--
	p.pLayerPlayerInfor:SetVisible( false );
	p.pLayerArmyBanquetInfor_Host:SetVisible( true );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( false );
	end
	--
	p.tArmyBanquetInfor	= {};
	local nUserID	= GetPlayerId();
	local szName	= GetRoleBasicDataS( nUserID, USER_ATTR.USER_ATTR_NAME );
	local nPetID	= RolePetFunc.GetMainPetId( nUserID );
	local nLevel	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LEVEL );
	p.tArmyBanquetInfor.nHostUserID	= nUserID;
	p.tArmyBanquetInfor.tAttendeeList		= {};
	p.tArmyBanquetInfor.tAttendeeList[1]	= {};
	p.tArmyBanquetInfor.tAttendeeList[1][ALDI.PlayerID]	= nUserID;
	p.tArmyBanquetInfor.tAttendeeList[1][ALDI.Name]		= szName;
	p.tArmyBanquetInfor.tAttendeeList[1][ALDI.Level]	= nLevel;
	p.FillArmyBanquetInfor( p.pLayerArmyBanquetInfor_Host, p.tArmyBanquetInfor.tAttendeeList );
end


---------------------------------------------------
-- 创建右侧宴会信息层--主办
function p.CreateArmyBanquetInforLayer_Host( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyBanquet: CreatePlayerInforLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyBanquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyBanquet: CreatePlayerInforLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_BanquetInfor0.ini", layer, p.OnUIEventArmyBanquetInforLayer_Host, 0, 0 );
	uiLoad:Free();
	p.pLayerArmyBanquetInfor_Host = layer;
end

---------------------------------------------------
-- 右侧宴会信息层--主办界面的事件响应
function p.OnUIEventArmyBanquetInforLayer_Host( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
	   if ( tag == ID_BTN_CACEL ) then
			ShowLoadBar();--
			MsgArmyBanquet.SendMsgCancelBanquet();
		elseif ( tag == ID_BTN_GOLDSTART ) then
			local nAmount = table.getn( p.tArmyBanquetInfor.tAttendeeList );
			--增加判定人數不足是 是否用金幣補全
			if ( nAmount < MsgArmyBanquet.BanquetLimit ) then
				--設定人數上限
				if p.PrePareGrade == nil then
					return true;
				end
				
				local lackUserCount = MsgArmyBanquet.BanquetLimit - nAmount --缺席數量
				local lackmoney =  lackUserCount*GetDataBaseDataN("syndicate_dinner_config",p.PrePareGrade,DB_SYNDICATE_DINNER_CONFIG.LACKMONEY_PER_NEED);
			
				CommonDlgNew.ShowYesOrNoDlg(string.format( GetTxtPri("ARMYBANQUET_05"), lackmoney), p.CallBack_StartArmyBanquet );
				return true;
			end
			
			if p.PrePareGrade ~= nil then
				ShowLoadBar();--
				MsgArmyBanquet.SendMsgGoldStart(p.PrePareGrade);				
			end
		end
	end
	return true;
end

---------------------------------------------------
function p.CallBack_StartArmyBanquet( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		ShowLoadBar();--
		MsgArmyBanquet.SendMsgGoldStart(p.PrePareGrade);
	end
end

---------------------------------------------------
function p.CallBack_GoldStart( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		ShowLoadBar();--
		MsgArmyBanquet.SendMsgGoldStart();
	end
end

---------------------------------------------------
-- 取消成功回调-(host取消，host和guest都收到)
function p.CallBack_CancelSucceed()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_CANCEL_SUCCEED, nil, nil, 3 );
	p.tArmyBanquetInfor	= nil;
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
	--
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerArmyBanquetInfor_Host:SetVisible( false );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end

---------------------------------------------------
-- 开席成功回调
function p.CallBack_StartSucceed()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_START_SUCCEED, nil, nil, 3 );
	p.tArmyBanquetInfor	= nil;
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
	--
	if ( p.nFreeArmyBanquetAmount ~= nil and p.nFreeArmyBanquetAmount > 0 ) then
		p.nFreeArmyBanquetAmount = p.nFreeArmyBanquetAmount - 1;
	end

	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerArmyBanquetInfor_Host:SetVisible( false );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end

---------------------------------------------------
-- 金币开席成功回调
function p.CallBack_GoldStartSucceed()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_GOLD_START_SUCCEED, nil, nil, 3 );
	p.tArmyBanquetInfor	= nil;
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
	--
	if ( p.nFreeArmyBanquetAmount ~= nil and p.nFreeArmyBanquetAmount > 0 ) then
		p.nFreeArmyBanquetAmount = p.nFreeArmyBanquetAmount - 1;
	end

	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerArmyBanquetInfor_Host:SetVisible( false );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end

---------------------------------------------------
-- 创建右侧宴会信息层--来宾
function p.CreateArmyBanquetInforLayer_Guest( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyBanquet: CreatePlayerInforLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyBanquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyBanquet: CreatePlayerInforLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_BanquetInfor1.ini", layer, p.OnUIEventArmyBanquetInforLayer_Guest, 0, 0 );
	uiLoad:Free();
	p.pLayerArmyBanquetInfor_Guest = layer;
	--
	--local tArmyBanquetInformation = MsgArmyBanquet.GetArmyBanquetInfor();--测试
	--p.FillArmyBanquetInfor( p.pLayerArmyBanquetInfor_Guest, tArmyBanquetInformation.tAttendeeList );--测试
end

---------------------------------------------------
-- 右侧宴会信息层--来宾界面的事件响应
function p.OnUIEventArmyBanquetInforLayer_Guest( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_LEAVE ) then
			ShowLoadBar();--
			MsgArmyBanquet.SendMsgLeaveBanquet();
		end
	end
	return true;
end

---------------------------------------------------
-- 离开成功回调
function p.CallBack_LeaveSucceed()
	CloseLoadBar();--
	p.tArmyBanquetInfor	= nil;
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
	--
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end


---------------------------------------------------
-- 显示宴会列表
function p.ShowArmyBanquetList()
end

-- 刷新宴会列表
function p.RefreshArmyBanquetList( tArmyBanquetList )
	if ( p.pLayerArmyBanquetList == nil ) then
		LogInfo( "ArmyBanquet: RefreshArmyBanquetList() failed! p.pLayerArmyBanquetList is nil" );
		return false;
	end
	if ( tArmyBanquetList == nil ) then
		return false;
	end
	p.tArmyBanquetList = tArmyBanquetList;
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_ListItem0.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_LIST_ITEM_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "ArmyBanquet: RefreshArmyBanquetList() failed! pScrollViewContainer is nil" );
		return false;
	end
	pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tArmyBanquetList == nil ) then
		LogInfo( "ArmyBanquet: RefreshArmyBanquetList() failed! tArmyBanquetList is nil" );
		return false;
	end
	
	local nListAmount = table.getn( tArmyBanquetList );
	if ( nListAmount == 0 ) then
		return true;
	end
	--LogInfo( "ArmyBanquet: RefreshArmyBanquetList() nListAmount:%d",nListAmount );
	for i = 1, nListAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "ArmyBanquet: RefreshArmyBanquetList failed! pListItem == nil" );
			return false;
		end
	
		pListItem:Init( false );
		pListItem:SetScrollStyle( UIScrollStyle.Verical );
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pScrollViewContainer:AddView( pListItem );
	
		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "ArmyGroup: RefreshArmyBanquetList failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_ListItem0.ini", pListItem, p.OnUIEventArmyBanquetListItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelHostName	= GetLabel( pListItem, ID_LABEL_HOSTNAME );
		local pLabelNumber		= GetLabel( pListItem, ID_LABEL_NUMBER );
		local pBtnJoin			= GetButton( pListItem, ID_BTN_JOIN );
		local pLabelArmyBanquet		= GetLabel( pListItem, ID_LEBEL_ArmyBanquet );
			
		
		local szHostName	= tArmyBanquetList[i][BLIDI.HostName];
		local nNumber		= tArmyBanquetList[i][BLIDI.AttendeeNumber];
		local nGrade =  tArmyBanquetList[i][BLIDI.Grade];
		local maxnum =  GetDataBaseDataN("syndicate_dinner_config",nGrade,DB_SYNDICATE_DINNER_CONFIG.MAX_NUM);
		local dinnername = GetDataBaseDataS("syndicate_dinner_config",nGrade,DB_SYNDICATE_DINNER_CONFIG.DINNER_NAME);
		
		pLabelArmyBanquet:SetText( dinnername );
		pLabelHostName:SetText( szHostName );
		pLabelNumber:SetText( nNumber .. "/" .. maxnum );
		if ( p.ArmyBanquetStatus == ArmyBanquetStatus.BS_NONE ) then
			pBtnJoin:SetVisible( true );
		else
			pBtnJoin:SetVisible( false );
		end
		if ( p.tArmyBanquetInfor ~= nil ) then
			local pLabelHost		= GetLabel( pListItem, ID_LEBEL_HOST );
			local pLabelAttendee	= GetLabel( pListItem, ID_LEBEL_ATTENDEE );
			if ( p.tArmyBanquetInfor.nHostUserID == tArmyBanquetList[i][BLIDI.HostUserID] ) then
				pLabelHostName:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelNumber:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelArmyBanquet:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelHost:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelAttendee:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			end
		end
	end
	
	return true;
end

---------------------------------------------------
-- 宴会列表项界面的事件响应
function p.OnUIEventArmyBanquetListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_JOIN == tag ) then
			local nUserID		= GetPlayerId();
			
			local nRepute	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_REPUTE );
			local nIndex		= uiNode:GetParent():GetTag();
			local nAmount		= p.tArmyBanquetList[nIndex][BLIDI.AttendeeNumber];
			
			local nGrade 		= p.tArmyBanquetList[nIndex][BLIDI.Grade];
			local nReputeneed =  GetDataBaseDataN("syndicate_dinner_config",nGrade,DB_SYNDICATE_DINNER_CONFIG.REPUTE_NEED);
			
			if ( nRepute < nReputeneed ) then
				
				CommonDlgNew.ShowYesDlg( string.format( GetTxtPri("ARMYBANQUET_06"), nReputeneed), nil, nil, 3 );
				return true;
			end	
			
			--參與金幣判定
			local playergold = GetRoleBasicDataN(nUserID,USER_ATTR.USER_ATTR_EMONEY);           
			local joingoldneed =  GetDataBaseDataN("syndicate_dinner_config",nGrade,DB_SYNDICATE_DINNER_CONFIG.JOIN_MONEY_NEED);
			
			if ( playergold < joingoldneed ) then
				CommonDlgNew.ShowYesDlg(string.format( GetTxtPri("ARMYBANQUET_02"), joingoldneed), nil, nil, 3 );
				return true;
			end
			
			
			--設定人數上限
			local nmaxnum =  GetDataBaseDataN("syndicate_dinner_config",nGrade,DB_SYNDICATE_DINNER_CONFIG.MAX_NUM);
			if ( nAmount >= nmaxnum ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_06, nil, nil, 3 );
				return true;
			end
			local nHostUserID	= p.tArmyBanquetList[nIndex][BLIDI.HostUserID];
			
			local synid = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	
			ShowLoadBar();--
			MsgArmyBanquet.SendMsgJoinBanquet( nHostUserID ,synid);
		end
	end
	return true;
end

---------------------------------------------------
-- 加入成功回调
function p.CallBack_JoinSucceed()
	CloseLoadBar();--
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_GUEST;
	--
	p.pLayerPlayerInfor:SetVisible( false );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( true );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( false );
	end
	--p.FillArmyBanquetInfor( p.pLayerArmyBanquetInfor_Guest, tArmyBanquetInformation.tAttendeeList );
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetInfor_Guest, ID_LIST_ATTENDEE );
	pScrollViewContainer:RemoveAllView();
end


---------------------------------------------------
-- 显示宴会信息(人员及其他)
function p.ShowArmyBanquetInformation()
end

-- 刷新宴会信息(人员及其他)
function p.RefreshArmyBanquetInformation( tArmyBanquetInformation )
	if ( p.ArmyBanquetStatus == ArmyBanquetStatus.BS_GUEST ) then
		if ( p.pLayerArmyBanquetInfor_Guest == nil ) then
			return false;
		end
		p.tArmyBanquetInfor = tArmyBanquetInformation;
		p.FillArmyBanquetInfor( p.pLayerArmyBanquetInfor_Guest, p.tArmyBanquetInfor.tAttendeeList );
	elseif ( p.ArmyBanquetStatus == ArmyBanquetStatus.BS_HOST ) then
		if ( p.pLayerArmyBanquetInfor_Host == nil ) then
			return false;
		end
		p.tArmyBanquetInfor = tArmyBanquetInformation;
		p.FillArmyBanquetInfor( p.pLayerArmyBanquetInfor_Host, p.tArmyBanquetInfor.tAttendeeList );
	end
	return false;
end

-- 填充宴会信息出席者列表
function p.FillArmyBanquetInfor( pLayer, tAttendeeList )
	if ( pLayer == nil ) then
		LogInfo( "ArmyBanquet: FillArmyBanquetInfor() failed! pLayer is nil" );
		return false;
	end
	if ( tAttendeeList == nil ) then
		LogInfo( "ArmyBanquet: FillArmyBanquetInfor() failed! tAttendeeList is nil" );
		return false;
	end
	
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_ListItem1.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_LIST_ITEM_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pLayer, ID_LIST_ATTENDEE );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "ArmyBanquet: FillArmyBanquetInfor() failed! pScrollViewContainer is nil" );
		return false;
	end
	pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tAttendeeList == nil ) then
		LogInfo( "ArmyBanquet: FillArmyBanquetInfor() failed! tAttendeeList is nil" );
		return false;
	end
	
	local nListAmount = table.getn( tAttendeeList );
	if ( nListAmount == 0 ) then
		LogInfo( "ArmyBanquet: FillArmyBanquetInfor() failed! nListAmount is 0" );
		return false;
	end
	LogInfo( "ArmyBanquet: FillArmyBanquetInfor() nListAmount:%d",nListAmount );
	local nUserID = GetPlayerId();
	for i = 1, nListAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "ArmyBanquet: RefreshArmyBanquetList failed! pListItem == nil" );
			return false;
		end
	
		pListItem:Init( false );
		pListItem:SetScrollStyle( UIScrollStyle.Verical );
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pScrollViewContainer:AddView( pListItem );
	
		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "ArmyGroup: FillArmyBanquetInfor failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "ArmyGroupBanquet/ArmyGroupBanquetUI_ListItem1.ini", pListItem, p.OnUIEventArmyBanquetInforItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelName	= GetLabel( pListItem, ID_LEBEL_PLAYER_NAME );
		local pLabelLevel	= GetLabel( pListItem, ID_LEBEL_PLAYER_LEVEL );
		local pBtnX			= GetButton( pListItem, ID_BTN_SHOWTHEDOOR );
		
		local szName	= tAttendeeList[i][ALDI.Name];
		local nLevel	= tAttendeeList[i][ALDI.Level];
		local nPlayerID	= tAttendeeList[i][ALDI.PlayerID];
		pLabelName:SetText( szName );
		pLabelLevel:SetText( SafeN2S(nLevel) );
		if ( p.ArmyBanquetStatus == ArmyBanquetStatus.BS_HOST and nUserID ~= nPlayerID ) then
			pBtnX:SetVisible( true );
		else
			pBtnX:SetVisible( false );
		end
	end
	
end

---------------------------------------------------
-- 宴会信息列表项界面的事件响应
function p.OnUIEventArmyBanquetInforItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_SHOWTHEDOOR == tag ) then
			if ( p.ArmyBanquetStatus ~= ArmyBanquetStatus.BS_HOST ) then
				return true;
			end
		end
		local nIndex	= uiNode:GetParent():GetTag();
		local nPlayerID	= p.tArmyBanquetInfor.tAttendeeList[nIndex][ALDI.PlayerID];
		local nUserID	= GetPlayerId();
		if ( nPlayerID == nUserID ) then
			return true;
		end
		--
		ShowLoadBar();--
		MsgArmyBanquet.SendMsgShowTheDoor( nPlayerID );
	end
	return true;
end

---------------------------------------------------
-- 驱逐成功回调
function p.CallBack_ShowTheDoorSucceed( nPlayerID )
	if ( p.ArmyBanquetStatus == ArmyBanquetStatus.BS_HOST ) then
		-- 当前玩发起驱逐
		CloseLoadBar();--
		for i, v in pairs( p.tArmyBanquetInfor.tAttendeeList ) do
			if ( nPlayerID == v[ALDI.PlayerID] ) then
				table.remove( p.tArmyBanquetInfor.tAttendeeList, i );
				break;
			end
		end
		p.FillArmyBanquetInfor( p.pLayerArmyBanquetInfor_Host, p.tArmyBanquetInfor.tAttendeeList );
		-- 金币开席按钮在参与者达5个人后变灰
		local pBtnGoldStart = GetButton( p.pLayerArmyBanquetInfor_Host, ID_BTN_GOLDSTART );
		if ( table.getn( p.tArmyBanquetInfor.tAttendeeList ) < MsgArmyBanquet.BanquetLimit ) then
			pBtnGoldStart:EnalbeGray( false );
		else
			pBtnGoldStart:EnalbeGray( true );
		end
	elseif ( p.ArmyBanquetStatus == ArmyBanquetStatus.BS_GUEST ) then
		-- 当前玩家被驱逐
		if ( nPlayerID == GetPlayerId() ) then
			p.tArmyBanquetInfor	= nil;
			p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
			--
			p.pLayerPlayerInfor:SetVisible( true );
			p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
			--
			local pScrollViewContainer = GetScrollViewContainer( p.pLayerArmyBanquetList, ID_LIST_ArmyBanquet );
			local nViewAmount = pScrollViewContainer:GetViewCount();
			for i=1, nViewAmount do
				local pView			= pScrollViewContainer:GetViewById( i );
				local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
				pBtnJoin:SetVisible( true );
			end
			CommonDlgNew.ShowYesDlg( SZ_SHOW_THE_DOOR, nil, nil, 3 );
		end
	end
end

---------------------------------------------------
-- 定时发送获取宴会列表请求
function p.OnTimer_SendMsgGetArmyBanquetList( nTimerID )
	if not IsUIShow( NMAINSCENECHILDTAG.ArmyBanquet ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	if ( p.pLayerArmyBanquetList == nil ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	MsgArmyBanquet.SendMsgGetBanquetList();
end

---------------------------------------------------
-- 宴会时间过回调
function p.CallBack_TimeOut()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_TIME_OUT, nil, nil, 3 );
	p.tArmyBanquetInfor	= nil;
	p.ArmyBanquetStatus = ArmyBanquetStatus.BS_NONE;
	p.pLayerPlayerInfor:SetVisible( true );
	--p.pLayerNotice:SetVisible( true );
	p.pLayerArmyBanquetList:SetVisible( false );
	p.pLayerArmyBanquetInfor_Host:SetVisible( false );
	p.pLayerArmyBanquetInfor_Guest:SetVisible( false );
	if ( p.nTimerID ~= nil ) then
		UnRegisterTimer( p.nTimerID );
		p.nTimerID = nil;
	end
	local pBtn = GetButton( p.pLayerPlayerInfor, ID_BTN_PREPARE );
	pBtn:EnalbeGray( true );
end


---------------------------------------------------
-- 显示出错文字
function p.ShowErrorString( nCode )
end


---------------------------------------------------
--刷新金钱
function p.RefreshMoney()
    LogInfo("ArmyBanquet: RefreshMoney");
    local pScene = GetSMGameScene();
    if( pScene == nil ) then
        return;
    end
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.ArmyBanquet );
    if( pLayer == nil ) then
        return;
    end
    local nUserID		= GetPlayerId();
    local szSilver		= MoneyFormat( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) );
    local szGold		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY ) );
    
    _G.SetLabel( pLayer, ID_LABEL_SELVER, szSilver);
    _G.SetLabel( pLayer, ID_LABEL_GOLD, szGold);
end
GameDataEvent.Register( GAMEDATAEVENT.USERATTR, "ArmyBanquet.RefreshMoney", p.RefreshMoney );
