---------------------------------------------------
--描述: 登入修改密码页面
--时间: 2013.6.20
--作者: tzq
---------------------------------------------------
LoginChgPassWord = {}
local p = LoginChgPassWord;

local ID_EDIT_OLD_PASSWORD     = 88;    --原密码输入控件
local ID_EDIT_NEW_PASSWORD    = 89;    --新密码输入控件
local ID_EDIT_SEC_PASSWORD    = 90;    --新密码第二次输入控件
local ID_BTN_OK        = 10;    --确定
local ID_BTN_CANCEL    = 86;    --离开
p.CurLayer = nil;
p.FstPassWord = nil;
p.SedPassWord = nil;
p.Account = nil;


function p.LoadUI()
	
	--local scene = GetSMLoginScene();	
	--local scene = GetSMGameScene();
	local scene = GetRunningScene();
	
	if scene == nil then
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		return;
	end
    
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.LoginChgPassWord);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);
	p.CurLayer = layer;
	
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return;
	end
	uiLoad:Load("Login/login_1_1.ini", layer, p.OnUIEvent, 0, 0);
	
	p.InitData();
end

function p.InitData()
     --设置密码项为不可见模式 
    local uiNode = GetUiNode(p.CurLayer, ID_EDIT_OLD_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMinLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MIN);
        edit:SetMaxLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MAX);
        edit:SetPassword(true);
    end
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_NEW_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMinLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MIN);
        edit:SetMaxLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MAX);
        edit:SetPassword(true);
    end
    
    
    --设置密码项为不可见模式 
    uiNode = GetUiNode(p.CurLayer, ID_EDIT_SEC_PASSWORD);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetMinLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MIN);
        edit:SetMaxLength(LoginCommon.NUM_LIMITE.PASSWORD_NUM_MAX);
        edit:SetPassword(true);
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent hit tag = %d", tag);
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_OK == tag then  --确定

			--原密码校验
			local OldPassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_OLD_PASSWORD);
			if not LoginCommon.CheckDataValidity(OldPassWord, LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_OLD) then
				return true;
			end	
			
			--新密码校验
			p.FstPassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_NEW_PASSWORD);
			if not LoginCommon.CheckDataValidity(p.FstPassWord, LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_FST) then
				return true;
			end	
			
			--两次密码输入一致性校验
			local SndPassWord = LoginCommon.GetEditData(p.CurLayer, ID_EDIT_SEC_PASSWORD);
			if p.FstPassWord ~= SndPassWord then
				LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_SND, true);
				return true;
			end
			
			--旧密码与新密码一致性校验
			if OldPassWord == p.FstPassWord then
				LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_CHG_OLD_NEW, true);
				return true;
			end
			
			local record = SqliteConfig.SelectSelfLogin(1);
			if record == nil then
				return true;
			end
			p.Account = record.Account;
			
			--发起修改密码请求
			SendHttpMsgLogin.HttpSendChangePassWord(p.Account, OldPassWord, p.FstPassWord);
		
		elseif ID_BTN_CANCEL == tag then          --离开                     
			--LoginCommon.CloseUI(NMAINSCENECHILDTAG.LoginChgPassWord);
			--LoginUI.LoadUI();
			CloseUI(NMAINSCENECHILDTAG.LoginChgPassWord);
			
		elseif 	(ID_EDIT_OLD_PASSWORD == tag 
		        or ID_EDIT_NEW_PASSWORD == tag 
		        or ID_EDIT_SEC_PASSWORD == tag) then
		        
			local uiNode1 = GetUiNode(p.CurLayer, ID_EDIT_OLD_PASSWORD);
			local uiNode2 = GetUiNode(p.CurLayer, ID_EDIT_NEW_PASSWORD);
			local uiNode3 = GetUiNode(p.CurLayer, ID_EDIT_SEC_PASSWORD);	
			local edit1 = ConverToEdit(uiNode1);
			local edit2 = ConverToEdit(uiNode2);
			local edit3 = ConverToEdit(uiNode3);
			edit1:SetFocus(false);
			edit2:SetFocus(false);
			edit3:SetFocus(false);
			
			if ID_EDIT_OLD_PASSWORD == tag then
				edit1:SetFocus(true);
			elseif ID_EDIT_NEW_PASSWORD == tag then
				edit2:SetFocus(true);
			elseif ID_EDIT_SEC_PASSWORD == tag then
				edit3:SetFocus(true);
			end
		end
		--输入键盘回调响应
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then

		--[[
		if tag == ID_EDIT_OLD_PASSWORD then     
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				--原密码校验
				LoginCommon.CheckDataValidity(edit:GetText(), LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_OLD);
			end
			
		elseif tag == ID_EDIT_NEW_PASSWORD then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.FstPassWord = edit:GetText();
				--第一次输入密码校验
				LoginCommon.CheckDataValidity(edit:GetText(), LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_FST);
			end	
			
		elseif tag == ID_EDIT_SEC_PASSWORD then
			local edit = ConverToEdit(uiNode);
			if CheckP(edit) then
				p.SedPassWord = edit:GetText();
				
				--第二次输入密码校验
				if p.FstPassWord ~= p.SedPassWord then
					edit:SetText("");
					LoginCommon.ShowErrorTipInfo(LoginCommon.CHECK_FLAG.TYPE_CHG_PWD_SND);
				end
			end			
		end		
		]]
	end

	return true;
end


--修改密码成功保存至数据库
function p.LoginChgSuccess()
	CloseUI(NMAINSCENECHILDTAG.LoginChgPassWord);
	local record = {};	record.ID = 1;	record.nAutoLogin = 0;	record.Account = p.Account;	record.PassWord = p.FstPassWord;	SqliteConfig.InsertSelfLogin(record);
end
