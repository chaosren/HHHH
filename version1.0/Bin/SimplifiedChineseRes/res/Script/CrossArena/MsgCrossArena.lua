---------------------------------------------------
--描述: 跨服竞技场消息处理
--时间: 2013.8.30
--作者: tzq
---------------------------------------------------
MsgCrossArena = {}
local p = MsgCrossArena;

p.EOPERATE_ACTION =
{
    EOPERATE_ACTION_ADD_CHALLENGE_COUNT_REQUEST = 1,
    EOPERATE_ACTION_ADD_CHALLENGE_COUNT_OVER = 2,  
    EOPERATE_ACTION_CHALLENGE  = 3,         
};

function p.RevCrossArenaList(netdatas)
	
	CrossArenaUI.UserInfo = {};

	CrossArenaUI.UserInfo.usRank =          netdatas:ReadShort();           --玩家排名
	CrossArenaUI.UserInfo.ucLeftCount =     netdatas:ReadByte();            --剩余挑战次数
	CrossArenaUI.UserInfo.ucHasAddCount =   netdatas:ReadByte();            --已增加次数
	CrossArenaUI.UserInfo.dwCDTime    =     netdatas:ReadInt();             --CD时间
	
	local ucAcount =     netdatas:ReadByte();            --列表数据量
	
	if ucAcount < 3 then
		return;   --前三名为左边要显示的前三名玩家
	end
	
	CrossArenaUI.CrossArenaListInfo = {};
	for i = 1, ucAcount do
		local obj = {};
		obj.nUserid=netdatas:ReadInt();
		obj.nRank=netdatas:ReadInt();
		obj.ucLevel=netdatas:ReadByte();
		obj.szName=netdatas:ReadUnicodeString();
		obj.nIdLookface=netdatas:ReadInt(); 
        
       table.insert(CrossArenaUI.CrossArenaListInfo, obj);
	end
	
	 if not IsUIShow(NMAINSCENECHILDTAG.TransportUI) then
		CrossArenaUI.LoadUI();
	 else
	 	CrossArenaUI.RefreshUI(); 
	 end
end

--增加挑战次数请求
function p.MsgSendAcrossArenaAction(nAction, nRank)  
	local netdata = createNDTransData(NMSG_Type._MSG_WORLDBATTLE_OPERATE);
	netdata:WriteShort(nAction);
	
	if nAction == p.EOPERATE_ACTION.EOPERATE_ACTION_CHALLENGE then
		netdata:WriteShort(nRank);   --发送挑战请求
	end
	SendMsg(netdata);	
	netdata:Free();	
	return true;	
end

--
function p.MsgSendChllenge(nRank)  
	local netdata = createNDTransData(NMSG_Type._MSG_WORLDBATTLE_OPERATE);
	netdata:WriteShort( p.EOPERATE_ACTION.EOPERATE_ACTION_ADD_CHALLENGE_COUNT_REQUEST );
	SendMsg(netdata);	
	netdata:Free();	
	return true;	
end


function p.RevChallengeTimes(netdatas)
	local usAccion = netdatas:ReadShort();
	
	--更新用户挑战次数
	if usAccion == p.EOPERATE_ACTION.EOPERATE_ACTION_ADD_CHALLENGE_COUNT_OVER then
		if CrossArenaUI.UserInfo ~= nil then
			CrossArenaUI.UserInfo.ucLeftCount = netdatas:ReadInt();  --挑战次数
			CrossArenaUI.UserInfo.ucHasAddCount = netdatas:ReadInt();  --已增加次数	
			if not IsUIShow(NMAINSCENECHILDTAG.TransportUI) then
				CrossArenaUI.LoadUI();
			else
				CrossArenaUI.RefreshUI(); 
			end
		end
	end
end



RegisterNetMsgHandler(NMSG_Type._MSG_WORLDBATTLE_OPERATE, "p.RevChallengeTimes", p.RevChallengeTimes);
RegisterNetMsgHandler(NMSG_Type._MSG_WORLDBATTLE_PLAYERINFO, "p.RevCrossArenaList", p.RevCrossArenaList);