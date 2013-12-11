---------------------------------------------------
--描述: 登入界面
--时间: 2013.6.18
--作者: tzq
---------------------------------------------------
LoginUI = {}
local p = LoginUI;


p.Account = nil;      --账号
p.PassWord = nil;     --密码
p.nAutoLogin = 0;     --自动登入标志         

p.CurLayer = nil;


--控件id
local ID_EDIT_ACCOUNT     = 88;    --账号输入控件
local ID_EDIT_PASSWORD    = 89;    --密码输入控件
local ID_BOX_AUTO_LOGIN    = 87;    --自动登入单选框

local ID_BTN_GUEST_LOGIN       = 85;    --游客登入按钮
local ID_BTN_START_GAME        = 10;    --开始游戏按钮
local ID_BTN_REGISTER    = 86;    --注册账号按钮

local ID_TXT_ERROR_TIP    = 9;    --登入错误提示框
	


function p.LoadUI(Account, PassWord, AutoLogin)
	
	if p.CurLayer ~= nil then
		return;
	end
	
	--记录传入的账号密码
	p.Account = Account;
	p.PassWord = PassWord;
	p.nAutoLogin = AutoLogin;
	
	local scene = GetSMLoginScene();	
	if scene == nil then
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		return;
	end
    
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.LoginUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	p.CurLayer = layer;
	
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
		return;
	end
	uiLoad:Load("Login/login_1.ini", layer, p.OnUIEvent, 0, 0);
	
    --初始化数据
	p.InitData();   
    
    --设置编辑控件的内容
    p.SetLoginEditData(Account, PassWord); 
end

function p.InitData()
    --设置帐号最大长度
	local uiNode = GetUiNode(p.CurLayer, ID_EDIT_ACCOUNT);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMinLength(LoginCommon.NUM_LIMITE.ACCOUNT_NUM_MIN);
        edit:SetMaxLength(LoginCommon.NUM_LIMITE.ACCOUNT_NUM_MAX);
    end
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMinLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MIN);
        edit:SetMaxLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MAX);
        edit:SetPassword(true);
    end
    
    --获取自动登入标志
    uiNode = GetUiNode(p.CurLayer, ID_BOX_AUTO_LOGIN);
    local pCheckBox = ConverToCheckBox( uiNode );
	
	if p.nAutoLogin == 1 then
		pCheckBox:SetSelect(true);
	else
		pCheckBox:SetSelect(false);
		p.nAutoLogin = 0;
	end
end

--设置编辑控件的内容
function p.SetLoginEditData(pszAccount, pszPassWord)
	LoginCommon.SetEditData(p.CurLayer, ID_EDIT_ACCOUNT, pszAccount);
	LoginCommon.SetEditData(p.CurLayer, ID_EDIT_PASSWORD, pszPassWord);
end



function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent hit tag = %d", tag);
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_START_GAME == tag then    --开始游戏 
			--账号密码基本校验  
			p.Account = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_ACCOUNT);
			p.PassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_PASSWORD);
			
			if not LoginCommon.CheckDataValidity(p.Account, LoginCommon.CHECK_FLAG.TYPE_LOG_ACNT) 
			or  not LoginCommon.CheckDataValidity(p.PassWord, LoginCommon.CHECK_FLAG.TYPE_LOG_PWD) then
				return true;
			end
			
			--发起登入请求
			--MsgSelfSdkLogin.MsgSendLoginAccount(p.Account, p.PassWord);
			SendHttpMsgLogin.HttpSendLoginAccount(p.Account, p.PassWord);
		elseif ID_BTN_REGISTER == tag then          --注册账号                    
			p.CloseLoginUI();   
			LoginRegisterUI.LoadUI();
			
		elseif ID_BTN_GUEST_LOGIN == tag then          --游客登入
			--游客登入功能实现
			CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("SELF_SDK_TIP9"), p.OnGuestLogin, true);
			--p.CloseLoginUI();
			--LoginChgPassWord.LoadUI();
			
		elseif 	(ID_EDIT_ACCOUNT == tag 
		        or ID_EDIT_PASSWORD == tag) then
		        
			local uiNode1 = GetUiNode(p.CurLayer, ID_EDIT_ACCOUNT);
			local uiNode2 = GetUiNode(p.CurLayer, ID_EDIT_PASSWORD);
			local edit1 = ConverToEdit(uiNode1);
			local edit2 = ConverToEdit(uiNode2);
			edit1:SetFocus(false);
			edit2:SetFocus(false);
			
			if ID_EDIT_ACCOUNT == tag then
				edit1:SetFocus(true);
			elseif ID_EDIT_PASSWORD == tag then
				edit2:SetFocus(true);
			end				
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		--自动登入单选框点击操作
		if ID_BOX_AUTO_LOGIN == tag then  
			local pCheckBox = ConverToCheckBox( uiNode );
			
			--获取当前相反结果
			if pCheckBox:IsSelect() then
				p.nAutoLogin = 1;
			else
				p.nAutoLogin = 0;
			end
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
		-- 用户按下键盘的返回键
		if tag == ID_EDIT_ACCOUNT then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.Account = edit:GetText();
				LogInfo("eidt text [%s][%s]", edit:GetText(), p.Account);
			end
		elseif tag == ID_EDIT_PASSWORD then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.PassWord = edit:GetText();
				LogInfo("eidt text [%s][%s]", edit:GetText(), p.PassWord);
			end			
		end	
	end
     
	return true;
end


function p.OnGuestLogin(nId, param)
	if ( CommonDlgNew.BtnOk == nId ) then
		LoginGuest.GusetLogin();
	end
end

--注册成功调用
function p.LoginSuccess()
	--关闭注册页面
	p.CloseLoginUI()

	--保存注册信息至数据库
	local record = {};	record.ID = 1;	record.nAutoLogin = p.nAutoLogin;	record.Account = p.Account;	record.PassWord = p.PassWord;	SqliteConfig.InsertSelfLogin(record);
end

function p.CloseLoginUI()
	LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginUI);
	p.CurLayer = nil;
end
