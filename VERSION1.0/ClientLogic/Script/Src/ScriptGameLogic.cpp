/*
 *  ScriptGameLogic.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (����)DeNA. All rights reserved.
 *
 */

#include "ScriptGameLogic.h"
#include "ScriptInc.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "ItemMgr.h"
#include "Chat.h"
#include "NDMapMgr.h"
#include "ScriptGameData.h"
#include "ScriptGameData_New.h"
#include "NewChatScene.h"
#include "NDMapLayer.h"
#include "SMGameScene.h"
#include "SMLoginScene.h"
#include "WorldMapScene.h"
#include "NDBeforeGameMgr.h"
#include "BattleMgr.h"
#include "Battle.h"
#include "SqliteDBMgr.h"
#include "NDPath.h"
#include "SystemSetMgr.h"
#include "ItemImage.h"
#include "ScriptMgr.h"
#include "UsePointPls.h"
#include "../CocosDenshion/include/SimpleAudioEngine.h"
#include "DenaSdkLoginScene.h"


#ifdef USE_MGSDK
#import <Foundation/Foundation.h>
#include "MBGSocialService.h"
#include "MobageViewController.h"
#endif
#include "CCPlatformConfig.h"
#include "NDVideoMgr.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "jni/JniHelper.h"
#include "ScriptDataBase.h"

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <shellapi.h>
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace CocosDenshion;

//#include "CCVideoPlayer.h"

namespace NDEngine
{
	static bool gs_bIsMusic = true;
	static bool gs_bIsSound = true;

void PlayVideo(const char* videofilepath, bool bSkip)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	
#endif

	if (!videofilepath || !*videofilepath)
	{
		LOGERROR("videofilepath is null");
		return ;
	}

	VideoMgrPtr->PlayVideo("/sdcard/dhlj_dena/SimplifiedChineseRes/res/Video/480_0.mp4");

#if 0
	if(!videofilepath || 0 == strlen(videofilepath))
	{

		return;
	}

	string strPath = [[NSString alloc] initWithUTF8String: NDPath::GetSMVideoPath(videofilepath)];
	NDLog("%s", strPath.c_str());

	//** chh 2012-07-18 δ������� **//

	[CCVideoPlayer playMovieWithFile:path];
	if( bSkip == true )
	{
		[CCVideoPlayer setNoSkip:NO];
	}
	else
	{
		[CCVideoPlayer setNoSkip:YES];
	}
#endif

}

void SysChat(const char* text)
{
#if 0
	if(!text || 0 == strlen(text))
	{
		return;
	}

	Chat::DefaultChat()->AddMessage(ChatTypeSystem,text);
#endif
}

void QuitGame()
{
	quitGame();
}

void CreatePlayer(int lookface, int x, int y, int userid, std::string name)
{
	NDLog("CreatePlayer:%s", name.c_str());
	NDPlayer::pugeHero();
	NDPlayer& kPlayer = NDPlayer::defaultHero(lookface, true);
	kPlayer.InitRoleLookFace(lookface);

	kPlayer.stopMoving();
	kPlayer.SetPositionEx(ConvertUtil::convertCellToDisplay(x, y));
	kPlayer.SetServerPositon(x, y);
	kPlayer.m_nID = userid;
	kPlayer.SetName( name );
}
void ReloadPlayer(int lookface)
{
	NDLog("ReloadPlayer");
	NDPlayer& player = NDPlayer::defaultHero();
	player.ReLoadLookface(lookface);
}

//++Guosen 2012.7.13
//������Ҹ������״̬����������
void CreatePlayerWithMount(int lookface, int x, int y, int userid,
		std::string name, int nRideStatus, int nMountType)
{
	NDLog("CreatePlayer:%s", name.c_str());
	NDPlayer::pugeHero();
	NDPlayer& kPlayer = NDPlayer::defaultHero(lookface, true);
	kPlayer.ChangeModelWithMount(nRideStatus, nMountType);
	kPlayer.stopMoving();
	kPlayer.SetPositionEx(ConvertUtil::convertCellToDisplay(x, y));
	kPlayer.SetServerPositon(x, y);
	kPlayer.m_nID = userid;
	kPlayer.SetName( name );
}
//������
void PlayerRideMount(int nRideStatus, int nMountType)
{
	NDPlayer& kPlayer = NDPlayer::defaultHero();
	kPlayer.ChangeModelWithMount(nRideStatus, nMountType);
}

