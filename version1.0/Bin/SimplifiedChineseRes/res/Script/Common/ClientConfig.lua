---------------------------------------------------
--描述: 客户端配置信息,每个版本对应一个，以后不会更新本文件
--时间: 2013.8.28
--作者: wjl
---------------------------------------------------
ClientConfig = {}
local p = ClientConfig;


--豪华版配置
p.LUXURY_CONFIG =
{
    NOT_LUXURY = 0,
    LUXURY = 1,
    END = 11,
};
--客户端类型配置
p.CLIENT_TYPE_CONFIG =
{
	CLIENT_TYPE_BEGIN = 0,
	CLIENT_TYPE_ANDROID_LUXURY = 1,         --安卓繁体豪华版
	CLIENT_TYPE_ANDROID_NORMAL = 2,         --安卓繁体普通版
	CLIENT_TYPE_ANDROID_INTERNAL = 3,       --安卓繁体国际版
	CLIENT_TYPE_IOS_LUXURY = 4,            --ios繁体豪华版
	CLIENT_TYPE_IOS_NORMAL = 5,            --ios繁体普通版
	CLIENT_TYPE_IOS_INTERNAL = 6,          --ios繁体国际版
   	CLIENT_TYPE_END = 7, 
};function p.GetLuxuryConfig()   return p.LUXURY_CONFIG.NOT_LUXURY;   --非豪华版
endfunction p.GetClientTypeConfig()   return p.CLIENT_TYPE_CONFIG.CLIENT_TYPE_ANDROID_NORMAL;   --安卓繁体普通版end