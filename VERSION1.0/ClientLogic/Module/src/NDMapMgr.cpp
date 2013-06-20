
#include "NDMapMgr.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "NDMapLayer.h"
#include "GameScene.h"
#include "NDItemType.h"
#include "Battle.h"
#include "define.h"
#include "NDUISynLayer.h"
#include "SMGameScene.h"
#include "ItemMgr.h"
#include "ScriptGlobalEvent.h"
#include "NDNetMsg.h"
#include "TutorUILayer.h"
#include "ScriptMgr.h"
#include "TaskListener.h"
#include "BattleMgr.h"
#include "CPet.h"
#include "NDMsgDefine.h"
#include "NDUtility.h"
//#include "BeatHeart.h"
#include "NDDataPersist.h"
// #include "Chat.h"
#include "SMLoginScene.h"
#include "GlobalDialog.h"
#include "NDMonster.h"
#include "NDSocket.h"
#include "AutoPathTip.h"
#include "NDDataTransThread.h"
#include "GameSceneLoading.h"
#include "NDBeforeGameMgr.h"
#include "ScriptGameLogic.h"
#include "SocialElement.h"
#include "NDTransData.h"
#include "ObjectTracker.h"
#include "StringConvert.h"

#ifdef USE_MGSDK
#import <Foundation/Foundation.h>
#import  "MBGPlatform.h"
#import  "MBGBankDebit.h"
#include "MobageViewController.h"
#endif

#if defined(ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#endif
#include "../CocosDenshion/include/SimpleAudioEngine.h"

using namespace CocosDenshion;

NS_NDENGINE_BGN

#define TAG_TIMER_KICK_OUT_TIP (1021) 

const char* pszChannelID = "IPHONE_BYWX";

enum
{
	TEXT_TEXT = 1,
};

int SHENGWANGMAX[7] =
{ 5000, 1500, 500, 100, -100, -500, -1500 };
int discount[7] =
{ 70, 80, 90, 95, 100, 110, 120 };

IMPLEMENT_CLASS(NDMapMgr, NDObject);

bool NDMapMgr::m_bVerifyVersion = true;
bool NDMapMgr::m_bFirstCreate = false;

int getShengWangLevel(int v)
{
	int result = 7;
	for (int i = 0; i < 7; i++)
	{
		if (v > SHENGWANGMAX[i])
		{
			result = i;
			break;
		}
	}
	return result;
}

int getDiscount(int v)
{
	return discount[getShengWangLevel(v)];
}

bool GetIntData(int& t, string strValue, string strType)
{
	int nPos = strValue.find(strType);

	if (-1 == nPos || strValue.length() < strType.length())
	{
		return false;
	}

	string strNumber = strValue.substr(strType.length() + 1, strValue.length());

	t = (int) atoi(strNumber.c_str());

	return true;
}

bool GetShortData(short& t, string strValue, string strType)
{
	int nPos = strValue.find(strType);

	if (-1 == nPos || strValue.length() < strType.length())
	{
		return false;
	}

	string strNumber = strValue.substr(strType.length() + 1, strValue.length());

	t = (short) atoi(strNumber.c_str());

	return true;
}

bool GetCharData(char& t, string strValue, string strType)
{
	int nPos = strValue.find(strType);

	if (-1 == nPos || strValue.length() < strType.length())
	{
		return false;
	}

	string strNumber = strValue.substr(strType.length() + 1, strValue.length());

	t = (char) atoi(strNumber.c_str());

	return true;
}

NDMapMgr::NDMapMgr() :
	m_nCurrentMonsterBound(0),
	m_nRoadBlockX(0),
	m_nRoadBlockY(0),
	m_nSaveMapID(0),
	m_nMapID(0),
	m_nMapDocID(0),
	m_nCurrentMonsterRound(0)
{
	INC_NDOBJ_RTCLS

	m_iCurDlgNpcID = 0;
	mapType = MAPTYPE_NORMAL;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	NDConsole::instance().RegisterConsoleHandler(this, "sim ");
#endif

	m_kTimer.SetTimer(this, 1, 0.1);
	memset(m_nCampType, 0, sizeof(int) * CAMP_TYPE_END);
	m_bIsShowName = true;
	m_bIsShowOther = true;

	RegisProcessMsg();
}

NDMapMgr::~NDMapMgr()
{
	DEC_NDOBJ_RTCLS
	m_vNPC.clear();
	m_mapManualRole.clear();
}

void NDMapMgr::RegisProcessMsg()
{
	NDNetMsgPool* pool = NDNetMsgPoolObj;
	pool->RegMsg(_MSG_NPCINFO_LIST, this);
	pool->RegMsg(_MSG_ROOM, this);

	pool->RegMsg(_MSG_USERINFO, this);
	pool->RegMsg(_MSG_USERATTRIB, this);
	pool->RegMsg(_MSG_PLAYER, this);
	pool->RegMsg(_MSG_PLAYER_EXT, this);
	pool->RegMsg(_MSG_NPC_STATUS, this);
	pool->RegMsg(_MSG_MONSTER_INFO_LIST, this);
	pool->RegMsg(MB_MSG_DISAPPEAR, this);
	pool->RegMsg(_MSG_WALK, this);
	pool->RegMsg(_MSG_KICK_BACK, this);
	pool->RegMsg(_MSG_CHGPOINT, this);
	pool->RegMsg(_MSG_PETINFO, this);
	pool->RegMsg(_MSG_DIALOG, this);
	pool->RegMsg(_MSG_LIFESKILL, this);
	pool->RegMsg(_MSG_SYNTHESIZE, this);
	pool->RegMsg(_MSG_COLLECTION, this);
	pool->RegMsg(_MSG_LOGIN_SUC,this);
	pool->RegMsg(_MSG_CREATE_TEMP_CREDENTIAL_RET,this);
	pool->RegMsg(_MSG_REQUEST_ACCESS_TOKEN_RET,this);
	pool->RegMsg(_MSG_CREATE_TRANSACTION_RET,this);
	pool->RegMsg(_MSG_CLOSE_TRANSACTION_RET,this);
	pool->RegMsg(_MSG_REHEARSE, this);
	pool->RegMsg(_MSG_TEAM, this);
	pool->RegMsg(_MSG_GOODFRIEND, this);
	pool->RegMsg(_MSG_GAME_QUIT, this);
	pool->RegMsg(_MSG_TASKINFO, this);
	pool->RegMsg(_MSG_DOING_TASK_LIST, this);
	pool->RegMsg(_MSG_QUERY_TASK_LIST, this);
	pool->RegMsg(_MSG_TASK_ITEM_OPT, this);
	pool->RegMsg(_MSG_QUERY_TASK_LIST_EX, this);
	pool->RegMsg(_MSG_NPCINFO, this);
	pool->RegMsg(_MSG_TRADE, this);
	pool->RegMsg(_MSG_BILLBOARD, this);
	pool->RegMsg(_MSG_BILLBOARD_FIELD, this);
	pool->RegMsg(_MSG_BILLBOARD_LIST, this);
	pool->RegMsg(_MSG_BILLBOARD_USER, this);
	pool->RegMsg(_MSG_SHOPINFO, this);
	pool->RegMsg(_MSG_SHOP, this);
	pool->RegMsg(_MSG_REG_TUTOR_INFO, this);  
	pool->RegMsg(_MSG_TUTOR_INFO, this);
	pool->RegMsg(_MSG_USER_POS, this);
	pool->RegMsg(_MSG_CHG_MAP_FAIL, this);
	pool->RegMsg(_MSG_TUTOR, this);
	pool->RegMsg(_MSG_USERINFO_SEE, this); 
	pool->RegMsg(_MSG_EQUIP_INFO, this); 
	pool->RegMsg(_MSG_USER_STATE, this);
	pool->RegMsg(_MSG_USER_STATE_CHG, this);
	pool->RegMsg(_MSG_POS_TEXT, this);
	pool->RegMsg(_MSG_EQUIPIMPROVE, this);
	pool->RegMsg(_MSG_FORMULA, this); 
	pool->RegMsg(_MSG_BOOTH, this);
	pool->RegMsg(_MSG_BOOTH_GOODS, this);
	pool->RegMsg(_MSG_MAGIC_GOODS, this);
	pool->RegMsg(_MSG_SKILL, this);
	pool->RegMsg(_MSG_PET_SKILL, this);
	pool->RegMsg(_MSG_MBR_LIST, this);
	pool->RegMsg(_MSG_APPLY_LIST, this);
	pool->RegMsg(_MSG_SYN_ANNOUNCE, this);
	pool->RegMsg(_MSG_SYN_INFO, this);
	pool->RegMsg(_MSG_QUERY_REG_SYN_LIST, this);
	pool->RegMsg(_MSG_SYNDICATE, this);
	pool->RegMsg(_MSG_SYN_LIST, this);
	pool->RegMsg(_MSG_INVITE_LIST, this);
	pool->RegMsg(_MSG_INVITE_LIST_EX, this);
	pool->RegMsg(_MSG_SYN_INVITE, this);
	pool->RegMsg(_MSG_SYN_LIST_EX, this);
	pool->RegMsg(_MSG_LETTER, this);
	pool->RegMsg(_MSG_LETTER_INFO, this);
	pool->RegMsg(_MSG_LETTER_REQUEST, this);
	pool->RegMsg(_MSG_AUCTION, this);
	pool->RegMsg(_MSG_AUCTIONINFO, this);
	pool->RegMsg(_MSG_DIGOUT, this);
	pool->RegMsg(_MSG_CUSTOMER_SERVICE, this);
	pool->RegMsg(_MSG_SYSTEM_DIALOG, this);
	pool->RegMsg(MB_MSG_CHANGE_PASS, this);
	pool->RegMsg(_MSG_NAME, this);
	pool->RegMsg(_MSG_PLAYERLEVELUP, this);
	pool->RegMsg(_MSG_NPC, this);
	pool->RegMsg(_MSG_SEE, this);
	pool->RegMsg(_MSG_REPUTE_ATTR, this);
	pool->RegMsg(_MSG_CAMP_STORAGE, this);
	pool->RegMsg(_MSG_NPC_POSITION, this);
	pool->RegMsg(_MSG_NPC_TALK, this);
	pool->RegMsg(_MSG_ITEM_TYPE_INFO, this);
	pool->RegMsg(_MSG_COMPETITION, this);
	pool->RegMsg(_MSG_WISH, this);
	pool->RegMsg(_MSG_TIP, this);
	pool->RegMsg(_MSG_WALK_TO, this);
	pool->RegMsg(_MSG_REPUTE, this);
	pool->RegMsg(_MSG_COMMON_LIST, this);
	pool->RegMsg(_MSG_COMMON_LIST_RECORD, this);
	pool->RegMsg(_MSG_LIGHT_EFFECT, this);
	pool->RegMsg(_MSG_CHG_PET_POINT, this);
	pool->RegMsg(MB_MSG_RECHARGE, this); 
	pool->RegMsg(MB_MSG_RECHARGE_RETURN, this); 
	pool->RegMsg(_MSG_CLIENT_VERSION, this);
	pool->RegMsg(_MSG_ACTIVITY, this);
	pool->RegMsg(_MSG_DELETEROLE, this);
	//pool->RegMsg(_MSG_PORTAL, this);
	pool->RegMsg(_MSG_QUERY_SOCIAL_INFO, this);
	pool->RegMsg(MB_MSG_MOBILE_PWD, this);
	pool->RegMsg(_MSG_MARRIAGE, this);
	//pool->RegMsg(_MSG_RESPOND_TREASURE_HUNT_INFO, this);
	//pool->RegMsg(_MSG_RESPOND_TREASURE_HUNT_PR0B, this);
	pool->RegMsg(_MSG_SHOW_TREASURE_HUNT_AWARD, this);
	pool->RegMsg(_MSG_KICK_OUT_TIP, this);
	pool->RegMsg(_MSG_CHARGE_GIFT_INFO, this);
	pool->RegMsg(_MSG_QUERY_PETCKILL, this);
	pool->RegMsg(_MSG_ROADBLOCK,this);

}

bool NDMapMgr::process(MSGID usMsgID, NDEngine::NDTransData* pkData,
		int nLength)
{
	switch (usMsgID)
	{
		case _MSG_ROADBLOCK:
		{
			processRoadBlock(*pkData);
		}
			break;
		case _MSG_QUERY_PETCKILL:
		{
			processQueryPetSkill(*pkData);
		}
			break;
		case _MSG_CHARGE_GIFT_INFO:
		{
			//RechargeUI::ProcessGiftInfo(*kData); ///< ���������ڵ� NewRecharge ����
		}
			break;
		case _MSG_KICK_OUT_TIP:
		{
			processKickOutTip(*pkData);
		}
			break;
		case 3003: //_MSG_RESPOND_TREASURE_HUNT_PR0B: �˺��Ҳ���������������
		{
			processRespondTreasureHuntProb(*pkData);
		}
			break;
		case 3005: //_MSG_RESPOND_TREASURE_HUNT_INFO:	�˺��Ҳ���������������
		{
			processRespondTreasureHuntInfo(*pkData);
		}
			break;
		case _MSG_SHOW_TREASURE_HUNT_AWARD:
		{
			processShowTreasureHuntAward(*pkData);
		}
			break;
		case _MSG_MARRIAGE:
		{
			processMarriage(*pkData);
		}
			break;
		case 2562:	///< Ϊʲô_MSG_PORTAL�Ҳ���
		{
			processPortal(*pkData);
		}
			break;
		case _MSG_DELETEROLE:
		{
			processDeleteRole(*pkData);
		}
			break;
		case _MSG_ACTIVITY:
		{
			processActivity(*pkData);
		}
			break;
		case _MSG_CLIENT_VERSION:
		{
			processVersionMsg(*pkData);
		}
			break;
		case MB_MSG_RECHARGE_RETURN:
		{
			processRechargeReturn(*pkData);
		}
			break;
		case MB_MSG_CHANGE_PASS:
		{
			CloseProgressBar;
			GlobalShowDlg(NDCommonCString("SysTip"), pkData->ReadUnicodeString());
		}
			break;
		case _MSG_SEE:
		{
			processSee(*pkData);
		}
			break;
		case _MSG_SYSTEM_DIALOG:
		{
			m_strNoteTitle = pkData->ReadUnicodeString();
			m_strNoteContent = pkData->ReadUnicodeString();
			GlobalDialogObj.Show(NULL, m_strNoteTitle.c_str(),
					m_strNoteContent.c_str(), NULL, NULL);
		}
			break;
		case _MSG_TALK:
		{
			processTalk(*pkData);
		}
			break;
		case _MSG_GAME_QUIT:
		{
			processGameQuit(pkData, nLength);
		}
			break;
		case MB_MSG_RECHARGE:
		{
			processReCharge(*pkData);
		}
			break;
		case _MSG_PLAYERLEVELUP:
		{
			processPlayerLevelUp(*pkData);
		}
			break;
		case _MSG_COLLECTION:
		{
			processCollection(*pkData);
		}
			break;
		case _MSG_AUCTION:
		{
			///< �����ŵ� AuctionUILayer ����
			//AuctionUILayer::processAuction(*kData);
		}
			break;
		case _MSG_AUCTIONINFO:
		{
			///< �����ŵ� AuctionUILayer ����
			//AuctionUILayer::processAuctionInfo(*pkData);
		}
			break;
		case _MSG_PETINFO:
		{
			processPetInfo(pkData, nLength);
		}
			break;
		case _MSG_COMPETITION:
		{
			processCompetition(*pkData);
		}
			break;
		case _MSG_KICK_BACK:
		{
			processKickBack(pkData, nLength);
		}
			break;
		case MB_MSG_DISAPPEAR:
		{
			processDisappear(pkData, nLength);
		}
			break;
		case _MSG_CHGPOINT:
		{
			processChgPoint(pkData, nLength);
		}
			break;
		case _MSG_REPUTE:
		{
			NDPlayer& kRole = NDPlayer::defaultHero();
			kRole.m_nSWCountry = pkData->ReadInt();
			kRole.m_nSWCamp = pkData->ReadInt();
			kRole.m_nHonour = pkData->ReadInt();
			kRole.m_nExpendHonour = pkData->ReadInt();
			kRole.m_strRank = pkData->ReadUnicodeString();

			updateTaskRepData(kRole.m_nSWCamp, false);
			updateTaskHrData(kRole.m_nHonour, false);
		}
			break;
		case _MSG_NPC_STATUS:
		{
			processNpcStatus(pkData, nLength);
		}
			break;
		case _MSG_MONSTER_INFO_LIST:
		{
			processMonsterInfo(pkData, nLength);
		}
			break;
		case _MSG_COMMON_LIST:
		{
			processMsgCommonList(*pkData);
		}
			break;
		case _MSG_COMMON_LIST_RECORD:
		{
			processMsgCommonListRecord(*pkData);
		}
			break;
		case _MSG_CHG_PET_POINT:
		{
			int nBtAnswer = pkData->ReadByte();
		}
			break;
		case _MSG_PLAYER:
		{
			processPlayer(pkData, nLength);
		}
			break;
		case _MSG_LOGIN_SUC:
		{
			ProcessLoginSuc(*pkData);
		}
			break;
		case _MSG_PLAYER_EXT:
		{
			processPlayerExt(pkData, nLength);
		}
			break;
		case _MSG_ITEM_TYPE_INFO:
		{
			processItemTypeInfo(*pkData);
		}
			break;
		case _MSG_NPC_TALK:
		{
			processNpcTalk(*pkData);
		}
			break;
		case _MSG_WALK_TO:
		{
			processWalkTo(*pkData);
		}
			break;
		case _MSG_NPCINFO_LIST:
		{
			processNPCInfoList(pkData, nLength);
		}
			break;
		case _MSG_ROOM:
		{
			processChangeRoom(pkData, nLength);
		}
			break;
		case _MSG_WALK:
		{
			processWalk(pkData, nLength);
		}
			break;
		case _MSG_TASKINFO:
		case _MSG_DOING_TASK_LIST:
		case _MSG_QUERY_TASK_LIST:
		case _MSG_TASK_ITEM_OPT:
		case _MSG_QUERY_TASK_LIST_EX:
		{
			processTask(usMsgID, pkData);
		}
			break;
		case _MSG_NPCINFO:
		{
			processNPCInfo(*pkData);
		}
			break;
		case _MSG_REHEARSE:
		{
			processRehearse(*pkData);
		}
			break;
		case _MSG_GOODFRIEND:
		{
			processGoodFriend(*pkData);
		}
			break;
		case _MSG_TUTOR:
		{
			///< �����ŵϵ�TutorUILayer ����
			//TutorUILayer::processMsgTutor(*kData);
		}
			break;
		case _MSG_REG_TUTOR_INFO:
		{
			///< �����ŵϵ�MasterUILayer ����
			//MasterUILayer::refreshScroll(*kData);
		}
			break;
		case _MSG_TUTOR_INFO:
		{
			///< �����ŵϵ�TutorUILayer ����
			//TutorUILayer::processTutorList(*kData);
		}
			break;
		case _MSG_USER_POS:
		{
			///< �����ŵϵ�TutorUILayer ����
			//TutorUILayer::processUserPos(*kData);
		}
			break;
//		case _MSG_CHG_MAP_FAIL:
//		{
//			NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();
//
//			if (pkScene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading))) 
//	 		{
//	 			NDDirector::DefaultDirector()->PopScene();
//	 		}
//		}
//			break;
		case _MSG_USERINFO_SEE:
		{
			processUserInfoSee(*pkData);
		}
			break;
		case _MSG_POS_TEXT:
		{
			GameScene* pkGameScene = GameScene::GetCurGameScene();

			if (pkGameScene)
			{
				pkGameScene->processMsgPosText(*pkData);
			}
		}
			break;
		case _MSG_FORMULA:
		{
			processFormula(*pkData);
		}
			break;
		case _MSG_BOOTH:
		{
			//VendorUILayer::processMsgBooth(*kData);	///< �����ŵϵ�VendorUILayer ����
		}
			break;
		case _MSG_BOOTH_GOODS:
		{
			//VendorBuyUILayer::Show(*kData);		///< �����ŵϵ�VendorBuyUILayer ����
		}
			break;
		case _MSG_QUERY_REG_SYN_LIST:
		{
			//SyndicateRegListUILayer::refreshScroll(*kData); ///< �����֪����˭�� ����
		}
			break;
		case _MSG_SYNDICATE:
		{
			processSyndicate(*pkData);
		}
			break;
		case _MSG_SYN_INFO:
		{
			int nRank = pkData->ReadByte(); // �����ڰ����е�ְλ
			string strSynName = pkData->ReadUnicodeString(); // ��������
			NDPlayer& kRole = NDPlayer::defaultHero();
			kRole.setSynRank(nRank);
			kRole.m_strSynName = (strSynName);
			break;
		}
			break;
		case _MSG_SYN_ANNOUNCE:
		{
			/***
			 * �����ŵϵ�SynInfoUILayer
			 * ����
			 */
			//SynInfoUILayer* synInfo = SynInfoUILayer::GetCurInstance();
			//if (synInfo) {
			//	synInfo->processSynBraodcast(*kData);
			//}
		}
			break;
		case _MSG_APPLY_LIST:
		{
			/***
			 * �����ŵϵ� SynApproveUILayer
			 * ����
			 */
			//SynApproveUILayer* approve = SynApproveUILayer::GetCurInstance();
			//if (approve) {
			//	approve->processApproveList(*kData);
			//}
		}
			break;
		case _MSG_DIGOUT:
		{
			processDigout(*pkData);
		}
			break;
		case _MSG_MBR_LIST:
		{
			/***
			 * �����ŵϵ� SynMbrListUILayer
			 * ����
			 */
			//SynMbrListUILayer* mbrList = SynMbrListUILayer::GetCurInstance();
			//if (mbrList) {
			//	mbrList->processMbrList(*kData);
			//}
		}
			break;
//		case _MSG_TIP:
//		{
// 			NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();
// 			if (pkScene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading))) 
// 			{
// 				GameSceneLoading* pkGameSceneLoading = (GameSceneLoading*)pkScene;
// 				pkGameSceneLoading->UpdateTitle(pkData->ReadUnicodeString());
// 			}
//		}
//			break;
		case _MSG_NAME:
		{
			//showDialog(NDCommonCString("tip"), NDCommonCString("RenameSucc")); ///< ����showDialog ����
		}
			break;
		case _MSG_NPC_POSITION:
		{
			processNpcPosition(*pkData);
		}
			break;
		case _MSG_NPC:
		{
			processNPC(*pkData);
		}
			break;
        case _MSG_CREATE_TEMP_CREDENTIAL_RET:
            this->ProcessTempCredential(*pkData);
            break;
        case _MSG_REQUEST_ACCESS_TOKEN_RET:
            this->ProcessOAuthTokenRet(*pkData);
            break;
        case _MSG_CREATE_TRANSACTION_RET:
            this->ProcessCreateTransactionRet(*pkData);
            break;
        case _MSG_CLOSE_TRANSACTION_RET:
            this->ProcessCloseTransactionRet(*pkData);
            break;
		default:
			break;
	}

	return true;
}

