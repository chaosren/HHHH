---------------------------------------------------
--描述: 装备魔化相关消息响应及发送
--时间: 2013.8.2
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgEvilMelt = {}
local p = MsgEvilMelt;

---------------------------------------------------


---------------------------------------------------

-- 装备魔化消息事件类型




---------------------------------------------------


---------------------------------------------------


--------------------------------------------------- 

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
-- 发送装备魔化请求
function p.SendMsgEvilMelt( nItemID )
	LogInfo( "MsgEvilMelt: SendMsgEvilMelt nItemID:%d",nItemID );
	local netdata = createNDTransData(NMSG_Type._MSG_EVILMELT);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteInt( nItemID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
end

---------------------------------------------------
-- 处理装备魔化消息
function p.HandleMsgEvilMelt( tNetDataPackete )
	LogInfo( "MsgEvilMelt: HandleMsgEvilMelt" );
	EvilMelt.CallBack_EvilMelt();--
    CloseLoadBar();
end


---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgEvilMelt: HandleNetMessage" );
	p.HandleMsgEvilMelt( tNetDataPackete );
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_EVILMELT, "MsgEvilMelt.HandleNetMessage", p.HandleNetMessage );

