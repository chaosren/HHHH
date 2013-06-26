/*
 *  NDCommonScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-11.
 *  Copyright 2011 (����)DeNA. All rights reserved.
 *
 */

#ifndef _ND_COMMON_SCENE_H_
#define _ND_COMMON_SCENE_H_

#include "NDUILayer.h"
#include "NDScene.h"
#include "NDUILabel.h"
#include "NDUIButton.h"
#include "NDUISpecialLayer.h"
#include "NDUIImage.h"

using namespace NDEngine;

//////////////////////////////////////////////////////////////
#pragma mark tab �ڵ�
class TabNode : public NDUINode
{
	DECLARE_CLASS(TabNode)
	
	TabNode();
	
	virtual ~TabNode();
public:
	void Initialization(); override
	
	// interface begin ...
	void SetImage(NDPicture *pic, NDPicture *focusPic, NDPicture* selPic=NULL);
	
	void SetText(const char *text);
	
	void SetTextColor(ccColor4B color, bool setBoder=false, ccColor4B colorBoder=ccc4(255, 255, 255, 255));
	
	void SetFocusColor(ccColor4B color, bool setBoder=false, ccColor4B colorBoder=ccc4(255, 255, 255, 255));
	
	void SetTextFontSize(unsigned int fontsize, bool horzontal=true, unsigned int verticalOffset=0);
	
	void SetFocus(bool focus);
	
	void ShowHorizontal(bool horizontal);
	
	void SetTextPicture(NDPicture* picText, NDPicture* picFocusText);
	
	// interface end ...
	
protected:
	
	void draw(); override
	
	void InitLabel();
	
protected:

	NDUILabel *m_lbText;
	
	NDPicture *m_pic, *m_picFocus;
	
	NDPicture *m_picFocusSel;
	
	NDPicture *m_picText, *m_picFocusText;
	
	bool m_focus;
	
	bool m_focusTextColor;
	
	ccColor4B m_textColor, m_focusColor;
	
	bool m_bHorizontal;
	
	unsigned int m_uiVerticalOffect;
};

class VerticalTabNode : public TabNode
{
	DECLARE_CLASS(VerticalTabNode)
	VerticalTabNode();
public:
	void SetFoucusOffset(int offset);
private:
	void draw(); override
	
	int m_iFocusOffset;
};

//////////////////////////////////////////////////////////////
#pragma mark tab��������
class TabLayer;

class TabLayerDelegate
{
public:
	virtual void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex) {}
	virtual void OnTabLayerClick(TabLayer* tab, uint curIndex) {}
	virtual void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage) {}
};

//////////////////////////////////////////////////////////////
#pragma mark tab����
class TabLayer : 
public NDUILayer
{
	DECLARE_CLASS(TabLayer)
	
	TabLayer();
	
	virtual ~TabLayer();
	
public:
	void Initialization(unsigned int interval=0); hide
	
	void SetTabNodeSize(CCSize size);
	
	virtual TabNode* CreateTabNode();
	
	TabNode* GetTabNode(unsigned int index);
	
	unsigned int GetTabNodeCount();
	
	virtual void SetFocusTabIndex(unsigned int index, bool dispatchEvent=false);
	
	void SetFocusTabNode(TabNode* tabnode, bool dispatchEvent=false);
	
	unsigned int GetFocusIndex();
	
	CCSize GetTabNodeSize();
	
	TabNode* GetFoucusTabNode();

protected:
	
	bool DispatchTouchEndEvent(CCPoint beginTouch, CCPoint endTouch); override
	
protected:
	
	unsigned int m_uiFocusIndex;
	
	unsigned int m_uiInterval;
	
	CCSize m_tabNodeSize;
};

//////////////////////////////////////////////////////////////
#pragma mark ˮƽ��tab����
class HorizontalTabLayer : public TabLayer
{
	DECLARE_CLASS(HorizontalTabLayer)
	
	HorizontalTabLayer();
	
public:
	TabNode* CreateTabNode(); override
	
	virtual void SetFocusTabIndex(unsigned int index, bool dispatchEvent=false);
	
	// call before CreateTabNode
	void SetCountPerPage(unsigned int count);
	
	bool IsShowPage();
	
	void NextPage();
	
	unsigned int GetPerPageCount() { return m_uiCountPerPage; }
	
private:
	bool m_ShowPage;
	
	unsigned int m_uiCountPerPage;
};

