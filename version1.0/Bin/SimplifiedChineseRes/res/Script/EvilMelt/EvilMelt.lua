---------------------------------------------------
--描述: 装备魔化
--时间: 2013.8.2
--作者: Guosen
---------------------------------------------------
-- 进入装备魔化界面接口：		EvilMelt.Entry()
---------------------------------------------------

EvilMelt = {}
local p = EvilMelt;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 3;	-- X
local ID_LABEL_SELVER				= 243;	-- 银币值
local ID_LABEL_GOLD					= 242;	-- 金币值
local ID_LABEL_CRYSTAL				= 229;	-- 魔晶值
local ID_PIC_LEFT_ZONE				= 2;	-- 左侧区域
local ID_PIC_RIGHTT_ZONE			= 227;	-- 右侧区域

-- 
local ID_LIST_STORAGE_ITEM				= 600;	-- 装备所在仓库列表--人身上，背包上...
local ID_LIST_STORAGE_NAME				= 601;	-- 装备所在仓库名称列表

local ID_PIC_LEFT_ARROW				= 24;	-- 列表左箭头
local ID_PIC_RIGHT_ARROW			= 25;	-- 列表右箭头

---------------------------------------------------
-- 右侧界面控件
local ID_BTN_EVIL_MELT				= 11;	-- 魔化按钮
local ID_BTN_ITEM_BUTTON			= 2;	-- 装备图像按钮--
local ID_LABEL_ITEM_NAME			= 3;	-- 装备名称

local ID_LABEL_PROPERTY_1_NAME			= 201;	-- 属性名称
local ID_LABEL_PROPERTY_2_NAME			= 202;
local ID_LABEL_PROPERTY_3_NAME			= 203;

local ID_LABEL_PROPERTY_1_CURRENT		= 211;	-- 属性当前数值
local ID_LABEL_PROPERTY_2_CURRENT		= 212;
local ID_LABEL_PROPERTY_3_CURRENT		= 213;

local ID_LABEL_PROPERTY_1_AFTER			= 221;-- 属性魔化后数值
local ID_LABEL_PROPERTY_2_AFTER			= 222;
local ID_LABEL_PROPERTY_3_AFTER			= 223;

local ID_LABEL_CRYSTAL_NEEDED			= 39;	-- 需要的魔晶量
local ID_LABEL_SELVER_NEEDED			= 37;	-- 需要的银币量

---------------------------------------------------
-- 
local TAG_PET_NAME	= 1;        -- 武将名字

---------------------------------------------------
-- 物品列表项界面控件
local TAG_EQUIP_PIC     = 2;    --装备图片
local TAG_EQUIP_NAME    = 6;    --装备名字
local TAG_EQUIP_LEVEL   = 7;    --等级
local TAG_EQUIP_BUTTON  = 5;    --按钮-checkbox
---------------------------------------------------

---------------------------------------------------
local SZ_ERROR_01					= GetTxtPri("EM_I1");--"银币不足。。。";
local SZ_ERROR_02					= GetTxtPri("EM_I2");--"数量不足。。。";

---------------------------------------------------
p.EVIL_CRYSTAL_ITEM_TYPE_ID			= 35000001;	-- "魔晶"物品类型ID

local SZ_ITEMTYPE_EVILMELT			= "itemtype_evilmelt";
local tEvilItemTypeList = GetDataBaseIdList( SZ_ITEMTYPE_EVILMELT );--

---------------------------------------------------
-- tStorage={ petId=123,petName="",equipIdList={...} };
p.tStorageList	= nil;--{ ... },(petId=0为背包)
--local equipIdList = ItemPet.GetEquipItemList(nPlayerID, petId);

p.pLayerMainUI			= nil;	-- 主界面
p.pLayerRightZone		= nil;	-- 右边区域的层
p.pItemViewChoosen		= nil;	-- 选中的物品VIEW界面
p.nNeededMoney			= nil;
p.nNeededItemType		= nil;
p.nNeededItemNum		= nil;


---------------------------------------------------
-- 进入--
function p.Entry()
	p.pLayerMainUI			= nil;
	p.pLayerRightZone		= nil;
	p.pItemViewChoosen		= nil;
	p.nNeededMoney			= nil;
	p.nNeededItemType		= nil;
	p.nNeededItemNum		= nil;
	p.ShowEvilMeltMainUI();
	--ShowLoadBar();--
	--MsgEvilMelt.SendMsgGetFreeCardAmount();
