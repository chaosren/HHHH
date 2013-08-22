---------------------------------------------------
--描述: 资源争夺战相关消息
--时间: 2013.5.28
--作者: sjt
---------------------------------------------------

MsgBattleCity = {}
local p = MsgBattleCity;

--玩家活动类型
p.ActionType =
{
    ActionGetCityInfo = 0, 		--//获取城市信息
	ActionGetBattleHistory = 1,		--//获取历史记录
	ActionEnterList = 2,			--//进入防御或者进攻列表
	ActionLeaveList = 3,			--//离开列表
	ActionAttack = 4,				--//攻击对方
	ActionGetEncourageInfo = 5,		--//获取鼓舞信息
	ActionEncourage = 6,			--//鼓舞
	ActionResetEncourageByGold = 7,	--//重置鼓舞
	ActionUnlockEncourage = 8,		--//解锁鼓舞
	ActionResetDebuff = 9,			--//重置debuff
	ActionGetStorageInfo = 10,		--//获取争夺战仓库信息
	ActionGetStorage = 11,			--//获取争夺战仓库中的资源,参数1设置表示0:money,1:宝石,2:神马鞭
	ActionLeave = 12,				--//离开活动
}; 
local ActionType = p.ActionType
local function SendActionMsg(actionType,param)
	LogInfo("BattleCity: SendActionMsg actionType=%d,param=%s", actionType,tostring(param));    
	local netdata = createNDTransData(NMSG_Type._MSG_BATTLECITY_ACTION);
    netdata:WriteByte(actionType);
	if(param~=nil)then
		netdata:WriteInt(param);
	end
	SendMsg(netdata);	
	netdata:Free();	
end

function p.GetCityInfo(city)
	SendActionMsg(ActionType.ActionGetCityInfo,city);
end

function p.GetBattleHistory(city)
	SendActionMsg(ActionType.ActionGetBattleHistory,city);
end

function p.EnterList(city)
	SendActionMsg(ActionType.ActionEnterList,city);
end

function p.LeaveList()
	SendActionMsg(ActionType.ActionLeaveList);
end

function p.Attack(target)
	SendActionMsg(ActionType.ActionAttack,target);
end

function p.GetEncourageInfo()
	SendActionMsg(ActionType.ActionGetEncourageInfo);
end

function p.Encourage(encourageID)
	SendActionMsg(ActionType.ActionEncourage,encourageID);
end

function p.ResetEncourageByGold()
	SendActionMsg(ActionType.ActionResetEncourageByGold);
end

function p.UnlockEncourage(idx)
	SendActionMsg(ActionType.ActionUnlockEncourage,idx);
end

function p.ResetDebuff()
	SendActionMsg(ActionType.ActionResetDebuff);
end

function p.GetStorageInfo()
	SendActionMsg(ActionType.ActionGetStorageInfo);
end

function p.GetStorage()
	SendActionMsg(ActionType.ActionGetStorage);
end

function p.Leave()
	SendActionMsg(ActionType.ActionLeave)
end

local function HandleBattleCityInfo(netdata)
	local cityID = netdata:ReadByte()
	local synID = netdata:ReadInt()
	local attCount = netdata:ReadShort()
	local defCount = netdata:ReadShort()
	local synname = netdata:ReadUnicodeString()
	LogInfo("BattleCity:HandleBattleCityInfo cityID=%d,synID=%d,attCount=%d,defCount=%d,synname=%s",cityID,synID,attCount,defCount,synname)
	BattleCity.HandleBattleCityInfo(cityID,synID,attCount,defCount,synname)
end