//++
//����ҳ-ϵͳ�Դ������
bool OpenURL(std::string strURL)
{
	if (0 == strURL.length())
	{
		return false;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return [ [UIApplication sharedApplication] openURL: [ NSURL URLWithString: [NSString stringWithUTF8String: strURL.c_str()] ] ];
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	ShellExecuteA(NULL,"open",strURL.c_str(),NULL,NULL,SW_SHOWNORMAL);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"openUrl",
		"(Ljava/lang/String;)I"))
	{
		LOGD("the t value is:env = %d,classID = %d,methodID = %d",(int)t.env,(int)t.classID,(int)t.methodID);

		jstring stringArg1;
		stringArg1 = t.env->NewStringUTF(strURL.c_str());

		jint retFromJava = (jint) t.env->CallStaticObjectMethod(t.classID,
			t.methodID, stringArg1);

		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(t.classID);
	}

#endif

	return true;
}
//++

//�������������ɫ
void SetPlayerNameColorByQuality(int nQuality)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.m_nQuality = nQuality;
}

void SetRidePet(int petLookface, int stand_action, int run_action, int acc)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.SetRidePet(petLookface, stand_action, run_action, acc);
}
void SetPlayerWeapon(int weapon_id)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.SetWeaponImage(weapon_id);
}
void SetPlayerAnimation(int nAnimationIndex)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.SetCurrentAnimation(nAnimationIndex, player.IsReverse());
}
void SetPlayerState(int nState)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.SetState(nState);
}

unsigned long GetPlayerId()
{
	return NDPlayer::defaultHero().m_nID;
}

void PlayerStopMove()
{
	NDPlayer::defaultHero().stopMoving();
}

bool RoleAddSMEffect(int nRoleId, std::string strEffectPath,
		int nSMEffectAlignment, int nDrawOrder)
{
	NDManualRole* role = NDMapMgrObj.GetManualRole(nRoleId);
	if (!role)
	{
		return false;
	}
	return role->AddSMEffect(strEffectPath, nSMEffectAlignment, nDrawOrder);
}
bool RoleRemoveSMEffect(int nRoleId, std::string strEffectPath)
{
	NDManualRole* pkRole = NDMapMgrObj.GetManualRole(nRoleId);
	if (!pkRole)
	{
		return false;
	}
	return pkRole->RemoveSMEffect(strEffectPath);
}
unsigned long GetMapId()
{
	return NDMapMgrObj.GetMotherMapID();
}
int GetMapInstanceId()
{
	int a = NDMapMgrObj.GetMapID();
	if (NDMapMgrObj.GetMapID() / 100000000 > 0)
	{
		return NDMapMgrObj.GetMotherMapID();
	}
}

int GetCurrentMonsterRound()
{
	return NDMapMgrObj.GetCurrentMonsterRound();
}

int GetPlayerLookface()
{
	return NDPlayer::defaultHero().GetLookface();
}
int GetPlayerPetLookface()
{
	return NDPlayer::defaultHero().GetPetLookface();
}
int GetPlayerPetStandAction()
{
	return NDPlayer::defaultHero().GetPetStandAction();
}
int GetPlayerPetWalkAction()
{
	return NDPlayer::defaultHero().GetPetWalkAction();
}

int GetItemCount(int nItemType)
{
	int count = 0;
	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
	for_vec(vec_item, VEC_ITEM_IT)
	{
		Item *item = (*it);
		if (item->m_nItemType == nItemType)
		{
			if (item->isEquip())
			{
				count++;
			}
			else
			{
				count += item->m_nAmount;
			}
		}
	}
	return count;
}

void NavigateTo(int nMapId, int nMapX, int nMapY)
{
	NDMapMgrObj.NavigateTo(nMapX, nMapY, nMapId);
}
void BackCity()
{
	int nMapId = NDMapMgrObj.GetMapID();
	NDMapMgrObj.WorldMapSwitch(nMapId);
}