end

---------------------------------------------------
-- 显示装备魔化主界面
function p.ShowEvilMeltMainUI()
	--LogInfo( "EvilMelt: ShowEvilMeltMainUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "EvilMelt: ShowEvilMeltMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EvilMelt: ShowEvilMeltMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.EvilMelt );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UILayerZOrder.NormalLayer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EvilMelt: ShowEvilMeltMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "foster_D.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	--
	p.pLayerMainUI = layer;
	p.CreateRightZoneLayer( p.pLayerMainUI );
	p.FillStorageDataList();
	p.FillStorageNameList( p.pLayerMainUI, p.tStorageList );
	p.FillStorageItemList( p.pLayerMainUI, p.tStorageList );
	p.ShowArrow();
	--显示金钱数量
	p.RefreshMoney();
	--显示魔晶数量
	p.RefreshEvilCrystal();
end



-- 关闭装备魔化界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.EvilMelt, true );
	end
	p.pLayerMainUI			= nil;
	p.pLayerRightZone		= nil;
	p.pItemViewChoosen		= nil;
	p.nNeededMoney			= nil;
	p.nNeededItemType		= nil;
	p.nNeededItemNum		= nil;
end

---------------------------------------------------
-- 装备魔化界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		end
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if ( tag == ID_LIST_STORAGE_ITEM ) then--
			--
			if ( CheckP(p.pLayerMainUI) ) then
				local pItemContainer = GetScrollViewContainerM( p.pLayerMainUI, ID_LIST_STORAGE_ITEM );
				local pNameContainer = GetScrollViewContainer( p.pLayerMainUI, ID_LIST_STORAGE_NAME );
				if ( CheckP(pItemContainer) and CheckP(pNameContainer) ) then
					pNameContainer:ShowViewByIndex(pItemContainer:GetBeginIndex());
				end
			end
		elseif ( tag == ID_LIST_STORAGE_NAME ) then--
			p.ShowArrow();
		end
	end
	return true;
end



---------------------------------------------------
-- 创建右侧界面
function p.CreateRightZoneLayer( pLayer )
	local pUINode = GetUiNode( pLayer, ID_PIC_RIGHTT_ZONE );
	if ( not CheckP(pUINode) ) then
		return;
	end
	local tRect = pUINode:GetFrameRect();
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EvilMelt: ShowEvilMeltMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.EvilMelt );
	layer:SetFrameRect( CGRectMake( 0, 0, tRect.size.w, tRect.size.h ) );
	pUINode:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EvilMelt: ShowEvilMeltMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "foster_D_R.ini", layer, p.OnUIEventRightZone, 0, 0 );
	uiLoad:Free();
	p.pLayerRightZone = layer;
	p.FillRightZone( p.pLayerRightZone, 0 );
end

---------------------------------------------------
-- 右侧界面的事件响应
function p.OnUIEventRightZone( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_EVIL_MELT == tag ) then
			p.OnBtn_EvilMelt();
		end
	end
	return true;
end

--
function p.OnBtn_EvilMelt()
	if ( p.pItemViewChoosen == nil ) then
		return;
	end
	if ( p.nNeededMoney == nil or p.nNeededItemType == nil or p.nNeededItemNum == nil ) then
		return;
	end
	local nUserID		= GetPlayerId();
	if ( p.nNeededMoney > GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) ) then
		CommonDlgNew.ShowYesDlg( SZ_ERROR_01, nil, nil, 3 );
		return;
	end
	local nItemAmount	= Banquet.GetItemAmount(p.nNeededItemType);
	if ( p.nNeededItemNum > nItemAmount ) then
		local nItemName		= ItemFunc.GetName(p.nNeededItemType);
		CommonDlgNew.ShowYesDlg( nItemName..SZ_ERROR_02, nil, nil, 3 );
		return;
	end
	local nItemID	= p.pItemViewChoosen:GetTag();
	MsgEvilMelt.SendMsgEvilMelt(nItemID);
end

