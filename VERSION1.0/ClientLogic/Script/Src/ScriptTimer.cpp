/*
 *  ScriptTimer.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-3-9.
 *  Copyright 2012 (����)DeNA. All rights reserved.
 *
 */

#include "ScriptTimer.h"


unsigned int RegisterTimer(LuaObject func, float fInterval)
{
	unsigned int unTag	= ScriptTimerMgrObj.AddTimer(func, fInterval);
	return unTag;
}

void UnRegisterTimer(unsigned int nTag)
{
	ScriptTimerMgrObj.RemoveTimer(nTag);
}

namespace NDEngine {

void ScriptTimerMgr::Load()
{
	ETCFUNC("RegisterTimer", RegisterTimer);
	ETCFUNC("UnRegisterTimer", UnRegisterTimer);
}

void ScriptTimerMgr::OnTimer(OBJID tag)
{
	//NDAsssert(m_mapDebugTimerFuncTip.find(tag) != m_mapDebugTimerFuncTip.end());
	std::map<OBJID, LuaObject>::iterator
	it = m_mapFunc.find(tag);
	
	if (it == m_mapFunc.end())
	{
		return;
	}
	//ScriptMgrObj.DebugOutPut("script time call back:%s", m_mapDebugTimerFuncTip[tag].c_str());
	
	LuaObject& fun = it->second;
	
	if (fun.IsFunction())
	{
		LuaFunction<void> luaFunc(fun);
		luaFunc(tag);
	}
}

unsigned int ScriptTimerMgr::AddTimer(LuaObject func, float fInterval)
{
	if (!func.IsFunction())
	{
		return 0;
	}
	
	OBJID nId = m_idAlloc.GetID();
	
	m_mapFunc.insert(std::make_pair(nId, func));
	
	m_timer.SetTimer(this, nId, fInterval);
	
	return nId;
}

bool ScriptTimerMgr::RemoveTimer(OBJID tag)
{
	std::map<OBJID, LuaObject>::iterator
	it = m_mapFunc.find(tag);
	
	if (it == m_mapFunc.end())
	{
		return false;
	}
	
	//ScriptMgrObj.DebugOutPut("remove timer:%s", m_mapDebugTimerFuncTip[tag].c_str());
	m_mapFunc.erase(it);
	
	m_idAlloc.ReturnID(tag);
	
	m_timer.KillTimer(this, tag);
	
	return true;
}

bool ScriptTimerMgr::RemoveAllTimer()
{
	std::map<OBJID, LuaObject>::iterator
	it = m_mapFunc.begin();
	
	while (it != m_mapFunc.end()) 
	{
		OBJID nId = it->first;
		
		m_mapFunc.erase(it++);
		
		m_timer.KillTimer(this, nId);
	}
	
	m_idAlloc.reset();
	return true;
}

}
