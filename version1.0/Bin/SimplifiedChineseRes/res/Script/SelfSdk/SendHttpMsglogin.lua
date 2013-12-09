---------------------------------------------------
--描述: 通过http请求来实现登入
--时间: 2013.11.18
--作者: tzq
---------------------------------------------------
SendHttpMsgLogin = {}
local p = SendHttpMsgLogin;


--p.strHttpIpPort = "http://112.124.57.245:9009/";           --ip，端口

p.strHttpIpPort = "http://dhlj.cn03.91dena.com:9009/";           --ip，端口
p.strHttpLogin = "process_login_account";        --登入账号
p.strHttpRnameAcnt = "process_rename_account";   --绑定账号
p.strHttpRegister = "process_register_account";  --注册账号
p.strHttpChgPwd = "process_change_password";    --修改密码

p.strResult = "result";
p.strAccount_id = "platform_account_id";

--一些数据的限制
p.NUM_MSG_TYPE = 
{
	MSG_TYPE_LOGIN = 1,   --登入消息
	MSG_TYPE_REGISTER = 2,   --注册消息
	MSG_TYPE_RENAME = 3,   --绑定账号
	MSG_TYPE_CHG_PWD = 4,   --修改密码
	MSG_TYPE_GUESS_LOGIN = 5,   --游客登入	
};

p.MsgType = p.NUM_MSG_TYPE.MSG_TYPE_LOGIN;


--发送登入请求
--http://host:9009/process_login_account?account=xx&pwd=xx
function p.HttpSendLoginAccount(Account, PassWord)    
	ShowLoadBar() 
	p.MsgType = p.NUM_MSG_TYPE.MSG_TYPE_LOGIN;
	local strPwd = LoginCommon.GetEncryptString(PassWord);
	local strSendData = p.strHttpIpPort..p.strHttpLogin;      
	strSendData = strSendData.."?account="..Account.."&pwd="..strPwd;
	SendHttpLoginMsg(strSendData);
end

--发送注册账号请求
--http://host:9009/process_register_account?account=xx&pwd=xx
function p.HttpSendRegisterAccount(Account, PassWord)  
	ShowLoadBar()
	p.MsgType = p.NUM_MSG_TYPE.MSG_TYPE_REGISTER;
	
	local strPwd = LoginCommon.GetEncryptString(PassWord);
	local strSendData = p.strHttpIpPort..p.strHttpRegister;      
	strSendData = strSendData.."?account="..Account.."&pwd="..strPwd;
	SendHttpLoginMsg(strSendData);
end

--发送修改密码消息
--http://host:9009/process_change_password?account=xx&pwd=xx&new_pwd=xx
function p.HttpSendChangePassWord(Account, OldPassWord, NewPassWord)  
	--获取当前的登入的账号
	ShowLoadBar()
	p.MsgType = p.NUM_MSG_TYPE.MSG_TYPE_CHG_PWD;
		
	local OldPwd = LoginCommon.GetEncryptString(OldPassWord);
	local NewPwd = LoginCommon.GetEncryptString(NewPassWord);
	
	local strSendData = p.strHttpIpPort..p.strHttpChgPwd;      
	strSendData = strSendData.."?account="..Account.."&pwd="..OldPwd.."&new_pwd="..NewPwd;
	SendHttpLoginMsg(strSendData);
end

--发送绑定账号请求消息
--http://host:9009/process_rename_account?account=xx&pwd=xx&new_account=xx
function p.HttpSendBindAccount(Account, PassWord, NewAccount) 
	ShowLoadBar()
	p.MsgType = p.NUM_MSG_TYPE.MSG_TYPE_RENAME;
		
	local NewPwd = LoginCommon.GetEncryptString(PassWord);
	
	local strSendData = p.strHttpIpPort..p.strHttpRnameAcnt;      
	strSendData = strSendData.."?account="..Account.."&pwd="..NewPwd.."&new_account="..NewAccount;
	SendHttpLoginMsg(strSendData);
