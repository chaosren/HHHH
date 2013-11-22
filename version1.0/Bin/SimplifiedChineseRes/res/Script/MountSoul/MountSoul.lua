---------------------------------------------------
--描述: 兽魂
--时间: 2012.1.21
--作者: Guosen
---------------------------------------------------
-- 进入兽魂界面接口：		MountSoul.Entry()
---------------------------------------------------

MountSoul = {}
local p = MountSoul;

--当前属性：当前累积加成值
--下级属性：当前累积加成值+该等级能获得的加成值

---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 6;	-- X
local ID_LABEL_SELVER				= 243;	-- 银币值
local ID_LABEL_GOLD					= 242;	-- 金币值

local ID_BTN_TRAIN					= 5;	-- 普通培养按钮
local ID_BTN_GOLDTRAIN				= 46;	-- 金币培养按钮
local ID_BTN_INTRO					= 7;	-- 兽魂规则按钮

-- 用来显示三态用的按钮
local ID_CB_MOUNTSOUL1				= 47;	--    上
local ID_CB_MOUNTSOUL2				= 48;	--       右
local ID_CB_MOUNTSOUL3				= 49;	--    下
local ID_CB_MOUNTSOUL4				= 50;	--  左
-- 响应事件的按钮
local ID_BTN_MOUNTSOUL11			= 147;	--    上
local ID_BTN_MOUNTSOUL12			= 148;	--       右
local ID_BTN_MOUNTSOUL13			= 149;	--    下
local ID_BTN_MOUNTSOUL14			= 150;	--  左

local ID_LABEL_TRAIN_MOUNTSOUL		= 21;	-- 当前培养兽魂属性文本
local ID_LABEL_BONUSES				= 45;	-- 兽魂属性总加成文本

-- 4类兽魂经验条控件ID
local ID_EXP_MOUNTSOUL1				= 56;
local ID_EXP_MOUNTSOUL2				= 57;
local ID_EXP_MOUNTSOUL3				= 58;
local ID_EXP_MOUNTSOUL4				= 59;

-- 经验条背景
local ID_PIC_EXP_BG					= 55;

-- 4类兽魂培养进展弧图片控件
local ID_PIC_PRO_MOUNTSOUL1			= 51;
local ID_PIC_PRO_MOUNTSOUL2			= 52;
local ID_PIC_PRO_MOUNTSOUL3			= 53;
local ID_PIC_PRO_MOUNTSOUL4			= 54;

---------------------------------------------------
-- 金币培养选择界面控件
local ID_BTN_TRAIN_ADVANCED				= 22;	-- 高级培养选择按钮
local ID_BTN_TRAIN_PLATINIC				= 23;	-- 白金培养选择按钮
local ID_BTN_TRAIN_IMPERIAL				= 24;	-- 至尊培养选择按钮

local ID_LABEL_GOLD_ADVANCED			= 19;	-- 高级培养需要的金币标签
local ID_LABEL_GOLD_PLATINIC			= 20;	-- 白金培养需要的金币标签
local ID_LABEL_GOLD_IMPERIAL			= 21;	-- 至尊培养需要的金币标签
local ID_LABEL_SILVER					= 25;	-- 消耗银币标签

local ID_BTN_OK					= 503;	-- 确定
local ID_BTN_CANCEL				= 504;	-- 取消

local ID_EDIT_TRAIN_AMOUNT				= 501;	-- 培养次数输入框


---------------------------------------------------
local ID_LABEL_GODHORSEWHIP_AMOUNT			= 60;	-- 神马鞭数量
local ID_LABEL_MOUNTSOULPILL_A_AMOUNT		= 61;	-- 高级兽魂丹数量
local ID_LABEL_MOUNTSOULPILL_P_AMOUNT		= 62;	-- 白金兽魂丹数量
local ID_LABEL_MOUNTSOULPILL_I_AMOUNT		= 63;	-- 至尊兽魂丹数量

local GodHorsewhip_ITEM_TYPE			= 36000000;	-- 神马鞭 物品类型ID
local MountSoulPill_ADVANCED_ITEM_TYPE	= 36000001;	-- 高级兽魂丹 物品类型ID
local MountSoulPill_PLATINIC_ITEM_TYPE	= 36000002;	-- 白金兽魂丹 物品类型ID
local MountSoulPill_IMPERIAL_ITEM_TYPE	= 36000003;	-- 至尊兽魂丹 物品类型ID

---------------------------------------------------
local SZ_STRONG				= GetTxtPri("MS_T1");	-- "力量+"
local SZ_AGILE				= GetTxtPri("MS_T2");	-- "敏捷+"
local SZ_INTELLIGENCE		= GetTxtPri("MS_T3");	-- "智力+"
local SZ_LIFE				= GetTxtPri("MS_T4");	-- "生命+"
local SZ_IMMUNEDAMAGE		= GetTxtPri("MS_T5");	-- "免伤+"
local SZ_EXP				= GetTxtPri("MS_T17");	-- "经验+"
local SZ_NEEDED_EXP			= GetTxtPri("MS_T14");	-- 

local SZ_MOUNTSOUL1			= GetTxtPri("MS_T6");	-- "蛮力兽魂"
local SZ_MOUNTSOUL2			= GetTxtPri("MS_T7");	-- "狡诈兽魂"
local SZ_MOUNTSOUL3			= GetTxtPri("MS_T8");	-- "迅捷兽魂"
local SZ_MOUNTSOUL4			= GetTxtPri("MS_T9");	-- "坚韧兽魂"

local SZ_DATA_FILE			= "mount_soul_config";	-- 用到的数据文件--每行数据表示升级到该ID所示的等级需要的经验，金币需求等，
local tIDList				= GetDataBaseIdList( SZ_DATA_FILE );	-- 可升级的等级表
local N_LEVEL_LIMITED		= table.getn(tIDList);	-- 等级限制

local UI_ZORDER				= 5010;	--UILayerZOrder.ActivityLayer--盖在聊天按钮上的ZORDER

local N_DEFAULT_AMOUNT		= 1;					-- 缺省的培养次数

---------------------------------------------------
local tTagBtn = {
	ID_CB_MOUNTSOUL1,
	ID_CB_MOUNTSOUL2,
	ID_CB_MOUNTSOUL3,
	ID_CB_MOUNTSOUL4,
};
local tMountSoulBtnList = {
	ID_BTN_MOUNTSOUL11,
	ID_BTN_MOUNTSOUL12,
	ID_BTN_MOUNTSOUL13,
	ID_BTN_MOUNTSOUL14,
};
-- 兽魂名
local tSZName = {
	SZ_MOUNTSOUL1,
	SZ_MOUNTSOUL2,
	SZ_MOUNTSOUL3,
	SZ_MOUNTSOUL4,
};

local N_MS_AMOUNT			= table.getn(tSZName);	-- 兽魂种类总数

-- 经验条控件ID
local tExpCtrlID = {
	ID_EXP_MOUNTSOUL1,
	ID_EXP_MOUNTSOUL2,
	ID_EXP_MOUNTSOUL3,
	ID_EXP_MOUNTSOUL4,
};

