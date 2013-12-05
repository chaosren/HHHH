---------------------------------------------------
--描述: 军团邮件群发
--时间: 2013.9.6
--作者: Guosen
---------------------------------------------------

MassEmailDlg = {}
local p = MassEmailDlg;

---------------------------------------------------
local ID_BTN_CLOSE					= 39;	-- X
local ID_EDIT_SUBJECT				= 21;	-- 编辑控件-主题
local ID_EDIT_CONTENT				= 22;	-- 编辑控件-内容
local ID_BTN_SEND					= 10;	-- 按钮-发送

---------------------------------------------------
local SUBJECT_LENGTH_LIMIT			= 20;	-- 主题限制字数
local CONTENT_LENGTH_LIMIT			= 255;	-- 内容限制字数


---------------------------------------------------
p.pLayerMassEmailDlg			= nil;
p.pEditSubject					= nil;
p.pEditContent					= nil;

---------------------------------------------------
function p.CreateMassEmailDlg( pParentLayer )
	local tMemberList		= MsgArmyGroup.GetArmyGroupMemberList( ArmyGroup.nArmyGroupID );
	if ( table.getn(tMemberList) == 1 ) then
		CommonDlgNew.ShowYesDlg( GetTxtPri("MED_E1"), nil, nil, 3 );
		return;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "MassEmailDlg: CreateHadleMemberDlg failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "MassEmailDlg: CreateHadleMemberDlg failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_MailCompose.ini", layer, p.OnUIEventMassEmailDlg, 0, 0 );
	uiLoad:Free();
	p.pLayerMassEmailDlg = layer;
	
	-- 标题编辑框
	pUINode			= GetUiNode( layer, ID_EDIT_SUBJECT );
	p.pEditSubject	= ConverToEdit( pUINode );
	p.pEditSubject:SetMaxLength(SUBJECT_LENGTH_LIMIT);
	
	-- 内容编辑框
	pUINode			= GetUiNode( layer, ID_EDIT_CONTENT );
	p.pEditContent	= ConverToEdit( pUINode );
	p.pEditContent:SetMaxLength(CONTENT_LENGTH_LIMIT);
	return true;
end

---------------------------------------------------
function p.CloseUI()
	if ( p.pLayerMassEmailDlg ~= nil ) then
		p.pLayerMassEmailDlg:RemoveFromParent( true );
		p.pLayerMassEmailDlg		= nil;
	end
end

---------------------------------------------------
-- 军团成员面板界面的事件响应
function p.OnUIEventMassEmailDlg( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif( tag == ID_BTN_SEND ) then
			local tMemberList		= MsgArmyGroup.GetArmyGroupMemberList( ArmyGroup.nArmyGroupID );
			if ( table.getn(tMemberList) == 1 ) then
				CommonDlgNew.ShowYesDlg( GetTxtPri("MED_E1"), nil, nil, 3 );
			else
				local szSubject	= p.pEditSubject:GetText();
				local szContent	= p.pEditContent:GetText();
				if ( "" == szSubject ) then
					CommonDlg.ShowWithConfirm( GetTxtPri("EL2_T2"), nil );
				elseif ( "" == szContent ) then
					CommonDlg.ShowWithConfirm( GetTxtPri("EL2_T3"), nil );
				else
					MsgArmyGroup.SendMsgMassEmail( szSubject, szContent );
				end
			end
        end
    end
    return true;
end

---------------------------------------------------
-- 群发邮件回调
function p.Callback_MassEmail()
	--CommonDlgNew.ShowYesDlg( "群发成功", nil, nil, 3 );--
	p.CloseUI();
end
