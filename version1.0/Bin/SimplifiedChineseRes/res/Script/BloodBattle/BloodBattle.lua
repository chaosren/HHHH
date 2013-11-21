---------------------------------------------------
--描述: 血战
--时间: 2012.7.8
--作者: Guosen
---------------------------------------------------
-- 进入血战界面接口：		BloodBattle.Entry()
---------------------------------------------------

BloodBattle = {}
local p = BloodBattle;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 2;	-- X

local ID_LABEL_RECORD				= 17;	-- 当日最高纪录（关数）标签
local ID_LABEL_RIVAL				= 27;	-- 当前关卡对手-标签
local ID_LABEL_TIMES				= 28;	-- 今日可挑战次数-标签
local ID_LABEL_POINTS				= 30;	-- 今日最高积分
local ID_LABEL_BUFF_LV				= 33;	-- BUFF等级

-- 按钮
local ID_BTN_START_CHALLENGE		= 21;	-- 开始挑战
local ID_BTN_RESTART				= 22;	-- 重新开始--重置
local ID_BTN_RULE_DESCRIPTION		= 23;	-- 规则说明
local ID_BTN_RANKING				= 24;	-- 昨日排名

local ID_CHECK_BOX_NORMAL			= 71;	-- 难度-普通
local ID_CHECK_BOX_HARD				= 72;	-- 难度-困难
local ID_CHECK_BOX_HELL				= 73;	-- 难度-炼狱

--
local ID_PIC_LEVEL_HUNDRADE			= 81;	-- 关数-百位-图形
local ID_PIC_LEVEL_DECADE			= 82;	-- 关数-十位-图形
local ID_PIC_LEVEL_UNIT				= 83;	-- 关数-个位-图形

--通关显示的图
local ID_PIC_CLEAR_STAGE				= 31;	-- 通关图片
-- 通关须隐藏的图
local ID_PIC_S_PIC1				= 51;	-- 
local ID_PIC_S_PIC2				= 52;	-- 
local ID_PIC_S_PIC3				= 50;	-- 
local ID_PIC_S_PIC4				= 48;	-- 
local ID_PIC_S_PIC5				= 49;	-- 

---------------------------------------------------
local SZ_PIC_NUM_PATH				= "blood_battle/bb_num.png";--关数数字图形文件
local FIGURE_WIDTH					= 37;--关数数字图形-单字符的宽度
local FIGURE_HEIGHT					= 57;--关数数字图形-单字符的高度

local SZ_LEVEL						= GetTxtPri("BB_D1");--"关";
local SZ_TIME						= GetTxtPri("BB_D2");--"次";
local SZ_ERROR_00					= GetTxtPri("BB_D3");--"今日可挑战次数用尽";
local SZ_ERROR_01					= GetTxtPri("BB_D4");--"玩家等级不足";
local SZ_ERROR_02					= GetTxtPri("BB_D5");--"时间点已过";
local SZ_REWARD_TITLE				= GetTxtPri("BB_D6");--"恭喜您过关！获得：";
local SZ_PROMPT_00					= GetTxtPri("BB_D7");--"您此次挑战已通过了所有的关卡！";
local SZ_PROMPT_01					= GetTxtPri("BB_D8");--"恭喜您通关！获得："
local SZ_DESCRIPTION				= GetTxtPri("BB_I1").."\n"..GetTxtPri("BB_I2").."\n"..GetTxtPri("BB_I3").."\n"..GetTxtPri("BB_I4").."\n"..GetTxtPri("BB_I5").."\n"..GetTxtPri("BB_I6").."\n"..GetTxtPri("BB_I7").."\n"..GetTxtPri("BB_I8");--"血战说明……";
local PLAYER_LEVEL_LIMITE			= 30;	--玩家等级限制

-- BloodBattleDifficulty
local BBD ={
	NORMAL	= 1,
	HARD	= 2,
	HELL	= 3,
};

---------------------------------------------------
local ID_BTN_RULEDESCRIPTIONUI_CLOSE	= 49;	-- 规则说明界面关闭按钮
local ID_LABEL_DESCRIPTION				= 87;	-- 规则说明文本标签

---------------------------------------------------

local UI_ZORDER				= 5010;	--UILayerZOrder.ActivityLayer--盖在聊天按钮上的ZORDER

---------------------------------------------------

