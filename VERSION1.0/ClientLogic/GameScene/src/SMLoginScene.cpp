//
//  SMLoginScene.cpp
//  SMYS
//
//  Created by user on 12-3-21.
//  Copyright 2012�� (����)DeNA. All rights reserved.
//

#include "SMLoginScene.h"
#include "NDDirector.h"
#include "ScriptGlobalEvent.h"
#include "ScriptInc.h"
//#include "SimpleAudioEngine_objc.h"
#include "NDPath.h"
#include "SMUpdate.h"
#include "GameApp.h"
//#include "NDUtility.h"
#include "NDUtil.h"
#include "sys/stat.h"
#include "SystemSetMgr.h"
#include "InstallSelf.h"
#include "NDBeforeGameMgr.h"
#include "NDTargetEvent.h"
#include "NDLocalXmlString.h"
#include "NDProfile.h"
#include "ScriptMgr.h"
#include <iostream>
#include <sstream>
#include "ScriptRegLua.h"
#include "ObjectTracker.h"
#include "CCPlatformConfig.h"
#include "NDUIProgressBar.h"
#include "TQPlatform.h"
#include "UsePointPls.h"
#include "StringConvert.h"
#include "NDJsonReader.h"
#include "../CocosDenshion/include/SimpleAudioEngine.h"

using namespace CocosDenshion;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>
#include "android/jni/JniHelper.h"
#include "SqliteDBMgr.h"

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif
////////////////////////////////////////////////////////////

//--------------------//

#define UPDATE_TIP_TEXT_ANDROID 0x7f080039	///< ��׿�≺������ʾ���֣�������׿String.xml���unzip_text ����

#define UPDATE_ON		0	//0�ر����أ�1��������
#define CACHE_MODE 		0  //����ģʽ//0�رտ�����1��������Դ������cacheĿ¼������
//--------------------//

#define TAG_INSTALL_SUCCESS			1
#define TAG_INSTALL_FAILED			2
#define TAG_TIMER_INIT				3
#define TAG_TIMER_GET_STATUS		4
#define	TAG_REQUEST_URL_ERROR		5
#define TAG_TIMER_DOWNLOAD_SUCCESS	6
#define TAG_TIMER_UPDATE			7	//
#define TAG_TIMER_CHECK_WIFI		8	// ���WIFI
#define TAG_TIMER_UNZIP_SUCCESS     9
#define TAG_TIMER_CHECK_UPDATE      10  // ���UPDATE
#define TAG_TIMER_CHECK_COPY        11  //
#define TAG_TIMER_FIRST_RUN         12  // 
#define TAG_TIMER_LOAD_RES_OK       13  // װ�����ֺ�Lua���
#define TAG_TIMER_CHECK_LOGIN_COPY  14

//----------------------------------------------------------
//Update Layer ��
#define TAG_CTRL_PIC_BG					1	//����ͼƬ�ؼ�tag
#define TAG_LABEL_PROMPT				4	//���ֱ�ǩ�ؼ�tag
#define TAG_CTRL_PROGRESS				2	//�������ؼ�tag
#define TAG_UPDATE_LAYER				(2000 + 167)	//��Tag

#define TAG_DLG_CONFIRM					100	//ȷ�϶Ի���tag

#define TAG_BTN_OK						101	//ȷ����ť
#define TAG_BTN_CANCEL					102	//ȡ����ť
#define TAG_LABEL_TIP					103	//���ֱ�ǩ
#define TAG_PIC_DLG_BG					12	//�Ի��򱳾�

#define TAG_SPRITE_NODE					200	//

//----------------------------------------------------------
#define SZ_ERROR_01						"LOGIN_SZ_ERROR_01"			//"��汾����,����������������Ϸ�汾"
#define SZ_ERROR_02						"LOGIN_SZ_ERROR_02"			//"��ǰ�汾��������,���������ػ�����ϵGM"
#define SZ_ERROR_03						"LOGIN_SZ_ERROR_03"			//"�汾��Ϣ�𻵣����������ػ�����ϵGM"
#define SZ_ERROR_04						"LOGIN_SZ_ERROR_04"			//"��Ǹ,������Դδ�ҵ�,����ϵGM"
#define SZ_ERROR_05						"LOGIN_SZ_ERROR_05"			//"����ʧ��,�����������ӻ��������豸����"
#define SZ_DOWNLOADING					"LOGIN_SZ_DOWNLOADING"		//"�汾�����С���"
#define SZ_INSTALLING					"LOGIN_SZ_INSTALLING"		//"���ڰ�װ���¡���"
#define SZ_WIFI_OFF						"LOGIN_SZ_WIFI_OFF"			//"�������ظ��°�,����δ����WIFI,�Ƿ������"
#define SZ_UPDATE_OFF					"LOGIN_SZ_UPDATE_OFF"		//"�޷����ӷ�����,��������"
#define SZ_FIRST_INSTALL                "LOGIN_SZ_FIRST_INSTALL"    //"�״�����,��ʼ�������С���"
#define SZ_CONNECT_SERVER               "LOGIN_SZ_CONNECT_SERVER"   //"���ӷ���������"
#define SZ_SETUP						"LOGIN_SZ_SETUP"			//"�����С���"

