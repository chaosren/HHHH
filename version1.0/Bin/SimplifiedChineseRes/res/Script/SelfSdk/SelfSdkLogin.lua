---------------------------------------------------
--描述: sdk登入处理
--时间: 2013.6.18
--作者: tzq
---------------------------------------------------
SelfSdkLogin = {}
local p = SelfSdkLogin;

p.nAutoFlag = 0;
--登入处理流程
function p.LoginControl()
	
	p.nAutoFlag = 0;
	local nTestFlag = 1;
	local record = {};
	
	--首先查找本地数据库,
	if nTestFlag == 0 then
		record = SqliteConfig.SelectSelfLogin(1);
	else
		record.nAutoLogin = 0;
		record.Account = "ababab";
		record.PassWord = "aaaaaa";
	end
	
	if record == nil then
		--在数据库中读取不到记录，进入自己的登入界面
		LoginCommon.CommonDataInit();
		LoginUI.LoadUI();	
	else
		local nAutoLogin = record.nAutoLogin;
		local Account = record.Account;
		local PassWord = record.PassWord;
		nAutoLogin = 0;
		
		if nAutoLogin == 0 then  		--非自动登入
			LoginCommon.CommonDataInit();
			LoginUI.LoadUI(Account, PassWord);
		else                         --自动登入
			p.nAutoFlag = 1;
			--MsgSelfSdkLogin.MsgSendLoginAccount(Account, PassWord);
			SendHttpMsgLogin.HttpSendLoginAccount(Account, PassWord);
		end
	end
	
	--自动登入流程
	return true;
end



--获取是否为自动登入，自动登入不继续写数据库
function p.GetAutoFlag()
	return p.nAutoFlag
end