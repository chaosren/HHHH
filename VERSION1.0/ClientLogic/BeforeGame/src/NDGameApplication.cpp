#include "NDGameApplication.h"
#include "NDDirector.h"
#include "SMLoginScene.h"
#include "CCEGLView.h"
#include "NDPath.h"
#include "ScriptCommon.h"
#include "ScriptGlobalEvent.h"
#include "ScriptNetMsg.h"
#include "ScriptUI.h"
#include "ScriptGameLogic.h"
#include "SMGameScene.h"
#include "GameScene.h"
#include "ScriptTimer.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "NDNpc.h"
#include "ScriptDrama.h"
#include <ScriptGameLogic.h>
#include "NDSocket.h"
#include "NDMapMgr.h"
#include "LuaStateMgr.h"
#include "NDBeforeGameMgr.h"
#include "ScriptGameData.h"
#include "ScriptGameData_NewUtil.h"
#include "NDDebugOpt.h"
#include "NDClassFactory.h"
#include "Battle.h"
#include "NDProfile.h"
#include "NDBaseDirector.h"
#include "WorldMapScene.h"
#include "NDUILoad.h"
#include "ScriptRegLua.h"
#include "ObjectTracker.h"
#include "CCTextureCache.h"
#include "NDPicture.h"
#include "TextureList.h"
#include "NDAnimationGroupPool.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "Foundation/NSAutoreleasePool.h"
#import "EAGLView.h"
static NDBaseDirector s_NDBaseDirector;
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "android/jni/JniHelper.h"
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

#include "BattleMgr.h"
#include "NDBaseBattleMgr.h"
#include "NDNetMsg.h"
#include "NDBaseNetMgr.h"
#include "NDBaseScriptMgr.h"
#include "ScriptMgr.h"
#include "NDBaseGlobalDialog.h"
#include "GlobalDialog.h"
#include "UIItemButton.h"
#include "UIEquipItem.h"
#include "NDUIBaseItemButton.h"
#include "UIItemButton.h"

#include "SqliteDBMgr.h"
#include "NDUILoadEngine.h"
#include "NDVideoMgr.h"
#include "../CocosDenshion/include/SimpleAudioEngine.h"
#include "NDUtil.h"
#include "NDUtility.h"

using namespace CocosDenshion;

///////////////////////////////////////////
//@android: for test only
void dumpCocos2dx()
{
	CCLog( "@@------------------------------------------------------------{{\r\n" );

	// dump NDDirector & CCDirector
	{
		CCLog( 
			//			"hero pos(%d, %d)\r\n"
			"[CCDirector] size in Points  (%d, %d)\r\n"
			"[CCDirector] size in Pixels  (%d, %d)\r\n"
			"[CCDirector] content scale = %.1f\r\n"
			,
			//			(int)posScreen.x, (int)posScreen.y, //screen pos in pixels.

			(int)CCDirector::sharedDirector()->getWinSize().width,
			(int)CCDirector::sharedDirector()->getWinSize().height,

			(int)CCDirector::sharedDirector()->getWinSizeInPixels().width,
			(int)CCDirector::sharedDirector()->getWinSizeInPixels().height,

			CCDirector::sharedDirector()->getContentScaleFactor()
			);
	}

	// dump EGL view
	{
		CCEGLView* eglView = CCDirector::sharedDirector()->getOpenGLView();
		if (eglView)
		{
			CCLog(
				"\r\n"
				"[EGLVIEW] frame     size (%d, %d)\r\n"
				"[EGLVIEW] designed  size (%d, %d)\r\n"
				"[EGLVIEW] viewport  size (%d, %d)\r\n"
				"[EGLVIEW] visible   org  (%d, %d)\r\n"
				"[EGLVIEW] visible   size (%d, %d)\r\n"
				"[EGLVIEW] scale (%.1f, %.1f)\r\n"
				//"[EGLVIEW] resolution policy (%d)\r\n"
				"[EGLVIEW] retina enabled (%d)\r\n"
				,
				/*frame*/	(int)eglView->getFrameSize().width,			(int)eglView->getFrameSize().height, 
				/*designed*/(int)eglView->getSize().width,				(int)eglView->getSize().height, 
				/*viewport*/(int)eglView->getViewPortRect().origin.x,	(int)eglView->getViewPortRect().origin.y, //in origin, not in size!
				/*vis org*/	(int)eglView->getVisibleOrigin().x,			(int)eglView->getVisibleOrigin().y,
				/*vis size*/(int)eglView->getVisibleSize().width,		(int)eglView->getVisibleSize().height,
				/*scale*/	eglView->getScaleX(), eglView->getScaleY(),
				/*policy*/
				/*retina*/	(int)eglView->isRetinaEnabled()
				);
		}
	}

	// 	// dump map layer
	// 	{
	// 		extern NDMapLayer* g_pMapLayer; //for debug only.
	// 		if (g_pMapLayer)
	// 		{
	// 			sprintf( msg, 
	// 				"\r\n"
	// 				"[NDMapLayer] content size (%d, %d)\r\n"
	// 				"[NDMapLayer] screen center (%d, %d)\r\n", 
	// 				(int)g_pMapLayer->GetContentSize().width,
	// 				(int)g_pMapLayer->GetContentSize().height,
	// 				(int)g_pMapLayer->GetScreenCenter().x,
	// 				(int)g_pMapLayer->GetScreenCenter().y
	// 				);
	// 
	// 			WriteConsoleA( hOut, msg, strlen(msg), &n, NULL );	
	// 		}
	// 	}

	// 	// dump world map layer
	// 	{
	// 		extern WorldMapLayer* g_pWorldMapLayer; //for debug only.
	// 		if (g_pWorldMapLayer)
	// 		{
	// 			sprintf( msg, 
	// 				"\r\n"
	// 				"[WorldMapLayer] content size (%d, %d)\r\n", 
	// 				(int)g_pWorldMapLayer->GetContentSize().width,
	// 				(int)g_pWorldMapLayer->GetContentSize().height
	// 				);
	// 
	// 			WriteConsoleA( hOut, msg, strlen(msg), &n, NULL );	
	// 		}
	// 	}

	CCLog( "@@------------------------------------------------------------}}\r\n" );
}