#define SZ_UPDATE_URL					"192.168.19.169"//���·������ĵ�ַ
#define SZ_DEL_FILE						"del.txt"//������ɾ���ļ�·���������ļ�/CACHESĿ¼��

#define SZ_MOBAGE_BG_PNG_PATH			"/res/image00/Res00/Load/mobage_bg.png"
#define SZ_UPDATE_BG_PNG_PATH			"/res/image00/Res00/Load/entry_bg.png"

////////////////////////////////////////////////////////////
//NSAutoreleasePool * globalPool = [[NSAutoreleasePool alloc] init];
IMPLEMENT_CLASS(CSMLoginScene, NDScene)

//===========================================================================
CSMLoginScene* CSMLoginScene::Scene( bool bShowEntry /*= false*/  )
{
	CSMLoginScene* pkScene = new CSMLoginScene;

    //��ʾ����ҳ��
	if ( bShowEntry )
	{
		//����������ʱ����Ҫ�õ����ַ���Դ
		if (NDLocalXmlString::GetSingleton().LoadLoginString())
		{
			pkScene->setIsLoadLocalString(true);
		}
		SimpleAudioEngine::sharedEngine()->setMusicStream(true);
		SimpleAudioEngine::sharedEngine()->raiseMusicStream();
        
		//�ǰ�׿ƽ̨�Ž���
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
		//����һ������ؽ��볡�� Ϊ����ӵ�һ����������(android��java��ʵ��)
		NDUILayer* pkLayer = new NDUILayer();
	 	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
		pkLayer->Initialization();
		pkLayer->SetFrameRect(CCRectMake(0, 0, kWinSize.width, kWinSize.height));
		pkScene->AddChild(pkLayer);
		pkScene->m_pLayerOld = pkLayer;

		//����һ������ͼƬ
		NDPicturePool& kPool = *(NDPicturePool::DefaultPool());
		NDUIImage* pkBackgroundImage = new NDUIImage;
		pkBackgroundImage->Initialization();
		pkBackgroundImage->SetFrameRect( CCRectMake(0, 0, kWinSize.width, kWinSize.height ));

		NDPicture* pkPicture = kPool.AddPicture( NDPath::GetImg00Path("Res00/Load/bg_load.png") );
		if (pkPicture)
		{
			pkBackgroundImage->SetPicture(pkPicture, true);
		} 

		pkLayer->AddChild(pkBackgroundImage);
#endif

		//pkScene->ontimer_first_run();	    --��ʱ����ֱ�ӵ��õ�ԭ���������ʱ��SCENE��û����ջ
		pkScene->m_pTimer->SetTimer( pkScene, TAG_TIMER_FIRST_RUN, 0.5f);
    }
	return pkScene;
}

//===========================================================================
CSMLoginScene::CSMLoginScene()
: m_bUpdOk(false)
, m_pLayerOld(NULL)
, m_pLayerUpdate(NULL)
, m_pTimer(NULL)
, m_pCtrlProgress(NULL)
, m_pLabelPromtp(NULL)
, m_iAccountID(0)
, m_iState(0)
, m_pLayerCheckWIFI(NULL)
, m_bIsLoadingLocalString(false)
{
	INC_NDOBJ_RTCLS
	Initialization();
	SetTag(SMLOGINSCENE_TAG);
	WriteCon( "%08X: CSMLoginScene::CSMLoginScene()\r\n", this);
}

//===========================================================================
CSMLoginScene::~CSMLoginScene()
{
	DEC_NDOBJ_RTCLS
   
	WriteCon( "%08X: CSMLoginScene::~CSMLoginScene()\r\n", this);

   	SAFE_DELETE( m_pTimer );

	NDDirector::DefaultDirector()->Recyle();
}

//===========================================================================
void CSMLoginScene::Initialization(void)
{
	NDScene::Initialization();
	//m_doucumentPath = NDPath::GetDocumentPath();
	m_strCachePath = NDPath::GetCashesPath();
	//m_strSavePath = m_strCachePath + "update.zip";
	//m_resPath = NDPath::GetResPath();
	PackageCount = 0;
	m_pTimer = new NDTimer();
}

//�����ʼ�����ȵ�ҳ��
void CSMLoginScene::clearSplash(void)
{
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		JniMethodInfo t;
		if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
										   "clearSplash",
										   "()V"))
		{
			t.env->CallStaticObjectMethod(t.classID, t.methodID);
			t.env->DeleteLocalRef(t.classID);
		}
	#else
		if (m_pLayerOld)
		{
			m_pLayerOld->RemoveFromParent(true);
			m_pLayerOld = NULL;
		}
	#endif
}

void notifyProcess(int nPercent)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo methodInfo;
    if (JniHelper::getStaticMethodInfo(methodInfo, "org/DeNA/DHLJ/DaHuaLongJiang", "drawText",
                                       "(I)V"))
    {
        methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID, nPercent);
        
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
    }
#endif
}

