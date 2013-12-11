/*
 *  NDControlHelp.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (����)DeNA. All rights reserved.
 *
 */

#pragma once

#include "UIData.h"
#include "NDUILabel.h"
#include "NDUIButton.h"
#include "NDUIImage.h"
//#include "NDScrollLayer.h"
//#include "NDUITableLayer.h"
#include "NDPicture.h"
#include "NDUIScrollContainer.h"
#include "NDUIScrollView.h"
#include "NDTextNode.h"
#include "NDUIHyperlink.h"
#include "UICheckBox.h"
#include "UIRadioButton.h"
#include "NDUIExp.h"
#include "UIEdit.h"
#include "NDUISpriteNode.h"
#include "NDPath.h"
#include "NDWideString.h"
#include "NDUIScrollViewMulHand.h"
#include "NDUIScrollContainerExpand.h"
#include "NDUIBaseItemButton.h"
#include "ScriptGameDataLua.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif


using namespace NDEngine;

// �ؼ�����
enum MY_CONTROL_TYPE
{
	MY_CONTROL_TYPE_UNKNOWN,
	MY_CONTROL_TYPE_PICTURE,						// ͼƬ
	MY_CONTROL_TYPE_BUTTON,							// ��ť
	MY_CONTROL_TYPE_CHECK_BUTTON,					// ѡ��ť
	MY_CONTROL_TYPE_TEXT,							// �ı�
	MY_CONTROL_TYPE_UITEXT,							// UI�ı�(�ı�����ʾ��ͬ��ɫ)
	MY_CONTROL_TYPE_HYPER_TEXT,						// �����ı�
	MY_CONTROL_TYPE_HYPER_TEXT_BUTTON,				// ���Ӱ�ť
	MY_CONTROL_TYPE_LIST,							// �б�(ˮƽ��)
	MY_CONTROL_TYPE_EXP,							// ������
	MY_CONTROL_TYPE_PROGRESS,						// ������
	MY_CONTROL_TYPE_SLIDER,							// ������
	MY_CONTROL_TYPE_BACK,							// ����
	MY_CONTROL_TYPE_TABLE,							// ���
	MY_CONTROL_TYPE_LIST_M,							// ��ֱ���б�
	MY_CONTROL_TYPE_RADIO_BUTTON,					// ��ѡ��ť
	MY_CONTROL_TYPE_ITEM_BUTTON,					// ��Ʒ��ť
	MY_CONTROL_TYPE_EQUIP_BUTTON,					// װ����ť
	MY_CONTROL_TYPE_EDIT,							// �����
	MY_CONTROL_TYPE_SPRITE,							// ����
	MY_CONTROL_TYPE_LIST_HV,                        // ˮƽ+��ֱ���б�20
	MY_CONTROL_TYPE_LIST_LOOP,                      // ѭ��ˮƽ�б�21
};

class CtrolBase
{
protected:
	void Init(UIINFO& info, CCSize& sizeOffset)
	{
		m_info = info;
		
		m_sizeOffset = sizeOffset;
	}
	
	CCRect GetFrameRect()
	{
		CCRect rect = CCRectZero;
		
		rect.origin = ccpAdd(
							 m_info.CtrlPos, 
							 ccp(m_sizeOffset.width, m_sizeOffset.height));
		
		if (m_info.nCtrlWidth != 0 && m_info.nCtrlHeight != 0)
		{
			rect.size = CCSizeMake(m_info.nCtrlWidth, m_info.nCtrlHeight);
			return rect;
		}
		
		if (m_info.strNormalFile.empty()) 
		{
			NDAsssert(0);
			
			return rect;
		}
		
		NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(
							NDPath::GetUIImgPath(m_info.strNormalFile.c_str()) );
		
		rect.size = pic->GetSize();
		
		delete pic;
		
		return rect;
	}
	
	NDPicture* GetNormalPicture()
	{
		return GetPicture(m_info.strNormalFile, m_info.rectNormal);
	}
	
	NDPicture* GetSelectedPicture()
	{
		return GetPicture(m_info.strSelectedFile, m_info.rectSelected);
	}
	
	NDPicture* GetDisablePicture()
	{
		return GetPicture(m_info.strDisableFile, m_info.rectDisable);
	}
	
	NDPicture* GetFocusPicture()
	{
		return GetPicture(m_info.strFocusFile, m_info.rectFocus);
	}
	
