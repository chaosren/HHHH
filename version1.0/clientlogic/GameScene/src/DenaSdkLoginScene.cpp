/*---------------------------------------------------
--描述: 无sdk版本登入点
--时间: 2013.11.15
--作者: tzq
---------------------------------------------------*/
#include "DenaSdkLoginScene.h"
#include "NDConstant.h"

#define SEND_DATA_BUF_LEN 128

CDenaSdkLoginScene::CDenaSdkLoginScene()
{
	//m_pkHttp->setNotifyCallback(DownloadCallback, this, 1);
}

CDenaSdkLoginScene::~CDenaSdkLoginScene()
{

}


void CDenaSdkLoginScene::SendHttpRequest(const char* pszReqData)
{
	m_pkHttp = new KHttp;
	m_pBuff = new char[SEND_DATA_BUF_LEN];
	memset(m_pBuff, 0, SEND_DATA_BUF_LEN);
	//strcpy(m_pBuff, "\"platform_account_id\":666666, \"result\":2");
	//strcpy(m_pBuff, "\"result\":2");
	//m_pBuff = "\"platform_account_id\":id, \"result\":1";
	m_pkHttp->getHttpFile(pszReqData, m_pBuff);
	if (strlen(m_pBuff) != 0)
	{
		ScriptMgrPtr->excuteLuaFunc( "MsgRcvHttpRespond", "SendHttpMsgLogin", m_pBuff); 
	}
	SAFE_DELETE(m_pkHttp);
	SAFE_DELETE_ARRAY(m_pBuff);
	int iiii = 0;
}
