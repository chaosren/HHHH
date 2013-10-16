---------------------------------------------------
--描述: 兽魂相关消息响应及发送
--时间: 2012.1.21
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgMountSoul = {}
local p = MsgMountSoul;

---------------------------------------------------


---------------------------------------------------


-- 消息事件类型
local BMA_Entry					= 1;	-- 进入
local BMA_Cultivate				= 2;	-- 培养

-- MountSoulTrainMode 培养类型
MSTM = {
	Normal		= 1,	-- 普通培养
	Advanced	= 2,	-- 高级培养
	Platinic	= 3,	-- 白金培养
	Imperial	= 4,	-- 至尊培养
	
};

---------------------------------------------------
---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
---------------------------------------------------
-- 发送培养请求(培养类型，培养次数)
function p.SendMsgCultivate( nType, nCount )
	LogInfo( "MsgMountSoul: SendMsgCultivate: nType:%d, nCount:%d", nType, nCount );
	local netdata = createNDTransData(NMSG_Type._MSG_MOUNTSOUL);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_Cultivate );
	netdata:WriteInt( nType );
	netdata:WriteInt( nCount );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
end

---------------------------------------------------
-- 处理培养消息
function p.HandleMsgCultivate( tNetDataPackete )
	LogInfo( "MsgMountSoul: HandleMsgCultivate" );
	local nType		= tNetDataPackete:ReadInt();	-- 实际培养类型
	local nCount	= tNetDataPackete:ReadInt();	-- 实际培养次数
	local nLevel	= tNetDataPackete:ReadInt();	-- 升了几级
	local nExp		= tNetDataPackete:ReadInt();	-- 获得经验
	local nStr		= tNetDataPackete:ReadInt();	-- 获得力量加成
	local nIni		= tNetDataPackete:ReadInt();	-- 获得智力加成--
	local nAgi		= tNetDataPackete:ReadInt();	-- 获得敏捷加成--
	local nLife		= tNetDataPackete:ReadInt();	-- 获得生命加成
	local nImmuneDamage	= tNetDataPackete:ReadInt();	-- 获得免伤加成
	local nCritNum	= tNetDataPackete:ReadInt();	-- 暴击次数
	local tProperty	= {};
	tProperty.nType		= nType;
	tProperty.nCount	= nCount;
	tProperty.nLevel	= nLevel;
	tProperty.nExp		= nExp;
	tProperty.nStr		= nStr;
	tProperty.nAgi		= nAgi;
	tProperty.nIni		= nIni;
	tProperty.nLife		= nLife;
	tProperty.nImmuneDamage	= nImmuneDamage;
	tProperty.nCritNum	= nCritNum;
	MountSoul.ShowIncProperty( tProperty );
end

---------------------------------------------------
-- 发送进入请求
function p.SendMsgEntry()
	LogInfo( "MsgMountSoul: SendMsgEntry" );
	local netdata = createNDTransData(NMSG_Type._MSG_MOUNTSOUL);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_Entry );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
end

---------------------------------------------------
-- 进入界面
function p.HandleMsgEntry( tNetDataPackete )
	LogInfo( "MsgMountSoul: HandleMsgEntry" );
	local nCurrentLevel	= tNetDataPackete:ReadInt();	-- 总总总的某一等级
	local nCurrentExp	= tNetDataPackete:ReadInt();	-- 当前等级，当前剩余的经验
	local nTotalExp		= tNetDataPackete:ReadInt();	-- 已获得的经验总和
	local nTotalStr		= tNetDataPackete:ReadInt();	-- 力量加成总和
	local nTotalAgi		= tNetDataPackete:ReadInt();	-- 敏捷加成总和
	local nTotalIni		= tNetDataPackete:ReadInt();	-- 智力加成总和
	local nTotalLife	= tNetDataPackete:ReadInt();	-- 生命加成总和
	local nTotalImmuneDamage	= tNetDataPackete:ReadInt();	-- 免伤加成总和
	local tProperty	= {};
	tProperty.nCurrentLevel	= nCurrentLevel;
	tProperty.nCurrentExp	= nCurrentExp;
	tProperty.nTotalExp		= nTotalExp;
	tProperty.nTotalStr		= nTotalStr;
	tProperty.nTotalAgi		= nTotalAgi;
	tProperty.nTotalIni		= nTotalIni;
	tProperty.nTotalLife	= nTotalLife;
	tProperty.nTotalImmuneDamage	= nTotalImmuneDamage;
	if not IsUIShow( NMAINSCENECHILDTAG.MountSoul ) then
		MountSoul.ShowMountSoulMainUI();
		MountSoul.CallBack_Refresh( tProperty );
	else
		MountSoul.CallBack_Refresh( tProperty );
	end
    CloseLoadBar();
end


---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgMountSoul: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgMountSoul: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == BMA_Cultivate ) then
		p.HandleMsgCultivate( tNetDataPackete );
	elseif ( nActionID == BMA_Entry ) then
		p.HandleMsgEntry( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_MOUNTSOUL, "MsgMountSoul.HandleNetMessage", p.HandleNetMessage );