//////////////////////////////////////////////////////////////
#pragma mark ��ֱ��tab����
class VerticalTabLayer : public TabLayer
{
	DECLARE_CLASS(VerticalTabLayer)
	
public:
	
	VerticalTabNode* CreateTabNode(); override
};

//////////////////////////////////////////////////////////////
#pragma mark �ͻ������
class NDUIClientLayer;

class NDUIClientLayerDelegate
{
public:
	virtual void OnClientLayerTabSel(NDUIClientLayer* clientLayer, unsigned int lastIndex, unsigned int curIndex) {}
};

//////////////////////////////////////////////////////////////
#pragma mark �ͻ���
class NDUIClientLayer : 
public NDUIChildrenEventLayer,
public TabLayerDelegate
{
	DECLARE_CLASS(NDUIClientLayer)
	
	NDUIClientLayer();
	
	~NDUIClientLayer();
	
public:
	
	// ����һ������tab��ǩ(����һ��)
	// ʹ���߶Է��ص�tab������
	VerticalTabLayer* CreateFuncTab(unsigned int interval=0);
	
	// ��ȡ���ܲ�(����֮ǰ���Ѵ�����tab,�򷵻ض�Ӧ�ı�ǩ��)
	// ���Լ�����ʾ�ڵ�
	// ���ڱ�ǩ���л�����(���ܲ��л�)�ڲ����
	NDUILayer* GetFuncLayer(unsigned int index);
	
	TabNode* GetFuncTabNode(unsigned int index);
	
	unsigned int GetFuncTabNodeCount();
	
	void SetFocusFuncTabIndex(unsigned int index, bool dispatchEvent=false);
	
	void SetFocusFuncTabNode(TabNode* tabnode, bool dispatchEvent=false);
	
	unsigned int GetCurFuncTabIndex();
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
private:

	VerticalTabLayer* m_tab;
	
	std::vector<NDUILayer*> m_vClientLayer;
};

//////////////////////////////////////////////////////////////
#pragma mark ͨ�ý��泡��
class NDCommonScene : 
public NDScene,
public TabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonScene)
	
	NDCommonScene();
	
	~NDCommonScene();
	
public:
	void Initialization(bool showPage=false, unsigned int perPageCount=0); override
	
	// ����һ��tab��ǩ
	// ��ǩ������0��ʼ����
	// ͬʱΪ�ñ�ǩ������һ���ͻ���
	TabNode* AddTabNode();
	
	// ��ȡ��ǩ�Ŀͻ���
	// ����������ǻ�ȡ�ͻ����������ӽڵ�(����չ��),���ڱ�ǩ���л�����(�ͻ����л�)�ڲ����
	// ����ÿͻ�����Ҫ֧�ֶ������,���԰Ѽ���ڵ�Ĺ�������ת�Ƶ�NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	// ��ȡͨ�ò�
	// ͨ�ò���tab�޹� 
	// ͨ�ò�һֱ������ʾ״̬(������Ϊtab�л������ػ���ʾ)
	NDUILayer* CetGernalLayer(bool dealEvent,unsigned int zOrder=0);
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
	unsigned int GetCurTabIndex();
	
protected:
	bool OnBaseButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override

	void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage); override
protected:
	
	HorizontalTabLayer* m_tab;
	
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	NDUILayer						*m_genralLayer;
	NDUILayer						*m_genralEventLayer;
	
	unsigned int m_curTabIndex;
	
	unsigned int m_uiTabInterval;
	
	CCSize m_tabNodeSize;
	
protected:
	void InitTab(bool showPage=false, unsigned int perPageCount=0);
	
protected:
	NDUIButton *m_btnClose, *m_btnNext;
	
	NDUILayer  *m_layerBackground;
};

#pragma mark ����tab
class NDFuncTab :
public NDUILayer,
public TabLayerDelegate
{
	DECLARE_CLASS(NDFuncTab)

	NDFuncTab();
	
	~NDFuncTab();
	
public:
	
	void Initialization(unsigned int tabCount, CCPoint pos, CCSize sizeTabNode=CCSizeMake(25, 63), unsigned selHeight=0, unsigned unselHeight=0, bool bFullClient=false, int bgwidth=280); hide
	
	TabNode* GetTabNode(unsigned int index);
	
	// ��ȡ��ǩ�Ŀͻ���
	// ����������ǻ�ȡ�ͻ����������ӽڵ�(����չ��),���ڱ�ǩ���л�����(�ͻ����л�)�ڲ����
	// ����ÿͻ�����Ҫ֧�ֶ������,���԰Ѽ���ڵ�Ĺ�������ת�Ƶ�NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	void SetVisible(bool visible); override
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
protected:
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	void OnTabLayerClick(TabLayer* tab, uint curIndex); override

private:
	VerticalTabLayer* m_tab;
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	
};