void NDMapMgr::processPlayer(NDTransData* pkData, int nLength)
{
	if (!pkData || nLength == 0)
		return;

	int nUserID = 0;
	(*pkData) >> nUserID; // �û�id 4���ֽ�
	int nLife = 0;
	(*pkData) >> nLife; // ����ֵ4���ֽ�
	int nMaxLife = 0;
	(*pkData) >> nMaxLife; // ����ֵ4���ֽ�
	int nMana = 0;
	(*pkData) >> nMana; // ħ��ֵ
	int nMoney = 0;
	(*pkData) >> nMoney; // ���� 4���ֽ�
	int dwLookFace = 0;
	(*pkData) >> dwLookFace; // ���������ʱ����6����ۿɹ�ѡ����� ���� 4���ֽ�
	unsigned short usRecordX = 0;
	(*pkData) >> usRecordX; // ��¼����ϢX
	unsigned short usRecordY = 0;
	(*pkData) >> usRecordY; // ��¼����ϢY
	unsigned char btDir = 0;
	(*pkData) >> btDir; // ����沿���������������� 1���ֽ�
	unsigned char btProfession = 0;
	(*pkData) >> btProfession; // ��ҵ�ְҵ 1���ֽ�
	unsigned char btLevel = 0;
	(*pkData) >> btLevel; // �û��ȼ�
	int dwState = 0;
	(*pkData) >> dwState; // ״̬λ
	// System.out.println(" ״̬ " + dwState);
	int synRank = 0;
	(*pkData) >> synRank; // ���ɵȼ�
	int dwArmorType = 0;
	(*pkData) >> dwArmorType; // ����id 4���ֽ�
	int dwPkPoint = 0;
	(*pkData) >> dwPkPoint; // pkֵ
	//int weaponTypeID=0; (*pkData) >> weaponTypeID;
	//int armorTypeID=0; (*pkData) >> armorTypeID;
	unsigned char btCamp = 0;
	(*pkData) >> btCamp; // ��Ӫ
	std::string name = "";
	std::string strRank = "";
	std::string synName = ""; // ��������

	unsigned char uiNum = 0;
	(*pkData) >> uiNum; // TQMB ���� 1�ֽ�
	for (int i = 0; i < uiNum; i++)
	{
		std::string strString = pkData->ReadUnicodeString();
		if (i == 0)
		{
			name = strString;
		}
		else if (i == 1 && strString.length() > 2)
		{
			strRank = strString;
		}
		else if (i == 2)
		{
			synName = strString;
		}
	}

	if (synName.empty())
	{
		synRank = SYNRANK_NONE;
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();
	if (nUserID == kPlayer.m_nID)
	{
		if (dwState & USERSTATE_SHAPESHIFT)
		{
			kPlayer.updateTransform(pkData->ReadInt());
		}
		else
		{
			kPlayer.updateTransform(0);
		}

		// ��Ч
		int effectAmount = pkData->ReadByte();
		std::vector<int> vEffect;
		for (int i = 0; i < effectAmount; i++)
		{
			vEffect.push_back(pkData->ReadInt());
		}

		kPlayer.SetPosition(
				ConvertUtil::convertCellToDisplay( usRecordX, usRecordY ));

		kPlayer.SetState(dwState);
		kPlayer.SetServerPositon(usRecordX, usRecordY);
		kPlayer.SetAction(false);
		return;
	}

	NDManualRole *pkRole = NULL;
	bool bAdd = true;
	pkRole = NDMapMgrObj.GetManualRole(nUserID);
	if (!pkRole)
	{
		pkRole = new NDManualRole;
		pkRole->m_nID = nUserID;
		pkRole->Initialization(dwLookFace, true);
		bAdd = false;
	}

	if (dwState & USERSTATE_SHAPESHIFT)
	{
		pkRole->updateTransform(pkData->ReadInt());
	}
	else
	{
		pkRole->updateTransform(0);
	}

	// ��Ч
	int nEffectAmount = pkData->ReadByte();
	std::vector<int> vEffect;
	for (int i = 0; i < nEffectAmount; i++)
	{
		vEffect.push_back(pkData->ReadInt());
	}
	//++Guosen 2012.7.15
	int tRank = pkData->ReadByte();
	int nRideStatus = pkData->ReadInt();
	int nMountType = pkData->ReadInt();
	int nQuality = pkData->ReadByte();
	//unsigned int nMountlookface = ScriptDBObj.GetN( "mount_model_config", nMountType, DB_MOUNT_MODEL_LOOKFACE );
	pkRole->ChangeModelWithMount(nRideStatus, nMountType);
	//++

	pkRole->m_nQuality = nQuality;

	pkRole->m_nLife = nLife;
	pkRole->m_nMaxLife = nMaxLife;
	pkRole->m_nMana = nMana;
	pkRole->m_nMoney = nMoney;
	pkRole->m_nLookface = dwLookFace;
	pkRole->m_nProfesstion = btProfession;
	pkRole->m_nLevel = btLevel;
	pkRole->SetState(dwState);
	pkRole->setSynRank(synRank);
	pkRole->m_nPKPoint = dwPkPoint;
	pkRole->SetCamp((CAMP_TYPE) btCamp);
	pkRole->SetName( name );
	pkRole->m_strRank = strRank;
	pkRole->m_strSynName = synName;
	pkRole->m_nTeamID = dwArmorType;
	pkRole->SetPosition(
			ConvertUtil::convertCellToDisplay( usRecordX, usRecordY ));

	pkRole->SetSpriteDir(btDir);
	pkRole->SetServerPositon(usRecordX, usRecordY);

	if (!bAdd)
	{
		NDMapMgrObj.AddManualRole(nUserID, pkRole);
	}

	pkRole->SetAction(false);
	pkRole->SetServerEffect(vEffect);

	if (dwState & USERSTATE_PRACTISE)
	{
		// todo������Ҵ���״̬
		pkRole->SetCurrentAnimation(7, pkRole->IsReverse());
	}
	else
	{
		// todoȡ������״̬
		if (pkRole->AssuredRidePet())
		{
// 			pkRole->SetCurrentAnimation(pkRole->GetPetStandAction(),
// 					pkRole->IsReverse());
		}
		else
		{
			pkRole->SetCurrentAnimation(0, pkRole->IsReverse());
		}
	}
}

void NDMapMgr::AddManualRole(int nID, NDManualRole* pkRole)
{
	if (0 == pkRole || -1 == nID)
	{
		return;
	}

	m_mapManualRole.insert(make_pair(nID, pkRole));

	NDLayer* pkLayer = (NDLayer*) getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG));

	if (0 == pkLayer)
	{
		return;
	}

	pkLayer->AddChild((NDNode*) pkRole);

	if (pkRole->m_nID == NDPlayer::defaultHero().m_iFocusManuRoleID)
	{
		GameScene* pkGameScene = GameScene::GetCurGameScene();

		if (0 != pkGameScene)
		{
			pkGameScene->SetTargetHead(pkRole);
		}

		pkRole->SetFocus(true);
	}
}

NDManualRole* NDMapMgr::GetManualRole(int nID)
{
	NDPlayer& kRole = NDPlayer::defaultHero();

	if (nID == kRole.m_nID)
	{
		return &kRole;
	}

	if (m_mapManualRole.empty())
	{
		return 0;
	}

	map_manualrole::iterator it = m_mapManualRole.find(nID);

	if (m_mapManualRole.end() != it)
	{
		return it->second;
	}

	return 0;
}

NDManualRole* NDMapMgr::GetManualRole(const char* pszName)
{
	NDManualRole* pkResult = 0;

	for (map_manualrole::iterator it = m_mapManualRole.begin();
			m_mapManualRole.end() != it; it++)
	{
		NDManualRole* pkRole = it->second;

		if (0 == strcmp(pkRole->GetName().c_str(), pszName))
		{
			pkResult = it->second;
			break;
		}
	}

	return pkResult;
}

void NDMapMgr::Update(unsigned long ulDiff)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.Update(ulDiff);

	// �����������
	do
	{
		map_manualrole::iterator it = m_mapManualRole.begin();
		while (it != m_mapManualRole.end())
		{
			NDManualRole *role = it->second;
			if (role->m_bClear)
			{
				//	updateTeamListDelPlayer(*role);			///< No team ����
				SAFE_DELETE_NODE(role->m_pkRidePet);
				SAFE_DELETE_NODE(role);
				m_mapManualRole.erase(it++);
			}
			else
			{
				it++;
			}
		};

		it = m_mapManualRole.begin();
		for (; it != m_mapManualRole.end(); it++)
		{
			NDManualRole* role = it->second;

			if (role == &player)
				continue;

			if (role)
			{
				NDNode* parent = role->GetParent();
				if (parent && !parent->IsKindOfClass(RUNTIME_CLASS(BattleUILayer)))
				{
					role->Update(ulDiff);
				}
			}
		}
	} while (0);

	// ���е�ͼ�ϵĹ�
	do
	{
		if (NDPlayer::defaultHero().IsInState(USERSTATE_FIGHTING)
				|| NDPlayer::defaultHero().IsGathering()
				|| NDUISynLayer::IsShown())
		{
			break;
		}

		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
		{
			GameScene *gamescene = (GameScene*) scene;
			if (gamescene->IsUIShow())
			{
				break;
			}
		}

		VEC_MONSTER::iterator it = m_vMonster.begin();
		while (it != m_vMonster.end())
		{
			NDMonster* tmp = *it;
			if (!tmp->m_bClear)
			{
				it++;
				continue;
			}

			if (GetBattleMonster() == tmp)
			{
				tmp = NULL;
			}

			SAFE_DELETE_NODE(tmp);
			it = m_vMonster.erase(it);
		}

		it = m_vMonster.begin();
		for (; it != m_vMonster.end(); it++)
		{
			NDMonster* monster = *it;
			if (monster && it == m_vMonster.begin())
			{
				monster->Update(ulDiff);
			}
		}
	} while (0);
}

NDMapLayer* NDMapMgr::getMapLayerOfScene(NDScene* pkScene)
{
	if (0 == pkScene)
	{
		return 0;
	}

	NDNode* pkNode = pkScene->GetChild(MAPLAYER_TAG);

	if (0 == pkNode || 0 == pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return 0;
	}

	return (NDMapLayer*) pkNode;
}

void NDMapMgr::DelManualRole(int nID)
{
	if (-1 == nID)
	{
		return;
	}

	map_manualrole::iterator it = m_mapManualRole.find(nID);

	if (m_mapManualRole.end() != it)
	{
		NDManualRole* pkRole = it->second;

		if (pkRole)
		{
			SAFE_DELETE_NODE(pkRole);
		}

		m_mapManualRole.erase(it);
	}
}

void NDMapMgr::processPlayerExt(NDTransData* pkData, int nLength)
{
	if (0 == pkData || 0 == nLength)
	{
		return;
	}

	int nUserID = 0;
	(*pkData) >> nUserID;
	int dwStatus = 0;
	(*pkData) >> dwStatus;

	NDManualRole* pkRole = 0;
	pkRole = NDMapMgrObj.GetManualRole(nUserID);

	if (0 == pkRole)
	{
		return;
	}

	pkRole->SetState(dwStatus);
	pkRole->unpakcAllEquip();

	unsigned char btAmount = 0;
	(*pkData) >> btAmount;

	for (int i = 0; i < btAmount; i++)
	{
		int nEquipTypeID = 0;
		(*pkData) >> nEquipTypeID;
		NDItemType* pkItem = ItemMgrObj.QueryItemType(nEquipTypeID);

		if (0 == pkItem)
		{
			continue;
		}

		pkRole->m_vEquipsID.push_back(nEquipTypeID);
		int nID = pkItem->m_data.m_lookface;
		int nQuality = nEquipTypeID % 10;

		if (0 == nID)
		{
			continue;
		}

		int nAnimationID = 0;

		if (10000 < nID)
		{
			nAnimationID = (nID % 100000) / 10;
		}

		if (nAnimationID >= 1900 && nAnimationID < 2000
				|| nID >= 19000 && nID < 20000)
		{
			ShowPetInfo kShowPetInfo(nEquipTypeID, nID, nQuality);
			pkRole->SetShowPet(kShowPetInfo);
		}
		else
		{
			pkRole->SetEquipment(nID, nQuality);
		}
	}

	if (pkRole->IsInState(USERSTATE_SHAPESHIFT))
	{
		pkRole->updateTransform(pkData->ReadInt());
	}
	else
	{
		pkRole->updateTransform(0);
	}

	if (pkRole->GetParent() != 0
			&& !pkRole->GetParent()->IsKindOfClass(RUNTIME_CLASS(BattleUILayer)))
	{
		pkRole->SetAction(pkRole->isMoving(), true);
	}
}

void NDMapMgr::processWalk(NDTransData* pkData, int nLength)
{
	if (0 == pkData || 0 == nLength)
	{
		return;
	}

	int nID = 0;
	(*pkData) >> nID;
	unsigned char ucDir = 0;
	(*pkData) >> ucDir;

	if (NDPlayer::defaultHero().m_nID != nID)
	{
//		NDManualRole* pkRole = 0;
//		pkRole = NDMapMgrObj.GetManualRole(nID);
//
//		if (pkRole->isTeamLeader())
//		{
//			pkRole->teamSetServerDir(ucDir);
//		}
		NDManualRole *role = NULL;
		role = NDMapMgrObj.GetManualRole(nID);
		if ( role && (!role->isTeamMember() || role->isTeamLeader())) 
		{
			role->AddWalkDir(ucDir);
			role->SetServerDir(ucDir);
			if (role->isTeamLeader()) 
			{
				role->teamSetServerDir(ucDir);
			}
		}
	}
}

void NDMapMgr::processWalkTo(NDTransData& kData)
{
	int nPlayerID = kData.ReadInt();
	int nAmount = kData.ReadByte();
	NDPlayer& kPlayer = NDPlayer::defaultHero();

	for (int i = 0; i < nAmount; i++)
	{
		int nPosX = kData.ReadShort();
		int nPosY = kData.ReadShort();
		int nNPCID = kData.ReadInt();

		if (kPlayer.m_nID == nPlayerID)
		{
			CloseProgressBar;

			if (0 != nNPCID)
			{
				NDNpc* pkNPC = 0;
			}
		}
	}
}

NDNpc* NDMapMgr::GetNpcByID(int nID)
{
	for (VEC_NPC::iterator it = m_vNPC.begin(); m_vNPC.end() != it; it++)
	{
		NDNpc* pkTemp = *it;

		if (nID != pkTemp->m_nID)
		{
			continue;
		}

		return pkTemp;
	}

	return 0;
}

