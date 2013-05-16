---------------------------------------------------
--描述: 战神像
--时间: 2012.3.26
--作者: Guosen
---------------------------------------------------
-- 进入战神像界面接口：		Warlord.Entry()
---------------------------------------------------

Warlord = {}
local p = Warlord;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 25;	-- X

local ID_LABEL_SPIRIT				= 24;	-- 武魂值
local ID_LABEL_GOLD					= 20;	-- 金币值

local ID_PIC_WARLORD1				= 101;	-- 武神像1
local ID_PIC_WARLORD2				= 102;	-- 武神像2
local ID_PIC_WARLORD3				= 103;	-- 武神像3

local ID_BTN_WARLORD1				= 31;	-- 武神像按钮1
local ID_BTN_WARLORD2				= 32;	-- 武神像按钮2 
local ID_BTN_WARLORD3				= 33;	-- 武神像按钮3

local ID_BTN_LEFT_ARROW				= 1;
local ID_BTN_RIGHT_ARROW			= 242;

local ID_BTN_WORSHIP1				= 42;	-- 普通参拜按钮
local ID_BTN_WORSHIP2				= 43;	-- 虔诚参拜按钮
local ID_BTN_WORSHIP3				= 44;	-- 狂热参拜按钮


local ID_LABEL_WORSHIP1				= 11;	-- 普通参拜文本
local ID_LABEL_WORSHIP2				= 12;	-- 虔诚参拜文本
local ID_LABEL_WORSHIP3				= 13;	-- 狂热参拜文本


---------------------------------------------------
-- 选中武将的信息窗口
local ID_TIPS_BTN_CLOSE						= 29;	-- "关闭"按钮
local ID_TIPS_BTN_INVITE					= 67;	-- "招募"按钮
local ID_TIPS_BTN_REJOIN					= 30;	-- "归队"按钮
local ID_TIPS_BTN_GOLD_INVITE				= 40;	-- "金币招募"按钮

local ID_TIPS_PIC_PET_HEAD					= 39;	-- 武将头像
local ID_TIPS_LABEL_PET_NAME				= 43;	-- 武将名字(+阵营)
local ID_TIPS_LABEL_PET_LEVEL				= 44;	-- 武将等级
local ID_TIPS_LABEL_PET_JOB					= 46;	-- 武将职业
local ID_TIPS_LABEL_PET_STR					= 55;	-- 武将力量
local ID_TIPS_LABEL_PET_AGI					= 48;	-- 武将敏捷
local ID_TIPS_LABEL_PET_INT					= 57;	-- 武将智力
local ID_TIPS_LABEL_PET_HP					= 54;	-- 武将生命
local ID_TIPS_LABEL_PET_STR_I				= 24;	-- 武将成长加成力量
local ID_TIPS_LABEL_PET_AGI_I				= 25;	-- 武将成长加成敏捷
local ID_TIPS_LABEL_PET_INT_I				= 26;	-- 武将成长加成智力
local ID_TIPS_LABEL_PET_HP_I				= 27;	-- 武将成长加成生命
local ID_TIPS_LABEL_PET_SKILL				= 56;	-- 武将绝招
local ID_TIPS_LABEL_PET_RANK				= 60;	-- 该武将招募需求军衔
local ID_TIPS_LABEL_PET_SILVER 				= 59;	-- 该武将招募需求武魂
local ID_TIPS_LABEL_PET_GOLD				= 31;	-- 该武将招募需求金币
local ID_TIPS_LABEL_SKILL_DESC				= 75;	-- 绝招介绍

---------------------------------------------------
local UI_ZORDER				= 5010;	--UILayerZOrder.ActivityLayer--盖在聊天按钮上的ZORDER

local N_DEFAULT_AMOUNT		= 1;					-- 缺省的参拜次数

local SZ_INFOR				= GetTxtPri("WL_T1");	-- 消耗XX金币，获得X武魂+XX银币

---------------------------------------------------

local CAMP_WARLORD			= 80;	-- 战神级武将的阵营