	NDPicture* GetBackPicture()
	{
		return GetPicture(m_info.strBackFile, m_info.rectBack);
	}
	
	LabelTextAlignment GetTextAlign()
	{
		/*
		 "�����";
		 "�Ҷ���";
		 "ˮƽ����"
		 "��ֱ����"
		 "����"
		 */
		
		LabelTextAlignment align = LabelTextAlignmentLeft;
		CCLog("test %s", m_info.strTextAlign.c_str());
		if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("LeftAlign").c_str()) == 0) //�����
			align = LabelTextAlignmentLeft;

		else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("RightAlign").c_str()) == 0) //�Ҷ���
			align = LabelTextAlignmentRight;

		else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("HorzCenterAlign").c_str()) == 0) //ˮƽ���ж���
			align = LabelTextAlignmentHorzCenter;

		else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("VertCenterAlign").c_str()) == 0) //��ֱ���ж���
			align = LabelTextAlignmentVertCenter;

		else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("CenterAlign").c_str()) == 0) //���ж���
			align = LabelTextAlignmentCenter;

		return align;
	}
private:	
	NDPicture*	GetPicture(std::string& filename, CTRL_UV& uv)
	{
		//LOGD("GetPicture() filename is %s",filename.c_str());

		NDPicture* res = NULL;
		
		if (filename.empty())
		{
			return res;
		}
		
		if (m_info.nCtrlWidth != 0 && m_info.nCtrlHeight != 0)
		{ // ���� (����󲻽���u,v����)
			// ��ȡͼƬ��С����u,v�Ƚ�,��С��һ��˵���ǿ�ͼ,��������,��һ���Ժ���Էŵ�UI�༭��(ֱ�ӵ�������Ϣ)
			const string strTemp = NDPath::GetUIImgPath(filename.c_str());
			//LOGD("NDPath::GetUIImgPath(filename.c_str() return value is %s",strTemp.c_str());
			NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(strTemp.c_str());

			//LOGD("NDPicture *pic value is %d",(int)pic);

			if (pic)
			{
				CCSize size = pic->GetSize();
				if (uv.w <= int(size.width) && uv.h <= int(size.height))
				{
					pic->Cut(CCRectMake(uv.x, uv.y, uv.w, uv.h ) );
					
					return pic;
				}
			}
			
			res  = NDPicturePool::DefaultPool()->AddPicture(
															NDPath::GetUIImgPath(filename.c_str()),
															m_info.nCtrlWidth, m_info.nCtrlHeight );
			delete pic;
		}
		else
		{ // ������ (�۳�����ͼ�������촦��)
			res  = NDPicturePool::DefaultPool()->AddPicture(
															NDPath::GetUIImgPath(filename.c_str()) );
			
			if (uv.w != 0 && uv.h != 0)
			{
				res->Cut(CCRectMake(
									uv.x, uv.y, uv.w, uv.h ) );
			}
		}
		
		return res;
	}
	
protected:
	UIINFO m_info;
	CCSize m_sizeOffset;
};

template<typename CTROL>
class CtrolTrait : public CtrolBase
{
public:
	CTROL* Create(UIINFO& info, CCSize& sizeOffset) 
	{ 
		Init(info, sizeOffset);
		
		return NULL; 
	}
};

template<>
class CtrolTrait<NDUIImage> : public CtrolBase
{
public:
	NDUIImage* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUIImage *image = new NDUIImage;
		image->Initialization();
		image->SetFrameRect(this->GetFrameRect());
		image->SetPicture(GetNormalPicture(), true);
		return image;
	}
};

template<>
class CtrolTrait<NDUIButton> : public CtrolBase
{
public:
	NDUIButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUIButton *btn = new NDUIButton;
		btn->Initialization();
		btn->CloseFrame();
		btn->SetFrameRect(this->GetFrameRect());
		btn->SetImage(GetNormalPicture(), false, CCRectZero, true);
		btn->SetBackgroundPicture(GetBackPicture(), NULL, false, CCRectZero, true);
		btn->SetTouchDownImage(GetSelectedPicture(), false, CCRectZero, true);
		btn->SetFocusImage(GetFocusPicture(), false, CCRectZero, true);
		btn->SetDisImage(GetDisablePicture(), false, CCRectZero, true);
		btn->SetTitle(info.strText.c_str());
		btn->SetFontSize(info.nTextFontSize);
		btn->SetFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return btn;
	}
};

