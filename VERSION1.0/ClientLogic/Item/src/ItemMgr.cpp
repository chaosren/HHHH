/*
 *  ItemMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 (����)DeNA. All rights reserved.
 *
 */

#include "ItemMgr.h"
#include "NDPlayer.h"
#include "NDItemType.h"
#include "NDPath.h"
#include "define.h"
#include "NDPath.h"
#include "JavaMethod.h"
#include "NDConstant.h"
#include <sstream>
#include "NDUIDialog.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDDirector.h"
#include "TaskListener.h"
#include "VipStoreScene.h"
#include "PetSkillCompose.h"
#include "SuitTypeObj.h"
#include "AuctionUILayer.h"
#include "VendorUILayer.h"
#include "VendorBuyUILayer.h"
#include "TradeUILayer.h"
#include "GameNewItemBag.h"
#include "NewGamePlayerBag.h"
#include "BattleFieldScene.h"
#include "GameUINpcStore.h"
#include "PlayerInfoScene.h"

#include "ScriptGlobalEvent.h"
#include "GameStorageScene.h"
#include "NDUtility.h"
#include "ObjectTracker.h"

using std::stringstream;
using namespace NDEngine;

const Byte ITEM_USE = 1;

ItemMgr::ItemMgr()
{
	INC_NDOBJ("ItemMgr");

	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		m_EquipList[i] = NULL;
	}

	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		roleEuiptItemsOK[i] = false;
	}

	NDNetMsgPoolObj->RegMsg(_MSG_ITEMINFO, this);
	NDNetMsgPoolObj->RegMsg(_MSG_EQUIP_EFFECT, this); // װ���Ƿ�ʧЧ
	NDNetMsgPoolObj->RegMsg(_MSG_ITEM_ATTRIB, this);
	NDNetMsgPoolObj->RegMsg(_MSG_ITEM_DEL, this);
	NDNetMsgPoolObj->RegMsg(_MSG_ITEM, this);
	NDNetMsgPoolObj->RegMsg(_MSG_STONE, this);
	NDNetMsgPoolObj->RegMsg(_MSG_STONEINFO, this);
	NDNetMsgPoolObj->RegMsg(_MSG_LIMIT, this);
	NDNetMsgPoolObj->RegMsg(_MSG_QUERY_DESC, this);
	NDNetMsgPoolObj->RegMsg(_MSG_TIDY_UP_BAG, this);
	NDNetMsgPoolObj->RegMsg(_MSG_ITEMKEEPER, this);
	NDNetMsgPoolObj->RegMsg(_MSG_SHOP_CENTER, this); // �̳�
	NDNetMsgPoolObj->RegMsg(_MSG_EQUIP_SET_CFG, this);
	NDNetMsgPoolObj->RegMsg(_MSG_EQUIP_BIND, this);
	NDNetMsgPoolObj->RegMsg(_MSG_SHOP_CENTER_GOODS_TYPE, this);

	m_iBags = 0;
	m_iStorages = 0;
}

ItemMgr::~ItemMgr()
{
	DEC_NDOBJ("ItemMgr");

	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		SAFE_DELETE (m_EquipList[i]);
	}

	for (MAP_ITEMTYPE::iterator it = m_mapItemType.begin();
			it != m_mapItemType.end(); it++)
	{
		delete it->second;
	}

	for (MAP_ENHANCEDTYPE_IT itEnhanced = m_mapEnhancedType.begin();
			itEnhanced != m_mapEnhancedType.end(); itEnhanced++)
	{
		SAFE_DELETE(itEnhanced->second);
	}

	std::vector<Item*>::iterator itBag = m_vecBag.begin();
	for (; itBag != m_vecBag.end(); itBag++)
	{
		SAFE_DELETE(*itBag);
	}
	m_vecBag.clear();

	std::vector<Item*>::iterator itStorage = m_vecStorage.begin();
	for (; itStorage != m_vecStorage.end(); itStorage++)
	{
		SAFE_DELETE(*itStorage);
	}
	m_vecStorage.clear();

	RemoveSoldItems();
	ItemMgrObj.repackEquip();
}

void ItemMgr::quitGame()
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (m_EquipList[i])
		{
			delete m_EquipList[i];
			m_EquipList[i] = NULL;
		}
	}

	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		roleEuiptItemsOK[i] = false;
	}

	VEC_ITEM_IT it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		delete (*it);
	}
	m_vecBag.clear();

	VEC_ITEM_IT it2 = m_vecStorage.begin();
	for (; it2 != m_vecStorage.end(); it2++)
	{
		delete (*it2);
	}
	m_vecStorage.clear();

	RemoveSoldItems();

	m_iBags = 0;
	m_iStorages = 0;

	ClearVipItem();
}

/*�������Ȥ��������Ϣ*/
bool ItemMgr::process(MSGID msgID, NDTransData* data, int len)
{
	switch (msgID)
	{
	case _MSG_ITEMINFO:
		processItemInfo(data, len);
		break;
	case _MSG_EQUIP_EFFECT:
		processEquipEffect(data, len);
		break;
	case _MSG_ITEM_ATTRIB:
		processItemAttrib(data, len);
		break;
	case _MSG_ITEM_DEL:
		processItemDel(data, len);
		break;
	case _MSG_ITEM:
		processItem(data, len);
		break;
	case _MSG_STONE:
		processStone(data, len);
		break;
	case _MSG_STONEINFO:
		processStoneInfo(data, len);
		break;
	case _MSG_LIMIT:
		processLimit(data, len);
		break;
	case _MSG_QUERY_DESC:
		processQueryDesc(data, len);
		break;
	case _MSG_TIDY_UP_BAG:
		processTidyUpBag(data, len);
		break;
	case _MSG_ITEMKEEPER:
		processItemKeeper(data, len);
		break;
	case _MSG_SHOP_CENTER:
		processShopCenter(data, len);
		break;
	case _MSG_EQUIP_SET_CFG:
		processEquipSetCfg(data, len);
		break;
	case _MSG_EQUIP_BIND:
		processEquipBind(data, len);
		break;
	case _MSG_SHOP_CENTER_GOODS_TYPE:
		processShopCenterGoodsType(*data);
	default:
		break;
	}

	CloseProgressBar;

	return true;
}

Item* ItemMgr::QueryOtherItem(int idItem)
{
	for (VEC_ITEM_IT it = m_vOtherItems.begin(); it != m_vOtherItems.end();
			it++)
	{
		if ((*it)->m_nID == idItem)
		{
			return *it;
		}
	}
	return NULL;
}

void ItemMgr::RemoveOtherItems()
{
	for (VEC_ITEM_IT it = m_vOtherItems.begin(); it != m_vOtherItems.end();
			it++)
	{
		SAFE_DELETE(*it);
	}

	m_vOtherItems.clear();
}