---------------------------------------------------
-- 填充列表
function p.FillStorageDataList()
	p.tStorageList = {};
	local nPlayerID		= GetPlayerId();
	local tPetIDList	= RolePetUser.GetPetListPlayer(nPlayerID);
	tPetIDList			= RolePet.OrderPets(tPetIDList);	
	for i, nPetID in ipairs(tPetIDList) do
		local tStorage = {};
		tStorage.nOwnerID		= nPetID;
		local szPetName			= ConvertS( RolePetFunc.GetPropDesc( nPetID, PET_ATTR.PET_ATTR_NAME ) );
		tStorage.szOwnerName	= szPetName;
		tStorage.tItemIDList	= {};
		local tItemIDList = ItemPet.GetEquipItemList( nPlayerID, nPetID );--当前武将身上的物品
		tItemIDList = Item.OrderItems(tItemIDList);
		for i, nItemID in ipairs(tItemIDList) do
			local nItemType = Item.GetItemInfoN( nItemID, Item.ITEM_TYPE );
			for j, nEvilItemType in ipairs(tEvilItemTypeList) do
				if ( nItemType == nEvilItemType ) then
					table.insert( tStorage.tItemIDList, nItemID );
				end
			end
		end
		table.insert( p.tStorageList, tStorage );
	end
	--
	if ( true ) then
		local nPetID = 0;
		local tStorage = {};
		tStorage.nOwnerID		= nPetID;
		tStorage.szOwnerName	= GetTxtPub("bag");
		tStorage.tItemIDList	= {};
		local tItemIDList	= ItemUser.GetBagItemList(nPlayerID);--背包的物品
		tItemIDList = Item.OrderItems(tItemIDList);
		for i, nItemID in ipairs(tItemIDList) do
			local nItemType = Item.GetItemInfoN( nItemID, Item.ITEM_TYPE );
			for j, nEvilItemType in ipairs(tEvilItemTypeList) do
				if ( nItemType == nEvilItemType ) then
					table.insert( tStorage.tItemIDList, nItemID );
				end
			end
		end
		table.insert( p.tStorageList, tStorage );
	end
end

--function p.FillStorageDataList_1()
--	p.tStorageList = {};
--	local nPlayerID		= GetPlayerId();
--	local tItemIDList	= ItemUser.GetBagItemList(nPlayerID);--全部的物品--
--	local tEvilItemIDList	= {};--全部的可魔化的物品
--	for i, nItemID in ipairs(tItemIDList) do
--		local nItemType = Item.GetItemInfoN( nItemID, Item.ITEM_TYPE );
--		for j, nEvilItemType in ipairs(tEvilItemTypeList) do
--			if ( nItemType == nEvilItemType ) then
--				table.insert( tEvilItemIDList, nItemID );
--			end
--		end
--	end
--	local tPetIDList	= RolePetUser.GetPetListPlayer(nPlayerID);
--	tPetIDList			= RolePet.OrderPets(tPetIDList);	
--	for i, nPetID in ipairs(tPetIDList) do
--		local tStorage = {};
--		tStorage.nOwnerID		= nPetID;
--		local szPetName			= ConvertS( RolePetFunc.GetPropDesc( nPetID, PET_ATTR.PET_ATTR_NAME ) );
--		tStorage.szOwnerName	= szPetName;
--		tStorage.tItemIDList	= {};
--		for j, nItemID in ipairs(tEvilItemIDList) do
--			local nOwnerID = Item.GetItemInfoN( nItemID, Item.ITEM_OWNER_ID );
--			--LogInfo( "EvilMelt: FillStorageDataList() nPetID:%d, nOwnerID:%d ",nPetID,nOwnerID );
--			if ( tStorage.nOwnerID == nOwnerID ) then
--				table.insert( tStorage.tItemIDList, nItemID );
--				--LogInfo( "EvilMelt: FillStorageDataList() nPetID:%d, nItemID:%d ",nPetID,nItemID );
--			end
--		end
--		table.insert( p.tStorageList, tStorage );
--	end
--	--
--	if ( true ) then
--		local nPetID = 0;--背包
--		local tStorage = {};
--		tStorage.nOwnerID		= nPetID;
--		tStorage.szOwnerName	= GetTxtPub("bag");
--		tStorage.tItemIDList	= {};
--		for j, nItemID in ipairs(tEvilItemIDList) do
--			local nOwnerID = Item.GetItemInfoN( nItemID, Item.ITEM_OWNER_ID );
--			if ( tStorage.nOwnerID == nOwnerID ) then
--				table.insert( tStorage.tItemIDList, nItemID );
--				--LogInfo( "EvilMelt: FillStorageDataList() nPetID:%d, nItemID:%d ",nPetID,nItemID );
--			end
--		end
--		table.insert( p.tStorageList, tStorage );
--	end
--end

