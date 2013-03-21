//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDPath.h"
#include "define.h"
#include "ObjectTracker.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#endif

#include "CCFileUtils.h"//cocos2d

NS_NDENGINE_BGN
///////////////////////////<<<

#define SZ_ROOT_SOURCE_DIR					"SimplifiedChineseRes/"	//按语种划分资源根目录名
#define SZ_CONF_FILE_DIR					"config/"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
//#define NDPath_ResPath		      "/sdcard/dhlj/SimplifiedChineseRes/res/"
//#define NDPath_ImgPath			 "/sdcard/dhlj/SimplifiedChineseRes/res/Image/"
//#define NDPath_ImgPath_BattleUI	 "/sdcard/dhlj/SimplifiedChineseRes/res/Image/battle_ui/"
//#define NDPath_ImgPath_UINew		 "/sdcard/dhlj/SimplifiedChineseRes/res/Image/ui_new/"
//#define NDPath_MapPath			 "/sdcard/dhlj/SimplifiedChineseRes/res/map/"
//#define NDPath_AniPath			 "/sdcard/dhlj/SimplifiedChineseRes/res/animation/"
//#define NDPath_SoundPath			 "/sdcard/dhlj/SimplifiedChineseRes/res/sound/"
//#define NDPath_UIPath			 "/sdcard/dhlj/SimplifiedChineseRes/res/UI/"
//#define NDPath_ScriptPath		 "/sdcard/dhlj/SimplifiedChineseRes/res/Script/"
#define NDPath_LogPath			 "/sdcard/dhlj/"
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
//#define NDPath_ResPath			 "../../Bin/SimplifiedChineseRes/res/"
// #define NDPath_ImgPath			 "../SimplifiedChineseRes/res/Image/"
// #define NDPath_ImgPath_BattleUI	 "../SimplifiedChineseRes/res/Image/battle_ui/"
// #define NDPath_ImgPath_UINew		 "../SimplifiedChineseRes/res/Image/ui_new/"
// #define NDPath_MapPath			 "../SimplifiedChineseRes/res/map/"
// #define NDPath_AniPath			 "../SimplifiedChineseRes/res/animation/"
// #define NDPath_SoundPath			 "../SimplifiedChineseRes/res/sound/"
// #define NDPath_UIPath			 "../SimplifiedChineseRes/res/UI/"
// #define NDPath_ScriptPath		 "../SimplifiedChineseRes/res/Script/"
#define NDPath_LogPath			 "log/"
#endif


////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDPath, NDObject)

int NDPath::s_iResDirPos = 0;

NDPath::NDPath()
{
	INC_NDOBJ_RTCLS
}
NDPath::~NDPath()
{
	DEC_NDOBJ_RTCLS
}

const char* NDPath::GetRootResDirName()
{
	return SZ_ROOT_SOURCE_DIR;
}

//===========================================================================
//应用程序目录（工作目录，资源最初目录）
const string NDPath::GetAppPath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return std::string([[[NSBundle mainBundle] resourcePath] UTF8String]) + "/";
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return "/sdcard/dhlj/";
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	return "../../Bin/";
#endif
}

//===========================================================================
//获取Cashe 目录（可更新的资源文件目录）
const string NDPath::GetCashesPath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
     // NSError *error;
#if 0
     NSString *path1 = [NSHomeDirectory()stringByAppendingPathComponent:@"Library"];
     NSString *CashesDirectory = [path1 stringByAppendingPathComponent:@"/Caches"];
     return std::string([CashesDirectory UTF8String]) +"/";
#else
    string path = std::string([[[NSBundle mainBundle] resourcePath] UTF8String]) + "/";
    return path;
#endif
    
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return "/sdcard/dhlj/";
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	return "../../Bin/";
#endif
}

//===========================================================================
//获取文档目录（临时文件目录）
const string NDPath::GetDocumentPath()
{
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	return std::string([documentsDirectory UTF8String]) + "/";
//
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//	return "/sdcard/dhlj/";
//#endif
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
//	return "./";
//#endif
	return cocos2d::CCFileUtils::sharedFileUtils()->getWriteablePath();
}

//===========================================================================
//获取资源根路径
const string NDPath::GetRootResPath(bool bPackage)
{
    string ret;
	if ( s_iResDirPos == 0 )
	{
		ret = NDPath::GetAppPath() + SZ_ROOT_SOURCE_DIR;
	}
	else
	{
		if (bPackage)
		{
			LOGD("Entry bPackage");
			ret = string(SZ_ROOT_SOURCE_DIR);
		}
		else
		{
			ret = NDPath::GetCashesPath() + SZ_ROOT_SOURCE_DIR;
		}
	}
    return ret;
}

//===========================================================================
const string NDPath::GetLogPath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return NDPath::GetDocumentPath();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return NDPath_LogPath;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	return NDPath::GetCashesPath() + NDPath_LogPath;
#endif
}


//===========================================================================
//获取普通资源路径
const string NDPath::GetResPath(bool bPackage)
{
	return NDPath::GetRootResPath(bPackage) + "res/";
}

const string NDPath::GetResPath(const char* fileName)
{
	string ret;
	ret = GetResPath() + string(fileName);
	PrintResStatistic(ret);

	return ret;
}