//===========================================================================
void CSMLoginScene::OnTimer( OBJID idTag )
{
	/*
	static bool bFirst = true;

	if (bFirst)
	{
		LOGD("Entry First OnTimer");
		//idTag = TAG_TIMER_UPDATE;
		bFirst = false;
	}
   */
	if ( idTag == TAG_TIMER_UPDATE ) 
	{
		LOGD("TAG_TIMER_UPDATE process entry");
        /*
		if ( !rename( m_strSavePath.c_str(), m_strSavePath.c_str() ) )
		{
			if ( remove( m_strSavePath.c_str() ) )
			{ 
				m_pTimer->KillTimer(this, TAG_TIMER_UPDATE);
				return;
			}
		}
		*/
        //��������m_SavePath��ֵ�����汾�ص��ļ����������������������һ��
		char szUpdateURL[100] = {0};
		snprintf(szUpdateURL,sizeof(szUpdateURL),"%s",m_strUpdateURL.c_str());
		char* szTempFile = GetPathFileName(szUpdateURL,'/');
        if (szTempFile)
        {
			m_strSavePath = m_strCachePath + szTempFile;
        }
		else
			return;
		LOGD("m_strUpdateURL is %s,m_strSavePath is %s",m_strUpdateURL.c_str(),m_strSavePath.c_str());
        
		FromUrl(m_strUpdateURL.c_str());
		ToPath(m_strSavePath.c_str()); 
		Download();
		m_pTimer->KillTimer(this, TAG_TIMER_UPDATE);
	}
	else if ( idTag == TAG_TIMER_DOWNLOAD_SUCCESS )
	{
		m_pTimer->KillTimer(this, TAG_TIMER_DOWNLOAD_SUCCESS);

		LOGD("Entry TAG_TIMER_DOWNLOAD_SUCCESS process.");
		UnZipFile( m_strSavePath.c_str(), m_strCachePath.c_str());
	}
    else if ( idTag == TAG_TIMER_UNZIP_SUCCESS )
	{
		m_pTimer->KillTimer(this, TAG_TIMER_UNZIP_SUCCESS);
		if ( remove(m_strSavePath.c_str()) )
		{
		    NDLog("delete:%s failed",m_strSavePath.c_str());
		    //return;
		}
        std::string szListFile = NDPath::GetCashesPath() + SZ_DEL_FILE;
		DeleteFileFromFile( szListFile );
    
		if(kDeqUpdateUrl.size() > 0)
		{
		    kDeqUpdateUrl.pop_front();
			m_CurDownNum++;
		}

		PackageCount++;
		//�������ض���
		if (kDeqUpdateUrl.size() > 0)
		{
		    //���屣��·��
		    m_strUpdateURL = *kDeqUpdateUrl.begin();
		    //m_savePath = [[NSString stringWithFormat:@"%s/update%d.zip", m_cachPath.c_str(), PackageCount] UTF8String];
			//��������m_SavePath��ֵ�����汾�ص��ļ����������������������һ��
			/*
			char szUpdateURL[100] = {0};
			snprintf(szUpdateURL,sizeof(szUpdateURL),"%s",m_strUpdateURL.c_str());
			char* szTempFile = GetPathFileName(szUpdateURL,'/');
			if (szTempFile)
			{
				m_strSavePath = m_strCachePath + szTempFile;
			}
			else
				return;
			*/
		    m_pTimer->SetTimer( this, TAG_TIMER_UPDATE, 0.5f );
		    StartDownload();
		}
		else
		{
		    //��ת����������
		    StartEntry();
		}
	}
	else if ( TAG_TIMER_CHECK_WIFI == idTag )
	{
		//������û����WIFI�򲻶ϼ��//
    	if ( NDBeforeGameMgrObj.isWifiNetWork() )
    	{
			m_pTimer->KillTimer( this, TAG_TIMER_CHECK_WIFI );
			CloseConfirmDlg();
			StartUpdate();
    	}
	}
	else if ( TAG_TIMER_CHECK_UPDATE == idTag )
	{
        m_pTimer->KillTimer(this, TAG_TIMER_CHECK_UPDATE);
        ShowUpdateOff();
	}
	else if ( TAG_TIMER_CHECK_COPY == idTag )
	{
		//��ѹ��Դ����ʱ��ʾ����
		ontimer_check_copy();
	}
    else if ( TAG_TIMER_FIRST_RUN == idTag )
	{	
		//����ʱ��ʼ��ʱ��
		ontimer_first_run();
	}
	else if ( TAG_TIMER_LOAD_RES_OK == idTag )
	{
		m_pTimer->KillTimer( this, TAG_TIMER_LOAD_RES_OK );
		CloseWaitingAni();
		CloseUpdateUILayer();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		//if ( m_iAccountID == 0 )
		m_iAccountID = ScriptMgrObj.excuteLuaFuncRetN( "GetAccountID", "Login_ServerUI" );
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
#endif
		ScriptMgrObj.excuteLuaFunc( "ShowUI", "Entry", m_iAccountID );
		//    ScriptMgrObj.excuteLuaFunc("ProecssLocalNotification", "MsgLoginSuc");
	}
}