---------------------------------------------------
-- 填充名称列表
function p.FillStorageNameList( pLayer, tStorageList )
	if ( pLayer == nil ) then
		return;
	end
	if ( tStorageList == nil ) then
		return;
	end
	
	local container = GetScrollViewContainer( pLayer, ID_LIST_STORAGE_NAME );
	if nil == container then
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	container:SetViewSize(rectview.size);
		
	for i, tStorage in pairs(tStorageList) do
		local view = createUIScrollView();
		if view == nil then
			return;
		end
		view:Init(false);
		view:SetViewId(tStorage.nOwnerID);
		view:SetTag(tStorage.nOwnerID);
		container:AddView(view);
		--初始化ui
		local uiLoad = createNDUILoad();
		uiLoad:Load("PetNameListItem.ini", view, nil, 0, 0);
		uiLoad:Free();
		local labelName = GetLabel(view, TAG_PET_NAME);
        labelName:SetText(tStorage.szOwnerName);
        ItemPet.SetLabelColor(labelName, tStorage.nOwnerID);
		view:SetTouchEnabled(false);
	end
end

---------------------------------------------------
-- 填充各仓库列表
function p.FillStorageItemList( pLayer, tStorageList )
	if ( pLayer == nil ) then
		return;
	end
	if ( tStorageList == nil ) then
		return;
	end
	local container		= GetScrollViewContainerM( pLayer, ID_LIST_STORAGE_ITEM );--特别的ScrollViewContainer
	if ( not CheckP(container) ) then
		LogInfo( "EvilMelt: FillStorageItemList error! container is nil" );
		return;
	end
    local nIndexBegin	= container:GetBeginIndex();
    container:RemoveAllView();
    container:ShowViewByIndex(0);
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);
    container:EnableScrollBar(true);
    
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "foster_D_L_Item.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetUiNode( layer, TAG_EQUIP_BUTTON );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	for i, tStorage in pairs(tStorageList) do
        local clientLayer = createContainerClientLayerM();--特别的
        clientLayer:Init(false);
		clientLayer:SetViewSize(tSize);
		--clientLayer:SetViewId(tStorage.nOwnerID);
        container:AddView(clientLayer);
        p.FillStorageItem( clientLayer, tStorage );
	end
    --container:ShowViewByIndex(nIndexBegin);
end

---------------------------------------------------
-- 填充物品仓库
function p.FillStorageItem( pLayer, tStorage )
	for i, nItemID in ipairs(tStorage.tItemIDList) do
		local view = createUIScrollViewM();--特别的ScrollView
		view:Init(false);
		view:SetViewId(nItemID);
		view:SetTag(nItemID);
		pLayer:AddView(view);
		local uiLoad = createNDUILoad();
		uiLoad:Load( "foster_D_L_Item.ini", view, p.OnUIEventItem, 0, 0 );--物品项view
		uiLoad:Free();
		local pBtnImage		= GetItemButton( view, TAG_EQUIP_PIC );
		pBtnImage:ChangeItem(nItemID);
		local nItemType		= Item.GetItemInfoN( nItemID, Item.ITEM_TYPE );
		local szItemName	= ItemFunc.GetName(nItemType);
		local pLabelName	= GetLabel( view, TAG_EQUIP_NAME );
		pLabelName:SetText(szItemName);
		local pLabelLevel	= GetLabel( view, TAG_EQUIP_LEVEL );
		local nLevel		= Item.GetItemInfoN( nItemID, Item.ITEM_EVIL_LEVEL );
		local szLevel		= GetTxtPub("MoHua") .. nLevel .. GetTxtPub("Level");
		pLabelLevel:SetText(szLevel);
	end
end

---------------------------------------------------
-- 物品项view界面事件响应
function p.OnUIEventItem(uiNode, uiEventType, param)
	local tag 		= uiNode:GetTag();
	local pUIView	= uiNode:GetParent();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == TAG_EQUIP_PIC ) then
			p.NewFocus( pUIView );
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( tag == TAG_EQUIP_BUTTON ) then
			p.NewFocus( pUIView );
		end
	end
	return true;