local tPetIDListWarlord		= RoleInvite.GetPetIDListByCamp(CAMP_WARLORD);

local PRESNT_NUM_PER_PAGE	= 3;	-- 一页显示的数量

local DISP_PAGE_NUM			= math.floor( (table.getn(tPetIDListWarlord)+PRESNT_NUM_PER_PAGE-1) / PRESNT_NUM_PER_PAGE );--总可以显示的页数

---------------------------------------------------
-- 战神像图控件表
local tPicCtrl = {
	ID_PIC_WARLORD1,
	ID_PIC_WARLORD2,
	ID_PIC_WARLORD3,
};


--local tPetListPerPage {-- 每页武将列表,
	--nPetID,		-- 武将ID(至少招募过一次)
	--nPetTypeID,	-- 武将类型ID
	--nPos,			-- 位置
	--bIsGray,		-- 
--};

---------------------------------------------------
p.pLayerWarlordUI		= nil;	-- 
p.nUserVisitNum			= nil;	-- 已参拜次数
p.nChoosenWarlord		= nil;	-- 选中的战神像
p.nCurPage				= nil;	-- 当前页-当前显示页数
p.tPetInforList			= nil;	-- 武将信息,{nPetID,nPetTypeID,nPos,bIsGray}
p.nChoosenPetIndex		= nil;	-- 选中的武将索引
p.pLayerPetInfor		= nil;	-- 武将信息窗口

---------------------------------------------------
-- 进入--发数据给服务端
function p.Entry()
--	ShowLoadBar();--
	MsgWarlord.SendMsgEntry();
end

function p.EntryTest()
	p.ShowWarlordMainUI();
--	
--local nUserVisitNum = 0;
--	p.CallBack_Refresh( nUserVisitNum );
end



---------------------------------------------------
-- 检测玩家是否有某种道具
-- 参数：该道具的 ITEM_TYPE
function p.GetItemAmount( nItemType )
    local nCount = 0;
	local nUserID		= GetPlayerId();
	local tItemIDList	= ItemUser.GetBagItemList( nUserID );
	for i, v in ipairs( tItemIDList ) do
		local nItemTypeTmp	= Item.GetItemInfoN( v, Item.ITEM_TYPE );
		if( nItemTypeTmp == nItemType ) then
            nCount = Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
			break;
		end
	end
	return nCount;
end

---------------------------------------------------
-- 显示战神像主界面
function p.ShowWarlordMainUI()
	--LogInfo( "Warlord: ShowWarlordMainUI()" );
	p.pLayerWarlordUI		= nil;	-- 
	p.nUserVisitNum			= nil;	-- 已参拜次数
	p.nChoosenWarlord		= nil;	-- 选中的战神像
	p.nCurPage				= nil;	-- 当前页-当前显示页数
	p.tPetInforList			= nil;	-- 武将信息,{nPetID,nPetTypeID,nPos,bIsGray}
	p.nChoosenPetIndex		= nil;	-- 选中的武将索引
	p.pLayerPetInfor		= nil;	-- 武将信息窗口
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "Warlord: ShowWarlordMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Warlord: ShowWarlordMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.Warlord );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UI_ZORDER );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Warlord: ShowWarlordMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Warlord/Warlord.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	
	p.pLayerWarlordUI = layer;
	p.SetWorshipInfor();
	p.GetPetInforList();--
	p.nCurPage	= 1;
	p.DisplayWarlordPic( p.nCurPage );
