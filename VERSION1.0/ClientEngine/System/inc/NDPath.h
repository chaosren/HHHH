//
//  NDPath.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (����)DeNA. All rights reserved.
//

#ifndef __NDPath_H
#define __NDPath_H

#include "NDObject.h"
#include <string>
#include "define.h"
#include <map>

NS_NDENGINE_BGN

using namespace std;

class NDPath: public NDObject
{
	DECLARE_CLASS (NDPath)
public:
	NDPath();
	~NDPath();

public:
	static const string GetAppPath();
	static const string GetCashesPath();
	static const string GetDocumentPath();
	static const string GetRootResPath(bool bPackage = false);
	
	// res path
	static const string GetResPath(bool bPackage = false);
	static const string GetDBPath();
	static const string GetResPath(const char* fileName);
	static const string GetImagePath(bool bPackage = false);  
	static const string GetImage00Path();  
	static const string GetMapPath();
	static const string GetMapResPath();
	static const string GetAnimationPath();

	static const string GetSoundPath();
	static const string GetImgPathBattleUI(const char* fileName);
	static const string GetImgPathBattleUI();
	static const string GetImgPath(const char* fileName,bool bPackage = false);
	static const string GetImg00Path(const char* fileName);
	static const string GetImgPathNew(const char* fileName);
	static const string GetImgPathNewAdvance(const char* fileName);
	static const string GetAniPath(const char* fileName);
	static const string GetMapPath(const char* fileName);
	static const string GetUIConfigPath(const char* filename);
	static const string GetUIImgPath(const char* uiFileNameWithPath);
	
	static const string GetSMImgPath(const char* fileName);
	static const string GetSMImg00Path(const char* fileName);
	static const string GetScriptPath(const char* filename);
	static const string GetScriptPath();
	static const string GetAppResFilePath(const char* filename);
	static const string GetResourceFilePath(const char* filename);
	static const string GetSMVideoPath(const char* fileName);
	static const string GetImgPathUINew(const char* fileName);
	static const string GetImgPathUINewAdvance(const char* fileName);
 	static const string GetFullImagepath(const char* fileName);
 	static const string GetUIPath(const char* fileName);
	static const string GetUIPath();
	static const string GetGameConfigPath(const char* pszConfFileName,bool bPackage = false);
	//������end
	static void SetResDirPos( int iPos );
	static int GetResDirPos(){ return s_iResDirPos; }
	static const char* GetRootResDirName();

	static const string GetLogPath();

	static void PrintResStatistic(const string ResPath);
	static void ClearResPath();

protected:

	static int s_iResDirPos;//��ԴĿ¼����λ�� 0:AppĿ¼��,1:DocumentĿ¼��
};

NS_NDENGINE_END

#endif