---------------------------------------------------
p.nCurrentLevel				= nil;	-- 玩家当前挑战的关数
p.nDifficulty				= nil;	-- 当前难度
p.pLayerMainUI				= nil;	-- 主界面
p.tUserInfor				= nil;	--

---------------------------------------------------
-- 进入--时间点到才可以
function p.Entry()
	p.nCurrentLevel				= nil;	--
	p.nDifficulty				= nil;
	p.pLayerMainUI				= nil;
	p.tUserInfor				= nil;	--
	--
	local nPlayerID		= GetPlayerId();--User表中的ID
	local nPlayerPetID	= RolePetFunc.GetMainPetId( nPlayerID );
	local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	if ( nPlayerLevel < PLAYER_LEVEL_LIMITE ) then
		CommonDlgNew.ShowYesDlg( SZ_ERROR_01, nil, nil, 3 );
		return;
	end
	
	MsgBloodBattle.SendMsgUserInfor();
--测试-直接进入主界面
--local tUserInfor = {};
--tUserInfor.nChallCount	= 0;--当天已挑战次数--(挑战失败才累加)
--tUserInfor.nClimbLayer	= 0;--当前次已挑战的关数
--tUserInfor.nMaxLayer	= 0;--当天挑战的最高关数
--tUserInfor.nGrade		= 1;---玩家所处的阶段
--tUserInfor.uChallMax	= 3;--当天挑战次数上限
--tUserInfor.nGID	= 1;--怪物生成ID
--tUserInfor.nLvLmt		= 100;--当前阶段关卡限制
--tUserInfor.nPoints		= 99999;--今日最高积分
--tUserInfor.nBuffLv		= 1;--BUFF等级
--p.ShowBloodBattleMainUI( tUserInfor );
end


---------------------------------------------------