void ItemMgr::processItemInfo(NDTransData* data, int len)
{
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();

	GameScene* gamescene =
			(GameScene*) (NDDirector::DefaultDirector()->GetScene(
					RUNTIME_CLASS(GameScene)));

	unsigned char itemCount = 0;
	(*data) >> itemCount; // ���յ���Ʒ����

	for (int j = 0; j < itemCount; j++)
	{
		int itemID = 0;
		(*data) >> itemID; // ��Ʒ��Id 4���ֽ�
		int ownerID = 0;
		(*data) >> ownerID; // ��Ʒ��������id 4���ֽ�
		int itemType = 0;
		(*data) >> itemType; // ��Ʒ���� id 4���ֽ�
		int dwAmount = 0;
		(*data) >> dwAmount; // ��Ʒ����/�;ö� 4���ֽ�
		int itemPosition = 0;
		(*data) >> itemPosition; // ��Ʒλ�� 4���ֽ�
		int btAddition = 0;
		(*data) >> btAddition; // װ��׷�� 4���ֽ�
		unsigned char bindState = 0;
		(*data) >> bindState; // ��״̬
		unsigned char btHole = 0;
		(*data) >> btHole; // װ���м�����
		int createTime = 0;
		(*data) >> createTime; // ����ʱ��
		unsigned short sAge = 0;
		(*data) >> sAge; // �������
		unsigned char stoneCount = 0;
		(*data) >> stoneCount;

		Item *item = new Item;
		item->m_nID = itemID;
		item->m_nOwnerID = ownerID;
		item->m_nItemType = itemType;
		item->m_nAmount = dwAmount;
		item->m_nPosition = itemPosition;
		item->m_nAddition = btAddition;
		item->m_nBindState = bindState;
		item->m_nHole = btHole;
		item->m_nCreateTime = createTime;
		item->m_nAge = sAge;

		if (stoneCount > 0)
		{
			for (int i = 0; i < stoneCount; i++)
			{
				int stoneID = 0;
				(*data) >> stoneID;
				Item *stoneItem = new Item(stoneID);
				item->m_vStone.push_back(stoneItem);
			}
		}

		if (itemPosition == POSITION_STORAGE)
		{ // �ֿ�
			bool bolHas = false;
			for (int i = 0; i < int(m_vecStorage.size()); i++)
			{
				Item *item2 = m_vecStorage[i];
				if (item2->m_nID == item->m_nID)
				{
					bolHas = true;
				}
			}
			if (!bolHas)
			{
				m_vecStorage.push_back(item);
				GameStorageAddItem(eGameStorage_Storage, *item);
			}
			else
			{
				SAFE_DELETE(item);
			}
			continue;
		}
		else if (itemPosition == POSITION_MAIL)
		{ // �ʼ���Ʒ
			m_vOtherItems.push_back(item);
		}
		else if (itemPosition == POSITION_AUCTION)
		{ // ֮ǰ������,��ʱ�ȼ���,��ֹ���ݿ� ��֮ǰ��������,
		  // ������������ǲ�����91��ֵ����
			delete item; //����δ������ʱdelete
		}
		else if (itemPosition == POSITION_SOLD)
		{ // �ѳ��۵���Ʒ
			m_mapSoldItems[item->m_nID] = item;
		}
		else
		{ // ���ӵ��Ǳ����е���Ʒ
		  // ���������Ʒ
			NDPlayer& role = NDPlayer::defaultHero();
			if (role.m_nID != item->m_nOwnerID)
			{ // ���������Ʒ
				m_vOtherItems.push_back(item);
			}
			else
			{
				bool bolHandle = false;

				for (VEC_ITEM_IT it = m_vecBag.begin(); it != m_vecBag.end();
						it++)
				{
					if (item->m_nID == (*it)->m_nID)
					{
						int nItemTypeUseInScript = item->m_nItemType;
						(*it)->m_nAmount = item->m_nAmount;
						(*it)->m_nItemType = item->m_nItemType;
						(*it)->m_nAddition = item->m_nAddition;
						(*it)->m_nHole = item->m_nHole;
						(*it)->m_nCreateTime = item->m_nCreateTime;
						SAFE_DELETE(item);
						bolHandle = true;
						ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE,
								nItemTypeUseInScript);
						break;
					}
				}

				if (!bolHandle)
				{
					// ���ӵ�������
					if (itemPosition == POSITION_PACK)
					{ // �����е�
						m_vecBag.push_back(item);

						if (bagscene)
						{
							bagscene->AddItemToBag(item);
						}

						GameStorageAddItem(eGameStorage_Bag, *item);
						int nItemTypeUseInScript = item->m_nItemType;
						ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE,
								nItemTypeUseInScript);
					}
					else
					{ // װ���ϵ�

						Item::eEquip_Pos pos = getEquipListPos(item);
						if (pos == Item::eEP_End)
						{
							SAFE_DELETE(item);
						}
						else
						{
							SAFE_DELETE (m_EquipList[pos]);
							m_EquipList[pos] = item;
						}

						NDItemType* item_type = ItemMgrObj.QueryItemType(
								itemType);

						if (!item_type)
						{
							continue;
						}

						int nID = item_type->m_data.m_lookface;
						int quality = itemType % 10;

						if (nID == 0)
						{
							continue;
						}
						int aniId = 0;
						if (nID > 100000)
						{
							aniId = (nID % 100000) / 10;
						}
						if (aniId >= 1900 && aniId < 2000
								|| nID >= 19000 && nID < 20000 || nID == 1210
								|| nID == 1220)
						{ // ս��
						}
						else
						{
							NDPlayer::defaultHero().SetEquipment(nID, quality);
						}
					}
				}
			}
		}

	}

	if (bagscene)
	{
		bagscene->UpdateEquipList();
	}

	if (gamescene)
	{
		gamescene->RefreshQuickItem();
	}

	BattleFieldScene::UpdateShop();
}

void ItemMgr::processEquipEffect(NDTransData* data, int len)
{
	unsigned char ucCount = 0;
	(*data) >> ucCount;
	for (int i = 0; i < ucCount; i++)
	{
		int itemID = 0;
		(*data) >> itemID;
		unsigned char effect = 0;
		(*data) >> effect;
		effect = (effect + 1) % 2;
		for (int j = Item::eEP_Begin; j < Item::eEP_End; j++)
		{
			Item *item = m_EquipList[j];
			if (item != NULL && item->m_nID == itemID)
			{
				roleEuiptItemsOK[j] = effect;
				break;
			}
		}
	}
}

