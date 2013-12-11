/*
 *  ScriptRegLua.cpp
 *  DragonDrive
 *
 *  Created by zhangwq on 12-11-30.
 *  Copyright 2012 (����)DeNA. All rights reserved.
 *	
 *	˵����C++��ע�ᵽLuaplus����ȷ����ʱ����ȷ���ķ���ע�ᣡƽ̨�޹أ�
 *			֮ǰ��ע��ʱ������ģ���ȫ�ֱ�����ʼ���������������á�������ȣ���ʱ��ע��ģ�
 *			�ڲ�ͬ���������в�ͬʵ�֣��ⲿ�ֲ�����C++��׼������ƽ̨��صģ����������Է��룩
 *
 */


#include "ScriptRegLua.h"
#include "ScriptDefine.h"
#include "ScriptMgr.h"

#include "NDMapLayer.h"
#include "NDNode.h"
#include "NDTransData.h"
#include "NDPicture.h"
#include "CCGeometry.h"
#include "UITabLogic.h"
#include "UIEdit.h"
#include "NDUISpriteNode.h"
#include "NDUIExp.h"
#include "UIRadioButton.h"
#include "UICheckBox.h"
#include "UIEquipItem.h"
#include "UIItemButton.h"
#include "NDUIHyperlink.h"
#include "UIRoleNode.h"
#include "NDUIScrollViewExpand.h"
#include "NDUIScrollViewMulHand.h"
#include "NDUIScrollContainerExpand.h""
#include "NDUIScrollView.h"
#include "NDUIScrollContainer.h"
#include "NDUIScroll.h"
#include "NDUIMovableLayer.h"
#include "NDUIChatText.h"
#include "NDUIDialog.h"
#include "NDUILabel.h"
#include "NDUIImage.h"
#include "NDUIButton.h"
#include "NDUILayer.h"
#include "NDUINode.h"
#include "NDScene.h"
#include "NDDirector.h"
#include "NDUILoad.h"
#include "NDJsonReader.h"