---------------------------------------------------
-- 显示血战主界面(用户的信息)
function p.ShowBloodBattleMainUI( tUserInfor )
	--LogInfo( "BloodBattle: ShowBloodBattleMainUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "BloodBattle: ShowBloodBattleMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "BloodBattle: ShowBloodBattleMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.BloodBattle );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UI_ZORDER );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "BloodBattle: ShowBloodBattleMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "blood_battle/blood_battle.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	
	p.pLayerMainUI = layer;
	p.nDifficulty = BBD.NORMAL;
	p.ShowDifBtn( 1 );
	p.RefreshMainUI( tUserInfor );
	--
	ArenaUI.isInChallenge = 10;-- 血战结算
end

---------------------------------------------------
--
function p.Reset()
end

---------------------------------------------------
-- 刷新主界面(用户的信息)
function p.RefreshMainUI( tUserInfor )
	if ( p.pLayerMainUI == nil ) then
		return;
	end
	if ( tUserInfor == nil ) then
		return;
	end
	p.tUserInfor	 = tUserInfor;
	--
	local pLabelRecord = GetLabel( p.pLayerMainUI, ID_LABEL_RECORD );
	pLabelRecord:SetText( tUserInfor.nMaxLayer .. SZ_LEVEL );
	--
	local nTimes = tUserInfor.uChallMax - tUserInfor.nChallCount;
	if ( tUserInfor.nClimbLayer > 0 ) then--当前次第一关挑战开始挑战后则显示可的挑战次数才扣
		nTimes = nTimes - 1;
	end
	if ( nTimes < 0 ) then
		nTimes = 0;
	end
	local pLabelTimes	= GetLabel( p.pLayerMainUI, ID_LABEL_TIMES );
	pLabelTimes:SetText( nTimes .. SZ_TIME );
	--
	local pLabelPoints	= GetLabel( p.pLayerMainUI, ID_LABEL_POINTS );
	pLabelPoints:SetText( tUserInfor.nPoints .. "" );
	--
	local pLabelBuffLv	= GetLabel( p.pLayerMainUI, ID_LABEL_BUFF_LV );
	pLabelBuffLv:SetText( tUserInfor.nBuffLv .. GetTxtPri("Common_Level") );
	--
	p.ShowChallengeLevelNumber( tUserInfor.nClimbLayer + 1 );
	--
	p.ShowRivalName();
	--
	p.ShowClearStagePicture();
end

---------------------------------------------------
-- 过关则显示图片
function p.ShowClearStagePicture()
	if ( p.pLayerMainUI == nil ) then
		return;
	end
	if ( p.tUserInfor == nil ) then
		return;
	end
	local pUINode001	= GetUiNode( p.pLayerMainUI, ID_CHECK_BOX_NORMAL );
	local pUINode002	= GetUiNode( p.pLayerMainUI, ID_CHECK_BOX_HARD );
	local pUINode003	= GetUiNode( p.pLayerMainUI, ID_CHECK_BOX_HELL );
	local pUINode004	= GetUiNode( p.pLayerMainUI, ID_PIC_LEVEL_HUNDRADE );
	local pUINode005	= GetUiNode( p.pLayerMainUI, ID_PIC_LEVEL_DECADE );
	local pUINode006	= GetUiNode( p.pLayerMainUI, ID_PIC_LEVEL_UNIT );
	local pUINode007	= GetUiNode( p.pLayerMainUI, ID_PIC_LEVEL_UNIT );
	local pPic001		= GetUiNode( p.pLayerMainUI, ID_PIC_S_PIC1 );
	local pPic002		= GetUiNode( p.pLayerMainUI, ID_PIC_S_PIC2 );
	local pPic003		= GetUiNode( p.pLayerMainUI, ID_PIC_S_PIC3 );
	local pPic004		= GetUiNode( p.pLayerMainUI, ID_PIC_S_PIC4 );
	local pPic005		= GetUiNode( p.pLayerMainUI, ID_PIC_S_PIC5 );
	--
	local pPicCS		= GetUiNode( p.pLayerMainUI, ID_PIC_CLEAR_STAGE );

	if ( p.tUserInfor.nClimbLayer < p.tUserInfor.nLvLmt ) then--
		pUINode001:SetVisible(true);
		pUINode002:SetVisible(true);
		pUINode003:SetVisible(true);
		pUINode004:SetVisible(true);
		pUINode005:SetVisible(true);
		pUINode006:SetVisible(true);
		pUINode007:SetVisible(true);
		pPic001:SetVisible(true);
		pPic002:SetVisible(true);
		pPic003:SetVisible(true);
		pPic004:SetVisible(true);
		pPic005:SetVisible(true);
		pPicCS:SetVisible(false);
	else
		pUINode001:SetVisible(false);
		pUINode002:SetVisible(false);
		pUINode003:SetVisible(false);
		pUINode004:SetVisible(false);
		pUINode005:SetVisible(false);
		pUINode006:SetVisible(false);
		pUINode007:SetVisible(false);
		pPic001:SetVisible(false);
		pPic002:SetVisible(false);
		pPic003:SetVisible(false);
		pPic004:SetVisible(false);
		pPic005:SetVisible(false);
		pPicCS:SetVisible(true);
	end
end

---------------------------------------------------
-- 显示正在挑战关卡数
function p.ShowChallengeLevelNumber( nNum )
	if ( p.pLayerMainUI == nil ) then
		return;
	end
	local pImageHund = GetImage( p.pLayerMainUI, ID_PIC_LEVEL_HUNDRADE );
	local pImageDeca = GetImage( p.pLayerMainUI, ID_PIC_LEVEL_DECADE );
	local pImageUnit = GetImage( p.pLayerMainUI, ID_PIC_LEVEL_UNIT );
	local nHund = math.floor(math.mod( nNum/100, 10 ));
	local nDeca = math.floor(math.mod( nNum/10, 10 ));
	local nUnit = math.floor(math.mod( nNum, 10 ));
	local pool = DefaultPicPool();
	
	--LogInfo( "BloodBattle: ShowChallengeLevelNumber: nNum:%d, nHund:%d, nDeca:%d, nUnit:%d",nNum,nHund,nDeca,nUnit );
	--LogInfo( "BloodBattle: ShowChallengeLevelNumber: nNum:"..nNum..", nHund:"..nHund..", nDeca:"..nDeca..", nUnit:"..nUnit );
	if ( pImageHund ) then
		local tRect = CGRectMake( FIGURE_WIDTH*nHund, 0, FIGURE_WIDTH, FIGURE_HEIGHT );
		local pPic = pool:AddPicture( GetSMImgPath( SZ_PIC_NUM_PATH ), false);
		if ( pPic ) then
			pPic:Cut( tRect );
			pImageHund:SetPicture(pPic);
		end
	end
	if ( pImageDeca ) then
		local tRect = CGRectMake( FIGURE_WIDTH*nDeca, 0, FIGURE_WIDTH, FIGURE_HEIGHT );
		local pPic = pool:AddPicture( GetSMImgPath( SZ_PIC_NUM_PATH ), false);
		if ( pPic ) then
			pPic:Cut( tRect );
			pImageDeca:SetPicture(pPic);
		end
	end
	if ( pImageUnit ) then
		local tRect = CGRectMake( FIGURE_WIDTH*nUnit, 0, FIGURE_WIDTH, FIGURE_HEIGHT );
		local pPic = pool:AddPicture( GetSMImgPath( SZ_PIC_NUM_PATH ), false);
		if ( pPic ) then
			pPic:Cut( tRect );
			pImageUnit:SetPicture(pPic);
		end
	end
end

---------------------------------------------------
-- 关闭血战界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.BloodBattle, true );
	end
	p.nCurrentLevel				= nil;
	p.nDifficulty				= nil;
	p.pLayerMainUI				= nil;
	p.tUserInfor				= nil;