//��ѹ��Դ����ʱ��ʾ����
void CSMLoginScene::ontimer_check_copy()
{

	int nCopyStatus = NDBeforeGameMgr::GetCopyStatus();
	switch (nCopyStatus) 
	{
	case -1:
		m_pTimer->KillTimer( this, TAG_TIMER_CHECK_COPY );
		LOGERROR("Copy files error!");
		exit(0);
		break;
	case 0:
		break;
	case 100:
		{
			CCImage::changeSystemFont(false);
			CCDirector::sharedDirector()->setGLDefaultValues();
			m_pTimer->KillTimer( this, TAG_TIMER_CHECK_COPY );

			//��ѹ��ɿ�ʼ����sdk
			#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
				NDBeforeGameMgrObj.doNDSdkLogin();
				ShowWaitingAni();
				usleep(200);
			#endif

			#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
				notifyProcess(100);
				//��ʱ��Դ������,�����ǳ�ʼ�����ݿ�
				CSqliteDBMgr::shareInstance().InitDataBase("DNSG.sqlite");
			#endif

			//�����������
			OnProcessUpdate();
		}
		break;
	default:
		{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			notifyProcess(nCopyStatus);
#endif
		}
		break;
	}

}

//����ʱ��ʼ��ʱ��
void CSMLoginScene::ontimer_first_run()
{
	m_pTimer->KillTimer( this, TAG_TIMER_FIRST_RUN );

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	//��ȡ�˺�����
	m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();

	//���߸��µĻ���ֱ�ӽ������ҳ��
	#if (UPDATE_ON == 0 && CACHE_MODE == 0)
		StartEntry();
		return;
	#endif
#endif

#if CACHE_MODE == 1
	//�߻�����ƵĻ�(ͨ��version.ini���ж��Ƿ��ѹ��Դ��  (windowsһ��Ϊfalse,android�Ƚ�apk�뱾��version.ini)
	if ( NDBeforeGameMgrObj.CheckFirstTimeRuning() )
	{
		//����һ�߳�ר�Ž�����Դ�ļ�ѹ
		NDBeforeGameMgrObj.CopyRes();
		m_pTimer->SetTimer( this, TAG_TIMER_CHECK_COPY, 0.5f );
	}
	else
	{
		CCImage::changeSystemFont(false);

		//ios�ڴ�ʱ�ڿ�ʼ��ʼ��sdk
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			NDBeforeGameMgrObj.doNDSdkLogin();
		#endif

		CloseWaitingAni();
		OnProcessUpdate();
	}
#else
	//ios�ڴ�ʱ�ڿ�ʼ��ʼ��sdk
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		NDBeforeGameMgrObj.doNDSdkLogin();
	#endif
	CloseWaitingAni();
	OnProcessUpdate();
#endif
}
//==========================================================
//--Guosen 2012.8.7
//int     
//CSMLoginScene::OnProcess(int nPercent)
//{
//    CUIExp* pProcess = (CUIExp*)m_layer->GetChild(ID_LOADING_PROCESS);
//	if (!pProcess) {
//        return 0;
//    }
//    pProcess->SetProcess(nPercent);
//    return 0;
//}
//==========================================================
//--Guosen 2012.8.7
//int     
//CSMLoginScene::OnFail(const char* pszStrErr)
//{
//    return 0;
//}
//==========================================================
//--Guosen 2012.8.7
//int		
//CSMLoginScene::OnComplete(void)
//{
//    m_bUpdOk = true;
//    return 0; 
//}
//===========================================================================
// ��������
bool CSMLoginScene::StartUpdate()
{
	LOGD("Entry StartUpdate");

	if ( kDeqUpdateUrl.empty() )
	{
		LOGERROR("kDeqUpdateUrl is empty");
		return false;
	}
	//�����һ����
	std::string strURL = *kDeqUpdateUrl.begin();
	m_strUpdateURL	= strURL;
	m_pTimer->SetTimer( this, TAG_TIMER_UPDATE, 0.5f );	
	m_CurDownNum = 1;
	StartDownload();
	return true;
}


//===========================================================================
//������������̵Ļص�
//������bOpContinue �Ƿ���ֹ�������
//������nFileNum Ҫ��������ļ���
//������nFileIndex Ҫ����ĵ�ǰ�ļ�����
//������pszFileName �ļ���������·��
void CSMLoginScene::OnUnCompressEvent( bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName )
{
	int percent = (nFileIndex + 1) *100/ nFileNum;
	SetProgress( percent );
}

//===========================================================================
//��������������Ļص�
//������emErrCode �������
//������pszErrMsg ������ʾ
void CSMLoginScene::OnTQZipError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg)
{
	NDLog("OnTQZipError %s", pszErrMsg);
}

///////////////////////////////////////////////
//bool 
//CSMLoginScene::CheckClientVersion()
//{
//    int nCurVer = 0;
//	NSString *strIniPath = [NSString stringWithFormat:@"%s", NDPath::GetResPath("version.ini")];
//	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:strIniPath];
//	if (!stream)
//	{
//		return false;
//	}
//	//nCurVer = [stream readInt];
//    NDDataTransThread::DefaultThread()->Stop();
//    NDDataTransThread::ResetDefaultThread();
//    NDDataTransThread::DefaultThread()->Start("192.168.64.30", 9500);
//	if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
//	{
//		return false;
//	}
//	NDTransData data(_MSG_CLIENT_VERSION);
//	
//	int version = 1;
//	data << version;
//	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//
//}
//===========================================================================
/*void 
CSMLoginScene::OnDrawUI()
{
    (NDDirector::DefaultDirector())->ForceDraw();
}
*/
//===========================================================================
void 
CSMLoginScene::OnDownloadEvent(DWORD dwSizeFile,DWORD dwSideDownLoaded)
{
    float nProcess = (float)dwSideDownLoaded/(float)dwSizeFile;
    //ScriptMgrObj.excuteLuaFunc("OnDownloadEvent", "Login_Upd",int(nProcess*60));
}
//===========================================================================
void 
CSMLoginScene::OnUnCompress(int nFileNum,int nFileIndex,const char* pszFileName)
{
    //ScriptMgrObj.excuteLuaFunc("OnUnCompress", "Login_Upd");
}
//===========================================================================
void 
CSMLoginScene::CompleteUpdate(ISMUpdateEvent::ERROR_CODE emErrCode)
{
    //ScriptMgrObj.excuteLuaFunc("CompleteUpdate", "Login_Upd");
}
//===========================================================================
void 
CSMLoginScene::OnError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg)
{
	if(emErrCode == ISMUpdateEvent::ERRCODE_VERSION_LATEST){
        return;
    }
    //ScriptMgrObj.excuteLuaFunc("OnUpdError", "Login_Upd",pszErrMsg);
}

