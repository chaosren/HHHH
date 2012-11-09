-----------------------------------------------------描述: 玩家任务网络消息处理及其逻辑--时间: 2012.2.23--作者: jhzheng---------------------------------------------------MsgPlayerTask = {}local p = MsgPlayerTask;local TASK_DATA_ACTION_INVALID								= 0;local TASK_DATA_ACTION_UPDATE_CLIENT_TASK_LIST				= 1; --更新用户任务列表local TASK_DATA_ACTION_UPDATE_CLIENT_CANACCEPT_TASK_LIST	= 2; --更新可接列表local TASK_ACTION_INVALID									= 0;local TASK_ACTION_CLIENT_COMMIT								= 1; --客户端请求完成任务local TASK_ACTION_CLIENT_ACCEPT								= 2; --客户端请求接收任务local TASK_ACTION_CLIENT_DELETE								= 3; --客户端请求删除任务local TASK_ACTION_SERVER_COMMIT_SUCC						= 4; --服务端通知客户端任务完成处理成功local TASK_ACTION_SERVER_ACCEPT_SUCC						= 5; --服务端通知客户端任务接受处理成功		local TASK_ACTION_SERVER_DEL_SUCC							= 6; --服务端通知客户端任务放放弃处理成功		local TASK_ACTION_CLIENT_COMMIT_TEST							= 7; --客户端请求完成任务local IfDataReady = false;function p.SetDataReady()	IfDataReady = true;endfunction p.ResetDataReady()    LogInfo("p.ProcessTaskDataAction ResetDataReady");	IfDataReady = false;endfunction p.GetDataReady()	return IfDataReady;end-- 网络消息处理(更新任务数据)function p.ProcessTaskDataAction(netdata)	local btTaskAction			= ConvertN(netdata:ReadByte());	local btCount				= ConvertN(netdata:ReadByte());	if btTaskAction == TASK_DATA_ACTION_UPDATE_CLIENT_TASK_LIST then		--更新用户任务列表		LogInfo("p.ProcessTaskDataAction update task accept list count[%d]:", btCount);		TASK.DelGameData();		for	i=1, btCount do			local nTaskId		= ConvertN(netdata:ReadInt());			local nStateState	= ConvertN(netdata:ReadByte());			local data1			= ConvertN(netdata:ReadShort());			local data2			= ConvertN(netdata:ReadShort());			local data3			= ConvertN(netdata:ReadShort());			local data4			= ConvertN(netdata:ReadShort());			local data5			= ConvertN(netdata:ReadShort());			local data6			= ConvertN(netdata:ReadShort());						LogInfo("p.ProcessTaskDataAction  [%d][%d][%d][%d][%d][%d][%d][%d]", nTaskId,						nStateState, data1, data2, data3, data4,						data5, data6);			TASK.CreateTask(nTaskId,nStateState,					data1, data2,					data3, data4,					data5, data6				);			--[[						LogInfo(" [%d]", nTaskId);			TASK.SetGameDataN(nTaskId, TASK_DATA.ID, nTaskId);			TASK.SetGameDataN(nTaskId, TASK_DATA.TASK_STATE, ConvertN(netdata:ReadShort()));			TASK.SetGameDataN(nTaskId, TASK_DATA.DATA1, ConvertN(netdata:ReadShort()));			TASK.SetGameDataN(nTaskId, TASK_DATA.DATA2, ConvertN(netdata:ReadShort()));			TASK.SetGameDataN(nTaskId, TASK_DATA.DATA3, ConvertN(netdata:ReadShort()));			TASK.SetGameDataN(nTaskId, TASK_DATA.DATA4, ConvertN(netdata:ReadShort()));			TASK.SetGameDataN(nTaskId, TASK_DATA.DATA5, ConvertN(netdata:ReadShort()));			TASK.SetGameDataN(nTaskId, TASK_DATA.DATA6, ConvertN(netdata:ReadShort())); --]]		end		if IsUIShow(NMAINSCENECHILDTAG.PlayerTask) then			-- 玩家任务界面处理显示状态			TaskUI.RefreshTaskList(true);		end				--if IsUIShow(NMAINSCENECHILDTAG.MainUITop) then			-- 主界面任务跟踪					--end					elseif btTaskAction == TASK_DATA_ACTION_UPDATE_CLIENT_CANACCEPT_TASK_LIST then		--更新可接列表			LogInfo("qbw 99 p.ProcessTaskDataAction update task unaccept list count[%d]:", btCount);		TASK.ClearCanAcceptTasks();		for i=1, btCount do			local nId = ConvertN(netdata:ReadInt());			TASK.AddCanAcceptTask(nId);			LogInfo("p.ProcessTaskDataAction TASK.AddCanAcceptTask [%d]", nId);		end				--数据更新标识        LogInfo("p.ProcessTaskDataAction TASK.SetDataReady");		p.SetDataReady();						if IsUIShow(NMAINSCENECHILDTAG.PlayerTask) then			-- 玩家任务界面处理显示状态			TaskUI.RefreshTaskList(false);		end					end		TASK.TaskStateRefresh();	return 1;end-- 任务交互function p.ProcessTaskAction(netdata)	local btTaskAction			= ConvertN(netdata:ReadByte());	local nTaskId				= ConvertN(netdata:ReadInt());	LogInfo("任务交互[%d][%d]", btTaskAction, nTaskId);		LogInfo("qbw 99 p.ProcessTaskAction");	CloseLoadBar();	--提交任务提示	if  btTaskAction == TASK_ACTION_SERVER_COMMIT_SUCC then		local playerid = GetPlayerId();		ChatDataFunc.AddChatRecord(playerid,5,0,"",TaskUI.GetTaskPrizeContent(nTaskId));		--成功音效       		Music.PlayEffectSound(Music.SoundEffect.FINISH_TASK);   		   		   		--动画提示   		local tContentTable = TaskUI.GetTaskPrizeContentTable(nTaskId);           		local tParam = {}   		for i,v in ipairs(tContentTable) do   			if v ~= "" then   				table.insert(tParam,{v,FontColor.Text});   				   			end		end						CommonDlgNew.ShowTipsDlg(tParam);	end			if  btTaskAction == TASK_ACTION_SERVER_COMMIT_SUCC  or		btTaskAction == TASK_ACTION_SERVER_DEL_SUCC then		LogInfo("recv finish task notify");		 --服务端通知客户端任务完成处理成功		 --删除任务		 TASK.DelTaskData(nTaskId);		 if IsUIShow(NMAINSCENECHILDTAG.PlayerTask) then			-- 玩家任务界面处理显示状态			TaskUI.DelAcceptTask(true,nTaskId );		end						CloseLoadBar();	elseif btTaskAction == TASK_ACTION_SERVER_ACCEPT_SUCC then		LogInfo("recv accept task notify");		 --服务端通知客户端任务接受处理成功		 TASK.CreateTask(nTaskId, TASK.SM_TASK_STATE.STATE_UNCOMPLETE, 					0, 0, 0, 0, 0, 0				);		 if IsUIShow(NMAINSCENECHILDTAG.PlayerTask) then			-- 玩家任务界面处理显示状态			TaskUI.AddTask(true, nTaskId);		end				--剧情播放		Drama.OnBeginTask(nTaskId)				--成功音效       		Music.PlayEffectSound(Music.SoundEffect.RECEIVE_TASK);   				--系统提示		local playerid = GetPlayerId();		ChatDataFunc.AddChatRecord(playerid,5,0,"","您成功接受任务:"..TASK.GetTaskName(nTaskId));		CloseLoadBar();	end			TASK.TaskStateRefresh();		return 1;endfunction p.SendTaskAction(nTaskId, nAction)	if not CheckN(nTaskId) or not CheckN(nAction) then		return false;	end	if nTaskId <= 0 then		return false;	end	local netdata = createNDTransData(NMSG_Type._MSG_TASK_ACTION);	if nil == netdata then		return false;	end		ShowLoadBar();	netdata:WriteByte(nAction);	netdata:WriteInt(nTaskId);	SendMsg(netdata);	netdata:Free();	LogInfo("send task[%d] action[%d]", nTaskId, nAction);	return true;end--发送任务条件数据function p.SendTaskCondition(nTaskId,nGuideType,nGuideParam)	if not CheckN(nTaskId)then		return false;	end	if nTaskId <= 0 then		return false;	end	local netdata = createNDTransData(NMSG_Type._MSG_TASK_CONDITION);	if nil == netdata then		return false;	end	netdata:WriteByte(1);	netdata:WriteInt(nTaskId);	netdata:WriteInt(nGuideType);	netdata:WriteInt(nGuideParam);		SendMsg(netdata);	netdata:Free();	LogInfo("NMSG_Type._MSG_TASK_CONDITION:"..NMSG_Type._MSG_TASK_CONDITION);	LogInfo("send task[%d] action nGuideType[%d] nGuideParam[%d]", nTaskId,nGuideType,nGuideParam);	return true;endfunction p.ProccessTaskCondition(netdata)	local btTaskAction			= ConvertN(netdata:ReadByte());	local nTaskId		= ConvertN(netdata:ReadInt());	local nParam1		= ConvertN(netdata:ReadInt());	local nParam2		= ConvertN(netdata:ReadInt());	 	--引导任务事件触发	GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,nParam1,nParam2);endfunction p.SendCompleteTask(nTaskId)    --剧情动画    Drama.OnFinishTask(nTaskId)    	return p.SendTaskAction(nTaskId, TASK_ACTION_CLIENT_COMMIT);endfunction p.SendCompleteTask_TEST(nTaskId)		LogInfo("QBW1: FINISH TASK TEST :"..nTaskId)	return p.SendTaskAction(nTaskId, TASK_ACTION_CLIENT_COMMIT_TEST);endfunction p.SendAcceptTask(nTaskId)	return p.SendTaskAction(nTaskId, TASK_ACTION_CLIENT_ACCEPT);endfunction p.SendDelTask(nTaskId)	return p.SendTaskAction(nTaskId, TASK_ACTION_CLIENT_DELETE);end_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGIN_GAME, "p.ResetDataReady", p.ResetDataReady);RegisterNetMsgHandler(NMSG_Type._MSG_TASK_ACTION, "p.ProcessTaskAction", p.ProcessTaskAction);RegisterNetMsgHandler(NMSG_Type._MSG_TASK_DATA_ACTION, "p.ProcessTaskDataAction", p.ProcessTaskDataAction);RegisterNetMsgHandler(NMSG_Type._MSG_TASK_CONDITION, "p.ProcessTaskDataAction", p.ProccessTaskCondition);