end

---------------------------------------------------
-- 宴会界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( tag == ID_BTN_START_CHALLENGE ) then
			if ( p.tUserInfor.nChallCount < p.tUserInfor.uChallMax ) then
				if ( p.tUserInfor.nClimbLayer < p.tUserInfor.nLvLmt ) then--
					MsgBloodBattle.SendMsgChallenge( p.nDifficulty );
				else
					CommonDlgNew.ShowYesDlg( SZ_PROMPT_00, nil, nil, 3 );
				end
			else
				CommonDlgNew.ShowYesDlg( SZ_ERROR_00, nil, nil, 3 );
			end
		elseif ( tag == ID_BTN_RESTART ) then
			MsgBloodBattle.SendMsgReset();
		elseif ( tag == ID_BTN_RULE_DESCRIPTION ) then
			p.ShowRuleDescriptionUI();
		--测试--直接显示奖励窗口
		--local tReward	= {};
		--tReward.nMoney		= 1999;
		--tReward.nItemType	= 1102072;
		--tReward.nItemAmount	= 2;
		--p.ShowRewardDlg( tReward )
		elseif ( tag == ID_BTN_RANKING ) then
			MsgBloodBattle.SendMsgRanking( 1 );--
		--测试--直接显示排名窗口
		--local nGrade = 1;
		--local tRanking = { {nRank=1,nLevel=100,nName="ufo"},{nRank=3,nLevel=90,nName="moon"},{nRank=4,nLevel=80,nName="sun"},{nRank=2,nLevel=99,nName="earth"}};
		--p.ShowRankingUI( nGrade,tRanking );
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( tag == ID_CHECK_BOX_NORMAL ) then
			p.nDifficulty = BBD.NORMAL;
			p.ShowDifBtn( 1 );
			p.ShowRivalName();
		elseif ( tag == ID_CHECK_BOX_HARD ) then
			p.nDifficulty = BBD.HARD;
			p.ShowDifBtn( 2 );
			p.ShowRivalName();
		elseif ( tag == ID_CHECK_BOX_HELL ) then
			p.nDifficulty = BBD.HELL;
			p.ShowDifBtn( 3 );
			p.ShowRivalName();
		end
	end
	return true;
end

---------------------------------------------------
-- 显示选难度择按钮各态
function p.ShowDifBtn( nDif )
	if ( p.pLayerMainUI == nil ) then
		return;
	end
	local pBtnNormal	= ConverToCheckBox( GetUiNode( p.pLayerMainUI, ID_CHECK_BOX_NORMAL ) );
	local pBtnHard		= ConverToCheckBox( GetUiNode( p.pLayerMainUI, ID_CHECK_BOX_HARD ) );
	local pBtnHell		= ConverToCheckBox( GetUiNode( p.pLayerMainUI, ID_CHECK_BOX_HELL ) );
	if ( nDif == 1 ) then
		pBtnNormal:SetSelect( true );
		pBtnHard:SetSelect( false );
		pBtnHell:SetSelect( false );
	elseif ( nDif == 2 ) then
		pBtnNormal:SetSelect( false );
		pBtnHard:SetSelect( true );
		pBtnHell:SetSelect( false );
	elseif ( nDif == 3 ) then
		pBtnNormal:SetSelect( false );
		pBtnHard:SetSelect( false );
		pBtnHell:SetSelect( true );
	end