//===========================================================================
void CSMLoginScene::ReflashPercent(int percent, int pos, int filelen )
{
    /*
	if (m_label) 
	{
		//NSString *str = [NSString stringWithFormat:@"�����أ�%d\%", percent];
		//m_label->SetText([str UTF8String]);
		char buff[100] = {0x00};
		sprintf(buff, "�����أ�%d\%%", percent);
		m_label->SetText(buff);
		
		m_progressBar->SetCurrentStep(percent);
	}
	*/ 
	if ( m_pLabelPromtp )
	{
		int iTotalDownNum = kDeqUpdateUrl.size() + m_CurDownNum - 1;
		//std::stringstream str;
		char dataSize[10] = {0};
		sprintf(dataSize,"%.2f",filelen/(1024*1024.0));
		std::string strDownloading = NDCommonCString2(SZ_DOWNLOADING);
		char buff[100] = {0};
		sprintf(buff,"(%sMB)%s(%d/%d)",dataSize, strDownloading.c_str(),m_CurDownNum,iTotalDownNum);
		//str << "("<<buff<< "MB)" << CCString::stringWithFormat(strDownloading.c_str(), m_CurDownNum, iTotalDownNum)->getCString();
		//m_pLabelPromtp->SetText( str.str().c_str() );
		m_pLabelPromtp->SetText(buff);
		m_pLabelPromtp->SetVisible( true );
	}
	SetProgress( percent );
}

//===========================================================================
void CSMLoginScene::DidDownloadStatus( DownloadStatus status )
{
	CCLog( "@@ CSMLoginScene::DidDownloadStatus(): %d\r\n", int(status));
	if (status == DownloadStatusResNotFound) 
	{
		//m_label->SetText( "��Ǹ��������Դδ�ҵ�������ϵGM" );
		if (m_pLabelPromtp)
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_04).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
			//m_pLabelPromtp->SetFontSize( 20 );
			//CCRect tRect = m_pLabelPromtp->GetFrameRect();
			//m_pLabelPromtp->SetFrameRect( CCRectMake( tRect.origin.x, tRect.origin.y, tRect.size.width*3, tRect.size.height*2));
			//m_pLabelPromtp->SetVisible( true );
		}
	}
	else if (status == DownloadStatusFailed)
	{
		if (m_pLabelPromtp)
		{
			//m_label->SetText( "����ʧ�ܣ������������ӻ��������豸����" );

			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_05).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
			//m_pLabelPromtp->SetFontSize( 20 );
			//CCRect tRect = m_pLabelPromtp->GetFrameRect();
			//m_pLabelPromtp->SetFrameRect( CCRectMake( tRect.origin.x/2, tRect.origin.y, tRect.size.width*3, tRect.size.height*2));
			//m_pLabelPromtp->SetVisible( true );
		}
	}
	else 
	{
		//m_label->SetText("������ɣ����ڽ��а�װ���������Ժ�......");		
		m_pTimer->SetTimer( this, TAG_TIMER_DOWNLOAD_SUCCESS, 0.5f );
		StartInstall();
	}
}

//===========================================================================
//wt
// ��ʼ�����¶���
void CSMLoginScene::InitDownload( std::string & szUpdatePath )
{
	kDeqUpdateUrl.push_back(szUpdatePath);
}

//++Guosen2012.8.7
void CSMLoginScene::ShowRequestError()
{
	NDUIDialog* pkUIDialog = new NDUIDialog();
	pkUIDialog->Initialization();
	pkUIDialog->SetTag(TAG_REQUEST_URL_ERROR);
	pkUIDialog->SetDelegate(this);
	pkUIDialog->Show(NDCommonCString2("Common_error").c_str(),
		NDCommonCString2("LOGIN_SZ_REQUEST_DOWNLOAD_FAIL").c_str(),
		NULL, NDCommonCString2("Common_Ok").c_str(), NULL);
}