void NDMapMgr::processChangeRoom(NDTransData* pkData, int nLength)
{
	if (NULL == pkData || 0 == nLength)
	{
		return;
	}

	m_nCurrentMonsterBound = 0;

	//�汾��֤
	if (m_bVerifyVersion)
	{
		m_bVerifyVersion = false;
		//NDBeforeGameMgrObj.VerifyVersion();
	}
	
	BattleMgrObj.quitBattle(false);

	m_nRoadBlockX = -1;
	m_nRoadBlockY = -1;

	pkData->ReadShort();  //δʹ��
	pkData->ReadInt();    //δʹ��

	int nMapID = pkData->ReadInt();
	int nMapDocID = pkData->ReadInt();
	int dwPortalX = pkData->ReadShort();  //������X����
	int dwPortalY = pkData->ReadShort();  //������Y����

	pkData->ReadShort();    //δʹ��
	pkData->ReadShort();    //δʹ��
	pkData->ReadShort();    //δʹ��
	pkData->ReadShort();    //δʹ��

	m_nMapType = pkData->ReadInt();
	m_strMapName = pkData->ReadUnicodeString();


	NDUISynLayer::Close(SYN_CREATE_ROLE);
	NDMapMgrObj.ClearManualRole();

	m_nMapID = nMapID;

	if (1 == m_nMapID || 2 == m_nMapID)
	{
		m_nSaveMapID = m_nMapID;
	}

	ShowPetInfo kPetInfoRerserve;

	NDPlayer& kPlayer = NDPlayer::defaultHero();
	kPlayer.m_nCurMapID = nMapDocID;
/*	kPlayer.m_strName = string("efawfawe");*/
	kPlayer.SetPosition( 
		ConvertUtil::convertCellToDisplay( dwPortalX, dwPortalY ));

	kPlayer.stopMoving();
	kPlayer.SetServerPositon(dwPortalX, dwPortalY);
	kPlayer.SetShowPet(kPetInfoRerserve);
	if ( kPlayer.GetParent() )
	{
		kPlayer.RemoveFromParent(false);
	}

	while (NDDirector::DefaultDirector()->PopScene());

	NDMapMgrObj.preLoadScene();
	NDMapMgrObj.loadSceneByMapDocID(nMapDocID);

	NDMapLayer* pkLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
	ND_ASSERT_NO_RETURN(NULL == pkLayer);

	int nTheID = GetMotherMapID();


#if 0
   	NDRidePet* pkRidePet = kPlayer.GetRidePet();
   	if (0 != pkRidePet)
   	{
   		pkRidePet->stopMoving();
   		pkRidePet->SetPositionEx(ccp(dwPortalX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
   									 dwPortalY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
   	}
#endif 

	pkLayer->SetScreenCenter(
			ConvertUtil::convertCellToDisplay( dwPortalX, dwPortalY ));

	kPlayer.SetAction(false);
	kPlayer.SetLoadMapComplete();

	ScriptGlobalEvent::OnEvent (GE_GENERATE_GAMESCENE);

	if (nTheID / 100000000 > 0)
	{
		ScriptMgrObj.excuteLuaFunc("SetUIVisible", "", 0);
	}
	else
	{
		pkLayer->AddChild(&kPlayer);
		ScriptMgrObj.excuteLuaFunc("SetUIVisible", "", 1);
	}

	CloseProgressBar;
	NDMapMgrObj.LoadSceneMonster();
}

void NDMapMgr::processNPCInfoList(NDTransData* pkData, int nLength)
{
	const int LIST_ACTION_END = 1;
	//NDLog(@"����NPC��Ϣ-----------");
	unsigned char btAction = 0;
	(*pkData) >> btAction;
	unsigned char btCount = 0;
	(*pkData) >> btCount;

	for (int i = 0; i < btCount; i++)
	{
		int nID = 0;
		(*pkData) >> nID; // 4���ֽ� pkNpc id
		unsigned char uitype = 0;
		(*pkData) >> uitype; // ���ֶ����ڹ���Ѱ·��pkNpc�б�
		int usLook = 0;
		(*pkData) >> usLook; // 4���ֽ�
		unsigned char btSort = 0;
		(*pkData) >> btSort;
		unsigned short usCellX = 0;
		(*pkData) >> usCellX; // 2���ֽ�
		unsigned short usCellY = 0;
		(*pkData) >> usCellY; // 2���ֽ�
		unsigned char btState = 0;
		(*pkData) >> btState; // 1���ֽڱ�״̬
		unsigned char btCamp = 0;
		(*pkData) >> btCamp;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		std::string strName = pkData->ReadUnicodeString();
		std::string dataStr = pkData->ReadUnicodeString();
		std::string talkStr = pkData->ReadUnicodeString();
#else
	
		// all in utf8
		string strName = pkData->ReadUnicodeString().c_str();
		string dataStr = pkData->ReadUnicodeString().c_str();
		string talkStr = pkData->ReadUnicodeString().c_str();
#endif

		NDNpc *pkNPC = new NDNpc;
		pkNPC->m_nID = nID;
		pkNPC->m_nCol = usCellX;
		pkNPC->m_nRow = usCellY;
		pkNPC->m_nLook = usLook;
		pkNPC->SetCamp(CAMP_TYPE(btCamp));

		if (uitype == 6)
		{
			pkNPC->SetName("");
		}
		else
		{
			pkNPC->SetName(strName);
		}

		pkNPC->SetPosition(
				ConvertUtil::convertCellToDisplay( usCellX, usCellY ));

		pkNPC->setData( dataStr );
		pkNPC->setTalk( talkStr );
		pkNPC->SetType(uitype);
		pkNPC->Initialization(usLook);

		if (btSort != 0)
		{
			pkNPC->SetActionOnRing(false);
			pkNPC->SetDirectOnTalk(false);
		}

		pkNPC->initUnpassPoint();
		NDMapMgrObj.m_vNPC.push_back(pkNPC);
	}

	if (btAction == LIST_ACTION_END)
	{ // �շ�����
		NDMapMgrObj.AddAllNPCToMap();
	}

	NDMapMgrObj.AddAllNPCToMap();
}

void NDMapMgr::AddAllNPCToMap()
{
	NDMapLayer* pkLayer = (NDMapLayer*) getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());

	if (0 == pkLayer)
	{
		return;
	}

	for (VEC_NPC::iterator it = m_vNPC.begin(); m_vNPC.end() != it; it++)
	{
		NDNpc* pkNPC = *it;

		if (pkLayer->ContainChild(pkNPC))
		{
			continue;
		}

		pkLayer->AddChild((NDNode*) pkNPC, 2, 100);

#if 0
 		if (0 != pkNPC->GetRidePet())
 		{
 			pkNPC->GetRidePet()->stopMoving();
 			pkNPC->GetRidePet()->SetPositionEx(pkNPC->GetPosition());
 			pkNPC->GetRidePet()->SetCurrentAnimation(RIDEPET_STAND, pkNPC->m_bFaceRight);
 		}
#endif 
		pkNPC->HandleNpcMask(true);
	}

	NDPlayer::defaultHero().UpdateFocus();
}

void NDMapMgr::OnCustomViewRadioButtonSelected(NDUICustomView* customView,
		unsigned int radioButtonIndex, int ortherButtonTag)
{
	//throw std::exception("The method or operation is not implemented.");
}

void NDMapMgr::ClearManualRole()
{
	if (m_mapManualRole.empty())
	{
		return;
	}

	for (map_manualrole::iterator it = m_mapManualRole.begin();
			m_mapManualRole.end() != it; it++)
	{
		NDManualRole* pkRole = it->second;
		SAFE_DELETE_NODE(pkRole);
	}
	m_mapManualRole.clear();
}

void NDMapMgr::ClearNPC()
{
	if (m_vNPC.empty())
	{
		return;
	}

	for (VEC_NPC::iterator it = m_vNPC.begin(); m_vNPC.end() != it; it++)
	{
		NDNpc* pkRole = *it;
		SAFE_DELETE_NODE(pkRole);
	}

	m_vNPC.clear(); 
}

void NDMapMgr::ClearMonster()
{
	if (m_vMonster.empty())
	{
		return;
	}

	for (VEC_MONSTER::iterator it = m_vMonster.begin(); m_vMonster.end() != it;
			it++)
	{
		NDMonster* pkRole = *it;
		SAFE_DELETE_NODE(pkRole);
	}
}

void NDMapMgr::ClearGP()
{

}

bool NDMapMgr::loadSceneByMapDocID(int nMapID)
{
	m_nMapDocID = nMapID;

	NDDirector::DefaultDirector()->PurgeCachedData();
	//NDDirector::DefaultDirector()->ReplaceScene(NDScene::Scene());

	CSMGameScene* pkScene = CSMGameScene::Scene();
	pkScene->Initialization(nMapID);
	pkScene->SetTag(SMGAMESCENE_TAG);
	NDDirector::DefaultDirector()->ReplaceScene(pkScene);

	NDMapLayer* pkMapLayer = getMapLayerOfScene(pkScene);

	if (0 != pkMapLayer)
	{
		m_kMapSize = pkMapLayer->GetContentSize();
	}
	else
	{
		m_kMapSize = CCSizeZero;
	}

	AddSwitch();

	return true;
}

void NDMapMgr::AddSwitch()
{
	NDScene* pkScene = NDDirector::DefaultDirector()->GetScene(
			RUNTIME_CLASS(CSMGameScene));
	NDMapLayer* pkLayer = 0;
	NDMapData* pkMapData = 0;

	ND_ASSERT_NO_RETURN(NULL == pkScene);
	ND_ASSERT_NO_RETURN(NULL == (pkLayer = getMapLayerOfScene(pkScene)));
	ND_ASSERT_NO_RETURN(NULL == (pkMapData = pkLayer->GetMapData()));

	ScriptDB& kScriptDB = ScriptDBObj;
	ID_VEC kIDList;
	kScriptDB.GetIdList("portal", kIDList);

	for (ID_VEC::iterator it = kIDList.begin(); kIDList.end() != it; it++)
	{
		int nMapID = GetMapID();

		if (kScriptDB.GetN("portal", *it, DB_PORTAL_MAPID) == nMapID)
		{
			int nIndex = kScriptDB.GetN("portal", *it, DB_PORTAL_PORTAL_INDEX);
			int nX = kScriptDB.GetN("portal", *it, DB_PORTAL_PORTALX);
			int nY = kScriptDB.GetN("portal", *it, DB_PORTAL_PORTALY);

			string strDesc = NDCommonCString2("CityGate");

			pkMapData->addMapSwitch(nX, nY, nIndex, nMapID, strDesc.c_str(),
					"");
		}
	}

	pkLayer->MapSwitchRefresh();
}

int NDMapMgr::GetMapID()
{
	return m_nMapID;
}

void NDMapMgr::WorldMapSwitch(int mapId)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene) 
	{
		return;
	}

	NDDirector::DefaultDirector()->PushScene(GameSceneLoading::Scene());

	NDPlayer& player = NDPlayer::defaultHero();
	NDTransData bao(_MSG_POSITION);
	bao << player.m_nID << (unsigned short)0 << (unsigned short)0 
		<< mapId << (unsigned short)_WORD_MAPCHANGE << int(0);
	SEND_DATA(bao);
}

int NDMapMgr::GetMotherMapID()
{
	int nTheID = m_nMapID;

	if (m_nMapID / 10000000 > 0)
	{
		nTheID = m_nMapID / 100000 * 100000;
	}

	return nTheID;
}

void NDMapMgr::LoadSceneMonster()
{
	int nTheID = GetMotherMapID();
	ID_VEC kIDList;
	ScriptDBObj.GetIdList("mapzone", kIDList);

	for (unsigned int i = 0; i < kIDList.size(); i++)
	{
		int m_nID = ScriptDBObj.GetN("mapzone", kIDList.at(i),
				DB_MAPZONE_MAPID);
		if (m_nID == nTheID)
		{

			NDMapLayer* pkLayer = NDMapMgrObj.getMapLayerOfScene(
					NDDirector::DefaultDirector()->GetRunningScene());
			if (!pkLayer)
			{
				return;
			}
			NDMonster* pkMonster = new NDMonster();
			int elite_flag = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_ELITE_FLAG);

			pkMonster->m_nID = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_ID);
			int col = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_POS_X);
			int row = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_POS_Y);
			int idType = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_MONSTER_TYPE);
			int atk_area = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_ATK_AREA);
			int rule_id = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_GENERATE_RULE_ID);
			pkMonster->Initialization(idType);
			NDMapMgrObj.m_vMonster.push_back(pkMonster);
		}
	}
	NDMapMgrObj.AddAllMonsterToMap();
}

void NDMapMgr::AddAllMonsterToMap()
{
	NDMapLayer* pkLayer = getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());

	if (0 == pkLayer)
	{
		return;
	}

	for (VEC_MONSTER::iterator it = m_vMonster.begin(); m_vMonster.end() != it;
			it++)
	{
		NDMonster* pkMonster = *it;

		if (0 != pkMonster && pkMonster->m_nID > 0
				&& pkMonster->getState() == MONSTER_STATE_DEAD)
		{
			continue;
		}

		if (pkMonster->GetParent() == 0)
		{
			pkLayer->AddChild((NDNode*) pkMonster, 0, 0);
		}

		///< �������gather... ����
	}
}

bool NDMapMgr::processConsole(const char* pszInput)
{
	if (true)
	{
		return false;
	}

	string strInput = pszInput;

	printf("�_ʼ����Ҫģ�M�İ�����\n");

	NDTransData kTransData;

	vector < string > kStringVector;
	int nPos = 0;
	int nStartPos = 0;
	int nOmegaPos = 0;
	short usMsgID = 0;
	unsigned char szBuffer[1024] =
	{ 0 };
	unsigned int pPos = 0;

	nOmegaPos = strInput.find(';');
	unsigned int nLength = strInput.length();

	if (strInput.length() - 3 != nOmegaPos)
	{
		printf("�﷨����\n");
		return false;
	}

	while (true)
	{
		nPos = strInput.find(',');
		int nKeywordPos = 0;

		string strNum;

		if (-1 == nPos)
		{
			strNum = strInput.substr(0, strInput.length() - 3);
			break;
		}
		else
		{
			strNum = strInput.substr(nStartPos, nPos);
		}

		if (0 == strNum.length())
		{
			printf("����\n");
			break;
		}

		int uiData = 0;
		short usData = 0;
		char ucData = 0;
		strInput = strInput.substr(nPos + 1, strInput.length());

		if (GetShortData(usMsgID, strNum, string("id")))
		{
			if (0 == usMsgID)
			{
				return false;
			}
		}
		else if (GetIntData(uiData, strNum, string("int")))
		{
			kTransData.WriteInt(uiData);
		}
		else if (GetShortData(usData, strNum, string("short")))
		{
			kTransData.WriteShort(usData);
		}
		else if (GetCharData(ucData, strNum, string("char")))
		{
			kTransData.WriteByte(ucData);
		}
	}

	process(usMsgID, &kTransData, 0);

	printf("�����ꮅ!\n");

	return true;
}

void NDMapMgr::OnTimer(OBJID tag)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	const char* pszCommand = NDConsole::instance().GetSpecialCommand(
			"sim ");

	if (0 != pszCommand && *pszCommand)
	{
		string strInput = pszCommand;

		printf("�_ʼ����Ҫģ�M�İ�����\n");

		NDTransData kTransData;

		vector < string > kStringVector;
		int nPos = 0;
		int nStartPos = 0;
		int nOmegaPos = 0;
		short usMsgID = 0;
		unsigned char szBuffer[1024] =
		{ 0 };
		unsigned int pPos = 0;

		nOmegaPos = strInput.find(';');
		unsigned int nLength = strInput.length();

		if (strInput.length() - 3 != nOmegaPos)
		{
			printf("�﷨����\n");
			return;
		}

		while (true)
		{
			nPos = strInput.find(',');
			int nKeywordPos = 0;

			string strNum;

			if (-1 == nPos)
			{
				strNum = strInput.substr(0, strInput.length() - 3);
				break;
			}
			else
			{
				strNum = strInput.substr(nStartPos, nPos);
			}

			if (0 == strNum.length())
			{
				printf("����\n");
				break;
			}

			int uiData = 0;
			short usData = 0;
			char ucData = 0;
			strInput = strInput.substr(nPos + 1, strInput.length());

			if (GetShortData(usMsgID, strNum, string("id")))
			{
				if (0 == usMsgID)
				{
					return;
				}
			}
			else if (GetIntData(uiData, strNum, string("int")))
			{
				kTransData.WriteInt(uiData);
			}
			else if (GetShortData(usData, strNum, string("short")))
			{
				kTransData.WriteShort(usData);
			}
			else if (GetCharData(ucData, strNum, string("char")))
			{
				kTransData.WriteByte(ucData);
			}
		}

		process(usMsgID, &kTransData, 0);

		printf("�����ꮅ!\n");
	}
#endif
}

NDMonster* NDMapMgr::GetBattleMonster()
{
	return m_apWaitBattleMonster;
}

void NDMapMgr::SetBattleMonster(NDMonster* pkMonster)
{
	if (0 == pkMonster)
	{
		m_apWaitBattleMonster.Clear();
	}
	else
	{
		m_apWaitBattleMonster = pkMonster->QueryLink();
	}
}

void NDMapMgr::getDeviceVersionInfo_JNI()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"getDeviceVersion",
		"()Ljava/lang/String;"))
	{
		jstring retFromJava = (jstring) t.env->CallStaticObjectMethod(t.classID, t.methodID);
		const char* str = t.env->GetStringUTFChars(retFromJava, 0);
		ScriptMgrObj.excuteLuaFunc("setDeviceVersionInfo", "MsgLoginSuc", str);
		CCLog("tzq %s", str);
		t.env->ReleaseStringUTFChars(retFromJava, str);
		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(retFromJava);
	}
#endif
}

void NDMapMgr::ProcessLoginSuc(NDTransData& kData)
{
	getDeviceVersionInfo_JNI();
	ScriptMgrObj.excuteLuaFunc("ProcessLoginSuc", "MsgLoginSuc", 0);
}

void NDMapMgr::processNpcTalk(NDTransData& kData)
{
	int nAction = kData.ReadByte();
	int nID = kData.ReadInt();
	int nTime = kData.ReadInt();
	std::string strMessage = kData.ReadUnicodeString();
	switch (nAction)
	{
	case 0:
	{
		NDManualRole* pkPlayer = GetManualRole(nID);
		if (pkPlayer != NULL)
		{
			pkPlayer->addTalkMsg(strMessage, nTime);
		}
		break;
	}
	case 1:
	{
		CloseProgressBar;
		NDNpc *pkNPC = GetNpcByID(nID);
		if (pkNPC != NULL)
		{
			pkNPC->addTalkMsg(strMessage, nTime);
		}
		break;
	}
	case 2:
	{
		NDMonster *pkMonster = GetMonster(nID);
		if (pkMonster != NULL)
		{
			pkMonster->addTalkMsg(strMessage, nTime);
		}
	}
		break;
	}
}

NDMonster* NDMapMgr::GetMonster(int nID)
{
	for (VEC_MONSTER::iterator it = m_vMonster.begin(); it != m_vMonster.end();
			it++)
	{
		NDMonster *pkTempMonster = *it;

		if (pkTempMonster->m_nID == nID)
		{
			return pkTempMonster;
		}
	}

	return NULL;
}

void NDMapMgr::processMsgCommonList(NDTransData& kData)
{
	///< ���������ڵ�NewPaiHangScene ����

// 	int iID = kData.ReadInt();
// 	int field_count = kData.ReadInt();
// 	int button_count = kData.ReadInt();
// 	string title = kData.ReadUnicodeString();
// 
// 	NewPaiHangScene::curPaiHangType = iID;
// 
// 	std::vector<int>& fildTypes = NewPaiHangScene::s_PaiHangTitle[iID].fildTypes;
// 	std::vector<std::string>& fildNames = NewPaiHangScene::s_PaiHangTitle[iID].fildNames;
// 
// 	fildTypes.clear();
// 	fildNames.clear();
// 
// 	for (int i = 0; i < field_count; i++) {
// 		fildTypes.push_back(kData.ReadByte());
// 		fildNames.push_back(kData.ReadUnicodeString());
// 	}
// 
// 	for (int i = 0; i < button_count; i++) {
// 		kData.ReadUnicodeString();
// 	}
}

void NDMapMgr::processMsgCommonListRecord(NDTransData& kData)
{
	///< ���������ڵ�NewPaiHangScene ����

// 	int packageFlag = kData.ReadByte();
// 	int curCount = kData.ReadByte();
// 	kData.ReadShort();
// 
// 
// 	std::vector<int>& fildTypes = NewPaiHangScene::s_PaiHangTitle[NewPaiHangScene::curPaiHangType].fildTypes;
// 	std::vector<std::string>& values = NewPaiHangScene::values[NewPaiHangScene::curPaiHangType];
// 	values.clear();
// 	for (int i = 0; i < curCount; i++) {
// 		kData.ReadInt(); // button id
// 		for (int j = 0; j < int(fildTypes.size()); j++) {
// 			if (fildTypes[j] == 0) {
// 				std::stringstream ss; ss << (kData.ReadInt());
// 				values.push_back(ss.str());
// 			} else if (fildTypes[j] == 1) {
// 				values.push_back(kData.ReadUnicodeString());				
// 			}
// 		}
// 	}
// 
// 	if ((packageFlag & 2) > 0) {
// 		NewPaiHangScene::refresh();
// 		CloseProgressBar;
// 	}
}