--	
	--local pPic1				= p.GetWarlordStatue( tPetIDListWarlord[2] );
	--local pImageWarlord1	= GetImage( p.pLayerWarlordUI, tPicCtrl[1] );
	--pImageWarlord1:SetPicture(pPic1);
	--local pPic2				= p.GetWarlordStatue( tPetIDListWarlord[1] );
	--local pImageWarlord2	= GetImage( p.pLayerWarlordUI, tPicCtrl[2] );
	--pImageWarlord2:SetPicture(pPic2);
	--local pPic3				= p.GetWarlordStatue( tPetIDListWarlord[3] );
	--local pImageWarlord3	= GetImage( p.pLayerWarlordUI, tPicCtrl[3] );
	--pImageWarlord3:SetPicture(pPic3);

	--local pBtnChoosePet1	= GetButton( p.pLayerWarlordUI, ID_BTN_WARLORD1 );
	--pBtnChoosePet1:SetImage( pPic1, true );
	--local pBtnChoosePet2	= GetButton( p.pLayerWarlordUI, ID_BTN_WARLORD2 );
	--pBtnChoosePet2:SetImage( pPic2, true );
	--local pBtnChoosePet3	= GetButton( p.pLayerWarlordUI, ID_BTN_WARLORD3 );
	--pBtnChoosePet3:SetImage( pPic3, true );

	p.RefreshMoney();--显示银币与金币
	--
end

---------------------------------------------------
-- 显示战神像图(页数)
function p.DisplayWarlordPic( nPageNum )
	if ( p.tPetInforList == nil ) then
		return;
	end
	for i=1, PRESNT_NUM_PER_PAGE do
		local nOrdinal	= (nPageNum-1)*PRESNT_NUM_PER_PAGE+i;
		if ( nOrdinal > table.getn( p.tPetInforList ) ) then
			local pImageWarlord	= GetImage( p.pLayerWarlordUI, tPicCtrl[i] );
			pImageWarlord:SetPicture(nil);--
		else
			local tPetInfor		= p.tPetInforList[nOrdinal];
			local pPic			= nil;
			local pImageWarlord	= GetImage( p.pLayerWarlordUI, tPicCtrl[i] );
			if ( tPetInfor.bIsGray == true ) then
				pPic			= p.GetGrayWarlordStatue( tPetInfor.nPetTypeID );
			else
				pPic			= p.GetWarlordStatue( tPetInfor.nPetTypeID );
			end
			pImageWarlord:SetPicture(pPic);
		end
	end
end

---------------------------------------------------
-- 关闭战神像主界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.Warlord, true );--p.pLayerMainUI:RemoveFromParent( true );
	end
	p.pLayerWarlordUI		= nil;
	p.nUserVisitNum			= nil;
	p.nChoosenWarlord		= nil;
	p.nCurPage				= nil;
	p.tPetInforList			= nil;
	p.nChoosenPetIndex		= nil;
	p.pLayerPetInfor		= nil;
end

---------------------------------------------------
-- 战神像主界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( ID_BTN_WORSHIP1 == tag ) then
			p.Worship( WWM.Normal );
		elseif ( ID_BTN_WORSHIP2 == tag ) then
			p.Worship( WWM.Devout );
		elseif ( ID_BTN_WORSHIP3 == tag ) then
			p.Worship( WWM.Wild );
		elseif ( ID_BTN_WARLORD1 == tag ) then
			local nOrdinal	= (p.nCurPage-1)*PRESNT_NUM_PER_PAGE+1;
			if ( ( p.tPetInforList ~= nil ) and ( nOrdinal <= table.getn( p.tPetInforList ) ) ) then
				p.CreatePetInforLayer(nOrdinal);
			end
		elseif ( ID_BTN_WARLORD2 == tag ) then
			local nOrdinal	= (p.nCurPage-1)*PRESNT_NUM_PER_PAGE+2;
			if ( ( p.tPetInforList ~= nil ) and ( nOrdinal <= table.getn( p.tPetInforList ) ) ) then
				p.CreatePetInforLayer(nOrdinal);
			end
		elseif ( ID_BTN_WARLORD3 == tag ) then
			local nOrdinal	= (p.nCurPage-1)*PRESNT_NUM_PER_PAGE+3;
			if ( ( p.tPetInforList ~= nil ) and ( nOrdinal <= table.getn( p.tPetInforList ) ) ) then
				p.CreatePetInforLayer(nOrdinal);
			end
		end
	end
	return true;
end


