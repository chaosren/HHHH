---------------------------------------------------
--描述: 跨服竞技场主页面
--时间: 2013.8.30
--作者: tzq
---------------------------------------------------
CrossArenaUI = {}
local p = CrossArenaUI;

local ID_BTN_CLOSE = 5;   --关闭按钮
local ID_BTN_RULE = 21;   --规则按钮
local ID_BTN_REWARD = 20;   --奖励查看
local ID_BTN_ADD = 19;   --增加挑战次数按钮
local ID_TEXT_TIMES = 31;   --剩余挑战次数
local ID_LIST_CONTAINER = 1001;
local ID_BTN_CHALLEAGE = 50;
local ID_TEXT_RANK = 4;  --排名
local ID_TEXT_NAME = 5;  --姓名
local ID_TEXT_EMONEY = 3029;  --金币显示



local ListViewSize = CGSizeMake(198*CoordScaleX, 29.6*CoordScaleY);

p.tbTopThreeId = {{idPic = 51, idText = 22}, {idPic = 52, idText = 23}, {idPic = 53, idText = 24}};
p.tbRankId = {81, 82, 83, 84, 85};

p.CrossArenaListInfo = {};
p.UserInfo = {};  
p.tbNumPics = {};

p.DbCrossArenaConfig = {};

p.nShowIndex = -1;   --要显示的索引


--要用的数据对应的id枚举  
p.DATA_CONFIG_ID =
{
	ENUM_WORLDBATTLE_CONFIG_TOP_AMOUNT = 1,  --競技場前幾名可參加
	ENUM_WORLDBATTLE_CONFIG_BASE_COST = 6,   --初始消耗金币数
	ENUM_WORLDBATTLE_CONFIG_ADD_COST  = 7,   --每次增加金币数
};

function p.LoadUI()
    ArenaUI.isInChallenge = 11;
    --------------------获得游戏主场景------------------------------------------
	local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.CrossArenaUI);
	layer:SetFrameRect(RectFullScreenUILayer); 
	scene:AddChildZ(layer, UILayerZOrder.NormalLayer);

	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("DragonRank/DragonRank.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free(); 

    p.InitDbData();
	p.RefreshUI();
	return true;
end

function p.InitDbData()
	p.nShowIndex = -1;
    ids = GetDataBaseIdList("worldbattle_config");
    p.DbCrossArenaConfig = {};
	for i,v in ipairs(ids) do
		p.DbCrossArenaConfig[v] = GetDataBaseDataN("worldbattle_config", v, DB_WORLDBATTLE_CONFIG.VALUE); 
	end
    
end


function p.GetDbWorldBattleConfigValue(nId)
	local nRet = p.DbCrossArenaConfig[nId];

	if nRet == nil then
		nRet = 0;
	end

	return nRet;
end

function p.RefreshUI()
	--刷新前三名数据以及玩家数据信息
	p.RefreshTopThreeAndUserInfo();

	--刷新金币显示
	p.RefreshMoney();
	 
	--刷新排行版
	p.RefreshRankList();
end

--刷新排行版
function p.RefreshRankList()
	local layer = GetSMGameSceneLayerByTag(NMAINSCENECHILDTAG.CrossArenaUI);
	local ListContainer  = GetScrollViewContainer(layer, ID_LIST_CONTAINER);
    
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(ListViewSize);
    ListContainer:EnableScrollBar(true);
    local nBeginViewIndex = ListContainer:GetBeginIndex();
    ListContainer:RemoveAllView();    
		
	--玩家在排名列表的第几个位置	  
	local nIndex = 0;
    --设置当前要显示的说明信息
	for i, v in pairs(p.CrossArenaListInfo) do
		if i > 3 then
			p.AddViewItem(ListContainer, i-3, v, "DragonRank/DragonRank_list.ini");
		end
		
		if v.nRank == p.UserInfo.usRank then
			--减去3是因为前三名也是放在同一个列表中
			nIndex = i - 3;
		end
	end
	
	if (p.nShowIndex == -1) then
		--同一个页面只能显示7行的信息，为了一开始就能够看到玩家自己的信息
		if nIndex > 7 then 
			nIndex = nIndex - 7;
		else
			nIndex = 0;
		end
		p.nShowIndex = nIndex;
	else
		p.nShowIndex = nBeginViewIndex;
    end

	ListContainer:ShowViewByIndex(p.nShowIndex); 
end

function p.AddViewItem(container, nIndex, info, uiFile)
    
    local view = createUIScrollView();
    if view == nil then
        return;
    end
    
    container:SetViewSize(ListViewSize);
    
	view:Init(false);
	view:SetViewId(nIndex);
	view:SetTag(nIndex);  
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
    
    uiLoad:Load(uiFile, view, p.OnViewUIEvent, 0, 0);
    
    local btn = GetButton(view, ID_BTN_CHALLEAGE);
    btn:SetParam1(info.nRank);   
    
    SetLabel(view, ID_TEXT_RANK, SafeN2S(info.nRank)); 
    SetLabel(view, ID_TEXT_NAME, info.szName.."  lv.".. info.ucLevel); 
    
	if info.nRank == p.UserInfo.usRank then
		local textName = GetLabel(view, ID_TEXT_NAME);
		local textRank = GetLabel(view, ID_TEXT_RANK);	
		textName:SetFontColor(ccc4(245, 0, 0, 255));
		textRank:SetFontColor(ccc4(245, 0, 0, 255));	
		btn:SetVisible(false);
	end
end


function p.OnViewUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local btn = ConverToButton(uiNode);
        
        if(btn == nil) then
            return;
        end

        if ID_BTN_CHALLEAGE == tag then  
			if p.UserInfo.usRank == 0 then
				local nNeedNum = p.GetDbWorldBattleConfigValue(p.DATA_CONFIG_ID.ENUM_WORLDBATTLE_CONFIG_TOP_AMOUNT);
				CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("CrossArena_03"), nNeedNum));
			elseif CrossArenaUI.UserInfo.ucLeftCount == 0 then
				CommonDlgNew.ShowYesDlg(GetTxtPri("CrossArena_05"));
			else
				--发送挑战请求   
				local nId = btn:GetParam1();
				local strName = "";
				--增加二次確認窗口
				
				for i, v in pairs(p.CrossArenaListInfo) do
					if v.nRank == nId then
						strName = v.szName;
					end
				end
				
				CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("AREAUI_T6").. strName, p.onChallengeDlg, nId);
				--MsgCrossArena.MsgSendAcrossArenaAction(MsgCrossArena.EOPERATE_ACTION.EOPERATE_ACTION_CHALLENGE, nId);	
			end
        end
    end
	return true;
