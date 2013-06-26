/*
 *  ScriptGameDataLua.cpp
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 *	˵����ע�����ݿ�LUA�ӿ�
 */

#include "ScriptGameData.h"
#include "ScriptGameData_NewUtil.h"
#include "ScriptInc.h"
#include "ScriptDataBase.h"
#include "SqliteDBMgr.h"
#include "NDLocalization.h"
#include "ScriptGameDataLua.h"

//@loadini
using namespace NDEngine;

//#pragma mark ��ȡID�б�
int GetGameDataIdList(LuaState* pkState)
{
	lua_State* pkLuaState = pkState->GetCState();

	if (!pkLuaState)
	{
		pkState->PushNil();
		return 1;
	}

	lua_newtable(pkLuaState);

	LuaStack kArgsStack(pkState);
	// eScriptData
	LuaObject kScriptData = kArgsStack[1];
	// nKey
	LuaObject kKey = kArgsStack[2];
	// eRoleData
	LuaObject kRoleData = kArgsStack[3];

	if (!kScriptData.IsNumber() || !kKey.IsNumber() || !kRoleData.IsNumber())
	{
		return 1;
	}

	ID_VEC kIDVector;

#if WITH_NEW_DB
	NDGameDataUtil::getDataIdList(
			MAKE_NDTABLEPTR(
					kScriptData.GetInteger(),
					kKey.GetInteger(),
					kRoleData.GetInteger()),
			kIDVector);
#else
	ScriptGameDataObj.GetDataIdList((eScriptData) kScriptData.GetInteger(),
			kKey.GetInteger(), (eRoleData) kRoleData.GetInteger(), kIDVector);
#endif

	size_t uiSize = kIDVector.size();
	for (size_t i = 0; i < uiSize; i++)
	{
		lua_pushnumber(pkLuaState, i + 1);
		lua_pushnumber(pkLuaState, kIDVector[i]);
		lua_settable(pkLuaState, -3);
	}
	return 1;
}

#if WITH_NEW_DB
void ModifyParam(int nESD, unsigned int nKey, int& e)
{
	//˵����
	//LUA�������Ĳ�������Ҫ��鲢�����޸ģ�֮������Ҫ�޸�����ΪLUA�ĵ��úܲ��淶��
	//�磺local nVal = GetGameDataN(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex);
	//����������Ϊ�˶�ȡINI�����ļ���һ�У���3����������Ӧ����0������LUA��������NRoleData.ePet=1��������ĳ���ط���-1���0.

	if (nESD == (int)eMJR_DataBase ||
			nESD == (int)eMJR_TaskConfig)
	{
		e = 0;
	}
}
#endif

void SetGameDataN(int esd, unsigned int nKey, int e, int nId,
		unsigned short index, double dVal)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	NDGameDataUtil::setDataN( MAKE_NDTABLEPTR( esd, nKey, e),
			MAKE_CELLPTR( nId, index ), dVal );
#else
	return ScriptGameDataObj.SetData((eScriptData) esd, nKey, (eRoleData) e,
			nId, index, dVal);
#endif
}

void SetGameDataF(int esd, unsigned int nKey, int e, int nId,
		unsigned short index, float fVal)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	NDGameDataUtil::setDataF( MAKE_NDTABLEPTR( esd, nKey, e),
			MAKE_CELLPTR( nId, index ), fVal );
#else
	return ScriptGameDataObj.SetData((eScriptData) esd, nKey, (eRoleData) e,
			nId, index, fVal);
#endif
}

void SetGameDataS(int esd, unsigned int nKey, int e, int nId,
		unsigned short index, const char* szVal)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	NDGameDataUtil::setDataS( MAKE_NDTABLEPTR( esd, nKey, e ),
			MAKE_CELLPTR( nId, index ), szVal );
#else
	return ScriptGameDataObj.SetData((eScriptData) esd, nKey, (eRoleData) e,
			nId, index, szVal);
#endif
}

double GetGameDataN(int esd, unsigned int nKey, int e, int nId,
		unsigned short index)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	return NDGameDataUtil::getDataN( MAKE_NDTABLEPTR( esd, nKey, e ),
			MAKE_CELLPTR( nId, index ),false);
#else
	double ulVal = ScriptGameDataObj.GetData<double>((eScriptData) esd, nKey,
			(eRoleData) e, nId, index);
	return ulVal;
#endif
}

double GetGameDataF(int esd, unsigned int nKey, int e, int nId,
		unsigned short index)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	return NDGameDataUtil::getDataF( MAKE_NDTABLEPTR( esd, nKey, e ),
			MAKE_CELLPTR( nId, index ),false);
#else
	float fVal = ScriptGameDataObj.GetData<double>((eScriptData) esd, nKey,
			(eRoleData) e, nId, index);
	return fVal;