-- 进展弧度图片控件ID
local tProPicID = {
	ID_PIC_PRO_MOUNTSOUL1,
	ID_PIC_PRO_MOUNTSOUL2,
	ID_PIC_PRO_MOUNTSOUL3,
	ID_PIC_PRO_MOUNTSOUL4,
};

-- 培养的各类型名
local tTrainTypeName = {
	GetTxtPri("MS_T19"),	-- 普通
	GetTxtPri("MS_T20"),	-- 高级
	GetTxtPri("MS_T21"),	-- 白金
	GetTxtPri("MS_T22"),	-- 至尊
};

-- 颜色
local tColorLabelField = {
	"<cFF4802%s/e",-- 力量--蛮力
	"<c0ABDEA%s/e",-- 智力--狡诈
	"<cDB1AFF%s/e",-- 敏捷--迅捷
	"<c50B70C%s/e",-- 生命--坚韧
};

--1、智力：蓝色 01,BD,EA
--2、力量：红色 FF,48,02
--3、敏捷：紫色 DB,1A,FF
--4、生命：绿色 50,B7,0C

---------------------------------------------------
--local tProperty				= -- 属性，
--{
--nCurrentLevel					= nil,	-- 当前兽魂等级-总
--nCurrentExp					= nil,	-- 当前经验
--nTotalExp						= nil,	--
--nTotalStr						= nil,	-- 力量加成-总
--nTotalAgi						= nil,	-- 敏捷加成-总
--nTotalIni						= nil,	-- 智力加成-总
--nTotalLife					= nil,	-- 生命加成-总
--nTotalImmuneDamage			= nil, 	-- 免伤加成-总
--
--nNSilver	= nil,	-- 普通培养需要的银币
--nAGold	= nil,	-- 高级培养需要的金币
--nPGold	= nil,	-- 白金培养需要的金币
--nIGold	= nil,	-- 至尊培养需要的金币
--}

---------------------------------------------------
p.pLayerMountSoulUI		= nil;	-- 
p.tProperty				= nil;	-- 属性
p.nChoosenMountSoul		= nil;	-- 选中的兽魂
p.nTranMode				= nil;	-- 训练的模式
p.nTranAmount			= nil;	-- 训练的次数
p.pColorLabel			= nil;	-- 

---------------------------------------------------
-- 进入--发数据给服务端
function p.Entry()
--	ShowLoadBar();--
	MsgMountSoul.SendMsgEntry();
end
function p.EntryTest()
	p.ShowMountSoulMainUI();
	local tProperty = {
		nCurrentLevel				= 1,	-- 当前兽魂等级-总
		nCurrentExp					= 82,	-- 当前经验
		nTotalExp					= 3,	--
		nTotalStr					= 4,	-- 力量加成-总
		nTotalAgi					= 5,	-- 敏捷加成-总
		nTotalIni					= 6,	-- 智力加成-总
		nTotalLife					= 7,	-- 生命加成-总
		nTotalImmuneDamage			= 8, 	-- 免伤加成-总
		nNSilver	= 9,	-- 普通培养需要的银币
		nAGold	= 10,	-- 高级培养需要的金币
		nPGold	= 11,	-- 白金培养需要的金币
		nIGold	= 12,	-- 至尊培养需要的金币
	};
	p.CallBack_Refresh( tProperty );
end



---------------------------------------------------
-- 检测玩家是否有某种道具
-- 参数：该道具的 ITEM_TYPE
function p.GetItemAmount( nItemType )
    local nCount = 0;
	local nUserID		= GetPlayerId();
	local tItemIDList	= ItemUser.GetBagItemList( nUserID );
	for i,v in ipairs( tItemIDList ) do
		local nItemTypeTmp	= Item.GetItemInfoN( v, Item.ITEM_TYPE );
		if( nItemTypeTmp == nItemType ) then
            nCount = Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
			break;
		end
	end
	return nCount;
end

---------------------------------------------------
-- 显示兽魂主界面
function p.ShowMountSoulMainUI()
	--LogInfo( "MountSoul: ShowMountSoulMainUI()" );
	p.pLayerMountSoulUI		= nil;	-- 
	p.tProperty				= nil;	-- 属性
	p.nTagPressedBtn		= nil;	-- 选中的兽魂按钮
	p.nTranMode				= nil;	-- 训练的模式
	p.nTranAmount			= nil;	-- 训练的次数
	p.pColorLabel			= nil;	-- 
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "MountSoul: ShowMountSoulMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "MountSoul: ShowMountSoulMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.MountSoul );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UI_ZORDER );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "MountSoul: ShowMountSoulMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MountSoul/MountSoul.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	
	-- 重设按钮ZOrder
	for i, v in ipairs(tTagBtn) do
    	local pMountSoulBtn = GetButton( layer, v );
		pMountSoulBtn:RemoveFromParent( false );
		layer:AddChildZ( pMountSoulBtn, 1 );
	end
	for i, v in ipairs(tMountSoulBtnList) do
    	local pMountSoulBtn = GetButton( layer, v );
		pMountSoulBtn:RemoveFromParent( false );
		layer:AddChildZ( pMountSoulBtn, 1 );
	end
	
	p.pLayerMountSoulUI = layer;
	p.SetMountSoulBtn();
	p.SetMountSoulExp();
	p.ShowProPic();
	p.ShowMountSoulPillAmount();--显示兽魂丹数量
	p.RefreshMoney();--显示银币与金币
	--
end

-- 关闭兽魂主界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.MountSoul, true );--p.pLayerMainUI:RemoveFromParent( true );
	end
	p.pLayerMountSoulUI		= nil;
	p.tProperty				= nil;
	p.nTagPressedBtn		= nil;
	p.nTranMode				= nil;
	p.nTranAmount			= nil;
	p.pColorLabel			= nil;
end

---------------------------------------------------
-- 兽魂主界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( ID_BTN_INTRO == tag ) then
			p.ShowIntro();
		elseif ( ID_BTN_TRAIN == tag ) then
			if ( p.tProperty ~= nil ) then
	LogInfo( "MountSoul: LevelLimit:%d, nCurrentLevel:%d", N_LEVEL_LIMITED, p.tProperty.nCurrentLevel );
				if ( p.tProperty.nCurrentLevel < N_LEVEL_LIMITED ) then
					local nDlgTag, pDlgLayer = CommonDlgNew.ShowInputDlg( p.tProperty.nNSilver .. GetTxtPri("MS_T15").."\n"..GetTxtPri("MS_T25"), p.CallBack_NormalTrainInputUI, nil, N_DEFAULT_AMOUNT, 2, GetTxtPri("MS_T18") );
					if ( pDlgLayer ~= nil ) then
						local pInputBox = ConverToEdit( GetUiNode( pDlgLayer, CommonDlgNew.InputNum ) );
						if ( pInputBox ~= nil ) then
							pInputBox:SetFlag( 1 );		-- 仅可输入数字
						end
					end
				else
					CommonDlgNew.ShowYesDlg( GetTxtPri("MS_T13"), nil, nil, 3 );
				end
			end
			--p.tProperty.nCurrentLevel = p.tProperty.nCurrentLevel + 1;
			--p.CallBack_Refresh( p.tProperty );
		elseif ( ID_BTN_GOLDTRAIN == tag ) then
			if ( p.tProperty ~= nil ) then
				if ( p.tProperty.nCurrentLevel < N_LEVEL_LIMITED ) then
					p.ShowSelectTrainMode();
				else
					CommonDlgNew.ShowYesDlg( GetTxtPri("MS_T13"), nil, nil, 3 );
				end
			end
		elseif ( tag == ID_BTN_MOUNTSOUL11 ) then
			p.ShowChoosenMountSoulInfor( 1 );
		elseif ( tag == ID_BTN_MOUNTSOUL12 ) then
			p.ShowChoosenMountSoulInfor( 2 );
		elseif ( tag == ID_BTN_MOUNTSOUL13 ) then
			p.ShowChoosenMountSoulInfor( 3 );
		elseif ( tag == ID_BTN_MOUNTSOUL14 ) then
			p.ShowChoosenMountSoulInfor( 4 );
		end
	end
	return true;