---------------------------------------------------
-- 祭拜(类型)
function p.Worship( nType )
	if ( p.nUserVisitNum ~= nil and p.nUserVisitNum < MsgWarlord.tConfig.nVisitMax ) then
		local nPlayerGold = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_EMONEY );
		local nNeededGold = 0;
		local szWorshipType = "";
		if ( nType == WWM.Normal ) then
			nNeededGold = MsgWarlord.tConfig.nNormalSpendEmoney;
			szWorshipType = GetTxtPri("WL_T6")
		elseif( nType == WWM.Devout ) then
			nNeededGold = MsgWarlord.tConfig.nDevoutSpendEmoney;
			szWorshipType = GetTxtPri("WL_T7")
		elseif( nType == WWM.Wild ) then
			nNeededGold = MsgWarlord.tConfig.nWildSpendEmoney;
			szWorshipType = GetTxtPri("WL_T8")
		end
    	if ( nPlayerGold < nNeededGold ) then
			CommonDlgNew.ShowYesDlg( GetTxtPri("TH_T2"), nil, nil, nil );
    	else
    	    -- 发送虔诚祭拜消息
			--MsgWarlord.SendMsgWorship( nType );
			local szTitle = string.format( GetTxtPri("WL_T9"), nNeededGold, szWorshipType  );
			CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_ConfirmWorshipDlg, nType );
    	end
    else
		CommonDlgNew.ShowYesDlg( GetTxtPri("WL_T2"), nil, nil, nil );
	end
end

---------------------------------------------------
-- 祭拜确认回调
function p.CallBack_ConfirmWorshipDlg( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		nType = param;
		MsgWarlord.SendMsgWorship( nType );
	end
end

---------------------------------------------------
-- 设置参拜配置标签
function p.SetWorshipInfor()
	if ( p.pLayerWarlordUI == nil ) then
		return;
	end
	if ( MsgWarlord.tConfig == nil ) then
		return;
	end
	local pLabelWorship1 = GetLabel( p.pLayerWarlordUI, ID_LABEL_WORSHIP1 );
	local pLabelWorship2 = GetLabel( p.pLayerWarlordUI, ID_LABEL_WORSHIP2 );
	local pLabelWorship3 = GetLabel( p.pLayerWarlordUI, ID_LABEL_WORSHIP3 );
	local tConfig = MsgWarlord.tConfig;
	local szWorshipInfor1 = string.format( SZ_INFOR, tConfig.nNormalSpendEmoney, tConfig.nNormalSpirit, tConfig.nNormalMoney );
	local szWorshipInfor2 = string.format( SZ_INFOR, tConfig.nDevoutSpendEmoney, tConfig.nDevoutSpirit, tConfig.nDevoutMoney );
	local szWorshipInfor3 = string.format( SZ_INFOR, tConfig.nWildSpendEmoney, tConfig.nWildSpirit, tConfig.nWildMoney );
	pLabelWorship1:SetText( szWorshipInfor1 );
	pLabelWorship2:SetText( szWorshipInfor2 );
	pLabelWorship3:SetText( szWorshipInfor3 );
end

---------------------------------------------------
-- 刷新界面回调（已参拜次数）
function p.CallBack_Refresh( nUserVisitNum )
	if ( p.pLayerWarlordUI == nil ) then
		return;
	end
	p.nUserVisitNum = nUserVisitNum;
end

---------------------------------------------------
--刷新金钱
function p.RefreshMoney()
    --LogInfo("Warlord: RefreshMoney");
    local pScene = GetSMGameScene();
    if( pScene == nil ) then
        return;
    end
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.Warlord );
    if( pLayer == nil ) then
        return;
    end
    local nUserID		= GetPlayerId();
    local szSpirit		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_SPIRIT ) );
    local szGold		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY ) );
    
    _G.SetLabel( pLayer, ID_LABEL_SPIRIT, szSpirit);
    _G.SetLabel( pLayer, ID_LABEL_GOLD, szGold);