//@reglua: û����ע�ᣬֻ�Ǽ�¼��һ�Ѻ����ص�������ط�ͳһ����
void NDScriptRegLua::doReg()
{
	//��ͼ��ӿڵ���
	ETSUBCLASSBEGIN(NDMapLayer,NDNode);
	ETMEMBERFUNC("setStartRoadBlockTimer",			&NDMapLayer::setStartRoadBlockTimer);
	ETMEMBERFUNC("setAutoBossFight",				&NDMapLayer::setAutoBossFight)	;
	//ETMEMBERFUNC("IsBattleBackground",			&NDMapLayer::IsBattleBackground);	
	ETMEMBERFUNC("ShowTreasureBox",					&NDMapLayer::ShowTreasureBox);

	//** chh 2012-07-15 **//
	ETMEMBERFUNC("AddChild",                        (void (NDMapLayer::*)(NDNode*, int, int))&NDMapLayer::AddChild);
	ETMEMBERFUNC("RemoveChildByTag",                (void (NDMapLayer::*)(int, bool))&NDMapLayer::RemoveChild);
	ETCLASSEND(NDMapLayer);

	// �������ݴ����ർ��
	ETCLASSBEGIN(NDTransData);
	ETCONSTRUCTARG1("createNDTransData", int);
	ETDESTRUCT("Free");

	ETMEMBERFUNC("ReadByte", &NDTransData::ReadByte);
	ETMEMBERFUNC("ReadInt", &NDTransData::ReadInt);
	ETMEMBERFUNC("ReadShort", &NDTransData::ReadShort);
	ETMEMBERFUNC("ReadUnicodeString", (std::string (NDTransData::*)())&NDTransData::ReadUnicodeString);
	ETMEMBERFUNC("WriteByte", &NDTransData::WriteByte);
	ETMEMBERFUNC("WriteShort", &NDTransData::WriteShort);
	ETMEMBERFUNC("WriteInt", &NDTransData::WriteInt);
	ETMEMBERFUNC("WriteStr", (void (NDTransData::*)(const char*))&NDTransData::WriteUnicodeString);
	ETCLASSEND(NDTransData);

//#pragma mark ͼƬ��������
	// ��ɫ�ṹ����
	ETSTRUCTBEGIN(ccColor4B)
	ETSTRUCTPROP("r",								&ccColor4B::r)
	ETSTRUCTPROP("g",								&ccColor4B::g)
	ETSTRUCTPROP("b",								&ccColor4B::b)
	ETSTRUCTPROP("a",								&ccColor4B::a)
	ETSTRUCTEND(ccColor4B)
	
	ETSTRUCTBEGIN(ccColor3B)
	ETSTRUCTPROP("r",								&ccColor3B::r)
	ETSTRUCTPROP("g",								&ccColor3B::g)
	ETSTRUCTPROP("b",								&ccColor3B::b)
	ETSTRUCTEND(ccColor3B)
	
	// ͼƬ�ص���
	ETCLASSBEGIN(NDPicturePool)
	ETCFUNC("DefaultPicPool",						&NDPicturePool::DefaultPool)
	ETMEMBERFUNC("AddPicture",						(NDPicture* (NDPicturePool::*)(const char*, bool))&NDPicturePool::AddPicture)
	ETMEMBERFUNC("AddPictureEx",					(NDPicture* (NDPicturePool::*)(const char*, int, int, bool))&NDPicturePool::AddPicture)
	ETCLASSEND(NDPicturePool)
	
	// ͼƬ�ർ��
	ETCLASSBEGIN(NDPicture)
	//ETCONSTRUCTARG1("createNDPicture", bool)
	//ETDESTRUCT("Free")
	//ETMEMBERFUNC("Initialization",					(void (NDPicture::*)(const char*))&NDPicture::Initialization)
	//ETMEMBERFUNC("InitializationEx",				(void (NDPicture::*)(const char*, int, int))&NDPicture::Initialization)
	ETMEMBERFUNC("Cut",								&NDPicture::Cut)
	ETMEMBERFUNC("SetReverse",						&NDPicture::SetReverse)
	ETMEMBERFUNC("Rotation",						&NDPicture::Rotation)
	ETMEMBERFUNC("SetColor",						&NDPicture::SetColor)
	ETMEMBERFUNC("GetSize",							&NDPicture::GetSize)
	ETMEMBERFUNC("SetGrayState",					&NDPicture::SetGrayState)
	ETMEMBERFUNC("IsGrayState",						&NDPicture::IsGrayState)
    
    //** CHH 2012-08-01 **//
    ETMEMBERFUNC("SetIsTran",						&NDPicture::setIsTran)
	ETCLASSEND(NDPicture)
	
//#pragma mark UI����
	
//#pragma mark UI�ṹ����
	// ��С�ṹ����
	ETSTRUCTBEGIN(CCSize)
	ETSTRUCTPROP("w",								&CCSize::width)
	ETSTRUCTPROP("h",								&CCSize::height)
	ETSTRUCTEND(CCSize)
	
	// ��ṹ����
	ETSTRUCTBEGIN(CCPoint)
	ETSTRUCTPROP("x",								&CCPoint::x)
	ETSTRUCTPROP("y",								&CCPoint::y)
	ETSTRUCTEND(CCPoint)
	
	// ��Χ�ṹ����
	ETSTRUCTBEGIN(CCRect)
	ETSTRUCTPROP("origin",							&CCRect::origin)
	ETSTRUCTPROP("size",							&CCRect::size)
	ETSTRUCTEND(CCRect)
	
//#pragma mark UI���ص���
	ETCLASSBEGIN(NDUILoad)
	ETCONSTRUCT("createNDUILoad")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Load",							(bool (NDUILoad::*)(const char*, NDUINode *, LuaObject, CGFloat, CGFloat))&NDUILoad::LoadLua)
	ETCLASSEND(NDUILoad)
	
//#pragma mark �ڵ��ർ��"NDNode.h"
	// �ڵ��ർ��
	ETCLASSBEGIN(NDNode)
	ETCONSTRUCT("createNDNode")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&NDNode::Initialization)
	ETMEMBERFUNC("GetParent",						&NDNode::GetParent)
	ETMEMBERFUNC("RemoveAllChildren",				&NDNode::RemoveAllChildren)
	ETMEMBERFUNC("GetzOrder",						&NDNode::GetzOrder)
	ETMEMBERFUNC("GetTag",							&NDNode::GetTag)
	ETMEMBERFUNC("SetTag",							&NDNode::SetTag)
	ETMEMBERFUNC("AddChild",						(void (NDNode::*)(NDNode*))&NDNode::AddChild)
	ETMEMBERFUNC("AddChildZ",						(void (NDNode::*)(NDNode*, int))&NDNode::AddChild)
	ETMEMBERFUNC("AddChildZTag",					(void (NDNode::*)(NDNode*, int, int))&NDNode::AddChild)
	ETMEMBERFUNC("RemoveChild",						(void (NDNode::*)(NDNode*, bool))&NDNode::RemoveChild)
	ETMEMBERFUNC("RemoveChildByTag",				(void (NDNode::*)(int, bool))&NDNode::RemoveChild)
	ETMEMBERFUNC("ContainChild",					&NDNode::ContainChild)
	ETMEMBERFUNC("RemoveFromParent",				&NDNode::RemoveFromParent)
	ETMEMBERFUNC("GetChild",						&NDNode::GetChild)
	ETMEMBERFUNC("IsChildOf",						&NDNode::IsChildOf)
	ETMEMBERFUNC("DrawEnabled",						&NDNode::DrawEnabled)
	ETMEMBERFUNC("SetParam1",						&NDNode::SetParam1)
	ETMEMBERFUNC("SetParam2",						&NDNode::SetParam2)
	ETMEMBERFUNC("GetParam1",						&NDNode::GetParam1)
	ETMEMBERFUNC("GetParam2",						&NDNode::GetParam2)
	ETMEMBERFUNC("SetDestroyNotify",				&NDNode::SetDestroyNotify)
	ETCLASSEND(NDNode)

	/***
	* Json�����ļ��xȡ�  ����
	*/
	ETCLASSBEGIN(NDJsonReader)
	ETCONSTRUCT("createNDJsonReader")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("readJsonFile",&NDJsonReader::readJsonFile)
	ETMEMBERFUNC("readData",&NDJsonReader::readData)
	ETCLASSEND(NDJsonReader)
	
//#pragma mark �����ർ��"NDDirector.h"
	// �����ർ��
	ETCLASSBEGIN(NDDirector)
	ETCFUNC("DefaultDirector",						&NDDirector::DefaultDirector)
	ETMEMBERFUNC("PushScene",						&NDDirector::PushScene)
	ETMEMBERFUNC("PopScene",						(bool (NDDirector::*)(bool))&NDDirector::PopScene)
	ETMEMBERFUNC("GetRunningScene",					&NDDirector::GetRunningScene)
	ETMEMBERFUNC("GetWinSize",						&NDDirector::getWinSizeInPixels_Lua)
	ETMEMBERFUNC("SetViewRect",						&NDDirector::SetViewRect)
	ETMEMBERFUNC("ResumeViewRect",					&NDDirector::ResumeViewRect)
	ETMEMBERFUNC("GetSceneByTag",					&NDDirector::GetSceneByTag)
	ETMEMBERFUNC("GetScaleFactor",					&NDDirector::getResourceScale)
	ETMEMBERFUNC("GetCoordScaleX",					&NDDirector::getCoordScaleX)
	ETMEMBERFUNC("GetCoordScaleY",					&NDDirector::getCoordScaleY)
	ETMEMBERFUNC("IsEnableRetinaDisplay",			&NDDirector::IsEnableRetinaDisplay)
	ETCLASSEND(NDDirector)
	
//#pragma mark �����ർ��"NDScene.h"
	// �����ർ��
	ETSUBCLASSBEGIN(NDScene, NDNode)
	ETCFUNC("Scene",								&NDScene::Scene)
	ETCLASSEND(NDScene)
    
