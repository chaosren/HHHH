---------------------------------------------------
--描述: 7x7游戏消息处理及其逻辑
--时间: 2013.5.13
--作者: sjt
---------------------------------------------------

Msg7x7 = {}

local p = Msg7x7

p.ActionType = {
		ActionMove = 0,
        ActionFinish = 1,
        ActionOpen = 2,
        ActionGetScoreBoard = 3,
        }
local ActionType = p.ActionType

function p.SendGetScoreBoard()
   local netdata = createNDTransData(NMSG_Type._MSG_7x7_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(ActionType.ActionGetScoreBoard);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("SendGetScoreBoard");

	return true; 
end

function p.SendFinish()
    local netdata = createNDTransData(NMSG_Type._MSG_7x7_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(ActionType.ActionFinish);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("SendFinish");

	return true;
end

local function IdxCliToSer(idx)
    return idx-1
end

function p.SendMove(path)
    local netdata = createNDTransData(NMSG_Type._MSG_7x7_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(ActionType.ActionMove);
    netdata:WriteByte(#path)
    for i=1,#path do
        netdata:WriteByte(IdxCliToSer(path[i]))
    end
	SendMsg(netdata);
	netdata:Free();
	LogInfo("SendMove");

	return true;
end

function p.SendOpen()
    local netdata = createNDTransData(NMSG_Type._MSG_7x7_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(ActionType.ActionOpen);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("SendFinish");

	return true;
end

local function Process7x7ActionRet(netdata)
    local idUser = GetPlayerId();
	local action = netdata:ReadByte();
    local ret = netdata:ReadByte();
    LogInfo("7x7ActionRet,action=%d,ret=%d",action,ret)
    SG7x7.DoActionRet(action,ret)
end

local function Process7x7Delete(netdata)
    local score = netdata:ReadInt()
    local combo = netdata:ReadByte()
    local count = netdata:ReadByte()
    local idxs = {}
    for i=1,count do
        idx = netdata:ReadByte()
        table.insert(idxs,idx)
    end
    LogInfo("7x7Delete,score=%d,combo=%d,count=%d",score,combo,count)
    SG7x7.DoDelete(score,combo,idxs)
end

local function Process7x7Add(netdata)
    local idx = netdata:ReadByte()
    local color = netdata:ReadByte()
    LogInfo("7x7Add,idx=%d,color=%d",idx,color)
    SG7x7.DoAdd(idx,color)
end

local function Process7x7Next(netdata)
    local count = netdata:ReadByte()
    local nexts = {}
    for i=1,count do
        color = netdata:ReadByte()
        table.insert(nexts,color)
    end
    LogInfo("7x7Next,count=%d",count)
    SG7x7.DoNext(nexts)
end

local function Process7x7Finish(netdata)
    local score = netdata:ReadInt()
    LogInfo("7x7Finish,score=%d",score)
    SG7x7.DoFinish(score)
end

local function Process7x7Begin(netdata)
    local score = netdata:ReadInt()
    local level = netdata:ReadByte()
    local combo = netdata:ReadByte()
    local count = netdata:ReadByte()
    local nextCount = netdata:ReadByte()
    local paneldata = {}
    local nextdata = {}
    for i=1,count do
        local idx = netdata:ReadByte()
        local color = netdata:ReadByte()
        table.insert(paneldata,{idx,color})
    end
    for i=1,nextCount do
        table.insert(nextdata,netdata:ReadByte())
    end
    LogInfo("7x7Begin,datacount=%d,nextcount=%d",count,nextCount)
    SG7x7.DoBegin(score,level,combo,paneldata,nextdata)
end

local function Process7x7ScoreBoard(netdata)
    local flag = netdata:ReadByte()
    local count = netdata:ReadByte()
    if(flag==0 or flag==3)then
        SG7x7Board.ClearBoard()
    end
    local ranks = {}
    for i=1,count do
        local id = netdata:ReadInt()
        local score = netdata:ReadInt()
        local name = netdata:ReadUnicodeString()
        --增加一条
        local rank = {}
        rank.id = id
        rank.score = score
        rank.name = name
        table.insert(ranks,rank)
    end
    LogInfo("Process7x7ScoreBoard:receive %d rands",#ranks)
    SG7x7Board.SetBoard(ranks)
end

local function Process7x7UpdateLevel(netdata)
    local level = netdata:ReadByte()
    LogInfo("game7x7:Process7x7UpdateLevel,level=%d",level)
    SG7x7.UpdateLevel(level)
end

local function Process7x7UpdateCombo(netdata)
    local combo = netdata:ReadByte()
    LogInfo("Game7x7:Process7x7UpdateCombo,combo=%d",combo)
    SG7x7.UpdateCombo(combo)
end

RegisterNetMsgHandler(NMSG_Type._MSG_7x7_ACTION_RET,"Process7x7ActionRet",Process7x7ActionRet)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_DELETE,"Process7x7Delete",Process7x7Delete)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_ADD,"Process7x7Add",Process7x7Add)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_NEXT,"Process7x7Next",Process7x7Next)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_FINISH,"Process7x7Finish",Process7x7Finish)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_BEGIN,"Process7x7Begin",Process7x7Begin)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_SCOREBOARD,"Process7x7ScoreBoard",Process7x7ScoreBoard)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_UPDATELEVEL,"Process7x7UpdateLevel",Process7x7UpdateLevel)
RegisterNetMsgHandler(NMSG_Type._MSG_7x7_UPDATECOMBO,"Process7x7UpdateCombo",Process7x7UpdateCombo)