end


---------------------------------------------------
-- 显示规则说明界面
function p.ShowRuleDescriptionUI()
	if ( p.pLayerMainUI == nil ) then
		return;
	end

	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "BloodBattle: ShowRuleDescriptionUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetFrameRect( RectFullScreenUILayer );
	p.pLayerMainUI:AddChildZ( layer,1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "BloodBattle: ShowRuleDescriptionUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "blood_battle/bb_rule.ini", layer, p.OnUIEventRuleDescription, 0, 0 );
	uiLoad:Free();
	
	local pLabel = GetLabel( layer, ID_LABEL_DESCRIPTION );
	pLabel:SetText( SZ_DESCRIPTION );
end

---------------------------------------------------
-- 关闭规则说明界面
function p.CloseRuleDescriptionUI()
end

---------------------------------------------------
-- 规则说明界面的事件响应
function p.OnUIEventRuleDescription( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_RULEDESCRIPTIONUI_CLOSE == tag ) then
			local pNode = uiNode:GetParent();
			pNode:RemoveFromParent(true);
		end
	end
	return true;
end

---------------------------------------------------
-- 显示挑战的怪物名字()
function p.ShowRivalName()
	if ( p.pLayerMainUI == nil ) then
		return;
	end
	if ( p.tUserInfor == nil ) then
		return;
	end
	if ( p.nDifficulty == nil ) then
		return;
	end
	
	local pLabelRival	= GetLabel( p.pLayerMainUI, ID_LABEL_RIVAL );
	local szEnemyInfo	= p.GetEnemyName( p.tUserInfor.nGID );
	pLabelRival:SetText( szEnemyInfo );
end


---------------------------------------------------
-- 获取敌物名(怪物的生成规则ID)
function p.GetEnemyName( nGenerateRuleID )
	local szEnemyInfo	= "";
	if ( nGenerateRuleID == nil ) or ( nGenerateRuleID <= 0 ) then
		return szEnemyInfo;
	end
	
	local nMonsterType	= 0;
	local szMonsterName	= "";
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS1 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS2 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS3 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS4 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS5 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS6 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS7 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS8 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "bloodbattle_monster_generate", nGenerateRuleID, DB_BLOODBATTLE_MONSTER_GENERATE.STATIONS9 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "bloodbattle_monster_addition", nMonsterType, DB_BLOODBATTLE_MONSTER_ADDITION.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	
	return szEnemyInfo;
end

---------------------------------------------------
-- 显示奖励信息对话框
function p.ShowRewardDlg( tReward )
	if ( p.pLayerMainUI == nil ) then
		return;
	end
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetFrameRect(RectFullScreenUILayer);
	p.pLayerMainUI:AddChildZ( layer, 1 );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("ShowYesDlg.ini", layer, p.OnUIEventRewardDlg, 0, 0);
	uiLoad:Free();
	
	local pLabel	= GetLabel( layer, 103 );--
	local szReward	= p.GetRewardString( tReward );
	if ( szReward ~= nil ) and ( szReward ~= "" ) then
		if ( p.tUserInfor.nClimbLayer < p.tUserInfor.nLvLmt ) then--
			szReward	= SZ_REWARD_TITLE .. szReward;
		else
			szReward	= SZ_PROMPT_01 .. szReward;
		end
	end
	pLabel:SetText(szReward);
end

---------------------------------------------------
-- 显示不在时间点对话框
function p.ShowTimeOutDlg()
	CommonDlgNew.ShowYesDlg( SZ_ERROR_02, nil, nil, 3 );
end

---------------------------------------------------
-- 奖励信息对话框事件响应
function p.OnUIEventRewardDlg( uiNode, uiEventType, param )
    local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == 101 ) then--确定
			local pNode = uiNode:GetParent();
			pNode:RemoveFromParent(true);
		end
	end
	return true;
end

-- 获得奖励内容的字符串
function p.GetRewardString( tReward )
    local szResult = "";
    
    if ( tReward.nMoney > 0 ) then
    	szResult = szResult .. string.format(GetTxtPub("coin").."+%d, ", tReward.nMoney);
    end
    if ( tReward.nItemType > 0 ) and ( tReward.nItemAmount > 0 ) then
            szResult = szResult ..string.format(ItemFunc.GetName(tReward.nItemType).."+%d, ", tReward.nItemAmount);
	end
    return szResult;