//#pragma mark  UI���ർ��"NDUINode.h"
	// UI���ർ��
	ETSUBCLASSBEGIN(NDUINode, NDNode)
	ETCONSTRUCT("createNDUINode")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&NDUINode::Initialization)
	ETMEMBERFUNC("SetFrameRect",					&NDUINode::SetFrameRect)
	ETMEMBERFUNC("GetFrameRect",					&NDUINode::GetFrameRect)
	ETMEMBERFUNC("SetVisible",						&NDUINode::SetVisible)
	ETMEMBERFUNC("IsVisibled",						&NDUINode::IsVisibled)
	ETMEMBERFUNC("EnableEvent",						&NDUINode::EnableEvent)
	ETMEMBERFUNC("EventEnabled",					&NDUINode::EventEnabled)
	ETMEMBERFUNC("GetScreenRect",					&NDUINode::GetScreenRect)
	ETMEMBERFUNC("SetLuaDelegate",					&NDUINode::SetLuaDelegate)
    // 1-����߷��� 2-���ұ߷��� 3-���Ϸ��� 4-���·���
    ETMEMBERFUNC("FlyToRect",                       &NDUINode::FlyToRect/*(CCRect rect, int nFrameNum, int nDirect)*/)
    ETMEMBERFUNC("SetBoundScale",					&NDUINode::SetBoundScale)
	ETCLASSEND(NDUINode)
	
//#pragma mark ���ർ��"NDUILayer.h"
	// ���ർ��
	ETSUBCLASSBEGIN(NDUILayer, NDUINode)
	ETCONSTRUCT("createNDUILayer")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("SetDebugName",					&NDUILayer::setDebugName)
	ETMEMBERFUNC("SetPopupDlgFlag",					&NDUILayer::setPopupDlgFlag)
	ETMEMBERFUNC("bringToTop",						&NDUILayer::bringToTop)
	ETMEMBERFUNC("bringToBottom",					&NDUILayer::bringToBottom)
	ETMEMBERFUNC("Init",							&NDUILayer::Initialization)
	ETMEMBERFUNC("SetBackgroundImage",				&NDUILayer::SetBackgroundImageLua)
	ETMEMBERFUNC("SetBackgroundFocusImage",			&NDUILayer::SetBackgroundFocusImageLua)
	ETMEMBERFUNC("SetBackgroundColor",				&NDUILayer::SetBackgroundColor)
    ETMEMBERFUNC("SetTouchEnabled",                 &NDUILayer::SetTouchEnabled)                //���
	ETMEMBERFUNC("SetFocus",						&NDUILayer::SetFocus)
	ETMEMBERFUNC("GetFocus",						&NDUILayer::GetFocus)
	ETMEMBERFUNC("lazyClose",						&NDUILayer::lazyDelete)
	ETCLASSEND(NDUILayer)
	
//#pragma mark ��ť�ർ��"NDUIButton.h"
	// ��ť�ർ��
	ETSUBCLASSBEGIN(NDUIButton, NDUINode)
	ETCONSTRUCT("createNDUIButton")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&NDUIButton::Initialization)
	ETMEMBERFUNC("SetImage",						&NDUIButton::SetImageLua)
	ETMEMBERFUNC("SetImageEx",						&NDUIButton::SetImageCustom)
	ETMEMBERFUNC("SetTouchDownImage",				&NDUIButton::SetTouchDownImageLua)
	ETMEMBERFUNC("SetTouchDownImageEx",				&NDUIButton::SetTouchDownImageCustom)
	ETMEMBERFUNC("SetTouchDownColor",				&NDUIButton::SetTouchDownColor)
	ETMEMBERFUNC("SetFocusColor",					&NDUIButton::SetFocusColor)
	ETMEMBERFUNC("SetFocusFontColor",				&NDUIButton::SetFocusFontColor)
	ETMEMBERFUNC("SetFocusImage",					&NDUIButton::SetFocusImageLua)
	ETMEMBERFUNC("SetFocusImageEx",					&NDUIButton::SetFocusImageCustom)
	ETMEMBERFUNC("OpenFrame",						&NDUIButton::OpenFrame)
	ETMEMBERFUNC("CloseFrame",						&NDUIButton::CloseFrame)
	ETMEMBERFUNC("SetTitle",						&NDUIButton::SetTitleLua)
	ETMEMBERFUNC("GetTitle",						&NDUIButton::GetTitle)
	ETMEMBERFUNC("SetFontColor",					&NDUIButton::SetFontColor)
	ETMEMBERFUNC("GetFontColor",					&NDUIButton::GetFontColor)
	ETMEMBERFUNC("SetBackgroundPicture",			&NDUIButton::SetBackgroundPictureLua)
	ETMEMBERFUNC("SetBackgroundPictureEx",			&NDUIButton::SetBackgroundPictureCustom)
	ETMEMBERFUNC("SetFontSize",						&NDUIButton::SetFontSize)
	ETMEMBERFUNC("GetFontSize",						&NDUIButton::GetFontSize)
	ETMEMBERFUNC("SetArrow",						&NDUIButton::SetArrow)
	ETMEMBERFUNC("EnalbeGray",						&NDUIButton::EnalbeGray)
	ETMEMBERFUNC("IsGray",							&NDUIButton::IsGray)
	ETMEMBERFUNC("EnalbelBackgroundGray",			&NDUIButton::EnalbelBackgroundGray)
	ETMEMBERFUNC("IsBackgroundGray",				&NDUIButton::IsBackgroundGray)
	ETMEMBERFUNC("SetNormalImageColor",				&NDUIButton::SetNormalImageColor)
	ETMEMBERFUNC("GetImage",						&NDUIButton::GetImage)
	ETMEMBERFUNC("GetImageCopy",					&NDUIButton::GetImageCopy)
	ETMEMBERFUNC("ChangeSprite",					&NDUIButton::ChangeSprite)
    ETMEMBERFUNC("SetFocus",                        &NDUIButton::SetFocus)
    ETMEMBERFUNC("SetSoundEffect",                  &NDUIButton::SetSoundEffect)
    ETMEMBERFUNC("SetChecked",                      &NDUIButton::SetChecked)
    //ETMEMBERFUNC("TabSel",                          &NDUIButton::TabSel)//&NDUIButton::TabSel)//Guosen 2012.11.22 ��ťģ��ѡ�...
	ETMEMBERFUNC("TabSel",                          &NDUIButton::SetChecked)//&NDUIButton::TabSel)//Guosen 2012.11.22 ��ťģ��ѡ�...
	ETCLASSEND(NDUIButton)
	
