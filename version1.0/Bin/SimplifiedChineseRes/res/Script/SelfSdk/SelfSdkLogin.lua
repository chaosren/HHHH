---------------------------------------------------
--描述: sdk登入处理
--时间: 2013.6.18
--作者: tzq
---------------------------------------------------
SelfSdkLogin = {}
local p = SelfSdkLogin;


--登入处理流程
function p.LoginControl()
	
	local nTestFlag = 1;
	local record = {};
	
	if nTestFlag == 0 then
		record = SqliteConfig.SelectSelfLogin(1);
	else
		record.nAutoLogin = 0;
		record.Account = "323DFD";
		record.PassWord = "12345W3";
	end
	
	if record == nil then
		--在数据库中读取不到记录，进入自己的登入界面
		LoginUI.LoadUI();	
	else
		local nAutoLogin = record.nAutoLogin;
		local Account = record.Account;
		local PassWord = record.PassWord;
		
		if nAutoLogin == 0 then  		--非自动登入
			LoginUI.LoadUI(Account, PassWord);
		else                         --自动登入
			MsgSelfSdkLogin.MsgSendLoginAccount(Account, PassWord);
		end
	end
	
	--自动登入流程
	return true;
end