#pragma mark �罻���ͳ���
class NDCommonSocialScene :
public NDScene,
public TabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonSocialScene)
	
	NDCommonSocialScene();
	
	~NDCommonSocialScene();
	
public:
	void Initialization(); override
	
	void InitTab(unsigned int tabCount, CCSize sizeTabNode=CCSizeMake(25, 63), unsigned selHeight=0, unsigned unselHeight=0);
	
	void SetClientLayerBackground(unsigned int tabIndex, bool bFullClient=false, int bgwidth=280);
	
	TabNode* GetTabNode(unsigned int tabIndex);
	
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
protected:
	bool OnBaseButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
protected:
	NDUIButton *m_btnClose;
	NDUILayer  *m_layerBackground;
	VerticalTabLayer* m_tab;
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	std::vector<NDUIImage*>			m_vClientBackground;
};

#pragma mark ˮƽ�͹���tab

class NDHFuncTab;

class HFuncTabDelegate
{
public:
	virtual void OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex) {}
	virtual void OnHFuncTabClick(NDHFuncTab* tab, uint curIndex) {}
};

class NDHFuncTab :
public NDUILayer,
public TabLayerDelegate
{
	DECLARE_CLASS(NDHFuncTab)
	
	NDHFuncTab();
	
	~NDHFuncTab();
	
public:
	
	void Initialization(unsigned int tabCount, CCSize sizeTabNode=CCSizeMake(70, 34), unsigned int interval=5); hide
	
	TabNode* GetTabNode(unsigned int index);
	
	// ��ȡ��ǩ�Ŀͻ���
	// ����������ǻ�ȡ�ͻ����������ӽڵ�(����չ��),���ڱ�ǩ���л�����(�ͻ����л�)�ڲ����
	// ����ÿͻ�����Ҫ֧�ֶ������,���԰Ѽ���ڵ�Ĺ�������ת�Ƶ�NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	void SetVisible(bool visible); override
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
protected:
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	void OnTabLayerClick(TabLayer* tab, uint curIndex); override
	
private:
	HorizontalTabLayer* m_tab;
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	NDUILayer *m_layerBackground;
	
};

#pragma mark ͨ�ý����
class NDCommonLayer : 
public NDUILayer,
public TabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonLayer)
	
	NDCommonLayer();
	
	~NDCommonLayer();
	
public:
	void Initialization(bool showPage=false, unsigned int perPageCount=0); override
	
	// maxTabNodeCharWidth-����tab�ڵ��ַ��Ŀ��
	void Initialization(float maxTabNodeCharWidth); override
	
	void OnButtonClick(NDUIButton* button); override
	
	virtual void SetVisible(bool visible); override
	
	// ����һ��tab��ǩ
	// ��ǩ������0��ʼ����
	// ͬʱΪ�ñ�ǩ������һ���ͻ���
	TabNode* AddTabNode();
	
	// ��ȡ��ǩ�Ŀͻ���
	// ����������ǻ�ȡ�ͻ����������ӽڵ�(����չ��),���ڱ�ǩ���л�����(�ͻ����л�)�ڲ����
	// ����ÿͻ�����Ҫ֧�ֶ������,���԰Ѽ���ڵ�Ĺ�������ת�Ƶ�NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	CCSize GetClientSize();
	
	// ��ȡͨ�ò�
	// ͨ�ò���tab�޹� 
	// ͨ�ò�һֱ������ʾ״̬(������Ϊtab�л������ػ���ʾ)
	NDUILayer* CetGernalLayer(bool dealEvent,unsigned int zOrder=0);
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
	unsigned int GetCurTabIndex();
	
protected:
	bool OnBaseButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage); override
protected:
	
	HorizontalTabLayer* m_tab;
	
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	NDUILayer						*m_genralLayer;
	NDUILayer						*m_genralEventLayer;
	
	unsigned int m_curTabIndex;
	
	unsigned int m_uiTabInterval;
	
	CCSize m_tabNodeSize;
	
protected:
	void InitTab(bool showPage=false, unsigned int perPageCount=0);
	
protected:
	NDUIButton *m_btnNext;
	
	NDUILayer  *m_layerBackground;
};


#endif // _ND_COMMON_SCENE_H_