//===========================================================================
//ͨ�����ݽ����ļ�·������ô�ɾ�����ļ�·����ɾ����ɾ�����ļ���ɾ�����ݽ����ļ�
bool CSMLoginScene::DeleteFileFromFile( std::string & szDelListFile )
{
	std::ifstream kTempFile;
	kTempFile.open( szDelListFile.c_str(), ios_base::in );
	if ( !kTempFile )
	{
		if ( kTempFile.is_open() )
		{
			kTempFile.close();
		}

		return false;
	}
	std::string lineStr;
	while ( getline( kTempFile, lineStr ) )
	{
		std::string DelFile = m_strCachePath + lineStr;
 		if ( remove( DelFile.c_str() ) )
		{
			NDLog( "ɾ���ļ�ʧ�ܣ�%s",DelFile.c_str() );
		}
	}
	kTempFile.close();
	remove( szDelListFile.c_str() );
	return true;
}

//===========================================================================
bool CSMLoginScene::CreateUpdateUILayer()
{
	LOGD("Entry CreateUpdateUILayer");

	//�������²��ʱ�����������ʼҳ����ʾ��
	clearSplash();

	if ( m_pLayerUpdate != NULL)
	{
		//������²��Ѵ��ھͲ���Ҫ��������
		return false;
	}
	
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	NDUILayer*	pkLayer = new NDUILayer();

	if ( !pkLayer )
	{
		LOGERROR( "CSMLoginScene::CreateUpdateUILayer() pLayer is null" );
		return false;
	}

	pkLayer->Initialization();
	pkLayer->SetFrameRect( CCRectMake(0, 0, kWinSize.width, kWinSize.height) );
	pkLayer->SetTag( TAG_UPDATE_LAYER );
	AddChild(pkLayer);
	m_pLayerUpdate = pkLayer;
	
	NDUILoad kTempUILoad;
	
	//�����R�e ���е�Ч�� ÿ��load����clearһ�Σ����Զ���{��Ҳ�]�P�S
	NDLocalXmlString::GetSingleton().LoadLoginString();

	LOGD("Ready to load update.ini file");
	kTempUILoad.Load( "UpdateUI.ini", pkLayer, this, CCSizeMake(0, 0));
	
	m_pCtrlProgress	= (CUIExp*)pkLayer->GetChild( TAG_CTRL_PROGRESS );
	if ( !m_pCtrlProgress )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() m_pCtrlProgress is null" );
		return false;
	}

	m_pCtrlProgress->SetProcess(0);
	m_pCtrlProgress->SetTotal(100);
	m_pCtrlProgress->SetStyle(1);
	m_pCtrlProgress->SetVisible(false);
	m_pCtrlProgress->SetTextFontColor( ccc4(255,255,255,255) );
	
	m_pLabelPromtp	= (NDUILabel*)pkLayer->GetChild( TAG_LABEL_PROMPT );
	if ( !m_pLabelPromtp )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() m_pLabelPromtp is null" );
		return false;
	}

	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetVisible(false);
	}

	if (m_pLayerOld)
	{
		m_pLayerOld->SetVisible(false);
	}

	return true;
}

//===========================================================================
void CSMLoginScene::CloseUpdateUILayer()
{
	if ( m_pLayerUpdate )
	{
		m_pLayerUpdate->RemoveFromParent(true);
		m_pLayerUpdate	= NULL;
		m_pCtrlProgress	= NULL;
		m_pLabelPromtp	= NULL;
	}
}

//===========================================================================
void CSMLoginScene::OnMsg_ClientVersion(NDTransData& kData)
{
	CCLog( "@@ CSMLoginScene::OnMsg_ClientVersion()\r\n" );
	LOGD("Entry OnMsg_ClientVersion");

	bool bUpdate = false;
	
	int bLatest				= kData.ReadByte();
	int bForceUpdate		= kData.ReadByte();
	int nFromVersion		= kData.ReadInt();
	int nToVersion			= kData.ReadInt();
	std::string strUpdatePath  = kData.ReadUnicodeString();
	LOGD("Client Version:FromVersion is %d,ToVersion is %d",nFromVersion,nToVersion);

	//std::string strUpdatePath = "http://222.77.177.219/twt/android/6999_7000_in_dhljupdate.zip";//kData.ReadUnicodeString();
	
	if ( bForceUpdate )
	{
        CloseWaitingAni();
		LOGD("Redown the game client please!");
		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_01).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
		}
		return ;
	}
	else if ( ( nFromVersion ==  nToVersion ) &&  ( !bLatest ) )
	{
        CloseWaitingAni();
		LOGERROR("Current version error!!,Please call GM!");

		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_02).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
		}
		return ;
	}
	else if ( ( nFromVersion == 0 ) && ( nToVersion == 0 ) )
	{
        CloseWaitingAni();
		LOGERROR("Version info is broken,Please call GM!");

		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_03).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
		}

		return ;
	}
	else if ( ( nFromVersion == nToVersion ) && (bLatest) )
	{
		LOGD("Current version is newest");
		StartEntry();
		return;
	}
	else
	{
		bUpdate = true;
	}

	LOGD("Res update URL:%s",strUpdatePath.c_str());
	kDeqUpdateUrl.push_back(strUpdatePath);

	if (bUpdate)
	{
		LOGD("Pass bUpdate,value is %s",bUpdate ? "true" : "false");

		if (bLatest)
		{
			CloseWaitingAni();
			if ( !NDBeforeGameMgrObj.isWifiNetWork() )//
			{
				ShowCheckWIFIOff();
				m_pTimer->SetTimer( this, TAG_TIMER_CHECK_WIFI, 1.0f );
			}
			else
			{
				StartUpdate();
			}
		}
	}

	LOGD("Leave OnMsg_ClientVersion");
	CCLog("@@ Leave OnMsg_ClientVersion");
}
//===========================================================================
void CSMLoginScene::StartDownload()
{
	LOGD("Entry StartDownload");
	
	//�@ȡҪ���d�Ŀ��Ĕ���
	int iTotalDownNum = kDeqUpdateUrl.size() + m_CurDownNum - 1;

	if ( m_pLabelPromtp )
	{
		m_pLabelPromtp->SetText( CCString::stringWithFormat(NDCommonCString2(SZ_DOWNLOADING).c_str(), m_CurDownNum, iTotalDownNum)->getCString());
		m_pLabelPromtp->SetVisible( true );
	}
	if ( m_pCtrlProgress )
	{
		m_pCtrlProgress->SetVisible( true );
	}
}