--UINT32 unAttID;
--UINT32 unDefID;
--BYTE btState;	//0输1赢2易主
--BYTE btAttSide;	//攻击方阵营,1驻守,2攻击
--attname
--defname
historys = {}	
local function HandleBattleCityHistory(netdata)
	local cityID = netdata:ReadByte()
	local count = netdata:ReadShort()
	local flag = netdata:ReadByte()
	if(flag==0 or flag==3)then
		historys = {}
	end
	for i=1,count,1 do
		local attID = netdata:ReadInt()
		local defID = netdata:ReadInt()
		local state = netdata:ReadByte()
		local side = netdata:ReadByte()
		local rectime = netdata:ReadInt()
		local attname = netdata:ReadUnicodeString()
		local defname = netdata:ReadUnicodeString()
		local synname = netdata:ReadUnicodeString()
		one = {}
		one.attID = attID
		one.defID = defID
		one.state = state
		one.side = side
		one.attname = attname
		one.defname = defname
		one.synname = synname
		one.rectime = rectime
		table.insert(historys,one)
	end
	if(flag==2 or flag==3)then
		LogInfo("BattleCity:HandleBattleCityHistory cityID=%d,historys=%d",cityID,#historys)
		BattleCity.HandleBattleCityHistory(cityID,historys)
	end
end

--参与攻城略地的玩家信息
local function HandleBattleCityPlayerInfo(netdata)
	local cityID = netdata:ReadByte()
	local side = netdata:ReadByte()
	local encourageID = netdata:ReadShort()
	local encourageLevel = netdata:ReadShort()
	local debufferTime = netdata:ReadInt()
	local synID = netdata:ReadInt()
	local debufferCanReset = netdata:ReadByte()
	local hasCdTimes = netdata:ReadInt();  --已经清除CD的次数
    LogInfo("BattleCity:HandleBattleCityPlayerInfo cityID=%d,side=%d,encourageID=%d,debufferTime=%d,synID=%d,debufferCanReset=%d",
		cityID,side,encourageID,debufferTime,synID,debufferCanReset);
	BattleCity.HandleBattleCityPlayerInfo(cityID,side,encourageID,encourageLevel,debufferTime,synID,debufferCanReset, hasCdTimes)
end






local function HandleBattleCityBattleInfo(netdata)
	local cityID = netdata:ReadByte()
	local defValue = netdata:ReadInt()
	local weak = netdata:ReadInt()
	LogInfo("BattleCity:HandleBattleCityBattleInfo cityID=%d,defValue=%d,weak=%d",cityID,defValue,weak)
	BattleCity.HandleBattleCityBattleInfo(cityID,defValue,weak)
end

--playerid
--level
--name
players = {}
local function HandleBattleCityPlayerList(netdata)
	local cityID = netdata:ReadByte()
	local side = netdata:ReadByte()
	local count = netdata:ReadShort()
	local flag = netdata:ReadByte()
	if(flag==0 or flag==3)then
		players = {}
	end
	for i=1,count,1 do
		local playerID = netdata:ReadInt()
		local level = netdata:ReadShort()
		local name = netdata:ReadUnicodeString()
		one = {}
		one.playerID = playerID
		one.level = level
		one.name = name
		table.insert(players,one)
	end
	if(flag==2 or flag==3)then
		LogInfo("BattleCity:HandleBattleCityPlayerList cityID=%d,side=%d,players=%d",cityID,side,#players)
		BattleCity.HandleBattleCityPlayerList(cityID,side,players)
	end
end

local function HandleBattleCityChangePlayerList(netdata)
	local cityID = netdata:ReadByte()
	local change = netdata:ReadByte()
	local playerID = netdata:ReadInt()
	local level = netdata:ReadShort()
	local name = netdata:ReadUnicodeString()
	LogInfo("BattleCity:HandleBattleCityChangePlayerList cityID=%d,change=%d,playerID=%d,level=%d,name=%s",cityID,change,playerID,level,name);
	BattleCity.HandleBattleCityChangePlayerList(cityID,change,playerID,level,name)
end

local function HandleBattleCityEncourageInfo(netdata)
	local encourages = {}
    local leftResetCount = netdata:ReadShort()
	for i=1,5,1 do
		table.insert(encourages,{netdata:ReadShort(),0})
	end
	for i=1,5,1 do
		encourages[i][2] = netdata:ReadShort()
	end
	LogInfo("BattleCity:HandleBattleCityEncourageInfo encourages={(%d,%d),(%d,%d),(%d,%d),(%d,%d),(%d,%d)}",
		encourages[1][1],encourages[1][2],encourages[2][1],encourages[2][2],
		encourages[3][1],encourages[3][2],encourages[4][1],encourages[4][2],
		encourages[5][1],encourages[5][2])
	BattleCity.HandleBattleCityEncourageInfo(leftResetCount,encourages)
end

local function HandleBattleCityStorageInfo(netdata)
	local money = netdata:ReadInt()
	local stone = netdata:ReadInt()
	local shenma = netdata:ReadInt()
	LogInfo("BattleCity:HandleBattleCityStorageInfo money=%d,stone=%d,shenma=%d",money,stone,shenma);
	BattleCity.HandleBattleCityStorageInfo(money,stone,shenma)
end

local function HandleBattleCityActionRet(netdata)
	local action = netdata:ReadByte()
	local ret = netdata:ReadInt()
	LogInfo("BattleCity:HandleBattleCityActionRet action=%d,ret=%d",action,ret);
	BattleCity.HandleBattleCityActionRet(action,ret)
end

--接收地图信息
local function HandleBattleCityMapInfo(netdata)
	local count = netdata:ReadByte()
    local leftResetTime = netdata:ReadInt()
	local citys = {}
	for i=1,count,1 do
		local cityID = netdata:ReadByte()
		local synID = netdata:ReadInt()
		local protectTime = netdata:ReadInt()
		local cityName = netdata:ReadUnicodeString()
		local synName = netdata:ReadUnicodeString()
		local city = {}
		city.cityID = cityID
		city.synID = synID
		city.protectTime = protectTime
		city.cityName = cityName
		city.synName = synName
		citys[city.cityID] = city
	end
	LogInfo("HandleBattleCityMapInfo citys=%d",#citys)
	BattleCity.HandleBattleCityMapInfo(leftResetTime,citys)
end

local function ProcessBattleWeakInfo(netdata)
	local nAttWeak = netdata:ReadByte();
	local nDefWeak = netdata:ReadByte();
	
	local nPerWeak = netdata:ReadByte();
	local nDefPerWeak = netdata:ReadByte();
    local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end	
    LogInfo("BattleCity:ProcessBattleWeakInfo,nAttWeak=%d,nDefWeak=%d",nAttWeak,nDefWeak)
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleUI_Title);	
	BattleUI_Title.SetFightersLevel( layer, nAttWeak + nPerWeak, nDefWeak + nDefPerWeak);
end


--注册信息接收消息
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_CITYINFO,  "HandleBattleCityInfo", HandleBattleCityInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_HISTORY,  "HandleBattleCityHistory", HandleBattleCityHistory);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_PLAYERINFO,  "HandleBattleCityPlayerInfo", HandleBattleCityPlayerInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_BATTLEINFO,  "HandleBattleCityBattleInfo", HandleBattleCityBattleInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_PLAYERLIST,  "HandleBattleCityPlayerList", HandleBattleCityPlayerList);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_CHANGEPLAYERLIST,  "HandleBattleCityChangePlayerList", HandleBattleCityChangePlayerList);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_ENCOURAGEINFO,  "HandleBattleCityEncourageInfo", HandleBattleCityEncourageInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_STORAGEINFO,  "HandleBattleCityStorageInfo", HandleBattleCityStorageInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_ACTION_RET,  "HandleBattleCityActionRet", HandleBattleCityActionRet);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_MAPINFO, "HandleBattleCityMapInfo", HandleBattleCityMapInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_WEAKINFO, "ProcessBattleWeakInfo", ProcessBattleWeakInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BATTLECITY_PLAYERWEAKINFO, "HandleBattleCityPlayerWeakInfo", HandleBattleCityPlayerWeakInfo);