void ItemMgr::processItemAttrib(NDTransData* data, int len)
{
	int itemID = 0;
	(*data) >> itemID; // ��Ʒ��Id 4���ֽ�

	int action = 0;
	(*data) >> action; // ��Ϊ,Ŀǰֻ��_ITEM _AMOUNT

	int amount = 0;
	(*data) >> amount; // ��Ʒ����

	GameScene* gamescene =
			(GameScene*) (NDDirector::DefaultDirector()->GetScene(
					RUNTIME_CLASS(GameScene)));
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();

	switch (action)
	{
	case ITEMDATA_AMOUNT:
	{
		bool bolProed = false;

		Item *itemBag = NULL;

		if (HasItemByType(ITEM_BAG, itemID, itemBag))
		{
			itemBag->m_nAmount = amount;

			int nItemTypeUseInScript = itemBag->m_nItemType;
			ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);

			if (gamescene)
			{
				gamescene->RefreshQuickItem();
			}

			if (bagscene)
			{
				bagscene->UpdateItem(itemBag->m_nID);
			}
			break;
		}

		if (!bolProed)
		{
			// ���²ֿ��е���Ʒ

			Item *itemStorage = NULL;

			if (HasItemByType(ITEM_STORAGE, itemID, itemStorage))
			{
				itemStorage->m_nAmount = amount;
				//bolProed = true;
				break;
			}
		}

		if (!bolProed)
		{

			Item *itemEquip = NULL;

			if (HasItemByType(ITEM_EQUIP, itemID, itemEquip))
			{
				bool bSetEquipState = false;
				if (itemEquip->m_nAmount == 0 || amount == 0)
				{
					bSetEquipState = true;
				}

				itemEquip->m_nAmount = amount;

				if (bSetEquipState)
				{				// ����;ö�Ϊ0�������������
					setEquipState();
				}
				//bolProed = true;
				break;
			}
		}

		break;
	}
	case ITEMDATA_POSITION:
	{ // action==2ʱ,����װ�� amount��ʾ��Ʒ��λ���൱��postion
		if (ChangeItemPosSold(itemID, amount))
		{
			return;
		}

		Item *itemBag = NULL;

		if (HasItemByType(ITEM_BAG, itemID, itemBag))
		{
			int itemType = itemBag->m_nItemType;
			int equipType = Item::getIdRule(itemType, Item::ITEM_EQUIP); // װ������
			int equipItem = -1;
			int changeItem = -1;

			switch (amount)
			{
			case 1:
			{ // ͷ��
				equipItem = Item::eEP_Head;
				break;
			}
			case 2:
			{ // ���
				equipItem = Item::eEP_Shoulder;
				break;
			}
			case 3:
			{ // �ؼ�
				equipItem = Item::eEP_Armor;
				break;
			}
			case 4:
			{ // ����
				equipItem = Item::eEP_Shou;
				break;
			}
			case 5:
			{ // ����--����
				equipItem = Item::eEP_YaoDai;
				break;
			}
			case 6:
			{ // ����
				equipItem = Item::eEP_HuTui;
				break;
			}
			case 7:
			{ // Ь��
				equipItem = Item::eEP_Shoes;
				break;
			}
			case 8:
			{ // ����
				equipItem = Item::eEP_XianLian;
				break;
			}
			case 9:
			{ // ����
				equipItem = Item::eEP_ErHuan;
				break;
			}
			case 10:
			{ // ���� �ռ�
				equipItem = Item::eEP_HuiJi;
				break;
			}
			case 11:
			{ // ���ָ
				equipItem = Item::eEP_LeftRing;
				break;
			}
			case 12:
			{ // �ҽ�ָ
				equipItem = Item::eEP_RightRing;
				break;
			}
			case 13:
			{ // ������
				equipItem = Item::eEP_MainArmor;

				if (equipType == 1)
				{
					if (m_EquipList[Item::eEP_FuArmor] != NULL)
					{
						changeItem = Item::eEP_FuArmor;
					}
				}
				else if (m_EquipList[Item::eEP_FuArmor] != NULL)
				{ // ����װ˫���������ж��Ƿ�װ������������
					int itemtype = m_EquipList[Item::eEP_FuArmor]->m_nItemType;
					int type1 = Item::getIdRule(itemtype, Item::ITEM_CLASS); // װ������
					int type2 = Item::getIdRule(itemType, Item::ITEM_CLASS);

					if (type1 != type2)
					{
						changeItem = Item::eEP_FuArmor;
					}
				}

				break;
			}
			case 14:
			{ // ������
				equipItem = Item::eEP_FuArmor;

				Item *tempI = m_EquipList[Item::eEP_MainArmor];
				if (tempI != NULL)
				{
					int tempEquipType = Item::getIdRule(tempI->m_nItemType,
							Item::ITEM_EQUIP);

					if (tempEquipType == 1)
					{
						// unpackEquip(T.roleEuiptItems[6]);
						changeItem = Item::eEP_MainArmor;
					}
				}

				break;
			}
			case 80:
			{ // ����
				equipItem = Item::eEP_Ride;
				break;
			}
			case 81:
			{ // ѫ��
				equipItem = Item::eEP_Decoration;
				break;
			}
			}

			if (equipItem == -1)
			{
				DelItem(ITEM_BAG, itemID);
			}
			else
			{
				DelItem(ITEM_BAG, itemID, false);

				unpackEquip(equipItem, false);

				m_EquipList[equipItem] = itemBag;

				NDItemType* item_type = ItemMgrObj.QueryItemType(
						itemBag->m_nItemType);

				if (item_type)
				{
					int nID = item_type->m_data.m_lookface;
					int quality = itemType % 10;

					NDPlayer& kPlayer = NDPlayer::defaultHero();
					kPlayer.SetEquipment(nID, quality);

					if (kPlayer.GetParent()
							&& kPlayer.GetParent()->IsKindOfClass(
									RUNTIME_CLASS(NDMapLayer)))
					{
						NDPlayer::defaultHero().SetAction(false);
					}
				}

				unpackEquip(changeItem, false);
			}
		}
		break;
	}
	case ITEMDATA_PLUNDER:
	{
		Item *itemEquip = NULL;

		if (HasItemByType(ITEM_EQUIP, itemID, itemEquip))
		{
			itemEquip->m_nAge = amount;
			break;
		}
		break;
	}
	}

	if (bagscene)
	{
		bagscene->UpdateEquipList();
		bagscene->updateCurItem();
	}

	setEquipState();
}

