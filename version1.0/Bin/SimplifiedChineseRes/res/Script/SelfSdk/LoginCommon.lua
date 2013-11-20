---------------------------------------------------
--描述: 使用自登入一些接口信息
--时间: 2013.6.7
--作者: tzq
---------------------------------------------------
LoginCommon = {}
local p = LoginCommon;


--selfSdk  table
local SelfLoginTableName = "SelfLogin"
--nAutoLogin 是否自动登入 0:不是  1:是   Account用户名  PassWord密码
local SelfLoginCreateScript = "CREATE TABLE SelfLogin (ID INTEGER, nAutoLogin INTEGER, Account NVARCHAR(300), PassWord NVARCHAR(300));";


local SelfLoginInsert = "INSERT INTO SelfLogin VALUES(%d, %d, \'%s\', \'%s\')";
local SelfLoginUpdate = "UPDATE SelfLogin SET nAutoLogin = %d, Account=\'%s\', PassWord=\'%s\' WHERE ID=%d;";
local SelfLoginSelect = "SELECT * FROM SelfLogin WHERE ID=%d;";


--一些数据的限制
p.NUM_LIMITE = 
{
	ACCOUNT_NUM_MIN = 4,   --账号字符最少个数
	ACCOUNT_NUM_MAX = 32,   --账号字符最多个数
	PASSWORD_NUM_MIN = 6,   --密码字符最少个数
	PASSWORD_NUM_MAX = 12,   --密码字符最多个数		
};

--要验证的数据枚举
p.ENUM_DATA_FLAG =
{	 
    ACCOUNT_DATA = 1,   --账号数据
    PASSWORD_DATA = 2,  --密码数据
};

--数据校验类型对应CommonDataInit中的nCheckFlag
p.CHECK_FLAG =
{	 
	TYPE_LOG_ACNT = 1,  --登入账号校验
	TYPE_LOG_PWD = 2,   --登入密码校验
	TYPE_REV_LOG_ACNT_ERR = 3,   --收到登入返回账号错误
	TYPE_REV_LOG_PWD_ERR = 4,    --收到登入返回密码错误
	
	TYPE_REG_ACNT = 5,  --注册账号校验
	TYPE_REG_PWD_FST = 6,   --注册第一个密码校验
	TYPE_REG_PWD_SND = 7,   --注册第二个密码校验
	TYPE_REV_REG_ACNT_EXIT = 8,   --注册返回账号已存在
	TYPE_REV_REG_FAIL = 9,   --注册返回失败
	
	TYPE_CHG_PWD_OLD = 10,   --修改密码原密码校验
	TYPE_CHG_PWD_FST = 11,   --修改密码第一次输入密码校验
	TYPE_CHG_PWD_SND = 12,   --修改密码第二次输入密码校验
	TYPE_CHG_OLD_NEW = 13,   --新旧密码相同性校验
};

--获取的数据段对应CommonDataInit中每条记录的每个字段例如 nTipId,nCtrId等
p.ENUM_DATATYPE_FLAG =
{	 
	TYPE_TIP_ID = 1,  --提示字符类型
	TYPE_CTR_ID = 2,   --显示提示的控件
	TYPE_UI_TAG = 3,   --提示的页面tag
	TYPE_EDT_ID1 = 4,  
	TYPE_EDT_ID2 = 5, 
	TYPE_EDT_ID3 = 6, 
};

p.tbCommonData = {};

function p.CommonDataInit()
	p.tbCommonData = {
	--nCheckFlag校验的类型, nTipId提示的字符类型, nCtrId显示提示的控件id, nUITag显示提示的页面tag
	--nEditId1要清除的编辑控件1,2,3
	--登入页面用到的
	{nCheckFlag = 1, nTipId = 1, nCtrId = 9, nUITag = NMAINSCENECHILDTAG.LoginUI, nEditId1 = 88, nEditId2 = 89},
	{nCheckFlag = 2, nTipId = 2, nCtrId = 9, nUITag = NMAINSCENECHILDTAG.LoginUI, nEditId1 = 89},
	{nCheckFlag = 3, nTipId = 3, nCtrId = 9, nUITag = NMAINSCENECHILDTAG.LoginUI, nEditId1 = 88, nEditId2 = 89},
	{nCheckFlag = 4, nTipId = 4, nCtrId = 9, nUITag = NMAINSCENECHILDTAG.LoginUI, nEditId1 = 89},
	
	--注册页面用到的
	{nCheckFlag = 5, nTipId = 1, nCtrId = 43, nUITag = NMAINSCENECHILDTAG.LoginRegisterUI, nEditId1 = 88, nEditId2 = 89, nEditId3 = 90},
	{nCheckFlag = 6, nTipId = 2, nCtrId = 43, nUITag = NMAINSCENECHILDTAG.LoginRegisterUI, nEditId1 = 89, nEditId2 = 90},
	{nCheckFlag = 7, nTipId = 5, nCtrId = 43, nUITag = NMAINSCENECHILDTAG.LoginRegisterUI, nEditId1 = 90},
	{nCheckFlag = 8, nTipId = 6, nCtrId = 43, nUITag = NMAINSCENECHILDTAG.LoginRegisterUI, nEditId1 = 88, nEditId2 = 89, nEditId3 = 90},
	{nCheckFlag = 9, nTipId = 7, nCtrId = 43, nUITag = NMAINSCENECHILDTAG.LoginRegisterUI, nEditId1 = 88, nEditId2 = 89, nEditId3 = 90},	
	
	--修改密码页面
	{nCheckFlag = 10, nTipId = 2, nCtrId = 8, nUITag = NMAINSCENECHILDTAG.LoginChgPassWord, nEditId1 = 88, nEditId2 = 89, nEditId3 = 90},
	{nCheckFlag = 11, nTipId = 2, nCtrId = 8, nUITag = NMAINSCENECHILDTAG.LoginChgPassWord, nEditId1 = 89, nEditId2 = 90},
	{nCheckFlag = 12, nTipId = 5, nCtrId = 8, nUITag = NMAINSCENECHILDTAG.LoginChgPassWord, nEditId1 = 89, nEditId2 = 90},
	{nCheckFlag = 13, nTipId = 8, nCtrId = 8, nUITag = NMAINSCENECHILDTAG.LoginChgPassWord, nEditId1 = 89, nEditId2 = 90},

	};