end


function p.onChallengeDlg(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
    	MsgCrossArena.MsgSendAcrossArenaAction(MsgCrossArena.EOPERATE_ACTION.EOPERATE_ACTION_CHALLENGE, param);	
    end
end


--刷新前三名数据以及玩家数据信息
function p.RefreshTopThreeAndUserInfo()
	local layer = GetSMGameSceneLayerByTag(NMAINSCENECHILDTAG.CrossArenaUI);
	
	if layer == nil then
		return;
	end
	
	--显示前三名图片以及名字
	for i, v in ipairs(p.tbTopThreeId) do 
		
		local info = p.CrossArenaListInfo[i];
		if info == nil then
			return;
		end
		
		local ctrlPic = GetImage(layer, v.idPic);  
		local pic = GetCrossArenaUIPlayerHeadPic(info.nIdLookface);
		ctrlPic:SetPicture(pic);
		SetLabel(layer, v.idText, info.szName.."  lv.".. info.ucLevel);
	end

	--显示玩家当前名次
	p.SetPicFromNum(p.UserInfo.usRank);

	--显示玩家还可以挑战次数
	p.RefreshChallengeTimes()
end

--显示玩家还可以挑战次数
function p.RefreshChallengeTimes()
	local layer = GetSMGameSceneLayerByTag(NMAINSCENECHILDTAG.CrossArenaUI);
	SetLabel(layer, ID_TEXT_TIMES, SafeN2S(p.UserInfo.ucLeftCount));
end

function p.SetPicFromNum(nNum)
	local layer = GetSMGameSceneLayerByTag(NMAINSCENECHILDTAG.CrossArenaUI);
	
	--先清空旧有图片
	for i, v in ipairs(p.tbRankId) do
		local ctrlPic = GetImage(layer, v);  
		ctrlPic:SetPicture(nil);
	end
	
	local pool = _G.DefaultPicPool();
	p.tbNumPics = {};
	local N_W = 50;
	local N_H = 52;
   
 
   if nNum < 10 then
		local pic1 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
		local ctrlPic1 = GetImage(layer, p.tbRankId[3]); 
		
		pic1:Cut( _G.CGRectMake( nNum*N_W, 0, N_W, N_H ) );
		ctrlPic1:SetPicture(pic1);
		
	elseif nNum < 100 then
		if math.fmod(nNum, 10) == 0 then
			local pic1 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic2 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local ctrlPic1 = GetImage(layer, p.tbRankId[2]); 
			local ctrlPic2 = GetImage(layer, p.tbRankId[3]); 
			
			--显示10位
			pic1:Cut( _G.CGRectMake( nNum/10*N_W, 0, N_W, N_H ) );
			ctrlPic1:SetPicture(pic1);
			
			--显示十
			pic2:Cut( _G.CGRectMake( 10*N_W, 0, N_W, N_H ) );
			ctrlPic2:SetPicture(pic2);
		else
			--显示10位
			local pic1 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic2 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic3 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local ctrlPic1 = GetImage(layer, p.tbRankId[2]); 
			local ctrlPic2 = GetImage(layer, p.tbRankId[3]); 
			local ctrlPic3 = GetImage(layer, p.tbRankId[4]); 
			
			pic1:Cut( _G.CGRectMake( math.floor(nNum/10)*N_W, 0, N_W, N_H ) );
			ctrlPic1:SetPicture(pic1);
			
			--显示十
			pic2:Cut( _G.CGRectMake( 10*N_W, 0, N_W, N_H ) );
			ctrlPic2:SetPicture(pic2);
			
			--显示个位
			pic3:Cut( _G.CGRectMake( math.fmod(nNum, 10)*N_W, 0, N_W, N_H ) );
			ctrlPic3:SetPicture(pic3);	
		end
	else
		--被百整除
		if math.fmod(nNum, 100) == 0 then
			local pic1 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic2 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local ctrlPic1 = GetImage(layer, p.tbRankId[2]); 
			local ctrlPic2 = GetImage(layer, p.tbRankId[3]); 
			
			--显示百位
			pic1:Cut( _G.CGRectMake( nNum/100*N_W, 0, N_W, N_H ) );
			ctrlPic1:SetPicture(pic1);
			
			--显示百
			pic2:Cut( _G.CGRectMake( 11*N_W, 0, N_W, N_H ) );
			ctrlPic2:SetPicture(pic2);
		--被十整除
		else
			local pic1 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic2 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic3 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic4 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local pic5 = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false); 
			local ctrlPic1 = GetImage(layer, p.tbRankId[1]); 
			local ctrlPic2 = GetImage(layer, p.tbRankId[2]); 
			local ctrlPic3 = GetImage(layer, p.tbRankId[3]); 
			local ctrlPic4 = GetImage(layer, p.tbRankId[4]); 
			local ctrlPic5 = GetImage(layer, p.tbRankId[5]); 
			
			--显示百位
			pic1:Cut( _G.CGRectMake( math.floor(nNum/100)*N_W, 0, N_W, N_H ) );
			ctrlPic1:SetPicture(pic1);
			
			--显示百
			pic2:Cut( _G.CGRectMake( 11*N_W, 0, N_W, N_H ) );
			ctrlPic2:SetPicture(pic2);
			
			--显示十位
			local nMod = math.fmod(nNum, 100);
			nMod = math.floor(nMod/10);
			pic3:Cut( _G.CGRectMake( nMod*N_W, 0, N_W, N_H ) );
			ctrlPic3:SetPicture(pic3);
			
			--显示十
			pic4:Cut( _G.CGRectMake( 10*N_W, 0, N_W, N_H ) );
			ctrlPic4:SetPicture(pic4);
			
			--显示个位
			nMod = math.fmod(nNum, 10);
			if nMod ~= 0 then
				pic5:Cut( _G.CGRectMake( nMod*N_W, 0, N_W, N_H ) );
				ctrlPic5:SetPicture(pic5);
			end
		end
	end