end
GameDataEvent.Register( GAMEDATAEVENT.USERATTR, "Warlord.RefreshMoney", p.RefreshMoney );



---------------------------------------------------
-- 获得彩色武神像
function p.GetWarlordStatue( nPetTypeID )
	local nIcon = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.ICON );
	local szFilePath = "Warlord/Statue/pet" .. nIcon .. ".png";
	local pPicPool = _G.DefaultPicPool();
	local pPic;
	pPic = pPicPool:AddPicture( _G.GetSMImgPath( szFilePath ), false );
    
	if not _G.CheckP(pPic) then
		LogInfo("Warlord: GetWarlordStatue() pPic is null!");
	end

	return pPic;
end
-- 获得灰色武神像
function p.GetGrayWarlordStatue( nPetTypeID )
	local nIcon = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.ICON );
	local szFilePath = "Warlord/Statue/petgray" .. nIcon .. ".png";
	local pPicPool = _G.DefaultPicPool();
	local pPic;
	pPic = pPicPool:AddPicture( _G.GetSMImgPath( szFilePath ), false );
    
	if not _G.CheckP(pPic) then
		LogInfo("Warlord: GetGrayWarlordStatue() pPic is null!");
	end

	return pPic;
end

---------------------------------------------------
-- 获得武将信息列表--
function p.GetPetInforList()
	local nPlayerID			= GetPlayerId();
	local invited_idTable	= RolePetUser.GetPetList( nPlayerID );--所有曾招募过的武将ID列表
	--local inTeam_idTable	= RolePetUser.GetPetListPlayer( nPlayerID );--在队伍中的武将ID列表
	--local inTeam_petNum	= table.getn( inTeam_idTable );--
	--local petNum_limit	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_PET_LIMIT );--
	--local nPlayerRank		= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_RANK );
	--local nPlayerPetID	= RolePetFunc.GetMainPetId( nPlayerID );
	--local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	p.tPetInforList			= {};--
	for i, v in ipairs(tPetIDListWarlord) do
		local nPetTypeID		= v;--
			
		-- 能否被招募，可被招募才显示
		--local can_call = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.CAN_CALL );
		-- 阵营
		--local camp = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.CAMP );
		--判断玩家当前的军衔是否可以开启这个伙伴
		--need_rank = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.REPUTE_LEV );
		--判断玩家当前的游戏进度是否可以开启这个伙伴
		--local need_stage = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.NEED_STAGE );
		--LogInfo( "Warlord: PlayerStage:%d, PetNeedStage:%d", nPlayerStage, need_stage );
		--判断玩家当前的等级是否可以开启这个伙伴
		--local need_level = GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.REQ_LEVEL );
		--LogInfo( "Warlord: PlayerLevel:%d, PetNeedLevel:%d", nPlayerLevel, need_level );
        	
		local nPetID		= 0;
		local petPosition	= 2;		--0队伍中;1已离队;2未入队;
		local bIsGray		= false;
        	
		-- 判断已招募和招募过的伙伴
		if ( nil ~= invited_idTable ) then
			for nIndex, nInvitedPetID  in ipairs( invited_idTable ) do
				local tmpPetType = RolePet.GetPetInfoN( nInvitedPetID, PET_ATTR.PET_ATTR_TYPE );
				--LogInfo( "Warlord: nInvitedPetID=%d,type=%d", nInvitedPetID, petType );
				if ( nPetTypeID == tmpPetType ) then
					petPosition = RolePet.GetPetInfoN( nInvitedPetID, PET_ATTR.PET_ATTR_POSITION );	-- 0/1
					nPetID		= nInvitedPetID;
					break;
				end
			end
		end
        	
		-- 已招募的置灰
		if petPosition == 0 then
			bIsGray		= true;
		end
			
		-- 银币需求为0且未曾招募过的不显示（离队的可显示）
		--local nPetSilver	= GetDataBaseDataN( "pet_config", nPetTypeID, DB_PET_CONFIG.MONEY );
		local tPetInfor = {};
		tPetInfor.nPetID		= nPetID;
		tPetInfor.nPetTypeID	= nPetTypeID;
		tPetInfor.nPos			= petPosition;
		tPetInfor.bIsGray		= bIsGray;
			
		table.insert( p.tPetInforList, tPetInfor );
	end