end

---------------------------------------------------
-- 显示选中的类型
function p.ShowChoosenMountSoulInfor( nCMSType )
	if ( p.tProperty == nil ) then
		return;
	end
	local nType = GetDataBaseDataN( SZ_DATA_FILE, p.tProperty.nCurrentLevel, DB_MOUNT_SOUL_CONFIG.TYPE );
	local nOffset = nType - nCMSType;
	if ( nOffset < 0 ) then
		nOffset = nOffset + N_MS_AMOUNT;
	end
	local nLevel = p.tProperty.nCurrentLevel - nOffset;
	--if ( nLevel <= 0 ) then
	--	return;
	--end
	local szInfor = tSZName[nCMSType] .. p.GetTipsInfor( nLevel );
	CommonDlgNew.ShowYesDlg( szInfor, nil, nil, nil );
end

-- 获取选中某兽魂提示信息
--function p.GetTipsInfor( nLevel )
--	if ( nLevel == nil ) then
--		return "";
--	end
--	local szInfor = "";
--	if ( nLevel <= 0 ) then
--		szInfor = szInfor .. " Lv:0\n";
--		szInfor = szInfor .. GetTxtPri("MS_T11");
--		szInfor = szInfor .. GetTxtPri("MS_T10") .. "\n";
--	else
--		local nMountSoulLevel	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.LEVEL );
--		szInfor = szInfor .. " Lv:" .. nMountSoulLevel .. "\n";
--		--当前属性
--		szInfor = szInfor .. GetTxtPri("MS_T11");
--		szInfor = szInfor .. p.GetPropertyString_Tips( nLevel );
--	end
--	--下级属性
--	local nNextLevel = nLevel + N_MS_AMOUNT;
--	if ( nNextLevel <= N_LEVEL_LIMITED ) then
--		szInfor = szInfor .. GetTxtPri("MS_T12");
--		szInfor = szInfor .. p.GetPropertyString_Tips( nNextLevel );
--		local nExp	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.REQ_EXP );
--		local nAcquiredExp = 0;
--		if ( nNextLevel == p.tProperty.nCurrentLevel+1 ) then
--			nAcquiredExp = p.tProperty.nCurrentExp;
--		end
--		szInfor = szInfor .. SZ_NEEDED_EXP .. nAcquiredExp .. "/" .. nExp;
--	else
--		szInfor = szInfor .. GetTxtPri("MS_T13");
--	end
--	return szInfor;
--end
function p.GetTipsInfor( nLevel )
	local szInfor = "";
	if ( nLevel == nil ) then
		return szInfor;
	end
	if ( nLevel <= 0 ) then
		szInfor = szInfor .. " Lv:0\n";
	else
		local nMountSoulLevel	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.LEVEL );
		szInfor = szInfor .. " Lv:" .. nMountSoulLevel .. "\n";
	end
	--当前属性
	szInfor = szInfor .. GetTxtPri("MS_T11");
	local nTrainLevel = nLevel;
	if ( nLevel <= 0 ) then
		nTrainLevel = nLevel  + N_MS_AMOUNT;--
	end
	local nStrPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.STR_MILLI );
	local nAgiPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.AGI_MILLI );
	local nIntPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.INI_MILLI );
	local nLifePlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.LIFE_MILLI );
	if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
		szInfor = szInfor .. SZ_STRONG .. p.tProperty.nTotalStr/10 .. "%\n";
	end
	if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
		szInfor = szInfor .. SZ_AGILE .. p.tProperty.nTotalAgi/10 .. "%\n";
	end
	if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
		szInfor = szInfor .. SZ_INTELLIGENCE .. p.tProperty.nTotalIni/10 .. "%\n";
	end
	if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
		szInfor = szInfor .. SZ_LIFE .. p.tProperty.nTotalLife/10 .. "%\n";
	end
	--下级属性
	local nNextLevel = nLevel + N_MS_AMOUNT;
	if ( nNextLevel <= N_LEVEL_LIMITED ) then
		szInfor = szInfor .. GetTxtPri("MS_T12");
		local nStrPlus	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.STR_MILLI );
		local nAgiPlus	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.AGI_MILLI );
		local nIntPlus	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.INI_MILLI );
		local nLifePlus	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.LIFE_MILLI );
		if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
			szInfor = szInfor .. SZ_STRONG .. (p.tProperty.nTotalStr+nStrPlus)/10 .. "%\n";
		end
		if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
			szInfor = szInfor .. SZ_AGILE .. (p.tProperty.nTotalAgi+nAgiPlus)/10 .. "%\n";
		end
		if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
			szInfor = szInfor .. SZ_INTELLIGENCE .. (p.tProperty.nTotalIni+nIntPlus)/10 .. "%\n";
		end
		if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
			szInfor = szInfor .. SZ_LIFE .. (p.tProperty.nTotalLife+nLifePlus)/10 .. "%\n";
		end
		local nExp	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.REQ_EXP );
		local nAcquiredExp = 0;
		if ( nNextLevel == p.tProperty.nCurrentLevel+1 ) then
			nAcquiredExp = p.tProperty.nCurrentExp;
		end
		szInfor = szInfor .. SZ_NEEDED_EXP .. nAcquiredExp .. "/" .. nExp;
	else
	end
	
	return szInfor;
end

-- 获取指定等级的加成属性信息字符串tips
--function p.GetPropertyString_Tips( nLevel )
--	local szProperty = "";
--	local nStrPlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.STR_MILLI );
--	local nAgiPlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.AGI_MILLI );
--	local nIntPlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.INI_MILLI );
--	local nLifePlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.LIFE_MILLI );
--	if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
--		szProperty = szProperty .. SZ_STRONG .. nStrPlus/10 .. "%\n";
--	end
--	if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
--		szProperty = szProperty .. SZ_AGILE .. nAgiPlus/10 .. "%\n";
--	end
--	if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
--		szProperty = szProperty .. SZ_INTELLIGENCE .. nIntPlus/10 .. "%\n";
--	end
--	if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
--		szProperty = szProperty .. SZ_LIFE .. nLifePlus/10 .. "%\n";
--	end
--	return szProperty;
--end