void NavigateToNpc(int nNpcId)
{
	//	NDMapMgrObj.NavigateToNpc(nNpcId);
}

int GetCurrentTime()
{
	//return (int)([[NSDate date] timeIntervalSince1970] / 1000);
	return 1;
}

//��ע����Ҫ������ʱ������ָ�룡
//		��������ṩLUA���ã������Ҫһ��ָ�����ͣ�
//		��ʱ��Ϊstaticȷ�����ݣ�
std::string GetSMImgPath(const char* name) //@lua
{
	if (!name)
	{
		return "";
	}

	return NDPath::GetSMImgPath(name);
}

std::string GetSMImg00Path(const char* name) 
{
	if (!name)
	{
		return "";
	}

	return NDPath::GetSMImg00Path(name);
}

std::string GetImgResPath(const char* name) //@lua
{
	if (!name)
	{
		return "";
	}

	return NDPath::GetImgPath(name);
}
std::string GetAniResPath(const char* name) //@lua
{
	if (!name)
	{
		return "";
	}

	return NDPath::GetAniPath(name);
}

std::string GetSMResPath(const char* name) //@lua
{
	if (!name)
	{
		return "";
	}

	return NDPath::GetResPath(name);
}
NDPicture* GetItemPicture(int nIconIndex)
{
	//return ItemImage::GetSMItemNew(nIconIndex);
	return NULL;
}

NDMapLayer* GetMapLayer()
{
	NDScene* scene = NDDirector::DefaultDirector()->GetScene(
			RUNTIME_CLASS(CSMGameScene));
	if (!scene)
	{
		return NULL;
	}
	NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
	if (!layer)
	{
		return NULL;
	}

	return layer;
}

int GetSystemSetN(const char* key, int default_value)
{
	return SystemSetMgrObj.GetNumber(key, default_value);
}
bool GetSystemSetB(const char* key, bool default_value)
{
	return SystemSetMgrObj.GetBoolean(key, default_value);
}
const char* GetSystemSetS(const char* key, const char* default_value)
{
	return SystemSetMgrObj.GetString(key, default_value);
}
bool SetSystemSetN(const char* key, int value)
{
	return SystemSetMgrObj.Set(key, value);
}
bool SetSystemSetB(const char* key, bool value)
{
	return SystemSetMgrObj.Set(key, value);
}
bool SetSystemSetS(const char* key, const char* value)
{
	return SystemSetMgrObj.Set(key, value);
}
void ShowRoleName(bool isShow)
{
	NDMapMgrObj.setIsShowName(isShow);
}
void ShowOtherRole(bool isShow)
{
	NDMapMgrObj.setIsShowOther(isShow);
}
void restartLastBattle()
{
	BattleMgrObj.restartLastBattle();
}
void FinishBattle(void)
{
	BattleMgrObj.SetBattleOver();
}

void CloseBattle()
{
	BattleUILayer* battle = BattleMgrObj.GetBattle();
	if (battle)
	{
		battle->FinishBattle();
	}
}

void SetSceneMusicNew(int idMusic)
{
	LOGD("Entry SetSceneMusicNew,id is %d",idMusic);

	if (!gs_bIsMusic)
	{
		return;
	}

	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return;
	}
	
	string strMusicPath = NDPath::GetSoundPath();
	CCString* pstrMusicFile = CCString::stringWithFormat("%smusic_%d.ogg",
		strMusicPath.c_str(),idMusic);
	pkSimpleAudio->playBackgroundMusic(pstrMusicFile->getCString(),true);
}

void SetBgMusicVolume(int nVolune)
{
	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return;
	}

	float fVol = (float)nVolune / 100.0f;
	pkSimpleAudio->setBackgroundMusicVolume(fVol);
}

void SetEffectSoundVolune(int nVolune)
{
	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return;
	}

	float fVol = (float)nVolune / 100.0f;
	pkSimpleAudio->setEffectsVolume(fVol);
}

void StartBGMusic()
{
	gs_bIsMusic = true;

	int nTheID = NDMapMgrObj.GetMotherMapID();
	int nMusicID = ScriptDBObj.GetN("map",nTheID,DB_MAP_MUSIC);

	LOGD("Start the music,id is %d",nMusicID);

	SetSceneMusicNew(1);
}