NS_NDENGINE_BGN
using namespace NDEngine;

NDGameApplication::NDGameApplication()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	NDConsole::instance().RegisterConsoleHandler(this,"script ");
#endif
	CCLog( "@@ NDGameApplication::ctor()\r\n");
}
NDGameApplication::~NDGameApplication()
{
	CCLog( "@@ NDGameApplication::dtor()\r\n");
}

bool NDGameApplication::applicationDidFinishLaunching()
{
	CCDirector* pDirector = CCDirector::sharedDirector();
	CCDirector::sharedDirector()->stopAnimation();
	CCAssert(pDirector, "applicationDidFinishLaunching");
	pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

	TargetPlatform target = getTargetPlatform();

	if (target == kTargetIpad)
	{
		// ipad

		CCFileUtils::sharedFileUtils()->setResourceDirectory("iphonehd");

		// don't enable retina because we don't have ipad hd resource
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(960, 640,
			kResolutionNoBorder);
	}
	else if (target == kTargetIphone)
	{
		// iphone

		// try to enable retina on device
		if (true == CCDirector::sharedDirector()->enableRetinaDisplay(true))
		{
			// iphone hd
			CCFileUtils::sharedFileUtils()->setResourceDirectory("iphonehd");
		}
		else
		{
			CCFileUtils::sharedFileUtils()->setResourceDirectory("iphone");
		}
	}
	else if (target == kTargetAndroid)
	{
		CCEGLView* eglView = CCDirector::sharedDirector()->getOpenGLView();
		CCLog("Entryu setDesignResolutionSize");
		CCLog("@@ before setDesignResolutionSize(), frameSize=(%d,%d)\r\n",
			(int) eglView->getFrameSize().width,
			(int) eglView->getFrameSize().height);
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(
			eglView->getFrameSize().width, eglView->getFrameSize().height,
			kResolutionNoBorder);
	}
	else
	{
		// android, windows, blackberry, linux or mac
		// use 960*640 resources as design resolution size
		//CCFileUtils::sharedFileUtils()->setResourceDirectory("iphonehd");
		//CCEGLView::sharedOpenGLView()->setDesignResolutionSize(480*2, 320*2, kResolutionNoBorder);//@todo
		CCDirector::sharedDirector()->enableRetinaDisplay(true);	//@retina

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

		// initialize socket
		InitSocket();
#endif
	}

	// turn on display FPS
	pDirector->setDisplayStats(false); //@fps

	// set FPS. the default value is 1.0/60 if you don't call this
	//pDirector->setAnimationInterval(1.0 / 60);
	LOGD("tzqtzqtzq pDirector->setAnimationInterval() value is %d", (int) pDirector);
	pDirector->setAnimationInterval(1.0 / 24.0);

#if 0 //@todo @hello
	// create a scene. it's an autorelease object
	CCScene *pScene = HelloWorld::scene();

	// run
	pDirector->runWithScene(pScene);
	//////////////////////////////////////////////
#else
	MyInit();
#endif

//	hideSplash();

	return true;
}

