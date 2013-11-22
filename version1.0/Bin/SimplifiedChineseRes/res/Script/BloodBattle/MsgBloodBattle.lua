---------------------------------------------------
--描述: 血战相关消息响应及发送
--时间: 2012.7.8
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgBloodBattle = {}
local p = MsgBloodBattle;


---------------------------------------------------
--BloodBattleMesageAction
local BBMA_Challenge				= 1;	-- 开始挑战
local BBMA_Reset					= 2;	-- 重置
local BBMA_UserInfor				= 3;	-- 玩家信息
local BBMA_Reward					= 4;	-- 奖励信息
local BBMA_TimeOut					= 5;	-- 不在时间点
local BBMA_LeftTimes				= 6;	-- 剩余挑战次数



---------------------------------------------------

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
-- 发送挑战请求(难度(1,2,3))
function p.SendMsgChallenge( nMode )
	LogInfo( "MsgBloodBattle: SendMsgChallenge nMode:%d",nMode );
	local netdata = createNDTransData(NMSG_Type._MSG_BLOODBATTLE);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BBMA_Challenge );
	netdata:WriteInt( nMode );
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end

---------------------------------------------------
-- 处理挑战消息
function p.HandleMsgChallenge( tNetDataPackete )
	--LogInfo( "MsgBloodBattle: HandleMsgChallenge" );
	CloseLoadBar();--
end
---------------------------------------------------
-- 发送重置请求
function p.SendMsgReset()
	LogInfo( "MsgBloodBattle: SendMsgReset" );
	local netdata = createNDTransData(NMSG_Type._MSG_BLOODBATTLE);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BBMA_Reset );
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end

---------------------------------------------------
-- 处理重置消息
function p.HandleMsgReset( tNetDataPackete )
	--LogInfo( "MsgBloodBattle: HandleMsgReset" );
	if IsUIShow( NMAINSCENECHILDTAG.BloodBattleRanking ) then
	else
		BloodBattle.Reset();
	end
	CloseLoadBar();--
end

---------------------------------------------------
-- 发送玩家信息请求 
function p.SendMsgUserInfor()
	LogInfo( "MsgBloodBattle: SendMsgUserInfor" );
	local netdata = createNDTransData(NMSG_Type._MSG_BLOODBATTLE);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BBMA_UserInfor );
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end

---------------------------------------------------
-- 处理玩家信息
function p.HandleMsUserInfor( tNetDataPackete )
	--LogInfo( "MsgBloodBattle: HandleMsUserInfor" );
	local nChallCount	= tNetDataPackete:ReadInt();--当天已挑战次数
	local nClimbLayer	= tNetDataPackete:ReadInt();--当前次已挑战的关数
	local nMaxLayer		= tNetDataPackete:ReadInt();--当天挑战的最高关数
	local nGrade		= tNetDataPackete:ReadInt();--玩家所处的阶段
	local uChallMax		= tNetDataPackete:ReadInt();--当天挑战次数上限
	local nGID			= tNetDataPackete:ReadInt();--怪物生成ID
	local nLvLmt		= tNetDataPackete:ReadInt();--当前阶段关卡限制
	local nPoints		= tNetDataPackete:ReadInt();--今日最高积分
	local nBuffLv		= tNetDataPackete:ReadInt();--BUFF等级
	--
	local tUserInfor = {};
	tUserInfor.nChallCount	= nChallCount;
	tUserInfor.nClimbLayer	= nClimbLayer;
	tUserInfor.nMaxLayer	= nMaxLayer;
	tUserInfor.nGrade		= nGrade;
	tUserInfor.uChallMax	= uChallMax;
	tUserInfor.nGID			= nGID;
	tUserInfor.nLvLmt		= nLvLmt;
	tUserInfor.nPoints		= nPoints;
	tUserInfor.nBuffLv		= nBuffLv;
	--LogInfo( "MsgBloodBattle: HandleMsUserInfor nChallCount:%d, nClimbLayer:%d, nMaxLayer:%d, nGrade:%d, uChallMax:%d, nGID:%d",nChallCount,nClimbLayer,nMaxLayer,nGrade,uChallMax,nGID );
	if IsUIShow( NMAINSCENECHILDTAG.BloodBattle ) then
		BloodBattle.RefreshMainUI( tUserInfor );
	else
		BloodBattle.ShowBloodBattleMainUI( tUserInfor );
	end
	CloseLoadBar();--
end