end

---------------------------------------------------
---------------------------------------------------
local ID_BTN_RANKINGUI_CLOSE		= 49;	-- 排名界面关闭按钮

local ID_BTN_RANKINGUI_GRADE1		= 91;	-- 低级段
local ID_BTN_RANKINGUI_GRADE2		= 92;	-- 中级段
local ID_BTN_RANKINGUI_GRADE3		= 93;	-- 高级段
local ID_BTN_RANKINGUI_GRADE4		= 94;	-- 顶级段

local ID_LIST_CONTAINER				= 50;	-- 列表容器;
local ID_PIC_BORDER					= 1000;

---------------------------------------------------
local ID_LABEL_RANK					= 5;	-- 排名
local ID_LABEL_NAME					= 79;	-- 英雄
local ID_LABEL_LEVEL				= 84;	-- 关数

---------------------------------------------------
p.tRankingList		= nil;	-- 排名表的列表
p.pLayerRankingUI	= nil;	-- 排名界面层
p.nGrade			= nil;	-- 当前阶段--根据等级划分
---------------------------------------------------
-- 显示排名界面
function p.ShowRankingUI( nGrade, tRanking )
	p.tRankingList	 	= nil;
	p.pLayerRankingUI	= nil;
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "BloodBattle: ShowRankingUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "BloodBattle: ShowRankingUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.BloodBattleRanking );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UI_ZORDER );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "BloodBattle: ShowRuleDescriptionUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "blood_battle/bb_rank.ini", layer, p.OnUIRanking, 0, 0 );
	uiLoad:Free();
	p.pLayerRankingUI = layer;
	p.RefreshRankingUI( nGrade, tRanking );
end

---------------------------------------------------
-- 关闭排名界面
function p.CloseRankingUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.BloodBattleRanking, true );
	end
	p.tRankingList	 = nil;
	p.pLayerRankingUI	= nil;
end

---------------------------------------------------
-- 规则说明界面的事件响应
function p.OnUIRanking( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_RANKINGUI_CLOSE == tag ) then
			p.CloseRankingUI();
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( tag == ID_BTN_RANKINGUI_GRADE1 ) then
			p.HighLightGradeButton( p.nGrade );
			if ( p.tRankingList[1] == nil ) then
				 MsgBloodBattle.SendMsgRanking( 1 );
			else
				if ( p.nGrade ~= 1 ) then
					p.nGrade	= 1;
					p.FillRankgList( p.tRankingList[1] );
					p.HighLightGradeButton( p.nGrade );
				end
			end
		elseif ( tag == ID_BTN_RANKINGUI_GRADE2 ) then
			p.HighLightGradeButton( p.nGrade );
			if ( p.tRankingList[2] == nil ) then
				 MsgBloodBattle.SendMsgRanking( 2 );
			else
				if ( p.nGrade ~= 2 ) then
					p.nGrade	= 2;
					p.FillRankgList( p.tRankingList[2] );
					p.HighLightGradeButton( p.nGrade );
				end
			end
		elseif ( tag == ID_BTN_RANKINGUI_GRADE3 ) then
			p.HighLightGradeButton( p.nGrade );
			if ( p.tRankingList[3] == nil ) then
				 MsgBloodBattle.SendMsgRanking( 3 );
			else
				if ( p.nGrade ~= 3 ) then
					p.nGrade	= 3;
					p.FillRankgList( p.tRankingList[3] );
					p.HighLightGradeButton( p.nGrade );
				end
			end
		elseif ( tag == ID_BTN_RANKINGUI_GRADE4 ) then
			p.HighLightGradeButton( p.nGrade );
			if ( p.tRankingList[4] == nil ) then
				 MsgBloodBattle.SendMsgRanking( 4 );
			else
				if ( p.nGrade ~= 4 ) then
					p.nGrade	= 4;
					p.FillRankgList( p.tRankingList[4] );
					p.HighLightGradeButton( p.nGrade );
				end
			end
		end
	end
	return true;
end