end

---------------------------------------------------
-- 新焦点
function p.NewFocus( pUIView )
	if ( p.pItemViewChoosen ~= pUIView ) then
		if ( p.pItemViewChoosen ~= nil ) then
			--local pBtnFocusLast	= GetButton( p.pItemViewChoosen, TAG_EQUIP_BUTTON );
			--pBtnFocusLast:SetFocus(false);
			local uiNodeL		= GetUiNode( p.pItemViewChoosen, TAG_EQUIP_BUTTON );
			local pCheckBoxL	= ConverToCheckBox( uiNodeL );
			pCheckBoxL:SetSelect( false );
		end
		local uiNode	= GetUiNode( pUIView, TAG_EQUIP_BUTTON );
		local pCheckBox = ConverToCheckBox( uiNode );
		pCheckBox:SetSelect( true );
		--local pBtnFocus	= GetButton( pUIView, TAG_EQUIP_BUTTON );
		--pBtnFocus:SetFocus(true);
		p.pItemViewChoosen = pUIView;
		local nItemID	= p.pItemViewChoosen:GetTag();
		p.FillRightZone( p.pLayerRightZone, nItemID );
	end
end

---------------------------------------------------
-- 显示箭头
function p.ShowArrow()
	local pScene = GetSMGameScene();
	if( pScene == nil ) then
		return;
	end
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.EvilMelt );
	if( not CheckP(pLayer) ) then
		return;
	end
	local container = GetScrollViewContainer( pLayer, ID_LIST_STORAGE_NAME );
    SetArrow( pLayer, container, 1, ID_PIC_LEFT_ARROW, ID_PIC_RIGHT_ARROW );
end


---------------------------------------------------
-- 填充右侧区域
function p.FillRightZone( pLayer, nItemID )
	if ( pLayer == nil ) then
		return;
	end
	if ( nItemID == nil ) then
		return;
	end
    local pItemButtonImage	= GetItemButton( pLayer, ID_BTN_ITEM_BUTTON );-- 装备图像按钮
    local pLabelItemName		= GetLabel( pLayer, ID_LABEL_ITEM_NAME );-- 装备名称
    local pLabelPro1Name		= GetLabel( pLayer, ID_LABEL_PROPERTY_1_NAME );-- 属性名
    local pLabelPro2Name		= GetLabel( pLayer, ID_LABEL_PROPERTY_2_NAME );
    local pLabelPro3Name		= GetLabel( pLayer, ID_LABEL_PROPERTY_3_NAME );
    local pLabelPro1Cur			= GetLabel( pLayer, ID_LABEL_PROPERTY_1_CURRENT );-- 属性当前值
    local pLabelPro2Cur			= GetLabel( pLayer, ID_LABEL_PROPERTY_2_CURRENT );
    local pLabelPro3Cur			= GetLabel( pLayer, ID_LABEL_PROPERTY_3_CURRENT );
    local pLabelPro1Aft			= GetLabel( pLayer, ID_LABEL_PROPERTY_1_AFTER );-- 属性魔化后数值
    local pLabelPro2Aft			= GetLabel( pLayer, ID_LABEL_PROPERTY_2_AFTER );
    local pLabelPro3Aft			= GetLabel( pLayer, ID_LABEL_PROPERTY_3_AFTER );
	local pLabelCrystalNeeded	= GetLabel( pLayer, ID_LABEL_CRYSTAL_NEEDED );-- 需要的魔晶量
	local pLabelSelverNeeded	= GetLabel( pLayer, ID_LABEL_SELVER_NEEDED );-- 需要的银币量
	local pBtnEvilMelt			= GetButton( pLayer, ID_BTN_EVIL_MELT );--魔化按钮

	pItemButtonImage:ChangeItem(0);
	pLabelItemName:SetText("");
	pLabelPro1Name:SetText("");
	pLabelPro2Name:SetText("");
	pLabelPro3Name:SetText("");
	pLabelPro1Cur:SetText("");
	pLabelPro2Cur:SetText("");
	pLabelPro3Cur:SetText("");
	pLabelPro1Aft:SetText("");
	pLabelPro2Aft:SetText("");
	pLabelPro3Aft:SetText("");
	pLabelCrystalNeeded:SetText("");
	pLabelSelverNeeded:SetText("");
	pBtnEvilMelt:SetVisible(false);
	
	if ( nItemID == 0 ) then
		return;
	end