void DisableBGMusic()
{
	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();
	gs_bIsMusic = false;

	if (0 == pkSimpleAudio)
	{
		return;
	}

	pkSimpleAudio->stopBackgroundMusic();
}

void StopBGMusic()
{
	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return;
	}

	pkSimpleAudio->stopBackgroundMusic();
}

int StartEffectSound(int idMusic)
{
	if (!gs_bIsSound)
	{
		return 2;
	}

	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return -1;
	}

	string strMusicPath = NDPath::GetSoundPath();
	CCString* pstrMusicFile = CCString::stringWithFormat("%seffect/effect_%d.aac",
		strMusicPath.c_str(),idMusic);
	return pkSimpleAudio->playEffect(pstrMusicFile->getCString(),false);
}

void ResumeAllEffectSound()
{
	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return;
	}

	pkSimpleAudio->resumeAllEffects();
	gs_bIsSound = true;
}

void StopEffectSound()
{
	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();
	gs_bIsSound = false;

	if (0 == pkSimpleAudio)
	{
		return;
	}

	pkSimpleAudio->pauseAllEffects();
}

void WorldMapGoto(int nMapId, LuaObject tFilter)
{
	NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();

	if (!pkScene)
	{
		return;
	}

	WorldMapLayer* pkWorldLayer = NULL;
	NDNode* pkNode = pkScene->GetChild(TAG_WORLD_MAP);
	if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(WorldMapLayer)))
	{
		pkWorldLayer = (WorldMapLayer*) pkNode;
	}
	else
	{
		pkWorldLayer = new WorldMapLayer;
		pkWorldLayer->Initialization(GetMapId());
		pkWorldLayer->SetTag(TAG_WORLD_MAP);
		pkScene->AddChild(pkWorldLayer);
	}

	if (tFilter.IsTable())
	{
		ID_VEC vId;
		int nTableCount = tFilter.GetTableCount();
		if (nTableCount > 0)
		{
			for (int i = 1; i <= nTableCount; i++)
			{
				LuaObject tag = tFilter[i];
				if (tag.IsInteger())
				{
					vId.push_back(tag.GetInteger());
				}
			}
		}
		pkWorldLayer->SetFilter(vId);
	}

	pkWorldLayer->Goto(nMapId);
}

void WorldMap(int nMapId, LuaObject tFilter)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene)
	{
		return;
	}

	WorldMapLayer* world = NULL;
	NDNode* node = scene->GetChild(TAG_WORLD_MAP);
	if (node && node->IsKindOfClass(RUNTIME_CLASS(WorldMapLayer)))
	{
		world = (WorldMapLayer*) node;
	}
	else
	{
		world = new WorldMapLayer;
		world->Initialization(GetMapId());
		scene->AddChild(world);
	}

	if (tFilter.IsTable())
	{
		ID_VEC vId;
		int nTableCount = tFilter.GetTableCount();
		if (nTableCount > 0)
		{
			for (int i = 1; i <= nTableCount; i++)
			{
				LuaObject tag = tFilter[i];
				if (tag.IsInteger())
				{
					vId.push_back(tag.GetInteger());
				}
			}
		}
		world->SetFilter(vId);
	}

	world->SetRoleAtPlace(nMapId);
}

bool SwichKeyToServer(const char* pszIp, int nPort, const char* pszAccountName,
		const char* pszPwd, const char* pszServerName)
{
	NDDataTransThread::DefaultThread()->Stop();
	NDDataTransThread::ResetDefaultThread();
	return NDBeforeGameMgrObj.SwichKeyToServer(pszIp, nPort, pszAccountName,
			pszPwd, pszServerName);
}
bool doNDSdkLogin()
{
	return NDBeforeGameMgrObj.doNDSdkLogin();

}
bool doNDSdkChangeLogin()
{
	return NDBeforeGameMgrObj.doNDSdkChangeLogin();

}

