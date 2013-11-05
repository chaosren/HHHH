---------------------------------------------------
--描述: 玩家数据配置
--时间: 2013.4.19
--作者: tzq
---------------------------------------------------
PlayerDataConfig = {}
local p = PlayerDataConfig;


--名將亂彈資源更新類型      这里做个记录，实际数据从game_config.json中读取
p.MJLT_RES_UPDATE_TYPE =
{
    RES_NONE = 0,           
    RES_IOS_CN_91 = 10,           --IOS簡體91版本
};


--玩家平台类型
p.PLAYER_PLATFORM_TYPE =
{
	TYPE_NONE = 0,				--小米
	TYPE_XIAOMI = 1,          --小米
	TYPE_ND91JIJIN = 2,        --91积金
	PLATFORM_TYPE_Mobage = 3,	-- 梦包谷SDK
	PLATFORM_TYPE_UC = 4,		-- UC 平台
	PLATFORM_TYPE_JF = 5,		-- 机锋 平台
	PLATFORM_TYPE_DL = 6,		-- 当乐 平台
	PLATFORM_TYPE_PP = 7,		-- PP助手 平台
	PLATFORM_TYPE_SELF = 8,		-- 公司自己的 平台
	PLATFORM_TYPE_MAX          -- 平台类型上限
};

p.CurPlatFormType = p.PLAYER_PLATFORM_TYPE.PLATFORM_TYPE_SELF;

function p.GetCurPlatFormType()
	return p.CurPlatFormType;
end