--
	pItemButtonImage:ChangeItem(nItemID);
	local nItemType		= Item.GetItemInfoN( nItemID, Item.ITEM_TYPE );
	local szItemName	= ItemFunc.GetName(nItemType);
	--pLabelItemName:SetText( szItemName );
	local tBaseData		= p.GetEvilItemDBData( nItemType );
	if ( tBaseData == nil ) then
		LogInfo( "EvilMelt: FillRightZone tBaseData is nil" );
		return;
	end
	-- 属性名
	local szPro1Name	= ItemFunc.GetAttrTypeDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE1]);
	local szPro2Name	= ItemFunc.GetAttrTypeDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE2]);
	local szPro3Name	= ItemFunc.GetAttrTypeDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE3]);
	pLabelPro1Name:SetText(szPro1Name);
	pLabelPro2Name:SetText(szPro2Name);
	pLabelPro3Name:SetText(szPro3Name);
	local nEvilLevel	= Item.GetItemInfoN( nItemID, Item.ITEM_EVIL_LEVEL );--当前魔化等级
	pLabelItemName:SetText( szItemName.."("..GetTxtPub("MoHua") .. nEvilLevel .. GetTxtPub("Level")..")" );-- 名称(魔化等级)
	-- 属性当前值
	local nPro1Cur		= tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_VALUE1] + tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_GROW1] * nEvilLevel;
	local nPro2Cur		= tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_VALUE2] + tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_GROW2] * nEvilLevel;
	local nPro3Cur		= tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_VALUE3] + tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_GROW3] * nEvilLevel;
	local szPro1Cur		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE1], nPro1Cur);
	local szPro2Cur		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE2], nPro2Cur);
	local szPro3Cur		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE3], nPro3Cur);
	pLabelPro1Cur:SetText(szPro1Cur);
	pLabelPro2Cur:SetText(szPro2Cur);
	pLabelPro3Cur:SetText(szPro3Cur);
	if ( nEvilLevel < tBaseData[DB_ITEMTYPE_EVILMELT.MELT_LEVEL_MAX] ) then
		local nPro1Aft		= nPro1Cur + tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_GROW1];
		local nPro2Aft		= nPro2Cur + tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_GROW2];
		local nPro3Aft		= nPro3Cur + tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_GROW3];
		local szPro1Aft		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE1], nPro1Aft);
		local szPro2Aft		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE2], nPro2Aft);
		local szPro3Aft		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE3], nPro3Aft);
		pLabelPro1Aft:SetText(szPro1Aft);
		pLabelPro2Aft:SetText(szPro2Aft);
		pLabelPro3Aft:SetText(szPro3Aft);
		--
		local nNeededMoney	= tBaseData[DB_ITEMTYPE_EVILMELT.REQ_MONEY_BASE] + tBaseData[DB_ITEMTYPE_EVILMELT.REQ_MONEY_GROW]*(nEvilLevel+1);
		local szSilver		= GetTxtPub("coin")..nNeededMoney;--GetTxtPub("coin")..MoneyFormat( nNeededMoney );
		pLabelSelverNeeded:SetText(szSilver);
		local szItemName	= ItemFunc.GetName(tBaseData[DB_ITEMTYPE_EVILMELT.REQ_ITEMTYPE_ID]);
		local nItemNum		= tBaseData[DB_ITEMTYPE_EVILMELT.REQ_ITEMTYPE_BASE] + tBaseData[DB_ITEMTYPE_EVILMELT.REQ_ITEMTYPE_GROW]*(nEvilLevel+1);
		local szItem = szItemName..nItemNum;
		pLabelCrystalNeeded:SetText(szItem);
		pBtnEvilMelt:SetVisible(true);
		p.nNeededMoney		= nNeededMoney;
		p.nNeededItemType	= tBaseData[DB_ITEMTYPE_EVILMELT.REQ_ITEMTYPE_ID];
		p.nNeededItemNum	= nItemNum;
	else
		local nPro1Aft		= nPro1Cur;
		local nPro2Aft		= nPro2Cur;
		local nPro3Aft		= nPro3Cur;
		local szPro1Aft		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE1], nPro1Aft);
		local szPro2Aft		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE2], nPro2Aft);
		local szPro3Aft		= p.GetAttrTypeValueDesc(tBaseData[DB_ITEMTYPE_EVILMELT.EVIL_TYPE3], nPro3Aft);
		pLabelPro1Aft:SetText(szPro1Aft);
		pLabelPro2Aft:SetText(szPro2Aft);
		pLabelPro3Aft:SetText(szPro3Aft);
		--
	end
