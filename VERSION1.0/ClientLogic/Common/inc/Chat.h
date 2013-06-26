//
//  Chat.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __CHAT_H
#define __CHAT_H

#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDUIScrollText.h"
#include <vector>
#include <deque>
#include "NDTimer.h"
#include "NDDirector.h"
#include "NDTextNode.h"

using namespace NDEngine;

typedef enum{
	ChatTypeAll,		//ȫ��
	ChatTypeTip,		//С��ʿ
	ChatTypeImportant,	//��Ҫ��ʾ
	ChatTypeWorld,		//��
	ChatTypeSection,	//��
	ChatTypeQueue,		//��
	ChatTypeArmy,		//��
	ChatTypeSecret,		//��
	ChatTypeSystem		//ϵ
}ChatType;

/*
 �������������ڲ����ã��ⲿ��������ģ��˽����ʹ�ã��ɲο��÷��������õĵط�
 */
ChatType GetChatTypeFromChannel(int channel);
int GetChannelFromChatType(ChatType type);
ccColor4B GetColorWithChatType(ChatType type);

//������Ϣ��ʾ�ؼ�
class TextControl : public NDUILayer//, public ITimerCallback
{
	DECLARE_CLASS(TextControl)
	TextControl();
	~TextControl();
public:
	void Initialization(unsigned int displaySecond); hide
	//����
	void SetText(const char* text);
	//��ɫ
	void SetFontColor(ccColor4B color);
	
	void OnFrameRectChange(CCRect srcRect, CCRect dstRect); override
	void OnTimer(OBJID tag); override
private:
	NDUIText* m_textUI;
	std::string m_text;
	ccColor4B m_color;
	NDTimer* m_timer;
};

//�������ͺ�����������ϵĽṹ�壬�ڲ�ʹ��
typedef struct MESSAGE_STRUCT{
	ChatType chatType;
	std::string message;
	MESSAGE_STRUCT(ChatType type, std::string msg)
	{
		chatType = type;
		message = msg;
	}
}MessageStruct;

//����Ĺ����࣬
//����
class Chat : public NDObject, public ITimerCallback, public NDDirectorDelegate
{
	DECLARE_CLASS(Chat)
	Chat();
	~Chat();
public:
	//��������ָ��
	static Chat* DefaultChat();
    static void  Release();
	//�������ͬʱ��ʾ�����¼��
	void SetRecordCount(unsigned int count);
	//����ÿ����¼����ʾʱ������λ����
	void SetAppearTime(float second);
	//����ӷ��������յ�һ�������¼���ɵ��ô˽ӿڣ�ʣ��������ڲ������㴦���ˣ������ⲿ����ֻҪʹ�ô˽ӿھͿ���
	void AddMessage(ChatType type, const char* message, const char* speaker=NULL, bool bRecord=true);
	
	/*
	 ���·����ڲ����ã��ⲿ�������
	 */
	void OnTimer(OBJID tag); override
	void BeforeDirectorPopScene(NDDirector* director, NDScene* scene, bool cleanScene); override
	void AfterDirectorPopScene(NDDirector* director, bool cleanScene); override
	void AfterDirectorPushScene(NDDirector* director, NDScene* scene); override
	
	void DeleteOneNormalText();
private:
	unsigned int m_recordCount;
	unsigned int m_appearSecond;
	std::deque<TextControl*> m_textControls;
	std::deque<MessageStruct> m_normalMessages;
	
	NDUIScrollText* m_importantScrollText;
	std::deque<MessageStruct> m_importantMessages;
	
	NDUIScrollText* m_tipScrollText;
	std::deque<MessageStruct> m_tipMessages;
	
	NDTimer* m_timer;
	
	void ReflashNormalData();	
	void CreateOneNormalText(ChatType type, const char* text, const char* speaker);
	
	
	NDUIScrollText* CreateScrollText(ChatType type, const char* text);		
	void DeleteScrollText(NDUIScrollText* scrollText);
	
	void AddControlsToScene(NDScene* scene);
	void RemoveControlsFromScene();
};

#endif
