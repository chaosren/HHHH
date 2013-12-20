---------------------------------------------------
--描述: 龙将兵法界面
--时间: 2012.8.10
--作者: tzq
---------------------------------------------------
DragonTacticUI = {}
local p = DragonTacticUI;


p.CurFocusBtnId   = 0;    --当前的焦点按钮

             --大話龍將
p.TabInfo = { TacticTabInfo = {LayerTag = 1001, tabBtnId = 24,  focusIndex = 1, FucInit = nil, 
                             FucRefresh = nil, FucOnEvent = nil, viewId = 7,},
              
             --遊戲助手         
             GameAssisInfo = {LayerTag = 1002,  tabBtnId = 25,  focusIndex = 2, FucInit = nil, 
                            FucRefresh = nil, FucOnEvent = nil, viewId = 7,},
                       
			  --現在為副本成就
             EveryDayActInfo  =  {LayerTag = 1003,  tabBtnId = 26,  focusIndex = 1, FucInit = nil, 
                                FucRefresh = nil, FucOnEvent = nil, viewId = 7,},
}


--获取记录类型   1为大话兵法  2为没钱了怎么办  3为我要升级   4打不过敌军怎么办 5 如何获得装备  6其他功能说明
p.TypeTitleDes = {GetTxtPri("DT_T1"),GetTxtPri("DT_T2"), GetTxtPri("DT_T3"), GetTxtPri("DT_T4"), GetTxtPri("DT_T5"),};

p.TacticInfoList = {};                 --大话兵法要显示的信息列表
p.GameAssisInfoList = {};       --游戏助手要显示的信息列表
p.EveryDayActList = {};           --精英特權要显示的信息列表

p.TacticStatusList = {};                 --大话兵法列表项更新状态表
p.EveryDayActStatusList = {};           --日常活动列表项更新状态表
local RectSubUILayer = CGRectMake(0, 39*CoordScaleY, 480*CoordScaleX, 275.0*CoordScaleY);
local TacticListSize = CGSizeMake(230*CoordScaleX, 36*CoordScaleY);

local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;
local CTR_BTN_2  = 2;
local CTR_BTN_CLOSE  = 5;
local CTR_PIC_FINISH  = 4;
local CTR_BTN_22 = 22;
local CTR_TEXT_3        = 3;
local CTR_TEXT_23       = 23;
local CTR_TEXT_21       = 21;
local CTRL_SPRITE_87    = 87;
local CTR_BTN_26 = 26;


