/*
 *  ItemMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 (����)DeNA. All rights reserved.
 *
 */

#ifndef _ITEM_MGR_H_
#define _ITEM_MGR_H_

#include "Singleton.h"
#include "NDNetMsg.h"
#include "NDTransData.h"
#include "Item.h"
#include "define.h"
#include "globaldef.h"
#include "NDItemType.h"
#include "EnhancedObj.h"
#include <vector>
#include <map>

#define ItemMgrObj ItemMgr::GetSingleton()

using namespace NDEngine;

#define BAG_ITEM_NUM	(24)

struct EquipPropAddtions 
{
	int iPowerAdd;			// �������ӵ���
	int iTiZhiAdd;			// ���ʸ��ӵ���
	int iMinJieAdd;			// ���ݸ��ӵ���
	int iZhiLiAdd;			// �������ӵ���
	EquipPropAddtions()
	{
		memset(this, 0, sizeof(*this));
	}
};

class VipItem 
{
public:
	int vipType;
	int itemId;
	Item* item;
	int price;	
};

enum  
{
	ITEM_BAG = 0,
	ITEM_STORAGE,
	ITEM_EQUIP,
	ITEM_SOLD,
};

typedef std::vector<Item*> VEC_ITEM;
typedef VEC_ITEM::iterator VEC_ITEM_IT;

typedef std::vector<VipItem*>			vec_vip_item;
typedef vec_vip_item::iterator			vec_vip_item_it;

typedef std::map<int, vec_vip_item>		map_vip_item;
typedef map_vip_item::iterator			map_vip_item_it;
typedef std::pair<int, vec_vip_item>	map_vip_item_pair;

typedef std::map<int, std::string>		map_vip_desc;
typedef map_vip_desc::iterator			map_vip_desc_it;
typedef std::pair<int, std::string>		pair_vip_desc;


class ItemMgr : public TSingleton<ItemMgr>, public NDMsgObject
{
public:
	ItemMgr();
	~ItemMgr();
	void quitGame();
	/*�������Ȥ��������Ϣ*/
	bool process(MSGID msgID, NDTransData* data, int len); override	
public:
	EquipPropAddtions GetEquipAddtionProp();
private:
	/*�����Ʒ��Ϣ*/
	void processItemInfo(NDTransData* data, int len);
	/*���װ��Ч��*/
	void processEquipEffect(NDTransData* data, int len);
	void processItemAttrib(NDTransData* data, int len);
	void processItemDel(NDTransData* data, int len);
	void processItem(NDTransData* data, int len);
	void processStone(NDTransData* data, int len);
	void processStoneInfo(NDTransData* data, int len);
	void processLimit(NDTransData* data, int len);
	void processQueryDesc(NDTransData* data, int len);
	void processTidyUpBag(NDTransData* data, int len);
	void processItemKeeper(NDTransData* data, int len);
	void processShopCenter(NDTransData* data, int len);
	void processEquipSetCfg(NDTransData* data, int len);
	void processEquipBind(NDTransData* data, int len);
	void processShopCenterGoodsType(NDTransData& data);
	
public:	
	Item* GetEquipItemByPos(Item::eEquip_Pos pos) { if (pos<Item::eEP_Begin || pos>=Item::eEP_End) return NULL; else return m_EquipList[pos]; }
	bool EquipHasNotEffect(Item::eEquip_Pos pos) { if (pos<Item::eEP_Begin || pos>=Item::eEP_End) return true; else return roleEuiptItemsOK[pos]; }
	Item::eEquip_Pos getEquipListPos(Item* item);
	
	// ��ѯ ItemType ���ã���������ڴ��������
	NDItemType* QueryItemType(OBJID idItemType);
	int QueryPercentByLevel(int level);
	
	void ReplaceItemType(NDItemType* itemtype);
	
	EnhancedObj* QueryEnhancedType(int idEnhancedType);
private:
	void LoadItemTypeIndex();
	void LoadItemAddtion();
	
	// ��������
	void LoadEnhancedTypeIndex();
	
private:
	typedef map<OBJID/*id*/, NDItemType*> MAP_ITEMTYPE;
	typedef map<OBJID/*id*/, int/*offset*/> MAP_ITEMTYPE_INDEX;
	
	typedef map<int, EnhancedObj*> MAP_ENHANCEDTYPE;
	typedef MAP_ENHANCEDTYPE::iterator MAP_ENHANCEDTYPE_IT;
	typedef MAP_ITEMTYPE_INDEX MAP_ENHANCEDTYPE_INDEX;
	