void NDMapMgr::processMonsterInfo(NDTransData* pkData, int nLength)
{
	///< �˺�������ע�Ͷ����������ڵ�GatherPoint ����

	unsigned char btAction = 0;
	(*pkData) >> btAction;
	unsigned char count = 0;
	(*pkData) >> count;

	switch (btAction)
	{
	case MONSTER_INFO_ACT_INFO:
		for (int i = 0; i < count; i++)
		{

			int idType = 0;
			(*pkData) >> idType;
			int lookFace = 0;
			(*pkData) >> lookFace;
			unsigned char lev = 0;
			(*pkData) >> lev;
			unsigned char btAiType = 0;
			(*pkData) >> btAiType;
			unsigned char btCamp = 0;
			(*pkData) >> btCamp;
			unsigned char btAtkArea = 0;
			(*pkData) >> btAtkArea;
			std::string name = pkData->ReadUnicodeString(); //����ַ���������Ҫ���޸�

			monster_type_info info;
			info.idType = idType;
			info.lookFace = lookFace;
			info.lev = lev;
			info.btAiType = btAiType;
			info.btCamp = btCamp;
			info.btAtkArea = btAtkArea;
			info.name = name;
			//if (lookFace == 19070 || lookFace == 206) continue;

			NDMapMgrObj.m_mapMonsterInfo.insert(
					monster_info_pair(idType, info));
		}
		break;
	case MONSTER_INFO_ACT_POS:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			int idType = 0;
			(*pkData) >> idType;
			unsigned short col = 0;
			(*pkData) >> col;
			unsigned short row = 0;
			(*pkData) >> row;
			unsigned char btState = 0;
			(*pkData) >> btState;

			NDLayer *layer = NDMapMgrObj.getMapLayerOfScene(
					NDDirector::DefaultDirector()->GetRunningScene());
			if (!layer)
			{
				return;
			}

			if (idType / 1000000 == 6)
			{ // �ɼ�
			  //GatherPoint *gp = NULL;
// 					if (idMonster > 0)
// 					{
// 						//map_gather_point_it it = m_mapGP.find(idMonster);
// 						if (it != m_mapGP.end())
// 						{
// 							gp = it->second;
// 						}
// 					}

				//if (gp == NULL) 
				//{
				//gp = new GatherPoint(idMonster, idType, col*MAP_UNITSIZE,
				//					 row *MAP_UNITSIZE, idMonster > 0, "");
				//m_mapGP.insert(map_gather_point_pair(idMonster, gp));
				//}

				//gp->setState(btState);

				continue;
			}

			monster_type_info info;
			if (!NDMapMgrObj.GetMonsterInfo(info, idType))
				continue;

			NDMonster* monster = new NDMonster;
			monster->m_nID = idMonster;
			monster->SetPosition(ccp(col * MAP_UNITSIZE_X, row * MAP_UNITSIZE_Y));
			monster->Initialization(idType);
			monster->SetType(MONSTER_ELITE);
			if (idMonster > 0)
			{
				monster->setState(btState);
			}

			NDMapMgrObj.m_vMonster.push_back(monster);

		}
		NDMapMgrObj.AddAllMonsterToMap();
		break;
	case MONSTER_INFO_ACT_STATE:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			unsigned char btState = 0;
			(*pkData) >> btState;
			if (idMonster > 0)
			{
// 					GatherPoint *gp = NULL;
// 					if (idMonster > 0)
// 					{
// 						map_gather_point_it it = m_mapGP.find(idMonster);
// 						if (it != m_mapGP.end())
// 						{
// 							gp = it->second;
// 						}
// 					}
// 					
// 					if (gp == NULL) 
// 					{
// 						for_vec(m_vMonster, vec_monster_it)
// 						{
// 							if ((*it)->m_nID == idMonster)
// 							{
// 								(*it)->setState(btState);
// 							}
// 						}
// 					}
// 					else
// 					{
// 						gp->setState(btState);
// 					}
			}
		}
		break;
	case MONSTER_INFO_ACT_BOSS_POS:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			int idType = 0;
			(*pkData) >> idType;
			unsigned short col = 0;
			(*pkData) >> col;
			unsigned short row = 0;
			(*pkData) >> row;
			unsigned char btState = 0;
			(*pkData) >> btState;

			NDLayer *layer = NDMapMgrObj.getMapLayerOfScene(
					NDDirector::DefaultDirector()->GetRunningScene());
			if (!layer)
			{
				return;
			}

			if (idType / 1000000 == 6)
			{ // �ɼ�
// 					GatherPoint *gp = NULL;
// 					if (idMonster > 0)
// 					{
// 						map_gather_point_it it = m_mapGP.find(idMonster);
// 						if (it != m_mapGP.end())
// 						{
// 							gp = it->second;
// 						}
// 					}
// 					
// 					if (gp == NULL) 
// 					{
// 						gp = new GatherPoint(idMonster, idType, col*MAP_UNITSIZE,
// 											 row *MAP_UNITSIZE, idMonster > 0, "");
// 						m_mapGP.insert(map_gather_point_pair(idMonster, gp));
// 					}
// 					
// 					gp->setState(btState);

				continue;
			}

			monster_type_info info;
			NDMonster *monster = new NDMonster;
			monster->m_nID = idMonster;
			monster->SetPosition(ccp(col * MAP_UNITSIZE_X, row * MAP_UNITSIZE_Y));
			monster->Initialization(idType);
			monster->SetType(MONSTER_BOSS);
			if (idMonster > 0)
			{
				monster->setState(btState);
			}

			NDMapMgrObj.m_vMonster.push_back(monster);

		}
		NDMapMgrObj.AddAllMonsterToMap();
		break;
	case MONSTER_INFO_ACT_BOSS_STATE:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			unsigned char btState = 0;
			(*pkData) >> btState;
			if (idMonster > 0)
			{
				for_vec(m_vMonster, vec_monster_it)
				{
					if ((*it)->m_nID == idMonster
							&& (*it)->GetType() == MONSTER_BOSS)
					{
						(*it)->setState(btState);
					}
				}
			}
		}
		break;
	}
}

bool NDMapMgr::GetMonsterInfo(monster_type_info& kInfo, int nType)
{
	monster_info_it it = m_mapMonsterInfo.find(nType);

	if (it == m_mapMonsterInfo.end())
	{
		return false;
	}

	kInfo = it->second;
	return true;
}

void NDMapMgr::BattleEnd(int iResult)
{
	NDMonster* monster = GetBattleMonster();
	if (monster && monster->getState() != MONSTER_STATE_DEAD)
	{
		monster->endBattle();
		monster->setMonsterStateFromBattle(iResult);
		SetBattleMonster(0);
	}

	if (BATTLE_COMPLETE_WIN == iResult)
	{
		m_nCurrentMonsterRound++;
	}
	else
	{
		if (BattleMgrObj.GetBattle()->GetBattleType() == BATTLE_TYPE_MONSTER)
		{
			if (monster)
			{
				monster->restorePosition();

				NDPlayer& player = NDPlayer::defaultHero();

				player.SetPosition(
						ccp(monster->m_nSelfMoveRectX - 64,	//@todo:���۵�Ӳ���룡
								monster->GetPosition().y));
				player.SetServerPositon(
						(monster->m_nSelfMoveRectX - 64) / MAP_UNITSIZE_X,
						(monster->GetPosition().y) / MAP_UNITSIZE_Y);

				BattleUILayer* battle = BattleMgrObj.GetBattle();
				if (battle)
				{
					battle->setSceneCetner(monster->m_nSelfMoveRectX - 64, //@todo:���۵�Ӳ���룡
							monster->GetPosition().y);
					player.stopMoving();
				}
				else
				{
					NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(
							NDDirector::DefaultDirector()->GetRunningScene());

					if (layer)
					{
						layer->SetScreenCenter(
								ccp(monster->m_nSelfMoveRectX - 64, //@todo:���۵�Ӳ���룡
										monster->GetPosition().y));
					}
					player.stopMoving();
				}
			}
		}
	}

	NDPlayer::defaultHero().BattleEnd(iResult);
}

void NDMapMgr::processNpcStatus(NDTransData* pkData, int nLength)
{
	unsigned char ucCount = 0;
	(*pkData) >> ucCount;

	for (int i = 0; i < ucCount; i++)
	{
		int nNPCID = 0;
		nNPCID = pkData->ReadInt();
		unsigned char ucState = 0;
		(*pkData) >> ucState;
		NDNpc *pkNPC = NULL;
		for_vec(m_vNPC, VEC_NPC::iterator)
		{
			if ((*it) && (*it)->m_nID == nNPCID)
			{
				pkNPC = *it;
			}
		}
		if (pkNPC)
		{
			pkNPC->SetNpcState(NPC_STATE(ucState));
		}
	}
}

void NDMapMgr::processDisappear(NDTransData* pkData, int nLength)
{
	if (!pkData || nLength == 0)
		return;

	int nUserID = 0;
	(*pkData) >> nUserID;

	NDManualRole *pkRole = GetManualRole(nUserID);
	if (pkRole)
	{
		pkRole->m_bClear = true;

		BattleMgr& kBattleMgr = BattleMgrObj;

		if (kBattleMgr.GetBattle()
				&& kBattleMgr.GetBattle()->OnRoleDisapper(pkRole->m_nID))
		{
			pkRole->RemoveFromParent(false);
		}

		NDPlayer::defaultHero().UpdateFocusPlayer();
	}
}

void NDMapMgr::processKickBack(NDTransData* pkData, int nLength)
{
	CCLog( "@@ !! NDMapMgr::processKickBack() !!\r\n ");

	if (!pkData || nLength == 0)
		return;

	unsigned short usRecordX = 0;
	(*pkData) >> usRecordX;
	unsigned short usRecordY = 0;
	(*pkData) >> usRecordY;

	NDPlayer& player = NDPlayer::defaultHero();

	player.SetPosition(
			ConvertUtil::convertCellToDisplay( usRecordX, usRecordY ));

	player.SetServerPositon(usRecordX, usRecordY);
	if (player.isTeamLeader())
	{
		player.teamSetServerPosition(usRecordX, usRecordY);
	}

	BattleUILayer* battle = BattleMgrObj.GetBattle();
	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());
	player.stopMoving();
	if (battle)
	{
		//NDLog(@"x,y=%d,%d",usRecordX,us);
		CCPoint centerPos = ConvertUtil::convertCellToDisplay( usRecordX, usRecordY );
		battle->setSceneCetner(centerPos.x, centerPos.y );
	}
	else
	{

		if (!layer)
		{
			return;
		}
		layer->SetScreenCenter(
				ConvertUtil::convertCellToDisplay( usRecordX, usRecordY ));
	}
}

void NDMapMgr::processChgPoint(NDTransData* pkData, int nLength)
{
	unsigned char ucAnswer = 0;
	(*pkData) >> ucAnswer;

	if (ucAnswer == 1)
	{
		// ������,��ԭ���޸��û�����
		NDPlayer::defaultHero().m_nPhyPoint -=
				NDPlayer::defaultHero().m_iTmpPhyPoint;
		NDPlayer::defaultHero().m_nDexPoint -=
				NDPlayer::defaultHero().m_iTmpDexPoint;
		NDPlayer::defaultHero().m_nMagPoint -=
				NDPlayer::defaultHero().m_iTmpMagPoint;
		NDPlayer::defaultHero().m_nDefPoint -=
				NDPlayer::defaultHero().m_iTmpDefPoint;
		NDPlayer::defaultHero().m_nRestPoint =
				NDPlayer::defaultHero().m_iTmpRestPoint;
	}

	// ����ӵ����Ի���
	NDPlayer::defaultHero().m_iTmpPhyPoint = 0;
	NDPlayer::defaultHero().m_iTmpDexPoint = 0;
	NDPlayer::defaultHero().m_iTmpMagPoint = 0;
	NDPlayer::defaultHero().m_iTmpDefPoint = 0;
	NDPlayer::defaultHero().m_iTmpRestPoint = 0;

	/***
	 * �������������ڵ� GameUIAttrib  ����
	 */
	// ����������Խ��洦�ڴ�״̬,����¸ý���
// 	GameUIAttrib *pkAttr = GameUIAttrib::GetInstance();
// 	if (pkAttr) 
// 	{
// 		pkAttr->UpdateGameUIAttrib();
// 	}
}

void NDMapMgr::processPetInfo(NDTransData* pkData, int nLength)
{
	NDPlayer& player = NDPlayer::defaultHero();

	NDManualRole* pkRole = NULL;

	bool bUseNewScene = false;

	int action = 0;
	(*pkData) >> action;

	int idPet = 0;
	(*pkData) >> idPet;

	if (action == 2)
	{
		NDPlayer & player = NDPlayer::defaultHero();
		ShowPetInfo showPetInfo;
		player.GetShowPetInfo(showPetInfo);
		if ((OBJID)idPet == showPetInfo.idPet)
		{
			player.ResetShowPet();
		}

		PetMgrObj.DelPet(idPet);
		//CUIPet* pUIPet = PlayerInfoScene::QueryPetScene();///< �˴�ע�����������ڵ� PlayerInfoScene  ����
		//if (pUIPet) {
		///< �˴�ע�����������ڵ� CUIPet  ����
		//pUIPet->UpdateUI(idPet);
		//}
		return;
	}

	int ownerid = 0;
	(*pkData) >> ownerid;

	if (ownerid == player.m_nID)
	{
		pkRole = (NDManualRole*) &player;
	}
	else
	{
		pkRole = GetManualRole(ownerid);
	}

	if (action != 1)
	{
		return;
	}

	PetInfo* kPetInfo = PetMgrObj.GetPetWithCreate(ownerid, idPet);

	NDAsssert(kPetInfo != NULL);

	PetInfo::PetData* pkPet = &kPetInfo->data;

	pkPet->int_PET_ID = idPet;

	bool bSwithPlayerInfoScene = false;

	int attrNum = 0;
	(*pkData) >> attrNum;
	for (int i = 0; i < attrNum; i++)
	{
		int type = 0;
		(*pkData) >> type;
		int value = 0;

		if (type != 100)
		{
			value = pkData->ReadInt();
		}

		switch (type)
		{
		case 1:		// PET_ATTR_LEVEL
			pkPet->int_PET_ATTR_LEVEL = value;
			break;
		case 2:		// PET_ATTR_EXP
			pkPet->int_PET_ATTR_EXP = value;
			break;
		case 3:		// PET_ATTR_LIFE
			pkPet->int_PET_ATTR_LIFE = value;
			break;
		case 4:		// PET_ATTR_MAX_LIFE
			pkPet->int_PET_ATTR_MAX_LIFE = value;
			break;
		case 5:		// PET_ATTR_MANA
			pkPet->int_PET_ATTR_MANA = value;
			break;
		case 6:		// PET_ATTR_MAX_MANA6
			pkPet->int_PET_ATTR_MAX_MANA = value;
			break;
		case 7:		// PET_ATTR_STR7
			pkPet->int_PET_ATTR_STR = value;
			break;
		case 8:		// PET_ATTR_STA8
			pkPet->int_PET_ATTR_STA = value;
			break;
		case 9:		// PET_ATTR_AGI9
			pkPet->int_PET_ATTR_AGI = value;
			break;
		case 10:		// PET_ATTR_INI10
			pkPet->int_PET_ATTR_INI = value;
			break;
		case 11:		// PET_ATTR_LEVEL_INIT11
			pkPet->int_PET_ATTR_LEVEL_INIT = value;
			break;
		case 12:		// PET_ATTR_STR_INIT12
			pkPet->int_PET_ATTR_STR_INIT = value;
			break;
		case 13:		// PET_ATTR_STA_INIT13
			pkPet->int_PET_ATTR_STA_INIT = value;
			break;
		case 14:		// PET_ATTR_AGI_INIT14
			pkPet->int_PET_ATTR_AGI_INIT = value;
			break;
		case 15:		// PET_ATTR_INI_INIT15
			pkPet->int_PET_ATTR_INI_INIT = value;
			break;
		case 16:		// PET_ATTR_LOYAL16
			pkPet->int_PET_ATTR_LOYAL = value;
			break;
		case 17:		// PET_ATTR_AGE17
			pkPet->int_PET_ATTR_AGE = value;
			break;
		case 18:		// PET_ATTR_FREE_SP18
			pkPet->int_PET_ATTR_FREE_SP = value;
			break;
		case 19:		// PET_ATTR_STR_RATE19
			pkPet->int_PET_PHY_ATK_RATE = value;
			break;
		case 20:		// PET_ATTR_STA_RATE20
			pkPet->int_PET_PHY_DEF_RATE = value;
			break;
		case 21:		// PET_ATTR_AGI_RATE21
			pkPet->int_PET_MAG_ATK_RATE = value;
			break;
		case 22:		// PET_ATTR_INI_RATE22
			pkPet->int_PET_MAG_DEF_RATE = value;
			break;
		case 23:		// PET_ATTR_HP_RATE23
			pkPet->int_PET_ATTR_HP_RATE = value;
			break;
		case 24:		// PET_ATTR_MP_RATE24
			pkPet->int_PET_ATTR_MP_RATE = value;
			break;
		case 25:		// PET_ATTR_LEVEUP_EXP25
			pkPet->int_PET_ATTR_LEVEUP_EXP = value;
			break;
		case 26:		// PET_ATTR_PHY_ATK26
			pkPet->int_PET_ATTR_PHY_ATK = value;
			break;
		case 27:		// PET_ATTR_PHY_DEF27
			pkPet->int_PET_ATTR_PHY_DEF = value;
			break;
		case 28:		// PET_ATTR_MAG_ATK28
			pkPet->int_PET_ATTR_MAG_ATK = value;
			break;
		case 29:		// PET_ATTR_MAG_DEF29
			pkPet->int_PET_ATTR_MAG_DEF = value;
			break;
		case 30:		// PET_ATTR_HARD_HIT30
			pkPet->int_PET_ATTR_HARD_HIT = value;
			break;
		case 31:		// PET_ATTR_DODGE31
			pkPet->int_PET_ATTR_DODGE = value;
			break;
		case 32:		// PET_ATTR_ATK_SPEED32
			pkPet->int_PET_ATTR_ATK_SPEED = value;
			break;
		case 33:		// PET_ATTR_TYPE33 ;����
			pkPet->int_PET_ATTR_TYPE = value;
			break;
		case 34:		// ���
			pkPet->int_PET_ATTR_LOOKFACE = value;
			break;
		case 35:		// PET_ATTR_SKILL_1 32
			pkPet->int_PET_MAX_SKILL_NUM = value;
			//PetSkillSceneUpdate();
			//PetSkillIconLayer::OnUnLockSkill(); ///< δ֪ ����
			bUseNewScene = true;
			break;
		case 36:			// PET_ATTR_SKILL_2 33
			pkPet->int_ATTR_FREE_POINT = value;
			break;
		case 37:			// �ٶ�����
			pkPet->int_PET_SPEED_RATE = value;
			break;
		case 38:			// �﹥��������
			pkPet->int_PET_PHY_ATK_RATE_MAX = value;
			break;
		case 39:			// �����������
			pkPet->int_PET_PHY_DEF_RATE_MAX = value;
			break;
		case 40:			// ������������
			pkPet->int_PET_MAG_ATK_RATE_MAX = value;
			break;
		case 41:			// ������������
			pkPet->int_PET_MAG_DEF_RATE_MAX = value;
			break;
		case 42:			// �����ӳ���������
			pkPet->int_PET_ATTR_HP_RATE_MAX = value;
			break;
		case 43:			// ħ���ӳ���������
			pkPet->int_PET_ATTR_MP_RATE_MAX = value;
			break;
		case 44:			// �ٶ���������
			pkPet->int_PET_SPEED_RATE_MAX = value;
			break;
		case 45:			// �ɳ���
			pkPet->int_PET_GROW_RATE = value;
			break;
		case 46:			// �ɳ�������
			pkPet->int_PET_GROW_RATE_MAX = value;
			break;
		case 47:			// ����
			pkPet->int_PET_HIT = value;
			break;
		case 48:			//��״̬
			pkPet->bindStatus = value;
			break;
		case 49: //����λ��
		{
			if (pkPet->int_PET_ATTR_POSITION != value)
			{
				bSwithPlayerInfoScene = true;
			}

			pkPet->int_PET_ATTR_POSITION = value;
		}
			break;
		case 100: // ����
		{
			std::string petName = pkData->ReadUnicodeString();
			kPetInfo->str_PET_ATTR_NAME = petName;
			break;
		}
		default:
			break;
		}
	}

	if (pkPet->int_PET_ATTR_POSITION & PET_POSITION_SHOW)
	{
		if (pkRole)
		{
			ShowPetInfo showPetInfo(pkPet->int_PET_ID,
					pkPet->int_PET_ATTR_LOOKFACE, kPetInfo->GetQuality());
			pkRole->SetShowPet(showPetInfo);
		}
	}
	else if (pkRole)
	{
		ShowPetInfo showPetInfo;
		pkRole->GetShowPetInfo(showPetInfo);
		if ((OBJID)pkPet->int_PET_ID == showPetInfo.idPet)
		{
			pkRole->ResetShowPet();
		}
	}

	if (bSwithPlayerInfoScene && pkRole->m_nID == ownerid)
	{
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();

		//if (scene && scene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene))) ///< �˴�ע�����������ڵ� PlayerInfoScene  ����
		{
			///< ������ע�����������ڵ� PlayerInfoScene  ����
			//PlayerInfoScene *playerInfoScene = (PlayerInfoScene*)scene;

			//playerInfoScene->SetTabFocusOnIndex(3, true);
		}
	}

	///< �˴�ע�����������ڵ� PlayerInfoScene  ����
	//CUIPet* pUIPet = PlayerInfoScene::QueryPetScene();
	//if (pUIPet) {
	///< �˴�ע�����������ڵ� CUIPet  ����
	//pUIPet->UpdateUI(pet->int_PET_ID);
	//}
}

