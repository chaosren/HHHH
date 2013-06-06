---------------------------------------------------
--描述: 战斗界面的控件处理层
--时间: 2012.8.16
--作者: tzq
---------------------------------------------------
BattleMapCtrl = {}
local p = BattleMapCtrl;


local CTRL_BTN_1  = 1;        --速战速决
RectFastBtn = CGRectMake(0,  0, 88*CoordScaleX, 27*CoordScaleY);  
RectLayer = CGRectMake(196*CoordScaleX, 285*CoordScaleY, 88*CoordScaleX, 27*CoordScaleY);  --速战速决按钮


--加载战斗页面控件层
function p.LoadUI()
     LogInfo("qboy setBattle CampBattle.SetBattle");  
     CampBattle.SetBattle();
     LogInfo("qboy setBattle SyndicateBattleUI.SetBattle");  

     SyndicateBattleUI.SetBattle();
     --boss战不使用快速战斗
     if ArenaUI.isInChallenge == 6 or
        ArenaUI.isInChallenge == 3 or
        ArenaUI.isInChallenge == 5 then
        
        if(p.BattleEndTimerTag == nil) then
            p.BattleEndTimerTag=RegisterTimer(p.szsjinit,10, "p.szsjinit()");
        end
        return;
    end
    
    --首先判断是否已经开启快速战斗vip功能
   
   local nVip,nLevel,bVip,bLevel = GetVipLevel2(DB_VIP_STATUC_VALUE.BATTLE_FAST_FLAG);
   if not (bVip or bLevel) then 
       return;
    end

    p.szsjinit();
    
    return true;
end

p.BattleEndTimerTag = nil;


function p.szsjinit()

    if(p.BattleEndTimerTag) then
        UnRegisterTimer(p.BattleEndTimerTag);
        p.BattleEndTimerTag = nil;
    end

--
            local scene = GetSMGameScene();
            if(scene) then
                local bs = GetUiLayer(scene,NMAINSCENECHILDTAG.BottomSpeedBar);
                if(bs) then
                    if(bs:IsVisibled()) then
                        LogInfo("BottomSpeedBar visible return");  
                        return;
                    end
                else
                	LogInfo("BottomSpeedBar nil go on");     
                end
            end
            
           
--          
            
            
    LogInfo("BattleMapCtrl function p.LoadUI()");  
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加页面控件层---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleMapCtrl);
	layer:SetFrameRect(RectLayer);
	scene:AddChildZ(layer,1);

    LogInfo("BattleMapCtrl function p.LoadUI()");  
    -----------------初始化ui添加到 layer 层上---------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("BattleMapCtrl.ini", layer, p.OnUIEvent, 0, 0);
    LogInfo("BattleMapCtrl function p.LoadUI()");  
    
    
    local btnFastBattle = GetButton(layer, CTRL_BTN_1);
    btnFastBattle:SetFrameRect(RectFastBtn);

end


-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent tag = %d, uiEventType = %d", tag, uiEventType);  
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if CTRL_BTN_1 == tag then                 --速战速决            
            LogInfo("hit in suzhansujue");  
            FinishBattle();      
			--CloseUI(NMAINSCENECHILDTAG.DragonTactic);
        end  
    end
    
	return true;
end

function p.CloseUI()
        if IsUIShow(NMAINSCENECHILDTAG.BattleMapCtrl) then
            CloseUI(NMAINSCENECHILDTAG.BattleMapCtrl);
        end
end