---------------------------------------------------
-- 刷新排名列表
function p.RefreshRankingUI( nGrade, tRanking )
	if ( p.pLayerRankingUI == nil ) then
		return;
	end
	if ( nGrade == nil ) then
		return;
	end
	if ( tRanking == nil ) then
		return;
	end
	if ( p.tRankingList == nil ) then
		p.tRankingList = {};
	end
	table.sort( tRanking, function(a,b) return a.nRank<b.nRank end );
	p.tRankingList[nGrade] = tRanking;
	p.nGrade = nGrade;
	p.FillRankgList( tRanking );
	p.HighLightGradeButton( nGrade );
end

---------------------------------------------------
-- 填充排名列表
function p.FillRankgList( tRanking )
	if ( p.pLayerRankingUI == nil ) then
		return;
	end
	if ( tRanking == nil ) then
		LogInfo( "BloodBattle: FillRankgList() failed! tRanking is nil" );
		return;
	end
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "blood_battle/bb_L.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
    
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerRankingUI, ID_LIST_CONTAINER );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "BloodBattle: FillRankgList() failed! pScrollViewContainer is nil" );
		return;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	local nItemAmount = table.getn( tRanking );
	if ( nItemAmount == 0 ) then
		LogInfo( "BloodBattle: FillRankgList() failed! nItemAmount is 0" );
		return;
	end
	local szPlayerName	= GetRoleBasicDataS(GetPlayerId(), USER_ATTR.USER_ATTR_NAME);
	for i = 1, nItemAmount do
		local pListItem = createUIScrollView();
		if not CheckP( pListItem ) then
			LogInfo( "ArmyGroup: pListItem == nil" );
			return false;
		end
	
		pListItem:Init( false );
		pListItem:SetScrollStyle( UIScrollStyle.Verical );
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pScrollViewContainer:AddView( pListItem );
		
		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "Member: FillListContainer failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "blood_battle/bb_L.ini", pListItem, nil, 0, 0 );
		uiLoad:Free();
		
		local pLabelRank	= GetLabel( pListItem, ID_LABEL_RANK );
		local pLabelName	= GetLabel( pListItem, ID_LABEL_NAME );
		local pLabelLevel	= GetLabel( pListItem, ID_LABEL_LEVEL );
		
		pLabelRank:SetText( SafeN2S(tRanking[i].nRank) );
		pLabelName:SetText( tRanking[i].szName );
		pLabelLevel:SetText( SafeN2S(tRanking[i].nLevel) );
		--
		if ( tRanking[i].szName == szPlayerName ) then
			pLabelName:SetFontColor( ccc4(255,0,0,255) );
		end
	end
end

---------------------------------------------------
-- 高亮某阶段按钮
function p.HighLightGradeButton( nGrade )
	if ( nGrade == nil ) then
		return;
	end
	if ( p.pLayerRankingUI == nil ) then
		return;
	end
	local pBtnGrade1 = ConverToCheckBox( GetUiNode( p.pLayerRankingUI, ID_BTN_RANKINGUI_GRADE1 ) );
	local pBtnGrade2 = ConverToCheckBox( GetUiNode( p.pLayerRankingUI, ID_BTN_RANKINGUI_GRADE2 ) );
	local pBtnGrade3 = ConverToCheckBox( GetUiNode( p.pLayerRankingUI, ID_BTN_RANKINGUI_GRADE3 ) );
	local pBtnGrade4 = ConverToCheckBox( GetUiNode( p.pLayerRankingUI, ID_BTN_RANKINGUI_GRADE4 ) );
	
	if ( nGrade == 1 ) then
		pBtnGrade1:SetSelect(true);
		pBtnGrade2:SetSelect(false);
		pBtnGrade3:SetSelect(false);
		pBtnGrade4:SetSelect(false);
	elseif ( nGrade == 2 ) then
		pBtnGrade1:SetSelect(false);
		pBtnGrade2:SetSelect(true);
		pBtnGrade3:SetSelect(false);
		pBtnGrade4:SetSelect(false);
	elseif ( nGrade == 3 ) then
		pBtnGrade1:SetSelect(false);
		pBtnGrade2:SetSelect(false);
		pBtnGrade3:SetSelect(true);
		pBtnGrade4:SetSelect(false);
	elseif ( nGrade == 4 ) then
		pBtnGrade1:SetSelect(false);
		pBtnGrade2:SetSelect(false);
		pBtnGrade3:SetSelect(false);
		pBtnGrade4:SetSelect(true);
	end
end

