/*---------------------------------------------------
--����: ��sdk�汾�����
--ʱ��: 2013.11.15
--����: tzq
---------------------------------------------------*/
#ifndef DENA_SDK_LOGIN_SCENE_H
#define DENA_SDK_LOGIN_SCENE_H


#include "NDScene.h"
#include "NDTile.h"
#include "KHttp.h"

#define CDenaSdkLoginSceneObj	CDenaSdkLoginScene::GetSingleton()
#define CDenaSdkLoginScenePtr	CDenaSdkLoginScene::GetSingletonPtr()

class CDenaSdkLoginScene:public TSingleton<CDenaSdkLoginScene>
{
public:
	CDenaSdkLoginScene();
	~CDenaSdkLoginScene();


public:
	void SendHttpRequest(const char* pszReqData);

private:
	KHttp* m_pkHttp;
	std::string m_strFromUrl;
	char *m_pBuff;

};


#endif