---------------------------------------------------
-- 普通培养次数输入界面回调
function p.CallBack_NormalTrainInputUI( eventType, param, val )
	if ( eventType == CommonDlgNew.BtnOk ) then
		if ( ( val == nil ) or ( val == "" ) ) then
			return;
		end
		local nAmount = SafeS2N( val );
		if ( nAmount <= 0 ) then
			return;
		end
		local nWhipAmount	= Banquet.GetItemAmount( GodHorsewhip_ITEM_TYPE );--神马鞭
		local nPlayerSilver	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_MONEY );
		local nNeededSilver = p.tProperty.nNSilver * nAmount;
		if ( (nPlayerSilver+p.tProperty.nNSilver*nWhipAmount) < nNeededSilver ) then
			CommonDlgNew.ShowYesDlg( GetTxtPri("Common_TongQianBuZhu"), nil, nil, 3 );
		else
			MsgMountSoul.SendMsgCultivate( MSTM.Normal, nAmount );
		end
	end
end

---------------------------------------------------
-- 刷新界面回调
function p.CallBack_Refresh( tProperty )
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	p.tProperty	= tProperty;
	p.tProperty.nNSilver	= 0;
	p.tProperty.nAGold		= 0;
	p.tProperty.nPGold		= 0;
	p.tProperty.nIGold		= 0;
	
	local nNextLevel = p.tProperty.nCurrentLevel + 1;
	if ( nNextLevel <= N_LEVEL_LIMITED ) then
		local nNSilver	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.NORMAL_TRAIN_MONEY );
		local nAGold	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.ADVANCED_TRAIN_EMONEY );
		local nPGold	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.GOLD_TRAIN_EMONEY );
		local nIGold	= GetDataBaseDataN( SZ_DATA_FILE, nNextLevel, DB_MOUNT_SOUL_CONFIG.EXTREME_TRAIN_EMONEY );
		p.tProperty.nNSilver	= nNSilver;
		p.tProperty.nAGold		= nAGold;
		p.tProperty.nPGold		= nPGold;
		p.tProperty.nIGold		= nIGold;
	end
	
	p.SetMountSoulBtn();
	p.SetMountSoulExp();
	p.ShowProPic();
	--p.SetCurrentMountSoulInformation();
	p.ShowCurrentMountSoulInformation();--
	p.ShowTotalInformation();
end


---------------------------------------------------
-- 设置高亮兽魂(当前培养的兽魂)
function p.SetMountSoulBtn()
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	for i, v in ipairs(tTagBtn) do
    	local pMountSoulBtn = GetButton( p.pLayerMountSoulUI, v );
		pMountSoulBtn:TabSel( false );
	end
	
	if ( p.tProperty == nil ) then
		return;
	end
	local nTrainLevel = p.tProperty.nCurrentLevel + 1;--
	if ( nTrainLevel > N_LEVEL_LIMITED ) then
		return;
	end
	local nType = GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.TYPE );
	if ( nType == nil ) then
		return;
	end
	local nTag = tTagBtn[nType];
	local pMountSoulBtn = GetButton( p.pLayerMountSoulUI, nTag );
	pMountSoulBtn:TabSel( true );
end


---------------------------------------------------
-- 设置经验条显示
function p.SetMountSoulExp()
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	for i, v in ipairs(tExpCtrlID) do
    	local pMountSoulExp = RecursivUIExp( p.pLayerMountSoulUI, {v} );
		pMountSoulExp:SetVisible( false );
	end
	
	if ( p.tProperty == nil ) then
		return;
	end
	local nTrainLevel = p.tProperty.nCurrentLevel + 1;--
	if ( nTrainLevel > N_LEVEL_LIMITED ) then
		local pPic = GetImage( p.pLayerMountSoulUI, ID_PIC_EXP_BG );--满级后经验条背景也不显示
		pPic:SetVisible( false );
		return;
	end
	local nType = GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.TYPE );
	if ( nType == nil ) then
		return;
	end
	local nTag = tExpCtrlID[nType];
    local pMountSoulExp	= RecursivUIExp( p.pLayerMountSoulUI, {nTag} );
	local nNeedExp		= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.REQ_EXP );
	pMountSoulExp:SetVisible( true );
	pMountSoulExp:SetProcess(p.tProperty.nCurrentExp);
	pMountSoulExp:SetTotal(nNeedExp);
	--pMountSoulExp:SetStyle(2);
	
end

---------------------------------------------------
-- 显示培养进展弧度图片--当前的兽魂类型，并非当前培养的兽魂类型
function p.ShowProPic( bUpdate )
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	for i, v in ipairs(tProPicID) do
		local pMountSoulProPic = GetImage( p.pLayerMountSoulUI, v );
		pMountSoulProPic:SetVisible( false );
	end
	if ( p.tProperty == nil ) then
		return;
	end
	local nLevel = p.tProperty.nCurrentLevel;
	if ( nLevel <= 0 ) then
		return;
	end
	if ( p.tProperty.nCurrentLevel >= N_LEVEL_LIMITED ) then--满级全显示
		for i, v in ipairs(tProPicID) do
			local pMountSoulProPic = GetImage( p.pLayerMountSoulUI, v );
			pMountSoulProPic:SetVisible( true );
		end
		return;
	end
	local nType = GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.TYPE );
	if ( nType == nil ) then
		return;
	end
	
	for i = 1, nType do
		local pMountSoulProPic = GetImage( p.pLayerMountSoulUI, tProPicID[i] );
		pMountSoulProPic:SetVisible( true );
	end
	
	-- 是否当前升级情况
	if ( bUpdate == true ) then
		if ( nType == N_MS_AMOUNT ) then
			RegisterTimer( p.OnTimer_HideProPic, 3 );
		end
	else
		if ( nType == N_MS_AMOUNT ) then
			for i, v in ipairs(tProPicID) do
				local pMountSoulProPic = GetImage( p.pLayerMountSoulUI, v );
				pMountSoulProPic:SetVisible( false );
			end
		end
	end
end

-- 延时隐藏进展圆弧图片
function p.OnTimer_HideProPic( nTimerID )
	LogInfo("MountSoul: OnTimer_HideProPic");
	UnRegisterTimer( nTimerID );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		return false;
	end
	
	local layer = GetUiLayer( scene, NMAINSCENECHILDTAG.MountSoul );
	if not CheckP(layer) then
		return false;
	end
	for i, v in ipairs(tProPicID) do
		local pMountSoulProPic = GetImage( p.pLayerMountSoulUI, v );
		pMountSoulProPic:SetVisible( false );
	end
end