end


--增加挑战次数回调
local function DoAddChallengeTimes(id, param)
    if (CommonDlgNew.BtnOk == id ) then
        MsgCrossArena.MsgSendAcrossArenaAction(MsgCrossArena.EOPERATE_ACTION.EOPERATE_ACTION_ADD_CHALLENGE_COUNT_REQUEST);	
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BTN_CLOSE == tag then   
			CloseUI(NMAINSCENECHILDTAG.CrossArenaUI);
		elseif ID_BTN_RULE == tag then
			CrossArenaRule.LoadUI();
		elseif ID_BTN_REWARD == tag then
			if CrossArenaUI.UserInfo.usRank == 0 then
				local nNeedNum = p.GetDbWorldBattleConfigValue(p.DATA_CONFIG_ID.ENUM_WORLDBATTLE_CONFIG_TOP_AMOUNT);
				CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("CrossArena_03"), nNeedNum));
			else
				CrossArenaReward.LoadUI();	
			end
		elseif ID_BTN_ADD == tag then  --增加挑战次数请求
		
			if CrossArenaUI.UserInfo.usRank == 0 then
				local nNeedNum = p.GetDbWorldBattleConfigValue(p.DATA_CONFIG_ID.ENUM_WORLDBATTLE_CONFIG_TOP_AMOUNT);
				CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("CrossArena_03"), nNeedNum));
			else
				local nFirstNeed = p.GetDbWorldBattleConfigValue(p.DATA_CONFIG_ID.ENUM_WORLDBATTLE_CONFIG_BASE_COST);
				local nGrowNeed = p.GetDbWorldBattleConfigValue(p.DATA_CONFIG_ID.ENUM_WORLDBATTLE_CONFIG_ADD_COST);
				local nNeedEMoney = nFirstNeed + nGrowNeed * p.UserInfo.ucHasAddCount;
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("CrossArena_01"), nNeedEMoney), DoAddChallengeTimes, true );
			end
		end
	end
	
	return true;
end


function p.RefreshMoney()
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		return;
	end

    local layer = GetSMGameSceneLayerByTag(NMAINSCENECHILDTAG.CrossArenaUI);
    local nEMoney 	= GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_EMONEY);
    SetLabel(layer, ID_TEXT_EMONEY, fomatBigNumber(nEMoney)); 
end


GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"CrossArenaUI.RefreshMoney", p.RefreshMoney);