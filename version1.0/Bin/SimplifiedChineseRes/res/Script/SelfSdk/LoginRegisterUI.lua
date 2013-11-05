---------------------------------------------------
--描述: 注册界面
--时间: 2013.6.18
--作者: tzq
---------------------------------------------------
LoginRegisterUI = {}
local p = LoginRegisterUI;

p.CurLayer = nil;           --保存当前层数据
p.Account = nil;            --保存账号数据
p.FstPassWord = nil;        --保存第一次密码数据
p.SedPassWord = nil;        --保存第二次密码数据

--控件id
local ID_EDIT_ACCOUNT        = 88;     --账号输入控件
local ID_EDIT_FST_PASSWORD    = 89;    --第一次密码控件
local ID_EDIT_SED_PASSWORD    = 90;    --第二次密码控件

local ID_BTN_BIND       = 10;    --绑定账号按钮
local ID_BTN_CANCEL     = 86;    --离开按钮

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
	layer:SetTag(NMAINSCENECHILDTAG.LoginRegisterUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	p.CurLayer = layer;
	
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return;
	end
	uiLoad:Load("Login/login_1_2.ini", layer, p.OnUIEvent, 0, 0);
	
	p.InitData();
end

function p.InitData()
    --设置帐号最大长度
	local uiNode = GetUiNode(p.CurLayer, ID_EDIT_ACCOUNT);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMaxLength(4);
        edit:SetMaxLength(32);
    end
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_FST_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMaxLength(6);
        edit:SetMaxLength(12);
        edit:SetPassword(true);
    end
    
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_SED_PASSWORD);
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
    
    --ui按钮响应
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_BIND == tag then     --绑定账号
			--账号基本校验  
			local Account = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_ACCOUNT);
			if not LoginCommon.CheckDataValidity(Account, LoginCommon.ENUM_DATA_FLAG.ACCOUNT_DATA) then
				return true;
			end
			
			--密码基本校验
			local PassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_FST_PASSWORD);
			if not LoginCommon.CheckDataValidity(PassWord, LoginCommon.ENUM_DATA_FLAG.PASSWORD_DATA) then
				return true;
			end
			
			--第二次输入的密码校验
			local SedPassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_SED_PASSWORD);
			if PassWord ~= SedPassWord then
				CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP5"));
				return true;
			end
			
			--发起注册请求
			MsgSelfSdkLogin.MsgSendRegisterAccount(Account, PassWord);
		elseif ID_BTN_CANCEL == tag then          --离开            
			LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginRegisterUI);
		end
		
	--输入键盘回调响应
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
		
		if tag == ID_EDIT_ACCOUNT then     
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				--账号校验
				LoginCommon.CheckDataValidity(edit:GetText(), LoginCommon.ENUM_DATA_FLAG.ACCOUNT_DATA);
			end
			
		elseif tag == ID_EDIT_FST_PASSWORD then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.FstPassWord = edit:GetText();
				--第一次输入密码校验
				LoginCommon.CheckDataValidity(edit:GetText(), LoginCommon.ENUM_DATA_FLAG.PASSWORD_DATA);
			end	
			
		elseif tag == ID_EDIT_SED_PASSWORD then
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



function p.ClearEditData()
	LoginCommon.SetEditData(p.CurLayer, ID_EDIT_ACCOUNT);
	LoginCommon.SetEditData(p.CurLayer, ID_EDIT_FST_PASSWORD);
	LoginCommon.SetEditData(p.CurLayer, ID_EDIT_SED_PASSWORD);
end


function p.SetLoginEditData()
	LoginUI.SetEditData(p.Account, p.FstPassWord);
end