//#pragma mark ͼƬ�ർ��"NDUIImage.h"
	ETSUBCLASSBEGIN(NDUIImage, NDUINode)
	ETCONSTRUCT("createNDUIImage")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("GetPicture",						&NDUIImage::GetPicture)
	ETMEMBERFUNC("SetPicture",						&NDUIImage::SetPictureLua)
	ETCLASSEND(NDUIImage)
	
//#pragma mark ��ǩ�ർ����NDUILabel��
	ETSUBCLASSBEGIN(NDUILabel, NDUINode)
	ETCONSTRUCT("createNDUILabel")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("SetText",							&NDUILabel::SetText)
	ETMEMBERFUNC("GetText",							&NDUILabel::GetText)
	ETMEMBERFUNC("SetFontColor",					&NDUILabel::SetFontColor)
	ETMEMBERFUNC("GetFontColor",					&NDUILabel::GetFontColor)
	ETMEMBERFUNC("SetFontSize",						&NDUILabel::SetFontSize)
	ETMEMBERFUNC("GetFontSize",						&NDUILabel::GetFontSize)
	ETMEMBERFUNC("SetTextAlignment",				&NDUILabel::SetTextAlignment)
	ETMEMBERFUNC("GetTextAlignment",				&NDUILabel::GetTextAlignment)
	ETMEMBERFUNC("SetRenderTimes",					&NDUILabel::SetRenderTimes)
	ETMEMBERFUNC("GetRenderTimes",					&NDUILabel::GetRenderTimes)
	ETMEMBERFUNC("SetFontBoderColer",				&NDUILabel::SetFontBoderColer)
    
    //** chh 2012-08-14 **//
    ETMEMBERFUNC("SetHasFontBoderColor",			&NDUILabel::SetHasFontBoderColor)
    
	ETCLASSEND(NDUILabel)
	
//#pragma mark ��ǩ�ർ��"NDUIDialog.h"
	ETSUBCLASSBEGIN(NDUIDialog, NDUILayer)
	ETCONSTRUCT("createNDUIDialog")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Show0",							&NDUIDialog::Show0)
	ETMEMBERFUNC("Show1",							&NDUIDialog::Show1)
	ETMEMBERFUNC("Show2",							&NDUIDialog::Show2)
	ETMEMBERFUNC("Show3",							&NDUIDialog::Show3)
	ETMEMBERFUNC("Show4",							&NDUIDialog::Show4)
	ETMEMBERFUNC("Show5",							&NDUIDialog::Show5)
	ETMEMBERFUNC("Show6",							&NDUIDialog::Show6)
	ETMEMBERFUNC("Show7",							&NDUIDialog::Show7)
	ETMEMBERFUNC("Show8",							&NDUIDialog::Show8)
	ETMEMBERFUNC("Show9",							&NDUIDialog::Show9)
	ETMEMBERFUNC("Show10",							&NDUIDialog::Show10)
	ETCLASSEND(NDUIDialog)
	
//#pragma mark �����ı�����ർ����UIChatText.h��
	ETSUBCLASSBEGIN(CUIChatText,NDUINode)
	ETCONSTRUCT("createUIChatText")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIChatText::Initialization)
	ETMEMBERFUNC("SetContentWidth",					&CUIChatText::SetContentWidth)	
	ETMEMBERFUNC("SetContent",						&CUIChatText::SetContent)
	ETMEMBERFUNC("GetContentHeight",				&CUIChatText::GetContentHeight)	
	ETCLASSEND(CUIChatText)
//#pragma mark ���ƶ��㵼��"NDUIMovableLayer.h"
	ETSUBCLASSBEGIN(CUIMovableLayer, NDUILayer)
	ETCONSTRUCT("createUIMovableLayer")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIMovableLayer::Initialization)
	ETMEMBERFUNC("SetMovableViewer",				&CUIMovableLayer::SetMovableViewer)
	ETCLASSEND(CUIMovableLayer)
	
//#pragma mark �����ർ��"NDUIScroll.h"
	ETSUBCLASSBEGIN(CUIScroll, CUIMovableLayer)
	ETCONSTRUCT("createUIScroll")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIScroll::Initialization)
	ETMEMBERFUNC("SetScrollStyle",					&CUIScroll::SetScrollStyle)
	ETMEMBERFUNC("IsCanAccerate",					&CUIScroll::IsCanAccerate)
	ETMEMBERFUNC("IsInAccceratState",				&CUIScroll::IsInAccceratState)
	ETMEMBERFUNC("StopAccerate",					&CUIScroll::StopAccerate)
	ETMEMBERFUNC("GetScrollStyle",					&CUIScroll::GetScrollStyle)
	ETMEMBERFUNC("SetContainer",					&CUIScroll::SetContainer)
	ETCLASSEND(CUIScroll)
	
//#pragma mark ������������"UIScrollContainer.h"
	ETSUBCLASSBEGIN(NDUIScrollContainer, NDUILayer)
	ETCONSTRUCT("createUIScrollContainer")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&NDUIScrollContainer::Initialization)
	ETMEMBERFUNC("SetLeftReserveDistance",			&NDUIScrollContainer::SetLeftReserveDistance)
	ETMEMBERFUNC("SetRightReserveDistance",			&NDUIScrollContainer::SetRightReserveDistance)
	ETMEMBERFUNC("SetTopReserveDistance",			&NDUIScrollContainer::SetTopReserveDistance)
	ETMEMBERFUNC("SetBottomReserveDistance",		&NDUIScrollContainer::SetBottomReserveDistance)
	ETMEMBERFUNC("ScrollToTop",						&NDUIScrollContainer::ScrollToTop)
	ETMEMBERFUNC("ScrollToBottom",					&NDUIScrollContainer::ScrollToBottom)
	ETMEMBERFUNC("EnableScrollBar",					&NDUIScrollContainer::EnableScrollBar)
	ETCLASSEND(NDUIScrollContainer)
	