void HideMobageSplashScreen() //Guosen 2012.8.3
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	[[MBGPlatform sharedPlatform] hideSplashScreen];
#endif
}
void doGoToMobageVipPage()
{
#if 0
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	[MBGSocialService showBankUI:^
	{
	}];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/DaHuaLongJiang"
                                       , "ShowBankUi"
                                       , "()V"))
        
    {
        t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
#endif
}

void doShowMobageBalance()
{
#if 0
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	MobageViewController* pMobageView = [MobageViewController sharedViewController];
	[pMobageView showBalanceButton:CGRectMake(200, 70, 100, 36)];
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/DaHuaLongJiang"
                                       , "showBalanceButton"
                                       , "()V"))
        
    {
        t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
#endif
}

void doHideMobageBalance()
{
#if 0
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	MobageViewController* pMobageView = [MobageViewController sharedViewController];
	[pMobageView hideBalanceButton];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/DaHuaLongJiang"
                                       , "hideBalanceButton"
                                       , "()V"))
        
    {
        t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
#endif
}

void doExchangeEmoney(int nQuantity)
{	
#if 0
	CCLog("SEND_DATA1194 doExchangeEmoney");
	CCLog("SEND_DATA1194 doExchangeEmoney nQuantity = %d", nQuantity);
	int idAccount = NDBeforeGameMgrObj.GetCurrentUser();
	CCLog("SEND_DATA1194 doExchangeEmoney idAccount = %d", idAccount);
	//int iPayType = NDBeforeGameMgrObj.GetPayType();
	//CCLog("SEND_DATA1194 doExchangeEmoney iPayType = %d", iPayType);
	if(idAccount <= 0)
	{
		CCLog("SEND_DATA1194 idAccount <= 0 return");
       return;
	}
	if(!NDBeforeGameMgrObj.IsOAuthTokenOK())
	{
		CCLog("SEND_DATA1194 !NDBeforeGameMgrObj.IsOAuthTokenOK() return");
       return;
	}
	NDTransData bao(_MSG_CREATE_TRANSACTION);
	bao << idAccount;
	bao << nQuantity;
	//bao << iPayType;

	//CCLog("SEND_DATA1194 idAccount = %d, iPayType = %d", idAccount, iPayType);
	SEND_DATA(bao);
#endif
}

std::string Int2StrIP(int ip_Int)
{
	int num1 = ((ip_Int & 0xff000000) >> 24) & 0xff;
	int num2 = ((ip_Int & 0xff0000L) >> 16) & 0xff;
	int num3 = ((ip_Int & 0xff00L) >> 8) & 0xff;
	int num4 = (ip_Int & 0xff);
	tq::CString str;
	str.Format("%d.%d.%d.%d", num4, num3, num2, num1);

	return str;
}

void sendMsgConnect(const char* pszIp, int nPort, int idAccount)
{
	CCLog( "@@login6.1: sendMsgConnect(%s, %d, %d)", pszIp, nPort, idAccount);

	NDDataTransThread::DefaultThread()->Stop();
	NDDataTransThread::ResetDefaultThread();
	NDDataTransThread::DefaultThread()->Start(pszIp, nPort);
	if (NDDataTransThread::DefaultThread()->GetThreadStatus()
			!= ThreadStatusRunning)
	{
		return;
	}

	NDBeforeGameMgrObj.sendMsgConnect(idAccount);
}

void sendMsgCreateTempCredential()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	int idAccount = NDBeforeGameMgrObj.GetCurrentUser();
	//int iPayType = NDBeforeGameMgrObj.GetPayType();
	if(idAccount <= 0)
	{
 		return;
	}
	NDTransData data(_MSG_CREATE_TEMP_CREDENTIAL);

	data << idAccount;
  	//data << iPayType;
	//NDLog("SEND_DATA1190 idAccount = %d, iPayType = %d", idAccount, iPayType);

	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
#endif
}
///////////////////////////////////////////////
std::string SimpleDecode(const char* pszPwd)
{
#if 0
	unsigned char pszDest[1024] =
	{	0x00};
	simpleDecode((const unsigned char*)pszPwd, pszDest);
	return (char*)pszDest;
#endif
	return "";
}

///////////////////////////////////////////////
std::string GetDeviceToken()
{
	return NDBeforeGameMgrObj.GetDeviceToken();
}