end


--去掉空格，"号
function p.RmvSpAnd(szInfo)  
	local strRet = "";
	local nLen = string.len(szInfo);
	
	for i = 1, nLen do
		local szChar = string.char(string.byte (szInfo, i));
		if szChar ~= nil and szChar ~= "\"" and szChar ~= " " and szChar ~= "{" and szChar ~= "}" then
			strRet = strRet..szChar;
		end
	end
	
	return strRet;
end


--发送修改密码消息
--http://host:9009/process_change_password?account=xx&pwd=xx&new_pwd=xx
function p.MsgRcvHttpRespond(szInfo)  
	CloseLoadBar()
	local strTemp = szInfo;
	--ShowLoadBar()
	local nPos1 = nil;
	local nPos2 = nil;
	--"platform_account_id":i d, " result": 1
	local szFstName = "";
	local szFstValue = "";
	local szSndName = "";
	local szSndValue = "";

	--找到第一个:号
	nPos1 = string.find(strTemp, ":");
	if not nPos1 then
		return; --错误返回
	end
	szFstName = string.sub(strTemp, 1, nPos1 - 1);
	
	--找到第一个,号
	nPos2 = string.find(strTemp, ",");
	--没有第二个值
	if not nPos2 then
		szFstValue = string.sub(strTemp, nPos1 + 1);
	else
		szFstValue = string.sub(strTemp, nPos1 + 1, nPos2 - 1);
		strTemp = string.sub(strTemp, nPos2 + 1);
		--找到第二个:
		nPos1 = string.find(strTemp, ":");
		if not nPos1 then
			return;  --错误返回
		end
		szSndName = string.sub(strTemp, 1, nPos1 - 1);
		szSndValue = string.sub(strTemp, nPos1 + 1);
	end
	
	--去掉引号，空格
	szFstName = p.RmvSpAnd(szFstName);
	szFstValue = p.RmvSpAnd(szFstValue);
	szSndName = p.RmvSpAnd(szSndName);
	szSndValue = p.RmvSpAnd(szSndValue);
	
	p.MsgRcvControl(szFstName, szFstValue, szSndName, szSndValue);
end


function p.MsgRcvControl(szFstName, szFstValue, szSndName, szSndValue)  
	if 	p.MsgType == p.NUM_MSG_TYPE.MSG_TYPE_REGISTER then
		if szFstName == p.strResult then
			p.MsgRcvRegCtl(szFstValue);
		end
	elseif p.MsgType == p.NUM_MSG_TYPE.MSG_TYPE_LOGIN then
		if szFstName == p.strAccount_id and szSndName == p.strResult then
			p.MsgRcvLogCtl(szFstValue, szSndValue);
		end
	elseif p.MsgType == p.NUM_MSG_TYPE.MSG_TYPE_CHG_PWD then
		if szFstName == p.strResult then
			p.MsgRcvChgPwdCtl(szFstValue);
		end
	elseif p.MsgType == p.NUM_MSG_TYPE.MSG_TYPE_RENAME then
		if szFstName == p.strResult then
			p.MsgRcvBindAcuntCtl(szFstValue);
		end
	end
end


--账号注册请求返回枚举
p.ENUM_REGISTER =
{
    REGISTER_OK = 0,   --成功
    ACCOUNT_EXIST = 1, --账号已存在
    REGISTER_FAIL = 2, --注册失败 
};
function p.MsgRcvRegCtl(strResult)  

	local nResult = SafeS2N(strResult); 
	local nGuestFlag = LoginGuest.GetGuestLoginFlag();
	
	--游客登入的处理
	if nGuestFlag then
		if nResult == p.ENUM_REGISTER.REGISTER_OK then --注册成功
			local strAcnt = LoginGuest.GetAcount();
			local strPwd  = LoginGuest.GetPassWord();
			--发起登入请求
			p.HttpSendLoginAccount(strAcnt, strPwd);
		else 
			LoginGuest.GusetLogin();  --注册失败 重新注册
		end
		return;
	end
	
	--正常注册结果处理
	if nResult == p.ENUM_REGISTER.REGISTER_OK then             --注册成功
		--关闭注册页面,并将当前账号密码填入登入界面账号密码处
		LoginRegisterUI.LoginRegSuccess();
		LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginRegisterUI);  
		LoginUI.LoadUI(LoginRegisterUI.Account, LoginRegisterUI.FstPassWord, 1);
	elseif nResult == p.ENUM_REGISTER.ACCOUNT_EXIST then     
		--账号已存在
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_REG_ACNT_EXIT);
	elseif nResult == p.ENUM_REGISTER.REGISTER_FAIL then     
		--注册失败 
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_REG_FAIL);
	end 