end

--获取想要的数据ID
function p.GetIdByFlag(nChkFlag, nDataFlag)
	for i, v in ipairs(p.tbCommonData) do
		if nChkFlag == v.nCheckFlag then
			if nDataFlag == p.ENUM_DATATYPE_FLAG.TYPE_TIP_ID then
				return v.nTipId;
			elseif nDataFlag == p.ENUM_DATATYPE_FLAG.TYPE_CTR_ID then
				return v.nCtrId;
			elseif nDataFlag == p.ENUM_DATATYPE_FLAG.TYPE_UI_TAG then
				return v.nUITag;
			elseif nDataFlag == p.ENUM_DATATYPE_FLAG.TYPE_EDT_ID1 then
				return v.nEditId1;
			elseif nDataFlag == p.ENUM_DATATYPE_FLAG.TYPE_EDT_ID2 then
				return v.nEditId2;
			elseif nDataFlag == p.ENUM_DATATYPE_FLAG.TYPE_EDT_ID3 then
				return v.nEditId3;			
			end
		end
	end
end


--显示错误提示信息nFlag校验的数据类型
function p.ShowErrorTipInfo(nFlag, bGameSceneFlag)
	
	local scene = nil;
	if bGameSceneFlag == nil then
		scene = GetSMLoginScene();
	else
		scene = GetSMGameScene();
	end
	
	if scene == nil then
		return false;
	end
	
	--获取需要的各个字段信息
	local nUItag = p.GetIdByFlag(nFlag, p.ENUM_DATATYPE_FLAG.TYPE_UI_TAG);
	local nCtrId = p.GetIdByFlag(nFlag, p.ENUM_DATATYPE_FLAG.TYPE_CTR_ID);
	local nTipId = p.GetIdByFlag(nFlag, p.ENUM_DATATYPE_FLAG.TYPE_TIP_ID);
	
	if nUItag == nil or nCtrId == nil or nTipId == nil then
		return;
	end
	
	local pLayer = GetUiLayer(scene, nUItag);
	if not pLayer then
		return;
	end
	
	local strShow = "SELF_SDK_TIP" .. nTipId;
	SetLabel(pLayer, nCtrId, GetTxtPri(strShow));
	
	
	--清除一些编辑控件的内容
	local nEditId1 = p.GetIdByFlag(nFlag, p.ENUM_DATATYPE_FLAG.TYPE_EDT_ID1);
	local nEditId2 = p.GetIdByFlag(nFlag, p.ENUM_DATATYPE_FLAG.TYPE_EDT_ID2);
	local nEditId3 = p.GetIdByFlag(nFlag, p.ENUM_DATATYPE_FLAG.TYPE_EDT_ID3);
	LoginCommon.SetEditData(pLayer, nEditId1);
	LoginCommon.SetEditData(pLayer, nEditId2);
	LoginCommon.SetEditData(pLayer, nEditId3);
end




--获取编辑控件的内容
function p.GetEditData(pLayer, EditID)

	local retData = nil;
	local uiNode = GetUiNode(pLayer, EditID);
	if CheckP(uiNode) then
		local edit = ConverToEdit(uiNode);
		retData = edit:GetText();
	end
	
	return retData;
end

--设置编辑控件的内容
function p.SetEditData(pLayer, EditID, pszData)
	if pLayer == nil or EditID == nil then
		return;
	end
	
	local uiNode = GetUiNode(pLayer, EditID);
	if CheckP(uiNode) then
		local edit = ConverToEdit(uiNode);
		
		if pszData ~= nil then
			edit:SetText(pszData);
		else
			edit:SetText("");
		end
	end
