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

namespace NDEngine
{

IMPLEMENT_CLASS(NDMapMgr,NDObject);

NDMapMgr::NDMapMgr()
{

}

NDMapMgr::~NDMapMgr()
{

}

bool NDMapMgr::process(MSGID usMsgID, NDEngine::NDTransData* pkData,
		int nLength)
{
	switch (usMsgID)
	{
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
	case _MSG_PLAYER_EXT:
	{
		processPlayerExt(pkData, nLength);
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
		std::string str = pkData->ReadUnicodeString();
		if (i == 0)
		{
			name = str;
		}
		else if (i == 1 && str.length() > 2)
		{
			strRank = str;
		}
		else if (i == 2)
		{
			synName = str;
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
				ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
						usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
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
	int effectAmount = pkData->ReadByte();
	std::vector<int> vEffect;
	for (int i = 0; i < effectAmount; i++)
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
	pkRole->m_dwLookFace = dwLookFace;
	pkRole->m_nProfesstion = btProfession;
	pkRole->m_nLevel = btLevel;
	pkRole->SetState(dwState);
	pkRole->setSynRank(synRank);
	pkRole->m_nPKPoint = dwPkPoint;
	pkRole->SetCamp((CAMP_TYPE) btCamp);
	pkRole->m_strName = name;
	pkRole->m_strRank = strRank;
	pkRole->m_strSynName = synName;
	pkRole->m_nTeamID = dwArmorType;
	pkRole->SetPosition(
			ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
	pkRole->SetSpriteDir(btDir);
	pkRole->SetServerPositon(usRecordX, usRecordY);

// 	if (pkRole->isTeamMember())
// 	{
// 		updateTeamListAddPlayer(*pkRole);
// 	}

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

		if (0 == strcmp(pkRole->m_strName.c_str(), pszName))
		{
			pkResult = it->second;
			break;
		}
	}

	return pkResult;
}

void NDMapMgr::Update(unsigned long ulDiff)
{

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
			&& !pkRole->GetParent()->IsKindOfClass(RUNTIME_CLASS(Battle)))
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
		NDManualRole* pkRole = 0;
		pkRole = NDMapMgrObj.GetManualRole(nID);

		if (pkRole->isTeamLeader())
		{
			pkRole->teamSetServerDir(ucDir);
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

NDNpc* NDMapMgr::GetNPC(int nID)
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
	if (0 == pkData || 0 == nLength)
	{
		return;
	}
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
		(*pkData) >> nID; // 4���ֽ� npc id
		unsigned char uitype = 0;
		(*pkData) >> uitype; // ���ֶ����ڹ���Ѱ·��npc�б�
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
		std::string name = pkData->ReadUnicodeString();

		std::string dataStr = pkData->ReadUnicodeString();
		std::string talkStr = pkData->ReadUnicodeString();

		NDNpc *pkNPC = new NDNpc;
		pkNPC->m_nID = nID;
		pkNPC->m_nCol = usCellX;
		pkNPC->m_nRow = usCellY;
		pkNPC->m_nLook = usLook;
		pkNPC->SetCamp(CAMP_TYPE(btCamp));

		if (uitype == 6)
		{
			pkNPC->m_strName = "";
		}
		else
		{
			pkNPC->m_strName = name;
		}
		pkNPC->SetPosition(
				ccp(usCellX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
						usCellY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
		pkNPC->m_strData = dataStr;
		pkNPC->m_strTalk = talkStr;
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
}

void NDMapMgr::AddAllNPCToMap()
{
	NDLayer* pkLayer = (NDLayer*) getMapLayerOfScene(
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

		pkLayer->AddChild((NDNode*) pkNPC);

		if (0 != pkNPC->GetRidePet())
		{
			pkNPC->GetRidePet()->stopMoving();
			pkNPC->GetRidePet()->SetPositionEx(pkNPC->GetPosition());
			pkNPC->GetRidePet()->SetCurrentAnimation(RIDEPET_STAND,
					pkNPC->m_bFaceRight);
		}

		pkNPC->HandleNPCMask(true);
	}

	NDPlayer::defaultHero().UpdateFocus();
}

void NDMapMgr::OnCustomViewRadioButtonSelected(NDUICustomView* customView,
		unsigned int radioButtonIndex, int ortherButtonTag)
{
	throw std::exception("The method or operation is not implemented.");
}

}