end

---------------------------------------------------

---------------------------------------------------
-- 创建“武将信息及招募/归队”窗口（"p.tPetInforList"表的索引）
function p.CreatePetInforLayer( nChoosenPetIndex )
	if ( p.pLayerWarlordUI == nil ) then
		return;
	end
	if ( p.pLayerPetInfor ~= nil ) then
		p.pLayerPetInfor:RemoveFromParent( true );
		p.pLayerPetInfor = nil;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo( "Warlord: CreatePetInforLayer failed! layer is nil" );
		return  false;
	end
	layer:Init();
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetTag( TAG_PET_INFO_LAYER );
	layer:SetBackgroundColor(ccc4(0,0,0,100));

	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load( "Warlord/PetInfo.ini", layer, p.OnPetInfoUIEvent, 0, 0 );
		uiLoad:Free();
	end

	p.pLayerWarlordUI:AddChildZ( layer, 2 );--触摸消息不穿透
	
	p.nChoosenPetIndex = nChoosenPetIndex;
	local tPetInfor = p.tPetInforList[p.nChoosenPetIndex];
	p.InitPetInfoUI( layer, tPetInfor )
	
	p.pLayerPetInfor	= layer;
	return true;
end

---------------------------------------------------
function p.ClosePetInforLayer()
	if ( p.pLayerPetInfor ~= nil ) then
		p.pLayerPetInfor:RemoveFromParent( true );
		p.pLayerPetInfor = nil;
	end
end

---------------------------------------------------
-- “武将信息及招募/归队”窗口事件响应
function p.OnPetInfoUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local nPlayerID			= GetPlayerId();
	local inTeam_idTable	= RolePetUser.GetPetListPlayer( nPlayerID );--在队伍中的武将ID列表
	local inTeam_petNum	= table.getn( inTeam_idTable );--
	local petNum_limit	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_PET_LIMIT );--
	local nPlayerRank	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_RANK );
	local nPlayerPetID	= RolePetFunc.GetMainPetId( nPlayerID );
	local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_TIPS_BTN_CLOSE == tag then
			p.ClosePetInforLayer();--uiNode:GetParent():GetParent():RemoveChild( uiNode:GetParent(), true );
			return true;
		elseif ID_TIPS_BTN_INVITE == tag then
			-- 招募
			local nPetType	= p.tPetInforList[p.nChoosenPetIndex].nPetTypeID;
			if ( inTeam_petNum >= petNum_limit ) then
				-- 队伍满员
				CommonDlgNew.ShowYesDlg( GetTxtPri("RI_T10"), nil, nil, nil );
			else
				local nNeededLevel = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_LEVEL );
				if ( nPlayerLevel < nNeededLevel ) then
					-- 等级低
					CommonDlg.ShowWithConfirm( GetTxtPri("RI_T21")..nNeededLevel..GetTxtPri("Common_Level"), nil );
				else
					if ( nPlayerRank < GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REPUTE_LEV ) ) then
						-- 军衔低
						CommonDlg.ShowWithConfirm( GetTxtPri("RI_T11"), nil );
						
					else
						local nNeededSpirit = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.SPIRIT );
						local nPlayerSpirit	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_SPIRIT );
						if ( nPlayerSpirit >= nNeededSpirit ) then
							-- 武魂足
							_G.MsgRolePet.SendBuyPetWithSpirit( nPetType );
						else
							-- 武魂缺
							CommonDlgNew.ShowYesDlg( GetTxtPri("WL_T5"), nil, nil, nil );
						end
					end
				end
			end
		elseif ID_TIPS_BTN_REJOIN == tag then
			-- 归队
			local nPetID	= p.tPetInforList[p.nChoosenPetIndex].nPetID;
			if ( inTeam_petNum < petNum_limit ) then
				-- 发送归队消息给服务端
				_G.MsgRolePet.SendBuyBackPet( nPetID );
			else
				CommonDlgNew.ShowYesDlg( GetTxtPri("RI_T10"), nil, nil, nil );
			end
		end
	end
	return true;
