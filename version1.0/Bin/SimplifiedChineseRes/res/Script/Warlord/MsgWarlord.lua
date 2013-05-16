---------------------------------------------------
--描述: 战神像相关消息响应及发送
--时间: 2012.3.26
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgWarlord = {}
local p = MsgWarlord;

---------------------------------------------------


---------------------------------------------------


-- 消息事件类型
local WMA_Worship				= 1;	-- 参拜
local WMA_Entry					= 2;	-- 进入
local WMA_Init					= 3;

-- WarlordWorshipMode 参拜类型
WWM = {
	Normal		= 1,	-- 普通参拜
	Devout		= 2,	-- 虔诚参拜
	Wild		= 3,	-- 狂热参拜
};

---------------------------------------------------
p.tConfig	=	nil;	-- 配置数据--服务端发
--{
--	nVisitMax			,	-- 每天可参拜次数
--	nNormalSpirit		,	-- 普通参拜获得的橙魂
--	nNormalMoney		,	-- 普通参拜获得的银币
--	nNormalSpendEmoney	,	-- 普通参拜消耗的金币
--	nDevoutSpirit		,	-- 虔诚参拜获得的橙魂
--	nDevoutMoney		,	-- 虔诚参拜获得的银币
--	nDevoutSpendEmoney	,	-- 虔诚参拜消耗的金币
--	nWildSpirit			,	-- 狂热参拜获得的橙魂
--	nWildMoney			,	-- 狂热参拜获得的银币
--	nWildSpendEmoney	,	-- 狂热参拜消耗的金币
--}

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
---------------------------------------------------
-- 发送参拜请求(参拜类型)
function p.SendMsgWorship( nType )
	LogInfo( "MsgWarlord: SendMsgWorship" );
	local netdata = createNDTransData(NMSG_Type._MSG_WARLORD);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( WMA_Worship );
	netdata:WriteInt( nType );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
end

---------------------------------------------------
-- 处理参拜消息
function p.HandleMsgWorship( tNetDataPackete )
	LogInfo( "MsgWarlord: HandleMsgWorship" );
	local nUserVisitNum	= tNetDataPackete:ReadInt();	-- 已参拜次数
	if IsUIShow( NMAINSCENECHILDTAG.Warlord ) then
		Warlord.CallBack_Refresh( nUserVisitNum );
	end
	CloseLoadBar();
end

---------------------------------------------------
-- 发送进入请求
function p.SendMsgEntry()
	LogInfo( "MsgWarlord: SendMsgEntry" );
	local netdata = createNDTransData(NMSG_Type._MSG_WARLORD);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( WMA_Entry );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
end

---------------------------------------------------
-- 进入界面
function p.HandleMsgEntry( tNetDataPackete )
	LogInfo( "MsgWarlord: HandleMsgEntry" );
	local nUserVisitNum	= tNetDataPackete:ReadInt();	-- 已参拜次数
	if not IsUIShow( NMAINSCENECHILDTAG.Warlord ) then
		Warlord.ShowWarlordMainUI();
		Warlord.CallBack_Refresh( nUserVisitNum );
	else
		Warlord.CallBack_Refresh( nUserVisitNum );
	end
	CloseLoadBar();
end

---------------------------------------------------
-- 登录后初始一些数据
function p.HandleMsgInit( tNetDataPackete )
	LogInfo( "MsgWarlord: HandleMsgInit" );
	local nVisitMax				= tNetDataPackete:ReadInt();	-- 每天可参拜次数
	local nNormalSpirit			= tNetDataPackete:ReadInt();	-- 普通参拜获得的橙魂
	local nNormalMoney			= tNetDataPackete:ReadInt();	-- 普通参拜获得的银币
	local nNormalSpendEmoney	= tNetDataPackete:ReadInt();	-- 普通参拜消耗的金币
	local nDevoutSpirit			= tNetDataPackete:ReadInt();	-- 虔诚参拜获得的橙魂
	local nDevoutMoney			= tNetDataPackete:ReadInt();	-- 虔诚参拜获得的银币
	local nDevoutSpendEmoney	= tNetDataPackete:ReadInt();	-- 虔诚参拜消耗的金币
	local nWildSpirit			= tNetDataPackete:ReadInt();	-- 狂热参拜获得的橙魂
	local nWildMoney			= tNetDataPackete:ReadInt();	-- 狂热参拜获得的银币
	local nWildSpendEmoney		= tNetDataPackete:ReadInt();	-- 狂热参拜消耗的金币
	local tConfig				= {};
	tConfig.nVisitMax			= nVisitMax;
	tConfig.nNormalSpirit		= nNormalSpirit;
	tConfig.nNormalMoney		= nNormalMoney;
	tConfig.nNormalSpendEmoney	= nNormalSpendEmoney;
	tConfig.nDevoutSpirit		= nDevoutSpirit;
	tConfig.nDevoutMoney		= nDevoutMoney;
	tConfig.nDevoutSpendEmoney	= nDevoutSpendEmoney;
	tConfig.nWildSpirit			= nWildSpirit;
	tConfig.nWildMoney			= nWildMoney;
	tConfig.nWildSpendEmoney	= nWildSpendEmoney;
	p.tConfig					= tConfig;
end


---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgWarlord: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgWarlord: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == WMA_Worship ) then
		p.HandleMsgWorship( tNetDataPackete );
	elseif ( nActionID == WMA_Entry ) then
		p.HandleMsgEntry( tNetDataPackete );
	elseif ( nActionID == WMA_Init ) then
		p.HandleMsgInit( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_WARLORD, "MsgWarlord.HandleNetMessage", p.HandleNetMessage );