template<>
class CtrolTrait<CUICheckBox> : public CtrolBase
{
public:
	CUICheckBox* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		CUICheckBox *checkBox = new CUICheckBox;
		NDPicture* fileUnCheck	= NULL;
		NDPicture* fileCheck	= NULL;
		if (!m_info.strNormalFile.empty())
		{
			//fileUnCheck	= NDPath::GetUIImgPath(m_info.strNormalFile.c_str()).c_str();
			fileUnCheck = GetNormalPicture();
		}
		if (!m_info.strSelectedFile.empty())
		{
			fileCheck = GetSelectedPicture();
		}
		checkBox->Initialization(fileUnCheck, fileCheck);
		checkBox->SetFrameRect(this->GetFrameRect());
		checkBox->SetText(info.strText.c_str());
		checkBox->SetTextFontSize(info.nTextFontSize);
		checkBox->SetTextFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return checkBox;
	}
};

template<>
class CtrolTrait<NDUILabel> : public CtrolBase
{
public:
	NDUILabel* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUILabel *lb = new NDUILabel;
		lb->Initialization();
		lb->SetFrameRect(this->GetFrameRect());
		lb->SetText(info.strText.c_str());
		lb->SetTextAlignment(GetTextAlign());
		lb->SetFontSize(info.nTextFontSize);
		lb->SetFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return lb;
	}
};

template<>
class CtrolTrait<NDUIScrollViewContainer> : public CtrolBase
{
public:
	NDUIScrollViewContainer* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// ˮƽ��
		CCRect rect = this->GetFrameRect();
		NDUIScrollViewContainer *container = new NDUIScrollViewContainer;
		container->Initialization();
		container->SetStyle(UIScrollStyleHorzontal);
		container->SetFrameRect(rect);
		container->SetLeftReserveDistance(rect.size.width);
		container->SetRightReserveDistance(rect.size.width);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

template<>
class CtrolTrait<CUIScrollViewContainerM> : public CtrolBase
{
public:
	CUIScrollViewContainerM* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// ˮƽ��
		CCRect rect = this->GetFrameRect();
		CUIScrollViewContainerM *container = new CUIScrollViewContainerM;
		container->Initialization();
		container->SetFrameRect(rect);
		container->SetLeftReserveDistance(rect.size.width);
		container->SetRightReserveDistance(rect.size.width);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

template<>
class CtrolTrait<CUIScrollContainerExpand> : public CtrolBase
{
public:
	CUIScrollContainerExpand* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// ˮƽ��
		CCRect rect = this->GetFrameRect();
		CUIScrollContainerExpand *container = new CUIScrollContainerExpand;
		container->Initialization();
		container->SetFrameRect(rect);
		//container->SetLeftReserveDistance(rect.size.width);
		//container->SetRightReserveDistance(rect.size.width);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

/*
template<>
class CtrolTrait<NDUITableLayer> : public CtrolBase
{
public:
	NDUITableLayer* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		NDUITableLayer *table = new NDUITableLayer;
		table->Initialization();
		table->SetFrameRect(this->GetFrameRect());
		table->SetBackgroundColor(ccc4(0, 0, 0, 0));
		table->VisibleSectionTitles(false);
		table->VisibleScrollBar(false);
		table->SetCellsInterval(2);
		table->SetCellsRightDistance(0);
		table->SetCellsLeftDistance(0);
		return table;
	}
};
*/
template<>
class CtrolTrait<NDUIText> : public CtrolBase
{
public:
	NDUIText* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUIText *uitext = new NDUIText;
		uitext->Initialization(false);
		uitext->SetFontSize(info.nTextFontSize);
		uitext->SetFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		uitext->SetFrameRect(this->GetFrameRect());
		return uitext;
	}
};

template<>
class CtrolTrait<CUIHyperlinkText> : public CtrolBase
{
public:
	CUIHyperlinkText* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIHyperlinkText *linktext = new CUIHyperlinkText;
		linktext->Initialization();
		linktext->SetFrameRect(rect);
		linktext->SetLinkBoundRect(rect);
		linktext->SetLinkTextAlignment(GetTextAlign());
		linktext->SetLinkTextFontSize(info.nTextFontSize);
		linktext->SetLinkTextColor(INTCOLORTOCCC4(info.nTextFontColor));
		linktext->SetLinkText(info.strText.c_str());
		return linktext;
	}
};

template<>
class CtrolTrait<CUIHyperlinkButton> : public CtrolBase
{
public:
	CUIHyperlinkButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIHyperlinkButton *linkbtn = new CUIHyperlinkButton;
		linkbtn->Initialization();
		linkbtn->SetFrameRect(rect);
		linkbtn->SetLinkTextAlignment(GetTextAlign());
		linkbtn->SetLinkBoundRect(rect);
		linkbtn->SetLinkTextFontSize(info.nTextFontSize);
		linkbtn->SetLinkTextColor(INTCOLORTOCCC4(info.nTextFontColor));
		linkbtn->SetLinkText(info.strText.c_str());
		return linkbtn;
	}
};