//#pragma mark ������ͼ����"UIScrollView.h"
	ETSUBCLASSBEGIN(CUIScrollView, CUIScroll)
	ETCONSTRUCT("createUIScrollView")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIScrollView::Initialization)
	ETMEMBERFUNC("SetScrollViewer",					&CUIScrollView::SetScrollViewer)
	ETMEMBERFUNC("SetViewId",						&CUIScrollView::SetViewId)
	ETMEMBERFUNC("GetViewId",						&CUIScrollView::GetViewId)
	ETCLASSEND(CUIScrollView)
	
	ETSUBCLASSBEGIN(NDUIScrollViewContainer, NDUIScrollContainer)
	ETCONSTRUCT("createUIScrollViewContainer")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",						&NDUIScrollViewContainer::Initialization)
	ETMEMBERFUNC("SetStyle",					&NDUIScrollViewContainer::SetStyle)
	ETMEMBERFUNC("GetScrollStyle",				&NDUIScrollViewContainer::GetScrollStyle)
	ETMEMBERFUNC("SetCenterAdjust",				&NDUIScrollViewContainer::SetCenterAdjust)
	ETMEMBERFUNC("IsCenterAdjust",				&NDUIScrollViewContainer::IsCenterAdjust)
	ETMEMBERFUNC("GetViewCount",				&NDUIScrollViewContainer::GetViewCount)
	ETMEMBERFUNC("SetViewSize",				&NDUIScrollViewContainer::SetViewSize)
	ETMEMBERFUNC("GetViewSize",				&NDUIScrollViewContainer::GetViewSize)
	ETMEMBERFUNC("AddView",						&NDUIScrollViewContainer::AddView)
	ETMEMBERFUNC("RemoveView",					&NDUIScrollViewContainer::RemoveView)
	ETMEMBERFUNC("RemoveViewById",				&NDUIScrollViewContainer::RemoveViewById)
	ETMEMBERFUNC("RemoveAllView",				&NDUIScrollViewContainer::RemoveAllView)
	ETMEMBERFUNC("ShowViewByIndex",				&NDUIScrollViewContainer::ShowViewByIndex)
	ETMEMBERFUNC("ShowViewById",				&NDUIScrollViewContainer::ShowViewById)
	ETMEMBERFUNC("ScrollViewByIndex",			&NDUIScrollViewContainer::ScrollViewByIndex)
	ETMEMBERFUNC("ScrollViewById",				&NDUIScrollViewContainer::ScrollViewById)
	ETMEMBERFUNC("GetView",						&NDUIScrollViewContainer::GetView)
	ETMEMBERFUNC("GetViewById",					&NDUIScrollViewContainer::GetViewById)
	ETMEMBERFUNC("GetBeginView",				&NDUIScrollViewContainer::GetBeginView)
	ETMEMBERFUNC("GetBeginIndex",				&NDUIScrollViewContainer::GetBeginIndex)
	ETMEMBERFUNC("EnableScrollBar",				&NDUIScrollViewContainer::EnableScrollBar)
	ETCLASSEND(NDUIScrollViewContainer)

    
    
    //** chh 2012-06-15 **//
//#pragma mark ������ͼ����"NDUIScrollViewMulHand.h"
	ETSUBCLASSBEGIN(CUIScrollViewM, CUIScroll)
	ETCONSTRUCT("createUIScrollViewM")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIScrollViewM::Initialization)
	ETMEMBERFUNC("SetScrollViewer",					&CUIScrollViewM::SetScrollViewer)
	ETMEMBERFUNC("SetViewId",						&CUIScrollViewM::SetViewId)
	ETMEMBERFUNC("GetViewId",						&CUIScrollViewM::GetViewId)
    ETMEMBERFUNC("SetViewPos",						&CUIScrollViewM::SetViewPos)
    ETMEMBERFUNC("GetViewPos",						&CUIScrollViewM::GetViewPos)
	ETCLASSEND(CUIScrollViewM)
	
    
    ETSUBCLASSBEGIN(ContainerClientLayerM, NDUILayer)
	ETCONSTRUCT("createContainerClientLayerM")
	ETDESTRUCT("Free")
    ETMEMBERFUNC("Init",                            &ContainerClientLayerM::Initialization)
    ETMEMBERFUNC("AddView",                         &ContainerClientLayerM::AddView)
    ETMEMBERFUNC("GetView",                         &ContainerClientLayerM::GetView)
    ETMEMBERFUNC("GetViewCount",                         &ContainerClientLayerM::GetViewCount)
    ETMEMBERFUNC("SetViewSize",                     &ContainerClientLayerM::SetViewSize)
    ETMEMBERFUNC("GetViewSize",                     &ContainerClientLayerM::GetViewSize)
    ETCLASSEND(ContainerClientLayerM)
    
    
	ETSUBCLASSBEGIN(CUIScrollViewContainerM, NDUIScrollContainer)
	ETCONSTRUCT("createUIScrollViewContainerM")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",						&CUIScrollViewContainerM::Initialization)
	ETMEMBERFUNC("SetCenterAdjust",				&CUIScrollViewContainerM::SetCenterAdjust)
	ETMEMBERFUNC("IsCenterAdjust",				&CUIScrollViewContainerM::IsCenterAdjust)
	ETMEMBERFUNC("GetViewCount",				&CUIScrollViewContainerM::GetViewCount)
	ETMEMBERFUNC("SetViewSize",                 &CUIScrollViewContainerM::SetViewSize)
	ETMEMBERFUNC("AddView",						&CUIScrollViewContainerM::AddView)
	ETMEMBERFUNC("RemoveView",					&CUIScrollViewContainerM::RemoveView)
	ETMEMBERFUNC("RemoveViewById",				&CUIScrollViewContainerM::RemoveViewById)
	ETMEMBERFUNC("RemoveAllView",				&CUIScrollViewContainerM::RemoveAllView)
	ETMEMBERFUNC("ShowViewByIndex",				&CUIScrollViewContainerM::ShowViewByIndex)
	ETMEMBERFUNC("ShowViewById",				&CUIScrollViewContainerM::ShowViewById)
	ETMEMBERFUNC("ScrollViewByIndex",			&CUIScrollViewContainerM::ScrollViewByIndex)
	ETMEMBERFUNC("ScrollViewById",				&CUIScrollViewContainerM::ScrollViewById)
	ETMEMBERFUNC("GetView",						&CUIScrollViewContainerM::GetView)
	ETMEMBERFUNC("GetViewById",					&CUIScrollViewContainerM::GetViewById)
	ETMEMBERFUNC("GetBeginView",				&CUIScrollViewContainerM::GetBeginView)
	ETMEMBERFUNC("GetBeginIndex",				&CUIScrollViewContainerM::GetBeginIndex)
	ETMEMBERFUNC("EnableScrollBar",				&CUIScrollViewContainerM::EnableScrollBar)
	ETCLASSEND(CUIScrollViewContainerM)
    
    
    //** chh 2012-07-24 **//
    ETSUBCLASSBEGIN(CUIScrollContainerExpand, NDUIScrollContainer)
	ETCONSTRUCT("createUIScrollContainerExpand")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",						&CUIScrollContainerExpand::Initialization)
	ETMEMBERFUNC("AddView",                     &CUIScrollContainerExpand::AddView)
    ETMEMBERFUNC("SetSizeView",                 &CUIScrollContainerExpand::SetSizeView)
    ETMEMBERFUNC("GetCurrentIndex",             &CUIScrollContainerExpand::GetCurrentIndex)
	ETMEMBERFUNC("GetViewCount",                &CUIScrollContainerExpand::GetViewCount)
    ETMEMBERFUNC("GetViewByIndex",              &CUIScrollContainerExpand::GetViewByIndex)
    ETMEMBERFUNC("GetPreIndex",                 &CUIScrollContainerExpand::GetPreIndex)
    ETCLASSEND(CUIScrollContainerExpand)
    
    ETSUBCLASSBEGIN(UIScrollViewExpand, NDUINode)
	ETCONSTRUCT("createUIScrollViewExpand")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&UIScrollViewExpand::Initialization)
	ETMEMBERFUNC("SetViewId",						&UIScrollViewExpand::SetViewId)
	ETMEMBERFUNC("GetViewId",						&UIScrollViewExpand::GetViewId)
	ETCLASSEND(UIScrollViewExpand)
    
    