#endif
}

std::string GetGameDataS(int esd, unsigned int nKey, int e, int nId,
		unsigned short index)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	return NDGameDataUtil::getDataS( MAKE_NDTABLEPTR( esd, nKey, e ),
			MAKE_CELLPTR( nId, index ),false);
#else
	std::string strVal = ScriptGameDataObj.GetData < std::string
			> ((eScriptData) esd, nKey, (eRoleData) e, nId, index);
	return strVal;
#endif
}

//ɾ��һ����¼
void DelRoleSubGameDataById(int esd, unsigned int nKey, int e, int nId)
{
#if WITH_NEW_DB
	NDGameDataUtil::delRecordById( MAKE_NDTABLEPTR(esd, nKey, e), nId );
#else
	ScriptGameDataObj.DelData((eScriptData) esd, nKey, (eRoleData) e, nId);
#endif
}

//ɾ��һ�ű�
void DelRoleSubGameData(int esd, unsigned int nKey, int e)
{
#if WITH_NEW_DB
	NDGameDataUtil::delTable( MAKE_NDTABLEPTR(esd, nKey, e));
#else
	ScriptGameDataObj.DelData((eScriptData) esd, nKey, (eRoleData) e);
#endif
}

//ɾ��������ĳ��role/monster��Ӧ�ĵı���
void DelRoleGameDataById(int esd, unsigned int nKey)
{
#if WITH_NEW_DB
	NDGameDataUtil::delTableSet( (DATATYPE_MAJOR)esd, nKey );
#else
	ScriptGameDataObj.DelData((eScriptData) esd, nKey);
#endif
}

//ɾ��ĳ����������б�ɾ����Ⱥ��
void DelRoleGameData(int esd)
{
#if WITH_NEW_DB
	NDGameDataUtil::delTableSetGroup( (DATATYPE_MAJOR)esd );
#else
	ScriptGameDataObj.DelData((eScriptData) esd);
#endif
}

//ɾ����������
void DelGameData()
{
#if WITH_NEW_DB
	NDGameDataUtil::destroyAll();
#else
	ScriptGameDataObj.DelAllData();
#endif
}

//����
void DumpGameData(int esd, unsigned int nKey, int e, int nId)
{
#if WITH_NEW_DB
	//@todo..
#else
	ScriptGameDataObj.LogOut((eScriptData) esd, nKey, (eRoleData) e, nId);
#endif
}

//����
void DumpDataBaseData(const char* filename, int nId)
{
#if WITH_NEW_DB
	//@todo..
#else
	ScriptDBObj.LogOut(filename, nId);
#endif
}

//����
void LogOutRoleDataIdTable(int esd, unsigned int nKey, int e, int nRoleId,
		eIDList eList)
{
#if WITH_NEW_DB
	//@todo..
#else
	ScriptGameDataObj.LogOutRoleDataIdList((eScriptData) esd, nKey,
			(eRoleData) e, nRoleId, (eIDList) eList);
#endif
}

//��ȡ��ɫid�б������ɫ��ָ�ķ�Χ�ܹ�...��
int GetRoleDataIdTable(LuaState* pkState)
{
	lua_State* pkLuaState = pkState->GetCState();

	if (!pkLuaState)
	{
		pkState->PushNil();
		return 1;
	}

	lua_newtable(pkLuaState);

	LuaStack kArgsStack(pkState);
	// eScriptData
	LuaObject pkEScriptData = kArgsStack[1];
	// nKey
	LuaObject nKey = kArgsStack[2];
	// eRoleData
	LuaObject kERoleData = kArgsStack[3];
	LuaObject nRoleId = kArgsStack[4];
	LuaObject kEList = kArgsStack[5];

	if (!pkEScriptData.IsNumber() || !nKey.IsNumber() || !kERoleData.IsNumber()
			|| !nRoleId.IsNumber() || !kEList.IsNumber())
	{
		return 1;
	}

	ID_VEC kIDVector;

#if WITH_NEW_DB
	NDGameDataUtil::getRoleDataIdList( MAKE_NDTABLEPTR(pkEScriptData.GetInteger(),
		nKey.GetInteger(),kERoleData.GetInteger()), nRoleId.GetInteger(),
		(eIDList)kEList.GetInteger(), kIDVector);
#else
	ScriptGameDataObj.GetRoleDataIdList(
			(eScriptData) pkEScriptData.GetInteger(), nKey.GetInteger(),
			(eRoleData) kERoleData.GetInteger(), nRoleId.GetInteger(),
			(eIDList) kEList.GetInteger(), kIDVector);
#endif

	size_t uiSize = kIDVector.size();

	for (size_t i = 0; i < uiSize; i++)
	{
		lua_pushnumber(pkLuaState, i + 1);
		lua_pushnumber(pkLuaState, kIDVector[i]);
		lua_settable(pkLuaState, -3);
	}
	return 1;
}