end


--验证数据合法性, Pdata要校验的数据 , nFlag数据类型
function p.CheckDataValidity(Pdata, nFlag)
	--数据类型验证(字母,数字,下划线)
	
	local bGameSceneFlag = nil;
	if nFlag >= p.CHECK_FLAG.TYPE_CHG_PWD_OLD and
	   nFlag <= p.CHECK_FLAG.TYPE_CHG_OLD_NEW then
	   bGameSceneFlag = true;
	end
	
	local nLen = string.len(Pdata);
	if nLen == 0 then
		p.ShowErrorTipInfo(nFlag, bGameSceneFlag);
		return false;
	end
	


	for i = 1, nLen do
		local nAscleNum = string.byte(Pdata, i);
		if not ( (nAscleNum >= 48 and  nAscleNum <= 57)    --为数字
		         or(nAscleNum >= 65 and  nAscleNum <= 90)  --小写字母
		         or(nAscleNum >= 97 and  nAscleNum <= 122) --大写字母
		         or (nAscleNum == 95)                     --下划线              
		         ) then
			 
			p.ShowErrorTipInfo(nFlag, bGameSceneFlag);
			return false; 
		end
	end
	
	local nMin = 0;
	local nMax = 0;
	
	if p.CHECK_FLAG.TYPE_LOG_ACNT == nFlag 
		or p.CHECK_FLAG.TYPE_REG_ACNT == nFlag then --账号校验
		nMin = p.NUM_LIMITE.ACCOUNT_NUM_MIN;
		nMax = p.NUM_LIMITE.ACCOUNT_NUM_MAX;
	else
		nMin = p.NUM_LIMITE.PASSWORD_NUM_MIN;
		nMax = p.NUM_LIMITE.PASSWORD_NUM_MAX;
	end



	--字符个数验证
	if Pdata == nil or  nLen < nMin or nLen > nMax then
		p.ShowErrorTipInfo(nFlag, bGameSceneFlag);
		return false
	end
	
	return true;
end



--关闭某个页面
function p.CloseUI(nTag)
	local scene = GetSMLoginScene();
	if scene == nil then
		return false;
	end
	
	local pLayer = GetUiLayer(scene, nTag);
	if CheckP(pLayer) then
		scene:RemoveChildByTag(nTag, true );
		return true;
	end
	return false;
end



--给数据strData加密,返回加密后数据
function p.GetEncryptString(strData)
	--[[
	local strRet = "";
	local strTemp = "";
	local nLen = string.len(strData);
	strTemp = string.reverse(strData); 
	
	for i = 1, nLen do
		local nAscleNum = string.byte(strTemp, i);
		local nNum = nAscleNum - 30 - i;
		if nNum == string.byte("=")
		   or nNum == string.byte("&") 
		   or nNum == string.byte("?")
		   or nNum == string.byte(" ")then
		   nNum = nNum + 1;
		end
		strRet = strRet .. string.char(nNum);
	end
	]]
	
	return strData;
end



--创建登入信息表
function p.CreateSelfLoginTable()
    LogInfo("Sqlite:p.CreateSelfLoginTable");
    local isExists = Sqlite_IsExistTable(SelfLoginTableName);
    if(not isExists) then
        LogInfo("Sqlite:CreateSelfLoginTable sql:[%s]",SelfLoginCreateScript);
        Sqlite_ExcuteSql(SelfLoginCreateScript);
    end
end

function p.SelectSelfLogin(nID)
    LogInfo("p.SelectSelfLoginTable");
    
    local total = Sqlite_SelectData(string.format(SelfLoginSelect, nID),4);
    LogInfo("p.SelectSelfLoginTable total:[%d]",total);
    local record = {};
    for i=1,total do
        local index = i - 1;
        
        record.ID = Sqlite_GetColDataN(index, 0)
        record.nAutoLogin = Sqlite_GetColDataN(index, 1);
        record.Account = Sqlite_GetColDataS(index, 2);
        record.PassWord = Sqlite_GetColDataS(index, 3);
        
        LogInfo("p.SelectSelfLoginTable ID:[%d], nAutoLogin:[%d], Account:[%s], PassWord:[%s]",record.ID,record.nAutoLogin,record.Account,record.PassWord);
    end
    
    return record;
end


function p.InsertSelfLogin(record)

    LogInfo("p.InsertSelfLogin");
    local nIsExists = Sqlite_SelectData(string.format(SelfLoginSelect, record.ID), 4);
    
    if(nIsExists > 0) then
        Sqlite_ExcuteSql(string.format(SelfLoginUpdate, record.nAutoLogin, record.Account, record.PassWord, record.ID));
        return false;
    else
        Sqlite_ExcuteSql(string.format(SelfLoginInsert, record.ID, record.nAutoLogin, record.Account, record.PassWord));
        return true;
    end
end