//#pragma mark ��ɫUI�ڵ㵼��"UIRoleNode.h"
	ETSUBCLASSBEGIN(CUIRoleNode, NDUINode)
	ETCONSTRUCT("createUIRoleNode")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",						&CUIRoleNode::Initialization)
	ETMEMBERFUNC("ChangeLookFace",				&CUIRoleNode::ChangeLookFace)
	ETMEMBERFUNC("SetEquip",					&CUIRoleNode::SetEquip)
	ETMEMBERFUNC("SetMove",						&CUIRoleNode::SetMove)
	ETMEMBERFUNC("SetRoleScale",				&CUIRoleNode::SetRoleScale)
	ETMEMBERFUNC("SetRidePet",					&CUIRoleNode::SetRidePet)
	ETCLASSEND(CUIRoleNode)
	
//#pragma mark �������ı�����"NDUIHyperLink.h"
	ETSUBCLASSBEGIN(CUIHyperlinkText, NDUINode)
	ETCONSTRUCT("createUIHyperLink")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIHyperlinkText::Initialization)
	ETMEMBERFUNC("SetLinkBoundRect",				&CUIHyperlinkText::SetLinkBoundRect)
	ETMEMBERFUNC("SetLinkText",						&CUIHyperlinkText::SetLinkText)
	ETMEMBERFUNC("SetLinkTextFontSize",				&CUIHyperlinkText::SetLinkTextFontSize)
	ETMEMBERFUNC("SetLinkTextColor",				&CUIHyperlinkText::SetLinkTextColor)
	ETMEMBERFUNC("EnableLine",						&CUIHyperlinkText::EnableLine)
	ETMEMBERFUNC("SetLinkTextAlignment",			&CUIHyperlinkText::SetLinkTextAlignment)
	ETCLASSEND(CUIHyperlinkText)
	
//#pragma mark �����Ӱ�ť����"NDUIHyperLink.h"
	ETSUBCLASSBEGIN(CUIHyperlinkButton, NDUIButton)
	ETCONSTRUCT("createUIHyperlinkButton")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIHyperlinkButton::Initialization)
	ETMEMBERFUNC("SetLinkBoundRect",				&CUIHyperlinkButton::SetLinkBoundRect)
	ETMEMBERFUNC("SetLinkText",						&CUIHyperlinkButton::SetLinkText)
	ETMEMBERFUNC("SetLinkTextFontSize",				&CUIHyperlinkButton::SetLinkTextFontSize)
	ETMEMBERFUNC("SetLinkTextColor",				&CUIHyperlinkButton::SetLinkTextColor)
	ETMEMBERFUNC("EnableLine",						&CUIHyperlinkButton::EnableLine)
	ETMEMBERFUNC("SetLinkTextAlignment",			&CUIHyperlinkButton::SetLinkTextAlignment)
	ETCLASSEND(CUIHyperlinkButton)
	
//#pragma mark ��Ʒ��ť "UIItemButton.h"
	ETSUBCLASSBEGIN(CUIItemButton, NDUIButton)
	ETCONSTRUCT("createUIItemButton")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("ChangeItem",						&CUIItemButton::ChangeItem)
	ETMEMBERFUNC("GetItemId",						&CUIItemButton::GetItemId)
	ETMEMBERFUNC("ChangeItemType",					&CUIItemButton::ChangeItemType)
	ETMEMBERFUNC("GetItemType",						&CUIItemButton::GetItemType)
	ETMEMBERFUNC("RefreshItemCount",				&CUIItemButton::RefreshItemCount)
	ETMEMBERFUNC("SetLock",							&CUIItemButton::SetLock)
	ETMEMBERFUNC("IsLock",							&CUIItemButton::IsLock)
	ETMEMBERFUNC("SetShowAdapt",					&CUIItemButton::SetShowAdapt)
	ETMEMBERFUNC("GetItemCount",					&CUIItemButton::GetItemCount)
	ETCLASSEND(CUIItemButton)
	
	ETSUBCLASSBEGIN(CUIEquipItem, CUIItemButton)
	ETCONSTRUCT("createUIEquipItem")
	ETDESTRUCT("Free")
    
    ETMEMBERFUNC("SetUpgrade",				&CUIEquipItem::SetUpgrade)
    ETMEMBERFUNC("GetUpgrade",				&CUIEquipItem::GetUpgrade)
    
    
	ETMEMBERFUNC("GetUpgradeIconPos",				&CUIEquipItem::GetUpgradeIconPos)
    ETMEMBERFUNC("SetUpgradeIconPos",				&CUIEquipItem::SetUpgradeIconPos)
    
	ETCLASSEND(CUIEquipItem)
	
