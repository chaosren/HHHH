/*
 *  NewGamePetBag.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUILayer.h"
#include "NDUIItemButton.h"
#include "NDPicture.h"
#include "NDUIImage.h"
#include "Item.h"
#include "NDUIBaseGraphics.h"
#include "define.h"
#include "NDUIDialog.h"
#include "ImageNumber.h"
#include "GameNewItemBag.h"
#include "UiPetDefine.h"


class CUIItemInfo :	// 物品信息
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(CUIItemInfo)
public:
	CUIItemInfo();
	~CUIItemInfo();
	
	bool Init();
	void EnableOperate(bool bEnable);
	void RefreshItemInfo(Item* pItem);
	
	void OnButtonClick(NDUIButton* button);

	virtual void SetVisible(bool bVisible);
protected:
	void ClearInfo();
	void UpdateButton();
	NDUIButton* CreateButton(const char* pszTitle);
private:
	NDUIImage* m_pImage;
	NDUILabel* m_pLableName;
	NDUILabel* m_pLableLevel;
	NDUILabelScrollLayer* m_pSrcLableInfo;
	
	bool		m_bEnable;
	
	enum { BUTTON_W = 48, BUTTON_H = 24, };
	NDUIButton* m_pBtnUse;
	bool		m_bUse;
	NDUIButton* m_pBtnDrop;
	bool		m_bDrop;
	NDUIButton*	m_pBtnClose;
};



class NewGamePetBag;

class NewGamePetBagDelegate
{
public:
	virtual void OnClickPage(NewGamePetBag* petbag, int iPage)													{}
	/**bFocused,表示该事件发生前该Cell是否处于Focus状态*/
	virtual bool OnClickCell(NewGamePetBag* petbag, int iPage, int iCellIndex, Item* item, bool bFocused)		{ return false;}
	/*ret=true*/
	virtual void AfterClickCell(NewGamePetBag* petbag, int iPage, int iCellIndex, Item* item, bool bFocused)		{}
	
	// 外部只需要处理卸载装备
	virtual bool OnBagButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch, bool del) { return false; }
	
	virtual bool OnDropItem(NewGamePetBag* petbag, Item* item) { return false; }
};

class NewGamePetBag : public NDUILayer , public NDUIButtonDelegate, public NDUIDialogDelegate
{
	DECLARE_CLASS(NewGamePetBag)
public:
	NewGamePetBag();
	~NewGamePetBag();
	
	void Initialization(vector<Item*>& itemlist); override
	void SetPageCount(int iPage){ if(iPage<=0) return; m_iTotalPage = iPage > NEW_MAX_PAGE_COUNT ? NEW_MAX_PAGE_COUNT : iPage; }
	void draw(); override
	void OnButtonClick(NDUIButton* button); override
	
	bool OnButtonLongClick(NDUIButton* button); override
	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void UpdatePetBag(vector<Item*>& itemlist);
	void UpdatePetBag(vector<Item*>& itemlist, vector<int> filter);
	bool AddItem(Item* item);
	bool DelItem(int iItemID);
	bool AddItemByIndex(int iCellIndex, Item* item);
	bool DelItemByIndex(int iCellIndex);
	bool IsFocus();
	void DeFocus();
	Item* GetFocusItem();
	
	NDUIItemButton* GetFocusItemBtn();
	
	// 获取某页某个索引物品
	Item* GetItem(int iPage, int iIndex);
	
	void ShowPage(int iPage);
	
	int GetCurPage() { return m_iCurpage; }
	
	NDUIItemButton* GetItemBtnByItem(Item* item);
	
	//该接口只提供给网络消息用来设置背包数
	static void UpdateBagNum(int iNum);
	
	bool SetItemAmountByID(int iItemID, unsigned int amount);
	bool SetItemAmount(Item* item, unsigned int amount);
	
	void SendUseItemMsg(OBJID idPet, OBJID idItem);
	void SendDropItemMsg(OBJID idItem);
	void SendUnloadItemMsg(OBJID idPet, OBJID idItem);
	
	void SetVisible(bool visible); override
private:
	NDUIItemButton* GetItemButtonByItemID(int iItemID);
	void ShowFocus();
	void HidePage(int iPage);
	void InitCellItem(int iIndex, Item* item, bool bShow);
	NDPicture* GetPagePic(unsigned int num, bool bHightLight);
	
private:
	NDUIItemButton* m_arrCellInfo[NEW_MAX_CELL_PER_PAGE*NEW_MAX_PAGE_COUNT];
	NDUILayer *m_backlayer;
	NDUIButton *m_btnPages[NEW_MAX_PAGE_COUNT]; NDPicture *m_picPages[NEW_MAX_PAGE_COUNT];
	NDUIImage *m_imagePages[NEW_MAX_PAGE_COUNT];
	NDUILayer *m_pageLayer;
	int m_iCurpage;
	int m_iFocusIndex;
	ItemFocus *m_itemfocus;
	
	NDUIImage *m_imageMouse;
	
	NDUIButton *m_btnDrop; // 丢弃
	
	ImageNumber *m_imageNumInfo[3];
		
	enum {
		OPERATOR_USE	= 1,
		OPERATOR_DROP,
		OPERATOR_ENLARGE_BAG,
	};
	OBJID		m_idOperatePet;
	OBJID		m_idOperateItem;
public:
	static int m_iTotalPage;
};