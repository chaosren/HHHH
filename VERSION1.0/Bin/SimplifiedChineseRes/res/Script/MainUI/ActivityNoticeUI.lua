-----------------------------------------------------描述: 活动公告界面--时间: 2012.9.28--作者: Guosen---------------------------------------------------ActivityNoticeUI = {}local p = ActivityNoticeUI;---------------------------------------------------local ID_BTN_CLOSE			= 533;	-- Xlocal ID_LABEL_NOTICE		= 14;	-- 公告标签--是否读取数据库中的公告数据local ReadDbNotice = true;local szTitle	= "2月22號更新公告";--local szNotice	= "【更新一】:開啟混服功能\nIOS,Android用戶可以在同一個伺服器內進行遊戲啦\n【更新二】:新服威震九州開啟\n混合新服威震九州開啟諸多新服活動邀你加入\n【更新三】:元宵活動開啟\n慶元宵佳節大話龍將專屬活動開啟\n詳情點擊左上角群組查看詳情介紹"local szNotice	= "【更新一】:修復材料自動尋路問題\n【更新二】:發放伺服器故障補償\n全服每人100萬銀幣,10個軍令\n【更新二】:新增線上活動\n伺服器故障補償第二波\n19日-21日線上即可領取禮包\n"---------------------------------------------------p.szNoticeInfo = "";--function p.ShowUI( nVer )	LogInfo( "ActivityNoticeUI: ShowUI" );	local scene = GetRunningScene();	if not CheckP(scene) then	LogInfo( "ActivityNoticeUI: ShowUI failed! scene is nil" );		return false;	end		local layer = createNDUILayer();	if not CheckP(layer) then		LogInfo( "ActivityNoticeUI: ShowUI failed! layer is nil" );		return false;	end		layer:SetPopupDlgFlag( true );	layer:Init();	layer:SetTag( NMAINSCENECHILDTAG.ActivityNoticeUI );	layer:SetFrameRect( RectFullScreenUILayer );	scene:AddChildZ( layer, 1 );	--if( CheckN(nVer) ) then        p.SendGetNoticeMsg(nVer);   -- else    --    p.FillUI();    --end	endfunction p.FillUI()    local layer = p.GetCurLayer();    local uiLoad = createNDUILoad();	if ( nil == uiLoad ) then		layer:Free();		LogInfo( "ActivityNoticeUI: ShowUI failed! uiLoad is nil" );		return false;	end	uiLoad:Load( "activity.ini", layer, p.OnUIEventActivityNoticeUI, 0, 0 );	uiLoad:Free();		--	local pLabelNotice = GetLabel( layer, ID_LABEL_NOTICE );	if ( pLabelNotice ~= nil ) then        --local record = SqliteConfig.SelectNotice(1);                if ReadDbNotice then			if p.szNoticeInfo ~= nil then				pLabelNotice:SetText( p.szNoticeInfo );			end		 else			pLabelNotice:SetText( szNotice ); 		 end	endendfunction p.GetCurLayer()    local scene = GetRunningScene();    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ActivityNoticeUI);    return layer;end---------------------------------------------------function p.CloseUI()	local scene = GetRunningScene();	if ( scene ~= nil ) then		scene:RemoveChildByTag( NMAINSCENECHILDTAG.ActivityNoticeUI, true );	endend---------------------------------------------------function p.OnUIEventActivityNoticeUI( uiNode, uiEventType, param )	local tag = uiNode:GetTag();	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then        if ( ID_BTN_CLOSE == tag ) then        	p.CloseUI();        end    end    return true;endfunction p.SendGetNoticeMsg( nVer )    --LogInfo("p.SendGetNoticeMsg nVer:[%d]",nVer);    local netdata = createNDTransData(NMSG_Type._MSG_BULLETIN);	if nil == netdata then		return false;	end	netdata:WriteInt(0);	SendMsg(netdata);	netdata:Free();endfunction p.RevNoticeMsg( netdata )    LogInfo("p.RevNoticeMsg");    local nVer = netdata:ReadInt();    p.szNoticeInfo = "";    LogInfo("nVer:[%d]",nVer)    --local record = SqliteConfig.SelectNotice(1);    --if(nVer > record.VER) then        --显示公告        local sNotice = netdata:ReadUnicodeString();                        local record = {};        record.ID = 1;        record.VER = nVer;        record.MSG = sNotice;        p.szNoticeInfo = sNotice;        --SqliteConfig.InsertNotice(record);    --end        local layer = p.GetCurLayer();    local uiLoad = createNDUILoad();	if ( nil == uiLoad ) then		layer:Free();		LogInfo( "ActivityNoticeUI: ShowUI failed! uiLoad is nil" );		return false;	end	uiLoad:Load( "activity.ini", layer, p.OnUIEventActivityNoticeUI, 0, 0 );	uiLoad:Free();		--	local pLabelNotice = GetLabel( layer, ID_LABEL_NOTICE );	if ( pLabelNotice ~= nil ) then		pLabelNotice:SetText( record.MSG );	end        --p.FillUI();endRegisterNetMsgHandler(NMSG_Type._MSG_BULLETIN,"p.RevNoticeMsg",p.RevNoticeMsg);