void NDMapMgr::processCollection(NDTransData& kData)
{
	CloseProgressBar;
	int itemtype = 0;
	kData >> itemtype;
	Item *item = new Item(itemtype);
	stringstream ss;
	ss << NDCommonCString("GatheredTip") << " " << item->getItemName();
	//showDialog(string("system"), ss.str().c_str()); ///< showDialog��ʱ�Ҳ��� ����
	delete item;
}

void NDMapMgr::processPlayerLevelUp(NDTransData& kData)
{
	std::stringstream kMessageStream;
	kMessageStream << NDCommonCString("up") << "������";
	int nPlayerID = kData.ReadInt();
	kMessageStream << " " << NDCommonCString("up") << NDCommonCString("object")
			<< "��" << nPlayerID;
	int dwNewExp = kData.ReadInt();
	kMessageStream << " " << NDCommonCString("NewExpVal") << dwNewExp;
	int usNewLevel = kData.ReadShort();
	kMessageStream << " " << NDCommonCString("NewLev") << usNewLevel;
	int usAddPoint = kData.ReadShort();
	kMessageStream << " " << NDCommonCString("NewRestDian") << usAddPoint;

	NDPlayer& kRole = NDPlayer::defaultHero();
	if (nPlayerID == kRole.m_nID)
	{
		kRole.m_nExp = dwNewExp;
		kRole.m_nLevel = usNewLevel;
		kRole.m_nRestPoint = usAddPoint;

		kRole.m_bLevelUp = true;
		kRole.playerLevelUp();

//		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("UpTip")); ///< �����ŵ�Chat ����

		if (usNewLevel == 20)
		{
			//Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("UpTip20"));	///< �����ŵ�Chat ����
		}

	}
	else
	{	// �����������
		map_manualrole_it it = m_mapManualRole.begin();
		for (; it != m_mapManualRole.end(); it++)
		{
			NDManualRole& kPlayer = *(it->second);
			if (kPlayer.m_nID == nPlayerID)
			{
				kPlayer.m_nExp = dwNewExp;
				kPlayer.m_nLevel = usNewLevel;
				kPlayer.m_nRestPoint = usAddPoint;

				kPlayer.m_bLevelUp = true;
				NDPlayer & kPlayer = NDPlayer::defaultHero();
				if (kPlayer.GetParent()
						&& kPlayer.GetParent()->IsKindOfClass(
								RUNTIME_CLASS(GameScene)))
				{
					kPlayer.playerLevelUp();
				}

				break;
			}
		}
	}
}

void NDMapMgr::processGameQuit(NDTransData* pkData, int nLength)
{
	//BeatHeartMgrObj.Stop(); ///< �˴������ŵ� BeatHeart ����
	CloseProgressBar;

	quitGame();
	ScriptGlobalEvent::OnEvent (GE_LOGIN_GAME);
}

void NDMapMgr::processNPCInfo(NDTransData& kData)
{
	int iid = 0;
	kData >> iid;
	unsigned char _unuse = 0;
	unsigned char uctype = 0;
	kData >> _unuse >> uctype;

	int usLook = 0;
	kData >> usLook;
	kData >> _unuse;
	unsigned short col = 0, row = 0;
	kData >> col >> row;

	unsigned char btState = 0, btCamp = 0;
	kData >> btState >> btCamp;

	std::string strName = kData.ReadUnicodeString();
	std::string strData = kData.ReadUnicodeString();
	std::string strTalk = kData.ReadUnicodeString();

	DelNpc(iid);

	NDNpc* pkNPC = new NDNpc;
	pkNPC->m_nID = iid;
	pkNPC->m_nCol = col;
	pkNPC->m_nRow = row;
	pkNPC->m_nLook = usLook;
	pkNPC->SetName( strName );
	pkNPC->SetPosition( ConvertUtil::convertCellToDisplay( col, row ));
	pkNPC->SetCamp(CAMP_TYPE(btCamp));
	pkNPC->SetNpcState(NPC_STATE(btState));
	pkNPC->setData( strData );
	pkNPC->setTalk( strTalk );
	pkNPC->SetType(uctype);
	pkNPC->Initialization(usLook);
	pkNPC->initUnpassPoint();
	AddOneNPC(pkNPC);
}

void NDMapMgr::DelNpc(int nID)
{
	if (m_vNPC.empty())
	{
		return;
	}

	VEC_NPC::iterator it = m_vNPC.begin();
	for (; it != m_vNPC.end(); it++)
	{
		NDNpc* pkNPC = *it;

		if (pkNPC->m_nID != nID)
		{
			continue;
		}

		if (pkNPC->m_nID == NDPlayer::defaultHero().GetFocusNpcID())
		{
			NDPlayer::defaultHero().InvalidNPC();
		}

		//pkNPC->HandleNpcMask(false); ///< �˴������ŵϵ�NDNpc ����

		SAFE_DELETE_NODE(pkNPC->m_pkRidePet);

		SAFE_DELETE_NODE(pkNPC);

		m_vNPC.erase(it);
		break;
	}
}

void NDMapMgr::AddOneNPC(NDNpc* pkNpc)
{
	NDMapLayer* pkLayer = getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));

	if (!pkLayer || !pkNpc)
	{
		return;
	}

	for_vec(m_vNPC, VEC_NPC::iterator)
	{
		if (pkNpc->m_nID == (*it)->m_nID)
		{
			return;
		}
	}

	if (pkLayer->ContainChild(pkNpc))
	{
		return;
	}

	m_vNPC.push_back(pkNpc);
	//pkLayer->AddChild((NDNode*)pkNpc); ///< �˴���Ҫ�޸�Layer ����

	// ���
	if (pkNpc->GetRidePet())
	{
		pkNpc->GetRidePet()->stopMoving();

		pkNpc->GetRidePet()->SetPositionEx(pkNpc->GetPosition());
		pkNpc->GetRidePet()->SetCurrentAnimation(RIDEPET_STAND,
				pkNpc->m_bFaceRight);
		pkNpc->SetCurrentAnimation(MANUELROLE_RIDE_PET_STAND,
				pkNpc->m_bFaceRight);
	}

	//pkNpc->HandleNpcMask(true); ///< �˴������ŵϵ�NDNpc

	NDPlayer::defaultHero().UpdateFocus();
}

void NDMapMgr::processTalk(NDTransData& kData)
{
	/***
	 * �˺�����������Chat��GameRequstUI ������Ҫ�ŵϺ����������
	 */
// 	unsigned char _ucUnuse = 0;
// 	kData >> _ucUnuse;
// 	unsigned char pindao = 0;
// 	kData >> pindao;
// 	int _iUnuse = 0;
// 	kData >> _iUnuse;
// 	kData >> _ucUnuse;
// 	unsigned char amount = 0;
// 	kData >> amount;
// 
// 	std::string speaker;
// 	std::string text;
// 	for (int i = 0; i < amount; i++) 
// 	{
// 		std::string c = kData.ReadUnicodeString();
// 		if (i == 0) 
// 		{
// 			text = c;
// 		} else if (i == 1) 
// 		{
// 			speaker = c;
// 		}
// 		// msg.append("����" + c);
// 
// 	}
// 
// 	CloseProgressBar;
// 
// 	if (speaker.empty()) {// �ֶ���Ϊ0������û��Speaker��������
// 		return;
// 	}
// 
// 	if (NewChatScene::DefaultManager()->IsFilterBySpeaker(speaker.c_str())) {
// 		return;
// 	}
// 
// 	if (speaker == "SYSTEM" ) {
// 		speaker = NDCommonCString("system");
// 	}
	//ChatType chatType = GetChatTypeFromChannel(pindao); ///< �˴�����ChatType�����ŵϵ�GetChatTypeFromChannel ����
// 	if (chatType == ChatTypeWorld && !NDDataPersist::IsGameSettingOn(GS_SHOW_WORLD_CHAT)) 
// 	{
// 		return;
// 	}
// 	else if (chatType == ChatTypeArmy && !NDDataPersist::IsGameSettingOn(GS_SHOW_SYN_CHAT)) 
// 	{
// 		return;
// 	}
// 	else if (chatType == ChatTypeQueue && !NDDataPersist::IsGameSettingOn(GS_SHOW_TEAM_CHAT)) 
// 	{
// 		return;
// 	}
// 	else if (chatType == ChatTypeSection && !NDDataPersist::IsGameSettingOn(GS_SHOW_AREA_CHAT)) 
// 	{
// 		return;
// 	}	
// 
// 	if (chatType == ChatTypeSecret) 
// 	{
// 		std::string text(speaker);
// 		if (text != (NDPlayer::defaultHero().m_strName)) 
// 		{
// 			RequsetInfo info;
// 			info.set(0, NDCommonCString("YouHaveNewChat"), RequsetInfo::ACTION_NEWCHAT);
// 			NDMapMgrObj.addRequst(info);
// 		}
// 
// 	}
	//Chat::DefaultChat()->AddMessage(chatType, text.c_str(), speaker.c_str()); ///< �˴������ŵϵ� Chat ����
}

/***
 * ���������ڵ� RequsetInfo
 * ����
 */
// void NDMapMgr::addRequst( RequsetInfo& request )
// {
// 	std::stringstream strBuf;
// 	strBuf << NDCommonCString("YouHaveNew") << request.info << "," << NDCommonCString("OpenRequestList");
// 	//Chat::DefaultChat()->AddMessage(ChatTypeSystem, strBuf.str().c_str()); ///< �˴������ŵϵ�Chat ����
// 
// 	std::vector<RequsetInfo>::iterator it = m_vecRequest.begin();
// 	for (; it != m_vecRequest.end(); it++)
// 	{
// 		RequsetInfo& info = *it;
// 		if (info.iRoleID == request.iRoleID && info.iAction == request.iAction && (info.iAction != RequsetInfo::ACTION_NEWMAIL || info.iAction != RequsetInfo::ACTION_NEWCHAT))
// 		{
// 			DelRequest(info.iID);
// 			break;
// 		}
// 	}
// 	request.iID = m_idAlloc.GetID();
// 	m_vecRequest.push_back(request);
// 
// 	//NewGameUIRequest::refreshQuestList(); ///< �˴����������ڵ�NewGameUIRequest
// 
// 	NDScene* scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
// 	if (scene) 
// 	{
// 		GameScene* gamescene = (GameScene*)scene;
// 		gamescene->flashAniLayer(0, true);
// 
// 		NDNode *node = gamescene->GetChild(UILAYER_REQUEST_LIST_TAG);
// 		if (node && node->IsKindOfClass(RUNTIME_CLASS(GameUIRequest)))
// 		{
// 			///< �˴����������ڵ�GameUIRequest ����
// // 			GameUIRequest *request = (GameUIRequest*)node;
// // 			if (request->IsVisibled())
// // 			{
// // 				request->UpdateMainUI();
// // 			}
// 		}
// 	}
// }
/***
 * ���������ڵ� RequsetInfo
 * ����
 */
bool NDMapMgr::DelRequest(int nID)
{
// 	std::vector<RequsetInfo>::iterator it = m_vecRequest.begin();
// 	for(; it != m_vecRequest.end(); it++)
// 	{
// 		if (nID == (*it).iID)
// 		{
// 			m_idAlloc.ReturnID(nID);
// 			m_vecRequest.erase(it);
// 			return true;
// 		}
// 	}

	return false;
}

void NDMapMgr::processRehearse(NDTransData& kData)
{
	unsigned char btAction = 0;
	kData >> btAction;
	int idTarget = 0;
	kData >> idTarget;

	NDManualRole* role = GetManualRole(idTarget);
	//RequsetInfo info;	///< ����������RequsetInfo ����

	switch (btAction)
	{
	case REHEARSE_APPLY:
	{
		if (role != NULL)
		{
			//info.set(idTarget, role->m_strName, RequsetInfo::ACTION_BIWU);///< ����������RequsetInfo ����
			//addRequst(info);		///< ����������GameUIRequst ����
		}
		break;
	}
	case REHEARSE_REFUSE:
	{
		if (role != NULL)
		{
			std::stringstream ss;
			ss << role->GetName() << NDCommonCString("RejectRefraseTip");
			//Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str()); ///< �����ŵ�Chat ����
		}
		break;
	}
	case REHEARSE_LOGOUT:
	{
		BattleUILayer* battle = BattleMgrObj.GetBattle();
		if (battle)
		{
			battle->SetFighterOnline(idTarget, false);
		}
	}
		break;
	case REHEARSE_LOGIN:
	{
		BattleUILayer* battle = BattleMgrObj.GetBattle();
		if (battle)
		{
			battle->SetFighterOnline(idTarget, true);
		}
	}
		break;
	}
}

void NDMapMgr::processGoodFriend(NDTransData& kData)
{
	/***
	 * �˺������������ŵϵ�GoodFriendUILayer
	 * ����
	 */

// 	unsigned char action = 0; kData >> action;
// 	unsigned char friendCount = 0; kData >> friendCount;
// 
// 	RequsetInfo info;
// 	switch (action) {
// 			case _FRIEND_APPLY: {
// 				int iID = 0; kData >> iID;
// 				// TAMBGString
// 				std::string name = kData.ReadUnicodeString();
// 				info.set(iID, name, RequsetInfo::ACTION_FRIEND);
// 				addRequst(info);
// 				break;
// 								}
// 			case _FRIEND_ACCEPT: {
// 									 {
// 										 int idFriend = kData.ReadInt();
// 										 string name = kData.ReadUnicodeString();
// 
// 										 FriendElement& fe = m_mapFriend[idFriend];
// 										 fe.m_id = idFriend;
// 										 fe.m_text1 = name;
// 										 fe.SetState(ES_ONLINE);
// 
// 										 onlineNum++;
// 
// 										 GoodFriendUILayer::refreshScroll();
// 										 NewGoodFriendUILayer::refreshScroll();
// 
// 										 name += " "; name += NDCommonCString("BeFriendTip"); name += "��";
// 										 Chat::DefaultChat()->AddMessage(ChatTypeSystem, name.c_str());
// 									 }
// 									 break;
// 								 }
// 			case _FRIEND_ONLINE: {
// 									 {
// 										 int idFriend = kData.ReadInt();
// 
// 										 FriendElement& fe = m_mapFriend[idFriend];
// 										 fe.SetState(ES_ONLINE);
// 										 onlineNum++;
// 
// 										 string content = std::string("") + NDCommonCString("YourFriend") + " " + fe.m_text1 + " " + NDCommonCString("logined");
// 										 Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 
// 										 GoodFriendUILayer::refreshScroll();
// 										 NewGoodFriendUILayer::refreshScroll();
// 									 }
// 									 break;
// 								 }
// 			case _FRIEND_OFFLINE: {
// 									  {
// 										  int idFriend = kData.ReadInt();
// 
// 										  FriendElement& fe = m_mapFriend[idFriend];
// 										  fe.SetState(ES_OFFLINE);
// 										  onlineNum--;
// 
// 										  string content = std::string("") + NDCommonCString("YourFriend") + " " + fe.m_text1 + " " + NDCommonCString("OfflineTip");
// 										  Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 										  GoodFriendUILayer::refreshScroll();
// 										  NewGoodFriendUILayer::refreshScroll();
// 									  }
// 									  break;
// 								  }
// 			case _FRIEND_BREAK: {
// 									{
// 										int idFriend = kData.ReadInt();
// 										FriendElement& fe = m_mapFriend[idFriend];
// 
// 										string content = fe.m_text1 + " " + NDCommonCString("DeFriendTip");
// 										Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 
// 										onlineNum--;
// 
// 										m_mapFriend.erase(idFriend);
// 										GoodFriendUILayer::refreshScroll();
// 										NewGoodFriendUILayer::refreshScroll();
// 										NDUISynLayer::Close();
// 									}
// 									break;
// 								}
// 			case _FRIEND_GETINFO: {
// 									  {
// 										  m_mapFriend.clear();
// 										  onlineNum = 0;
// 
// 										  for (int i = 0; i < friendCount; i++) {
// 											  int idFriend = kData.ReadInt();
// 
// 											  Byte state = kData.ReadByte();
// 
// 											  string name = kData.ReadUnicodeString();
// 
// 											  FriendElement& fe = m_mapFriend[idFriend];
// 
// 											  fe.m_id = idFriend;
// 											  fe.m_text1 = name;
// 											  fe.SetState((ELEMENT_STATE(state)));
// 
// 											  if (state == ES_ONLINE) { // 0������״̬
// 												  onlineNum++;
// 											  }
// 
// 										  }
// 										  GoodFriendUILayer::refreshScroll();
// 										  NewGoodFriendUILayer::refreshScroll();
// 									  }
// 									  break;
// 								  }
// 			case _FRIEND_REFUSE: {
// 									 {
// 										 kData.ReadInt();
// 										 string name = kData.ReadUnicodeString();
// 
// 										 name += " "; name += NDCommonCString("RejectFriendTip");
// 										 Chat::DefaultChat()->AddMessage(ChatTypeSystem, name.c_str());
// 									 }
// 									 break;
// 								 }
// 			case _FRIEND_DELROLE: {
// 									  {
// 										  int idFriend = kData.ReadInt();
// 
// 										  FriendElement& fe = m_mapFriend[idFriend];
// 
// 										  if (fe.m_state == ES_ONLINE) {
// 											  onlineNum--;
// 										  }
// 
// 										  string content = fe.m_text1 + " " + NDCommonCString("DeFriendTip");
// 										  Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 
// 										  m_mapFriend.erase(idFriend);
// 
// 										  GoodFriendUILayer::refreshScroll();
// 										  NewGoodFriendUILayer::refreshScroll();
// 									  }
// 									  break;
// 								  }
// 	}
}

