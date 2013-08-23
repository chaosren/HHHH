---------------------------------------------------
--描述: 每日抽奖
--时间: 2012.7.25
--作者: Guosen
---------------------------------------------------
-- 进入幸运宝箱界面接口：		DailyLottery.Entry()
---------------------------------------------------

DailyLottery = {}
local p = DailyLottery;


---------------------------------------------------
local ID_BTN_LOTTERY					= 3;	-- 抽奖按钮
local ID_CTRL_SPRITE					= 2;	-- 动画控件

---------------------------------------------------
-- 宝箱的动画索引
local BOX_INDEX_CLOSED		= 0;	-- 关闭的
local BOX_INDEX_OPENED		= 1;	-- 打开的
local BOX_INDEX_OPENING		= 2;	-- 打开过程


---------------------------------------------------
local SZ_ERROR_00				= GetTxtPri("DL_T1")-- "您已抽奖";

---------------------------------------------------

---------------------------------------------------
p.nAniIndex			= nil;	-- 动画索引
p.nTimerCutDown		= nil;	-- 关闭计时器
p.szPrize			= nil;	-- 奖励文字

---------------------------------------------------
-- 进入--时间点到才可以
function p.Entry()
	p.nAniIndex			= nil;
	p.nTimerCutDown		= nil;
	p.szPrize			= nil;
	MsgDailyLottery.SendMsgGetUserInfor();
	--测试
	--p.ShowDailyLotteryMainUI();
end


---------------------------------------------------
-- 显示每日抽奖主界面
function p.ShowDailyLotteryMainUI()
	--LogInfo( "DailyLottery: ShowDailyLotteryMainUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "DailyLottery: ShowDailyLotteryMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "DailyLottery: ShowDailyLotteryMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.DailyLottery );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "DailyLottery: ShowDailyLotteryMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "luckydraw/luckydraw.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	
	p.nAniIndex		= BOX_INDEX_CLOSED;
end

-- 关闭抽奖界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.DailyLottery, true );
	end
	if ( p.nTimerCutDown ~= nil ) then
		UnRegisterTimer( p.nTimerCutDown );
	end
	p.nAniIndex			= nil;
	p.nTimerCutDown		= nil;
	p.szPrize			= nil;
end

---------------------------------------------------
-- 每日抽奖界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( tag == ID_BTN_LOTTERY ) then
			MsgDailyLottery.SendMsgLottery();
			--测试
			--p.OpenBox();
		end
	end
	return true;
end

---------------------------------------------------
-- 获取用户信息回调（已抽奖次数，最高可抽奖次数）
function p.CallBack_GetUserInfor( nLotteryAmount, nMaxNum )
	LogInfo( "DailyLottery: CallBack_GetUserInfor nLotteryAmount:%d, nMaxNum:%d",nLotteryAmount,nMaxNum );
	if ( nLotteryAmount >= nMaxNum ) then
		CommonDlgNew.ShowYesDlg( SZ_ERROR_00, nil, nil, 3 );
		return;
	end
	if not IsUIShow( NMAINSCENECHILDTAG.DailyLottery ) then
		p.ShowDailyLotteryMainUI();
	end
end

---------------------------------------------------
-- 抽奖信息回调（奖励表）
function p.CallBack_Lottery( tPrize )
	if not IsUIShow( NMAINSCENECHILDTAG.DailyLottery ) then
		return;
	end
	p.szPrize = p.GetPrizeString( tPrize );
	p.OpenBox();
end