void ItemMgr::processItemDel(NDTransData* data, int len)
{
	unsigned char itemAmount = 0;
	(*data) >> itemAmount;
	std::vector<int> vecItemID;
	for (int i = 0; i < itemAmount; i++)
	{
		int itemID = 0;
		(*data) >> itemID;
		vecItemID.push_back(itemID);
	}

	// ж��װ��, ע:�������Ʒɾ��������Ϊ����ж��װ������,������PK��,�������ﲻ�öԱ���������д���
	bool bUnpack = false;
	std::vector<int>::iterator it = vecItemID.begin();
	for (; it != vecItemID.end(); it++)
	{
		Item *itemEquip = NULL;
		if (HasItemByType(ITEM_EQUIP, *it, itemEquip))
		{
			//if (EquipUIScreen.instance != null) { 
//				EquipUIScreen.instance
//				.unpackEquip(T.roleEuiptItems[i]);
//			} else {
//				T.roleEuiptItems[i].changeItem(null);
//				EquipUIScreen.unpackEquipOfRole(item.itemType);
//				// setEquipState();
//			}
			DelItem(ITEM_EQUIP, *it);
			bUnpack = true;
		}

		Item *itemBag = NULL;
		if (HasItemByType(ITEM_BAG, *it, itemBag))
		{
			DelItem(ITEM_BAG, *it);
			//updateTaskItemData(*itemBag, true);
			//��������
		}

		Item *itemStorage = NULL;
		if (HasItemByType(ITEM_STORAGE, *it, itemStorage))
		{
			DelItem(ITEM_STORAGE, *it);
			//��������
		}

		Item *itemSold = NULL;
		if (HasItemByType(ITEM_SOLD, *it, itemSold))
		{
			DelItem(ITEM_SOLD, *it);
		}
	}

	if (bUnpack)
	{
		setEquipState();
	}
}

void ItemMgr::processItem(NDTransData* data, int len)
{

	int itemID;
	unsigned char action;
	(*data) >> itemID >> action;

	switch (action)
	{
	case Item::ITEM_UNEQUIP:
	{ // װ��ж��
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if (item && item->m_nID == itemID)
			{
				unpackEquip(i, true);
				break;
			}
		}
		break;
	}
	case Item::ITEM_QUERY:
	{
		Item* item = NULL;
		if (m_vOtherItems.size())
		{
			item = m_vOtherItems[0];
		}

		if (!item)
		{
			HasItemByType(ITEM_BAG, itemID, item);
		}

		if (item)
		{
			std::string tempStr = item->makeItemDes(false, true);
			std::stringstream name;
			name << item->getItemNameWithAdd();

			//GlobalShowDlg(name.str().c_str(), tempStr.c_str());
		}
		else
		{
			//GlobalShowDlg(NDCommonCString("error"), NDCommonCString("CantFindItem"));
		}
	}
		break;
	case Item::_ITEMACT_REPAIR:
	{
		refreshEquipAmount(itemID, 0);
		NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
		if (bagscene)
			bagscene->updateCurItem();
	}
		//EquipUIScreen.refreshEquipAmount(itemID, (byte) 0);
//			setEquipState();
//			if (EquipUIScreen.instance != null) {
//				EquipUIScreen.instance.refreshCurItemText();
//				EquipUIScreen.instance.updateEquip();
//			}
		break;
	case Item::_ITEMACT_REPAIR_ALL:
	{
		refreshEquipAmount(itemID, 1);
		NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
		if (bagscene)
			bagscene->updateCurItem();
	}
		//EquipUIScreen.refreshEquipAmount(itemID, (byte) 1);
//			setEquipState();
//			if (EquipUIScreen.instance != null) {
//				EquipUIScreen.instance.refreshCurItemText();
//				EquipUIScreen.instance.updateEquip();
//			}
		break;
	case Item::_ITEMACT_USETYPE:
		//if (itemID == Item.CLEAR_POINT) { // ϴ��֮��
//				dialog = new Dialog("ϴ��ɹ�", "���ѳɹ���ϴ���������Ե�", Dialog.PRIV_HIGH);
//				T.addDialog(dialog);
//			}
		break;
	}

}

void ItemMgr::processStone(NDTransData* data, int len)
{
	unsigned char n = 0;
	(*data) >> n;
	if (n == Item::LIFESKILL_INLAY)
	{
		int idItem = 0;
		(*data) >> idItem;
		int idStoneType = 0;
		(*data) >> idStoneType;

		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item* item = *it;
			if (item->m_nID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}

		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if (item && item->m_nID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}

		NewPlayerBagLayer* pkBagScene = NewPlayerBagLayer::GetInstance();
		if (pkBagScene)
		{
			pkBagScene->updateCurItem();
		}
	}
	else if (n == Item::LIFESKILL_DIGOUT)
	{
		int idItem = 0;
		(*data) >> idItem;

		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item* item = *it;
			if (item->m_nID == idItem)
			{
				item->DelAllStone();
			}
		}

		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if (item && item->m_nID == idItem)
			{
				item->DelAllStone();
			}
		}

	}
	else
	{
		// InlayDialog.faile();
	}
}

void ItemMgr::processStoneInfo(NDTransData* data, int len)
{
	unsigned char btAmount = 0;
	(*data) >> btAmount; // ��Ƕ������
	for (int i = 0; i < btAmount; i++)
	{
		int idItem = 0;
		(*data) >> idItem;
		int idStoneType = 0;
		(*data) >> idStoneType;

		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item* item = *it;
			if (item->m_nID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}

		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if (item->m_nID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}
	}

}

void ItemMgr::processLimit(NDTransData* data, int len)
{
//	unsigned char action = 0; (*data) >> action;
//	if (action == 0) {
//		m_iStorages+=1;
//		showDialog(NDCommonCString("tip"), NDCommonCString("BuyStorageSucc"));
//		GameStorageUpdateLimit(eGameStorage_Storage);
//	} else {
//		m_iBags+=1;
//		showDialog(NDCommonCString("tip"), NDCommonCString("BuyBagSucc"));
//		//NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
////		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GamePlayerBagScene)))
////		{
////			GamePlayerBagScene* bagscene = (GamePlayerBagScene*)scene;
////			bagscene->UpdateBagNum(m_iBags);
////		}
////		GameStorageUpdateLimit(eGameStorage_Bag);
//	
//		// ���õ�GameItemBag�Ľ��治�ø��±�������,ͳһ�ɸþ�̬��������
//		GameItemBag::UpdateBagNum(m_iBags);
//		NewGameItemBag::UpdateBagNum(m_iBags);
//		NewGamePetBag::UpdateBagNum(m_iBags);
//	}
}

