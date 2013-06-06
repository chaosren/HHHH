local _MSG_GENERAL = 1000;

NMSG_Type = 
{
    _MSG_LOAD                       = 110;
    _MSG_TALK                       = _MSG_GENERAL + 4,
	_MSG_USERINFO					= _MSG_GENERAL + 8,
	_MSG_USERINFO_UPDATE			= _MSG_GENERAL + 40,
	TASK_NPC_MSG					= _MSG_GENERAL + 22,
	_MSG_PETINFO					= _MSG_GENERAL + 39,
	_MSG_PETINFO_UPDATE				= _MSG_GENERAL + 3000,
	_MSG_TASK_ACTION				= _MSG_GENERAL + 1097,
	_MSG_TASK_DATA_ACTION			= _MSG_GENERAL + 1098,
	_MSG_TASK_NPC_ACTION			= _MSG_GENERAL + 1099,
    _MSG_TASK_CONDITION             = _MSG_GENERAL + 1100,
    
    
    _MSG_GM_MAIL                    = _MSG_GENERAL + 1537,
	_MSG_ITEM_INFO					= _MSG_GENERAL + 16,
	_MSG_ITEM_ACTION				= _MSG_GENERAL + 17,
    _MSG_LOGIN_SUC                  = _MSG_GENERAL + 26,
    _MSG_CONNECTREPLY				= _MSG_GENERAL + 49,
    _MSG_SERVERROLE                 = _MSG_GENERAL + 158,
    _MSG_SERVERLISTITEM             = _MSG_GENERAL + 159,
    _MSG_CREATE_TEMP_CREDENTIAL     = _MSG_GENERAL + 190,
    _MSG_CREATE_TEMP_CREDENTIAL_RET = _MSG_GENERAL + 191,
    _MSG_REQUEST_ACCESS_TOKEN = _MSG_GENERAL + 192,
    _MSG_REQUEST_ACCESS_TOKEN_RET = _MSG_GENERAL + 193,
	
	_MSG_MATRIX_LIST				= _MSG_GENERAL + 3500,
	_MSG_MATRIX_ADDED				= _MSG_GENERAL + 3501,
	_MSG_MATRIX_UPGRADED			= _MSG_GENERAL + 3502,
	_MSG_MATRIX_COOLDOWN			= _MSG_GENERAL + 3503,
	_MSG_MATRIX_STATION				= _MSG_GENERAL + 3504,
	_MSG_MATRIX_STATION_OPEN		= _MSG_GENERAL + 3505,
    
    _MSG_SKILL_INFO_LIST            = _MSG_GENERAL + 3575,
    _MSG_USER_CURRENT_SKILL         = _MSG_GENERAL + 3577,
    _MSG_AFFIX_BOSS_NML_AGAIN	    = _MSG_GENERAL + 1000,
	_MSG_ATTACK_LIST				= _MSG_GENERAL + 3510,
	_MSG_ATTACK_ADDED				= _MSG_GENERAL + 3511,
	_MSG_ATTACK_UPGRADED			= _MSG_GENERAL + 3512,
	_MSG_ATTACK_COOLDOWN			= _MSG_GENERAL + 3513,
	_MSG_REALIZE_MERGE				= _MSG_GENERAL + 3516,
	_MSG_REALIZE_OPEN				= _MSG_GENERAL + 3517,
	_MSG_REALIZE_BUY				= _MSG_GENERAL + 3518,
	_MSG_REALIZE_LIST				= _MSG_GENERAL + 3529,
	_MSG_REALIZE_SALE				= _MSG_GENERAL + 3530,
	_MSG_REALIZE_PICKUP_ALL			= _MSG_GENERAL + 3531,
	_MSG_REALIZE_SALE_ALL			= _MSG_GENERAL + 3532,
	_MSG_REALIZE_MERGE_ALL			= _MSG_GENERAL + 3533,
	_MSG_REALIZE_BUY_ALL			= _MSG_GENERAL + 3534,
    _MSG_REALIZE_QMDJ               = _MSG_GENERAL + 3535,  -- 奇门遁甲
    _MSG_REALIZE_PICKUP             = _MSG_GENERAL + 3536,  -- 拾取
    _MSG_REALIZE_OP                 = _MSG_GENERAL + 3537,  -- 打开
    

    _MSG_ROLE_TRAIN_GET				= _MSG_GENERAL + 3506,
	_MSG_ROLE_TRAIN_TRAIN			= _MSG_GENERAL + 3507,
	_MSG_ROLE_TRAIN_COMMIT			= _MSG_GENERAL + 3508,
	_MSG_EQUIP_UPD_CD_LST			= _MSG_GENERAL + 3522,
	_MSG_EQUIP_UPD_CD_CLEAN			= _MSG_GENERAL + 3523,
	_MSG_EQUIP_UPD_CD_QUE_ADD		= _MSG_GENERAL + 3524,

	_MSG_PET_SHOP_ACTION			= _MSG_GENERAL + 3001,
	_MSG_ITEM_ATTRIB				= _MSG_GENERAL + 45,
	_MSG_PET_IMPART					= _MSG_GENERAL + 3005,
	
	_MSG_AFFIX_BOSS_NML_OPEN	    = _MSG_GENERAL + 3540,
	_MSG_AFFIX_BOSS_NML_ENTER		= _MSG_GENERAL + 3541,       --进入副本
	_MSG_AFFIX_BOSS_NML_CLEARUP		= _MSG_GENERAL + 3542,
	_MSG_AFFIX_BOSS_NML_CANCEL      = _MSG_GENERAL + 3543,
	_MSG_AFFIX_BOSS_NML_FINISH		= _MSG_GENERAL + 3544,
	_MSG_AFFIX_BOSS_NML_LEAVE		= _MSG_GENERAL + 3545,       --退出副本
	_MSG_AFFIX_BOSS_NML_RESET		= _MSG_GENERAL + 3550,
	_MSG_AFFIX_BOSS_NML_RAISE		= _MSG_GENERAL + 3555,      --用来副本信息更新
	_MSG_AFFIX_BOSS_CLEANUP_BATTLE	= _MSG_GENERAL + 3570,
	_MSG_AFFIX_BOSS_CLEANUP_RAISE	= _MSG_GENERAL + 3571,
	_MSG_AFFIX_BOSS_GROUP_RAISE		= _MSG_GENERAL + 3572,
	_MSG_AFFIX_BOSS_GET_BOX_LST		= _MSG_GENERAL + 3573,
	_MSG_AFFIX_BOSS_PICK_BOX_ITEM	= _MSG_GENERAL + 3574,

	_MSG_NPC						= _MSG_GENERAL+1031,
	
	_MSG_BOSS_BATTLE_INFO			= _MSG_GENERAL + 3007,
	_MSG_BOSS_SELF_INFO				= _MSG_GENERAL + 3009,
	_MSG_LIMIT						= _MSG_GENERAL+1508,	-- 格子上限
	
	_MSG_BOSS_BATTLE				= _MSG_GENERAL + 3006,
	
	_MSG_SPORTS						= _MSG_GENERAL + 3002,
	_MSG_SPORTS_INFO				= _MSG_GENERAL + 3003,
	_MSG_SPORTS_FRONT_INFO			= _MSG_GENERAL + 3004,
	_MSG_SPORTS_WATCH_BATTLE		= _MSG_GENERAL + 3010,
    _MSG_SPORTS_COUNT               = _MSG_GENERAL + 3013,  --获得PK剩余次数 chh 2012-07-11
    _MSG_SPORTS_FRONT_RECORD        = _MSG_GENERAL + 3014,  --第一名争夺战
	_MSG_DAILY_ACTIVITY_LIST		= _MSG_GENERAL + 3557,
	_MSG_START_BOSS_BATTLE			= _MSG_GENERAL + 3558,
	_MSG_INSANCING_LEAVE			= _MSG_GENERAL + 3545,
	_MSG_INSTANCING_BATTLE_LOG		= _MSG_GENERAL + 3566,  --副本站攻略
	_MSG_STONE                      = _MSG_GENERAL + 5503,
	_MSG_START_FORMULA_DATA			= _MSG_GENERAL + 1505,
    --Login Message
    MB_LOGINSYSTEM_MOBILE_SERVER_NOTIFY = 60000,
    MB_LOGINSYSTEM_CREATE_NEWBIE        = 60018,
    _MSG_NOTIFY_CLIENT              = _MSG_GENERAL+1028,
	_MSG_QUIT_BOSS_BATTLE			= _MSG_GENERAL + 3559,
	
	_MSG_GIFTPACK_LIST				= _MSG_GENERAL + 3520,
	_MSG_GET_GIFTPACK				= _MSG_GENERAL + 3519,
	
	_MSG_USER_STATE				    = _MSG_GENERAL + 1306,  --状态变化
	_MSG_USER_STATE_CHG				= _MSG_GENERAL + 1308,  --删除状态
	_MSG_CHOOSE_CAMP				= _MSG_GENERAL + 3012,  --选择阵营
	_MSG_SENDLETTER 				= _MSG_GENERAL + 400,	--发邮件++Guosen
	_MSG_RECEIED_LETTER 			= _MSG_GENERAL + 401,   --收邮件
	_MSG_LETTER_INFO       			= _MSG_GENERAL + 402,   --邮件详细信息
	_MSG_LETTER_REQUEST      		= _MSG_GENERAL + 403,   --邮件操作
	_MSG_USE_PILL                   = _MSG_GENERAL + 3561,  --使用丹药
	
	_MSG_EQUIPSTR_INFO              = _MSG_GENERAL + 1507,  --装备强化
	_MSG_EQUIPSTR_UPDATE            = _MSG_GENERAL + 4000,  --加速冷却时间

	_MSG_GOODFRIEND                 = _MSG_GENERAL + 1500,  --好友交互
	
	_MSG_NIMBUS                     = _MSG_GENERAL + 4001,  --器灵消息
    
    
    --坐骑
    _MSG_MOUNT_INFO_LIST			=_MSG_GENERAL+5001,     --获得坐骑信息
    _MSG_USER_CHANGE_MOUNT_TYPE     =_MSG_GENERAL+5002,     --幻化
    _MSG_USER_CHANGE_MOUNT_STATUS	=_MSG_GENERAL+5003,     --休息/骑
    _MSG_USER_CHANGE_MOUNT_UPGRUDE	=_MSG_GENERAL+5004,     --培养
    
    --军衔
    _MSG_RANK_UPGRADE               =_MSG_GENERAL+3578,     --升级军衔
    
    
    --背包
    _MSG_SHOP                       =_MSG_GENERAL+23,      --商店
    

    --神秘商人
    _MSG_PET_SHOP_MilOrders			= _MSG_GENERAL+6000,    --军令购买
    _MSG_CONFIG_MYSTERIOUS_GOODS    = _MSG_GENERAL+6001,    --宝石列表
    _MSG_BUY_LEVY                   = _MSG_GENERAL+6002,    --征收功能
    _MSG_SACRIFICE_INFO_LIST        = _MSG_GENERAL+6004,    --祭祀列表
    _MSG_CONFIRM_SACRIFICE          = _MSG_GENERAL+6005,    --确认祭祀
    
    -- 武将培养
	_MSG_TRAIN_INFO_LIST			= _MSG_GENERAL+6011;	-- 培养列表
	_MSG_CONFIRM_TRAIN_PET			= _MSG_GENERAL+6012;	-- 确认培养武将
	_MSG_END_TRAIN_PET				= _MSG_GENERAL+6013;	-- 结束培养武将
	_MSG_GET_TRAIN_PET_EXP			= _MSG_GENERAL+6014;	-- 获取培养附加经验

    --洗炼
    _MSG_EQUIP_EDU_INFO             = _MSG_GENERAL+5506,    --洗练信息
    _MSG_TRY_EQUIP_EDU              = _MSG_GENERAL+5507,    --洗练
    _MSG_CONFIRM_EQUIP_EDU          = _MSG_GENERAL+5508,    --确认洗练
    
    --GM反馈
    _MSG_GM_MAIL_LIST               = _MSG_GENERAL+5509,   --查询gm问题

	--将星图
	_MSG_ADVANCED_GS                       =_MSG_GENERAL+7000,

    --教程
    _MSG_UPGRADE_GUIDE_STAGE        = _MSG_GENERAL+6020,    --接收教程进度信息

    
    _MSG_AG_USERINFO					= 2338,		-- 玩家的军团的属性更改
    _MSG_ARMYGROUP						= 2302,		-- 军团消息
    --
    _MSG_GetDistributeHistory			= 2339,
    _MSG_DistributeHistory				= 2340,
    --
	_MSG_CLIENT_VERSION				= 60008,	--版本验证
	_MSG_MPF_VERSION				= 60009,	--新版本验证


    _MSG_GIFTPACK_ITEM_INFO         = _MSG_GENERAL + 6021,  --礼包物品反馈信息
    _MSG_ACHIEVEMENT_INFO_LIST = _MSG_GENERAL + 6025,  --大话兵法中兵法状态改变信息
    _MSG_ACHIEVEMENT_GET_PRIZE = _MSG_GENERAL + 6026,  --大话兵法中获取成就奖励信息
    
    _MSG_VIEW_PLAYER                    =   _MSG_GENERAL + 6035,        --主城查看其它玩家列表
    _MSG_BATTLEUI_TITLE					= _MSG_GENERAL + 6036,	--战斗TITLE消息

	_MSG_LUCKYBOX							= _MSG_GENERAL + 6041,		-- 幸运宝箱
	_MSG_TREASUREHUNT						= _MSG_GENERAL + 6042,		-- 古迹寻宝
	_MSG_PRIZE_INFO							= _MSG_GENERAL + 6043,		-- 古迹寻宝-奖励内容
	_MSG_QUESTION_INFO						= _MSG_GENERAL + 6044,		-- 古迹寻宝-问答
    _MSG_BANQUET                            = _MSG_GENERAL+6050,	--宴会
    _MSG_WARLORD                            = _MSG_GENERAL+6071,	--战神像

    _MSG_PLAYER_ACTION_INFO            =   _MSG_GENERAL + 7001,              --活动信息
    _MSG_PLAYER_ACTION_OPERATE   =   _MSG_GENERAL + 7002,               --活动操作

    _MSG_BATTLE_ENCOURAGE   =   _MSG_GENERAL + 7004,                    --鼓舞
    _MSG_ADDTION            =   _MSG_GENERAL + 7005,                    --pvp属性加成查询

	--==================大乱斗=====================--
    _MSG_CHAOSBATTLE_BOARD				= _MSG_GENERAL+8000,	--大乱斗活动板信息
    _MSG_CHAOSBATTLE_ADDREPORT			= _MSG_GENERAL+8001,	--增加战报
    _MSG_CHAOSBATTLE_CAMPLIST			= _MSG_GENERAL+8002,	--阵营列表
    _MSG_CHAOSBATTLE_CAMPLISTCHANGE     = _MSG_GENERAL+8003,	--阵营列表变化
    _MSG_CHAOSBATTLE_MAINREPORT         = _MSG_GENERAL+8004,	--总战报
    _MSG_CHAOSBATTLE_RANKBOARD			= _MSG_GENERAL+8005,	--排行榜
    _MSG_CHAOSBATTLE_USERREPORT         = _MSG_GENERAL+8006,	--个人战报
    _MSG_CHAOSBATTLE_UPDATEPLAYERINFO	= _MSG_GENERAL+8007,	--更新玩家信息
    _MSG_CHAOSBATTLE_WEEKINFO           = _MSG_GENERAL+8008,	--衰落信息
    
    
    _MSG_CHAOSBATTLE_ACTION             = _MSG_GENERAL+8050,	--大乱斗操作
    _MSG_CHAOSBATTLE_ACTION_RET         = _MSG_GENERAL+8051,	--大乱斗操作返回


	--==================军团战=====================--
    _MSG_SYNDICATEBATTLE_ACTION         = _MSG_GENERAL+8100,    --军团战动作
    _MSG_SYNDICATEBATTLE_ACTION_RET     = _MSG_GENERAL+8101,    --军团战动作返回
    _MSG_SYNDICATEBATTLE_SIGNUP_INFO    = _MSG_GENERAL+8102,    --军团战报名信息
    _MSG_SYNDICATEBATTLE_STEPS_INFO     = _MSG_GENERAL+8103,    --各个阶段战况
    _MSG_SYNDICATEBATTLE_BATTLE_RESULT  = _MSG_GENERAL+8104,    --具体对战结果
    _MSG_SYNDICATEBATTLE_CAMP_LIST      = _MSG_GENERAL+8105,    --阵营列表
    _MSG_SYNDICATEBATTLE_CHANGE_CAMP    = _MSG_GENERAL+8106,    --阵营列表改变
    _MSG_SYNDICATEBATTLE_BATTLE_OVER    = _MSG_GENERAL+8107,    --一场对战结束
    _MSG_SYNDICATEBATTLE_REPORT         = _MSG_GENERAL+8108,    --对战战报
    _MSG_SYNDICATEBATTLE_PLAYERINFO     = _MSG_GENERAL+8109,    --玩家信息
    

    --==================名人堂=====================--
    _MSG_RANKING    = _MSG_GENERAL+8110,    --
    
    --==================日常任务=====================--
    _MSG_DAILYTASK    = _MSG_GENERAL+6070,    --

    --==================断线重连=====================--
    _MSG_OPERATE_STATUS     = _MSG_GENERAL+7006,    --客户端操作状态


	--==================斗地主=====================--
  _MSG_LANDLORDS_ACTION				= _MSG_GENERAL+8120;		--斗地主动作
  _MSG_LANDLORDS_ACTION_RET			= _MSG_GENERAL+8121;		--斗地主动作返回
  _MSG_LANDLORDS_NOTIFY				= _MSG_GENERAL+8122;		--斗地主通知
  _MSG_LANDLORDS_TARGET_LIST			= _MSG_GENERAL+8123;		--目标列表
  _MSG_LANDLORDS_SYNSLAVES			= _MSG_GENERAL+8124;		--本家族中被捕的人员
  _MSG_LANDLORDS_ENEMY_LIST			= _MSG_GENERAL+8125;		--仇人列表
  _MSG_LANDLORDS_PLAYER_INFO			= _MSG_GENERAL+8126;		--斗地主玩家信息  
  _MSG_LANDLORDS_SOS_LIST			= _MSG_GENERAL+8127;		--斗地主玩家信息  

    _MSG_PLAYER_ACTION_LIST   =   _MSG_GENERAL + 7003,               --下发活动列表
        

    _MSG_RECIVE_TRANSPORT            =   _MSG_GENERAL + 6030,              --运送粮草信息
    _MSG_SEND_TRANSPORT   =   _MSG_GENERAL + 6031,               --运送粮草操作信息
    _MSG_RECV_INFO                =   _MSG_GENERAL + 6032,               --运粮过程中接收到的消息      
    
    _MSG_QUEUE_BEGIN                =   _MSG_GENERAL + 2034,               --登入排队开始         
    _MSG_QUEUE_END                =   _MSG_GENERAL + 2035,               --登入排队结束     
    

    _MSG_EVENT_LIST               = _MSG_GENERAL + 7007,         --充值活动数据接收消息

    _MSG_BULLETIN                   = _MSG_GENERAL + 101,           --公告消息
    
    _MSG_MAP_BUFF_ACTION     = _MSG_GENERAL+8140,    --玩家状态请求
    _MSG_MAP_BUFF_ACTION_RET     = _MSG_GENERAL+8141,    --玩家状态请求返回
    _MSG_MAP_BUFF_BUFFLIST     = _MSG_GENERAL+8142,    --玩家状态列表数据
    

    _MSG_MOUNTSOUL            =   _MSG_GENERAL + 6060,	-- 兽魂
    
    _MSG_GMCOMMAND              = 139,      --gm com
};