//@init
void NDGameApplication::hideSplash()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"showSplash",
		"(I)V"))
	{
		t.env->CallStaticObjectMethod(t.classID, t.methodID, jint(0));
		t.env->DeleteLocalRef(t.classID);
	}
#endif
}

//@init
void NDGameApplication::MyInit()
{
	SimpleAudioEngine::sharedEngine()->setEffectsVolume(7.0f);

	REGISTER_CLASS(NDBaseBattle,BattleUILayer);
	REGISTER_CLASS(NDBaseFighter,Fighter);
	REGISTER_CLASS(NDBaseBattleMgr,BattleMgr);
	REGISTER_CLASS(NDSprite,NDPlayer);
	REGISTER_CLASS(NDUtil,NDUtility);
	REGISTER_CLASS(NDBaseNetMgr,NDNetMsgPool);
	REGISTER_CLASS(NDBaseScriptMgr,ScriptMgr);
	REGISTER_CLASS(NDBaseGlobalDialog,CIDFactory);
	REGISTER_CLASS(NDUIBaseItemButton,CUIItemButton);
	REGISTER_CLASS(NDUIBaseItemButton,CUIEquipItem);
	REGISTER_CLASS(NDUILoadEngine,NDUILoad);


	NDMapMgr& kMapMgr = NDMapMgrObj;
	NDBeforeGameMgrObj;
	LOGD("NDBeforeGameMgrObj Over");

	NDDirector* pkDirector = NDDirector::DefaultDirector();
	pkDirector->Initialization();

	NDScriptRegLua::doReg(); //@reglua
	ScriptMgrObj.LoadRegClassFuncs(); //ע��C++�ӿڵ�LUA�����漰����LUA��.

//---init++Guosen 2012.11.29
    CSqliteDBMgr::shareInstance().InitDataBase("DNSG.sqlite");
    NDColorPoolObj;
    NDBeforeGameMgrObj.InitAccountTable();
//---init

	CCLog( "@@ now to run CSMLoginScene\r\n" );
	pkDirector->RunScene(CSMLoginScene::Scene(true));

	LOGD("pkDirector->RunScene(CSMLoginScene::Scene()); Over");

	//-------------------------------------------------------------
	dumpCocos2dx(); //@android //@del
	//-------------------------------------------------------------
}

void NDGameApplication::applicationDidEnterBackground()
{
#ifdef USE_MGSDK
    [MBGPlatform pause];
#endif
	CCDirector::sharedDirector()->stopAnimation();

	// if you use SimpleAudioEngine, it must be pause
	SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
	CCLog( "@@ NDGameApplication::applicationDidEnterBackground()\r\n" );
}

void NDGameApplication::applicationWillEnterForeground()
{
#ifdef USE_MGSDK
    [MBGPlatform resume];
#endif
	CCDirector::sharedDirector()->startAnimation();

	if (NDDataTransThread::DefaultThread()->GetQuitGame())
	{
		quitGame();
		NDDataTransThread::DefaultThread()->Stop();
		NDDataTransThread::ResetDefaultThread();
	}

	// if you use SimpleAudioEngine, it must resume here
	SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
	CCLog( "@@ NDGameApplication::applicationWillEnterForeground()\r\n" );
}

//@pm
bool NDGameApplication::processConsole( const char* pszInput )
{
	if (0 == pszInput || !*pszInput)
	{
		return false;
	}

	LuaStateMgrObj.GetState().m_state->DoString(pszInput);

	return true;
}

