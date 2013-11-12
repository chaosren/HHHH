---------------------------------------------------
--描述: sdk登入消息处理
--时间: 2013.6.21
--作者: tzq
---------------------------------------------------
MsgSelfSdkLogin = {}
local p = MsgSelfSdkLogin;

--账号密码验证请求返回枚举
p.ENUM_LOGIN_ACCOUNT_REPLY =
{
    ACCOUNT_NOT_EXIST = 0,   --账号不存在
    INVALID_PASSWORD = 1,    --密码错误
};

p.nAcntLen = 36;
p.nPwdLen  = 21;
p.strSerIp = GetGameConfig("world_server_ip");
p.nPort = GetWorldServerPort();

--初始化一些数据
function p.MsgDataInit()  
	local strPwd = LoginCommon.GetEncryptString(PassWord);   
	SendMsgLoginAccount(p.strSerIp, p.nPort, Account, strPwd, p.nAcntLen, p.nPwdLen, NMSG_Type._MSG_LOGIN_ACCOUNT);
end

--发送账号密码验证请求
function p.MsgSendLoginAccount(Account, PassWord)    
	ShowLoadBar() 
	local strPwd = LoginCommon.GetEncryptString(PassWord);      
	SendMsgLoginAccount(p.strSerIp, p.nPort, Account, strPwd, p.nAcntLen, p.nPwdLen, NMSG_Type._MSG_LOGIN_ACCOUNT);
end

--收到服务端下发的登入账号密码验证结果(只有登入错误才回收到此消息)登入成功收到_MSG_GAMEACCOUNT
function p.MsgReciveLoginAccount(netdatas)   
	
	--游客登入处理
	local nGuestFlag = LoginGuest.GetGuestLoginFlag();
	if nGuestFlag then
		LoginGuest.GusetLogin();  --注册失败 重新注册
		return;
	end
	
	
	--如果登入界面不存在那么打开登入界面
	CloseLoadBar()
	local scene = GetSMLoginScene();
	if scene == nil then
		return false;
	end
	
	local pLayer = GetUiLayer(scene, NMAINSCENECHILDTAG.LoginUI);
	if not CheckP(pLayer) then
		LoginUI.LoadUI();	
	end
	
	local nResult = netdatas:ReadInt(); 
	--登入请求错误返回
	if nResult == p.ENUM_LOGIN_ACCOUNT_REPLY.ACCOUNT_NOT_EXIST then   
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_LOG_ACNT_ERR); --您输入的账号有误,请重新输入 
	elseif nResult == p.ENUM_LOGIN_ACCOUNT_REPLY.INVALID_PASSWORD then   
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_LOG_PWD_ERR); --您输入的密码有误,请重新输入  
	end 
end


--账号注册请求返回枚举
p.ENUM_REGISTER_ACCOUNT_REPLY =
{
    REGISTER_OK = 0,   --成功
    ACCOUNT_EXIST = 1, --账号已存在
    REGISTER_FAIL = 2, --注册失败 
};
--发送注册账号请求
function p.MsgSendRegisterAccount(Account, PassWord)  
	ShowLoadBar()
	local strPwd = LoginCommon.GetEncryptString(PassWord);
	SendMsgRegisterAccount(p.strSerIp, p.nPort, Account, strPwd, p.nAcntLen, p.nPwdLen, NMSG_Type._MSG_REGISTER_ACCOUNT);
end
--收到服务端下发的注册账号请求结果
function p.MsgReciveRegisterAccount(netdatas)   
	CloseLoadBar()
	local nResult = netdatas:ReadInt(); 
	local nGuestFlag = LoginGuest.GetGuestLoginFlag();
	
	--游客登入的处理
	if nGuestFlag then
		if nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.REGISTER_OK then --注册成功
			local strAcnt = LoginGuest.GetAcount();
			local strPwd  = LoginGuest.GetPassWord();
			--发起登入请求
			MsgSelfSdkLogin.MsgSendLoginAccount(strAcnt, strPwd);
		else 
			LoginGuest.GusetLogin();  --注册失败 重新注册
		end
		return;
	end
	
	--正常注册结果处理
	if nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.REGISTER_OK then             --注册成功
		--关闭注册页面,并将当前账号密码填入登入界面账号密码处
		LoginRegisterUI.LoginRegSuccess();
		LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginRegisterUI);  
		LoginUI.LoadUI(LoginRegisterUI.Account, LoginRegisterUI.FstPassWord, 1);
	elseif nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.ACCOUNT_EXIST then     
		--账号已存在
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_REG_ACNT_EXIT);
	elseif nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.REGISTER_FAIL then     
		--注册失败 
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_REG_FAIL);
	end 
end




--发送修改密码消息
function p.MsgSendChangePassWord(Account, OldPassWord, NewPassWord)  
	--获取当前的登入的账号
	ShowLoadBar()
	local OldPwd = LoginCommon.GetEncryptString(OldPassWord);
	local NewPwd = LoginCommon.GetEncryptString(NewPassWord);

	SendMsgChangePassWord(p.strSerIp, p.nPort, Account, OldPwd, NewPwd, p.nAcntLen, p.nPwdLen, NMSG_Type._MSG_CHANGE_PASSWORD);
end


--修改密码请求返回枚举
p.ENUM_CHG_PWD_REPLY =
{
    CHG_OK = 0,   --修改成功
    ACNT_NOT_EXIT = 1, --账号不存在
    SAME_PWD = 2, --注册失败 
	PWD_ERROR = 3, --
    FAILED = 4, -- 
};



--收到服务端下发的修改密码请求结果
function p.MsgReciveChgPwd(netdatas)   

	CloseLoadBar()
	local nResult = netdatas:ReadInt(); 

	if nResult == p.ENUM_CHG_PWD_REPLY.CHG_OK then             --修改密码成功成功
		--关闭修改密码页面,并将当前账号密码填入登入界面账号密码处
		LoginChgPassWord.LoginChgSuccess();
		CloseUI(NMAINSCENECHILDTAG.LoginChgPassWord);
		LoginUI.LoadUI(LoginChgPassWord.Account, LoginChgPassWord.FstPassWord, 1);
	end 
end

--接收登入请求返回结果
RegisterNetMsgHandler(NMSG_Type._MSG_LOGIN_ACCOUNT,  "p.MsgReciveLoginAccount", p.MsgReciveLoginAccount);

--接收注册请求返回结果
RegisterNetMsgHandler(NMSG_Type._MSG_REGISTER_ACCOUNT,  "p.MsgReciveRegisterAccount", p.MsgReciveRegisterAccount);

--接收修改密码请求返回结果
RegisterNetMsgHandler(NMSG_Type._MSG_CHANGE_PASSWORD,  "p.MsgReciveChgPwd", p.MsgReciveChgPwd);