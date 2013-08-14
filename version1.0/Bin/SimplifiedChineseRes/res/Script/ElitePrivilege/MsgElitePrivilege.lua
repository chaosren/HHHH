---------------------------------------------------
--描述: 处理精英特权相关消息
--时间: 2013.4.26
--作者: tzq
---------------------------------------------------

MsgElitePrivilege = {}
local p = MsgElitePrivilege;

p.EPListener = nil;


--保存精英特权状态信息  { {byte type, int value}, {byte type, int value},}
p.tbElPriInfo = {};


function p.MsgRevElitePrivilege(netdatas)
	
	local bAccount = netdatas:ReadByte();
	
	for i = 1, bAccount do
		local tbInfo = {};
		tbInfo.bType = netdatas:ReadByte();
		tbInfo.nValue = netdatas:ReadInt();
		
		p.tbElPriInfo[tbInfo.bType] = tbInfo.nValue;
	end 
	
	--刷新對應的數據
	if p.EPListener ~= nil then
		p.EPListener();
	end
end



RegisterNetMsgHandler(NMSG_Type._MSG_ELITE_PRIVILEGE_INFO,  "p.MsgRevElitePrivilege", p.MsgRevElitePrivilege);