	typedef map<int,int>	map_item_addtion;
	typedef map_item_addtion::iterator map_item_addtion_it;
	typedef pair<int,int>	map_item_addtion_pair;
	
	// ���ļ��ж�ȡitemtype��ƫ����
	MAP_ITEMTYPE_INDEX m_mapItemTypeIndex;
	// ��ǰ�����ڴ����Ʒ��������
	MAP_ITEMTYPE m_mapItemType;
	
	MAP_ENHANCEDTYPE m_mapEnhancedType;
	
	MAP_ENHANCEDTYPE_INDEX m_mapEnhancedTypeIndex;
	
	map_item_addtion m_mapItemAddtion;
public:
	// ������ز���
	void SetBagLitmit( int iLimit );
	bool IsBagFull();
	void GetBattleUsableItem(std::vector<Item*>& itemlist);
	void GetCanUsableItem(std::vector<Item*>& itemlist);
	void GetEnhanceItem(VEC_ITEM& itemlist);
	void SortBag();
	int GetBagItemCount(int iType);
	// iType = 0-����, 1-�ֿ�, 2-װ��, ������ھͷ��ظ���Ʒָ��
	bool HasItemByType(int iType, int iItemID, Item*& itemRes);
	// ������Ʒ���ͻ�ȡ���������Ʒ
	Item* GetBagItemByType(int idItemType);
	
	bool DelItem(int iType, int iItemID, bool bClear=true);
	bool UseItem(Item* item);
	
	VEC_ITEM& GetPlayerBagItems() {
		return m_vecBag;
	}
	int GetPlayerBagNum(){ return  m_iBags; }
	
	void RemoveOtherItems();
	Item* QueryOtherItem(int idItem);
	VEC_ITEM& GetOtherItem() { return m_vOtherItems;}
public:
	// �ֿ���ز���
	void SetStorageLitmit( int iLimit );
	VEC_ITEM& GetStorage() { return m_vecStorage; }
	int GetStorageNum() { return m_iStorages; }
public:
	// װ����ز���
	void SetRoleEuiptItemsOK(bool bValue, int iPos) { if(iPos < Item::eEP_Begin || iPos >= Item::eEP_End) return; roleEuiptItemsOK[iPos] = bValue; } 
	void unpackEquip(int iPos, bool bUpdateGui);
	void unpackEquipOfRole(int itemType);
	void setEquipState();
	void refreshEquipAmount(int itemId, int type);
	bool HasEquip(int iPos) { if(iPos < Item::eEP_Begin || iPos >= Item::eEP_End) return false; if (m_EquipList[iPos]) return true; return false; }
	Item* GetEquipItem(int iPos) { if(iPos < Item::eEP_Begin || iPos >= Item::eEP_End) return NULL; return (m_EquipList[iPos]); }
	Item* GetSuitItem(int idItem); // ��װ��ʹ�õ�
	void repackEquip();
public:
	// �̳���ز���
	map_vip_item& GetVipStore() { return m_mapVipItem; }
	void ClearVipItem();
	map_vip_desc& GetVipStoreDesc() { return m_mapVipDesc; }
public:
	// 2012.1.6 xwq
	Item* QueryItem(OBJID idItem);
	void RemoveSoldItems();
	void GetSoldItemsId(ID_VEC& vecId);
	
	bool ChangeItemPosSold(OBJID idItem, int nPos);	// ��Ʒ���ۺͻع�ʱ��λ��
private:
	//���װ���б�
	Item *m_EquipList[Item::eEP_End];

	bool roleEuiptItemsOK[Item::eEP_End];
	
	//�������
	VEC_ITEM		m_vecBag;
	int				m_iBags;
	
	//�ֿ����
	VEC_ITEM		m_vecStorage;
	int				m_iStorages;
	
	// ��ʱ������������Ʒ
	VEC_ITEM		m_vOtherItems;
	
	map_vip_item	m_mapVipItem;
	map_vip_desc	m_mapVipDesc;
	
	typedef std::map<OBJID, Item*>			MAP_ITEM;
	MAP_ITEM		m_mapSoldItems;
};

void sendItemUse(Item& item);
void sendDropItem(Item& item);
void sendItemRepair(int itemID, int action);
int GetItemPos(Item& item);

#endif // _ITEM_MGR_H_