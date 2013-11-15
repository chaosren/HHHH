/*
 *  NDSdkLogin.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "MobageSdkLoginAndroid.h"
#include "ScriptGlobalEvent.h"
#include "NDDirector.h"
#include "ScriptMgr.h"

#include "NDBeforeGameMgr.h"
#include "SMLoginScene.h"
#include "SMGameScene.h"
#include "NDDataTransThread.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>
#include "android/jni/JniHelper.h"
#include "CCTMXTiledMap.h"
#include "CCSprite.h"

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif


extern void clearSplash();


void MobageSdkLoginAndroid::onLoginComplete(int userId) {
	LOGD("@@login app delegate onLoginComplete userId %d", userId);
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	mgr.SetCurrentUser(userId);
}

void MobageSdkLoginAndroid::onLoginError() {
    
}

void MobageSdkLoginAndroid::onLogout() {
    quitGame();
}