//---------------------------------------------------------------------------
void CSMLoginScene::StartInstall()
{
	if ( m_pLabelPromtp )
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_INSTALLING).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
	if ( m_pCtrlProgress )
	{
		m_pCtrlProgress->SetVisible( true );
	}
}
//---------------------------------------------------------------------------
void CSMLoginScene::SetProgress( int nPercent )
{
	NDLog("CSMLoginScene::SetProgress() nPercent:%d",nPercent);
	if ( m_pCtrlProgress )
	{
		m_pCtrlProgress->SetProcess( nPercent );
	}
}

//===========================================================================
void CSMLoginScene::StartEntry()
{
	WriteCon( "@@ CSMLoginScene::StartEntry()\r\n" );
	CCLog( "@@login04: StartEntry()\r\n" );

	//ֻ�н��������ҳ��Ż����  (��ʾ���ӷ�����)
	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_SETUP).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}

	{
		//����Ҫʹ�õ��ַ���Դ
		WriteCon( "@@ NDLocalXmlString::LoadData()...\r\n" );
		TIME_SLICE("NDLocalXmlString::LoadData()");
		NDLocalXmlString::GetSingleton().LoadData();
	}

	{
		//����LUA�ű�
		WriteCon( "@@ ScriptMgrObj.Load()...\r\n" );
		TIME_SLICE("ScriptMgrObj.Load()");
		ScriptMgrObj.Load(); 
	}

	//�������ȡ��Ϸ��������,�������ֵ�
	ScriptMgrPtr->excuteLuaFunc( "LoadData", "GameSetting" ); 

	//�ر�Ϊ����ʾ����ҳ��������Ĳ�
	CloseUpdateUILayer();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	//windows���˺���ֱ��д��Login_ServerUI.luaǰ���(���˺�ϵͳ)(����Ƕ��˺�ϵͳ��Ҳ���Ȼ�ȡд������������������·�һ����ʽ�˺�)
	m_iAccountID = ScriptMgrPtr->excuteLuaFuncRetN( "GetAccountID", "Login_ServerUI" );
#else
	//androidΪsdk���óɹ������onLoginComplete��ʱ��ֵ(iosδ����)
	m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
#endif
    
	CCLog("StartEntry(%d)\r\n", m_iAccountID);

	//�����Լ�SDK��ʱ���ȷ���0������˵���ɹ��������·��µ�id
	m_iAccountID = 0;	//(�˺��Ƿ�Ϸ����ж�Ӧ���ڲ����˺ŵĸ���Ҫ�����жϣ������ȡ���˺Ŷ�Ĭ�ϺϷ�)
	//����������ҳ��Ĳ�

	//�����ʼҳ��
	clearSplash();

	ScriptMgrPtr->excuteLuaFunc( "ShowUI", "Entry", m_iAccountID );
}

//===========================================================================
void CSMLoginScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog->GetTag() == TAG_DLG_CONFIRM)
	{
		NDBeforeGameMgrObj.doNDSdkLogin();
	}
}

//===========================================================================
bool CSMLoginScene::OnTargetBtnEvent( NDUINode * uiNode, int targetEvent )
{
	int	iTag = uiNode->GetTag();
	if ( TE_TOUCH_BTN_CLICK == targetEvent )
	{
		if ( TAG_BTN_OK == iTag ) 
		{
			CloseConfirmDlg();
			StartUpdate();
		}
		else if ( TAG_BTN_CANCEL == iTag ) 
		{
			exit(0);
		}
	}
	return true;
}

//===========================================================================
bool CSMLoginScene::CreatConfirmDlg( const char * szTip )
{
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	NDUILayer* pkLayer = new NDUILayer();

	if (!pkLayer)
	{
		return false;
	}

	pkLayer->Initialization();
	pkLayer->SetFrameRect( CCRectMake(0, 0, kWinSize.width, kWinSize.height) );
	pkLayer->SetTag( TAG_DLG_CONFIRM );
	AddChild(pkLayer);	
	
	NDUILoad kTempUILoad2;
	kTempUILoad2.Load( "ShowYesOrNoDlg.ini", pkLayer, this, CCSizeMake(0, 0) );
	
	NDUILabel * pLabelTip	= (NDUILabel*)pkLayer->GetChild( TAG_LABEL_TIP );
	if ( pLabelTip && szTip )
	{
		pLabelTip->SetText( szTip );
	}
	return true;
}
void CSMLoginScene::CloseConfirmDlg()
{
	RemoveChild( TAG_DLG_CONFIRM, true );
}