end

---------------------------------------------------
-- 通过PetType来初始化“武将信息及招募/归队”窗口(在野武将)
function p.InitPetInfoUI( pLayerInfor, tPetInfor )
	if ( pLayerInfor == nil or tPetInfor == nil ) then
		return;
	end
	
	local nPetID	= tPetInfor.nPetID;
	local nPetType	= tPetInfor.nPetTypeID;
	local nPos		= tPetInfor.nPos;
	
	-- 头像
	local pPetImage		= GetButton( pLayerInfor, ID_TIPS_PIC_PET_HEAD );
	local pic			= GetPetPotraitPic(nPetType);
	if CheckP(pic) then
	    pPetImage:SetImage( pic, true );
	end

	-- 名称
	local value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
	local l_name = SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_NAME, value );
    local cColor = ItemPet.GetPetConfigQuality(nPetType);
    l_name:SetFontColor(cColor);

	-- 等级
	value = 1;
	if ( nPos == 1 ) then
		--在队或离队的等级
		value = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LEVEL );
	end
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_LEVEL, value ..GetTxtPub("Level") );
	
	-- 站位类型
	local nStandType = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.STAND_TYPE );
	local szStandType = "(+)";
	if ( 1 == nStandType ) then
		szStandType = GetTxtPri("RI_T6");
	elseif ( 2 == nStandType ) then
		szStandType = GetTxtPri("RI_T7");
	elseif ( 3 == nStandType ) then
		szStandType = GetTxtPri("RI_T8");
	end
	-- 职业
	value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.PRO_NAME );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_JOB, value .. szStandType );

	if ( nPos == 2 ) then
		-- 力量
		value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_PHYSICAL );
		SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_STR, SafeN2S(value) );
		
		-- 敏捷
		value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_SUPER_SKILL );
		SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_AGI, SafeN2S(value) );
		
		-- 智力
		value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_MAGIC );
		SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_INT, SafeN2S(value) );
		
		-- 生命
		value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_LIFE );
		SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_HP, SafeN2S(value) );
	elseif ( nPos == 1 or nPos == 0 ) then
		-- 力量
		value = RolePet.GetTotalPhy( nPetID );
		SetLabel( pLayerTips, ID_TIPS_LABEL_PET_STR, SafeN2S(value) );
		
		-- 敏捷
		value = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_DEX );
		SetLabel( pLayerTips, ID_TIPS_LABEL_PET_AGI, SafeN2S(value) );
		
		-- 智力
		value = RolePet.GetTotalMagic( nPetID );
		SetLabel( pLayerTips, ID_TIPS_LABEL_PET_INT, SafeN2S(value) );
		
		-- 生命
		value = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LIFE_LIMIT );
		SetLabel( pLayerTips, ID_TIPS_LABEL_PET_HP, value );
	end

	-- 力量加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_PHYSICAL );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_STR_I, SafeN2S(value/1000) );

	-- 敏捷加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_SUPER_SKILL );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_AGI_I, SafeN2S(value/1000) );

	-- 智力加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_MAGIC );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_INT_I, SafeN2S(value/1000) );

	-- 生命加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_LIFE );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_HP_I, SafeN2S(value/1000) );
	
	-- 绝招
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.SKILL );
	local szSkillName = GetDataBaseDataS( "skill_config", value, DB_SKILL_CONFIG.NAME );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_SKILL, szSkillName );
	
	-- 绝招描述
	local szSkillDesc = GetDataBaseDataS( "skill_config", value, DB_SKILL_CONFIG.DESCRRIPTION );
	SetLabel( pLayerInfor, ID_TIPS_LABEL_SKILL_DESC, szSkillDesc );
	
	-- 需要军衔
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REPUTE_LEV );
	local szPlayerRank	= GetDataBaseDataS( "rank_config", value, DB_RANK_CONFIG.RANK_NAME );
	--if ( "" == szPlayerRank ) then
	--	szPlayerRank = GetTxtPri("RI_T9");
	--end
	SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_RANK, szPlayerRank);
	
	if ( nPos == 2 ) then
		-- 需要武魂
		value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.SPIRIT );
		SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_SILVER, SafeN2S(value)..GetTxtPri("WL_T3") );
	elseif ( nPos == 1 or nPos == 0 ) then
		-- 需要武魂
		SetLabel( pLayerInfor, ID_TIPS_LABEL_PET_SILVER, GetTxtPri("WL_T4") );
	end
	
	-- 不显示需要金币……
	local pLabel = GetLabel( pLayerInfor, ID_TIPS_LABEL_PET_GOLD );
	pLabel:SetVisible(false);
	
	-- 隐藏"招募"按钮
	local pBtnInvite	= GetButton( pLayerInfor, ID_TIPS_BTN_INVITE );
	if CheckP( pBtnInvite ) then
		pBtnInvite:SetVisible(false);
	end
	-- 隐藏"归队"按钮
	local pBtnRejoin	= GetButton( pLayerInfor, ID_TIPS_BTN_REJOIN );
	if CheckP( pBtnRejoin ) then
		pBtnRejoin:SetVisible(false);
	end
	if ( nPos == 2 ) then
		pBtnInvite:SetVisible(true);
	elseif ( nPos == 1 ) then
		pBtnRejoin:SetVisible(true);
	end

	--隐藏"金币招募"按钮
	local pBtnGoldInvite = GetButton( pLayerInfor, ID_TIPS_BTN_GOLD_INVITE );
	if CheckP( pBtnGoldInvite ) then
		pBtnGoldInvite:SetVisible(false);
	end