//#pragma mark Check��ť "UICheckBox.h"
	ETSUBCLASSBEGIN(CUICheckBox, NDUINode)
	ETCONSTRUCT("createUICheckBox")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							(void (CUICheckBox::*)(const char*, const char*))&CUICheckBox::Initialization)
	ETMEMBERFUNC("SetSelect",						&CUICheckBox::SetSelect)
	ETMEMBERFUNC("IsSelect",						&CUICheckBox::IsSelect)
	ETMEMBERFUNC("SetText",							&CUICheckBox::SetText)
	ETMEMBERFUNC("GetText",							&CUICheckBox::GetText)
	ETMEMBERFUNC("SetTextFontColor",				&CUICheckBox::SetTextFontColor)
	ETMEMBERFUNC("SetTextFontSize",					&CUICheckBox::SetTextFontSize)
	ETCLASSEND(CUICheckBox)
	
//#pragma mark ��ѡ��ť����ѡ��(���ʹ��)
	ETSUBCLASSBEGIN(CUIRadioButton, CUICheckBox)
	ETCONSTRUCT("createUIRadioButton")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							(void (CUIRadioButton::*)(const char*, const char*))&CUIRadioButton::Initialization)
	ETCLASSEND(CUIRadioButton)
	
	ETSUBCLASSBEGIN(CUIRadioGroup, NDUINode)
	ETCONSTRUCT("createUIRadioGroup")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("AddRadio",						&CUIRadioGroup::AddRadio)
	ETMEMBERFUNC("ContainRadio",					&CUIRadioGroup::ContainRadio)
	ETMEMBERFUNC("SetIndexSelected",				&CUIRadioGroup::SetIndexSelected)
	ETMEMBERFUNC("SetRadioSelected",				&CUIRadioGroup::SetRadioSelected)
	ETMEMBERFUNC("GetSelectedRadio",				&CUIRadioGroup::GetSelectedRadio)
	ETMEMBERFUNC("GetSelectedIndex",				&CUIRadioGroup::GetSelectedIndex)
	ETCLASSEND(CUIRadioGroup)
	
//#pragma mark ������ "NDUIExp.h"
	ETSUBCLASSBEGIN(CUIExp, NDUINode)
	ETCONSTRUCT("createUIExp")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							(void (CUIExp::*)(const char*, const char*))&CUIExp::Initialization)
	ETMEMBERFUNC("SetStart",						&CUIExp::SetStart)
	ETMEMBERFUNC("SetProcess",						&CUIExp::SetProcess)
	ETMEMBERFUNC("SetTotal",						&CUIExp::SetTotal)
    ETMEMBERFUNC("SetStyle",                        &CUIExp::SetStyle)
	ETMEMBERFUNC("GetStart",						&CUIExp::GetStart)
	ETMEMBERFUNC("GetProcess",						&CUIExp::GetProcess)
	ETMEMBERFUNC("GetTotal",						&CUIExp::GetTotal)
	ETMEMBERFUNC("SetText",							&CUIExp::SetText)
	ETMEMBERFUNC("SetTextFontColor",				&CUIExp::SetTextFontColor)
	ETMEMBERFUNC("SetTextFontSize",					&CUIExp::SetTextFontSize)
	ETCLASSEND(CUIExp)
	
//#pragma mark �����ؼ� "NDUISpriteNode.h"
	ETSUBCLASSBEGIN(CUISpriteNode, NDUINode)
	ETCONSTRUCT("createUISpriteNode")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUISpriteNode::Initialization)
	ETMEMBERFUNC("ChangeSprite",					&CUISpriteNode::ChangeSprite)
	ETMEMBERFUNC("SetAnimation",					&CUISpriteNode::SetAnimation)
	ETMEMBERFUNC("SetPlayFrameRange",				&CUISpriteNode::SetPlayFrameRange)
	ETMEMBERFUNC("SetScale",						&CUISpriteNode::SetScale)
	ETMEMBERFUNC("GetScale",						&CUISpriteNode::GetScale)
	ETMEMBERFUNC("GetAnimationAmount",				&CUISpriteNode::GetAnimationAmount)
	ETMEMBERFUNC("PlayAnimation",					&CUISpriteNode::PlayAnimation)
	ETMEMBERFUNC("IsAnimationComplete",				&CUISpriteNode::IsAnimationComplete)
	ETCLASSEND(CUISpriteNode)
	
//#pragma mark �༭��ؼ� "UIEdit.h"
	ETSUBCLASSBEGIN(CUIEdit, NDUINode)
	ETCONSTRUCT("createUIEdit")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIEdit::Initialization)
	ETMEMBERFUNC("SetText",							&CUIEdit::SetText)
	ETMEMBERFUNC("GetText",							&CUIEdit::GetText)
	ETMEMBERFUNC("SetPassword",						&CUIEdit::SetPassword)
	ETMEMBERFUNC("IsPassword",						&CUIEdit::IsPassword)
	ETMEMBERFUNC("SetMaxLength",					&CUIEdit::SetMaxLength)
	ETMEMBERFUNC("GetMaxLength",					&CUIEdit::GetMaxLength)
	ETMEMBERFUNC("SetMinLength",					&CUIEdit::SetMinLength)
	ETMEMBERFUNC("GetMinLength",					&CUIEdit::GetMinLength)
	ETMEMBERFUNC("SetImage",						&CUIEdit::SetImage)
	ETMEMBERFUNC("SetFocusImage",					&CUIEdit::SetFocusImage)
	ETMEMBERFUNC("EnableAdjustView",				&CUIEdit::EnableAdjustView)
	ETMEMBERFUNC("IsTextLessMinLen",				&CUIEdit::IsTextLessMinLen)
	ETMEMBERFUNC("IsTextLessMinLen",				&CUIEdit::IsTextMoreMaxLen)
	ETMEMBERFUNC("SetTextColor",					&CUIEdit::SetTextColor)
    ETMEMBERFUNC("SetFlag",                         &CUIEdit::SetFlag)
	ETMEMBERFUNC("GetFlag",                         &CUIEdit::GetFlag)
 	ETMEMBERFUNC("SetFocus",                         &CUIEdit::SetFocus)   
	ETCLASSEND(CUIEdit)
	
