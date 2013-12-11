/*
 *  UIEdit.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 ����(DeNA). All rights reserved.
 *
 */




#ifndef _UI_EDIT_H_ZJH_
#define _UI_EDIT_H_ZJH_

#include "NDPicture.h"
#include "CommonInput.h"
#include "NDUINode.h"
#include "NDUILabel.h"
#include "NDDirector.h"
#include "CCIMEDelegate.h"

using namespace NDEngine;

#define TEXT_LEFT_BORDER	(5*RESOURCE_SCALE)	//�������߾�����
#define TEST_TEXT			"��"				//������������ȡ���ִ�С

#define WITH_NEW_IME 1							//�Ƿ������µ����뷨����
#define WITH_OLD_IME (!WITH_NEW_IME)


////////////////////////////////////////////////////////////////////////
class CUIEdit : public NDUINode
				#if WITH_NEW_IME
					,public CCIMEDelegate
				#else
					,public CInputBase	
				#endif
{
	DECLARE_CLASS(CUIEdit)
	CUIEdit();
	~CUIEdit();
	
public:
	static CUIEdit*	sharedCurEdit() { return g_pCurUIEdit; }
    
	override void Initialization(); 
	
	void SetText(const char* pszText);
	const char* GetText() { return m_strText.c_str(); }

	void SetTextSize(unsigned int nSize);
	void SetTextColor(ccColor4B color);

	void SetPassword(bool bSet);
	bool IsPassword() { return m_bPassword; }
	
	void SetMaxLength(unsigned int nLen);
	unsigned GetMaxLength() { return m_nMaxLen; }
	
	void SetMinLength(unsigned int nLen) { m_nMinLen = nLen; }
	unsigned GetMinLength() { return m_nMinLen; }
	
	bool IsTextLessMinLen() { return m_strText.size() < m_nMinLen; }
	bool IsTextMoreMaxLen() { return m_strText.size() > m_nMaxLen; }

	void SetImage(NDPicture* pic);
	void SetFocusImage(NDPicture* pic);
	
	void EnableAdjustView(bool bEnable) { m_bEnableAjdustView = bEnable; }
	
    void SetFlag( int iFlag ){ m_iFlag = iFlag; }
    int GetFlag(){ return m_iFlag; }
	void SetTextAlignment(int alignment);

	void SetFocus( bool bFocus ); 
	
private:
	static CUIEdit*             g_pCurUIEdit;

	NDPicture*					m_picImage;
	NDPicture*					m_picFocusImage;
	
	unsigned int				m_nMinLen;
	unsigned int				m_nMaxLen;

	std::string					m_strText;
	NDUILabel*					m_lbText;

	bool						m_bPassword;
	bool						m_bEnableAjdustView;
	bool						m_bRecacl;
	ccColor4B					m_colorText;
    int                         m_iFlag;
	bool						m_bIMEOpen; //���뷨�Ƿ��״̬

	int							m_curInputCount;
	int							m_curStrCount;

	bool                     m_bFocus;

private:
	void InitInput();
	void SetShowTextColor(ccColor4B color);
	void SetShowTextFontSize(int nFontSize);
	void OnTextChanged();
public:
	void SetFrameRect(CCRect rect); 
	bool AutoInputReturn(); 

protected:
	void draw(); 
	void SetVisible(bool visible); 
	bool OnClick(NDObject* object); 

protected:
#if WITH_NEW_IME
    virtual bool attachWithIME();
    virtual bool detachWithIME();

	virtual bool canAttachWithIME();
	virtual bool canDetachWithIME();

	virtual void keyboardDidShow(CCIMEKeyboardNotificationInfo& info); 
	virtual void keyboardDidHide(CCIMEKeyboardNotificationInfo& info); 

	virtual void onAction( int action );
	virtual void insertText(const char * text, int len);
	virtual void deleteBackward();
	virtual const char * getContentText();
#else
	IPlatformInput*			m_pPlatformInput;
	bool OnInputReturn		(CInputBase* base); 
	bool OnInputTextChange	(CInputBase* base, const char* inputString); 
    void OnInputFinish		(CInputBase* base); 
#endif
};

#endif // _UI_EDIT_H_ZJH_
