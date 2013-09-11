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

local ListViewSize = CGSizeMake(120*CoordScaleX, 20*CoordScaleY);

p.tbTopThreeId = {{idPic = 51, idText = 22}, {idPic = 52, idText = 23}, {idPic = 53, idText = 24}};
p.tbRankId = {81, 82, 83, 84, 85};

p.CrossArenaListInfo = {};
p.UserInfo = {};  
p.tbNumPics = {};
p.DbCrossArenaAwardData = {};
p.DbCrossArenaConfig = {};

--要用的数据对应的id枚举  
p.DATA_CONFIG_ID =
{
    ENUM_WORLDBATTLE_CONFIG_BASE_COST = 6,   --初始消耗金币数
    ENUM_WORLDBATTLE_CONFIG_ADD_COST  = 7,   --每次增加金币数
};

function p.LoadUI()
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
    --获取id集合
    local ids = GetDataBaseIdList("worldbattle_award_config");
    p.DbCrossArenaAwardData = {};

    for i,v in ipairs(ids) do
		local record = {};
		record.id = v;
		record.nMinRank = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.RANK_MIN);  
		record.nMaxRank = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.RANK_MAX);  
		record.nMoney = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.MONEY);  	
		record.nEMoney = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.EMONEY); 
		record.nExploit = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.EXPLOIT); 
		record.nRepute = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.REPUTE); 
		record.nSope = GetDataBaseDataN("worldbattle_award_config", v, DB_WORLDBATTLE_AWARD_CONFIG.SOPH); 	
		table.insert(p.DbCrossArenaAwardData, record);
    end
    
    ids = GetDataBaseIdList("worldbattle_config");
    p.DbCrossArenaConfig = {};
	for i,v in ipairs(ids) do
		p.DbCrossArenaConfig[v] = GetDataBaseDataN("worldbattle_config", v, DB_WORLDBATTLE_CONFIG.VALUE); 
	end
    
end


function p.GetDbWorldBattleConfigValue(nId)
    local nRet = p.DbBattleCityData[nId];
	
	if nRet == nil then
		nRet = 0;
	end

    return nRet;
end

function p.RefreshUI()
	--刷新前三名数据以及玩家数据信息
	p.RefreshTopThreeAndUserInfo();
	
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
    ListContainer:RemoveAllView();

    --设置当前要显示的说明信息
	for i, v in pairs(p.CrossArenaListInfo) do
		if i > 3 then
			p.AddViewItem(ListContainer, v, "DragonRank/DragonRank_list.ini");
		end
	end
end

function p.AddViewItem(container, info, uiFile)
    
    local view = createUIScrollView();
    if view == nil then
        return;
    end
    
    container:SetViewSize(ListViewSize);
    
    view:Init(false);
	--view:SetViewId(nId);
	--view:SetTag(nId);  
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
    SetLabel(view, ID_TEXT_NAME, info.szName); 
end


function p.OnViewUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local btn = ConverToButton(uiNode);
        
        if(btn == nil) then
            return;
        end

        if p.ViewCtrlId.btnCtr == tag then    
			 --发送挑战请求   
            local nId = btn:GetParam1();
            MsgCrossArena.MsgSendAcrossArenaAction(MsgCrossArena.EOPERATE_ACTION.EOPERATE_ACTION_CHALLENGE, nId);	
        end
    end
	return true;
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
		local ctrlPic = GetImage(layer, v.idPic);  
		local pic = GetCrossArenaUIPlayerHeadPic(info.nIdLookface);
		ctrlPic:SetImage(pic);
		SetLabel(layer, v.idText, info.szName);
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
		local ctrlPic = GetImage(layer, v.idPic);  
		ctrlPic:SetImage(nil);
	end
	
	local pool = _G.DefaultPicPool();
	local Pic = pool:AddPicture( _G.GetSMImgPath( "DragonRank/num.png"), false);  
	p.tbNumPics = {};
	local N_W = 50;
	local N_H = 52;
   
 
   if nNum < 10 then
		local pic1 = Pic;
		local ctrlPic = GetImage(layer, p.tbRankId[3]); 
		pic1:Cut( _G.CGRectMake( nNum*N_W, 0, N_W, N_H ) );
		ctrlPic:SetPicture(pic1);
	elseif nNum < 100 then
		if math.fmod(nNum, 10) == 0 then
			--显示10位
			local pic1 = Pic;
			local ctrlPic = GetImage(layer, p.tbRankId[2]); 
			pic1:Cut( _G.CGRectMake( nNum/10*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示十
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[3]); 
			pic1:Cut( _G.CGRectMake( 10*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
		else
			--显示10位
			local pic1 = Pic;
			local ctrlPic = GetImage(layer, p.tbRankId[2]); 
			pic1:Cut( _G.CGRectMake( nNum/10*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示十
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[3]); 
			pic1:Cut( _G.CGRectMake( 10*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示个位
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[4]); 
			local nMod = math.fmod(nNum, 10);
			pic1:Cut( _G.CGRectMake( nMod*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);	
		end
	else
		--被百整除
		if math.fmod(nNum, 100) == 0 then
			--显示百位
			local pic1 = Pic;
			local ctrlPic = GetImage(layer, p.tbRankId[2]); 
			pic1:Cut( _G.CGRectMake( nNum/100*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示百
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[3]); 
			pic1:Cut( _G.CGRectMake( 11*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
		--被十整除
		else
			--显示百位
			local pic1 = Pic;
			local ctrlPic = GetImage(layer, p.tbRankId[1]); 
			pic1:Cut( _G.CGRectMake( nNum/100*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示百
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[2]); 
			pic1:Cut( _G.CGRectMake( 11*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示十位
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[3]); 
			local nMod = math.fmod(nNum, 100);
			nMod = math.floor(nMod, 10);
			pic1:Cut( _G.CGRectMake( nMod*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示十
			pic1 = Pic;
			ctrlPic = GetImage(layer, p.tbRankId[4]); 
			pic1:Cut( _G.CGRectMake( 10*N_W, 0, N_W, N_H ) );
			ctrlPic:SetPicture(pic1);
			
			--显示个位
			nMod = math.fmod(nNum, 10);
			if nMod ~= 0 then
				pic1 = Pic;
				ctrlPic = GetImage(layer, p.tbRankId[5]); 
				pic1:Cut( _G.CGRectMake( nMod*N_W, 0, N_W, N_H ) );
				ctrlPic:SetPicture(pic1);
			end
		end
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
			CrossArenaReward.LoadUI();	
		elseif ID_BTN_ADD == tag then  --增加挑战次数请求
			MsgCrossArena.MsgSendAcrossArenaAction(MsgCrossArena.EOPERATE_ACTION.EOPERATE_ACTION_ADD_CHALLENGE_COUNT_REQUEST);	
		end
	end
	
	return true;
end
