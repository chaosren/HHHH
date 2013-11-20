---------------------------------------------------
--描述: 游客登入处理
--时间: 2013.11.12
--作者: tzq
---------------------------------------------------
LoginGuest = {}
local p = LoginGuest;


p.Account = nil;            --保存账号数据
p.PassWord = "111111";       --保存默认的密码数据
p.nAcntNum = 10;       --账号位数
p.bGuestLoginFlag = false;   --标志是否为游客登入


--产生一个nNum数的随机字符串,字符取值范围在p.tbStr中

p.tbStr = 
{
	{nMin = 48, nMax = 57},  --数字
	{nMin = 65, nMax = 90},  --小写字母
	{nMin = 95, nMax = 95},  --下划线
	{nMin = 97, nMax = 122}, --大写字母
};


function p.GenerateNRandomStr(nNum)
	local nTbNum = #p.tbStr;
	local strRet = "";

	for i = 1, nNum do
		local nTbStr = math.random(1, nTbNum);  --随机获取一个字符范围
		local nMin = p.tbStr[nTbStr].nMin;
		local nMax = p.tbStr[nTbStr].nMax;
		
		local nRanNum = math.random(nMin, nMax);
		strRet = strRet .. string.char(nRanNum);
	end
	
	return strRet;
end

function p.SetGuestLoginFlag(bFlag)
	p.bGuestLoginFlag = bFlag;
end
function p.GetGuestLoginFlag()
	return p.bGuestLoginFlag;
end
function p.GetAcount()
	return p.Account;
end
function p.GetPassWord()
	return p.PassWord;
end



--游客登入的流程是先随机产生一个10位数账号，加默认密码111111 六个1，
--模拟注册，注册成功直接登入下次默认记住账号，注册不成功重新产生随机账号再次注册，直到成功为止
function p.GusetLogin()
	p.Account = p.GenerateNRandomStr(p.nAcntNum);
	p.SetGuestLoginFlag(true);
	
	--发起注册请求
	SendHttpMsgLogin.HttpSendRegisterAccount(p.Account, p.PassWord);
end


--注册成功调用
function p.LoginSuccess()
	--关闭登入页面
	LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginUI);

	--保存注册信息至数据库
	local record = {};	record.ID = 1;	record.nAutoLogin = 1;	record.Account = p.Account;	record.PassWord = p.PassWord;	SqliteConfig.InsertSelfLogin(record);
end