---------------------------------------------------
-- 获得奖励内容文本字符串--显示控制表
function p.GetPrizeString( tPrize )
	if ( tPrize == nil ) then
		return nil;
	end
	--local szResult = "";
	local infos = {};
	
	if ( tPrize.nMoney~=nil and tPrize.nMoney>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("coin").."+%d,",tPrize.nMoney);
		table.insert(infos,{string.format(GetTxtPub("coin").." +%d",tPrize.nMoney),FontColor.Silver});
	end
	if ( tPrize.nEMoney~=nil and tPrize.nEMoney>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("shoe").."+%d,",tPrize.nEMoney);
		table.insert(infos,{string.format(GetTxtPub("shoe").." +%d",tPrize.nEMoney),FontColor.Coin});
	end
	if ( tPrize.nRepute~=nil and tPrize.nRepute>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("ShenWan").."+%d,",tPrize.nRepute);
		table.insert(infos,{string.format(GetTxtPub("ShenWan").." +%d",tPrize.nRepute),FontColor.Reput});
	end
	if ( tPrize.nStamina~=nil and tPrize.nStamina>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("Stamina").."+%d,",tPrize.nStamina);
		table.insert(infos,{string.format(GetTxtPub("Stamina").." +%d",tPrize.nStamina),FontColor.Stamina});
	end
	if ( tPrize.nSoph~=nil and tPrize.nSoph>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("JianHun").."+%d,",tPrize.nSoph);
		table.insert(infos,{string.format(GetTxtPub("JianHun").." +%d",tPrize.nSoph),FontColor.Soul});
	end
	if ( tPrize.nExp~=nil and tPrize.nExp>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("exp").."+%d,",tPrize.nExp);
		table.insert(infos,{string.format(GetTxtPub("exp").." +%d",tPrize.nExp),FontColor.Exp});
	end
	if ( tPrize.nSpirit~=nil and tPrize.nSpirit>0 ) then
		--szResult = szResult .. string.format(GetTxtPub("Spirit").."+%d,",tPrize.nSpirit);
		table.insert(infos,{string.format(GetTxtPub("Spirit").." +%d",tPrize.nSpirit),FontColor.Text});
	end
	if ( tPrize.nExploits~=nil and tPrize.nExploits>0 ) then
		--szResult = szResult .. string.format("军功".."+%d,",tPrize.nExploits);
		table.insert(infos,{string.format("军功".." +%d",tPrize.nExploits),FontColor.Text});
	end
	
	local nItemCount = table.getn( tPrize.tItems );
	for i=1,nItemCount do
		local nItemType	=  tPrize.tItems[i][1];
		local nNum		=  tPrize.tItems[i][2];
		if(nNum>0) then
			--szResult = szResult ..string.format(ItemFunc.GetName(nItemType).."+%d,",nNum);
			table.insert(infos,{string.format(ItemFunc.GetName(nItemType).." x%d",nNum),ItemFunc.GetItemColor(nItemType)});
		end
	end
	--return szResult;
	return infos;
end

---------------------------------------------------
-- 打开宝箱-
function p.OpenBox()
	local pScene = GetSMGameScene();
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.DailyLottery );
	if not CheckP( pLayer ) then
		return;
	end
	if ( p.nAniIndex == BOX_INDEX_CLOSED ) then
		local pSpriteNode = RecursivUISprite( pLayer, {ID_CTRL_SPRITE} );
		if ( pSpriteNode ~= nil ) then
			pSpriteNode:PlayAnimation( BOX_INDEX_OPENING, false );
			RegisterTimer( p.OnTimer_SpriteAnimation, 1/24 );
			p.nAniIndex		= BOX_INDEX_OPENING;
		end
	elseif ( p.nAniIndex == BOX_INDEX_OPENED ) then
		p.CloseUI();
	end
end

---------------------------------------------------
-- 检测动画播放定时器
function p.OnTimer_SpriteAnimation( nTimerID )
	local pScene = GetSMGameScene();
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.DailyLottery );
	if not CheckP( pLayer ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	local pSpriteNode = RecursivUISprite( pLayer, {ID_CTRL_SPRITE} );
	if ( pSpriteNode == nil ) then
		p.CloseUI();
		UnRegisterTimer( nTimerID );
		return;
	end
	if ( pSpriteNode:IsAnimationComplete() ) then
		UnRegisterTimer( nTimerID );
		pSpriteNode:PlayAnimation( BOX_INDEX_OPENED, false );
		p.nAniIndex		= BOX_INDEX_OPENED;
		--
		if ( p.szPrize ~= nil ) then
			--
			CommonDlgNew.ShowTipsDlg( p.szPrize );
		end
		--
		p.nTimerCutDown		= RegisterTimer( p.OnTimer_CoutDown, 1.0 );--
	end
end

---------------------------------------------------
-- 关闭定时器
function p.OnTimer_CoutDown( nTimerID )
	UnRegisterTimer( nTimerID );
	p.CloseUI();
end