--加载龙将兵法主界面
function p.LoadUI()
   
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加龙将兵法层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
    layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.DragonTactic);
	layer:SetDebugName( "DragonTactic" ); --@opt
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("achieve_BG.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);

    --local BtnEveryDay = GetButton(layer, CTR_BTN_26);
    --BtnEveryDay:SetVisible(false);
    --初始化标签页面的基本信息
    p.InitTabInfo();
    

   ------------------------------------------------------------------添加大话兵法层-----------------------------------------------------------------------
    local layerTactic = createNDUILayer();
	if layerTactic == nil then
		return false;
	end
	layerTactic:Init();
	layerTactic:SetTag(p.TabInfo.TacticTabInfo.LayerTag);
	layerTactic:SetFrameRect(RectSubUILayer);
    layerTactic:SetVisible(false);
	layer:AddChild(layerTactic);
    
    --初始化ui添加到 layer 层上
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("achieve_1.ini", layerTactic,  p.TabInfo.TacticTabInfo.FucOnEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    local BtnClose = GetButton(layerTactic, CTR_BTN_22);
    BtnClose:EnalbeGray(true);
    
    --p.GetTutorial(false);
    local animate = RecursivUISprite(layerTactic,{CTRL_SPRITE_87});
    animate:SetVisible(false);
    
    ------------------------------------------------------------------添加游戏助手层-----------------------------------------------------------------------
    local layerGameAssis = createNDUILayer();
	if layerGameAssis == nil then
		return false;
	end
	layerGameAssis:Init();
	layerGameAssis:SetTag(p.TabInfo.GameAssisInfo.LayerTag);
	layerGameAssis:SetFrameRect(RectSubUILayer);
    layerGameAssis:SetVisible(false);
	layer:AddChild(layerGameAssis);
    
    --初始化ui添加到 layer 层上
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("achieve_2.ini", layerGameAssis,  p.TabInfo.GameAssisInfo.FucOnEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();

    ------------------------------------------------------------------添加副本成就层-----------------------------------------------------------------------
    local layerEveryDayAct = createNDUILayer();
	if layerEveryDayAct == nil then
		return false;
	end
	layerEveryDayAct:Init();
	layerEveryDayAct:SetTag(p.TabInfo.EveryDayActInfo.LayerTag);
	layerEveryDayAct:SetFrameRect(RectSubUILayer);
    layerEveryDayAct:SetVisible(false);
	layer:AddChild(layerEveryDayAct);
    AssistantUI.AssisLayer = layerEveryDayAct;
    
    --初始化ui添加到 layer 层上
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("achieve_4.ini", layerEveryDayAct,  p.TabInfo.EveryDayActInfo.FucOnEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free(); 
    
     -------------------------------初始化数据------------------------------------     
    p.initData();
    p.ChangeTab(p.TabInfo.TacticTabInfo.tabBtnId);

    return true;
end

--新手指引提示
function p.GetTutorial(nFlag)
    local layer = p.GetLayerByTag(p.TabInfo.TacticTabInfo.LayerTag); 
	if ( p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId ) then -- 副本成就里的提示
		layer = p.GetLayerByTag(p.TabInfo.EveryDayActInfo.LayerTag);
	end   
    local animate = RecursivUISprite(layer,{CTRL_SPRITE_87});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."jiantx03.spr");
    animate:SetVisible(nFlag);
end


-----------------------------初始化标签页面的基本信息---------------------------------
function p.InitTabInfo()
	p.TabInfo.TacticTabInfo.focusIndex = 1;
	p.TabInfo.GameAssisInfo.focusIndex = 2;
	p.TabInfo.EveryDayActInfo.focusIndex = 1;
        
	p.TabInfo.TacticTabInfo.FucInit = p.TacticInit;
	p.TabInfo.TacticTabInfo.FucRefresh = p.TacticRefresh;
	p.TabInfo.TacticTabInfo.FucOnEvent = p.TacticOnEvent;

	p.TabInfo.GameAssisInfo.FucInit = p.GameAssisInit;
	p.TabInfo.GameAssisInfo.FucRefresh = p.GameAssisRefresh;
	p.TabInfo.GameAssisInfo.FucOnEvent = p.GameAssisOnEvent;
   
	p.TabInfo.EveryDayActInfo.FucInit = p.EveryDayActicInit;
	p.TabInfo.EveryDayActInfo.FucRefresh = p.EveryDayActRefresh;
	p.TabInfo.EveryDayActInfo.FucOnEvent = p.EveryDayActOnEvent;
end

-----------------------------背景层事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    --LogInfo("p.OnUIEvent hit tag = %d", tag);
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        --关闭按钮      
        if CTR_BTN_CLOSE == tag then              
            p.FreeDate();        
			CloseUI(NMAINSCENECHILDTAG.DragonTactic);
        else
        	--处理几个标签页的按钮
        	for i, v in pairs(p.TabInfo) do
        	    if v.tabBtnId == tag then
        	        p.ChangeTab(tag);
        	        break;
        	    end
        	end
        end
    end
    
	return true;
end

-------------------------------关闭页面时释放一些数据----------------------------------------
function p.FreeDate()
    AssistantUI.freeData();
end  
-------------------------------切换标签界面----nBtnId要切换的tab页面的按钮id----------------------------------------
function p.ChangeTab(nBtnId)
    
    if (nBtnId == nil) or (p.CurFocusBtnId == nBtnId) then 
        return;
    end
    
    p.CurFocusBtnId = nBtnId;
    
    local layerMain = p.GetMainLayer();
    --设置显示的layer页面
    for i,v in pairs(p.TabInfo) do
        local btn = GetButton(layerMain, v.tabBtnId);
        local layer = p.GetLayerByTag(v.LayerTag);    
        if ( layer ~=nil ) then
        	if v.tabBtnId == nBtnId then
            	btn:TabSel(true);            --当前按钮设置为常亮
    	        layer:SetVisible(true);   --设置当前层为活动层
    	    else
    	        btn:TabSel(false);           --其他按钮去掉常亮标志
    	        layer:SetVisible(false);   --设置当前层为非活动层
    	    end
    	end
    end

    p.RefreshUI(nBtnId);    
end
---------------------------通过子层标签获取层--------------------------------------
function p.GetLayerByTag(SublayerTag)
    local layer = p.GetMainLayer();
    local Sublayer = GetUiLayer(layer, SublayerTag);
    if(Sublayer == nil) then
        --LogInfo("p.GetLayerByTag:[%d] is nil!", SublayerTag);
    end
    return Sublayer;
end


---------------------------初始化龙将兵法各个标签页要显示的内容--------------------------------------
function p.initData()
    p.TacticInfoList = {};                 --大话兵法要显示的信息列表
    p.GameAssisInfoList = {};       --游戏助手要显示的信息列表
    p.EveryDayActList = {};           --副本成就要显示的信息列表
    p.CurFocusBtnId   = 0;             --默认的当前page页面
   
    for i, v in pairs(p.TabInfo) do 
        if v.FucInit ~= nil then
           v.FucInit();
        end
    end
end
---------------------------获取龙将兵法的主页面层--------------------------------------
function p.GetMainLayer()
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DragonTactic);
    return layer;
end


---------------------------刷新龙将兵法的主页面层数据--------------------------------------
function p.RefreshUI(nBtnId)

    for i, v in pairs(p.TabInfo) do
         if v.tabBtnId == nBtnId then
            if v.FucRefresh ~= nil then
               v.FucRefresh();
            end
        end
    end
end
---------------------------添加控件元素-------------------------------------
function p.AddViewItem(container, nIndex, uiFile)
    
    local view = createUIScrollView();
    if view == nil then
        --LogInfo("p.LoadUI createUIScrollView failed");
        return;
    end
    
    container:SetViewSize(TacticListSize);
    
    view:SetPopupDlgFlag(true);
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
    
    --游戏助手的标题界面添加不同的ini
    if (p.CurFocusBtnId == p.TabInfo.GameAssisInfo.tabBtnId) and (p.GameAssisInfoList[nIndex].Type > 10) then
        --LogInfo("Type = %d, nIndex = %d", p.GameAssisInfoList[nIndex].Type, nIndex);  
        uiLoad:Load("achieve_2_L.ini", view, 0, 0, 0);
    else
        uiLoad:Load(uiFile, view, p.OnViewUIEvent, 0, 0);
    end

    p.refreshViewItem(view, nIndex);
end

---------------------------获取当前数据列表-------------------------------------
function p.GetCurDataInfoList()
    if p.CurFocusBtnId == p.TabInfo.TacticTabInfo.tabBtnId then
        return p.TacticInfoList;
    elseif p.CurFocusBtnId == p.TabInfo.GameAssisInfo.tabBtnId then
        return p.GameAssisInfoList;
    elseif p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId then    
        return p.EveryDayActList;
    end
end



---------------------------刷新控件元素-------------------------------------
function p.refreshViewItem(view, iNum)
     if(i==0) then
        return;
    end
    
    local btn = GetButton(view, CTR_BTN_2);
    btn:SetParam1(iNum);   

    local DataList = p.GetCurDataInfoList();
    
    if  DataList ~= nil then
        local info = DataList[iNum]; 
        local TextLable = GetLabel(view, CTR_TEXT_3); 
        
        if string.find(info.Title, "(特權)") ~= nil then
           TextLable:SetFontColor(ccc4(240, 255, 0, 255));
        end
        
        SetLabel(view, CTR_TEXT_3, info.Title); 
        
        if ( p.CurFocusBtnId == p.TabInfo.TacticTabInfo.tabBtnId ) or ( p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId ) then
            --LogInfo("info.Status = %d", info.Status);  
            local PicFinish = GetImage(view, CTR_PIC_FINISH);    
            if info.Status ~= 2 then
                PicFinish:SetVisible(false);
            else
                PicFinish:SetVisible(true);
            end
        end
    end
    
    return;
end

------------------列表控件按键响应-------------------------------
function p.OnViewUIEvent(uiNode, uiEventType, param)
 
    --LogInfo("p.OnViewUIEvent, p.CurFocusBtnId = %d, CTR_BTN_22 = %d", p.CurFocusBtnId, CTR_BTN_22); 
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local btn = ConverToButton(uiNode);
        --btn:TabSel(true);            --当前按钮设置为常亮
        --btn:SetFocus(true);
        
        if(btn == nil) then
            --LogInfo("btn is nil!");
            return;
        end
        
       local layer = nil;
       local FocusIndex = nil;   
       for i, v in pairs(p.TabInfo) do
           if v.tabBtnId == p.CurFocusBtnId then
               layer = p.GetLayerByTag(v.LayerTag);
               p.SetListFocus(btn:GetParam1());
               v.focusIndex = btn:GetParam1();
               FocusIndex = v.focusIndex;
               break;
            end
       end

        --获取当前标签下的数据list
        local DataList = p.GetCurDataInfoList();
        local Info = DataList[FocusIndex];
        SetLabel(layer, CTR_TEXT_23, Info.Describe);  
        
        --大话兵法页面的特殊处理
        if ( p.CurFocusBtnId == p.TabInfo.TacticTabInfo.tabBtnId ) or (  p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId ) then
            local strShowText = string.format(GetTxtPri("AwardMoneyStr"), Info.AwardMoney);
            if Info.AwardItem ~= 0 then
                local ItemName = ItemFunc.GetName(Info.AwardItem);
                strShowText = strShowText .. string.format(GetTxtPri("AwardItemStr"), ItemName, Info.AwardItemCount);
				if ( Info.AwardItem2 ~= nil and Info.AwardItemCount2 ~= 0 ) then
					local ItemName2 = ItemFunc.GetName(Info.AwardItem2);
					strShowText = strShowText .. string.format(GetTxtPri("AwardItemStr"), ItemName2, Info.AwardItemCount2);
				end 
            end
            SetLabel(layer, CTR_TEXT_21, strShowText); 
            
            --设置领取奖励按钮是否可用
            local BtnClose = GetButton(layer, CTR_BTN_22);
            if Info.Status == 1 then
                BtnClose:EnalbeGray(false);
                p.GetTutorial(true);
            else 
                BtnClose:EnalbeGray(true);
                p.GetTutorial(false);
            end
        end
        
	end
    
	return true;
end


---------------------------获取列表控件------------
function p.GetViewContainer(nBtnId)

    local svc = nil;
    if nBtnId == p.TabInfo.TacticTabInfo.tabBtnId then
        local Sublayer = p.GetLayerByTag(p.TabInfo.TacticTabInfo.LayerTag);    
        svc	= GetScrollViewContainer(Sublayer, p.TabInfo.TacticTabInfo.viewId);
    elseif nBtnId == p.TabInfo.GameAssisInfo.tabBtnId then
        local Sublayer = p.GetLayerByTag(p.TabInfo.GameAssisInfo.LayerTag);    
        svc	= GetScrollViewContainer(Sublayer, p.TabInfo.GameAssisInfo.viewId);
    elseif nBtnId == p.TabInfo.EveryDayActInfo.tabBtnId then
        local Sublayer = p.GetLayerByTag(p.TabInfo.EveryDayActInfo.LayerTag);    
        svc	= GetScrollViewContainer(Sublayer, p.TabInfo.EveryDayActInfo.viewId);
    end
    
	return svc;
end


--------------------------------------大话兵法基本函数定义--------------------------------
function p.TacticInit()
    
    p.TacticInfoList = {};
    
    --获取id集合
    local ids = GetDataBaseIdList("achievement_config");
    
    for i,v in pairs(ids) do
        --获取记录类型   1为大话兵法  2为没钱了怎么办  3为我要升级   4打不过敌军怎么办 5 如何获得装备  6其他功能说明
        local nType = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.TYPE);

        if (nType == 1) then
            local Record = {};
            Record.id = v;
            Record.Status = 0;
            Record.AwardMoney = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.AWARD_MONEY);
            Record.AwardItem = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.AWARD_ITEM);   
            Record.AwardItemCount = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.ITEM_COUNT); 
            Record.AwardItem2 = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.AWARD_ITEM2);   
            Record.AwardItemCount2 = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.ITEM_COUNT2);      
            Record.Title = GetDataBaseDataS("achievement_config", v, DB_ACHIEVEMENT_CONFIG.TITLE);   
            Record.Describe = GetDataBaseDataS("achievement_config", v, DB_ACHIEVEMENT_CONFIG.DESCRIBE);    
            --LogInfo("p.TacticInit() id  = %d, Status = %d, nType = %d, Money = %d, Item = %d, Count = %d, Title = %s, Describe = %s", Record.id, Record.Status, nType, Record.AwardMoney, Record.AwardItem, Record.AwardItemCount, Record.Title, Record.Describe);          
            
            table.insert(p.TacticInfoList, Record);
        end
    end
    
    for i, v in pairs(p.TacticStatusList) do
        for j, k in pairs(p.TacticInfoList) do
            --LogInfo("function p.RefreshTacticListInfo id = %d, Type = %d, Status = %d", k.id,  v.Type, v.Status); 
            if (k.id == v.Type) then
                --改变兵法状态
                k.Status = v.Status;
                break;
            end
        end
    end