end

---------------------------------------------------
-- 响应服务器消息刷新
function p.RefreshContainer( btAction, nPetID )
    LogInfo("RoleInvite: RefreshContainer");
	-- 关闭武将信息窗口
	if ( nil == p.pLayerWarlordUI ) then
    	LogInfo("Warlord: RefreshContainer() faild pLayerWarlordUI is nil");
		return;
	end
	if ( nil == p.pLayerPetInfor ) then
    	LogInfo("Warlord: RefreshContainer() faild pLayerPetInfor is nil");
		return;
	end
    p.ClosePetInforLayer();
    
	local nPetType	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_TYPE );
	local szName 	= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
    
	if ( 2 == btAction ) then
		-- 归队
		CommonDlgNew.ShowYesDlg( szName..GetTxtPri("RI_T16"), nil, nil, nil );
	elseif ( 1 == btAction ) then
		-- 招募
		CommonDlgNew.ShowYesDlg( szName..GetTxtPri("RI_T17"), nil, nil, nil );
		-- 播放招募成功光效
		PlayEffectAnimation.ShowAnimation(6);
	end
	--p.nChoosenPetIndex	= 0;
	p.GetPetInforList();--
	p.DisplayWarlordPic( p.nCurPage );

    CloseLoadBar();
end

---------------------------------------------------
--
function p.InviteSucess( btAction, nPetID )
	LogInfo( "Warlord: InviteSucess() btAction:%d, nPetId:%d", btAction, nPetID );
	if IsUIShow(NMAINSCENECHILDTAG.Warlord) then
		p.RefreshContainer( btAction, nPetID );
	else
		-- 没开启招募界面的回调
		if ( 2 == btAction ) then
			-- 归队
			--CommonDlgNew.ShowYesDlg( szName..GetTxtPri("RI_T16"), nil, nil, 3 );
		elseif ( 1 == btAction ) then
			-- 招募
			--CommonDlgNew.ShowYesDlg( szName..GetTxtPri("RI_T17"), nil, nil, 3 );
			PlayEffectAnimation.ShowAnimation(6);
		end
	end
end