void AddRoleDataId(int esd, unsigned int nKey, int e, int nRoleId, int eList,
		int nId)
{
#if WITH_NEW_DB
	NDGameDataUtil::addRoleDataId( MAKE_NDTABLEPTR(esd,nKey,e),
			nRoleId, eList, nId );
#else
	ScriptGameDataObj.PushRoleDataId((eScriptData) esd, nKey, (eRoleData) e,
			nRoleId, (eIDList) eList, nId);
#endif
}

void DelRoleDataId(int esd, unsigned int nKey, int e, int nRoleId, int eList,
		int nId)
{
#if WITH_NEW_DB
	NDGameDataUtil::delRoleDataId( MAKE_NDTABLEPTR(esd,nKey,e),
			nRoleId, eList, nId );
#else
	ScriptGameDataObj.PopRoleDataId((eScriptData) esd, nKey, (eRoleData) e,
			nRoleId, (eIDList) eList, nId);
#endif
}

void DelRoleDataIdList(int esd, unsigned int nKey, int e, int nRoleId,
		int eList)
{
#if WITH_NEW_DB
	NDGameDataUtil::delRoleDataIdList( MAKE_NDTABLEPTR(esd,nKey,e),
			nRoleId, eList );
#else
	ScriptGameDataObj.DelRoleDataIdList((eScriptData) esd, nKey, (eRoleData) e,
			nRoleId, (eIDList) eList);
#endif
}

int Sqlite_SelectData(const char* pszSql, int nColNum)
{
	return CSqliteDBMgr::shareInstance().SelectData(pszSql, nColNum);
}
bool Sqlite_ExcuteSql(const char* pszSql)
{
	return CSqliteDBMgr::shareInstance().ExcuteSql(pszSql);
}
int Sqlite_GetColDataN(int nRowIdx, int nFieldIdx)
{
	return CSqliteDBMgr::shareInstance().GetColDataN(nRowIdx, nFieldIdx);
}
std::string Sqlite_GetColDataS(int nRowIdx, int nFieldIdx)
{
	return std::string(
			CSqliteDBMgr::shareInstance().GetColDataS(nRowIdx, nFieldIdx));
}
bool Sqlite_IsExistTable(const char* pszTableName)
{
	return CSqliteDBMgr::shareInstance().IsExistTable(pszTableName);
}
std::string GetTxtPub_Common(const char* pszTableName)
{
	return NDCommonCString(pszTableName);
}
std::string GetTxtPri(const char* pszTableName)
{
	return NDCommonCString2(pszTableName);
}

//NS_NDENGINE_BGN
void NDScriptGameData::Load()
{
	ETLUAFUNC("GetGameDataIdList", GetGameDataIdList);
	ETCFUNC("SetGameDataN", SetGameDataN);
	ETCFUNC("SetGameDataF", SetGameDataF);
	ETCFUNC("SetGameDataS", SetGameDataS);
	ETCFUNC("GetGameDataN", GetGameDataN);
	ETCFUNC("GetGameDataF", GetGameDataF);
	ETCFUNC("GetGameDataS", GetGameDataS);
	ETCFUNC("DelRoleSubGameDataById", DelRoleSubGameDataById);
	ETCFUNC("DelRoleSubGameData", DelRoleSubGameData);
	ETCFUNC("DelRoleGameDataById", DelRoleGameDataById);
	ETCFUNC("DelRoleGameData", DelRoleGameData);
	ETCFUNC("DelGameData", DelGameData);
	ETCFUNC("DumpGameData", DumpGameData);
	ETCFUNC("DumpDataBaseData", DumpDataBaseData);
	ETLUAFUNC("GetRoleDataIdTable", GetRoleDataIdTable);
	ETCFUNC("AddRoleDataId", AddRoleDataId);
	ETCFUNC("DelRoleDataId", DelRoleDataId);
	ETCFUNC("LogOutRoleDataIdTable", LogOutRoleDataIdTable);
	ETCFUNC("Sqlite_SelectData", Sqlite_SelectData);
	ETCFUNC("Sqlite_ExcuteSql", Sqlite_ExcuteSql);
	ETCFUNC("Sqlite_GetColDataN", Sqlite_GetColDataN);
	ETCFUNC("Sqlite_GetColDataS", Sqlite_GetColDataS);
	ETCFUNC("Sqlite_IsExistTable", Sqlite_IsExistTable);
	ETCFUNC("GetTxtPub", GetTxtPub_Common);
	ETCFUNC("GetTxtPri", GetTxtPri);
}