void NDMapMgr::processUserInfoSee(NDTransData& kData)
{
	std::deque < string > deqStrings;
	int targeId = kData.ReadInt();

	// �罻�õ������ݲɼ�
	SocialData social;
	social.iId = targeId;

	std::stringstream sb;
	int bSex = kData.ReadByte(); // 1��2Ů
	sb << NDCommonCString("sex") << "       " << NDCommonCString("bie") << ": ";
	if (bSex == USER_SEX_MALE)
	{
		social.sex = NDCommonCString("male");
		sb << NDCommonCString("male");
	}
	else
	{
		social.sex = NDCommonCString("female");
		sb << NDCommonCString("female");
	}
	deqStrings.push_back(sb.str());
	sb.str("");
	int bLevel = kData.ReadByte(); // �ȼ�
	sb << NDCommonCString("deng") << "       " << NDCommonCString("Ji") << ": "
			<< bLevel;
	deqStrings.push_back(sb.str());
	sb.str("");

	social.lvl = bLevel;
	kData.ReadByte();
	int iPkPoint = kData.ReadInt(); // PKֵ
	int iHornor = kData.ReadInt(); // ����ֵ

	sb << "PK" << "      " << NDCommonCString("val") << ": " << iPkPoint;
	deqStrings.push_back(sb.str());
	sb.str("");

	sb << NDCommonCString("HonurVal") << ": " << iHornor;
	deqStrings.push_back(sb.str());
	sb.str("");

	int bShow = kData.ReadByte(); // ָ���Ƿ��а���,��ż,��λȡ
	std::string name = kData.ReadUnicodeString(); // �������
	sb << NDCommonCString("PlayerXingMing") << ": " << name; // ��������
	deqStrings.push_front(sb.str());
	sb.str("");

	bool isHaveSyn = false; // �Ƿ��а���
	bool isMarry = false; // �Ƿ���
	for (int i = 0; i < 2; i++)
	{
		int a = bShow & 0x1;
		if (a == 1)
		{
			if (i == 0)
			{
				isHaveSyn = true;
			}
			else
			{
				isMarry = true;
			}
		}
		bShow = bShow >> 1;
	}
	if (isHaveSyn)
	{
		std::string synName = kData.ReadUnicodeString(); // ��������
		int bRank = kData.ReadByte(); // ���ɵȼ�
		sb << NDCommonCString("JunTuanName") << ": " << synName;
		deqStrings.push_back(sb.str());
		sb.str("");

		sb << NDCommonCString("JunTuanPost") << ": " << getRankStr(bRank);
		deqStrings.push_back(sb.str());
		sb.str("");

		social.SynName = synName;
		social.rank = getRankStr(bRank);
	}
	else
	{
		sb << NDCommonCString("jun") << "       " << NDCommonCString("tuan")
				<< ": " << NDCommonCString("wu");
		deqStrings.push_back(sb.str());
		sb.str("");
	}
	if (isMarry)
	{
		std::string marryName = kData.ReadUnicodeString(); // ��ż����
		sb << NDCommonCString("pei") << "       " << NDCommonCString("ou")
				<< ": " << marryName;
		deqStrings.push_back(sb.str());
		sb.str("");
	}
	else
	{
		sb << NDCommonCString("pei") << "       " << NDCommonCString("ou")
				<< ": " << NDCommonCString("wu");
		deqStrings.push_back(sb.str());
		sb.str("");
	}

	CloseProgressBar;
	//OtherPlayerInfoScene::showPlayerInfo(deqStrings); ///< ���������ڵ�OtherPlayerInfoScene ����

	/***
	 * �����ŵϵ� SynMbrListUILayer
	 * ����
	 */
// 	SynMbrListUILayer* mbrList = SynMbrListUILayer::GetCurInstance();
// 	if (mbrList) {
// 		mbrList->processSocialData(social);
// 	}
	//GlobalShowDlg("�����Ϣ", content.str());
}

void NDMapMgr::processFormula(NDTransData& kData)
{
	/***
	 * �Ҳ��� FormulaMaterialData
	 * ����
	 */
// 	int byStudyType = kData.ReadByte();//0���·���1��ѧϰ
// 	int btSkillCount = kData.ReadByte();
// 	for(int i = 0;i<btSkillCount;i++){
// 		int t_idFormula = kData.ReadInt();
// 		int t_lev = kData.ReadByte();
// 		int t_matID_1 = kData.ReadInt();
// 		int t_matCount_1 = kData.ReadByte();
// 		int t_matID_2 = kData.ReadInt();
// 		int t_matCount_2 = kData.ReadByte();
// 		int t_matID_3 = kData.ReadInt();
// 		int t_matCount_3 = kData.ReadByte();
// 		int t_producID = kData.ReadInt();
// 		int t_money = kData.ReadInt();
// 		int t_emoney = kData.ReadInt();
// 		// TODO: ����ͼ�������ֶ�
// 		int iconIndex = kData.ReadInt();
// 		std::string s_formulaName = kData.ReadUnicodeString();
// 		std::string strIconName = kData.ReadUnicodeString();
// 		FormulaMaterialData* t_formula = getFormulaData(t_idFormula);
// 		if(t_formula != NULL){
// 			t_formula->init(t_lev,t_matID_1,t_matCount_1,t_matID_2,t_matCount_2,t_matID_3,t_matCount_3,t_producID,t_money,t_emoney,iconIndex);
// 		}else{
// 			m_mapFomula.insert( map_fomula_pair(t_idFormula,
// 				new FormulaMaterialData(t_idFormula,t_lev,t_matID_1,t_matCount_1,t_matID_2,t_matCount_2,t_matID_3,t_matCount_3,t_producID,t_money,t_emoney,s_formulaName,iconIndex) ) 
// 				);
// 		}
// 		if(byStudyType == 1){//0���·���1��ѧϰ
// 			//					String formulaName = new Item(t_idFormula).getItemName();
// 			Item item(t_idFormula);
// 			std::stringstream ss; ss << NDCommonCString("Common_LearnedTip") << item.getItemName();
// 			GlobalShowDlg(NDCommonCString("OperateSucess"), ss.str());
// 		}
// 	}
	CloseProgressBar;
}

void NDMapMgr::processSyndicate(NDTransData& kData)
{
	int answer = kData.ReadByte();

	/***
	 * �˺�����������SynApproveUILayer
	 * �ŵϵ�
	 * ����
	 */

// 	switch (answer)
// 	{
// 	case ANS_SYN_PANEL_INFO:
// 		{
// 			SynInfoUILayer* infoLayer = SynInfoUILayer::GetCurInstance();
// 			if (infoLayer) {
// 				infoLayer->processSynInfo(kData);
// 			}
// 		}
// 		break;
// 	case ANS_REG_SYN_INFO:
// 	case ANS_SYN_LIST_INFO:
// 	case ANS_QUERY_VOTE_INFO:
// 		{
// 			CloseProgressBar;
// 			string t_wndTitle = kData.ReadUnicodeString();
// 			string t_wndDetail = kData.ReadUnicodeString();
// 
// 			SyndicateInfoScene* synInfoScene = new SyndicateInfoScene;
// 			synInfoScene->Initialization(t_wndTitle, t_wndDetail);
// 			NDDirector::DefaultDirector()->PushScene(synInfoScene);
// 			return;
// 		}
// 	case ANS_QUERY_OFFICER:
// 		{
// 			SynElectionUILayer* election = SynElectionUILayer::GetCurInstance();
// 			if (election) {
// 				election->processQueryOfficer(kData);
// 			}
// 			return;
// 		}
// 	case ANS_QUERY_VOTE_LIST:{// �·�ͶƱ�б�
// 		SynVoteUILayer* voteLayer = SynVoteUILayer::GetCurInstance();
// 		if (voteLayer) {
// 			voteLayer->processVoteList(kData);
// 		}
// 		return;
// 							 }
// 	case ANS_QUERY_SYN_STORAGE:{
// 		SynDonateUILayer* donate = SynDonateUILayer::GetCurInstance();
// 		if (donate) {
// 			donate->processSynDonate(kData);
// 		}
// 		return;
// 							   }
// 	case ANS_SYN_UPGRADE_INFO:{// ����������Ϣ
// 		SynUpgradeUILayer* upgrade = SynUpgradeUILayer::GetCurInstance();
// 		if (upgrade) {
// 			upgrade->processSynUpgrade(kData);
// 		}
// 		return;
// 							  }
// 	case APPROVE_ACCEPT_OK:
// 	case APPROVE_ACCEPT_FAIL:
// 	case APPROVE_REFUSE_OK: {
// 		CloseProgressBar;
// 		SynApproveUILayer* approve = SynApproveUILayer::GetCurInstance();
// 		if (approve) {
// 			approve->delCurSelCell();
// 		}
// 		break;
// 		}
// 	case ANS_UPDATE_SYN_MBR_RANK:
// 		NDPlayer::defaultHero().setSynRank(kData.ReadByte());
// 		return;
// 	case QUIT_SYN_OK:
// 		{
// 		NDPlayer& role = NDPlayer::defaultHero();
// 		role.synName = "";
// 		role.setSynRank(SYNRANK_NONE);
// 		return;
// 		}
// 	default:
// 		break;
// 	}
}

void NDMapMgr::processDigout(NDTransData& kData)
{
	int nItemID = kData.ReadInt();
	kData.ReadByte();
	int nNumber = kData.ReadByte();
	std::vector<int> kStoneItemTypes;
	for (int i = 0; i < nNumber; i++)
	{
		kStoneItemTypes.push_back(kData.ReadInt());
	}
	Item* pkItem = NULL;
	VEC_ITEM& kItemList = ItemMgrObj.GetPlayerBagItems();
	for (int i = 0; i < int(kItemList.size()); i++)
	{
		pkItem = kItemList[i];
		if (pkItem->m_nID == nItemID)
		{
			break;
		}
	}
	if (pkItem != NULL)
	{
		for (int i = 0; i < int(kStoneItemTypes.size()); i++)
		{
			for (int j = 0; j < int(pkItem->m_vStone.size()); j++)
			{
				Item* pkItemStone = pkItem->m_vStone[j];
				if (pkItemStone->m_nItemType == kStoneItemTypes[i])
				{
					pkItem->DelStone(pkItemStone->m_nID);
					break;
				}
			}
		}
	}
	//RemoveStoneScene::Refresh(); ///< ���������ڵ�RemoveStoneScene ����
	//showDialog(NDCommonCString("tip"), NDCommonCString("WaChuBaoShiSucc")); ///< showDialog��֪����˭��
}

void NDMapMgr::processNPC(NDTransData& kData)
{
	CloseProgressBar;
	int iid = kData.ReadInt(); // 4���ֽ� npc id
	int btAction = kData.ReadByte(); // 1���ֽ� �������ͣ�EVENT_DELNPC = 3;
	int btType = kData.ReadByte(); // 1���ֽ� NPC����

	if (btAction == 3)
	{ // ɾ��NPC
		DelNpc(iid);
	}
	else if (btAction == 10)
	{ // ������ʾ
		setNpcTaskStateById(iid, btType);
	}
}

void NDMapMgr::setNpcTaskStateById(int nNPCID, int nState)
{
	if (m_vNPC.empty())
	{
		return;
	}

	for (VEC_NPC::iterator it = m_vNPC.begin(); it != m_vNPC.end(); it++)
	{
		NDNpc* pkTempNPC = *it;

		if (pkTempNPC->m_nID != nNPCID)
		{
			continue;
		}

		pkTempNPC->SetNpcState(NPC_STATE(nState));
		break;
	}
}

void NDMapMgr::processSee(NDTransData& kData)
{
	CloseProgressBar;

	enum
	{
		SEE_USER_INFO = 0,	// �鿴�����Ϣ
		SEE_EQUIP_INFO = 1,	// �鿴���װ��
		SEE_PET_INFO = 2,	// ��ѯ������Ϣ
		SEE_USER_PET_INFO = 3,	// ��ѯ��ҳ�����Ϣ
		//��ѯ���
		SEE_OK = 4,	// ��ѯ�ɹ�
		SEE_FAIL = 5,	// ��ѯʧ��

		SEE_TUTOR_POS = 6,	// ��ѯ��ʦͽ��ϵ���˵�λ��,
		SEE_PET_INFO_OK = 7,
		SEE_USER_INFO_OK = 8,
	};

	int nAction = kData.ReadByte();	// action
	int nTargetID = kData.ReadInt();	// idtarget

	if (nAction == SEE_PET_INFO_OK)
	{
		// ��ѯ��ֻ����
		PetInfo* pkPetInfo = PetMgrObj.GetPet(nTargetID);
		if (pkPetInfo)
		{
			///< �����ŵϣ�ò���ǡ�������NewPetInfoScene ����
			//NDDirector::DefaultDirector()->PushScene(NewPetInfoScene::Scene(idTarget));
		}
	}
	else if (nAction == SEE_USER_INFO_OK)
	{
		///< ���������ڵ� OtherPlayerInfoScene ����
		//OtherPlayerInfoScene::ShowPlayerPet(idTarget);
	}
}

void NDMapMgr::processNpcPosition(NDTransData& kData)
{
	int npcId = kData.ReadInt();
	short col = kData.ReadShort();
	short row = kData.ReadShort();

	NDNpc *npc = GetNpc(npcId);
	if (npc != NULL)
	{
		//npc->AddWalkPoint(col, row); ///< �����ŵ� NDNpc
	}
}

NDNpc* NDMapMgr::GetNpc(int nID)
{
	for (VEC_NPC::iterator it = m_vNPC.begin(); it != m_vNPC.end(); it++)
	{
		NDNpc* pkTempNPC = *it;

		if (pkTempNPC->m_nID != nID)
		{
			continue;
		}

		return pkTempNPC;
	}

	return NULL;
}

void NDMapMgr::processItemTypeInfo(NDTransData& kData)
{
	int cnt = kData.ReadByte();

	for (int i = 0; i < cnt; i++)
	{
		NDItemType *itemtype = new NDItemType;
		itemtype->m_data.m_id = kData.ReadInt();
		itemtype->m_data.m_level = kData.ReadByte();
		itemtype->m_data.m_req_profession = kData.ReadInt();
		itemtype->m_data.m_req_level = kData.ReadShort();
		itemtype->m_data.m_req_sex = kData.ReadShort();
		itemtype->m_data.m_req_phy = kData.ReadShort();
		itemtype->m_data.m_req_dex = kData.ReadShort();
		itemtype->m_data.m_req_mag = kData.ReadShort();
		itemtype->m_data.m_req_def = kData.ReadShort();
		itemtype->m_data.m_price = kData.ReadInt();
		itemtype->m_data.m_emoney = kData.ReadInt();
		itemtype->m_data.m_save_time = kData.ReadInt();
		itemtype->m_data.m_life = kData.ReadShort();
		itemtype->m_data.m_mana = kData.ReadInt();
		itemtype->m_data.m_amount_limit = kData.ReadShort();
		itemtype->m_data.m_hard_hitrate = kData.ReadShort();
		itemtype->m_data.m_mana_limit = kData.ReadShort();
		itemtype->m_data.m_atk_point_add = kData.ReadShort();
		itemtype->m_data.m_def_point_add = kData.ReadShort();
		itemtype->m_data.m_mag_point_add = kData.ReadShort();
		itemtype->m_data.m_dex_point_add = kData.ReadShort();
		itemtype->m_data.m_atk = kData.ReadShort();
		itemtype->m_data.m_mag_atk = kData.ReadShort();
		itemtype->m_data.m_def = kData.ReadShort();
		itemtype->m_data.m_mag_def = kData.ReadShort();
		itemtype->m_data.m_hitrate = kData.ReadShort();
		itemtype->m_data.m_atk_speed = kData.ReadShort();
		itemtype->m_data.m_dodge = kData.ReadShort();
		itemtype->m_data.m_monopoly = kData.ReadShort();
		itemtype->m_data.m_lookface = kData.ReadInt();
		itemtype->m_data.m_iconIndex = kData.ReadInt();
		itemtype->m_data.m_holeNum = kData.ReadByte();
		itemtype->m_data.m_suitData = kData.ReadInt();
		itemtype->m_data.m_idUplev = kData.ReadInt();
		itemtype->m_data.m_enhancedId = kData.ReadInt();
		itemtype->m_data.m_enhancedStatus = kData.ReadInt();
		itemtype->m_data.m_recycle_time = kData.ReadInt();

		itemtype->m_name = kData.ReadUnicodeString();
		itemtype->m_des = kData.ReadUnicodeString();

		// ����Ϊ"��"�Ĳ���ʾ
		if (itemtype->m_des == NDCommonCString("wu"))
		{
			itemtype->m_des.clear();
		}
		// �Է����Ϊ׼,�洢������ڴ�����
		ItemMgrObj.ReplaceItemType(itemtype);
	}
}

void NDMapMgr::processCompetition(NDTransData& kData)
{
	/***
	 * �����ŵ� SocialElement
	 * ����
	 */

// 	CloseProgressBar;
// 	int act = kData.ReadByte();
// 	short curPage = kData.ReadShort();
// 	short allPage = kData.ReadShort();
// 	int amount =  kData.ReadByte();
// 	VEC_SOCIAL_ELEMENT roles;
// 	for (int i = 0; i < amount;) 
// 	{
// 		SocialElement *se = new SocialElement;
// 		se->m_id = kData.ReadInt();
// 		se->m_text1 = kData.ReadUnicodeString();
// 
// 		if (act == Competelist_VS) 
// 		{
// 			se->m_text2 = "VS";
// 			se->m_param = kData.ReadInt();
// 			se->m_text3 = kData.ReadUnicodeString();
// 		}
// 		else 
// 		{
// 			se->m_text2 = "   ";
// 		}
// 
// 
// 		roles.push_back(se);
// 
// 		act == Competelist_Joins ? i++ : i+=2;
// 	}
	//CompetelistUpdate(act, curPage, allPage, roles); ��䲻֪������� ����
}

void NDMapMgr::processReCharge(NDTransData& kData)
{
	int amount = kData.ReadShort();
	int isEnd = kData.ReadShort();
	for (int i = 0; i < amount; i++)
	{
		int b1 = kData.ReadInt();		// �˵�ID
		int b2 = kData.ReadByte();		// �˵�����
		std::string s = kData.ReadUnicodeString();		// ����
		int id2 = b1 % 100;

		/***
		 * �˴����������ڵ�NewRecharge
		 * ����
		 * begin
		 */
// 			if (id2 == 0) 
// 			{
// 				RechargeUI::s_data.push_back(NewRechargeData());
// 				NewRechargeData& kData = RechargeUI::s_data.back();
// 				kData.mainData = NewRechargeSubData(b1, b2, s);
// 			} 
// 			else 
// 			{
// 				if (!RechargeUI::s_data.empty())
// 				{
// 					NewRechargeData& kData = RechargeUI::s_data.back();
// 					NDAsssert(b2 == RechargeData_Tip 
// 							  || b2 == RechargeData_Card
// 							  || b2 == RechargeData_Message);
// 					switch (b2) {
// 						case RechargeData_Tip:
// 							kData.tipData = NewRechargeSubData(b1, b2, s);
// 							break;
// 						case RechargeData_Card:
// 						case RechargeData_Message:
// 							kData.vSubData.push_back(NewRechargeSubData(b1, b2, s));
// 							break;
// 						default:
// 							break;
// 					}
// 				}
// 			}
// 		}
		/***
		 * end
		 */

		/***
		 * �����ŵϵ�NewVipStoreScene
		 * ����
		 * begin
		 */
// 		if (isEnd == 1) 
// 		{
// 			CloseProgressBar;
// 			NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
// 			if (scene && scene->IsKindOfClass(RUNTIME_CLASS(NewVipStoreScene)))
// 			{
// 				NewVipStoreScene *vipscene = (NewVipStoreScene*)scene;
// 				
// 				vipscene->ShowRechare();
// 			}
// 		}
		/***
		 * end
		 */
	}

}