//===========================================================================
void CSMLoginScene::UnzipPercent(int nFileNum,int nFileIndex)
{    
    int nPercent = 100 * (nFileIndex + 1) / nFileNum;
    SetProgress( nPercent );
}

void CSMLoginScene::UnzipStatus(bool bResult)
{
	if (!bResult) 
    {
        NDLog("UnZipFile:%s failed",m_strSavePath.c_str());
        //return;
    }
	m_pTimer->SetTimer( this, TAG_TIMER_UNZIP_SUCCESS, 0.5f );	
}

//===========================================================================
//��ʾ�ȴ���תȦȦ����
void CSMLoginScene::ShowWaitingAni()
{
	CUISpriteNode* pkCheckNode = (CUISpriteNode *)GetChild(TAG_SPRITE_NODE);

	if ( pkCheckNode )
	{
		return;
	}
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();	
	CUISpriteNode* pkUIScriptNode = new CUISpriteNode;
	pkUIScriptNode->Initialization();
	pkUIScriptNode->ChangeSprite(NDPath::GetAniPath("busy.spr").c_str());
	pkUIScriptNode->SetTag( TAG_SPRITE_NODE );
	pkUIScriptNode->SetFrameRect(CCRectMake(0, 0, kWinSize.width, kWinSize.height));
	AddChild(pkUIScriptNode);
}
void CSMLoginScene::CloseWaitingAni()
{
	RemoveChild( TAG_SPRITE_NODE, true );
}

//===========================================================================
//��ʾ���WIFIʧ�ܶԻ���
void CSMLoginScene::ShowCheckWIFIOff()
{
// 	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
// 	
// 	NDUILayer *	pLayer	= new NDUILayer();
// 	if ( !pLayer )
// 		return;
// 	pLayer->Initialization();
// 	pLayer->SetFrameRect( CCRectMake(0, 0, winSize.width, winSize.height) );
// 	AddChild(pLayer);
// 	m_pLayerCheckWIFI = pLayer;
// 	NDUILoad tmpUILoad;
// 	tmpUILoad.Load( "CheckWIFIDlg.ini", pLayer, this, CCSizeMake(0, 0) );
	CreatConfirmDlg( NDCommonCString2(SZ_WIFI_OFF).c_str() );
	m_iState = 1;
}

//��ʾ��������ʧ�ܶԻ���
void CSMLoginScene::ShowUpdateOff()
{
	CreatConfirmDlg( NDCommonCString2(SZ_UPDATE_OFF).c_str() );
	m_iState = 2;
}

//װ���ı���Lua//���߳�
void* CSMLoginScene::LoadTextAndLua( void * pPointer )
{
	if ( pPointer )
	{
		CSMLoginScene * pScene = (CSMLoginScene*)pPointer;
		NDLocalXmlString::GetSingleton().LoadData();
		//ScriptMgrObj.Load();//
		ScriptMgrObj.excuteLuaFunc( "LoadData", "GameSetting" ); 
		pScene->m_pTimer->SetTimer( pScene, TAG_TIMER_LOAD_RES_OK,0.05f );
	}
	return pPointer;
}

//������������
void CSMLoginScene::OnProcessUpdate()
{
#if UPDATE_ON == 1
	NDJsonReader kReader;
	string strUpdateURL = kReader.getGameConfig("world_server_ip").c_str();
	unsigned int uiServerPort = atoi(kReader.getGameConfig("server_port").c_str());

	LOGD("%s%s:%d",CONVERT_GBK_TO_UTF8("�˕r���µ�IP��ַ�飺"),strUpdateURL.c_str(),uiServerPort);
	CreateUpdateUILayer();

	if ( !strUpdateURL.length() )
	{
		CloseWaitingAni();
		StartEntry();
		return;
	}

	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_CONNECT_SERVER).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}

	if ( !NDBeforeGameMgrObj.CheckClientVersion( strUpdateURL.c_str(),uiServerPort) )
	{
		LOGERROR("CheckClientVersion failed");
		CloseWaitingAni();
		StartEntry();
		return;
	}
#endif
}

std::string CSMLoginScene::getTextFromStringXML_JNI( int nTextID )
{
	std::string ret;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"getTextFromStringXML",
		"(I)Ljava/lang/String;"))
	{
		jstring retFromJava = (jstring) t.env->CallStaticObjectMethod(t.classID,
			t.methodID, nTextID);
		const char* str = t.env->GetStringUTFChars(retFromJava, 0);
		ret = str;

		t.env->ReleaseStringUTFChars(retFromJava, str);
		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(retFromJava);
	}
	else
	{
		LOGERROR("Cant' find java function:getTextFromStringXML");
	}
#endif
	return ret;
}


char*  CSMLoginScene::GetPathFileName(char* src, char delitmit)   
{ 
	int i = strlen(src); 
	if(!(*src))     
		return NULL; 
	while(src[i-1])  
		if(strchr(src + (i - 1), delitmit))
			return   (src + i); 
		else   
		{
			i--; 
		}
		//�����û���ҵ����򷵻������ַ���
		if (i == 0)
		{
			return src;
		}
		return  NULL; 
} 