//#pragma mark �༭��ؼ� "UIList.h"
#if 0
	ETSTRUCTBEGIN(LIST_ATTR_SEC)
	ETSTRUCTPROP("secw",								&LIST_ATTR_SEC::unSectionWidth)
	ETSTRUCTPROP("sech",								&LIST_ATTR_SEC::unSectionHeight)
	ETSTRUCTPROP("lInner",								&LIST_ATTR_SEC::unContentLInner)
	ETSTRUCTPROP("rInner",								&LIST_ATTR_SEC::unContentRInner)
	ETSTRUCTPROP("tInner",								&LIST_ATTR_SEC::unContentTInner)
	ETSTRUCTPROP("bInner",								&LIST_ATTR_SEC::unContentBInner)
	ETSTRUCTPROP("cellInner",							&LIST_ATTR_SEC::unCellInner)
	ETSTRUCTPROP("cellw",								&LIST_ATTR_SEC::unCellWidth)
	ETSTRUCTPROP("cellh",								&LIST_ATTR_SEC::unCellHeight)
	ETSTRUCTEND(LIST_ATTR_SEC)
	
	ETSUBCLASSBEGIN(CUIListCell, NDUINode)
	ETCONSTRUCT("createListCell")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIListCell::Initialization)
	ETMEMBERFUNC("SetText",							&CUIListCell::SetText)
	ETMEMBERFUNC("GetText",							&CUIListCell::GetText)
	ETMEMBERFUNC("SetFontSize",						&CUIListCell::SetFontSize)
	ETMEMBERFUNC("SetFontColor",					&CUIListCell::SetFontColor)
	ETMEMBERFUNC("SetBGPicture",					&CUIListCell::SetBGPicture)
	ETMEMBERFUNC("SetCellId",						&CUIListCell::SetCellId)
	ETMEMBERFUNC("GetCellId",						&CUIListCell::GetCellId)
	ETCLASSEND(CUIListCell)
	ETSUBCLASSBEGIN(CUIListSection, NDUINode)
	ETCONSTRUCT("createListSection")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIListSection::Initialization)
	ETMEMBERFUNC("SetAttr",							&CUIListSection::SetAttr)
	ETMEMBERFUNC("SetText",							&CUIListSection::SetText)
	ETMEMBERFUNC("GetText",							&CUIListSection::GetText)
	ETMEMBERFUNC("SetFontSize",						&CUIListSection::SetFontSize)
	ETMEMBERFUNC("SetFontColor",					&CUIListSection::SetFontColor)
	ETMEMBERFUNC("SetBGPicture",					&CUIListSection::SetBGPicture)
	ETMEMBERFUNC("SetStatePicture",					&CUIListSection::SetStatePicture)
	ETMEMBERFUNC("SetInnerPicture",					&CUIListSection::SetInnerPicture)
	ETMEMBERFUNC("SetSectionId",					&CUIListSection::SetSectionId)
	ETMEMBERFUNC("GetSectionId",					&CUIListSection::GetSectionId)
	ETMEMBERFUNC("GetFocusIndex",					&CUIListSection::GetFocusIndex)
	ETMEMBERFUNC("GetFocusId",						&CUIListSection::GetFocusId)
	ETMEMBERFUNC("CellCount",						&CUIListSection::CellCount)
	ETMEMBERFUNC("IsExpand",						&CUIListSection::IsExpand)
	ETCLASSEND(CUIListSection)
#endif
	
   #if 0
 ETSUBCLASSBEGIN(CUIList, NDUILayer)
	ETCONSTRUCT("createUIList")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("Init",							&CUIList::Initialization)
	ETMEMBERFUNC("SetSectionInner",					&CUIList::SetSectionInner)
	ETMEMBERFUNC("SetScrollBarWidth",				&CUIList::SetScrollBarWidth)
	ETMEMBERFUNC("GetScrollBarWidth",				&CUIList::GetScrollBarWidth)
	ETMEMBERFUNC("AddSection",						&CUIList::AddSection)
	ETMEMBERFUNC("RemoveSection",					&CUIList::RemoveSection)
	ETMEMBERFUNC("RemoveSectionByIndex",			&CUIList::RemoveSectionByIndex)
	ETMEMBERFUNC("RemoveAllSection",				&CUIList::RemoveAllSection)
	ETMEMBERFUNC("AddCell",							&CUIList::AddCell);
	ETMEMBERFUNC("RemoveCell",						&CUIList::RemoveCell)
	ETMEMBERFUNC("RemoveCellByIndex",				&CUIList::RemoveCellByIndex)
	ETMEMBERFUNC("RemoveAllCell",					&CUIList::RemoveAllCell)
	ETMEMBERFUNC("Expand",							&CUIList::Expand)
	ETMEMBERFUNC("ExpandWithIndex",					&CUIList::ExpandWithIndex)
	ETCLASSEND(CUIList)
#endif
    
//#pragma mark �༭��ؼ� "UITabLogic.h"
	ETSUBCLASSBEGIN(CUITabLogic, NDUINode)
	ETCONSTRUCT("createUITabLogic")
	ETDESTRUCT("Free")
	ETMEMBERFUNC("AddTab",							&CUITabLogic::AddTab)
	ETMEMBERFUNC("Select",							&CUITabLogic::Select)
	ETMEMBERFUNC("SelectWithIndex",					&CUITabLogic::SelectWithIndex)
	ETCLASSEND(CUITabLogic)
	
}