void ItemMgr::processQueryDesc(NDTransData* data, int len)
{
	CloseProgressBar;

	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (bagscene)
	{
		int idItem = 0;
		(*data) >> idItem;
		std::string strContent = data->ReadUnicodeString();

		///Item *itembag = NULL;
		/*
		 if (HasItemByType(ITEM_BAG, idItem, itembag))
		 {
		 showDialog(itembag->getItemNameWithAdd().c_str(), strContent.c_str());
		 }
		 */
	}

	else if (VendorUILayer::isUILayerShown()
			|| VendorBuyUILayer::isUILayerShown()
			|| NewTradeLayer::isUILayerShown())
	{
		int nItemID = 0;
		(*data) >> nItemID;
		std::string strContent = data->ReadUnicodeString();

		Item* pkItem = QueryOtherItem(nItemID);
		if (!pkItem)
		{
			HasItemByType(ITEM_BAG, nItemID, pkItem);
		}

		if (pkItem)
		{
			showDialog(pkItem->getItemNameWithAdd().c_str(),
					strContent.c_str());
		}
	}
	else
	{
		if (AuctionUILayer::processItemDescQuery(*data))
		{
			return;
		}
	}
}

void ItemMgr::processTidyUpBag(NDTransData* data, int len)
{
	//T.sortItemList();
//	for (int i = 0; i < T.itemList.size(); i++) {
//		Item item = (Item) T.itemList.elementAt(i);
//		item.itemSeq = i;
//	}
//	
//	if (EquipUIScreen.instance != null) {
//		EquipUIScreen.instance.zhengLi();
//	}

	SortBag();

	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	if (bagscene)
		bagscene->UpdateBag();
}

void ItemMgr::processItemKeeper(NDTransData* data, int len)
{
	int value = data->ReadInt();
	int action = data->ReadInt();
	data->ReadInt();
	NDPlayer& player = NDPlayer::defaultHero();
}

void ItemMgr::processShopCenter(NDTransData* data, int len)
{
	int flag = data->ReadByte();
	int itemNum = data->ReadByte();
	std::vector<int> idList;
	std::stringstream sb;
	sb << "flag" << flag;

	for (int i = 0; i < itemNum; i++)
	{
		int goodsType = data->ReadByte();
		int itemID = data->ReadInt();
		int price = data->ReadInt();

		// Ԥ�ȼ���item type��Ϣ
		QueryItemType(itemID);

		VipItem *vItem = new VipItem();
		vItem->vipType = goodsType;
		vItem->itemId = itemID;
		vItem->price = price;
		vItem->item = new Item(itemID);

		map_vip_item_it it = m_mapVipItem.find(goodsType);
		if (it == m_mapVipItem.end())
		{
			vec_vip_item itemlist;
			itemlist.push_back(vItem);
			m_mapVipItem.insert(map_vip_item_pair(goodsType, itemlist));
		}
		else
		{
			vec_vip_item& itemlist = it->second;
			itemlist.push_back(vItem);
		}

		sb << (itemID);
		sb << ";";
	}

	//if (DepolyCfg.debug) {
//		ChatUI.addChatRecodeChatList(new ChatRecord(1, "�̵���Ʒ", sb
//													.toString()));
//	}

	if (flag == 1)
	{
		//NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene());
	}
}

void ItemMgr::processEquipSetCfg(NDTransData* data, int len)
{
}

void ItemMgr::processEquipBind(NDTransData* data, int len)
{
	CloseProgressBar;
	int result = data->ReadByte();
	int itemId = data->ReadInt();
	if (result == 0)
	{ // �󶨳ɹ�
		Item *res = NULL;
		if (HasItemByType(ITEM_BAG, itemId, res))
		{
		}
	}
	else if (result == 1)
	{ // ����󶨳ɹ�
		Item* pkResource = NULL;
		if (HasItemByType(ITEM_BAG, itemId, pkResource))
		{
			if (pkResource)
			{
				pkResource->m_nBindState = BIND_STATE_UNBIND;
			}
		}
	}
}

void ItemMgr::processShopCenterGoodsType(NDTransData& data)
{
	CloseProgressBar;
}

EquipPropAddtions ItemMgr::GetEquipAddtionProp()
{
	EquipPropAddtions result;
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		Item *item = m_EquipList[i];
		if (item)
		{
			NDItemType *itemtype = QueryItemType(item->m_nItemType);
			if (itemtype)
			{
				result.iPowerAdd += itemtype->m_data.m_atk_point_add;
				result.iTiZhiAdd += itemtype->m_data.m_def_point_add;
				result.iMinJieAdd += itemtype->m_data.m_dex_point_add;
				result.iZhiLiAdd += itemtype->m_data.m_mag_point_add;
			}

		}
	}
	return result;
}

Item::eEquip_Pos ItemMgr::getEquipListPos(Item* item)
{

	Item::eEquip_Pos pos;
	pos = Item::eEP_End;

	if (!item)
	{
		return pos;
	}

	switch (item->m_nPosition)
	{
	case 1:
	{ // ͷ��
		pos = Item::eEP_Head;
		break;
	}
	case 2:
	{ // ���
		pos = Item::eEP_Shoulder;
		break;
	}
	case 3:
	{ // �ؼ�
		pos = Item::eEP_Armor;
		break;
	}
	case 4:
	{ // ��
		pos = Item::eEP_Shou;
		break;
	}
	case 5:
	{ // ����--����
		pos = Item::eEP_YaoDai;
		break;
	}
	case 6:
	{ // ����
		pos = Item::eEP_HuTui;
		break;
	}
	case 7:
	{ // Ь��
		pos = Item::eEP_Shoes;
		break;
	}
	case 8:
	{ // ����
		pos = Item::eEP_XianLian;
		break;
	}
	case 9:
	{ // ����
		pos = Item::eEP_ErHuan;
		break;
	}
	case 10:
	{ // ���� �ռ�
		pos = Item::eEP_HuiJi;
		break;
	}
	case 11:
	{ // ���ָ
		pos = Item::eEP_LeftRing;
		break;
	}
	case 12:
	{ // �ҽ�ָ
		pos = Item::eEP_RightRing;
		break;
	}
	case 13:
	{ // ������
		pos = Item::eEP_MainArmor;
		break;
	}
	case 14:
	{ // ������
		pos = Item::eEP_FuArmor;
		break;
	}
	case 80:
	{ // ����
		pos = Item::eEP_Ride;
		break;
	}
	case 81:
	{ // ѫ��
		pos = Item::eEP_Decoration;
		break;
	}
	}
	return pos;
}