end


function sortData(a, b)
	if a.Status == b.Status then
		return a.id < b.id
	elseif a.Status == 0 then
		if b.Status == 1 then
			--1排0前
			return a.Status > b.Status;
		elseif b.Status == 2 then
			--0排2前
			return a.Status < b.Status;
		end 
	
	elseif a.Status == 1 then
		if b.Status == 0 then
			--1排0前
			return a.Status > b.Status;
		elseif b.Status == 2 then
			--1排2前
			return a.Status < b.Status;
		end	
	elseif a.Status == 2 then
		return a.Status < b.Status;
	end
end


--对数据进行排序,首先以id排序，先可领取在可完成之后已完成
function p.DragonSortData()
    local CurFocus = 1;
    local DataList = p.GetCurDataInfoList();
	table.sort(DataList, sortData);
end


--设置大话兵法当前焦点
function p.TacticSetCurFocus()
    local CurFocus = 1;
    local DataList = p.GetCurDataInfoList();
    if DataList == nil then
        return
    end
    
    --先获取第一个可领取的
    for i, v in pairs(DataList) do
        if v.Status == 1 then
            CurFocus = i;
            return CurFocus;
        end
    end
    
    --没有可领取的获取第一个未完成的
    for i, v in pairs(DataList) do
        if v.Status == 0 then
            CurFocus = i;
            return CurFocus;
        end
    end
    
    return CurFocus;   
