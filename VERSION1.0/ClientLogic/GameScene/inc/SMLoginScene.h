//
//  SMLoginScene.h
//  SMYS
//
//  Created by user on 12-3-21.
//  Copyright 2012�� (����)DeNA. All rights reserved.
//

#ifndef SMYS_SMLoginScene_h
#define SMYS_SMLoginScene_h


#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUIlayer.h"
#include "NDTimer.h"
#include "NDUILoad.h"
#include "NDUIExp.h"
#include "BattleMgr.h"
#include "NDColorPool.h"
#include "NDDataPersist.h"
#include "NDLocalXmlString.h"
#include "ItemMgr.h"
#include "cpLog.h"
#include "NDUtility.h"
#include "FarmMgr.h"
//#include "BattleFieldMgr.h"
#include "SMUpdate.h"
#include "DownloadPackage.h"
#include "NDTransData.h"
#include "NDUIDialog.h"
#include "ZipUnZip.h"

#define ID_LOADING_PROCESS (90)
class CSMLoginScene
: public NDScene
, public DownloadPackage
, public ITimerCallback
//, public ISMUpdateEvent
//, public ITQZipEvent
, public NDUITargetDelegate
, public NDUIDialogDelegate
, public CZipUnZip
{
	DECLARE_CLASS(CSMLoginScene)
	
	CSMLoginScene();
	~CSMLoginScene();
	
	static CSMLoginScene* Scene( bool bShowEntry = false );//�����Ƿ���ʾ����ҳ�棬

public:
	void Initialization(); override
	
public:// ISMUpdateEvent
	virtual void OnDownloadEvent(DWORD dwSizeFile,DWORD dwSideDownLoaded);
	virtual void OnUnCompress(int nFileNum,int nFileIndex,const char* pszFileName);
	virtual void CompleteUpdate(ISMUpdateEvent::ERROR_CODE emErrCode);
	virtual void OnError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg);
	virtual void UnzipPercent(int nFileNum,int nFileIndex);
    virtual void UnzipStatus(bool bResult);
    bool StartUpdate();
    
protected:// ITQZipEvent
	virtual void OnUnCompressEvent(bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName);
	void OnTQZipError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg);

public://NDUIDialogDelegate
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
private:
    virtual void OnTimer(OBJID idTag);
	
public:
	virtual void ReflashPercent( int percent, int pos, int filelen ); override
	virtual void DidDownloadStatus(DownloadStatus status ); override
	
public:    
public:
	virtual bool OnTargetBtnEvent( NDUINode * uiNode, int targetEvent ); override
	
private:
    bool			m_bUpdOk;
    
public:// twt
    typedef deque<string> DEQSTR;
    DEQSTR kDeqUpdateUrl;
	 int m_CurDownNum;
    vector<string> split(std::string& src, std::string delimit);
    std::string trim(std::string &s);
	std::string m_strSavePath;
	std::string m_strUpdateURL;
	std::string m_strCachePath;
    void InitDownload( std::string & szUpdatePath );
    int  PackageCount ;
    bool ReadFile( const char* file, int begin, int end, char* buf );
	char* GetPathFileName(char* src, char delitmit);
    
public:
    //++Guosen
    void ShowRequestError();
	bool DeleteFileFromFile( std::string & szListFile );
		
	// �������½���
	bool CreateUpdateUILayer();
	
	// �رո��½���
	void CloseUpdateUILayer();
	
	//��Ӧ"_MSG_CLIENT_VERSION"��Ϣ 
	void OnMsg_ClientVersion(NDTransData& kData);
	
	void StartDownload();
	void StartInstall();
	void StartEntry();
	void SetProgress( int nPercent );
	
	//����ȷ�϶Ի���
	bool CreatConfirmDlg( const char * szTip );
	void CloseConfirmDlg();
	
	//
	void ShowCheckWIFIOff();
	//
	void ShowUpdateOff();
    int  GetCurrentUser() { return m_iAccountID; }
protected:

	static void * LoadTextAndLua( void * pScene );
	void ShowWaitingAni();
	void CloseWaitingAni();
	void OnProcessUpdate();
	std::string getTextFromStringXML_JNI(int nTextID);			///< Add by ����

protected:

	NDUILayer *		m_pLayerOld; //�ɵĵ�½����
    NDUILayer *		m_pLayerUpdate;
    NDTimer *		m_pTimer;
	CUIExp *		m_pCtrlProgress;
	NDUILabel *		m_pLabelPromtp;
	int				m_iAccountID;
	int				m_iState;
    NDUILayer *		m_pLayerCheckWIFI;
	CC_SYNTHESIZE(bool,m_bIsLoadingLocalString,IsLoadLocalString);

private:
	void ontimer_first_run();
	void ontimer_check_copy();
	void clearSplash();
};
#endif