EnhancedObj* ItemMgr::QueryEnhancedType(int idEnhancedType)
{
	MAP_ENHANCEDTYPE_IT it = m_mapEnhancedType.find(idEnhancedType);
	if (it != m_mapEnhancedType.end())
	{
		return it->second;
	}
	else
	{
		MAP_ENHANCEDTYPE_INDEX::iterator itIndex = m_mapEnhancedTypeIndex.find(
				idEnhancedType);
		if (itIndex != m_mapEnhancedTypeIndex.end())
		{
			//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResPath().c_str()];
// 			NSString *type = [NSString stringWithFormat:@"%s", NDPath::GetResPath("enhancedtype.ini")];
// 			NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:type]; ///<��ʱע�͵� --����

// 			if (stream)
// 			{
// 				[stream open];
// 				
// 				EnhancedObj* pType = new EnhancedObj;
// 				
// 				[stream setProperty:[NSNumber numberWithInt:itIndex->second] forKey:NSStreamFileCurrentOffsetKey];
// 				
// 				pType->idType = [stream readInt];
// 				pType->addpoint = [stream readShort];
// 				pType->percent = [stream readByte];
// 				pType->req_item = [stream readInt];
// 				pType->req_num = [stream readByte];
// 				pType->req_money = [stream readInt];
// 				
// 				m_mapEnhancedType[idEnhancedType] = pType;
// 				
// 				[stream close];
// 				
// 				return pType;
// 			}
		}
	}

	return NULL;
}

NDItemType* ItemMgr::QueryItemType(OBJID idItemType)
{
	MAP_ITEMTYPE::iterator it = m_mapItemType.find(idItemType);
	if (it != m_mapItemType.end())
	{
		return it->second;
	}
	else
	{
		MAP_ITEMTYPE_INDEX::iterator itIndex = m_mapItemTypeIndex.find(
				idItemType);
		if (itIndex != m_mapItemTypeIndex.end())
		{
		}
	}

	return NULL;
}

void ItemMgr::LoadItemTypeIndex()
{
}

void ItemMgr::LoadEnhancedTypeIndex()
{
}

void ItemMgr::LoadItemAddtion()
{
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResPath().c_str()];
// 	NSString *itemAdditionTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("addition.ini")];
// 	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:itemAdditionTable];
// 	
// 	if (stream)
// 	{
// 		[stream open];
// 		
// 		while ( [stream hasBytesAvailable] ) 
// 		{
// 			int tempAddLevel = 0;
// 			
// 			int readLen = [stream read:(uint8_t *)(&tempAddLevel) maxLength:1];
// 			
// 			if ( !readLen ) 
// 			{
// 				break;
// 			}
// 			
// 			//int tempAddLevel = [stream readByte];
// 			
// 			int tempPercent = [stream readShort];
// 			
// 			m_mapItemAddtion.insert(map_item_addtion_pair(tempAddLevel, tempPercent));
// 		}
// 		
// 		[stream close];
// 	}
}

int ItemMgr::QueryPercentByLevel(int level)
{
	map_item_addtion_it it = m_mapItemAddtion.find(level);
	if (it != m_mapItemAddtion.end())
	{
		return it->second;
	}
	return 0;
}

void ItemMgr::ReplaceItemType(NDItemType* itemtype)
{
	if (!itemtype)
	{
		return;
	}
	MAP_ITEMTYPE::iterator it = m_mapItemType.find(itemtype->m_data.m_id);
	if (it != m_mapItemType.end())
	{
		delete it->second;
		m_mapItemType.erase(it);
	}
	m_mapItemType[itemtype->m_data.m_id] = itemtype;
}

void ItemMgr::SetBagLitmit(int iLimit)
{
	m_iBags = iLimit;
}
bool ItemMgr::IsBagFull()
{
	return int(m_vecBag.size()) == BAG_ITEM_NUM * m_iBags;
}
void ItemMgr::SetStorageLitmit(int iLimit)
{
	m_iStorages = iLimit;
}

void ItemMgr::unpackEquip(int iPos, bool bUpdateGui)
{
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();

	if (!(iPos < Item::eEP_Begin || iPos >= Item::eEP_End || !m_EquipList[iPos]))
	{
		int iItemType = m_EquipList[iPos]->m_nItemType;
		m_vecBag.push_back(m_EquipList[iPos]);
		if (bagscene)
		{
			bagscene->AddItemToBag(m_EquipList[iPos]);
		}
		int nItemTypeUseInScript = m_EquipList[iPos]->m_nItemType;
		ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
		m_EquipList[iPos] = NULL;
		unpackEquipOfRole(iItemType);
	}

	if (bUpdateGui && bagscene)
	{
		bagscene->UpdateEquipList();
	}

	setEquipState();
}

void ItemMgr::unpackEquipOfRole(int itemType)
{
	NDPlayer& player = NDPlayer::defaultHero();
	// ж�º�ı��ɫ���
	std::vector<int> idRule = Item::getItemType(itemType); // ������Ʒid
	// ��
	// 1
	// ��2λ��װ������
	if (idRule[0] == 0)
	{	// װ��
		int equipType = idRule[1] * 10 + idRule[2];
		if (equipType < 30)
		{	// ����

			if (m_EquipList[Item::eEP_MainArmor] == NULL)
			{	// ж��������
				player.unpackEquip(Item::eEP_MainArmor);
				//if (m_EquipList[Item::eEP_FuArmor] != NULL) {// ����������
//					player.SetSecWeaponType(ONE_HAND_WEAPON);
//				} else {
//					player.SetSecWeaponType(WEAPON_NONE);
//				}
			}
			if (m_EquipList[Item::eEP_FuArmor] == NULL)
			{	// ж�¸�����
				player.unpackEquip(Item::eEP_FuArmor);
				//if (m_EquipList[Item::eEP_MainArmor] != NULL) {// ����������
//					player.SetWeaponType(ONE_HAND_WEAPON);
//				} else {
//					player.SetWeaponType(WEAPON_NONE);
//				}
			}

		}
		else if (equipType == 41)
		{	// ͷ��
			player.unpackEquip(Item::eEP_Head);
		}
		else if (equipType == 43)
		{	// �ؼ�
			player.unpackEquip(Item::eEP_Armor);
		}
		else if (equipType == 31)
		{	// ��
			player.unpackEquip(Item::eEP_FuArmor);
		}
		else if (equipType == 32)
		{	// ����
			player.unpackEquip(Item::eEP_FuArmor);
		}
		else if (equipType == 45)
		{	// ���� -- ����
			player.unpackEquip(Item::eEP_YaoDai);
		}
	}
	int petType = idRule[0] * 10 + idRule[1];
	if (petType == 11)
	{	// ж�����
		//player.uppackBattlePet();
	}
	else if (petType == 14)
	{		// ж�����
		player.unpackEquip(Item::eEP_Ride);
	}
}