end

function p.TacticRefresh()

    local layer = p.GetLayerByTag(p.TabInfo.TacticTabInfo.LayerTag);    
    
    local ListContainer  = p.GetViewContainer(p.TabInfo.TacticTabInfo.tabBtnId);
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(TacticListSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    
    --设置当前要显示的说明信息
    local ToltalNum = table.getn(p.TacticInfoList);
    
    --对数据进行排序(优先可领取，其次未完成，再次已完成)
	p.DragonSortData();
	--local CurFocus  = p.TacticSetCurFocus(); 
    local CurFocus  = 1; 
    
    
    --添加list列表元素
	if ToltalNum > 20 then
		ToltalNum = 20;
	end
	
    for i = 1, ToltalNum do
      p.AddViewItem(ListContainer, i, "achieve_1_L.ini");
    end



    p.SetListFocus(CurFocus); 
    
    p.TabInfo.TacticTabInfo.focusIndex = CurFocus;
    --显示当前的提示信息
    local Info = p.TacticInfoList[p.TabInfo.TacticTabInfo.focusIndex];
    SetLabel(layer, CTR_TEXT_23, Info.Describe);
    
    local strShowText = string.format(GetTxtPri("AwardMoneyStr"), Info.AwardMoney);
    if Info.AwardItem ~= 0 then
       local ItemName = ItemFunc.GetName(Info.AwardItem);
       strShowText = strShowText .. string.format(GetTxtPri("AwardItemStr"), ItemName, Info.AwardItemCount);
		if ( Info.AwardItem2 ~= nil and Info.AwardItem2 ~= 0 ) then
			local ItemName2 = ItemFunc.GetName(Info.AwardItem2);
			strShowText = strShowText .. string.format(GetTxtPri("AwardItemStr"), ItemName2, Info.AwardItemCount2);
		end
    end
    SetLabel(layer, CTR_TEXT_21, strShowText); 
    
    --设置领取奖励按钮是否可用
    local BtnClose = GetButton(layer, CTR_BTN_22);
    if Info.Status == 1 then
        BtnClose:EnalbeGray(false);
        p.GetTutorial(true);
    else 
        BtnClose:EnalbeGray(true);
        p.GetTutorial(false);
    end

    if p.TabInfo.TacticTabInfo.focusIndex > 7 then
        ListContainer:ShowViewByIndex(6); 
    else
        ListContainer:ShowViewByIndex(p.TabInfo.TacticTabInfo.focusIndex - 1); 
    end

end

function p.SetListFocus(nIndex)
    local ListContainer  = p.GetViewContainer(p.CurFocusBtnId);
    local ScrollView = nil;
    local BtnFocus = nil; 
    
    ----LogInfo("p.SetListFocus newIndex = %d", nIndex); 
        
    if p.CurFocusBtnId == p.TabInfo.TacticTabInfo.tabBtnId then

        if p.TabInfo.TacticTabInfo.focusIndex ~= nIndex then
            ScrollView = ListContainer:GetViewById(p.TabInfo.TacticTabInfo.focusIndex);
            BtnFocus = GetButton(ScrollView, CTR_BTN_2);
            BtnFocus: TabSel(false);
            BtnFocus: SetFocus(false);
            ----LogInfo("p.SetListFocus  oldIndex = %d set false", p.TabInfo.TacticTabInfo.focusIndex); 
        end
        
         ----LogInfo("p.SetListFocus  newindex = %d set true", nIndex); 
        ScrollView = ListContainer:GetViewById(nIndex);
        BtnFocus = GetButton(ScrollView, CTR_BTN_2);
        BtnFocus: TabSel(true);
        BtnFocus: SetFocus(true);  
        
    elseif p.CurFocusBtnId == p.TabInfo.GameAssisInfo.tabBtnId then
        ScrollView = ListContainer:GetViewById(p.TabInfo.GameAssisInfo.focusIndex);
        BtnFocus = GetButton(ScrollView, CTR_BTN_2);
        BtnFocus: TabSel(false);
        BtnFocus: SetFocus(false);   
        
        ScrollView = ListContainer:GetViewById(nIndex);
        BtnFocus = GetButton(ScrollView, CTR_BTN_2);
        BtnFocus: TabSel(true);  
        BtnFocus: SetFocus(true);  
        
    elseif p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId then

        if p.TabInfo.EveryDayActInfo.focusIndex ~= nIndex then
            ScrollView = ListContainer:GetViewById(p.TabInfo.EveryDayActInfo.focusIndex);
            BtnFocus = GetButton(ScrollView, CTR_BTN_2);
            BtnFocus: TabSel(false);
            BtnFocus: SetFocus(false);
            --LogInfo("p.SetListFocus  oldIndex = %d set false", p.TabInfo.EveryDayActInfo.focusIndex); 
        end
        
         --LogInfo("p.SetListFocus  newindex = %d set true", nIndex); 
        ScrollView = ListContainer:GetViewById(nIndex);
        BtnFocus = GetButton(ScrollView, CTR_BTN_2);
        BtnFocus: TabSel(true);
        BtnFocus: SetFocus(true);  
    end    
end


function p.TacticOnEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    --LogInfo("p.OnViewUIEvent, tag = %d, p.CurFocusBtnId = %d, CTR_BTN_22 = %d", tag, p.CurFocusBtnId, CTR_BTN_22); 
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == CTR_BTN_22 then
            --获取按键是否可以响应
            local DataList = p.GetCurDataInfoList();
            local Info = DataList[p.TabInfo.TacticTabInfo.focusIndex];
            
            --LogInfo("focusIndex = %d, Status = %d, Type = %d, count = %d", 
                           -- p.TabInfo.TacticTabInfo.focusIndex, Info.Status, Info.AwardItem, Info.AwardItemCount); 
                            
              --判断当前按钮是否可响应
            if Info.Status == 1 then
               --判断背包是否已经满
                if Info.AwardItem ~= 0 then
                     local nAmountLimit = GetDataBaseDataN("itemtype", Info.AwardItem, DB_ITEMTYPE.AMOUNT_LIMIT);
                     if (ItemFunc.IsBagFull(math.ceil(Info.AwardItemCount/nAmountLimit)-1)) then
                        return true;
                     end
                end
				if ( Info.AwardItem2 ~= nil and Info.AwardItem2 ~= 0 ) then
                     local nAmountLimit = GetDataBaseDataN("itemtype", Info.AwardItem2, DB_ITEMTYPE.AMOUNT_LIMIT);
                     if (ItemFunc.IsBagFull(math.ceil(Info.AwardItemCount2/nAmountLimit)-1)) then
                        return true;
                     end
				end
            
                p.SendTacticListViewStatus(Info.id);
                Info.Status = 2;
                return true;
            end
        end
    end
end

--------------------------------------游戏助手基本函数定义----------初始化时按照类型排好序----------------------
function p.GameAssisInitDataList(nTypeIndex)
    --获取id集合
    local ids = GetDataBaseIdList("achievement_config");
    
    local nTitleAddFlag = 0;

    for i,v in ipairs(ids) do
        --获取记录类型   1为大话兵法  2为没钱了怎么办  3为我要升级   4打不过敌军怎么办 5 如何获得装备  6其他功能说明
        local nType = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.TYPE);
        if (nType == nTypeIndex) then
             if ( nTitleAddFlag == 0) then
                local Record = {};
                Record.Type = nType + 10;
                Record.Title = p.TypeTitleDes[nType - 1];     --入参nType从2开始
                Record.Describe = "";
                nTitleAddFlag = 1;
                table.insert(p.GameAssisInfoList, Record);
                --LogInfo("p.GameAssisInit() nType = %d, Title = %s, Describe = %s", Record.Type, Record.Title, Record.Describe);          
            end
            local Record = {};
            Record.Type = nType;
            Record.Title = GetDataBaseDataS("achievement_config", v, DB_ACHIEVEMENT_CONFIG.TITLE);   
            Record.Describe = GetDataBaseDataS("achievement_config", v, DB_ACHIEVEMENT_CONFIG.DESCRIBE);             
            --LogInfo("p.GameAssisInit() nType = %d, Title = %s, Describe = %s", Record.Type, Record.Title, Record.Describe);          
            table.insert(p.GameAssisInfoList, Record);
        end
    end