///////////////////////////////////////////////
//��ʼ����
bool StartUpdate()
{
#if 0
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
		return pScene->StartUpdate();
	}
#endif
	return false;
}
//��ʼ��������ַ����
void InitUpdateURLQueue(const char* pszUrl)
{
#if 0
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
		std::string szURL = pszUrl;
		return pScene->InitDownload( szURL );
	}
#endif
}
///////////////////////////////////////////////
//���ͻ��˰汾
bool CheckClientVersion(const char* szURL)
{
	//CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	//if(pScene){
	//    return pScene->CheckClientVersion();
	//}
	return false;
	// return NDBeforeGameMgrObj.CheckClientVersion( szURL );
}
///////////////////////////////////////////////
//void SetRole(unsigned long ulLookFace, const char* pszRoleName, int nProfession)
//{
//    NDBeforeGameMgrObj.SetRole(ulLookFace, pszRoleName, nProfession);
//}

///////////////////////////////////////////////
bool LoginByLastData(void)
{
	//return NDBeforeGameMgrObj.LoginByLastData();
	return 1;
}

//////////////////////////////////////////////
int GetAccountListNum(void)
{
	// return NDBeforeGameMgrObj.GetAccountListNum();
	return 1;
}

//////////////////////////////////////////////
const char* GetRecAccountNameByIdx(int idx) //@lua
{
	//return NDBeforeGameMgrObj.GetRecAccountNameByIdx(idx);
	return "";
}

//////////////////////////////////////////////
const char* GetRecAccountPwdByIdx(int idx) //@lua @bug
{
	return NDBeforeGameMgrObj.GetRecAccountPwdByIdx(idx);
}

void CreateRole(const char* pszName, Byte nProfession, int nLookFace,
		const char* pszAccountName)
{
	return NDBeforeGameMgrObj.CreateRole(pszName, nProfession, nLookFace,
			pszAccountName);
}

bool DownLoadServerListToDB(const char* pszIP, int nPort)
{
	//return NDBeforeGameMgrObj.DownLoadServerListToDB(pszIP, nPort);
	return false;
}
void SaveAccountPwdToDB(const char* pszName, const char* pszPwd)
{
	//return NDBeforeGameMgrObj.SaveAccountPwdToDB(pszName,pszPwd,0);
}
void RegisterAccount(const char* pszAccount, const char* pszPwd)
{
	//return NDBeforeGameMgrObj.RegisterAccout(pszAccount, pszPwd);
}

int GetVersion(void)
{
	return 1; //CSMUpdate::sharedInstance().GetVersion(NDPath::GetResourcePath().c_str());
}
void LoadLoginScene(void)
{
	//NDDirector::DefaultDirector()->ReplaceScene(CSMLoginScene::Scene());
}

void PauseScene(void)
{
	//NDDirector::DefaultDirector()->ReplaceScene(CSMLoginScene::Scene());
	//NDDirector::DefaultDirector()->Pause();
}

int ConvertReset(int nNum, int nMapId)
{
	int numG = (nNum & (int) pow(2.0, 2.0 * (nMapId - 1))) >> (2 * nMapId - 2);
	int numS = (nNum & (int) pow(2.0, 2.0 * nMapId - 1)) >> (2 * nMapId - 2);
	return numS * 2 + numG;
}


bool StartNetWork(const char* pszIp, int nPort)
{
	NDDataTransThread::DefaultThread()->Stop();
	NDDataTransThread::ResetDefaultThread();
	NDDataTransThread::DefaultThread()->Start(pszIp, nPort);
	if (NDDataTransThread::DefaultThread()->GetThreadStatus()
		!= ThreadStatusRunning)
	{
		return false;
	}
	return true;
}

void SendMsgLoginAccount(const char* pszIp, int nPort, const char* pszAccount, const char* pszPassWord, int iAccountLen, int iPassWordLen, int iMsgID)
{
	if (!StartNetWork(pszIp, nPort))
	{
		return;
	}

	NDTransData data(iMsgID);
	data.Write((const unsigned char*)pszAccount, iAccountLen);
	data.Write((const unsigned char*)pszPassWord, iPassWordLen);

	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
}

