---------------------------------------------------
--描述: 每日活动相关消息
--时间: 2012.10.8
--作者: tzq
---------------------------------------------------

MsgDailyAction = {}
local p = MsgDailyAction;


p.tbActionListInfo = {};

--活动列表(服务器下发)     
function p.MsgReciveDailyAcionInfo(netdatas)
    
    local actionType = netdatas:ReadByte();  --1:add  2:update   1的话为清空后更新  2为更新
    local nAmount = netdatas:ReadByte();  --活动数量 
    
    if actionType == 1 then
        DailyAction.TimerActions = {};    --定時活動活动信息
        DailyAction.DailyActions = {};     --每日活动信息  
    end
    
    --获取所有要更新的信息
    for i = 1, nAmount do
        local record = {};
        local tbInfos = {};
        
        record.nId = netdatas:ReadInt();                      --玩家id
        record.bStatus = netdatas:ReadByte();          --状态 0:结束  3:开启
        
        local nGroup = GetDataBaseDataN("event_activity", record.nId, DB_EVENT_ACTIVITY.GROUP);    
        
        --全天活动
        if nGroup == 1 then
            tbInfos = DailyAction.DailyActions;
        --定時活動 9.12改註釋
        elseif  nGroup == 2 then
            tbInfos = DailyAction.TimerActions;
        end
        
        if actionType == 1 then
            table.insert(tbInfos, record);
        else
            local bHasFind = false;
            for j, v in pairs(tbInfos) do
                if record.nId == v.nId then
                    tbInfos[j] = record;
                    bHasFind = true;
                    break;
                end
            end
            
            if not bHasFind then
                table.insert(tbInfos, record);
            end
        end
        
		--过关斩将 并刷新显示提示按钮
		if record.nId == 14  then
			if record.bStatus == 3 then
				--开启，则获取剩余次数
				--MsgBloodBattle.SendMsgLeftTimes();
				MsgBloodBattle.DailyActionUpdate(true);
			else
				--关闭,
				MsgBloodBattle.DailyActionUpdate(false);
				
			end	
		end
		
     
    end
    
    table.sort(DailyAction.TimerActions, function(a,b) return a.nId < b.nId   end);
    table.sort(DailyAction.DailyActions, function(a,b) return a.nId < b.nId   end);    

    if IsUIShow(NMAINSCENECHILDTAG.DailyActionUI) then
       --刷新活动页面
       DailyAction.RefreshUI(DailyAction.CurFocusBtnId);
    end    
	
	MainUI.RefreshFuncIsOpen();
end


--请求获取活动列表消息
function p.MsgSendGetActionListInfo()  
	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_LIST);
	SendMsg(netdata);	
	netdata:Free();	
	return true;	
end


--注册消息获取玩家活动信息
RegisterNetMsgHandler(NMSG_Type._MSG_PLAYER_ACTION_LIST,  "p.MsgReciveDailyAcionInfo", p.MsgReciveDailyAcionInfo);