---------------------------------------------------
-- 设置当前培养的兽魂的信息的文本标签
function p.SetCurrentMountSoulInformation()
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	local pLabelInfo = GetLabel( p.pLayerMountSoulUI, ID_LABEL_TRAIN_MOUNTSOUL );
	
	if ( p.tProperty == nil or p.tProperty.nCurrentLevel == nil ) then
		pLabelInfo:SetText( GetTxtPri("MS_T10") );
		return;
	end
	local szInfor = p.GetMountSoulInformation();
	pLabelInfo:SetText( szInfor );
end

-- 获得指定兽魂的信息
function p.GetMountSoulInformation()
	local nTrainLevel = p.tProperty.nCurrentLevel + 1;--将要培养的等级--总的等级
	if ( nTrainLevel > N_LEVEL_LIMITED ) then
		return GetTxtPri("MS_T13");
	end
	local szInfor = "";
	local nType = GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.TYPE );
	szInfor = szInfor .. tSZName[nType];
	local nMountSoulLevel	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.LEVEL );--当前培养中的兽魂的正在的培养等级
	szInfor = szInfor .. " Lv:" .. nMountSoulLevel-1 .. "\n";--当前培养中的兽魂的当前等级

	--当前培养的兽魂未累加属性
	szInfor = szInfor .. GetTxtPri("MS_T11") .. "\n";
	local nStrPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.STR_MILLI );
	local nAgiPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.AGI_MILLI );
	local nIntPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.INI_MILLI );
	local nLifePlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.LIFE_MILLI );
	if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
		szInfor = szInfor .. SZ_STRONG .. p.tProperty.nTotalStr/10 .. "%\n";
	end
	if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
		szInfor = szInfor .. SZ_AGILE .. p.tProperty.nTotalAgi/10 .. "%\n";
	end
	if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
		szInfor = szInfor .. SZ_INTELLIGENCE .. p.tProperty.nTotalIni/10 .. "%\n";
	end
	if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
		szInfor = szInfor .. SZ_LIFE .. p.tProperty.nTotalLife/10 .. "%\n";
	end
	
	--当前培养的兽魂累加属性
	local nNextLevel = nTrainLevel + N_MS_AMOUNT;
	if ( nNextLevel <= N_LEVEL_LIMITED ) then
		szInfor = szInfor .. GetTxtPri("MS_T12") .. "\n";
		if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
			szInfor = szInfor .. SZ_STRONG .. (p.tProperty.nTotalStr+nStrPlus)/10 .. "%\n";
		end
		if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
			szInfor = szInfor .. SZ_AGILE .. (p.tProperty.nTotalAgi+nAgiPlus)/10 .. "%\n";
		end
		if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
			szInfor = szInfor .. SZ_INTELLIGENCE .. (p.tProperty.nTotalIni+nIntPlus)/10 .. "%\n";
		end
		if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
			szInfor = szInfor .. SZ_LIFE .. (p.tProperty.nTotalLife+nLifePlus)/10 .. "%\n";
		end
	end
	
	return szInfor;
end

-- 获取指定等级的加成属性信息字符串
--function p.GetPropertyString( nLevel )
--	local szProperty = "";
--	local nStrPlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.STR_MILLI );
--	local nAgiPlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.AGI_MILLI );
--	local nIntPlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.INI_MILLI );
--	local nLifePlus	= GetDataBaseDataN( SZ_DATA_FILE, nLevel, DB_MOUNT_SOUL_CONFIG.LIFE_MILLI );
--	if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
--		szProperty = szProperty .. SZ_STRONG .. nStrPlus/10 .. "%\n";
--	end
--	if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
--		szProperty = szProperty .. SZ_AGILE .. nAgiPlus/10 .. "%\n";
--	end
--	if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
--		szProperty = szProperty .. SZ_INTELLIGENCE .. nIntPlus/10 .. "%\n";
--	end
--	if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
--		szProperty = szProperty .. SZ_LIFE .. nLifePlus/10 .. "%\n";
--	end
--	return szProperty;
--end


---------------------------------------------------
-- 多颜色
function p.ShowCurrentMountSoulInformation()
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	if ( p.pColorLabel ~= nil ) then
		p.pColorLabel:RemoveFromParent( true );
		p.pColorLabel = nil;
	end
	local pLabelInfo = GetLabel( p.pLayerMountSoulUI, ID_LABEL_TRAIN_MOUNTSOUL );
	local szInfor = ""
	if ( p.tProperty == nil or p.tProperty.nCurrentLevel == nil ) then
		szInfor = GetTxtPri("MS_T10");
	else
		szInfor = p.GetColorMountSoulInforString();
	end
	
    local nFontSize		= 14;
    local tRect 		= pLabelInfo:GetFrameRect();
    local nWidthLimit	= tRect.size.w;
    --local tTextSize		= _G.GetHyperLinkTextSize( szInfor, nFontSize, nWidthLimit );
	p.pColorLabel	= _G.CreateColorLabel( szInfor, nFontSize, nWidthLimit );
	p.pColorLabel:SetFrameRect( tRect );
	p.pLayerMountSoulUI:AddChild( p.pColorLabel );
end

-- 多颜色
function p.GetColorMountSoulInforString()
	local nTrainLevel = p.tProperty.nCurrentLevel + 1;--将要培养的等级--总的等级
	if ( nTrainLevel > N_LEVEL_LIMITED ) then
		return GetTxtPri("MS_T13");
	end
	local szInfor = "";
	local nType = GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.TYPE );
	szInfor = szInfor .. tSZName[nType];
	local nMountSoulLevel	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.LEVEL );--当前培养中的兽魂的正在的培养等级
	szInfor = szInfor .. " Lv:" .. nMountSoulLevel-1 .. "\n";--当前培养中的兽魂的当前等级
	--szInfor = string.format( tColorLabelField[nType], szInfor );

	--当前培养的兽魂未累加属性
	--szInfor = szInfor .. GetTxtPri("MS_T11") .. "\n";
	szInfor = szInfor .. string.format( tColorLabelField[nType], GetTxtPri("MS_T11") .. "\n" );
	local nStrPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.STR_MILLI );
	local nAgiPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.AGI_MILLI );
	local nIntPlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.INI_MILLI );
	local nLifePlus	= GetDataBaseDataN( SZ_DATA_FILE, nTrainLevel, DB_MOUNT_SOUL_CONFIG.LIFE_MILLI );
	if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
		szInfor = szInfor .. SZ_STRONG .. p.tProperty.nTotalStr/10 .. "%\n";
		--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_STRONG .. p.tProperty.nTotalStr/10 .. "%\n" );
	end
	if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
		szInfor = szInfor .. SZ_AGILE .. p.tProperty.nTotalAgi/10 .. "%\n";
		--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_AGILE .. p.tProperty.nTotalAgi/10 .. "%\n" );
	end
	if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
		szInfor = szInfor .. SZ_INTELLIGENCE .. p.tProperty.nTotalIni/10 .. "%\n";
		--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_INTELLIGENCE .. p.tProperty.nTotalIni/10 .. "%\n" );
	end
	if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
		szInfor = szInfor .. SZ_LIFE .. p.tProperty.nTotalLife/10 .. "%\n";
		--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_LIFE .. p.tProperty.nTotalLife/10 .. "%\n" );
	end
	
	--当前培养的兽魂累加属性
	if ( nTrainLevel <= N_LEVEL_LIMITED ) then
		--szInfor = szInfor .. GetTxtPri("MS_T12") .. "\n";
		szInfor = szInfor .. string.format( tColorLabelField[nType], GetTxtPri("MS_T12") .. "\n" );
		if ( ( nStrPlus ~= nil ) and ( nStrPlus > 0 ) ) then
			szInfor = szInfor .. SZ_STRONG .. (p.tProperty.nTotalStr+nStrPlus)/10 .. "%\n";
			--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_STRONG .. (p.tProperty.nTotalStr+nStrPlus)/10 .. "%\n" );
		end
		if ( ( nAgiPlus ~= nil ) and ( nAgiPlus > 0 ) ) then
			szInfor = szInfor .. SZ_AGILE .. (p.tProperty.nTotalAgi+nAgiPlus)/10 .. "%\n";
			--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_AGILE .. (p.tProperty.nTotalAgi+nAgiPlus)/10 .. "%\n" );
		end
		if ( ( nIntPlus ~= nil ) and ( nIntPlus > 0 ) ) then
			szInfor = szInfor .. SZ_INTELLIGENCE .. (p.tProperty.nTotalIni+nIntPlus)/10 .. "%\n";
			--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_INTELLIGENCE .. (p.tProperty.nTotalIni+nIntPlus)/10 .. "%\n" );
		end
		if ( ( nLifePlus ~= nil ) and ( nLifePlus > 0 ) ) then
			szInfor = szInfor .. SZ_LIFE .. (p.tProperty.nTotalLife+nLifePlus)/10 .. "%\n";
			--szInfor = szInfor .. string.format( tColorLabelField[nType], SZ_LIFE .. (p.tProperty.nTotalLife+nLifePlus)/10 .. "%\n" );
		end
	end
	
	return szInfor;
