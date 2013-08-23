---------------------------------------------------
--描述: 每日抽奖相关消息响应及发送
--时间: 2012.7.25
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgDailyLottery = {}
local p = MsgDailyLottery;

---------------------------------------------------


---------------------------------------------------
--DailyLotteryMesageAction
local DLMA_GetUserInfor			= 1;	-- 获得玩家信息
local DLMA_Lottery				= 2;	-- 抽奖



---------------------------------------------------

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
-- 发送获取玩家信息请求
function p.SendMsgGetUserInfor()
	LogInfo( "MsgDailyLottery: SendMsgGetUserInfor" );
	local netdata = createNDTransData(NMSG_Type._MSG_DAILY_LOTTERY);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( DLMA_GetUserInfor );
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end

---------------------------------------------------
-- 处理玩家信息消息
function p.HandleMsgGetUserInfor( tNetDataPackete )
	--LogInfo( "MsgDailyLottery: HandleMsgGetUserInfor" );
	local nLotteryAmount	= tNetDataPackete:ReadInt();	--已抽奖次数
	local nMaxNum			= tNetDataPackete:ReadInt();	--最高可抽奖次数
	LogInfo( "MsgDailyLottery:  HandleMsgGetUserInfor: nLotteryAmount:%d, nMaxNum:%d",nLotteryAmount,nMaxNum );
	DailyLottery.CallBack_GetUserInfor( nLotteryAmount, nMaxNum );
	CloseLoadBar();--
end

---------------------------------------------------
-- 发送获抽奖请求
function p.SendMsgLottery()
	LogInfo( "MsgDailyLottery: SendMsgLottery" );
	local netdata = createNDTransData(NMSG_Type._MSG_DAILY_LOTTERY);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( DLMA_Lottery );
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end

---------------------------------------------------
-- 处理抽奖消息
function p.HandleMsgLottery( tNetDataPackete )
	--LogInfo( "MsgDailyLottery: HandleMsgLottery" );
	local nMoney		= tNetDataPackete:ReadInt();
	local nEMoney		= tNetDataPackete:ReadInt();
	local nRepute		= tNetDataPackete:ReadInt();
	local nStamina		= tNetDataPackete:ReadInt();
	local nSoph			= tNetDataPackete:ReadInt();
	local nExp			= tNetDataPackete:ReadInt();
	local nSpirit		= tNetDataPackete:ReadInt();
	local nExploits		= tNetDataPackete:ReadInt();
	local nItemTypeNum	= tNetDataPackete:ReadInt();
	--LogInfo( "MsgDailyLottery: HandleMsgLottery %d, %d, %d, %d, %d, %d, %d, %d",nMoney,nEMoney,nRepute,nStamina,nSoph,nExp,nSpirit,nExploits );
	local tPrize	= {};
	tPrize.nMoney		= nMoney;
	tPrize.nEMoney		= nEMoney;
	tPrize.nRepute		= nRepute;
	tPrize.nStamina		= nStamina;
	tPrize.nSoph		= nSoph;
	tPrize.nExp			= nExp;
	tPrize.nSpirit		= nSpirit;
	tPrize.nExploits	= nExploits;
	tPrize.tItems		= {};
	for i=1, nItemTypeNum do
		local nItemType		= tNetDataPackete:ReadInt();
		local nItemCount	= tNetDataPackete:ReadInt();
		tPrize.tItems[i] = {};
		tPrize.tItems[i][1]	= nItemType;
		tPrize.tItems[i][2]	= nItemCount;
	end
	DailyLottery.CallBack_Lottery( tPrize );
	CloseLoadBar();--
end


---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgDailyLottery: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgDailyLottery: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == DLMA_GetUserInfor ) then
		p.HandleMsgGetUserInfor( tNetDataPackete );
	elseif ( nActionID == DLMA_Lottery ) then
		p.HandleMsgLottery( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_DAILY_LOTTERY, "MsgDailyLottery.HandleNetMessage", p.HandleNetMessage );