const string NDPath::GetImagePath(bool bPackage)
{
    return GetResPath(bPackage) + string("image/");
}
const string NDPath::GetImage00Path()
{
	return GetResPath() + string("image00/");
}

const string NDPath::GetMapPath()
{
    return GetResPath() + string("map/");
}

const string NDPath::GetSoundPath()
{
    return GetResPath() + string("sound/");
}

const string NDPath::GetAnimationPath()
{
    return GetResPath() + string("animation/");
}

const string NDPath::GetUIPath()
{
    return GetResPath() + string("UI/");
}

const string NDPath::GetUIPath( const char* fileName )
{
    return GetUIPath() + string(fileName);
}

const string NDPath::GetImgPathBattleUI()
{
    return GetResPath("image/battle_ui/");
}

const string NDPath::GetFullImagepath(const char* pszFileName)
{
	return GetImgPath(pszFileName);
}

const string NDPath::GetImgPath(const char* filename,bool bPackage)
{
	static string ret;
	ret = GetImagePath(bPackage) + filename;
	PrintResStatistic(ret);
	return ret;
}
const string NDPath::GetImg00Path(const char* filename)
{
	static string ret;
	ret = GetImage00Path() + filename;
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetImgPathBattleUI(const char* fileName)
{
	static string ret;
	ret = GetResPath("image/battle_ui/") + fileName;
	PrintResStatistic(ret);
	return ret;
}


const string NDPath::GetAniPath(const char* fileName)
{
	static string ret;
	ret = GetAnimationPath() + fileName;
	PrintResStatistic(ret);
	return ret;
}

// 新界面资源统一放在 res/image/ui_new
const string NDPath::GetImgPathUINew(const char* fileName)
{
	static string ret;
	ret = GetResPath("image/ui_new/")+ fileName;
	PrintResStatistic(ret);
	return ret;
}

// 新界面高分辨率资源统一放在 res/image/ui_new/advance
const string NDPath::GetImgPathUINewAdvance(const char* fileName)
{
	static string ret;
	ret = GetResPath("image/ui_new/advance/")+ fileName;
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetMapPath(const char* fileName)
{
	static string ret;
	ret = GetResPath("map/")+ fileName;
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetUIConfigPath(const char* filename)
{
	static string ret;
	ret = GetUIPath() + filename;
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetUIImgPath(const char* uiFileNameWithPath)
{
	static string ret;
	ret = NDPath::GetRootResPath() + uiFileNameWithPath;
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetSMImgPath(const char* fileName)
{
	static string ret;
	ret = GetImagePath() + "Res00/" + fileName;
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetSMImg00Path(const char* fileName)
{
	static string ret;
	ret = GetImage00Path() + "Res00/" + fileName;
	PrintResStatistic(ret);
	return ret;
}


const string NDPath::GetScriptPath(const char* filename)
{
	static string ret;
	ret = GetScriptPath() + filename;
	PrintResStatistic(ret);
	return ret;
}


const string NDPath::GetScriptPath()
{
    return GetResPath("Script/");
}

const string NDPath::GetImgPathNew( const char* fileName )
{
	static string ret;
	ret = GetResPath("image/ui_new/") + string(fileName);
	PrintResStatistic(ret);
	return ret;
}

const string NDPath::GetImgPathNewAdvance( const char* fileName )
{
	static string ret;
	ret = GetResPath("image/ui_new/advance/") + fileName;
	PrintResStatistic(ret);
	return ret;
}
    
//++Guosen 2012.8.9
void NDPath::SetResDirPos( int iPos )
{
	NDPath::s_iResDirPos = iPos;
}

const string NDPath::GetDBPath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return "/sdcard/dhlj/";
#else
	return "";
#endif
}

const string NDPath::GetGameConfigPath( const char* pszConfFileName,
									   bool bPackage )
{
	string strRet = "";

	if (0 == pszConfFileName || !*pszConfFileName)
	{
		return strRet;
	}

	strRet = GetRootResPath(bPackage) + SZ_CONF_FILE_DIR +
		string(pszConfFileName);

	return strRet;
}


//資源統計
#define RES_STATISTICS

#ifdef	RES_STATISTICS
//#include "ScriptMgr.h"
 map<string, int> mapResPathNum;
#endif

//打印資源統計結果
void NDPath::PrintResStatistic(const string ResPath)
{
#ifdef	RES_STATISTICS
	int iCount = mapResPathNum.count(ResPath);
	++mapResPathNum[ResPath];
	//ScriptMgrObj.excuteLuaFunc("GetPlayerLevel", "Transport");

	if(iCount == 0)
	{
		FILE *Pfile;
		char filename[256] = {0};
		char buff[256] = {0};
		memset(filename, 0, sizeof(filename));
		memset(buff, 0, sizeof(buff));
		
		sprintf(filename, "%s/ResStatistic.txt", NDPath::GetLogPath().c_str());
	   	sprintf(buff, "%s", ResPath.c_str());
		Pfile = fopen(filename, "a");  
		//fseek(Pfile, 0, SEEK_END);

		if(Pfile)
		{
			fwrite(ResPath.c_str(), 1, ResPath.size()+1, Pfile);
			fwrite("\n", 1, 1, Pfile);
			fclose(Pfile);
			Pfile = 0;
		}

	}
#endif
}

void NDPath::ClearResPath()
{
	mapResPathNum.clear();
}

///////////////////////////>>>

NS_NDENGINE_END