template<>
class CtrolTrait<NDUIBaseItemButton> : public CtrolBase
{
public:
	NDUIBaseItemButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		NDUIBaseItemButton *itemBtn = CREATE_CLASS(NDUIBaseItemButton,"CUIItemButton");

		itemBtn->InitializationItem();
		itemBtn->SetItemFrameRect(rect);
		itemBtn->CloseItemFrame();

		itemBtn->SetItemBackgroundPicture(GetBackPicture(), NULL, false, CCRectZero, true);
		itemBtn->SetItemTouchDownImage(GetSelectedPicture(), false, CCRectZero, true);
		itemBtn->SetItemFocusImage(GetFocusPicture(), false, CCRectZero, true);

// 		itemBtn->Initialization();
// 		itemBtn->SetFrameRect(rect);
// 		itemBtn->CloseFrame();
// 		itemBtn->SetBackgroundPicture(GetBackPicture(), NULL, false, CCRectZero, true);
// 		itemBtn->SetTouchDownImage(GetSelectedPicture(), false, CCRectZero, true);
// 		itemBtn->SetFocusImage(GetFocusPicture(), false, CCRectZero, true);
		return itemBtn;
	}
};

template<>
class CtrolTrait<CUIEdit> : public CtrolBase
{
public:
	CUIEdit* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIEdit *edit = new CUIEdit;
		edit->Initialization();
		edit->SetFrameRect(rect);
		edit->SetTextSize(info.nTextFontSize);
		edit->SetTextColor(INTCOLORTOCCC4(info.nTextFontColor));
		edit->SetImage(GetNormalPicture());
		edit->SetFocusImage(GetFocusPicture());
		edit->SetTextAlignment(LabelTextAlignmentLeft);
		if(!info.strSelectedFile.empty())
		{
			edit->SetFocusImage(GetSelectedPicture());
		}
		return edit;
	}
};

template<>
class CtrolTrait<CUIExp> : public CtrolBase
{
public:
	CUIExp* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIExp *exp = new CUIExp;
		string bgfile;
		string processfile;
		if (!m_info.strNormalFile.empty())
		{
			bgfile	= NDPath::GetUIImgPath(m_info.strNormalFile.c_str());
		}
		if (!m_info.strSelectedFile.empty())
		{
			processfile	= NDPath::GetUIImgPath(m_info.strSelectedFile.c_str());
		}
		exp->Initialization(bgfile.c_str(), processfile.c_str());
		exp->SetFrameRect(this->GetFrameRect());
		exp->SetText(info.strText.c_str());
		exp->SetTextFontSize(info.nTextFontSize);
		exp->SetTextFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return exp;
	}
};

template<>
class CtrolTrait<CUISpriteNode> : public CtrolBase
{
public:
	CUISpriteNode* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUISpriteNode *sprite = new CUISpriteNode;
		sprite->Initialization();		
		sprite->SetFrameRect(this->GetFrameRect());
		if (!m_info.strNormalFile.empty())
		{
			sprite->ChangeSprite(NDPath::GetUIImgPath(m_info.strNormalFile.c_str()).c_str());
		}
		return sprite;
	}
};

template<int CtrolType>
class ControlHelp : public CtrolTrait<void>
{
};
					