end
--------------------------------------游戏助手基本函数定义----------初始化时按照类型排好序----------------------
function p.GameAssisInit()
    --LogInfo("function p.GameAssisInit() begin");
    
    p.GameAssisInfoList = {};
    
    --获取id集合
    --local ids = GetDataBaseIdList("achievement_config");
    
    --获取记录类型   1为大话兵法  2为没钱了怎么办  3为我要升级   4打不过敌军怎么办 5 如何获得装备  6其他功能说明
    local TypeMaxNum = 6;   
    
    for i = 2, TypeMaxNum do    --添加除了1以外其他的类型
        p.GameAssisInitDataList(i);
    end
end

--通过索引获取游戏助手的列表项内容
function p.GetGameAssisViewInfoFromIndex(nIndex)
    local nNum = 1;
    for i, v in pairs(p.GameAssisInfoList) do
        --LogInfo("p.GetGameAssisViewInfoFromIndex v.Type = %d", v.Type);
        if v.Type < 10 then
            if nNum == nIndex then
                return v;
            else
                nNum = nNum + 1;
            end
        end
    end
    return nil;
end

--------------------------------------是否有可以领取奖励的东西--------------------------------
function p.IsCanGetRewards()
    --LogInfo("functionp.IsCanGetRewards"); 
    
    if p.TacticStatusList == nil then
        --LogInfo("functionp.IsCanGetRewards nil"); 
        return false;
    end
    
    for i, v in pairs(p.TacticStatusList) do
        --LogInfo("function p.TacticStatusList Status = %d",  v.Status); 
        if v.Status == 1 then
            --LogInfo("return true");
            return true;
        end
    end
    
    --LogInfo("return false");
    return false;
