---------------------------------------------------
--描述: 7x7 小游戏
--时间: 2013.05.02
--作者: sjt
---------------------------------------------------
SG7x7 = {}
local p = SG7x7;
local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;
local PanelHeight = 7;
local PanelWidth = 7;
local ColorCount = 6;
--一些可变的控件集合
p.MutableCtr = { };
                           
--一些不可变的控件集合
p.ImmutableCtr = { Btn          = {btnLeave = 6,btn_next1=57,btn_record=64,btn_rule=70},
                Lable       = {txtGameInfo = 5, txtGameName = 11, txt_level=67,txt_score=68,txt_combo=69},
                List          = {listMsg = 7, txtInfo = 2, viewIni = "7x7_L.ini",
                    ViewSize = CGSizeMake(107*ScaleFactor, 32*ScaleFactor),} };

local PanelData = {}    --初始无棋子
local EmptyList = {}
local EnableData = {}   --可到达的点
local Path = {}
local LastSelected = nil
local IsInAction = 0
local BasePosData = {}
local LastDragPos = nil
local LastDragType = nil
local LastDragSave = nil

local function IdxSerToCli(idx)
    return idx+1
end

local function ShowEmpty()
    for k,v in ipairs(EmptyList) do
        LogInfo("$$$$(%d,%d)$$$$$$$$",k,v)
    end
    LogInfo("$$$$$$$$$$$$$$$$$")
end

local function IdxToTag(idx)
    local x = (idx-1)%PanelWidth+1
    local y = math.floor((idx-1)/PanelWidth)+1
    return y*100+x
end

local function IdxToPos(idx)
    return (idx-1)%PanelWidth+1,math.floor((idx-1)/PanelWidth)+1
end

local function PosToIdx(x,y)
    return (y-1)*PanelWidth+x
end

local function GetTagByMousePos(pos)
    local x = math.floor((pos.x-BasePosData.x)/BasePosData.cellwidth)+1
    if(x<1) then
        x=1
    end
    if(x>PanelWidth)then
        x=PanelWidth
    end
    local y = math.floor((pos.y-BasePosData.y)/BasePosData.cellheight)+1
    if(y<1)then
        y=1
    end
    if(y>PanelHeight)then
        y=PanelHeight
    end
    return PosToIdx(x,y)
end

local function TagToPos(tag)
    local x = tag%100
    local y = math.floor(tag/100)
    local idx = (y-1)*PanelWidth+x
    return idx,x,y
end

local function GetNormalPic(type)
    if(type==nil)then
        return nil
    end
    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "7x7/7x7_icon"..type..".png" ), false);
    return Pic;
end

local function GetFocusPic(type)
    if(type==nil)then
        return nil
    end
    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "7x7/7x7_icon1"..type..".png" ), false);
    return Pic;
end

local function GetPathPic(type)
    if(type==nil)then
        return nil
    end
    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "7x7/7x7_icon2"..type..".png" ), false);
    return Pic;
end

local function GetParent()    --获取容器
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.SG7x7UI);
	if nil == layer then
		return nil;
	end
    
	return layer;
end

local function SetBlockType(idx,type)
    local layer = GetParent()
    local btn = GetButton(layer, IdxToTag(idx));
    if(type==nil)then
        btn:SetImage(nil)
        btn:SetFocusImage(nil)
        return
    end
    local pic = GetNormalPic(type);
    btn:SetImage(pic)
    pic = GetFocusPic(type)
    btn:SetFocusImage(pic)
end

local function SetBlockPath(idx,pathType)
    if(PanelData[idx]~=nil)then --有东西的不可以设置
        return
    end
    local layer = GetParent()
    local btn = GetButton(layer,IdxToTag(idx))
    if(pathType==nil)then
        --恢复
        btn:SetImage(nil)
        return
    end
    local pic = GetPathPic(pathType)
    btn:SetImage(pic)
end

local function CheckLine(x,y,disx,disy,type,line)
    for i=1,PanelWidth,1 do
        if(x+disx*i<1 or x+disx*i>PanelWidth)then
            break
        end
        if(y+disy*i<1 or y+disy*i>PanelHeight)then
            break
        end
        if(PanelData[(y+disy*i-1)*PanelWidth+x+disx*i]==type)then
            table.insert(line,(y+disy*i-1)*PanelWidth+x+disx*i)
        else
            break
        end
    end
end