void SendMsgRegisterAccount(const char* pszIp, int nPort, const char* pszAccount, const char* pszPassWord, int iAccountLen, int iPassWordLen, int iMsgID)
{
	if (!StartNetWork(pszIp, nPort))
	{
		return;
	}

	NDTransData data(iMsgID);
	data.Write((const unsigned char*)pszAccount, iAccountLen);
	data.Write((const unsigned char*)pszPassWord, iPassWordLen);
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
}

void SendMsgChangePassWord(const char* pszIp, int nPort, const char* pszAccount, 
						   const char* pszOldPassWord, const char* pszNewPassWord, 
						   int iAccountLen, int iPassWordLen, int iMsgID)
{
	if (!StartNetWork(pszIp, nPort))
	{
		return;
	}

	NDTransData data(iMsgID);
	data.Write((const unsigned char*)pszAccount, iAccountLen);
	data.Write((const unsigned char*)pszOldPassWord, iPassWordLen);
	data.Write((const unsigned char*)pszNewPassWord, iPassWordLen);

	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
}


void SendHttpLoginMsg(const char* pszReqData)
{
	CDenaSdkLoginSceneObj.SendHttpRequest(pszReqData);
}

///////////////////////////////////////////////
void ScriptGameLogicLoad()
{
	ETCFUNC("PlayVideo", PlayVideo);
	ETCFUNC("SysChat", SysChat);
	ETCFUNC("QuitGame", QuitGame);
	ETCFUNC("CreatePlayer", CreatePlayer);
	ETCFUNC("SetPlayerWeapon", SetPlayerWeapon);
	ETCFUNC("SetPlayerAnimation", SetPlayerAnimation);
	ETCFUNC("SetPlayerState", SetPlayerState);
	ETCFUNC("ReloadPlayer", ReloadPlayer);
	ETCFUNC("CreatePlayerWithMount", CreatePlayerWithMount);
	ETCFUNC("PlayerRideMount", PlayerRideMount);
	ETCFUNC("OpenURL", OpenURL);
	ETCFUNC("SetPlayerNameColorByQuality", SetPlayerNameColorByQuality);
	ETCFUNC("PlayerStopMove", PlayerStopMove);
	//ETCFUNC("GetImgPathNew", NDPath::GetImgPathNew);
	ETCFUNC("GetPlayerId", GetPlayerId);
	ETCFUNC("NavigateTo", NavigateTo);
	ETCFUNC("NavigateToNpc", NavigateToNpc);
	ETCFUNC("GetMapId", GetMapId);
	ETCFUNC("GetMapInstanceId", GetMapInstanceId);
	ETCFUNC("GetCurrentMonsterRound", GetCurrentMonsterRound);
	ETCFUNC("GetImgResPath", GetImgResPath);
	ETCFUNC("GetAniResPath", GetAniResPath);
	ETCFUNC("GetSMImgPath", GetSMImgPath);
	ETCFUNC("GetSMImg00Path", GetSMImg00Path);
	ETCFUNC("GetSMResPath", GetSMResPath);
	ETCFUNC("GetMapLayer", GetMapLayer);
	ETCFUNC("restartLastBattle", restartLastBattle);
	ETCFUNC("FinishBattle", FinishBattle);
	ETCFUNC("GetPlayerLookface", GetPlayerLookface);
	ETCFUNC("GetPlayerPetLookface", GetPlayerPetLookface);
	ETCFUNC("GetPlayerPetStandAction", GetPlayerPetStandAction);
	ETCFUNC("GetPlayerPetWalkAction", GetPlayerPetWalkAction);
	ETCFUNC("WorldMapGoto", WorldMapGoto);
	//WorldMap ��ʾ�����ͼ
	ETCFUNC("WorldMap", WorldMap);
	ETCFUNC("BackCity", BackCity);
	//ETCFUNC("GetRandomWords", &CSMLoginScene::GetRandomWords);
	ETCFUNC("CloseBattle", CloseBattle);
	//ETCFUNC("GetCurrentTime",GetCurrentTime);
	//ETCFUNC("WorldMapSwitch", WorldMapSwitch);
	/*��½����*/
	//ETCFUNC("FastRegister", FastRegister);
	//ETCFUNC("GetFastAccount", GetFastAccount);
	//ETCFUNC("GetFastPwd", GetFastPwd);
	ETCFUNC("SwichKeyToServer", SwichKeyToServer);
	ETCFUNC("doNDSdkLogin", doNDSdkLogin);

	//** chh 2012-07-24 **//
	ETCFUNC("doNDSdkChangeLogin", doNDSdkChangeLogin);
	ETCFUNC("HideMobageSplashScreen", HideMobageSplashScreen);
	ETCFUNC("doGoToMobageVipPage", doGoToMobageVipPage);
	ETCFUNC("doShowMobageBalance", doShowMobageBalance);
	ETCFUNC("doHideMobageBalance", doHideMobageBalance);
	ETCFUNC("doExchangeEmoney", doExchangeEmoney);

	ETCFUNC("Int2StrIP", Int2StrIP);
	ETCFUNC("sendMsgConnect", sendMsgConnect);
	ETCFUNC("sendMsgCreateTempCredential", sendMsgCreateTempCredential);
	ETCFUNC("SaveAccountPwdToDB", SaveAccountPwdToDB);
	ETCFUNC("GetVersion", GetVersion);
	//ETCFUNC("SetRole", SetRole);
	ETCFUNC("LoginByLastData", LoginByLastData);
	ETCFUNC("DownLoadServerListToDB", DownLoadServerListToDB);
	ETCFUNC("LoadLoginScene", LoadLoginScene);
	ETCFUNC("GetAccountListNum", GetAccountListNum);
	ETCFUNC("GetRecAccountNameByIdx", GetRecAccountNameByIdx);
	ETCFUNC("GetRecAccountPwdByIdx", GetRecAccountPwdByIdx);
	ETCFUNC("loadPackInfo", loadPackInfo);
	ETCFUNC("CheckClientVersion", CheckClientVersion);
	ETCFUNC("StartUpdate", StartUpdate);
	ETCFUNC("InitUpdateURLQueue", InitUpdateURLQueue);
	ETCFUNC("RegisterAccount", RegisterAccount);
	ETCFUNC("SetSceneMusicNew", SetSceneMusicNew);
	ETCFUNC("SimpleDecode", SimpleDecode);
	ETCFUNC("GetDeviceToken", GetDeviceToken);
	ETCFUNC("SetRidePet", SetRidePet);
	ETCFUNC("StartBGMusic", StartBGMusic);
	ETCFUNC("DisableBGMusic",DisableBGMusic);
	ETCFUNC("StopBGMusic", StopBGMusic);
	ETCFUNC("StartEffectSound", StartEffectSound);
	ETCFUNC("StopEffectSound", StopEffectSound);
	ETCFUNC("ResumeAllEffectSound",ResumeAllEffectSound);
	ETCFUNC("SetBgMusicVolume", SetBgMusicVolume);
	ETCFUNC("SetEffectSoundVolune", SetEffectSoundVolune);
	ETCFUNC("ShowRoleName", ShowRoleName);
	ETCFUNC("ShowOtherRole", ShowOtherRole);
	ETCFUNC("GetSystemSetN", GetSystemSetN);
	ETCFUNC("GetSystemSetB", GetSystemSetB);
	ETCFUNC("GetSystemSetS", GetSystemSetS);
	ETCFUNC("SetSystemSetN", SetSystemSetN);
	ETCFUNC("SetSystemSetB", SetSystemSetB);
	ETCFUNC("SetSystemSetS", SetSystemSetS);
	ETCFUNC("GetItemPicture", GetItemPicture);

	ETCFUNC("ConvertReset", ConvertReset);
	ETCFUNC("getStringSize", getStringSize);
	//SELF SDK ����
	ETCFUNC("SendMsgLoginAccount", SendMsgLoginAccount);		//��������	 
	ETCFUNC("SendMsgRegisterAccount", SendMsgRegisterAccount);  //ע������	 
	ETCFUNC("SendMsgChangePassWord", SendMsgChangePassWord);   //�޸���������	

	ETCFUNC("SendHttpLoginMsg", SendHttpLoginMsg);		//http��ʽ��������	 		
}

}