end


---------------------------------------------------
-- 设置总加成属性文本标签
function p.ShowTotalInformation()
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	local pLabelInfo = GetLabel( p.pLayerMountSoulUI, ID_LABEL_BONUSES );
	local szInfor = "";
	if ( p.tProperty == nil ) then
		return GetTxtPri("MS_T10");
	end
	if ( ( p.tProperty.nTotalStr ~= nil ) and ( p.tProperty.nTotalStr >= 0 ) ) then
		szInfor = szInfor .. SZ_STRONG .. p.tProperty.nTotalStr/10 .. "%\n";
	end
	if ( ( p.tProperty.nTotalAgi ~= nil ) and ( p.tProperty.nTotalAgi >= 0 ) ) then
		szInfor = szInfor .. SZ_AGILE .. p.tProperty.nTotalAgi/10 .. "%\n";
	end
	if ( ( p.tProperty.nTotalIni ~= nil ) and ( p.tProperty.nTotalIni >= 0 ) ) then
		szInfor = szInfor .. SZ_INTELLIGENCE .. p.tProperty.nTotalIni/10 .. "%\n";
	end
	if ( ( p.tProperty.nTotalLife ~= nil ) and ( p.tProperty.nTotalLife >= 0 ) ) then
		szInfor = szInfor .. SZ_LIFE .. p.tProperty.nTotalLife/10 .. "%\n";
	end
	if ( ( p.tProperty.nTotalImmuneDamage ~= nil ) and ( p.tProperty.nTotalImmuneDamage >= 0 ) ) then
		szInfor = szInfor .. SZ_IMMUNEDAMAGE .. p.tProperty.nTotalImmuneDamage/10 .. "%\n";
	end
	pLabelInfo:SetText( szInfor );
end


---------------------------------------------------


---------------------------------------------------
--刷新金钱
function p.RefreshMoney()
	--LogInfo("MountSoul: RefreshMoney");
    local pScene = GetSMGameScene();
    if( pScene == nil ) then
        return;
    end
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.MountSoul );
    if( pLayer == nil ) then
        return;
    end
    local nUserID		= GetPlayerId();
    local szSilver		= MoneyFormat( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) );
    local szGold		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY ) );
    
    _G.SetLabel( pLayer, ID_LABEL_SELVER, szSilver);
    _G.SetLabel( pLayer, ID_LABEL_GOLD, szGold);
end
GameDataEvent.Register( GAMEDATAEVENT.USERATTR, "MountSoul.RefreshMoney", p.RefreshMoney );


---------------------------------------------------
-- 显示 选择培养模式 界面
function p.ShowSelectTrainMode()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "MountSoul: ShowSelectTrainMode failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "MountSoul: ShowSelectTrainMode failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.MountSoul );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UI_ZORDER );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "MountSoul: ShowSelectTrainMode failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MountSoul/MountSoul_M.ini", layer, p.OnUIEventSelectTrainType, 0, 0 );
	uiLoad:Free();
	-- 选择按钮
	local pBtnA	= ConverToCheckBox( GetUiNode( layer, ID_BTN_TRAIN_ADVANCED ) );
	local pBtnP	= ConverToCheckBox( GetUiNode( layer, ID_BTN_TRAIN_PLATINIC ) );
	local pBtnI	= ConverToCheckBox( GetUiNode( layer, ID_BTN_TRAIN_IMPERIAL ) );
	pBtnA:SetSelect( true );
	pBtnP:SetSelect( false );
	pBtnI:SetSelect( false );
	p.nTranMode	= MSTM.Advanced;
	-- 金币
	p.ShowNeededGold( layer );
	-- 输入框
	p.nTranAmount	= N_DEFAULT_AMOUNT;
	local pEditCtrl	= ConverToEdit( GetUiNode( layer, ID_EDIT_TRAIN_AMOUNT ) );
	pEditCtrl:SetFlag( 1 );		-- 仅可输入数字
	pEditCtrl:SetMaxLength( 2 );	-- 最多可输入两个字(99)
	pEditCtrl:SetTextColor( ccc4(0xFF,0xd7,0x0,255) );		--
	pEditCtrl:SetText( SafeN2S( p.nTranAmount ) );
end

---------------------------------------------------
-- 显示培养所需的金币(到下一级)
function p.ShowNeededGold( pLayer )
	if ( pLayer == nil ) then
		return;
	end
	if ( p.tProperty == nil ) then
		return;
	end
	if ( p.tProperty.nCurrentLevel == nil ) then
		return;
	end
	
	local pLabelSilver	= GetLabel( pLayer, ID_LABEL_SILVER );
	local pLabelAG		= GetLabel( pLayer, ID_LABEL_GOLD_ADVANCED );
	local pLabelPG		= GetLabel( pLayer, ID_LABEL_GOLD_PLATINIC );
	local pLabelIG		= GetLabel( pLayer, ID_LABEL_GOLD_IMPERIAL );
	pLabelSilver:SetText( p.tProperty.nNSilver .. GetTxtPri("MS_T15") );
	pLabelAG:SetText( p.tProperty.nAGold .. GetTxtPri("MS_T16") );
	pLabelPG:SetText( p.tProperty.nPGold .. GetTxtPri("MS_T16") );
	pLabelIG:SetText( p.tProperty.nIGold .. GetTxtPri("MS_T16") );