end


---------------------------------------------------
-- 魔化回调
function p.CallBack_EvilMelt()
	if IsUIShow( NMAINSCENECHILDTAG.EvilMelt ) then
		--
		if ( p.pItemViewChoosen ~= nil ) then
			local pLayer		= p.pItemViewChoosen;
			local nItemID		= pLayer:GetTag();
			local pLabelLevel	= GetLabel( pLayer, TAG_EQUIP_LEVEL );
			local nLevel		= Item.GetItemInfoN( nItemID, Item.ITEM_EVIL_LEVEL );
			local szLevel		= GetTxtPub("MoHua") .. nLevel .. GetTxtPub("Level");
			pLabelLevel:SetText(szLevel);
			p.FillRightZone( p.pLayerRightZone, nItemID );
		end
		CommonDlgNew.ShowTipDlg(GetTxtPub("MoHua").."+1");
		p.RefreshEvilCrystal();
	end
end


---------------------------------------------------
--刷新金钱
function p.RefreshMoney()
	--LogInfo("EvilMelt: RefreshMoney");
	local pScene = GetSMGameScene();
	if( pScene == nil ) then
		return;
	end
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.EvilMelt );
	if( not CheckP(pLayer) ) then
		return;
	end
	local nUserID		= GetPlayerId();
	local szSilver		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) );--MoneyFormat( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) );
	local szGold		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY ) );
	
	_G.SetLabel( pLayer, ID_LABEL_SELVER, szSilver);
	_G.SetLabel( pLayer, ID_LABEL_GOLD, szGold);
end
GameDataEvent.Register( GAMEDATAEVENT.USERATTR, "EvilMelt.RefreshMoney", p.RefreshMoney );

---------------------------------------------------
--刷新魔晶
function p.RefreshEvilCrystal()
	--LogInfo("EvilMelt: RefreshEvilCrystal");
	local pScene = GetSMGameScene();
	if( pScene == nil ) then
		return;
	end
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.EvilMelt );
	if( not CheckP(pLayer) ) then
		return;
	end
	local nEvilCrystalAmount	= Banquet.GetItemAmount(p.EVIL_CRYSTAL_ITEM_TYPE_ID);
	_G.SetLabel( pLayer, ID_LABEL_CRYSTAL, SafeN2S(nEvilCrystalAmount) );
end

---------------------------------------------------
--GameDataEvent.Register(GAMEDATAEVENT.ITEMINFO,"EquipUpgradeUI.RestartRefreshGemList",p.RestartRefreshGemList);
--GameDataEvent.Register(GLOBALEVENT.GE_ITEM_UPDATE,"EquipUpgradeUI.RestartRefreshGemList",p.RestartRefreshGemList);
--GameDataEvent.Register(GAMEDATAEVENT.ITEMATTR,"EquipUpgradeUI.RestartRefreshGemList",p.RestartRefreshGemList);
---------------------------------------------------
-- 获得某物品类型魔化基础数据
function p.GetEvilItemDBData( nItemType )
	if ( nItemType == nil or nItemType == 0 ) then
		return nil;
	end
	local tData = {};
	local nIndexLmt = DB_ITEMTYPE_EVILMELT.EVIL_GROW3;--索引数量--从0
	for index=0, nIndexLmt do
		tData[index] = GetDataBaseDataN( SZ_ITEMTYPE_EVILMELT, nItemType, index );
	end
	return tData;
end
-- 属性加成啊值转字符串
function p.GetAttrTypeValueDesc(nAttr, nValue)
    local szVal = ""
    nAttr = Num1(nAttr);
    if(nAttr == 1) then
        szVal = "+"..nValue;
    elseif(nAttr == 2) then
        szVal = "-"..nValue;
    elseif(nAttr == 3) then
        szVal = "+"..(nValue/10);
        szVal = val.."%";
    elseif(nAttr == 4) then
        szVal = "-"..(nValue/10);
        szVal = val.."%";
    end
	return szVal;
end