void ItemMgr::setEquipState()
{
	bool bWeaponBroken = false, bDefBroken = false, bRidePetBroken = false;
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (m_EquipList[i])
		{
			if (m_EquipList[i]->m_nAmount == 0)
			{
				if (Item::isWeapon(m_EquipList[i]->m_nItemType))
				{
					bWeaponBroken = true;
				}
				else if (Item::isDefEquip(m_EquipList[i]->m_nItemType)
						|| Item::isAccessories(m_EquipList[i]->m_nItemType))
				{
					bDefBroken = true;
				}

				if (m_EquipList[i]->m_nAmount == 0
						|| m_EquipList[i]->m_nAge == 0)
				{
					bRidePetBroken = true;
				}
			}
		}
	}

	GameScene::SetWeaponBroken(bWeaponBroken);
	GameScene::SetDefBroken(bDefBroken);
	GameScene::SetDefBroken(bRidePetBroken);
}

void ItemMgr::refreshEquipAmount(int itemId, int type)
{
	switch (type)
	{
	case 0:
	{
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item *item = m_EquipList[i];
			if (item && item->m_nID == itemId)
			{
				int equipAllAmount = item->getAmount_limit();
				item->m_nAmount = equipAllAmount;

//					NewEquipRepairLayer::refreshAmount();
				return;
			}
		}

		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item *item = *it;
			if (item && item->m_nID == itemId)
			{
				int equipAllAmount = item->getAmount_limit();
				item->m_nAmount = equipAllAmount;
//					NewEquipRepairLayer::refreshAmount();
				return;
			}
		}
		break;

	}
	case 1:
	{ // ������ȫ��
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item *item = m_EquipList[i];
			if (item && item->isEquip() && !item->isRidePet())
			{
				int equipAllAmount = item->getAmount_limit();
				item->m_nAmount = equipAllAmount;
			}
		}
//			NewEquipRepairLayer::refreshAmount();
		return;
	}
	}
}

Item* ItemMgr::GetSuitItem(int idItem)
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (m_EquipList[i])
		{
			Item *item = m_EquipList[i];
			if (item->m_nItemType / 10 == idItem)
			{
				return item;
			}
		}
	}

	return NULL;
}

void ItemMgr::repackEquip()
{
	NDPlayer& player = NDPlayer::defaultHero();
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (i == Item::eEP_Ride)
		{
			continue;
		}
		player.unpackEquip(i);
	}

	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (m_EquipList[i] && i != Item::eEP_Ride)
		{
			NDItemType* item_type = ItemMgrObj.QueryItemType(
					m_EquipList[i]->m_nItemType);
			if (!item_type)
			{
				continue;
			}
			int nID = item_type->m_data.m_lookface;
			int quality = m_EquipList[i]->m_nItemType % 10;
			player.SetEquipment(nID, quality);
		}
	}
}

void ItemMgr::GetEnhanceItem(VEC_ITEM& itemlist)
{
	itemlist.clear();
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item)
		{
			if (item->isCanEnhance()
					|| (item->m_nItemType >= 28010000
							&& item->m_nItemType <= 28019999))
			{
				itemlist.push_back(item);
			}
		}
	}
}

void ItemMgr::GetBattleUsableItem(std::vector<Item*>& itemlist)
{
	itemlist.clear();
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item)
		{
			NDItemType *itemtype = QueryItemType(item->m_nItemType);
			int monopoly = 0;
			if (itemtype)
			{
				monopoly = itemtype->m_data.m_monopoly;
			}
			if (item->m_nItemType / 10000000 == 2
					&& ((monopoly & ITEMTYPE_MONOPOLY_BATTLE)
							== ITEMTYPE_MONOPOLY_BATTLE))
				itemlist.push_back(item);
		}
	}
}

void ItemMgr::GetCanUsableItem(std::vector<Item*>& itemlist)
{
	itemlist.clear();
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item && item->isItemCanUse() && !item->isEquip())
		{
			bool hasExist = false;
			for_vec(itemlist, VEC_ITEM_IT)
			{
				if ((*it)->m_nItemType == item->m_nItemType)
				{
					hasExist = true;

					break;
				}
			}

			if (!hasExist)
				itemlist.push_back(item);
		}
	}
}

void ItemMgr::SortBag()
{
	if (m_vecBag.empty())
	{
		return;
	}
	std::sort(m_vecBag.begin(), m_vecBag.end(), ItemTypeLessThan());
}

int ItemMgr::GetBagItemCount(int iType)
{
	int count = 0;

	for_vec(m_vecBag, VEC_ITEM_IT)
	{
		Item *item = *it;
		if (item && item->m_nItemType == iType)
		{
			if (item->m_nAmount > 0)
			{
				count += item->m_nAmount;
			}
			else
			{
				count++;
			}
		}
	}

	return count;
}

Item* ItemMgr::GetBagItemByType(int idItemType)
{
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item && item->m_nItemType == idItemType)
		{
			return item;
		}
	}
	return NULL;
}

bool ItemMgr::HasItemByType(int iType, int iItemID, Item*& itemRes)
{
	bool bRet = false;

	if (iType == ITEM_BAG)
	{ // ����
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item *item = *it;
			if (item && item->m_nID == iItemID)
			{
				itemRes = item;
				bRet = true;
				break;
			}
		}
	}
	else if (iType == ITEM_STORAGE)
	{ //�ֿ�
		std::vector<Item*>::iterator it = m_vecStorage.begin();
		for (; it != m_vecStorage.end(); it++)
		{
			Item *item = *it;
			if (item && item->m_nID == iItemID)
			{
				itemRes = item;
				bRet = true;
				break;
			}
		}
	}
	else if (iType == ITEM_EQUIP)
	{ //װ��
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item *item = m_EquipList[i];
			if (item && item->m_nID == iItemID)
			{
				itemRes = item;
				bRet = true;
				break;
			}
		}
	}
	else if (iType == ITEM_SOLD)
	{ // ���۳�
		MAP_ITEM::iterator itSold = m_mapSoldItems.find(iItemID);
		if (itSold != m_mapSoldItems.end())
		{
			itemRes = itSold->second;
			bRet = true;
		}
	}

	return bRet;
}