end




--账号密码验证请求返回枚举
p.ENUM_LOGIN =
{
    ACCOUNT_NOT_EXIST = 0,   --账号不存在
    INVALID_PASSWORD = 1,    --密码错误
    LOGIN_SUCCESS   = 2,     --登入成功
};
function p.MsgRcvLogCtl(strAcntId, strResult)  
	local nResult = SafeS2N(strResult);
	local nAcntId = SafeS2N(strAcntId);
	
	if nResult == p.ENUM_LOGIN.ACCOUNT_NOT_EXIST then   --账号不存在
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_LOG_ACNT_ERR); 
	elseif nResult == p.ENUM_LOGIN.INVALID_PASSWORD then  --密码错误
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_REV_LOG_PWD_ERR); 
	elseif nResult == p.ENUM_LOGIN.LOGIN_SUCCESS then  --登入成功
		local nGuestFlag = LoginGuest.GetGuestLoginFlag();
		if nGuestFlag then
			LoginGuest.LoginSuccess();
		else
			--seft sdk 登入成功调用
			local nAutoFlag = SelfSdkLogin.GetAutoFlag();
			
			if nAutoFlag ~= 1 then
				LoginUI.LoginSuccess();
			end
		end
		
		Login_ServerUI.SetAccountID(nAcntId);
		Login_ServerUI.LoadUI();
		Login_ServerUI.LoginOK_Normal(nAcntId)
	end	 
end


--修改密码请求返回枚举
p.ENUM_CHG_PWD =
{
	CHG_OK = 0,   --修改成功
	ACNT_NOT_EXIT = 1, --账号不存在
	SAME_PWD = 2, --相同密码
	PWD_ERROR = 3, --
	FAILED = 4, -- 
};

function p.MsgRcvChgPwdCtl(strResult)
	local nResult = SafeS2N(strResult);
	if nResult == p.ENUM_CHG_PWD.CHG_OK then
		LoginChgPassWord.LoginChgSuccess();
		CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP10"), nil, nil, 10);
	elseif nResult == p.ENUM_CHG_PWD.PWD_ERROR then
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_ERROR, true); 
	else
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_CHG_FAILED, true); 
	end
end


--綁定帳號返回枚举
p.ENUM_BIND_ACUNT =
{
	OK = 0,                  --修改成功
	ACCOUNT_NOT_EXIST = 1,    --账号不存在
	SAME_ACCOUNT = 2,        
	INVALID_PASSWORD = 3, 
	FAIL = 4, 
	ACCOUNT_NAME_EXIST = 5, 
};

function p.MsgRcvBindAcuntCtl(strResult)
	local nResult = SafeS2N(strResult);
	if nResult == p.ENUM_BIND_ACUNT.OK then
		LoginBindAccount.LoginBindSuccess();
		CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP16"), nil, nil, 10);
	elseif nResult == p.ENUM_BIND_ACUNT.SAME_ACCOUNT then
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_BIND_SAME_ACUNT, true); 
	elseif nResult == p.ENUM_BIND_ACUNT.ACCOUNT_NAME_EXIST then
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_BIND_ACUNT_EXIT, true); 
	else
		LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_BIND_FAILED, true);
	end
end