//@pm
bool NDGameApplication::processPM(const char* cmd) 
{
	if (cmd == 0 || cmd[0] == 0) return false;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	int n = 0, val = 0;
	char szDebugOpt[50] = {0};

	HANDLE hOut = NDConsole::instance().getOutputHandle();

	if (stricmp(cmd, "opt help") == 0)
	{
		TCHAR help[] =	L"syntax: opt arg 0/1\r\n"
			L"arg can be: tick, script, network, mainloop, drawhud, drawui, drawmap, drawrole, drawrolenpc, drawrolemonster, drawroleplayer, drawrolemanual.\r\n";

		DWORD n = 0;
		WriteConsoleW( hOut, help, sizeof(help)/sizeof(TCHAR), &n, NULL );
	}
	else if (sscanf(cmd, "opt %s %d", szDebugOpt, &val) == 2)
	{
		if (stricmp(szDebugOpt, "tick") == 0)
			NDDebugOpt::setTickEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "script") == 0)
			NDDebugOpt::setScriptEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "network") == 0)
			NDDebugOpt::setNetworkEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "mainloop") == 0)
			NDDebugOpt::setMainLoopEnabled( val != 0 );

		//
		else if (stricmp(szDebugOpt, "drawhud") == 0)
			NDDebugOpt::setDrawHudEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawui") == 0)
			NDDebugOpt::setDrawUIEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawmap") == 0)
			NDDebugOpt::setDrawMapEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawcell") == 0)
			NDDebugOpt::setDrawCellEnabled( val != 0 );

		//
		else if (stricmp(szDebugOpt, "drawrole") == 0)
			NDDebugOpt::setDrawRoleEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawrolenpc") == 0 ||
					stricmp(szDebugOpt, "drawnpc") == 0)
		{
			NDDebugOpt::setDrawRoleNpcEnabled( val != 0 );
		}
		else if (stricmp(szDebugOpt, "drawrolemonster") == 0 ||
					stricmp(szDebugOpt, "drawmonster") == 0)
		{
			NDDebugOpt::setDrawRoleMonsterEnabled( val != 0 );
		}
		else if (stricmp(szDebugOpt, "drawroleplayer") == 0 ||
					stricmp(szDebugOpt, "drawplayer") == 0)
		{
			NDDebugOpt::setDrawRolePlayerEnabled( val != 0 );
		}
		else if (stricmp(szDebugOpt, "drawrolemanual") == 0 ||
					stricmp(szDebugOpt, "drawmanual") == 0)
		{
			NDDebugOpt::setDrawRoleManualEnabled( val != 0 );
		}

		//
		else if (stricmp(szDebugOpt, "runanimmanual") == 0)
		{
			NDDebugOpt::setRunAnimManualEnabled( val != 0 );
		}
		else if (stricmp(szDebugOpt, "runanimplayer") == 0)
		{
			NDDebugOpt::setRunAnimPlayerEnabled( val != 0 );
		}
		else if (stricmp(szDebugOpt, "runanimnpc") == 0)
		{
			NDDebugOpt::setRunAnimNpcEnabled( val != 0 );
		}
		else if (stricmp(szDebugOpt, "runanimrole") == 0)
		{
			NDDebugOpt::setRunAnimRoleEnabled( val != 0 );
		}
	}
	else if (sscanf(cmd, "openmap %d", &val) == 1)
	{
		//NDMapMgrObj.Hack_loadSceneByMapDocID( val );
	}
	else if (stricmp(cmd, "profile") == 0)
	{
		NDProfileReport::report();
	}
	else if (stricmp(cmd, "profile dump") == 0)
	{
		NDProfileReport::dump();
	}
	else if (stricmp(cmd, "dumprole") == 0)
	{
		NDScene* pScene = NDDirector::DefaultDirector()->GetRunningScene();
		int childrenCount = pScene->GetChildren().size();
		for (int i = 0; i < childrenCount; i++)
		{
			NDNode* pNode = pScene->GetChildren().at(i);
			if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
			{
				NDMapLayer* pLayer = (NDMapLayer*)pNode;
				pLayer->dumpRole();
			}
		}	
	}
	else if (stricmp(cmd, "showhero") == 0)
	{
		CCPoint posScreen = NDPlayer::defaultHero().GetPosition();
		DWORD n = 0;
		char msg[500] = "";
		sprintf( msg, "hero pos(%d, %d)\r\n", (int)posScreen.x, (int)posScreen.y );
		WriteConsoleA( hOut, msg, sizeof(msg), &n, NULL );		
	}
	else if (stricmp(cmd, "info") == 0)
	{
		CCPoint posScreen = NDPlayer::defaultHero().GetPosition();
		DWORD n = 0;
		char msg[500] = "";

		// dump NDDirector & CCDirector
		{
			LOGD( msg, 
				"hero pos(%d, %d)\r\n"
				"[CCDirector] size in Points  (%d, %d)\r\n"
				"[CCDirector] size in Pixels  (%d, %d)\r\n"
				"[CCDirector] content scale = %.1f\r\n"
				,
				(int)posScreen.x, (int)posScreen.y, //screen pos in pixels.

				(int)CCDirector::sharedDirector()->getWinSize().width,
				(int)CCDirector::sharedDirector()->getWinSize().height,

				(int)CCDirector::sharedDirector()->getWinSizeInPixels().width,
				(int)CCDirector::sharedDirector()->getWinSizeInPixels().height,

				CCDirector::sharedDirector()->getContentScaleFactor()
				);

			sprintf( msg, 
				"hero pos(%d, %d)\r\n"
				"[CCDirector] size in Points  (%d, %d)\r\n"
				"[CCDirector] size in Pixels  (%d, %d)\r\n"
				"[CCDirector] content scale = %.1f\r\n"
				,
				(int)posScreen.x, (int)posScreen.y, //screen pos in pixels.

				(int)CCDirector::sharedDirector()->getWinSize().width,
				(int)CCDirector::sharedDirector()->getWinSize().height,

				(int)CCDirector::sharedDirector()->getWinSizeInPixels().width,
				(int)CCDirector::sharedDirector()->getWinSizeInPixels().height,

				CCDirector::sharedDirector()->getContentScaleFactor()
				);

			WriteConsoleA( hOut, msg, strlen(msg), &n, NULL );		
		}

		// dump EGL view
		{
			CCEGLView* eglView = CCDirector::sharedDirector()->getOpenGLView();
			if (eglView)
			{
				LOGD(msg,
					"\r\n"
					"[EGLVIEW] frame     size (%d, %d)\r\n"
					"[EGLVIEW] designed  size (%d, %d)\r\n"
					"[EGLVIEW] viewport  size (%d, %d)\r\n"
					"[EGLVIEW] visible   org  (%d, %d)\r\n"
					"[EGLVIEW] visible   size (%d, %d)\r\n"
					"[EGLVIEW] scale (%.1f, %.1f)\r\n"
					//"[EGLVIEW] resolution policy (%d)\r\n"
					"[EGLVIEW] retina enabled (%d)\r\n"
					,
					/*frame*/	(int)eglView->getFrameSize().width,			(int)eglView->getFrameSize().height, 
					/*designed*/(int)eglView->getSize().width,				(int)eglView->getSize().height, 
					/*viewport*/(int)eglView->getViewPortRect().origin.x,	(int)eglView->getViewPortRect().origin.y, //in origin, not in size!
					/*vis org*/	(int)eglView->getVisibleOrigin().x,			(int)eglView->getVisibleOrigin().y,
					/*vis size*/(int)eglView->getVisibleSize().width,		(int)eglView->getVisibleSize().height,
					/*scale*/	eglView->getScaleX(), eglView->getScaleY(),
					/*policy*/
					/*retina*/	(int)eglView->isRetinaEnabled()
					);
				sprintf( msg, 
					"\r\n"
					"[EGLVIEW] frame     size (%d, %d)\r\n"
					"[EGLVIEW] designed  size (%d, %d)\r\n"
					"[EGLVIEW] viewport  size (%d, %d)\r\n"
					"[EGLVIEW] visible   org  (%d, %d)\r\n"
					"[EGLVIEW] visible   size (%d, %d)\r\n"
					"[EGLVIEW] scale (%.1f, %.1f)\r\n"
					//"[EGLVIEW] resolution policy (%d)\r\n"
					"[EGLVIEW] retina enabled (%d)\r\n"
					,
					/*frame*/	(int)eglView->getFrameSize().width,			(int)eglView->getFrameSize().height, 
					/*designed*/(int)eglView->getSize().width,				(int)eglView->getSize().height, 
					/*viewport*/(int)eglView->getViewPortRect().origin.x,	(int)eglView->getViewPortRect().origin.y, //in origin, not in size!
					/*vis org*/	(int)eglView->getVisibleOrigin().x,			(int)eglView->getVisibleOrigin().y,
					/*vis size*/(int)eglView->getVisibleSize().width,		(int)eglView->getVisibleSize().height,
					/*scale*/	eglView->getScaleX(), eglView->getScaleY(),
					/*policy*/
					/*retina*/	(int)eglView->isRetinaEnabled()
					);

				WriteConsoleA( hOut, msg, strlen(msg), &n, NULL );		
			}
		}

		// dump map layer
		{
			extern NDMapLayer* g_pMapLayer; //for debug only.
			if (g_pMapLayer)
			{
				sprintf( msg, 
					"\r\n"
					"[NDMapLayer] content size (%d, %d)\r\n"
					"[NDMapLayer] screen center (%d, %d)\r\n", 
					(int)g_pMapLayer->GetContentSize().width,
					(int)g_pMapLayer->GetContentSize().height,
					(int)g_pMapLayer->GetScreenCenter().x,
					(int)g_pMapLayer->GetScreenCenter().y
					);

				WriteConsoleA( hOut, msg, strlen(msg), &n, NULL );	
			}
		}

		// dump world map layer
		{
			extern WorldMapLayer* g_pWorldMapLayer; //for debug only.
			if (g_pWorldMapLayer)
			{
				sprintf( msg, 
					"\r\n"
					"[WorldMapLayer] content size (%d, %d)\r\n", 
					(int)g_pWorldMapLayer->GetContentSize().width,
					(int)g_pWorldMapLayer->GetContentSize().height
					);

				WriteConsoleA( hOut, msg, strlen(msg), &n, NULL );	
			}
		}
	}
	else if (sscanf(cmd, "slowdown %d", &val) == 1)
	{
		extern int g_slowDownMul;
		g_slowDownMul = max(1,val);
	}
	else if (
		sscanf(cmd, "drawdebug %d", &val) == 1 ||
		sscanf(cmd, "debugdraw %d", &val) == 1 ||
		sscanf(cmd, "enablefocus %d", &val) == 1)
	{
		NDDebugOpt::setDrawDebugEnabled(val);
	}
	else if (stricmp(cmd, "test") == 0) //open test ui (test.ini)
	{
		NDScene* pScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (pScene)
		{
			pScene->RemoveAllChildren( false );

			NDUILayer *	pLayer	= new NDUILayer();
			if (pLayer)
			{
				pLayer->Initialization();
				pLayer->SetFrameRect( CCRectMake(0, 0, 960, 640));
				pLayer->SetTag( 0x100 );
				pScene->AddChild(pLayer,10);

				NDUILoad loader;
				loader.Load( "test.ini", pLayer, NULL );
			}
		}
	}
	else if (stricmp(cmd, "gamedb") == 0) //don't del. for debuging.
	{
		NDGameDataUtil::showMemStat();
		NDGameData& pGameData = NDGameData::Instance();
		int x = 0;
	}
	else if (stricmp(cmd, "dumptouch") == 0)
	{
		string str = CCDirector::sharedDirector()->getTouchDispatcher()->dump();
		DWORD n = 0;
		WriteConsoleA(  hOut, str.c_str(), str.length(), &n, NULL );
	}

	//dump obj
	else if (n = sscanf(cmd, "dumpobj %d", &val)) //n=
	{
		val = (n > 0 ? val : 0);
		string info;
		DUMP_OBJ(info, val);

		DWORD num = 0;
		WriteConsoleA(  hOut, info.c_str(), info.length(), &num, NULL );
	}

	//dump tex
	else if (stricmp( cmd, "dumptex" ) == 0 
				|| stricmp( cmd, "dumptexture" ) == 0)
	{
		string info = CCTextureCache::sharedTextureCache()->dumpCachedTextureInfo();
		DWORD num = 0;
		WriteConsoleA(  hOut, info.c_str(), info.length(), &num, NULL );
	}

	//dump pic
	else if (stricmp( cmd, "dumppic" ) == 0)
	{
		string info = NDPicturePool::DefaultPool()->dump();
		DWORD num = 0;
		WriteConsoleA(  hOut, info.c_str(), info.length(), &num, NULL );
	}

	//dump texlist
	//else if (stricmp( cmd, "dumptexlist" ) == 0)
	else if (n = sscanf(cmd, "dumptexlist %s", szDebugOpt))
	{
		if (n == 0) strcpy( szDebugOpt, "" );
		string info = TextureList::instance().dump( szDebugOpt );
		
		DWORD num = 0;
		WriteConsoleA(  hOut, info.c_str(), info.length(), &num, NULL );
	}

	//dump anim group pool
	else if (stricmp( cmd, "dumpanim" ) == 0)
	{
		string info = NDAnimationGroupPool::defaultPool()->dump();
		DWORD num = 0;
		WriteConsoleA(  hOut, info.c_str(), info.length(), &num, NULL );
	}
	else
	{
		DWORD n = 0;
		TCHAR msg[] = L"err: unknown cmd.\r\n";
		WriteConsole( hOut, msg, sizeof(msg)/sizeof(TCHAR), &n, NULL );
	}
#endif
	return true;
}

bool NDGameApplication::PreLoadEffectSound(const char* pszFilesPath)
{
	if (0 == pszFilesPath || !*pszFilesPath)
	{
		return false;
	}

	return true;
}

NS_NDENGINE_END