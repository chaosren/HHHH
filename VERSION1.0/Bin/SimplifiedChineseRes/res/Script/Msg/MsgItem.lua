-----------------------------------------------------描述: 玩家任务网络消息处理及其逻辑--时间: 2012.3.1--作者: jhzheng---------------------------------------------------MsgItem = {}local p = MsgItem;local MSG_ITEM_ACT_NONE						= 0;local MSG_ITEM_ACT_USE						= 1;local MSG_ITEM_ACT_DROP						= 2;local MSG_ITEM_ACT_QUERY_ITEMINFO			= 3;local MSG_ITEM_ACT_LOAD_EQUIP				= 4;local MSG_ITEM_ACT_UNLOAD_EQUIP				= 5;local MSG_ITEM_ACT_LOAD_PARTS				= 6;local MSG_ITEM_ACT_UNLOAD_PARTS				= 7;local MSG_ITEM_ACT_LOAD_DAO_FA				= 8;local MSG_ITEM_ACT_UNLOAD_DAO_FA			= 9;local MSG_ITEM_ACT_EXCHANGE_EQUIP           = 10;local MSG_ITEM_ACT_EXCHANGE_EQUIP_OK        = 11;local MSG_ITEM_ACT_END						= 12;--发送删除物品消息function p.SendDelItem(nItemId)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_DROP);end--发送使用物品消息function p.SendUseItem(nItemId,nNum,nPetId, szName)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_USE, nPetId, nNum, szName);end--发送穿装备消息function p.SendPackEquip(nItemId, weapId)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_LOAD_EQUIP, weapId);end--发送装备器灵消息function p.SendLoadSpirit(nItemId, weapId)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_LOAD_PARTS, weapId);end--发送脱器灵消息function p.SendUnLoadSpirit(nItemId, nPetId)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_UNLOAD_PARTS, nPetId);end--发送脱装备消息function p.SendUnPackEquip(nPetId, nItemId)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_UNLOAD_EQUIP, nPetId);end--发送穿daofa消息function p.SendPackDaoFa(nItemId, nPetId, nPosition)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_LOAD_DAO_FA, nPetId, nPosition);end--发送脱daofa消息function p.SendUnDaoFa(nPetId, nItemId)	return p.SendItemAction(nItemId, MSG_ITEM_ACT_UNLOAD_DAO_FA, nPetId);endfunction p.SendExchangeEquip(nPetId1, nPetId2)    return p.SendItemAction(nPetId1, MSG_ITEM_ACT_EXCHANGE_EQUIP, nPetId2);end-- 网络消息处理物品操作function p.ProcessItemAction(netdata)	LogInfo("p.ProcessItemAction(netdata)");		local btAction						= netdata:ReadByte();	local idItem						= netdata:ReadInt();	local idActOwner					= netdata:ReadInt();	local nData							= netdata:ReadInt();	    LogInfo("p.ProcessItemAction btAction:[%d],idItem:[%d],idActOwner:[%d],nData:[%d]",btAction,idItem,idActOwner,nData);    	if btAction == MSG_ITEM_ACT_DROP then		if nData <= 0 then			return;		end                local tips = {};        		for i = 1, nData do			local nItemId				= netdata:ReadInt();			if Item.IsExistItem(nItemId) then				LogInfo(" del item[%d]", nItemId);				local nPostion = Item.GetItemInfoN(nItemId, Item.ITEM_POSITION);				LogInfo("position[%d]", nPostion);				if nPostion == Item.POSITION_PACK then                    -- 删除玩家背包中的物品                    ItemUser.DelBagItem(GetPlayerId(), nItemId);                    if IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then                        PlayerUIBackBag.DelItem(idItem);                    end                                        elseif nPostion == Item.POSITION_DAO_FA_PACK then                                        LogInfo("chh_Item.POSITION_DAO_FA_PACK:p:[%d],item:[%d]",GetPlayerId(), nItemId);                    -- 删除玩家背包中的占星物品                    ItemUser.DelDaoFaItem(GetPlayerId(), nItemId);                    if IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then                        DestinyUI.DelItem(idItem);                    end                    				end				Item.DelItemInfo(nItemId);				-- 全局事件通知				GlobalEvent.OnEvent(GLOBALEVENT.GE_ITEM_UPDATE);			else				LogInfo(" del item[%d] not exist", nItemId);			end		end            elseif(btAction == MSG_ITEM_ACT_LOAD_EQUIP or btAction == MSG_ITEM_ACT_UNLOAD_EQUIP or btAction == MSG_ITEM_ACT_LOAD_DAO_FA or btAction == MSG_ITEM_ACT_UNLOAD_DAO_FA or btAction == MSG_ITEM_ACT_EXCHANGE_EQUIP_OK) then        CloseLoadBar();                --换装成功提示        if(btAction == MSG_ITEM_ACT_EXCHANGE_EQUIP_OK) then            if (p.mUIListener) then                p.mUIListener( NMSG_Type._MSG_ITEM_ACTION, btAction );            end        end	endend-- 网络消息处理(物品信息数据更新)function p.ProcessItemAttrib(netdata)	local idItem					= netdata:ReadInt();	-- Id	local nDataIndex				= netdata:ReadInt();	-- 数据索引	local nData						= netdata:ReadInt();	-- 数据	--物品是否存在	if not Item.IsExistItem(idItem) then		LogInfo("p.ProcessItemAttrib, not Item.IsExistItem[%d]", idItem);		return true;	end		if nDataIndex >= Item.ITEM_BEGIN and nDataIndex < Item.ITEM_END then		LogInfo("p.ProcessItemAttrib item[%d] attr[%d] val[%d]", idItem, nDataIndex, nData);				if nDataIndex == DB_ITEM.AMOUNT then			Item.SetItemInfoN(idItem, Item.ITEM_AMOUNT, nData);		elseif nDataIndex == DB_ITEM.OWNERTYPE then		elseif nDataIndex == DB_ITEM.POSITION then		elseif nDataIndex == DB_ITEM.OWNER_ID then		elseif nDataIndex == DB_ITEM.PLAYER_ID then		elseif nDataIndex == DB_ITEM.ADDITION then			Item.SetItemInfoN(idItem, Item.ITEM_ADDITION, nData);		elseif nDataIndex == DB_ITEM.ITEM_EXP then			Item.SetItemInfoN(idItem, Item.ITEM_EXP, nData);		end				GameDataEvent.OnEvent(GAMEDATAEVENT.ITEMATTR, {[1]=nDataIndex, [2]=nData, [3]=idItem});	end		-- 全局事件通知	--LogInfo("p.ProcessItemAttrib item");	GlobalEvent.OnEvent(GLOBALEVENT.GE_ITEM_UPDATE);		return true;end-- 网络消息处理(物品信息数据)function p.ProcessItemInfo(netdata)		local btItemAmount				= netdata:ReadByte(); --物品数量	--LogInfo("p.ProcessItemInfo item amount[%d]", btItemAmount);	for i = 1, btItemAmount do			local idItem					= netdata:ReadInt();	-- Id		local idType					= netdata:ReadInt();	-- 类型		local btOwnerType				= netdata:ReadByte(); -- 所有者类型		local idOwner					= netdata:ReadInt(); -- 所有者id		local idPlayer					= netdata:ReadInt(); -- 玩家id		local usAmount					= netdata:ReadShort();				-- 数量		local usPosition				= netdata:ReadShort(); -- 位置		local usAddition				= netdata:ReadShort(); -- 强化等级		local unExp						= netdata:ReadInt(); -- 道法经验		local btAttrAmount				= netdata:ReadByte(); -- 属性数量		local bGenCount               = netdata:ReadByte(); -- 宝石数量		local bHoleOpen               = netdata:ReadByte(); -- 开洞情况  0未开洞,1开一洞,3开两洞--[[  		LogInfo("idItem [%d] ", idItem);		LogInfo("idType [%d ]", idType);		LogInfo("btOwnerType [%d] ", btOwnerType);		LogInfo("idOwner [%d] ", idOwner);		LogInfo("idPlayer [%d] ", idPlayer);		LogInfo("usAmount [%d] ", usAmount);		LogInfo("usPosition [%d] ", usPosition);		LogInfo("usAddition [%d] ", usAddition);		LogInfo("unExp [%d] ", unExp);		LogInfo("btAttrAmount [%d] ", btAttrAmount);        LogInfo("bGenCount [%d] ", bGenCount);]]				if idItem <= 0 then			return 1;		end				--物品是否已存在		local oldPositon	= 0;		local oldOwnerId	= 0;		local oldOwnerType	= 0;		local oldPlayerId	= 0;				local bIsItemExist	= Item.IsExistItem(idItem);		if not bIsItemExist then			LogInfo("p.ProcessItemInfo item[%d]not exist", idItem);		end		if (bIsItemExist) then            LogInfo("p.ProcessItemInfo item[%d] exist", idItem);            			oldPositon		= ConvertN(Item.GetItemInfoN(idItem, Item.ITEM_POSITION));			oldOwnerId		= ConvertN(Item.GetItemInfoN(idItem, Item.ITEM_OWNER_ID));			oldPlayerId		= ConvertN(Item.GetItemInfoN(idItem, Item.ITEM_USER_ID));			oldOwnerType	= ConvertN(Item.GetItemInfoN(idItem, Item.ITEM_OWNERTYPE));                        if(usPosition == oldPositon) then                if Num8(idType) == 0 and Num7(idType) == 1 then                    LogInfo("p.ProcessItemInfo equip:[%d]",idItem);                    ItemPet.DelEquipItem(idPlayer, oldOwnerId, idItem);                    ItemPet.AddEquipItem(idPlayer, idOwner, idItem);                end                if Num8(idType) == 0 and Num7(idType) == 3 then                    LogInfo("p.ProcessItemInfo destiny:[%d]",idItem);                    ItemPet.DelDaoFaItem(idPlayer, oldOwnerId, idItem);                    ItemPet.AddDaoFaItem(idPlayer, idOwner, idItem);                end            end            		end				Item.SetItemInfoN(idItem, Item.ITEM_ID, idItem);		Item.SetItemInfoN(idItem, Item.ITEM_TYPE, idType);		Item.SetItemInfoN(idItem, Item.ITEM_OWNERTYPE, btOwnerType);		Item.SetItemInfoN(idItem, Item.ITEM_OWNER_ID, idOwner);		Item.SetItemInfoN(idItem, Item.ITEM_USER_ID, idPlayer);		Item.SetItemInfoN(idItem, Item.ITEM_AMOUNT, usAmount);		Item.SetItemInfoN(idItem, Item.ITEM_POSITION, usPosition);		Item.SetItemInfoN(idItem, Item.ITEM_ADDITION, usAddition);		Item.SetItemInfoN(idItem, Item.ITEM_EXP, unExp);		Item.SetItemInfoN(idItem, Item.ITEM_ATTR_NUM, btAttrAmount);       Item.SetItemInfoN(idItem, Item.ITEM_GEN_NUM, bGenCount);       Item.SetItemInfoN(idItem, Item.ITEM_HOLE_OPEN_FLAG, bHoleOpen);				local nAttrBegin = Item.ITEM_ATTR_BEGIN;				for i=1, btAttrAmount do			local btAttrType			= netdata:ReadByte();			-- ATTR_TYPE			local nData					= netdata:ReadInt();						LogInfo("btAttrType [%d] ", btAttrType);			LogInfo("nData [%d] ", nData);						Item.SetItemInfoN(idItem, nAttrBegin, btAttrType);			nAttrBegin	= nAttrBegin + 1;			Item.SetItemInfoN(idItem, nAttrBegin, nData);			nAttrBegin = nAttrBegin + 1;		end		                local nGenBegin = nAttrBegin;        for i=1, bGenCount do            local btGenType			= netdata:ReadInt();            Item.SetItemInfoN(idItem, nGenBegin, btGenType);            nGenBegin = nGenBegin + 1;        end        		if bIsItemExist then			if oldPositon == usPosition then				--更新物品toto				LogInfo("物品更新todo");			else				--变更物品 				p.LogicDelItem(oldPlayerId, oldOwnerId, idItem, oldPositon, oldOwnerType);				p.LogicAddItem(idPlayer, idOwner, idItem, usPosition, btOwnerType);			end		else		--物品不存在,增加物品			LogInfo("add");            p.LogicAddItem(idPlayer, idOwner, idItem, usPosition, btOwnerType);		end				GameDataEvent.OnEvent(GAMEDATAEVENT.ITEMINFO, idItem);        LogInfo("End");	end		--CloseLoadBar();		return 1;end--内部接口(物品操作)function p.LogicAddItem(idPlayer, idOwner, idItem, usPosition, nOwnerType)	if not CheckN(idPlayer) or 		not CheckN(idItem) or		not CheckN(usPosition) or		not CheckN(idOwner) or		not CheckN(nOwnerType) then		LogInfo("p.LogicAddItem invalid arg");		return;	end	LogInfo("chh_1");	local nPlayerId		= GetPlayerId();	local bSelf			= idPlayer == ConvertN(nPlayerId);		LogInfo("p.LogicAddItem idPlayer[%d]idOwner[%d]idItem[%d]usPosition[%d],nOwnerType[%d]",idPlayer, idOwner, idItem, usPosition, nOwnerType);	LogInfo("chh_2:nOwnerType:[%d]",nOwnerType);	if nOwnerType == Item.OWNER_TYPE_USER or	   nOwnerType == Item.OWNER_TYPE_NONE then		if usPosition == Item.POSITION_PACK then		--物品背包			LogInfo("msg add bag item[%d]", idItem);			ItemUser.AddBagItem(idPlayer, idItem);			if bSelf and IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then				PlayerUIBackBag.AddItem(idItem);			end		elseif usPosition == Item.POSITION_PARTS_PACK then		--器灵背包			ItemUser.AddQiLinItem(idPlayer, idItem);			if IsUIShow(NMAINSCENECHILDTAG.PlayerNimbusUI) then			  PlayerNimbusUI.AddItemToPartsBag(idItem);	        end 		elseif usPosition == Item.POSITION_DAO_FA_PACK then		--道法背包			ItemUser.AddDaoFaItem(idPlayer, idItem);            if bSelf and IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then				DestinyUI.AddItem(idItem);			end		elseif usPosition == Item.POSITION_STORAGE then		--仓库			ItemUser.AddStorageItem(idPlayer, idItem);		elseif usPosition == Item.POSITION_MAIL then		--邮件物品			ItemSystem.AddMailItem(idItem);		elseif usPosition == Item.POSITION_SOLD then		--已售物品			ItemSystem.AddSoldItem(idItem);		end	elseif nOwnerType == Item.OWNER_TYPE_PET then        LogInfo("chh_3:usPosition:[%d]",usPosition);		if usPosition >= Item.POSITION_EQUIP_1 and			usPosition <= Item.POSITION_EQUIP_6 then		--装备物品			LogInfo("add 装备物品idPlayer[%d]idOwner[%d]idItem[%d]", idPlayer, idOwner, idItem);                        --引导任务事件触发            local nItemType			= Item.GetItemInfoN(idItem, Item.ITEM_TYPE);            LogInfo("引导任务事件触发 使用物品nItemType:"..nItemType);            GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.USE_ITEM,nItemType);            			ItemPet.AddEquipItem(idPlayer, idOwner, idItem);			if bSelf and IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then				PlayerUIBackBag.AddEquip(idOwner, idItem, usPosition);			end		elseif usPosition >= Item.POSITION_DAO_FA_1 and			usPosition <= Item.POSITION_DAO_FA_8 then		--道法物品			LogInfo("add 装备物品idPlayer[%d]idOwner[%d]idItem[%d]", idPlayer, idOwner, idItem);                        --引导任务事件触发            local nItemType			= Item.GetItemInfoN(idItem, Item.ITEM_TYPE);            LogInfo("引导任务事件触发 使用物品nItemType:"..nItemType);            GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.USE_ITEM,nItemType);                        ItemPet.AddDaoFaItem(idPlayer, idOwner, idItem);            if bSelf and IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then				DestinyUI.AddEquip(idOwner, idItem, usPosition);			end		end	elseif nOwnerType == Item.OWNER_TYPE_ITEM then		if usPosition >= Item.POSITION_PARTS_1 and			usPosition <= Item.POSITION_PARTS_6 then		--器灵物品			ItemInlay.AddQiLinItem(idOwner, idItem);			if IsUIShow(NMAINSCENECHILDTAG.PlayerNimbusUI) then			  PlayerNimbusUI.AddInlayWeap(idOwner,idItem);	        end 		end	else		if usPosition == Item.POSITION_MAIL then		--邮件物品			ItemSystem.AddMailItem(idItem);		elseif usPosition == Item.POSITION_SOLD then		--已售物品			ItemSystem.AddSoldItem(idItem);		end	end		-- 全局事件通知	GlobalEvent.OnEvent(GLOBALEVENT.GE_ITEM_UPDATE);endfunction p.LogicDelItem(idPlayer, idOwner, idItem, usPosition, nOwnerType)	LogInfo("chh_p.LogicDelItem");    if not CheckN(idPlayer) or 		not CheckN(idItem) or		not CheckN(usPosition) or		not CheckN(idOwner) or		not CheckN(nOwnerType) then		LogInfo("p.LogicDelItem invalid arg");		return;	end	LogInfo("p.LogicDelItem idPlayer[%d]idOwner[%d]idItem[%d]usPosition[%d],nOwnerType[%d]",idPlayer, idOwner, idItem, usPosition, nOwnerType);        LogInfo("chh_nOwnerType:[%d]",nOwnerType);    	local nPlayerId		= GetPlayerId();	local bSelf			= idPlayer == ConvertN(nPlayerId);	if nOwnerType == Item.OWNER_TYPE_USER or 		nOwnerType == Item.OWNER_TYPE_NONE then		if usPosition == Item.POSITION_PACK then		--物品背包			ItemUser.DelBagItem(idPlayer, idItem);			LogInfo("msg del bag item[%d]", idItem);			if bSelf and IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then				PlayerUIBackBag.DelItem(idItem);			end		elseif usPosition == Item.POSITION_PARTS_PACK then		--器灵背包			ItemUser.DelQiLinItem(idPlayer, idItem);			if IsUIShow(NMAINSCENECHILDTAG.PlayerNimbusUI) then			  PlayerNimbusUI.DelItemFramePartsBag(idItem);	        end  		elseif usPosition == Item.POSITION_DAO_FA_PACK then		--道法背包			LogInfo("chh_Item.POSITION_DAO_FA_PACK:p:[%d],item:[%d]",idPlayer, idItem);            ItemUser.DelDaoFaItem(idPlayer, idItem);            if bSelf and IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then				DestinyUI.DelItem(idItem);			end		elseif usPosition == Item.POSITION_STORAGE then		--仓库			ItemUser.DelStorageItem(idPlayer, idItem);		elseif usPosition == Item.POSITION_MAIL then		--邮件物品			ItemSystem.DelMailItem(idItem);		elseif usPosition == Item.POSITION_SOLD then		--已售物品			ItemSystem.DelSoldItem(idItem);		end	elseif nOwnerType == Item.OWNER_TYPE_PET then        if usPosition >= Item.POSITION_EQUIP_1 and			usPosition <= Item.POSITION_EQUIP_6 then		--装备物品			LogInfo("del 装备物品idPlayer[%d]idOwner[%d]idItem[%d]", idPlayer, idOwner, idItem);			ItemPet.DelEquipItem(idPlayer, idOwner, idItem);			if bSelf and IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then				PlayerUIBackBag.DelEquip(idOwner, idItem, usPosition);			end		elseif usPosition >= Item.POSITION_DAO_FA_1 and			usPosition <= Item.POSITION_DAO_FA_8 then		--道法物品			ItemPet.DelDaoFaItem(idPlayer, idOwner, idItem);            if bSelf and IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then				DestinyUI.DelEquip(idOwner, idItem, usPosition);			end		end	elseif nOwnerType == Item.OWNER_TYPE_ITEM then		if usPosition >= Item.POSITION_PARTS_1 and			usPosition <= Item.POSITION_PARTS_6 then		--器灵物品			ItemInlay.DelQiLinItem(idOwner, idItem);			if IsUIShow(NMAINSCENECHILDTAG.PlayerNimbusUI) then			  PlayerNimbusUI.DelInlayWeap(idOwner,idItem);	        end  		end	else		if usPosition == Item.POSITION_MAIL then		--邮件物品			ItemSystem.DelMailItem(idItem);		elseif usPosition == Item.POSITION_SOLD then		--已售物品			ItemSystem.DelSoldItem(idItem);		end	end		-- 全局事件通知	GlobalEvent.OnEvent(GLOBALEVENT.GE_ITEM_UPDATE);		endfunction p.SendItemAction(nItemId, nAction, idActOwner, nData, szName)	if	not CheckN(nItemId) or		not CheckN(nAction) then		LogInfo("发送物品消息失败,参数不对");		return false;	end		idActOwner		= ConvertN(idActOwner);	nData			= ConvertN(nData);		if	nAction <= MSG_ITEM_ACT_NONE or 		nAction >= MSG_ITEM_ACT_END then		LogInfo("发送物品消息失败,Action不对");		return false;	end		local netdata = createNDTransData(NMSG_Type._MSG_ITEM_ACTION);	if nil == netdata then		LogInfo("发送物品消息失败,内存不够");		return false;	end	netdata:WriteByte(nAction);	netdata:WriteInt(nItemId);	netdata:WriteInt(idActOwner);	netdata:WriteInt(nData);		if szName ~= nil then		netdata:WriteStr(szName);	end		SendMsg(netdata);	netdata:Free();	LogInfo("send Item[%d] action[%d] idActOwner[%d] nData[%d]", nItemId, nAction, idActOwner, nData);	return true;endfunction p.SendShopAction(itemId, amount)    LogInfo("sendshopaction");    if	not CheckN(itemId) or		not CheckN(amount) then		LogInfo("发送物品消息失败,参数不对");		return false;	end    	local netdata = createNDTransData(NMSG_Type._MSG_SHOP);	if nil == netdata then		LogInfo("发送物品消息失败,内存不够");		return false;	end	netdata:WriteInt(itemId);    netdata:WriteInt(0);    netdata:WriteInt(4);	netdata:WriteInt(amount);	SendMsg(netdata);	netdata:Free();	return true;end--礼包使用反馈function p.ProcessGiftInfo(netdata)    LogInfo("p.ProcessGiftInfo");    local infos = {};    local nYinBi = netdata:ReadInt();    local nJinBi = netdata:ReadInt();    local nRepute = netdata:ReadInt();    local nStamina = netdata:ReadInt();    local nSoph = netdata:ReadInt();    local nExp = netdata:ReadInt();    local nSpirit = netdata:ReadInt();    local nExploits = netdata:ReadInt();            if(nYinBi>0) then        table.insert(infos,{string.format(GetTxtPub("coin").." +%d",nYinBi),FontColor.Silver});    end    if(nJinBi>0) then        table.insert(infos,{string.format(GetTxtPub("shoe").." +%d",nJinBi),FontColor.Coin});    end    if(nRepute>0) then        table.insert(infos,{string.format(GetTxtPub("ShenWan").." +%d",nRepute),FontColor.Reput});    end    if(nStamina>0) then        table.insert(infos,{string.format(GetTxtPub("Stamina").." +%d",nStamina),FontColor.Stamina});    end    if(nSoph>0) then        table.insert(infos,{string.format(GetTxtPub("JianHun").." +%d",nSoph),FontColor.Soul});    end    if(nExp>0) then        table.insert(infos,{string.format(GetTxtPub("exp").." +%d",nExp),FontColor.Exp});    end    if(nSpirit>0) then        table.insert(infos,{string.format(GetTxtPub("Spirit").." +%d",nSpirit),FontColor.Silver});    end        if(nExploits>0) then        table.insert(infos,{string.format(GetTxtPub("Exploit").." +%d",nExploits),FontColor.Silver});    end           LogInfo("nYinBi:[%d],nJinBi:[%d],nRepute:[%d],nStamina:[%d],nSoph:[%d],nExp:[%d]",nYinBi,nJinBi,nRepute,nStamina,nSoph,nExp);        local nItemCount = netdata:ReadInt();        LogInfo("nItemCount:[%d]",nItemCount);        for i=1,nItemCount do        local nItemType = netdata:ReadInt();        local nNum = netdata:ReadInt();        if(nNum>0) then            local n7 = Num7(nItemType);            local n8 = Num8(nItemType);                        if(n7 == 3 and n8 == 0) then                table.insert(infos,{string.format(ItemFunc.GetName(nItemType).." x%d",nNum),ItemFunc.GetDaoFaItemColor(nItemType)});            else                table.insert(infos,{string.format(ItemFunc.GetName(nItemType).." x%d",nNum),ItemFunc.GetItemColor(nItemType)});            end        end    end        CommonDlgNew.ShowTipsDlg(infos);        CloseLoadBar();endRegisterNetMsgHandler(NMSG_Type._MSG_ITEM_INFO, "p.ProcessItemInfo", p.ProcessItemInfo);RegisterNetMsgHandler(NMSG_Type._MSG_ITEM_ACTION, "p.ProcessItemAction", p.ProcessItemAction);RegisterNetMsgHandler(NMSG_Type._MSG_ITEM_ATTRIB, "p.ProcessItemAttrib", p.ProcessItemAttrib);RegisterNetMsgHandler(NMSG_Type._MSG_GIFTPACK_ITEM_INFO, "p.ProcessGiftInfo", p.ProcessGiftInfo);