local function GetDelayDelFunction(delpos)
    local function f(tag)
        UnRegisterTimer(tag)
        for _,vl in pairs(delpos) do
            for _,v in pairs(vl) do
                SetBlockType(v,nil)
                PanelData[v] = nil
                table.insert(EmptyList,v)
                LogInfo("$$$$Delete %d",v)
            end
        end
        IsInAction = IsInAction-1
    end
    return f
end

local function CheckDelete(idx)
    local layer = GetParent();
    local x,y = IdxToPos(idx)
    local type = PanelData[idx]
    local delpos = {}
    --看看横的有几个
    local line1 = {}
    CheckLine(x,y,-1,0,type,line1)
    CheckLine(x,y,1,0,type,line1)
    if(#line1>=3)then
        table.insert(delpos,line1)
    end
    --竖的
    local line2 = {}
    CheckLine(x,y,0,-1,type,line2)
    CheckLine(x,y,0,1,type,line2)
    if(#line2>=3)then
        table.insert(delpos,line2)
    end
    
    local line3 = {}
    CheckLine(x,y,-1,-1,type,line3)
    CheckLine(x,y,1,1,type,line3)
    if(#line3>=3)then
        table.insert(delpos,line3)
    end
    
    local line4 = {}
    CheckLine(x,y,1,-1,type,line4)
    CheckLine(x,y,-1,1,type,line4)
    if(#line4>=3)then
        table.insert(delpos,line4)
    end
    
    if(#delpos>0)then
        table.insert(delpos,{idx})
        IsInAction = IsInAction+1
        RegisterTimer(GetDelayDelFunction(delpos),0.2,"DelFunction")
        return true
    end
    return false
end

local function RandAdd(type)    --随机放入一个棋子
    local i = math.random(1,#EmptyList)
    local idx = EmptyList[i]
    table.remove(EmptyList,i)
    LogInfo("$$$$RandAdd %d",idx)
    PanelData[idx] = type
    SetBlockType(idx,type)
    --ShowEmpty()
    CheckDelete(idx)
end
local function NextStep(tag)    --执行下一步骤
    UnRegisterTimer(tag)
    if(#EmptyList==0)then
        --gameover
        return
    end
    RandAdd(math.random(1,ColorCount))
end

local function NextStepEnd(tag)
    UnRegisterTimer(tag)
    IsInAction = IsInAction-1
    if(#EmptyList==0)then
        --gameover
        return
    end
    RandAdd(math.random(1,ColorCount))
end
local function InitData()   --初始化数据
    PanelData = {}
    EmptyList = {}
    EnableData = {}
    Path = {}
    LastSelected = nil
    IsInAction = 0
    for i=1,PanelHeight*PanelWidth do
        SetBlockType(i,nil)
        table.insert(EmptyList,i)
    end
    LastDragPos = nil
    LastDragType = nil
    LastDragSave = nil
end

local function InitRandAdd()    --初始随机增加棋子
    IsInAction = IsInAction+1
    RegisterTimer(NextStep,0.25,"NextStep")
    RegisterTimer(NextStep,0.5,"NextStep")
    RegisterTimer(NextStep,0.75,"NextStep")
    RegisterTimer(NextStepEnd,1,"NextStepEnd")
end
local function SetSelected(idx) --设置为选择态
    layer = GetParent()
    if LastSelected~=nil then
        --取消选择态
        local btnLast = GetButton(layer,IdxToTag(LastSelected))
        --btnLast:SetFocus(false)
    end
    LastSelected = idx
    if(idx~=nil)then
        local layer = GetParent()
        local btn = GetButton(layer,IdxToTag(idx))
        --btn:SetFocus(true)
    end
end

local function ClearPath()
    for _,v in pairs(Path) do
        SetBlockPath(v,nil)
    end
    Path = {}
end

local function SetMoveFlag(idx)
    local layer = GetParent()
    layer:RemoveChildByTag(100,true)
    if(idx==0)then
        return
    end
    local lb = createNDUIImage();
	lb:Init();
	
	local pool = _G.DefaultPicPool();
    local pic = pool:AddPicture( _G.GetSMImgPath( "7x7/7x7_icon36.png" ), false);
    if (pic) then
		local size = pic:GetSize();
		lb:SetPicture(pic, true);
        local x,y = IdxToPos(idx)
        lb:SetFrameRect(CGRectMake(BasePosData.x+BasePosData.cellwidth*(x-1)+BasePosData.cellwidth/2-size.w/2,
            BasePosData.y+BasePosData.cellheight*(y-1)+BasePosData.cellheight/2-size.h/2,
            size.w,size.h));
        layer:AddChildZTag(lb, 100, 100);
	end
end

local function FindPath(from,to)
    --恢复之前的path
    ClearPath()
    local checked={}
    local checking = {}
    local cur = from
    checked[cur] = 0
    local pathok = false
    if(from==to)then
        return
    end
    while(true) do
        local x,y = IdxToPos(cur)
        if(y+1<=PanelHeight)then
            local idx = PosToIdx(x,y+1)
            if(idx==to) then
                pathok = true
                break
            end
            if(checked[idx]==nil and PanelData[idx]==nil)then
                --这点可以走
                checked[idx] = cur
                table.insert(checking,idx)
            end
        end
        if(x+1<=PanelWidth)then
            local idx = PosToIdx(x+1,y)
            if(idx==to) then
                pathok = true
                break
            end
            if(checked[idx]==nil and PanelData[idx]==nil)then
                --这点可以走
                checked[idx] = cur
                table.insert(checking,idx)
            end
        end
        if(y-1>=1) then
            local idx = PosToIdx(x,y-1)
            if(idx==to) then
                pathok = true
                break
            end
            if(checked[idx]==nil and PanelData[idx]==nil)then
                --这点可以走
                checked[idx] = cur
                table.insert(checking,idx)
            end
        end
        if(x-1>=1) then
            local idx = PosToIdx(x-1,y)
            if(idx==to) then
                pathok = true
                break
            end
            if(checked[idx]==nil and PanelData[idx]==nil)then
                --这点可以走
                checked[idx] = cur
                table.insert(checking,idx)
            end
        end
        if(#checking<=0)then
            break
        end
        cur = checking[1]
        table.remove(checking,1)
    end
    if(pathok)then
        --构建path
        while(true)do
            if(cur==0)then
                break
            end
            table.insert(Path,1,cur)
            cur = checked[cur]
        end
    end
end

local function DrawPath(pathType)
    for _,v in pairs(Path) do
        SetBlockPath(v,pathType)
    end
end

local function CalEnable()
    local layer = GetParent()
    EnableData = {}
    --重置所有的gray
    for i=1,PanelWidth*PanelHeight,1 do
        local btn = GetButton(layer,IdxToTag(i))
        btn:EnalbeGray(false)
    end
    if(LastSelected == nil)then
        return
    end
    local layer = GetParent()
    local x,y = IdxToPos(LastSelected)
    local checkList = {}
    EnableData[LastSelected] = 0    --检查过了
    while(true) do
        if(y+1<=PanelHeight)then
            local checkIdx = PosToIdx(x,y+1)
            if(EnableData[checkIdx]==nil)then
                if(PanelData[checkIdx]==nil)then    --可以继续
                    --LogInfo("$$$insert %d",checkIdx)
                    EnableData[checkIdx] = 1 --enable
                    table.insert(checkList,checkIdx)
                else
                    EnableData[checkIdx] = 0 --checked
                end
            end
        end
        if(x+1<=PanelWidth)then
            local checkIdx = PosToIdx(x+1,y)
            if(EnableData[checkIdx]==nil)then
                if(PanelData[checkIdx]==nil)then    --可以继续
                    --LogInfo("$$$insert %d",checkIdx)
                    EnableData[checkIdx] = 1 --enable
                    table.insert(checkList,checkIdx)
                else
                    EnableData[checkIdx] = 0 --checked
                end
            end
        end
        if(y-1>=1)then
            local checkIdx = PosToIdx(x,y-1)
            if(EnableData[checkIdx]==nil)then
                if(PanelData[checkIdx]==nil)then    --可以继续
                    --LogInfo("$$$insert %d",checkIdx)
                    EnableData[checkIdx] = 1 --enable
                    table.insert(checkList,checkIdx)
                else
                    EnableData[checkIdx] = 0 --checked
                end
            end
        end
        if(x-1>=1)then
            local checkIdx = PosToIdx(x-1,y)
            if(EnableData[checkIdx]==nil)then
                if(PanelData[checkIdx]==nil)then    --可以继续
                    --LogInfo("$$$insert %d",checkIdx)
                    EnableData[checkIdx] = 1 --enable
                    table.insert(checkList,checkIdx)
                else
                    EnableData[checkIdx] = 0 --checked
                end
            end
        end
        if(#checkList<=0)then
            break
        end
        x,y = IdxToPos(checkList[1])
        table.remove(checkList,1)
    end
    --剩余的都是不可到达的
    --for k,v in pairs(EnableData)do
    --    LogInfo("Enable (%d,%d)",k,v)
    --end
    for i=1,PanelWidth*PanelHeight,1 do
        if(EnableData[i]==nil)then
            if(PanelData[i]==nil)then
                EnableData[i] = -1  --不可到达
                local btn = GetButton(layer,IdxToTag(i))
                btn:EnalbeGray(true)
                --LogInfo("SetGray %d",i)
            else
                EnableData[i] = 0 --不许要判定
            end
        elseif(EnableData[i]<0)then
            local btn = GetButton(layer,IdxToTag(i))
            btn:EnalbeGray(true)
            --LogInfo("SetGray %d",i)
        end
    end
end

local function ResetAllNormal()
    for i=i,PanelWidth*PanelHeight,1 do
        if(PanelData[i]==nil)then
            
        else
        end
    end
end

local function RemoveFromEmtpyList(idx)
    local fkey = -1
    for k,v in ipairs(EmptyList) do
        if(v==idx)then
            fkey = k
            break
        end
    end
    if(fkey~=-1)then
        --LogInfo("remove it %d in %d",idx,fkey)
        table.remove(EmptyList,fkey)
    end
end

local function GameOver()

end

function p.LoadUI ()
    local scene = GetSMGameScene();
	if scene == nil then
		return;
	end

    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SG7x7UI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer,5001);

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("7x7.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    
    local BtnClose = GetButton(layer, p.ImmutableCtr.Btn.btnLeave);
    BtnClose:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    ----------游戏代码-------------------
    local btn = GetButton(layer,101)
    rect = btn:GetFrameRect()
    LogInfo("$$$$x=%d,y=%d,width=%d,height=%d",rect.origin.x,rect.origin.y,rect.size.w,rect.size.h)
    BasePosData.x = rect.origin.x
    BasePosData.y = rect.origin.y
    BasePosData.cellwidth = rect.size.w
    BasePosData.cellheight = rect.size.h
    InitData();
    return true
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = GetParent();
	local tag = uiNode:GetTag();
    LogInfo("$$$$$$OnUIEvent tag=%d,type=%d",tag,uiEventType)
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then  --点击事件 
		if p.ImmutableCtr.Btn.btnLeave == tag then                   --关闭
            CloseUI(NMAINSCENECHILDTAG.SG7x7UI);
        elseif p.ImmutableCtr.Btn.btn_record == tag then
            Msg7x7.SendGetScoreBoard()
            SG7x7Board.LoadUI(GetParent())
        elseif p.ImmutableCtr.Btn.btn_rule == tag then
            SG7x7Rule.LoadUI()
        else    --棋子移动
            if(IsInAction>0)then    --还在动画中
                return true
            end
            local x = tag%100
            local y = math.floor(tag/100)
            local idx = (y-1)*PanelWidth+x
            if(LastSelected==nil)then   --不在选择态
                if(PanelData[idx]==nil)then --不可选择的
                    return true
                end
                SetSelected(idx)
                CalEnable()
            else
                if(EnableData[idx]<=0)then --目标不可选择
                    if(PanelData[idx]~=nil)then
                        SetSelected(idx)
                        CalEnable()
                    end
                else
                                        
                    --由服务端控制消除
                    FindPath(LastSelected,idx)
                    table.insert(Path,idx)
                    Msg7x7.SendMove(Path)
                    IsInAction = IsInAction+1
                    
                    PanelData[idx] = PanelData[LastSelected]    --切换位置
                    SetBlockType(idx,PanelData[idx])
                    PanelData[LastSelected] = nil
                    SetBlockType(LastSelected,nil)
                    RemoveFromEmtpyList(idx)
                    table.insert(EmptyList,LastSelected)
                    SetSelected(nil)
                    CalEnable()
                    
                    --[[    客户端控制代码
                    if(not CheckDelete(idx))then
                        IsInAction = IsInAction+1
                        RegisterTimer(NextStep,0.25,"NextStep")
                        RegisterTimer(NextStep,1.0,"NextStep")
                        RegisterTimer(NextStepEnd,1.5,"NextStepEnd")
                    end
                    --]]
                end
            end
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then   --拖拽出
        LogInfo("$$$$DRAG_OUT$$$$")
        local idx,x,y = TagToPos(tag)
        if(PanelData[idx]==nil)then
            LastDragType = nil
            LastDragPos = nil
            LastDragSave = nil
            return true
        else
            if(LastDragType==nil)then
                LastDragType = PanelData[idx]
                LastDragPos = GetTagByMousePos(param)
                LastDragSave = LastDragPos
                LogInfo("DragFrom %d,type=%d",LastDragPos,LastDragType)
                SetSelected(LastDragPos)
                CalEnable()
            end
        end
        local curPos = GetTagByMousePos(param)
        LogInfo("CurPos=%d,LastSave=%d,LastDragType=%d",curPos,LastDragSave,LastDragType)
        if(curPos~=LastDragSave)then
            SetMoveFlag(curPos)
            if(PanelData[curPos]~=nil or EnableData[curPos]<=0)then
                ClearPath()
                LastDragSave = curPos
                return true
            end
            LogInfo("FindPath,from=%d,to=%d,type=%d",LastDragPos,curPos,LastDragType)
            FindPath(LastDragPos,curPos)
            DrawPath(LastDragType)
            LastDragSave = curPos
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then   --拖拽出  
        LogInfo("$$$$DRAG_OUT_END$$$$")
        if(LastDragPos~=nil and LastDragType~=nil and LastDragSave~=nil)then
            if(LastDragPos~=LastDragSave and PanelData[LastDragSave]==nil and EnableData[LastDragSave]>0)then
                --移动
                --由服务端控制消除
                table.insert(Path,LastDragSave)
                Msg7x7.SendMove(Path)
                IsInAction = IsInAction+1
                LogInfo("DragComplete,from %d,to %d",LastDragPos,LastDragSave)
                PanelData[LastDragSave] = PanelData[LastDragPos]    --切换位置
                SetBlockType(LastDragSave,PanelData[LastDragSave])
                PanelData[LastDragPos] = nil
                SetBlockType(LastDragPos,nil)
                RemoveFromEmtpyList(LastDragSave)
                table.insert(EmptyList,LastDragPos)
                SetSelected(nil)
                CalEnable()
                --[[    客户端控制代码
                if(not CheckDelete(LastDragSave))then
                    IsInAction = IsInAction+1
                    RegisterTimer(NextStep,0.25,"NextStep")
                    RegisterTimer(NextStep,1.0,"NextStep")
                    RegisterTimer(NextStepEnd,1.5,"NextStepEnd")
                end
                --]]
            end
            LastDragPos = nil
            LastDragType = nil
            LastDragSave = nil
            SetMoveFlag(0)
        end
        ClearPath();
    end
	return true;
end

local function ShowCombo(combo)
    local label_combo = GetLabel(GetParent(),p.ImmutableCtr.Lable.txt_combo)
    label_combo:SetText(tostring(combo))
end

local function ShowScore(score)
    local label_score = GetLabel(GetParent(),p.ImmutableCtr.Lable.txt_score)
    label_score:SetText(tostring(score))
end

local function ShowLevel(level)
    local label_level = GetLabel(GetParent(),p.ImmutableCtr.Lable.txt_level)
    label_level:SetText(tostring(level))
end

local function UpdateNext(nextdata)
    ShowCombo(0)
    for i=1,6,1 do
        --LogInfo("Game7x7:btn=%d",p.ImmutableCtr.btn.btn_next1+i-1)
        local btn = GetButton(GetParent(),p.ImmutableCtr.Btn.btn_next1+i-1)
        local type = nextdata[i]
        local pic = GetNormalPic(type);
        btn:SetImage(pic)
    end
end

function p.DoBegin(score,level,combo,paneldata,nextdata)
    if(IsUIShow(NMAINSCENECHILDTAG.SG7x7UI))then
        LogInfo("Game7x7:DoBegin,score=%d,level=%d",score,level)
        for _,v in pairs(paneldata)do
            PanelData[IdxSerToCli(v[1])] = v[2]
            SetBlockType(IdxSerToCli(v[1]),v[2])
        end
        --显示后续的几个颜色
        UpdateNext(nextdata)
        ShowScore(score)
        ShowLevel(level)
        ShowCombo(combo)
    end
end

function p.DoFinish(score)
    InitData()
    CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("SG7x7ShowFinish"),score));
    Msg7x7.SendOpen()
end

function p.UpdateLevel(level)
    ShowLevel(level)
end

function p.DoNext(nexts)
    if(IsUIShow(NMAINSCENECHILDTAG.SG7x7UI))then
        --显示后续的几个颜色
        UpdateNext(nexts)
    end
end

function p.DoAdd(idx,color)
    PanelData[IdxSerToCli(idx)] = color
    SetBlockType(IdxSerToCli(idx),color)
end

function p.DoDelete(score,combo,idxs)
    for _,v in pairs(idxs)do
        PanelData[IdxSerToCli(v)] = nil
        SetBlockType(IdxSerToCli(v),nil)
    end
    ShowScore(score)
    ShowCombo(combo)
end

function p.DoActionRet(action,ret)
    IsInAction = IsInAction-1
end

LogInfo("$$$$$$$$$$endend$$$$$$$$")