end

---------------------------------------------------
-- 选择培养模式界面的事件响应
function p.OnUIEventSelectTrainType( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local pLayer = uiNode:GetParent();
	local pBtnA	= ConverToCheckBox( GetUiNode( pLayer, ID_BTN_TRAIN_ADVANCED ) );
	local pBtnP	= ConverToCheckBox( GetUiNode( pLayer, ID_BTN_TRAIN_PLATINIC ) );
	local pBtnI	= ConverToCheckBox( GetUiNode( pLayer, ID_BTN_TRAIN_IMPERIAL ) );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CANCEL == tag ) then
			p.nTranMode		= nil;
			p.nTranAmount	= nil;
			uiNode:GetParent():RemoveFromParent( true );
		elseif ( ID_BTN_OK == tag ) then
			if ( p.nTranAmount <= 0 ) then
			else
				local nWhipAmount	= 0;	--
				local nAPillAmount	= 0;	--
				local nPPillAmount	= 0;	--
				local nIPillAmount	= 0;	--
				local nPlayerId		= ConvertN(GetPlayerId());
				local tItemIDList	= ItemUser.GetBagItemList(nPlayerId);
				for i, v in ipairs(tItemIDList) do
					local nItemType	= Item.GetItemInfoN( v, Item.ITEM_TYPE );
					if ( nItemType == GodHorsewhip_ITEM_TYPE ) then
						nWhipAmount = nWhipAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
					end
					if ( nItemType == MountSoulPill_ADVANCED_ITEM_TYPE ) then
						nAPillAmount = nAPillAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
    			    end
					if ( nItemType == MountSoulPill_PLATINIC_ITEM_TYPE ) then
						nPPillAmount = nPPillAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
    			    end
					if ( nItemType == MountSoulPill_IMPERIAL_ITEM_TYPE ) then
						nIPillAmount = nIPillAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
    			    end
				end
				local nPlayerSilver	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_MONEY );
				local nGoldTranAmount	= 0; -- 消耗金币银币培养的次数
				if ( p.nTranMode == MSTM.Advanced ) then
					nGoldTranAmount	= p.nTranAmount - nAPillAmount;
				elseif ( p.nTranMode == MSTM.Platinic ) then
					nGoldTranAmount	= p.nTranAmount - nPPillAmount;
				elseif ( p.nTranMode == MSTM.Imperial ) then
					nGoldTranAmount	= p.nTranAmount - nIPillAmount;
				end
				if ( nGoldTranAmount < 0 ) then
					nGoldTranAmount = 0;
				end
				local nNeededSilver = p.tProperty.nNSilver * nGoldTranAmount;
				if ( nPlayerSilver < nNeededSilver ) then
					CommonDlgNew.ShowYesDlg( GetTxtPri("Common_TongQianBuZhu"), nil, nil, 3 );
				else
					local nPlayerGold	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_EMONEY );
					local nNeededGold	= 0;
					if ( p.nTranMode == MSTM.Advanced ) then
						nNeededGold	= p.tProperty.nAGold * nGoldTranAmount;
					elseif ( p.nTranMode == MSTM.Platinic ) then
						nNeededGold	= p.tProperty.nPGold * nGoldTranAmount;
					elseif ( p.nTranMode == MSTM.Imperial ) then
						nNeededGold	= p.tProperty.nIGold * nGoldTranAmount;
					end
					if ( nPlayerGold < nNeededGold ) then
						CommonDlgNew.ShowYesDlg( GetTxtPri("Common_JinBiBuZhu"), nil, nil, 3 );
					else
						MsgMountSoul.SendMsgCultivate( p.nTranMode, p.nTranAmount );
					end
				end
			end
			p.nTranMode		= nil;
			p.nTranAmount	= nil;
			uiNode:GetParent():RemoveFromParent( true );
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( tag == ID_BTN_TRAIN_ADVANCED ) then
			pBtnA:SetSelect( true );
			pBtnP:SetSelect( false );
			pBtnI:SetSelect( false );
			p.nTranMode	= MSTM.Advanced;
		elseif ( tag == ID_BTN_TRAIN_PLATINIC ) then
			pBtnA:SetSelect( false );
			pBtnP:SetSelect( true );
			pBtnI:SetSelect( false );
			p.nTranMode	= MSTM.Platinic;
		elseif ( tag == ID_BTN_TRAIN_IMPERIAL ) then
			pBtnA:SetSelect( false );
			pBtnP:SetSelect( false );
			pBtnI:SetSelect( true );
			p.nTranMode	= MSTM.Imperial;
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH ) then
    	local pEditCtrl = ConverToEdit(uiNode);
    	if CheckP(pEditCtrl) then
			if ( tag == ID_EDIT_TRAIN_AMOUNT ) then
				local nInputNumber = SafeS2N( pEditCtrl:GetText() );
				p.nTranAmount = nInputNumber;
			end
		end
	end
	return true;
end




---------------------------------------------------
-- 弹出显示增加的属性文字提示
function p.ShowIncProperty( tProperty )--倒序显示……
    if ( tProperty == nil ) then
    	return;
    end

    local tInfor = {};
	if ( ( tProperty.nImmuneDamage ~= nil ) and ( tProperty.nImmuneDamage > 0 ) ) then
        table.insert( tInfor, { SZ_IMMUNEDAMAGE .. tProperty.nImmuneDamage/10 .. "%\n", FontColor.Text } );
    end
	if ( ( tProperty.nLife ~= nil ) and ( tProperty.nLife > 0 ) ) then
        table.insert( tInfor, { SZ_LIFE .. tProperty.nLife/10 .. "%\n", FontColor.Text } );
    end
	if ( ( tProperty.nIni ~= nil ) and ( tProperty.nIni > 0 ) ) then
        table.insert( tInfor, { SZ_INTELLIGENCE .. tProperty.nIni/10 .. "%\n", FontColor.Text } );
    end
	if ( ( tProperty.nAgi ~= nil ) and ( tProperty.nAgi > 0 ) ) then
        table.insert( tInfor, { SZ_AGILE .. tProperty.nAgi/10 .. "%\n", FontColor.Text } );
    end
	if ( ( tProperty.nStr ~= nil ) and ( tProperty.nStr > 0 ) ) then
        table.insert( tInfor, { SZ_STRONG .. tProperty.nStr/10 .. "%\n", FontColor.Text } );
    end
    
	if ( ( tProperty.nExp ~= nil ) and ( tProperty.nExp > 0 ) ) then
        table.insert( tInfor, { SZ_EXP .. tProperty.nExp .. "\n", FontColor.Text } );
    end
    local szType = "";
	if ( ( tProperty.nType ~= nil ) and ( tProperty.nType >= 0 ) ) then
        szType = tTrainTypeName[tProperty.nType];
    end
	if ( ( tProperty.nCount ~= nil ) and ( tProperty.nCount >= 0 ) ) then
        szType = szType .. tProperty.nCount .. GetTxtPri("MS_T23") .. " ";
    end
	if ( ( tProperty.nCritNum ~= nil ) and ( tProperty.nCritNum > 0 ) ) then
        szType = szType .. GetTxtPri("MS_T24") .. tProperty.nCritNum .. GetTxtPri("MS_T23") .. " ";
    end
    if ( szTypeExp ~= "" ) then
        table.insert( tInfor, { szType, FontColor.Text } );
    end
    
    CommonDlgNew.ShowTipsDlg( tInfor );
    
	if ( ( tProperty.nLevel ~= nil ) and ( tProperty.nLevel > 0 ) ) then
		-- 有升级
		LogInfo( "MountSoul: nIncLevel:%d",tProperty.nLevel );
		p.ShowProPic( true );
	end