template<>															
class ControlHelp<MY_CONTROL_TYPE_LIST_M> : public CtrolTrait<NDUIScrollViewContainer>		
{	
public:
	NDUIScrollViewContainer* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// ˮƽ��
		CCRect rect = this->GetFrameRect();
		NDUIScrollViewContainer *container = new NDUIScrollViewContainer;
		container->Initialization();
		container->SetStyle(UIScrollStyleVerical);
		container->SetFrameRect(rect);
		container->SetTopReserveDistance(rect.size.height);
		container->SetBottomReserveDistance(rect.size.height);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

template<>															
class ControlHelp<MY_CONTROL_TYPE_EQUIP_BUTTON> : public CtrolTrait<NDUIBaseItemButton>		
{	
public:
	NDUIBaseItemButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		NDUIBaseItemButton *equipBtn = CREATE_CLASS(NDUIBaseItemButton,"CUIEquipItem");
		equipBtn->InitializationItem();
		equipBtn->SetItemFrameRect(rect);
		equipBtn->CloseItemFrame();

		equipBtn->SetItemBackgroundPicture(GetBackPicture(), NULL, false, CCRectZero, true);
		equipBtn->SetItemTouchDownImage(GetSelectedPicture(), false, CCRectZero, true);
		equipBtn->SetItemFocusImage(GetFocusPicture(), false, CCRectZero, true);

// 		equipBtn->SetBackgroundPicture(GetBackPicture(), NULL, false, CCRectZero, true);
// 		equipBtn->SetTouchDownImage(GetSelectedPicture(), false, CCRectZero, true);
// 		equipBtn->SetFocusImage(GetFocusPicture(), false, CCRectZero, true);
		return equipBtn;
	}
};

template<>															
class ControlHelp<MY_CONTROL_TYPE_RADIO_BUTTON> : public CtrolTrait<CUICheckBox>		
{	
public:
	CUIRadioButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIRadioButton *radio = new CUIRadioButton;
		string fileUnCheck;
		string fileCheck;
		if (!m_info.strNormalFile.empty())
		{
			fileUnCheck	= NDPath::GetUIImgPath(m_info.strNormalFile.c_str());
		}
		if (!m_info.strSelectedFile.empty())
		{
			fileCheck	= NDPath::GetUIImgPath(m_info.strSelectedFile.c_str());
		}
		radio->Initialization(fileUnCheck.c_str(), fileCheck.c_str());
		radio->SetFrameRect(rect);
		radio->SetText(info.strText.c_str());
		radio->SetTextFontSize(info.nTextFontSize);
		radio->SetTextFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return radio;
	}
};

#pragma mark �ؼ�����

#define CtrolHelpDeclare(CONTROL_TYPE, CONTROL)						\
template<>															\
class ControlHelp<CONTROL_TYPE> : public CtrolTrait<CONTROL>		\
{																	\
};

CtrolHelpDeclare(MY_CONTROL_TYPE_UNKNOWN, NDUINode)
CtrolHelpDeclare(MY_CONTROL_TYPE_PICTURE, NDUIImage)
CtrolHelpDeclare(MY_CONTROL_TYPE_BUTTON, NDUIButton)
CtrolHelpDeclare(MY_CONTROL_TYPE_CHECK_BUTTON, CUICheckBox)
CtrolHelpDeclare(MY_CONTROL_TYPE_TEXT, NDUILabel)
CtrolHelpDeclare(MY_CONTROL_TYPE_LIST, NDUIScrollViewContainer)

CtrolHelpDeclare(MY_CONTROL_TYPE_LIST_HV, CUIScrollViewContainerM)
CtrolHelpDeclare(MY_CONTROL_TYPE_LIST_LOOP, CUIScrollContainerExpand)

CtrolHelpDeclare(MY_CONTROL_TYPE_PROGRESS, NDUINode)
CtrolHelpDeclare(MY_CONTROL_TYPE_SLIDER, NDUINode)
CtrolHelpDeclare(MY_CONTROL_TYPE_BACK, NDUIImage)
CtrolHelpDeclare(MY_CONTROL_TYPE_UITEXT, NDUIText)
CtrolHelpDeclare(MY_CONTROL_TYPE_HYPER_TEXT, CUIHyperlinkText)
CtrolHelpDeclare(MY_CONTROL_TYPE_HYPER_TEXT_BUTTON, CUIHyperlinkButton)
CtrolHelpDeclare(MY_CONTROL_TYPE_ITEM_BUTTON, NDUIBaseItemButton)
CtrolHelpDeclare(MY_CONTROL_TYPE_EXP, CUIExp)
CtrolHelpDeclare(MY_CONTROL_TYPE_EDIT, CUIEdit)
CtrolHelpDeclare(MY_CONTROL_TYPE_SPRITE, CUISpriteNode)