end




function p.GameAssisRefresh()
    --LogInfo("p.GameAssisRefresh begin");
    local layer = p.GetLayerByTag(p.TabInfo.GameAssisInfo.LayerTag);    
    local ListContainer  = p.GetViewContainer(p.TabInfo.GameAssisInfo.tabBtnId);
   
     if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(TacticListSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    
    --设置当前要显示的说明信息
    local ToltalNum = table.getn(p.GameAssisInfoList);
    if p.TabInfo.GameAssisInfo.focusIndex > ToltalNum then
        return
    end
    --LogInfo("p.GameAssisRefresh begin ToltalNum = %d", ToltalNum);
    
    --显示当前的提示信息
    local Info = p.GameAssisInfoList[p.TabInfo.GameAssisInfo.focusIndex];
    --LogInfo("p.GameAssisRefresh begin focusIndex = %d", p.TabInfo.GameAssisInfo.focusIndex);
    --local Info = p.GetGameAssisViewInfoFromIndex(p.TabInfo.GameAssisInfo.focusIndex); 
    
    SetLabel(layer, CTR_TEXT_23, Info.Describe);
    --LogInfo("p.GameAssisRefresh ToltalNum = %d, focusIndex = %d, Describe = %s",ToltalNum, p.TabInfo.GameAssisInfo.focusIndex, Info.Describe);
    
    --添加list列表元素
    for i = 1, ToltalNum do
      p.AddViewItem(ListContainer, i, "achieve_2_LL.ini");
    end
    
    p.SetListFocus(p.TabInfo.GameAssisInfo.focusIndex);

end

function p.GameAssisOnEvent(uiNode, uiEventType, param)
end


--------------------------------------日常活动基本函数定义--------------------------------

function p.EveryDayActicInit()
    
    p.EveryDayActList = {};
    
    --获取id集合
    local ids = GetDataBaseIdList("achievement_config");
    
    for i,v in pairs(ids) do
        --获取记录类型   1为大话兵法  2为没钱了怎么办  3为我要升级   4打不过敌军怎么办 5 如何获得装备  6其他功能说明 7
        local nType = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.TYPE);

        if (nType == 7) then
            local Record = {};
            Record.id = v;
            Record.Status = 0;
            Record.AwardMoney = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.AWARD_MONEY);
            Record.AwardItem = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.AWARD_ITEM);   
            Record.AwardItemCount = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.ITEM_COUNT);  
            Record.AwardItem2 = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.AWARD_ITEM2);   
            Record.AwardItemCount2 = GetDataBaseDataN("achievement_config", v, DB_ACHIEVEMENT_CONFIG.ITEM_COUNT2);      
            Record.Title = GetDataBaseDataS("achievement_config", v, DB_ACHIEVEMENT_CONFIG.TITLE);   
            Record.Describe = GetDataBaseDataS("achievement_config", v, DB_ACHIEVEMENT_CONFIG.DESCRIBE);    
            --LogInfo("p.EveryDayActicInit() id  = %d, Status = %d, nType = %d, Money = %d, Item = %d, Count = %d, Title = %s, Describe = %s", Record.id, Record.Status, nType, Record.AwardMoney, Record.AwardItem, Record.AwardItemCount, Record.Title, Record.Describe);          
            
            table.insert(p.EveryDayActList, Record);
        end
    end
    
    for i, v in pairs(p.TacticStatusList) do
        for j, k in pairs(p.EveryDayActList) do
            --LogInfo("function p.RefreshTacticListInfo id = %d, Type = %d, Status = %d", k.id,  v.Type, v.Status); 
            if (k.id == v.Type) then
                --改变兵法状态
                k.Status = v.Status;
                break;
            end
        end
    end