end


----------------



--===============================xxxxxxxx====================================----

local TipTxt ={
	GetTxtPri("MS_I01"),
	GetTxtPri("MS_I02"),
	GetTxtPri("MS_I03"),
	GetTxtPri("MS_I04"),
	GetTxtPri("MS_I05"),
	GetTxtPri("MS_I06"),
	GetTxtPri("MS_I07"),
	GetTxtPri("MS_I08"),
	GetTxtPri("MS_I09"),
	GetTxtPri("MS_I10"),
	GetTxtPri("MS_I11"),
	GetTxtPri("MS_I12"),
	GetTxtPri("MS_I13"),
	GetTxtPri("MS_I14"),
	GetTxtPri("MS_I15"),
	GetTxtPri("MS_I16"),
	GetTxtPri("MS_I17"),
};


--local Tiptag = 9998;
--显示提示信息
function p.ShowIntro()

  	local bglayer = GetSMGameScene();
    
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	--layer:SetTag(Tiptag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChildZ(layer,UI_ZORDER+2);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("MountSoul/MountSoul_Intro.ini", layer, p.OnUIEventIntro, 0, 0);

	
	
	----------------------------容器---------------------------------------
	local winsize	= GetWinSize();
	local rectX		= winsize.w*0.25;
	local rectW		= winsize.w*0.5;
	local rect		= CGRectMake(rectX, winsize.h*0.15, rectW, winsize.h*0.75); 
	

	tipcontainer = createUIScrollViewContainer();
	if tipcontainer == nil then
		LogInfo("tipcontainer == nil,load ui failed!");
		return;
	end
	tipcontainer:Init();
	tipcontainer:SetFrameRect(rect);
	layer:AddChild(tipcontainer);
	
	local rectview = tipcontainer:GetFrameRect();
	tipcontainer:SetStyle(UIScrollStyle.Verical);
	tipcontainer:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 10));
	tipcontainer:EnableScrollBar(true);
	
	
	local rectview		= tipcontainer:GetFrameRect();
	local nWidthLimit = rectview.size.w;
	
	for nIndex=1,#TipTxt do
	
		local view = createUIScrollView();

		if view ~= nil then
			view:Init(false);
			view:SetViewId(nIndex);
		
			tipcontainer:AddView(view);
			local sizeview		= view:GetFrameRect().size;
			local str = "";
			local pLabelTips = nil;
			local pLabelScore = nil;
			
			
		  	pLabelTips = _G.CreateColorLabel( TipTxt[nIndex], 11, nWidthLimit );
			pLabelTips:SetFrameRect(CGRectMake(0, 0, nWidthLimit, 20 * ScaleFactor));
			view:AddChild(pLabelTips);

		end
	end	
end


function p.OnUIEventIntro(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    	if 533 == tag then
    		local layer = uiNode:GetParent();          	
			layer:RemoveFromParent( true );
			return true;
    	end
	end
end


---------------------------------------------------
-- 显示各类兽魂丹数量
function p.ShowMountSoulPillAmount()
	if ( p.pLayerMountSoulUI == nil ) then
		return;
	end
	
	--local nWhipName		= ItemFunc.GetName( GodHorsewhip_ITEM_TYPE );	--
	--local szAPillName	= ItemFunc.GetName( MountSoulPill_ADVANCED_ITEM_TYPE );	--
	--local szPPillName	= ItemFunc.GetName( MountSoulPill_PLATINIC_ITEM_TYPE );	--
	--local szIPillName	= ItemFunc.GetName( MountSoulPill_IMPERIAL_ITEM_TYPE );	--
	local nWhipAmount	= 0;	--
	local nAPillAmount	= 0;	--
	local nPPillAmount	= 0;	--
	local nIPillAmount	= 0;	--
	local nPlayerId		= ConvertN(GetPlayerId());
	local tItemIDList	= ItemUser.GetBagItemList(nPlayerId);
	for i, v in ipairs(tItemIDList) do
		local nItemType		= Item.GetItemInfoN( v, Item.ITEM_TYPE );
		if ( nItemType == GodHorsewhip_ITEM_TYPE ) then
			nWhipAmount = nWhipAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
		end       
		if ( nItemType == MountSoulPill_ADVANCED_ITEM_TYPE ) then
			nAPillAmount = nAPillAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
        end
		if ( nItemType == MountSoulPill_PLATINIC_ITEM_TYPE ) then
			nPPillAmount = nPPillAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
        end
		if ( nItemType == MountSoulPill_IMPERIAL_ITEM_TYPE ) then
			nIPillAmount = nIPillAmount + Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
        end
	end
	--local szInfor = "";
	--szInfor = szInfor.. nWhipName .. ":" .. nWhipAmount .. "\n";
	--szInfor = szInfor.. szAPillName .. ":" .. nAPillAmount .. "\n";
	--szInfor = szInfor.. szPPillName .. ":" .. nPPillAmount .. "\n";
	--szInfor = szInfor.. szIPillName .. ":" .. nIPillAmount;
	--SetLabel( p.pLayerMountSoulUI, ID_LABEL_MOUNTSOULPILL_INFOR, szInfor);
	SetLabel( p.pLayerMountSoulUI, ID_LABEL_GODHORSEWHIP_AMOUNT, SafeN2S(nWhipAmount) );
	SetLabel( p.pLayerMountSoulUI, ID_LABEL_MOUNTSOULPILL_A_AMOUNT, SafeN2S(nAPillAmount) );
	SetLabel( p.pLayerMountSoulUI, ID_LABEL_MOUNTSOULPILL_P_AMOUNT, SafeN2S(nPPillAmount) );
	SetLabel( p.pLayerMountSoulUI, ID_LABEL_MOUNTSOULPILL_I_AMOUNT, SafeN2S(nIPillAmount) );
end

-- 有物品改变事件发生时的回调
GameDataEvent.Register( GAMEDATAEVENT.ITEMATTR, "MountSoul.ShowMountSoulPillAmount", p.ShowMountSoulPillAmount );
GameDataEvent.Register( GAMEDATAEVENT.ITEMINFO, "MountSoul.ShowMountSoulPillAmount", p.ShowMountSoulPillAmount );
GlobalEvent.Register( GLOBALEVENT.GE_ITEM_UPDATE, "MountSoul.ShowMountSoulPillAmount", p.ShowMountSoulPillAmount );