bool ItemMgr::DelItem(int iType, int iItemID, bool bClear/*=true*/)
{
	bool bRet = false;

	if (iType == ITEM_BAG)
	{ // ����
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item *item = *it;
			if (item && item->m_nID == iItemID)
			{
				int nItemTypeUseInScript = item->m_nItemType;
				GameScene* gamescene =
						(GameScene*) (NDDirector::DefaultDirector()->GetScene(
								RUNTIME_CLASS(GameScene)));
				NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
				if (bagscene)
				{
					bagscene->DelBagItem(iItemID);
				}

				if (bClear)
				{
					delete item;
				}

				m_vecBag.erase(it);
				bRet = true;

				if (gamescene)
				{
					gamescene->RefreshQuickItem();
				}

				if (bClear)
				{
					ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE,
							nItemTypeUseInScript);
				}

				break;
			}
		}
	}
	else if (iType == ITEM_STORAGE)
	{ //�ֿ�
		std::vector<Item*>::iterator it = m_vecStorage.begin();
		for (; it != m_vecStorage.end(); it++)
		{
			Item *item = *it;
			if (item && item->m_nID == iItemID)
			{
				int nItemTypeUseInScript = item->m_nItemType;
				if (bClear)
				{
					delete item;
				}
				m_vecBag.erase(it);
				bRet = true;
				if (bClear)
				{
					ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE,
							nItemTypeUseInScript);
				}
				break;
			}
		}
	}
	else if (iType == ITEM_EQUIP)
	{ //װ��
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item *item = m_EquipList[i];
			if (item && item->m_nID == iItemID)
			{
				int nItemTypeUseInScript = item->m_nItemType;
				if (bClear)
				{
					delete item;
				}
				m_EquipList[i] = NULL;
				bRet = true;
				setEquipState();
				if (bClear)
				{
					ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE,
							nItemTypeUseInScript);
				}
				break;
			}
		}

	}
	else if (iType == ITEM_SOLD)
	{ // ���۳�
		MAP_ITEM::iterator itSold = m_mapSoldItems.find(iItemID);
		if (itSold != m_mapSoldItems.end())
		{
			Item *item = itSold->second;
			if (bClear)
			{
				delete item;
			}
			bRet = true;
			m_mapSoldItems.erase(itSold);
		}
	}

	return bRet;
}

bool ItemMgr::UseItem(Item* item)
{
	sendItemUse(*item);

	return true;
}

void ItemMgr::ClearVipItem()
{
	map_vip_item_it itMap = m_mapVipItem.begin();
	for (; itMap != m_mapVipItem.end(); itMap++)
	{
		vec_vip_item& items = itMap->second;
		for_vec(items, vec_vip_item_it)
		{
			delete *it;
		}
		items.clear();
	}
	m_mapVipItem.clear();

	m_mapVipDesc.clear();
}

///////////////////////////////////////////////////////////////////
Item* ItemMgr::QueryItem(OBJID idItem)
{
	// ����
	VEC_ITEM::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item && ((OBJID) item->m_nID) == idItem)
		{
			return item;
		}
	}

	//�ֿ�
	it = m_vecStorage.begin();
	for (; it != m_vecStorage.end(); it++)
	{
		Item *item = *it;
		if (item && (OBJID) item->m_nID == idItem)
		{
			return item;
		}
	}

	//װ��
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		Item *item = m_EquipList[i];
		if (item && ((OBJID) item->m_nID) == idItem)
		{
			return item;
		}
	}

	// ���۳�
	MAP_ITEM::iterator itSold = m_mapSoldItems.find(idItem);
	if (itSold != m_mapSoldItems.end())
	{
		return itSold->second;
	}

	return QueryOtherItem((int) idItem);
}

void ItemMgr::RemoveSoldItems()
{
	MAP_ITEM::iterator itSold = m_mapSoldItems.begin();
	for (; itSold != m_mapSoldItems.end(); itSold++)
	{
		SAFE_DELETE(itSold->second);
	}
	m_mapSoldItems.clear();
}

void ItemMgr::GetSoldItemsId(ID_VEC& vecId)
{
	MAP_ITEM::iterator itSold = m_mapSoldItems.begin();
	for (; itSold != m_mapSoldItems.end(); itSold++)
	{
		if ((itSold->second))
		{
			vecId.push_back(itSold->second->m_nID);
		}
	}
}

bool ItemMgr::ChangeItemPosSold(OBJID idItem, int nPos)
{
	Item* pItem = NULL;
	if (nPos == POSITION_SOLD)
	{
		if (HasItemByType(ITEM_BAG, idItem, pItem))
		{
			DelItem(ITEM_BAG, idItem, false);
			m_mapSoldItems[idItem] = pItem;
		}
	}
	else if (nPos == POSITION_PACK)
	{
		if (HasItemByType(ITEM_SOLD, idItem, pItem))
		{
			DelItem(ITEM_SOLD, idItem, false);
			m_vecBag.push_back(pItem);
		}
	}

	if (pItem)
	{
		return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////
void sendItemUse(Item& item)
{
	NDItemType* itemType = ItemMgrObj.QueryItemType(item.m_nItemType);
	NDAsssert(itemType != NULL);
	ShowProgressBar;

	NDTransData bao(_MSG_ITEM);
	bao << (int) item.m_nID << (unsigned char) (Item::ITEM_USE);
}

void sendDropItem(Item& item)
{
	ShowProgressBar;
	NDTransData bao(_MSG_ITEM);
	bao << (int) item.m_nID << (unsigned char) Item::ITEM_DROP;
}

void sendItemRepair(int itemID, int action)
{
	ShowProgressBar;
	NDTransData bao(_MSG_ITEM);
	bao << itemID << (unsigned char) action;
}

int GetItemPos(Item& item)
{
	int iRes = Item::eEP_End;
	switch (item.m_nPosition)
	{
	case 1:
	{ // ͷ��
		iRes = Item::eEP_Head;
		break;
	}
	case 2:
	{ // ���
		iRes = Item::eEP_Shoulder;
		break;
	}
	case 3:
	{ // �ؼ�
		iRes = Item::eEP_Armor;
		break;
	}
	case 4:
	{ // ����
		iRes = Item::eEP_Shou;
		break;
	}
	case 5:
	{ // ����--����
		iRes = Item::eEP_YaoDai;
		break;
	}
	case 6:
	{ // ����
		iRes = Item::eEP_HuTui;
		break;
	}
	case 7:
	{ // Ь��
		iRes = Item::eEP_Shoes;
		break;
	}
	case 8:
	{ // ����
		iRes = Item::eEP_XianLian;
		break;
	}
	case 9:
	{ // ����
		iRes = Item::eEP_ErHuan;
		break;
	}
	case 10:
	{ // ���� �ռ�
		iRes = Item::eEP_HuiJi;
		break;
	}
	case 11:
	{ // ���ָ
		iRes = Item::eEP_LeftRing;
		break;
	}
	case 12:
	{ // �ҽ�ָ
		iRes = Item::eEP_RightRing;
		break;
	}
	case 13:
	{ // ������
		iRes = Item::eEP_MainArmor;
		break;
	}
	case 14:
	{ // ������
		iRes = Item::eEP_FuArmor;
		break;
	}
	case 80:
	{ // ����
		iRes = Item::eEP_Ride;
		break;
	}
	case 81:
	{ // ѫ��
		iRes = Item::eEP_Decoration;
		break;
	}
	}

	return iRes;
}