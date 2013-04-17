/*
 *  ScriptCommon.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-9.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "ScriptCommon.h"
#include "ScriptInc.h"
#include "NDPath.h"
#include "NDUtility.h"
#include <sstream>
#include <string>
#include <map>
#include "NDPicture.h"
#include "CCTextureCacheExt.h"
#include "ScriptDefine.h"
#include "ScriptMgr.h"

// #ifndef UPDATE_RES
// #define UPDATE_RES 1
// #endif

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaScriptMsg"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace LuaPlus;
using namespace std;

#include "define.h"

NS_NDENGINE_BGN

int LuaLogInfo(LuaState* state)
{
	LuaStack kArgs(state);
	LuaStackObject kStackObj = kArgs[1];
	LuaObject kString(kStackObj);
	
	if (kString.IsString())
	{
		ScriptMgrObj.WriteLog("[lua] %s", kString.GetString());
	}
	
	return 0;
}

int LuaColorInfo(LuaState* state)
{
	LuaStack kArgs(state);
	LuaObject kString = kArgs[1];
	LuaObject kLevel = kArgs[2];

	if (kString.IsString())
	{
		const char* pszTemp = kString.GetString();

		ScriptMgrObj.WriteLog("[lua] %s", kString.GetString());

		if (kLevel.IsNil())
		{
			ScriptMgrObj.DebugOutPut("[lua] %s",kString.GetString());
		}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		unsigned int uiLogLevel = kLevel.ToInteger();

		switch(uiLogLevel)
		{
		case 1:
			ScriptMgrObj.ColorDebugOutPut(FOREGROUND_GREEN,"[lua] %s", pszTemp);
		case 2:
			ScriptMgrObj.ColorDebugOutPut(FOREGROUND_BLUE,"[lua] %s", pszTemp);
		case 3:
			ScriptMgrObj.ColorDebugOutPut(FOREGROUND_RED,"[lua] %s", pszTemp);
		default:
			ScriptMgrObj.DebugOutPut("[lua] %s", pszTemp);
			break;
		}
#endif
	}

	return 0;
}

int LuaLogError(LuaState* state)
{
	LuaStack args(state);
	LuaObject str = args[1];
	
	if (str.IsString())
	{
		ScriptMgrObj.DebugOutPut("[lua] Error:%s", str.GetString());
		//WriteCon("@@lua: %s\r\n", str.GetString());
	}
	
	return 0;
}

int DoFile(LuaState* state)
{
	int nRet = -1;
	LuaStack args(state);
	LuaObject str = args[1];
	
	if (str.IsString())
	{
#ifndef UPDATE_RES
#if _DEBUG
        cocos2d::CCLog("DoFile:%s", NDPath::GetScriptPath(str.GetString()).c_str());
#endif
		nRet = state->DoFile(NDPath::GetScriptPath(str.GetString()).c_str());
#else
		string strTemp = NDPath::GetScriptPath(str.GetString());
		const char* szTemp = strTemp.c_str();
        ScriptMgrObj.LoadLuaFile(strTemp.c_str());
#endif
	}
	
	return nRet;
}

int LeftShift(int x, int y)
{
	return x << y;
}	

int RightShift(int x, int y)
{
	return x >> y;
}

int BitwiseAnd(int x, int y)
{
	int nRes = x&y;
	return nRes;
}

////////////////////////////////////////////////////////////
//std::string g_strTmpWords;
////////////////////////////////////////////////////////////

void ScriptCommonLoad()
{
	ETLUAFUNC("LuaLogInfo", LuaLogInfo);
	ETLUAFUNC("LuaColorInfo", LuaColorInfo);
	ETLUAFUNC("LuaLogError", LuaLogError);
	ETLUAFUNC("DoFile", DoFile);
	ETCFUNC("LeftShift", LeftShift);
	ETCFUNC("RightShift", RightShift);
	ETCFUNC("BitwiseAnd", BitwiseAnd);
	ETCFUNC("PicMemoryUsingLogOut", PicMemoryUsingLogOut);
}

NS_NDENGINE_END