---------------------------------------------------
--描述: 登入修改密码页面
--时间: 2013.6.20
--作者: tzq
---------------------------------------------------
LoginChgPassWord = {}
local p = LoginChgPassWord;

local ID_EDIT_OLD_PASSWORD     = 88;    --原密码输入控件
local ID_EDIT_NEW_PASSWORD    = 89;    --新密码输入控件
local ID_EDIT_SEC_PASSWORD    = 90;    --新密码第二次输入控件
local ID_BTN_OK        = 10;    --确定
local ID_BTN_CANCEL    = 86;    --离开
p.CurLayer = nil;
p.FstPassWord = nil;
p.SedPassWord = nil;

function p.LoadUI()
	
	local scene = GetSMLoginScene();	
	if scene == nil then
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		return;
	end
    
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.LoginChgPassWord);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);
	p.CurLayer = layer;
	
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return;
	end
	uiLoad:Load("Login/login_1_1.ini", layer, p.OnUIEvent, 0, 0);
	
	p.InitData();
end

function p.InitData()
     --设置密码项为不可见模式 
    local uiNode = GetUiNode(p.CurLayer, ID_EDIT_OLD_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMaxLength(6);
        edit:SetMaxLength(12);
        edit:SetPassword(true);
    end
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_NEW_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMaxLength(6);
        edit:SetMaxLength(12);
        edit:SetPassword(true);
    end
    
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_SEC_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMaxLength(6);
        edit:SetMaxLength(12);
        edit:SetPassword(true);
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent hit tag = %d", tag);
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_OK == tag then  --确定

			--原密码校验
			local OldPassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_OLD_PASSWORD);
			if not LoginCommon.CheckDataValidity(OldPassWord, LoginCommon.ENUM_DATA_FLAG.PASSWORD_DATA) then
				return true;
			end	
			
			--新密码校验
			local NewPassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_NEW_PASSWORD);
			if not LoginCommon.CheckDataValidity(NewPassWord, LoginCommon.ENUM_DATA_FLAG.PASSWORD_DATA) then
				return true;
			end	
			
			--两次密码输入一致性校验
			if OldPassWord ~= NewPassWord then
				CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP5"));
				return true;
			end

			--发起修改密码请求
			MsgSelfSdkLogin.MsgSendChangePassWord(OldPassWord, NewPassWord);
		
		elseif ID_BTN_CANCEL == tag then          --离开                     
			LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginChgPassWord);
		end
		
		
		--输入键盘回调响应
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then

		if tag == ID_EDIT_OLD_PASSWORD then     
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				--账号校验
				LoginCommon.CheckDataValidity(edit:GetText(), LoginCommon.ENUM_DATA_FLAG.PASSWORD_DATA);
			end
			
		elseif tag == ID_EDIT_NEW_PASSWORD then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.FstPassWord = edit:GetText();
				--第一次输入密码校验
				LoginCommon.CheckDataValidity(edit:GetText(), LoginCommon.ENUM_DATA_FLAG.PASSWORD_DATA);
			end	
			
		elseif tag == ID_EDIT_SEC_PASSWORD then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.SedPassWord = edit:GetText();
				
				--第二次输入密码校验
				if p.FstPassWord ~= p.SedPassWord then
					edit:SetText("");
					CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP5"));
				end
			end			
		end		
	end

	return true;
end
