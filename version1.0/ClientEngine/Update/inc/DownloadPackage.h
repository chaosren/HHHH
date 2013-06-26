//
//  DownLoadPackage.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 �ļ�����������Ҫ�������ظ��°�
 */

#ifndef __DownloadPackage_H
#define __DownloadPackage_H

#include "NDObject.h"
#include "KHttp.h"
#include "KData.h"
#include <string>

using namespace NDEngine;

bool isWifiNetWork();//�ж�wifi�Ƿ��ڹ���״̬
KData getHttpProxy();//��ȡhttp����
#define  RECONNECTCOUNT  5;
typedef enum
{
	DownloadStatusResNotFound,	//������Դ������
	DownloadStatusSuccess,		//���سɹ�
	DownloadStatusFailed,		//����ʧ��
}DownloadStatus;
//DownloadPackage���ڲ����õ�objective-c�������ⲿ�������
// @interface MainThreadSelector : NSObject
// - (void)runWithParam:(NSArray *)param;
// @end
/*
class DownloadPackageDelegate
{
	virtual void DidDownloadStatus(DownloadStatus status){};
	virtual void ReflashPercent(int percent, int pos, int filelen){};
};
*/
//�ļ���������
class DownloadPackage 
{
	//DECLARE_CLASS(DownloadPackage)
public:

	DownloadPackage();
	~DownloadPackage();

public:

	//�����ص��ļ�http��ַ
	void FromUrl(const char* url);
	//�����ص��ļ�����·��
	void ToPath(const char* path);
	//���ز���
	void Download();
    //��ȡ�ļ���С
	int GetFileSize(const char* filepath);
public:

	int m_nFileLen;
	//һ�����������ɿ�����˽�з������ⲿ�������
	void DownloadThreadExcute();
	virtual void DidDownloadStatus(DownloadStatus status){};
	virtual void ReflashPercent(int percent, int pos, int filelen){};

public:

	KHttp* m_pkHttp;
	std::string m_strDownloadURL;
	std::string m_strDownloadPath;
	//MainThreadSelector *m_selObj;
	
};



#endif