void NDMapMgr::processRechargeReturn(NDTransData& kData)
{
	/***
	 * ����������ɺ���ʵ��
	 * ����
	 */
}

void NDMapMgr::processVersionMsg(NDTransData& kData)
{
	CSMLoginScene* pkScene =
			(CSMLoginScene*) NDDirector::DefaultDirector()->GetSceneByTag(
					SMLOGINSCENE_TAG);
	if (pkScene)
	{
		return pkScene->OnMsg_ClientVersion(kData);
	}
}

void NDMapMgr::processActivity(NDTransData& kData)
{
	/***
	 * CustomActivity Ϊδ֪��
	 * ����
	 */
	CloseProgressBar;
	int nFlag = kData.ReadByte();
	int nAmount = kData.ReadByte();
	if (nFlag == 1)
	{
		//CustomActivity::ClearData();
	}
	for (int i = 0; i < nAmount; i++)
	{
		std::string str = kData.ReadUnicodeString();
		//CustomActivity::AddData(str);
	}
	if (nFlag == 2 || nFlag == 3)
	{
		//CustomActivity::refresh();
	}
}

void NDMapMgr::processDeleteRole(NDTransData& kData)
{
	CloseProgressBar;
	quitGame();
}

void NDMapMgr::processPortal(NDTransData& kData)
{
	///< ���ɱ���������Ϊֱ��return�� ����
	//CloseProgressBar;

	return;
}

void NDMapMgr::processMarriage(NDTransData& kData)
{
	/***
	 * ��ż�ġ�����Ϸ��û����ż����
	 * ����
	 */
}

void NDMapMgr::processShowTreasureHuntAward(NDTransData& kData)
{
	std::string strText = kData.ReadUnicodeString();
	GlobalShowDlg(NDCommonCString("XunBao"), strText.c_str());
}

void NDMapMgr::processRespondTreasureHuntProb(NDTransData& kData)
{
	CloseProgressBar;

	int huntLost = 0;
	int equipAdd = 0;
	int druation = 0;

	huntLost = kData.ReadByte();
	equipAdd = kData.ReadByte();
	druation = kData.ReadInt();

	///< �Ҳ���TreasureHuntScene ����
// 	TreasureHuntScene *scene = TreasureHuntScene::Scene();
// 	scene->SetRateInfo(huntLost, equipAdd, druation);
// 	NDDirector::DefaultDirector()->PushScene(scene);
}

void NDMapMgr::processRespondTreasureHuntInfo(NDTransData& kData)
{
	CloseProgressBar;
	//TreasureHuntScene::processHuntDesc(kData); ///< �Ҳ���  ����
}

void NDMapMgr::processKickOutTip(NDTransData& kData)
{
	CloseProgressBar;
	std::string strTip = kData.ReadUnicodeString();

	GameQuitDialog::DefaultShow(NDCommonCString("tip"), strTip.c_str(), 5.0f,
			true);
}

void NDMapMgr::processQueryPetSkill(NDTransData& kData)
{
	///< ���������ڵ� NewPetScene ����
// 	CUIPet* pUIPet	= PlayerInfoScene::QueryPetScene();
// 	if (pUIPet) {
// 		OBJID idItem	= kData.ReadInt();
// 		std::string	str	= kData.ReadUnicodeString();
// 		pUIPet->UpdateSkillItemDesc(idItem, str);
// 	}
}

void NDMapMgr::processRoadBlock(NDTransData& kData)
{
	int nX = kData.ReadInt();
	int nY = kData.ReadInt();
	unsigned int uiTime = kData.ReadInt();

	NDScene* pkScene = NDDirector::DefaultDirector()->GetScene(
			RUNTIME_CLASS(CSMGameScene));

	if (!pkScene)
	{
		return;
	}

	NDMapLayer* pkLayer = getMapLayerOfScene(pkScene);

	if (!pkLayer)
	{
		return;
	}

	pkLayer->setStartRoadBlockTimer(uiTime, nX, nY);
}

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
void  NDMapMgr::VerifierError(MBGError *error)
{
    NSLog(@"VerifierError:%d,%s", [error code], [error description] );
}

void  NDMapMgr::CloseTransaction()
{
    int idAccount = NDBeforeGameMgrObj.GetCurrentUser();
    if(idAccount <= 0)
        return;
    NSString* transactionId = NDBeforeGameMgrObj.GetCurrentTransactionID();
    if (transactionId == nil)
        return;
    const char* strTransactionID = [transactionId UTF8String];
    const unsigned char* szUnSignedTransactionID = (const unsigned char*)strTransactionID;
    NDTransData bao(_MSG_CLOSE_TRANSACTION);
    bao << idAccount;
    bao.Write(szUnSignedTransactionID, strlen(strTransactionID));
    SEND_DATA(bao);
    CloseProgressBar;
}

void  NDMapMgr::CancelTransaction()
{
    NSString* transactionId = NDBeforeGameMgrObj.GetCurrentTransactionID();
    if (transactionId == nil)
        return;
    
    [MBGBankDebit cancelTransaction:transactionId onSuccess:^(MBGTransaction *transaction) {
    } onError:^(MBGError *error) {
    }];
}

void  NDMapMgr::TransactionError(MBGError *error)
{
    NSLog(@"TransactionError:%d,%s", [error code], [error description] );
    CancelTransaction();
}
#endif


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void  NDMapMgr::CloseTransaction()
{
    int idAccount = NDBeforeGameMgrObj.GetCurrentUser();
	int iPayType = NDBeforeGameMgrObj.GetPayType();
    if(idAccount <= 0)
        return;
    std::string transactionId = NDBeforeGameMgrObj.GetCurrentTransactionID();
    if (transactionId.empty())
        return;
    const char* strTransactionID = transactionId.c_str();
    const unsigned char* szUnSignedTransactionID = (const unsigned char*)strTransactionID;
    NDTransData bao(_MSG_CLOSE_TRANSACTION);
    bao << idAccount;
    bao.Write(szUnSignedTransactionID, 37);
	bao << iPayType;
    SEND_DATA(bao);

	NDLog("SEND_DATA1196 idAccount = %d, iPayType = %d", idAccount, iPayType);
    CloseProgressBar;
}

void  NDMapMgr::CancelTransaction()
{
    std::string transactionId = NDBeforeGameMgrObj.GetCurrentTransactionID();
    if (transactionId.empty())
        return;
    
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/SocialUtils"
                                       , "cancelTransaction"
                                       , "(Ljava/lang/String;)V"))
        
    {
        jstring stringArg = t.env->NewStringUTF(transactionId.c_str());
        
        t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg);
        t.env->DeleteLocalRef(stringArg);
        t.env->DeleteLocalRef(t.classID);
    }
}

void NDMapMgr::ProcessJavaonCancelTransactionSuccess(std::string transid)
{
    NDLog(@"onCancelTransactionSuccessr:%s", transid.c_str());
}

void NDMapMgr::ProcessJavaonCancelTransactionError(std::string error)
{
    NDLog(@"onCancelTransactionError:%s", error.c_str());
}
#endif

void NDMapMgr::ProcessTempCredential(NDTransData& kData)
{
	///< ��������ע�͵� ����
// 	NSString temporaryCredential = kData.ReadUTF8NString();
// 	if(temporaryCredential == nil) return;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSString* temporaryCredential = kData.ReadUTF8NString();
    if(temporaryCredential == nil) return;
	[MBGSocialAuth authorizeToken:temporaryCredential onSuccess:^(NSString *verifier)
	{
		sendVerifier(verifier);
	}onError:^(MBGError *error)
	{
		VerifierError(error);
	}];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    std::string temporaryCredential = kData.ReadUTF8StdString();
    if(temporaryCredential.empty()) return;
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/SocialUtils"
                                       , "authorizeToken"
                                       , "(Ljava/lang/String;)V"))
        
    {
		jstring stringArg = t.env->NewStringUTF(temporaryCredential.c_str());
        
        t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg);
        t.env->DeleteLocalRef(stringArg);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void NDMapMgr::ProcessJavaonAuthSuccess(std::string verifier)
{
    sendVerifier(verifier);
}

void NDMapMgr::ProcessJavaonAuthError(std::string error)
{
    NDLog(@"onAuthError:%s", error.c_str() );
}
#endif


void  NDMapMgr::ProcessOAuthTokenRet(NDTransData& data)
{
    NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
    mgr.SetOAuthTokenOK();
}

void  NDMapMgr::ProcessCreateTransactionRet(NDTransData& data)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSString* transactionId = data.ReadUTF8NString();
    if (transactionId == nil)
        return;
    
    NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
    mgr.SetCurrentTransactionID(transactionId);
    CloseProgressBar;
    
    [MBGBankDebit continueTransaction:transactionId onSuccess:^(MBGTransaction *transaction) {
        CloseTransaction();
    } onCancel:^{
        CancelTransaction();
        
    } onError:^(MBGError *error) {
        TransactionError(error);
    }];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    std::string transactionId = data.ReadUTF8StdString();
    if (transactionId.empty())
        return;
    
    NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
    mgr.SetCurrentTransactionID(transactionId);
    CloseProgressBar;
    
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/SocialUtils"
                                       , "continueTransaction"
                                       , "(Ljava/lang/String;)V"))
        
    {
        jstring stringArg = t.env->NewStringUTF(transactionId.c_str());
        
        t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg);
        t.env->DeleteLocalRef(stringArg);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void NDMapMgr::ProcessJavaonContinueTransactionSuccess(std::string transid)
{
    NDLog(@"onContinueTransactionSuccessr:%s", transid.c_str());
    CloseTransaction();
}

void NDMapMgr::ProcessJavaonContinueTransactionError(std::string error)
{
    NDLog(@"onContinueTransactionError:%s", error.c_str());
    CancelTransaction();
}

void NDMapMgr::ProcessJavaonContinueTransactionCancel()
{
    NDLog(@"onContinueTransactionCancel");
    CancelTransaction();
}
#endif

void  NDMapMgr::ProcessCloseTransactionRet(NDTransData& data)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    //to do add EMoney
    MobageViewController* pMobageView = [MobageViewController sharedViewController];
    [pMobageView showBalanceButton:CGRectMake(200, 70, 100, 36)];
    ScriptMgrObj.excuteLuaFunc( "HandleNetMsg", "Agiotage", 0 );
#endif
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       , "org/DeNA/DHLJ/DaHuaLongJiang"
                                       , "showBalanceButton"
                                       , "()V"))
        
    {
        t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
    
    ScriptMgrObj.excuteLuaFunc( "HandleNetMsg", "Agiotage", 0 );
#endif
}

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
void  NDMapMgr::sendVerifier(NSString *verifier)
{
    int idAccount = NDBeforeGameMgrObj.GetCurrentUser();
    if(idAccount <= 0)
        return;
    
    const char* szVerifier = [verifier UTF8String];
    const unsigned char* szUnSignedVerifier = (const unsigned char*)szVerifier;
    
    NDTransData bao(_MSG_REQUEST_ACCESS_TOKEN);
    bao << idAccount;
    bao.Write(szUnSignedVerifier, strlen(szVerifier));

    SEND_DATA(bao);
}
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
void  NDMapMgr::sendVerifier(std::string verifier)
{
	char strVer[66] = {0};
	CCLog("SEND_DATA1192 sendVerifier");
    int idAccount = NDBeforeGameMgrObj.GetCurrentUser();
	CCLog("SEND_DATA1192 sendVerifier idAccount = %d", idAccount);
	int iPayType = NDBeforeGameMgrObj.GetPayType();
	CCLog("SEND_DATA1192 sendVerifier iPayType = %d", iPayType);
    if(idAccount <= 0)
        return;
    
    const char* szVerifier = verifier.c_str();
    const unsigned char* szUnSignedVerifier = (const unsigned char*)szVerifier;
    //strcpy(strVer, szVerifier);

    NDTransData bao(_MSG_REQUEST_ACCESS_TOKEN);
    bao << idAccount;
    bao.Write(szUnSignedVerifier, sizeof(strVer));
	bao << iPayType;

 //CCLog("SEND_DATA1192 szUnSignedVerifier = %s, szVerifier = %d", szUnSignedVerifier, strlen(szVerifier));
	CCLog("SEND_DATA1192 idAccount = %d, iPayType = %d", idAccount, iPayType);
    SEND_DATA(bao);
}
#endif

NDMonster* NDMapMgr::GetBoss()
{
	vec_monster_it it = m_vMonster.begin();
	for (; it != m_vMonster.end(); it++)
	{
		NDMonster *pkMonster = *it;
		if (pkMonster && pkMonster->GetType() == MONSTER_BOSS
				&& pkMonster->getState() != MONSTER_STATE_DEAD)
		{
			return pkMonster;
		}
	}
	return NULL;
}

NDManualRole* NDMapMgr::NearestDacoityManualrole(NDManualRole& role, int iDis)
{
	int minDist = iDis;

	NDManualRole * resrole = NULL;

	map_manualrole_it it = m_mapManualRole.begin();
	for (; it != m_mapManualRole.end(); it++)
	{
		NDManualRole* manualrole = it->second;

		if (role.m_nID == manualrole->m_nID)
			continue;

		if (!manualrole->IsInDacoity())
			continue;

		if (manualrole->IsInState(USERSTATE_FIGHTING)
				|| manualrole->IsInState(USERSTATE_DEAD)
				|| manualrole->IsInState(USERSTATE_PVE))
		{
			continue;
		}

		if (!(role.IsInState(USERSTATE_BATTLE_POSITIVE)
				&& manualrole->IsInState(USERSTATE_BATTLE_NEGATIVE)
				|| role.IsInState(USERSTATE_BATTLE_NEGATIVE)
						&& manualrole->IsInState(USERSTATE_BATTLE_POSITIVE)))
			continue;

		int dis = getDistBetweenRole(manualrole, &role);

		if (dis <= minDist)
		{
			resrole = manualrole;
			minDist = dis;
		}
	}

	return resrole;
}

NDManualRole* NDMapMgr::NearestBattleFieldManualrole(NDManualRole& role,
		int iDis)
{
	int minDist = iDis;

	NDManualRole * resrole = NULL;

	map_manualrole_it it = m_mapManualRole.begin();
	for (; it != m_mapManualRole.end(); it++)
	{
		NDManualRole* manualrole = it->second;

		if (role.m_nID == manualrole->m_nID)
			continue;

		if (!manualrole->IsInState(USERSTATE_BATTLEFIELD))
		{
			continue;
		}

		if (manualrole->IsInState(USERSTATE_BF_WAIT_RELIVE))
		{
			continue;
		}

		if (manualrole->IsInState(USERSTATE_FIGHTING)
				|| manualrole->IsInState(USERSTATE_DEAD))
		{
			continue;
		}

		if (manualrole->m_eCamp == role.m_eCamp)
		{
			continue;
		}

		int dis = getDistBetweenRole(manualrole, &role);

		if (dis <= minDist)
		{
			resrole = manualrole;
			minDist = dis;
		}
	}

	return resrole;
}

int NDMapMgr::getDistBetweenRole(NDBaseRole *firstrole, NDBaseRole *secondrole)
{
	if (!firstrole || !secondrole)
	{
		return FOCUS_JUDGE_DISTANCE;
	}

	CCPoint firstCell  = ConvertUtil::convertDisplayToCell( firstrole->GetPosition() );
	CCPoint secondCell = ConvertUtil::convertDisplayToCell( secondrole->GetPosition() );
	int w = firstCell.x - secondCell.x;
	int h = firstCell.y - secondCell.y;
	return w * w + h * h;
}

void NDMapMgr::BattleStart()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
	if (scene) 
	{
		/***
		 * �ȴ��ŵϵ� DirectKey
		 * ����
		 */
		//DirectKey* dk = ((GameScene*)scene)->GetDirectKey();
		//if (dk) 
		//{
		//	dk->OnButtonUp(NULL);
		//}
	}

	NDPlayer::defaultHero().BattleStart();
}

NDBaseRole* NDMapMgr::GetNextTarget(int iDistance)
{
	NDPlayer* pkPlayer = &NDPlayer::defaultHero();

	NDBaseRole * resrole = NULL;

	if (!pkPlayer)
	{
		return resrole;
	}

	if (pkPlayer->m_nTargetIndex >= int(m_vNPC.size() + m_mapManualRole.size()))
	{
		pkPlayer->m_nTargetIndex = 0;
	}

	if (pkPlayer->m_nTargetIndex < int(m_vNPC.size()))
	{
		VEC_NPC::iterator it = m_vNPC.begin() + pkPlayer->m_nTargetIndex;
		for (; it != m_vNPC.end(); it++)
		{
			pkPlayer->m_nTargetIndex++;
			NDNpc* npc = *it;

			if (npc->m_nID == pkPlayer->GetFocusNpcID())
			{
				continue;
			}

			int dis = getDistBetweenRole(pkPlayer, npc);
			if (dis < iDistance)
			{
				resrole = npc;
				return resrole;
			}
		}
	}

	int iIndexManuRole = pkPlayer->m_nTargetIndex - m_vNPC.size();

	if (iIndexManuRole < 0)
	{
		iIndexManuRole = 0;
	}

	if (iIndexManuRole < (int) m_mapManualRole.size())
	{
		map_manualrole_it it = m_mapManualRole.begin();
		for (int i = 0; i < iIndexManuRole; i++)
		{
			it++;
		}

		for (; it != m_mapManualRole.end(); it++)
		{
			pkPlayer->m_nTargetIndex++;

			NDManualRole *otherplayer = it->second;

			if (otherplayer->m_nID == pkPlayer->m_iFocusManuRoleID)
			{
				continue;
			}

			int dis = getDistBetweenRole(pkPlayer, otherplayer);
			if (dis < iDistance)
			{
				resrole = otherplayer;
				return resrole;
			}
		}
	}

	return resrole;
}

NDBaseRole* NDMapMgr::GetRoleNearstPlayer(int iDistance)
{
	int minDist = iDistance;

	NDPlayer *player = &NDPlayer::defaultHero();

	NDBaseRole * resrole = NULL;

	if (!player)
	{
		return resrole;
	}

	do
	{
		VEC_NPC::iterator it = m_vNPC.begin();
		for (; it != m_vNPC.end(); it++)
		{
			NDNpc *npc = *it;
			int dis = getDistBetweenRole(player, npc);
			if (dis < minDist)
			{
				resrole = npc;
				minDist = dis;
			}
		}

		if(resrole)
		{
			player->m_nTargetIndex = 0;

			//npc�ڸ����򷵻�
			return resrole;
		}

	} while (0);

	do
	{
		map_manualrole_it it = m_mapManualRole.begin();
		for (; it != m_mapManualRole.end(); it++)
		{
			NDManualRole *otherplayer = it->second;

			if (player->m_nTeamID != 0
					&& player->m_nTeamID == otherplayer->m_nTeamID)
			{
				continue;
			}

			int dis = getDistBetweenRole(player, otherplayer);
			if (dis < minDist)
			{
				resrole = otherplayer;
				minDist = dis;
			}
		}
	} while (0);

	return resrole;
}

