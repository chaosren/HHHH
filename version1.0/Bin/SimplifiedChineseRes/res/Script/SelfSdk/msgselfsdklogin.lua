---------------------------------------------------
--描述: sdk登入消息处理
--时间: 2013.6.21
--作者: tzq
---------------------------------------------------
MsgSelfSdkLogin = {}
local p = MsgSelfSdkLogin;

local ACCOUNT_LEN        = 36;   
local PASSWORD_LEN    = 21;   

local SerIp = GetGameConfig("world_server_ip");
local port = GetWorldServerPort();	

--账号密码验证请求返回枚举
p.ENUM_LOGIN_ACCOUNT_REPLY =
{
    ACCOUNT_NOT_EXIST = 0,   --账号不存在
    INVALID_PASSWORD = 1,    --密码错误
};

--发送账号密码验证请求
function p.MsgSendLoginAccount(Account, PassWord)  
	SendMsgLoginAccount(SerIp, port, Account, PassWord, ACCOUNT_LEN, PASSWORD_LEN, NMSG_Type._MSG_LOGIN_ACCOUNT);
end

--收到服务端下发的登入账号密码验证结果
function p.MsgReciveLoginAccount(netdatas)   
	--如果登入界面不存在那么打开登入界面
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
	if nResult == p.ENUM_LOGIN_ACCOUNT_REPLY.ACCOUNT_NOT_EXIST then             --账号不存在
	    CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP3"), nil, nil, 3);
	elseif nResult == p.ENUM_LOGIN_ACCOUNT_REPLY.INVALID_PASSWORD then          --密码错误
		CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP4"), nil, nil, 3);
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
	SendMsgRegisterAccount(SerIp, port, Account, PassWord, ACCOUNT_LEN, PASSWORD_LEN, NMSG_Type._MSG_REGISTER_ACCOUNT);
end
--收到服务端下发的注册账号请求结果
function p.MsgReciveRegisterAccount(netdatas)   

	local nResult = netdatas:ReadInt(); 

	if nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.REGISTER_OK then             --注册成功
		--关闭注册页面,并将当前账号密码填入登入界面账号密码处
		LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginRegisterUI);  
		LoginRegisterUI.SetLoginEditData();
	elseif nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.ACCOUNT_EXIST then     --账号已存在
		--提示账号已存在并清空编辑框中数据
		CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP6"), nil, nil, 3);
		LoginRegisterUI.ClearEditData();
	elseif nResult == p.ENUM_REGISTER_ACCOUNT_REPLY.REGISTER_FAIL then     --注册失败 
		--提示注册失败，重新注册
		CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP7"), nil, nil, 3);
	end 
end





--发送修改密码消息
function p.MsgSendChangePassWord(OldPassWord, NewPassWord)  
	--获取当前的登入的账号
	local record = SqliteConfig.SelectSelfLogin(1);
	if record == nil then
		return;
	end
	
	local Account = record.Account;
	SendMsgChangePassWord(SerIp, port, Account, OldPassWord, NewPassWord, ACCOUNT_LEN, PASSWORD_LEN, NMSG_Type._MSG_CHANGE_PASSWORD);
end

		
		

--接收登入请求返回结果
RegisterNetMsgHandler(NMSG_Type._MSG_LOGIN_ACCOUNT,  "p.MsgReciveLoginAccount", p.MsgReciveLoginAccount);

--接收注册请求返回结果
RegisterNetMsgHandler(NMSG_Type._MSG_REGISTER_ACCOUNT,  "p.MsgReciveRegisterAccount", p.MsgReciveRegisterAccount);