---------------------------------------------------
-- 处理奖励信息
function p.HandleMsReward( tNetDataPackete )
	--LogInfo( "MsgBloodBattle: HandleMsReward" );
	local nMoney		= tNetDataPackete:ReadInt();--银币
	local nItemType		= tNetDataPackete:ReadInt();--物品类型
	local nItemAmount	= tNetDataPackete:ReadInt();--物品数量
	local tReward = {};
	tReward.nMoney		= nMoney;
	tReward.nItemType	= nItemType;
	tReward.nItemAmount	= nItemAmount;
	LogInfo( "MsgBloodBattle: HandleMsReward nMoney:%d, nItemType:%d, nItemAmount:%d",nMoney,nItemType,nItemAmount );
	if IsUIShow( NMAINSCENECHILDTAG.BloodBattle ) then
		BloodBattle.ShowRewardDlg( tReward );
	else
	end
end


---------------------------------------------------

local g_LeftTimes = 0;
--获取剩余调战次数
function p.SendMsgLeftTimes()
	LogInfo( "MsgBloodBattle: SendMsgLeftTimes" );
	local netdata = createNDTransData(NMSG_Type._MSG_BLOODBATTLE);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BBMA_LeftTimes );
	SendMsg( netdata );
	netdata:Free();	
end

function p.GetLeftTimes()
	return g_LeftTimes;
end


--刷新主界面提示按钮
function p.HandleMsLeftTimes( tNetDataPackete )
	g_LeftTimes = tNetDataPackete:ReadInt();
	local test = g_LeftTimes
	
	MainUI.RefreshFuncIsOpen()
end

--活动数据更新 bOpen: true-活动开启  false-活动结束
function p.DailyActionUpdate(bOpen)
	if bOpen then
		p.SendMsgLeftTimes()
	else
		g_LeftTimes = 0
		MainUI.RefreshFuncIsOpen()
	end
end




-- 处理不在时间点信息
function p.HandleMsTimeOut( tNetDataPackete )
	--LogInfo( "MsgBloodBattle: HandleMsTimeOut" );
	if IsUIShow( NMAINSCENECHILDTAG.BloodBattle ) then
		BloodBattle.ShowTimeOutDlg();
	else
	end
	CloseLoadBar();--
end

---------------------------------------------------
-- 血战消息分发处理
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgBloodBattle: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgBloodBattle: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == BBMA_Challenge ) then
		p.HandleMsgChallenge( tNetDataPackete );
	elseif ( nActionID == BBMA_Reset ) then
		p.HandleMsgReset( tNetDataPackete );
	elseif ( nActionID == BBMA_UserInfor ) then
		p.HandleMsUserInfor( tNetDataPackete );
	elseif ( nActionID == BBMA_Reward ) then
		p.HandleMsReward( tNetDataPackete );
	elseif ( nActionID == BBMA_TimeOut ) then
		p.HandleMsTimeOut( tNetDataPackete );
	elseif 	( nActionID == BBMA_LeftTimes ) then
		p.HandleMsLeftTimes( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_BLOODBATTLE, "MsgBloodBattle.HandleNetMessage", p.HandleNetMessage );



---------------------------------------------------
-- 发送血战排名请求 
function p.SendMsgRanking( nGrade )
	LogInfo( "MsgBloodBattle: SendMsgRanking" );
	local netdata = createNDTransData(NMSG_Type._MSG_BLOODBATTLERANKING);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( nGrade );
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end
---------------------------------------------------
-- 血战排名消息分发处理
function p.HandleNetMessageRanking( tNetDataPackete )
	LogInfo( "MsgBloodBattle: HandleNetMessageRanking" );
	local nGrade = tNetDataPackete:ReadByte();
	local nCount = tNetDataPackete:ReadByte();
	local tRanking = {};
	for i=1, nCount do
		tRanking[i]	= {};
		tRanking[i].nRank	= tNetDataPackete:ReadInt();
		tRanking[i].nLevel	= tNetDataPackete:ReadInt();
		tRanking[i].szName	= tNetDataPackete:ReadUnicodeString();
		LogInfo( "MsgBloodBattle: HandleNetMessageRanking: nRank:%d, nLevel:%d, szName:%s",tRanking[i].nRank,tRanking[i].nLevel,tRanking[i].szName );
	end
	if IsUIShow( NMAINSCENECHILDTAG.BloodBattleRanking ) then
		BloodBattle.RefreshRankingUI( nGrade, tRanking );
	else
		BloodBattle.ShowRankingUI( nGrade, tRanking );
	end
	--
	CloseLoadBar();--
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_BLOODBATTLERANKING, "MsgBloodBattle.HandleNetMessageRanking", p.HandleNetMessageRanking );