end


function p.EveryDayActRefresh()

    local layer = p.GetLayerByTag(p.TabInfo.EveryDayActInfo.LayerTag);    
    
    local ListContainer  = p.GetViewContainer(p.TabInfo.EveryDayActInfo.tabBtnId);
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(TacticListSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    --设置当前要显示的说明信息
    local ToltalNum = table.getn(p.EveryDayActList);
    
    p.DragonSortData();
	--local CurFocus  = p.TacticSetCurFocus(); 
    local CurFocus  = 1; 
    
    --添加list列表元素
    for i = 1, ToltalNum do
      p.AddViewItem(ListContainer, i, "achieve_1_L.ini");
    end

    p.SetListFocus(CurFocus); 
    
    p.TabInfo.EveryDayActInfo.focusIndex = CurFocus;
    --显示当前的提示信息
    local Info = p.EveryDayActList[p.TabInfo.EveryDayActInfo.focusIndex];
    SetLabel(layer, CTR_TEXT_23, Info.Describe);
    
    local strShowText = string.format(GetTxtPri("AwardMoneyStr"), Info.AwardMoney);
    if Info.AwardItem ~= 0 then
       local ItemName = ItemFunc.GetName(Info.AwardItem);
       strShowText = strShowText .. string.format(GetTxtPri("AwardItemStr"), ItemName, Info.AwardItemCount);
		if ( Info.AwardItem2 ~= nil and Info.AwardItemCount2 ~= 0 ) then
			local ItemName2 = ItemFunc.GetName(Info.AwardItem2);
			strShowText = strShowText .. string.format(GetTxtPri("AwardItemStr"), ItemName2, Info.AwardItemCount2);
		end
    end
    SetLabel(layer, CTR_TEXT_21, strShowText); 
    
    --设置领取奖励按钮是否可用
    local BtnClose = GetButton(layer, CTR_BTN_22);
    if Info.Status == 1 then
        BtnClose:EnalbeGray(false);
        p.GetTutorial(true);
    else 
        BtnClose:EnalbeGray(true);
        p.GetTutorial(false);
    end

    if p.TabInfo.EveryDayActInfo.focusIndex > 7 then
        ListContainer:ShowViewByIndex(6); 
    else
        ListContainer:ShowViewByIndex(p.TabInfo.EveryDayActInfo.focusIndex - 1); 
    end
end


function p.EveryDayActOnEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    --LogInfo("p.OnViewUIEvent, tag = %d, p.CurFocusBtnId = %d, CTR_BTN_22 = %d", tag, p.CurFocusBtnId, CTR_BTN_22); 
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == CTR_BTN_22 then
            --获取按键是否可以响应
            local DataList = p.GetCurDataInfoList();
            local Info = DataList[p.TabInfo.EveryDayActInfo.focusIndex];
            
            --LogInfo("focusIndex = %d, Status = %d, Type = %d, count = %d", 
                           -- p.TabInfo.EveryDayActInfo.focusIndex, Info.Status, Info.AwardItem, Info.AwardItemCount); 
                            
              --判断当前按钮是否可响应
            if Info.Status == 1 then
				  local nAddNum = 0;
               --判断背包是否已经满
                if Info.AwardItem ~= 0 then
                     local nAmountLimit = GetDataBaseDataN("itemtype", Info.AwardItem, DB_ITEMTYPE.AMOUNT_LIMIT);
                     nAddNum = math.ceil(Info.AwardItemCount/nAmountLimit);
                     if (ItemFunc.IsBagFull(math.ceil(Info.AwardItemCount/nAmountLimit)-1)) then
                        return true;
                     end
                end
				if ( Info.AwardItem2 ~= nil and Info.AwardItem2 ~= 0 ) then
                     local nAmountLimit = GetDataBaseDataN("itemtype", Info.AwardItem2, DB_ITEMTYPE.AMOUNT_LIMIT);
                     if (ItemFunc.IsBagFull(math.ceil(Info.AwardItemCount2/nAmountLimit)-1 + nAddNum)) then
                        return true;
                     end
				end
            
                p.SendTacticListViewStatus(Info.id);
                Info.Status = 2;
                return true;
            end
        end
    end
end


-- 数据包标志
local PacketFlag = {
	PF_BEGIN	= 1,	-- 首包(多个包情况下)
	PF_CONTINUE	= 0,	-- 中包(多个包情况下)
	PF_END		= 2,	-- 尾包(多个包情况下)
	PF_SINGLE	= 3,	-- 单包
};
--------------------------------------当大话兵法中具体兵法项状态改变的时候信息刷新 --------------------------------
function p.RefreshTacticListInfo(netdata)  
    --LogInfo("function p.RefreshTacticListInfo begin"); 
    
	local nPacketFlag = netdata:ReadByte();
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
		p.TacticStatusList = {};
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		p.TacticStatusList = {};
	end
    local count		= netdata:ReadByte();
    for i = 1, count do
        local record = {};
        record.Type = netdata:ReadInt();
        record.Status = netdata:ReadInt();
        table.insert(p.TacticStatusList, record);
        --LogInfo("msg  count = %d, Type = %d, Status = %d", count, record.Type,  record.Status); 
    end
    
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
    	--更新大话兵法界面,前提是已经进入大话兵法界面
    	if IsUIShow(NMAINSCENECHILDTAG.DragonTactic) then
    	    for i, v in pairs(p.TacticStatusList) do
    	        for j, k in pairs(p.TacticInfoList) do
    	            --LogInfo("function p.RefreshTacticListInfo id = %d, Type = %d, Status = %d", k.id,  v.Type, v.Status); 
    	            if (k.id == v.Type) then
    	                --改变兵法状态
    	                k.Status = v.Status;
    	                break;
    	            end
    	        end
    	    end
    	    
    	    if p.CurFocusBtnId == p.TabInfo.TacticTabInfo.tabBtnId then    --是在大话兵法页面
    	        p.TabInfo.TacticTabInfo.FucRefresh(); --刷新大话兵法标签页面
    	    elseif p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId then    --
    	        p.TabInfo.EveryDayActInfo.FucRefresh(); --刷新每日活动标签页面
    	    end
    	end
    	p.DTStarTip();
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
    	--更新大话兵法界面,前提是已经进入大话兵法界面
    	if IsUIShow(NMAINSCENECHILDTAG.DragonTactic) then
    	    for i, v in pairs(p.TacticStatusList) do
    	        for j, k in pairs(p.TacticInfoList) do
    	            --LogInfo("function p.RefreshTacticListInfo id = %d, Type = %d, Status = %d", k.id,  v.Type, v.Status); 
    	            if (k.id == v.Type) then
    	                --改变兵法状态
    	                k.Status = v.Status;
    	                break;
    	            end
    	        end
    	    end
    	    
    	    if p.CurFocusBtnId == p.TabInfo.TacticTabInfo.tabBtnId then    --是在大话兵法页面
    	        p.TabInfo.TacticTabInfo.FucRefresh(); --刷新大话兵法标签页面
    	    elseif p.CurFocusBtnId == p.TabInfo.EveryDayActInfo.tabBtnId then    --
    	        p.TabInfo.EveryDayActInfo.FucRefresh(); --刷新每日活动标签页面
    	    end
    	end
    	p.DTStarTip();
	end

end

function p.SendTacticListViewStatus(nId)  
    --LogInfo("function p.SendTacticListViewStatus()  begin nId = %d", nId); 

	local netdata = createNDTransData(NMSG_Type._MSG_ACHIEVEMENT_GET_PRIZE);
	netdata:WriteInt(nId);	
	SendMsg(netdata);	
	netdata:Free();	
    --LogInfo("function p.SendTacticListViewStatus()  end"); 
	return true;	
end


--助手任务完成但还没领取奖励
function p.DTStarTip()
    --LogInfo("DragonTacticUI.DTStarTip");
	if p.IsCanGetRewards() then
        --LogInfo("DragonTacticUI.IsCanGetRewards true");
		local btn = MainUIBottomSpeedBar.GetFuncBtn(119);
		
		if btn == nil then
			--LogInfo("p.DTStarTip 1")
			return;
		end
		
        local pSpriteNode = ConverToSprite( GetUiNode( btn, 99 ) );
    	if ( pSpriteNode ~= nil ) then
    		return;
    	end  

		local pSpriteNode	= createUISpriteNode();
		
		
		local btnrect = btn:GetFrameRect();
		local btnWidth =btnrect.size.w;
		local btnHeight = btnrect.size.h;

		pSpriteNode:Init();
		local szAniPath		= NDPath_GetAnimationPath();
		local szSprFile		= "gongn01.spr";
		
		pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
		pSpriteNode:SetFrameRect( CGRectMake(-btnWidth*0.1,0,btnWidth,btnHeight) );
		pSpriteNode:SetScale(0.7);
		
		pSpriteNode:SetTag( 99 );
	
		--加到星星node上
    	btn:AddChild( pSpriteNode );
    	p.EffectSprite = pSpriteNode;
	else
		--LogInfo("DragonTacticUI.IsCanGetRewards false");
		p.RemoveEffect();
	end
end
p.EffectSprite	= nil;
function p.RemoveEffect()
	if p.EffectSprite == nil then
		return;
	end
    
    local effectspr = p.EffectSprite;
    --LogInfo("DragonTacticUI RemoveEffect 1");
    effectspr:RemoveFromParent( true );
    p.EffectSprite	= nil;
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "DragonTacticUI.DTStarTip", p.DTStarTip);

--注册当大话兵法中具体兵法项状态改变的时候信息刷新  消息格式  
--byte count 更新条数  ｛int type类型,  int status 状态值 0初始状态, 1可领取状态,  2已领取状态 }
RegisterNetMsgHandler(NMSG_Type._MSG_ACHIEVEMENT_INFO_LIST, "p.RefreshTacticListInfo", p.RefreshTacticListInfo);
