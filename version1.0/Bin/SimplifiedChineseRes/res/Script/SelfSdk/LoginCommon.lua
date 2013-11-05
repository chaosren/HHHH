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


--要验证的数据枚举
p.ENUM_DATA_FLAG =
{
    ACCOUNT_DATA = 0,   --账号数据
    PASSWORD_DATA = 1,  --密码数据
};


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
	if pLayer == nil then
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


--验证数据合法性， Pdata要校验的数据 
function p.CheckDataValidity(Pdata, nFlag)
	
	if p.ENUM_DATA_FLAG.ACCOUNT_DATA == nFlag then         	--账号数据验证合法性
		if Pdata == nil then
			CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP1"));
			return false
		else
			local nNum = string.len(Pdata);
			if nNum < 4 or nNum > 32 then
				CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP1"));	
				return false;
			end
		end
	elseif p.ENUM_DATA_FLAG.PASSWORD_DATA == nFlag then       --密码数据验证合法性
	
		if Pdata == nil then
			CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP2"));
			return false;
		else	
			local nNum = string.len(Pdata);
			if nNum < 6 or nNum > 12 then
				CommonDlgNew.ShowYesDlg(GetTxtPri("SELF_SDK_TIP2"));	
				return false;
			end
		end
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