void NDMapMgr::throughMap(int mapX, int mapY, int mapId)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene) 
	{
		return;
	}

//	NDDirector::DefaultDirector()->PushScene(GameSceneLoading::Scene());	

	NDPlayer& player = NDPlayer::defaultHero();
	NDTransData bao(_MSG_POSITION);
	bao << player.m_nID << (unsigned short)mapX << (unsigned short)mapY
		<< mapId << (unsigned short)_POSITION_TRANS_FLY << int(0);
	SEND_DATA(bao);
}

void NDMapMgr::NavigateTo(int mapX, int mapY, int mapId)
{
	if (GetMapID() == mapId)
	{
		if(NDPlayer::defaultHero().CanSwitch(mapX, mapY))
		{
			AutoPathTipObj.work("");
			NDPlayer::defaultHero().OnMoveEnd();
			return;
		}
		NDPlayer::defaultHero().Walk(CCPointMake(mapX * MAP_UNITSIZE_X, mapY * MAP_UNITSIZE_Y), SpriteSpeedStep4, true);
		AutoPathTipObj.work("");
		return;
	}

	throughMap(mapX, mapY, mapId);
}

void NDMapMgr::NavigateToNpc(int nNpcId)
{
	NDNpc* pkNPC = GetNpcByID(nNpcId);

	if (!pkNPC)
	{
		return;
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();

	CCPoint kDstPoint = 
		ConvertUtil::convertCellToDisplay( pkNPC->m_nCol, pkNPC->m_nRow );

	NDPlayer& player = NDPlayer::defaultHero();

	CCPoint disPos = ccpSub(kDstPoint, player.GetPosition());

	if (abs(int(disPos.x)) <= 32 && abs(int(disPos.y)) <= 32)
	{
		if (pkNPC && pkNPC->GetType() != 6)
		{
			player.SendNpcInteractionMessage(pkNPC->m_nID);
		}
	}
	else
	{
		AutoPathTipObj.work(pkNPC->GetName());
		player.Walk(kDstPoint, SpriteSpeedStep4, true);
	}

	return;
}

std::vector<NDManualRole*> NDMapMgr::GetPlayerTeamList()
{
	std::vector<NDManualRole*> k;
	return k;
}

void NDMapMgr::ClearNPCChat()
{
	usData = -1;
	strLeaveMsg.clear();
	strTitle.clear();
	strNPCText.clear();
	vecNPCOPText.clear();
	m_iCurDlgNpcID = 0;
}

void NDMapMgr::processMsgDlg(NDTransData& kData)
{
	int npcID = kData.ReadInt();

	usData = kData.ReadShort();

	Byte iDx = kData.ReadByte();

	Byte ucAction = kData.ReadByte();
	string str;

	// ��ֹ��Ϣ��ʱ���ã���������
	if (BattleMgrObj.GetBattle() != NULL)
	{
		return;
	}

	NDPlayer& player = NDPlayer::defaultHero();
	switch (ucAction)
	{
	case MSGDIALOG_LEAVE:
	{
		strLeaveMsg = kData.ReadUnicodeString();
		break;
	}
	case MSGDIALOG_TITLE:
	{
		strTitle = kData.ReadUnicodeString();
		break;
	}
	case MSGDIALOG_TEXT:
	{ // TEXT �ı���Ϣ����
		if (usData == TEXT_TEXT)
		{
			str = kData.ReadUnicodeString();
			strNPCText += str;
		}
		break;
	}
	case MSGDIALOG_LINK:
	{ // ѡ�����ʽ //��
		if (usData == TEXT_TEXT)
		{
			str = kData.ReadUnicodeString();
			str = changeToChineseSign(str);
			st_npc_op op;
			op.idx = iDx;
			op.str = str;
			vecNPCOPText.push_back(op);
		}

		break;
	}
	case MSGDIALOG_NO_TALK:
	{
		NDUISynLayer::Close (CLOSE);
		break;
	}
	case MSGDIALOG_DLG:
	{ // �Ի�����ʽ
		if (usData == TEXT_TEXT)
		{
			str = kData.ReadUnicodeString();
			str = changeNpcString(str);

			//NDUIDialog *dlg = new NDUIDialog;
			//					dlg->Initialization();
			std::string title = "";
			if (strTitle.empty())
			{
				NDNpc *focusNpc = player.GetFocusNpc();
				if (focusNpc)
				{
					title = focusNpc->GetName();
				}
			}

			//dlg->Show(title.c_str(), str.c_str(), "", NULL);
			GlobalDialogObj.Show(NULL, title.c_str(), str.c_str(), 0, NULL);
			CloseProgressBar;
		}

		break;
	}
	case MSGDIALOG_USER_OPEN_DLG:
	{
		switch (usData)
		{
		case 1:
		{ // ���̵����
			NDNpc *npc = player.GetFocusNpc();
			if (!npc)
			{
				CloseProgressBar;
				return;
			}

			CloseProgressBar;

			int npcCamp = npc->GetCamp();
			if (npcCamp - 1 >= 0 && npcCamp - 1 < 7)
			{
				int discount = getDiscount(m_nCampType[npcCamp - 1]);
				if (discount != 100)
				{
					std::stringstream ss;
					ss << NDCommonCString("ShopEnjoy") << discount << "%"
							<< NDCommonCString("discount");
					//showDialog(NDCommonCString("tip"), ss.str().c_str());	///< ��ʱû�ҵ�showDialog ����
				}
			}

			map_npc_store_it it = m_mapNpcStore.find(npc->m_nID);
			if (it == m_mapNpcStore.end())
			{
				NDTransData bao(_MSG_SHOPINFO);
				bao << int(npc->m_nID) << (unsigned char) 0;
				NDSocket* skt = NDDataTransThread::DefaultThread()->GetSocket();
				if (skt)
				{
					skt->Send(&bao);
				}
				ShowProgressBar;
			}
			else
			{
// 							GameUINpcStore::GenerateNpcItems(npc->m_nID); ///< ������ŵϵ� ����
// 							GameScene::ShowShop();
			}

			break;
		}
		case 2:
		case 3:
		{ // ��װ������
		  //T.addDialog(new EquipUIScreen(EquipUIScreen.SHOW_EQUIP_NORMAL));
			break;
		}
		case 4:
		{ // �򿪲ֿ�
			if (!player.GetFocusNpc())
			{
				break;
			}
			CloseProgressBar;
			int iNPCID = player.GetFocusNpcID();
			if (ItemMgrObj.GetStorage().empty())
			{
				NDTransData bao(_MSG_ITEMKEEPER);
				bao << int(0) << (unsigned char) MSG_STORAGE_ITEM_QUERY
						<< iNPCID;
				SEND_DATA(bao);
				ShowProgressBar;
			}
			else
			{
				//NDDirector::DefaultDirector()->PushScene(GameStorageScene::Scene()); ///< �ŵϵ� ����
			}
			break;
		}
		case 5:
		{ // todo ��ʱû�� �������

			CloseProgressBar;

			break;
		}
		case 6:
		{ // ����
			break;
		}
		case 7:
		{ // ����
		  //CreateSynDialog::Show(); ///< ò�Ʒ��� ����
			break;
		}
		case 8:
		{
			int idCurNpc = 0;
			if (player.IsFocusNpcValid())
			{
				idCurNpc = player.GetFocusNpcID();
			}

			if (idCurNpc == 0)
			{
				return;
			}

			MAP_NPC_SKILL_STORE_IT it = m_mapNpcSkillStore.find(idCurNpc);

			if (it == m_mapNpcSkillStore.end())
			{ // û�д棬������
				NDTransData bao(_MSG_MAGIC_GOODS);
				bao << idCurNpc;
				SEND_DATA(bao);
				ShowProgressBar;
			}
			else
			{
				//LearnSkillUILayer::Show(it->second); ///< ��ʱ��Ū ����
			}
			break;
		}
		case 9:
		{ // װ������
			CloseProgressBar;
			//NDDirector::DefaultDirector()->PushScene(NewEquipRepairScene::Scene()); ///< û��װ������ ����
			break;
		}
		case 11:
		{ // װ��Ʒ������
// 						CloseProgressBar;
// 						EquipUpgradeScene *scene = new EquipUpgradeScene;
// 						scene->Initialization(EQUIP_UPGRADE);
// 						NDDirector::DefaultDirector()->PushScene(scene);
			break;
		}
		case 12:
		{ // װ������
// 						CloseProgressBar;
// 						NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
// 						if (runningScene && runningScene->IsKindOfClass(RUNTIME_CLASS(EquipForgeScene))) {
// 							return;
// 						} else {
// 							///< ��ʱ����Ҫ ����
// // 							EquipForgeScene *scene = new EquipForgeScene;
// // 							scene->Initialization();
// // 							NDDirector::DefaultDirector()->PushScene(scene);
// 						}
// 						break;
		}
		case 13:
		{ // ��ʯժ��
		  //T.addDialog(new RemoveStone());
// 						CloseProgressBar;
// 						RemoveStoneScene *scene = new RemoveStoneScene;
// 						scene->Initialization();
// 						NDDirector::DefaultDirector()->PushScene(scene);
// 						break;
		}
		case 14:
		{ // װ������
// 						CloseProgressBar;
// 						OpenHoleScene *scene = new OpenHoleScene;
// 						scene->Initialization();
// 						NDDirector::DefaultDirector()->PushScene(scene);
			break;
		}
		case 15:
		{ // ��ȡ���
// 						NDUICustomView *view = new NDUICustomView;
// 						view->Initialization();
// 						view->SetDelegate(this);
// 						std::vector<int> vec_id; vec_id.push_back(1);
// 						std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("InputSeq"));
// 						view->SetEdit(1, vec_id, vec_str);
// 						view->SetTag(eCVOP_GiftNPC);
// 						view->Show();
// 						NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
// 						if (scene)
// 						{
// 							scene->AddChild(view);
// 						}
// 						CloseProgressBar;					
			break;
		}
		case 16:
		{ // 16�����ҩ��17���䷽��ҩ��18����ϳɣ�19���䷽�ϳ�
// 						CloseProgressBar;
// 						LifeSkillRandomScene *scene = new LifeSkillRandomScene;
// 						scene->Initialization(eChaoYao);
// 						NDDirector::DefaultDirector()->PushScene(scene);
// 						break;
		}
		case 17:
		{
			break;
		}
		case 18:
		{
			break;
		}
		case 19:
		{ //19���䷽�ϳ�
// 						CloseProgressBar;
// 						if ( getLifeSkill(GEM_IDSKILL) != NULL )
// 						{
// 							LifeSkillScene *scene = new LifeSkillScene;
// 							scene->Initialization(GEM_IDSKILL, LifeSkillScene_Product);
// 							NDDirector::DefaultDirector()->PushScene(scene);
// 						}
// 						else 
// 						{
// 							GlobalShowDlg(NDCommonCString("OperateFail"), NDCommonCString("NoBaoShiSkillTip"));
// 						}
			break;
		}
		case 20:
			//		ForgetSkillUILayer::Show();
			break;
		case 21: // ��Ը��
		{
// 						NDUICustomView *view = new NDUICustomView;
// 						view->Initialization();
// 						view->SetDelegate(this);
// 						std::vector<int> vec_id; vec_id.push_back(1);
// 						std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("InputWishTip"));
// 						view->SetEdit(1, vec_id, vec_str);
// 						view->SetTag(eCVOP_Wish);
// 						view->Show();
// 						NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
// 						if (scene)
// 						{
// 							scene->AddChild(view);
// 						}
			CloseProgressBar;
		}

			break;
		case 22: // ��Ը��
		{
// 						NDUICustomView *view = new NDUICustomView;
// 						view->Initialization();
// 						view->SetDelegate(this);
// 						std::vector<int> vec_id; vec_id.push_back(1);
// 						std::vector<std::string> vec_str; vec_str.push_back(std::string("") + NDCommonCString("InputWishTip") + "\n" + NDCommonCString("ModifyWishTip"));
// 						view->SetEdit(1, vec_id, vec_str);
// 						view->SetEditMaxLength(40, 0);
// 						view->SetTag(eCVOP_Wish);
// 						view->Show();
// 						NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
// 						if (scene)
// 						{
// 							scene->AddChild(view);
// 						}
			CloseProgressBar;
		}
			break;
		case 23: //�򿪼��ܺϳɽ���
		{
			CloseProgressBar;
		}
			break;
		case 24: // ��ֲ
		{
			CloseProgressBar;
			//showUseItemUI(npcID, 0);
		}
			break;
		case 25: // ����
		{
			CloseProgressBar;
			//showUseItemUI(npcID, 1);
		}
			break;
		case 26: // ʩ��
		{
			CloseProgressBar;
			//showUseItemUI(npcID, 2);
		}
			break;
		case 27: // ι����
		{
			CloseProgressBar;
			//	showUseItemUI(npcID, 3);
		}
			break;
		case 28: //ׯ԰����
		{
			CloseProgressBar;
			//ShowView(this, NDCommonCString("FarmRename"), eCVOP_FarmName, 15); ///< ��ʱ�Ҳ���ShowView ����

		}
			break;
		case 29: //ׯ԰��ӭ��
		{
			CloseProgressBar;
			//	ShowView(this, NDCommonCString("ModifyWelcome"), eCVOP_FarmWelcomeName, 64);

		}
			break;
		case 30: //��������
		{
			CloseProgressBar;
			//	showUseItemUI(npcID, 4);
		}
			break;
		case 31: //��������
		{
			CloseProgressBar;
			//	ShowView(this, NDCommonCString("ModifyBuildingName"), eCVOP_FarmBuildingName, 15);

			m_iCurDlgNpcID = npcID;
		}
			break;
		case 32: //�������
		{
			CloseProgressBar;
			//ShowView(this, NDCommonCString("ModifyCunluoName"), eCVOP_FarmHarmletName, 15);  ///< ShowView��ʱ�Ҳ��� ����

			m_iCurDlgNpcID = npcID;
		}
			break;
		case 33: //װ������
		{
// 						CloseProgressBar;
// 						EquipUpgradeScene *scene = new EquipUpgradeScene;
// 						scene->Initialization(EQUIP_UPLEVEL);
// 						NDDirector::DefaultDirector()->PushScene(scene);
		}
			break;

		}
		break;
	}
	case MSGDIALOG_CREATE:
	{ // npc�Ի� ���β
		m_iCurDlgNpcID = npcID;
		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
		{
			GameScene *gamescene = (GameScene*) scene;
			gamescene->ShowNPCDialog();
		}
		CloseProgressBar;
		break;
	}
	case MSGDIALOG_MAGIC_EFFECT:
	{ // todo ��ʾħ����Ч
		break;
	}
	case MSGDIALOG_LINK_EX:
	{ // ѡ�����ʾ��ͷ��
		if (usData == TEXT_TEXT)
		{
			str = kData.ReadUnicodeString();
			str = changeToChineseSign(str);
			st_npc_op op;
			op.idx = iDx;
			op.str = str;
			op.bArrow = true;
			vecNPCOPText.push_back(op);
		}
		break;
	}
	case MSGDIALOG_CREATE_EX:
	{ // ���������뿪��ť��
		{
			m_iCurDlgNpcID = npcID;
			NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
			if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
			{
				GameScene *gamescene = (GameScene*) scene;
				gamescene->ShowNPCDialog(false);
			}
			CloseProgressBar;
		}
		break;
	}
	}
}

string NDMapMgr::changeNpcString(string str)
{
	if (str.empty())
	{
		return "";
	}

	NDString ndstrtmp(str);

	ndstrtmp.replace(NDString("&n"),
			NDString(NDPlayer::defaultHero().GetName()));
	switch (NDPlayer::defaultHero().m_nSex)
	{
	case SpriteSexMale:
	{
		ndstrtmp.replace(NDString("&1"), NDString(NDCommonCString("XiaoMei")));
		ndstrtmp.replace(NDString("&2"), NDString(NDCommonCString("DaJie")));
		ndstrtmp.replace(NDString("&3"), NDString(NDCommonCString("NvXia")));
		break;
	}
	case SpriteSexFemale:
	default:
	{
		ndstrtmp.replace(NDString("&1"),
				NDString(NDCommonCString("XiaoXiongDi")));
		ndstrtmp.replace(NDString("&2"), NDString(NDCommonCString("DaGG")));
		ndstrtmp.replace(NDString("&3"), NDString(NDCommonCString("ShaoXia")));
		break;
	}
	}
	return changeToChineseSign(std::string(ndstrtmp.getData()));
}

void NDMapMgr::processShopInfo(NDTransData& data)
{
	///< ò�Ʒ������� ����
	//int shopID = data.ReadInt();
	//int itemNum = data.ReadByte();

	//vector<ShopItemInfo>& vShopItemInfo = m_mapNpcStore[shopID];

	//vShopItemInfo.clear();

	//std::stringstream sb; sb << "�̵�ID" << shopID;
	//sb << (" ��ƷID�б�Ϊ");
	//for (int i = 0; i < itemNum; i++) {
	//	int itemID = data.ReadInt();
	//	int payType = data.ReadByte();

	//	vShopItemInfo.push_back(ShopItemInfo(itemID, payType));

	//	sb << itemID;
	//	sb << ";";
	//}

	////m_mapNpcStore.insert(map_npc_store_pair(shopID, idList));
	////if (DepolyCfg.debug) {
	////			ChatUI.addChatRecodeChatList(new ChatRecord(1, "�̵���Ʒ", sb
	////														.toString()));
	////		}

	//GameUINpcStore::GenerateNpcItems(shopID);

	//CloseProgressBar;
	//if (shopID == 0) {
	//	//T.addDialog(new VipStore(itemList));
	//}
	//else if (shopID == 99998)
	//{
	//	GameScene::ShowShop(shopID);
	//} 
	//else 
	//{
	//	GameScene::ShowShop();
	//}
}

bool NDMapMgr::isMonsterClear()
{
	if (m_vMonster.empty())
	{
		return true;
	}

	bool bRet = true;

	for (VEC_MONSTER::iterator it = m_vMonster.begin();it != m_vMonster.end();it++)
	{
		NDMonster* pkTemp = *it;

		if (pkTemp->getState() != MONSTER_STATE_DEAD)
		{
			bRet = false;
		}
	}

	return bRet;
}

void NDMapMgr::LoadMapMusic()
{
	int nTheID = GetMotherMapID();
	int nMusicID = ScriptDBObj.GetN("map",nTheID,DB_MAP_MUSIC);

	SimpleAudioEngine* pkSimpleAudio = SimpleAudioEngine::sharedEngine();

	if (0 == pkSimpleAudio)
	{
		return;
	}

	CCString* pstrMusicPath = CCString::create(NDPath::GetSoundPath());
	CCString* pstrMusicFile = CCString::stringWithFormat("%smusic_%d.ogg",pstrMusicPath->getCString(),nMusicID);
	pkSimpleAudio->playBackgroundMusic(pstrMusicFile->getCString(),true);
}

// LifeSkill* NDMapMgr::getLifeSkill( OBJID idSkill )
// {
// 
// }

//�����µ�ͼ֮ǰ����һ��
void NDMapMgr::preLoadScene()
{
	this->ClearNPC();
	this->ClearMonster();
	this->ClearGP();
	this->ClearManualRole();
}

NS_NDENGINE_END