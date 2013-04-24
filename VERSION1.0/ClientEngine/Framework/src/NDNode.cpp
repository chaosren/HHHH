//
//  NDNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDNode.h"
#include "NDBaseNode.h"
#include <cocos2d.h>
#include "CCPointExtension.h"
#include "define.h"
#include "shaders/CCShaderCache.h"
#include "NDDebugOpt.h"
#include "ObjectTracker.h"
#include "NDAction.h"

using namespace cocos2d;

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDNode, NDCommonProtocol)

NDNode::NDNode():
m_nPosx(-1),
m_nPosy(-1)
{
	INC_NDOBJ_RTCLS

	m_pkParent = NULL;
	m_pkCCNode = NULL;
	m_bDrawEnabled = true;
	m_nParam1 = 0;
	m_nParam2 = 0;

	m_pShaderProgram = NULL; //@shader
	m_glServerState = CC_GL_BLEND;
}

NDNode::~NDNode()
{
	DEC_NDOBJ_RTCLS

	RemoveAllChildren(true);
	if (m_pkParent)
	{
		RemoveFromParent(false);
	}
	CC_SAFE_RELEASE (m_pkCCNode);
	CC_SAFE_RELEASE(m_pShaderProgram); //@shader
}

NDNode* NDNode::Node()
{
	NDNode* node = new NDNode();
	node->Initialization();
	return node;
}

void NDNode::Initialization()
{
	NDAsssert(m_pkCCNode == NULL);

	m_pkCCNode = new NDBaseNode();
	NDBaseNode *ndBaseNode = (NDBaseNode *) m_pkCCNode;
	ndBaseNode->setNDNode(this);
}

void NDNode::draw()
{
}

NDNode* NDNode::GetParent()
{
	return m_pkParent;
}

void NDNode::SetParent(NDNode* node)
{
	m_pkParent = node;
}

const std::vector<NDNode*>& NDNode::GetChildren()
{
	return m_kChildrenList;
}

void NDNode::RemoveAllChildren(bool bCleanUp)
{
	NDAsssert(m_pkCCNode != NULL);

	while (m_kChildrenList.begin() != m_kChildrenList.end())
	{
		NDNode* pkNDNode = (NDNode*) m_kChildrenList.back();

		LuaObject funcObj;

		if (pkNDNode && pkNDNode->GetDestroyNotify(funcObj) || funcObj.IsFunction())
		{
			LuaFunction<void> luaDestroyEventCallBack = funcObj;
			luaDestroyEventCallBack(pkNDNode, bCleanUp);
		}

		NDNodeDelegate* pkDelegate =
				dynamic_cast<NDNodeDelegate*>(pkNDNode->GetDelegate());

		if (pkDelegate)
		{
			pkDelegate->OnBeforeNodeRemoveFromParent(pkNDNode, bCleanUp);
		}

		m_kChildrenList.pop_back();
		pkNDNode->SetParent(NULL);

		if (pkDelegate)
		{
			pkDelegate->OnAfterNodeRemoveFromParent(pkNDNode, bCleanUp);
		}

		CCNode *pkNode = pkNDNode->m_pkCCNode;
		m_pkCCNode->removeChild(pkNode, bCleanUp);

		if (bCleanUp)
		{
			delete pkNDNode;
		}
	}
}

CCSize NDNode::GetContentSize()
{
	NDAsssert(m_pkCCNode != NULL);

	return m_pkCCNode->getContentSize();
}

void NDNode::SetContentSize(CCSize size)
{
	NDAsssert(m_pkCCNode != NULL);

	m_pkCCNode->setContentSize(size);
}

int NDNode::GetzOrder()
{
	NDAsssert(m_pkCCNode != NULL);

	return m_pkCCNode->getZOrder();
}

int NDNode::GetTag()
{
	NDAsssert(m_pkCCNode != NULL);

	return m_pkCCNode->getTag();
}

void NDNode::SetTag(int tag)
{
	NDAsssert(m_pkCCNode != NULL);

	m_pkCCNode->setTag(tag);
}

void NDNode::AddChild(NDNode* node)
{
	if (node && node->m_pkCCNode)
	{
		const char* pszTemp = GetRuntimeClass()->className;

		CCNode *ccNode = node->m_pkCCNode;
		int z = ccNode->getZOrder();
		int tag = ccNode->getTag();

		AddChild(node, z, tag);
	}
}

void NDNode::AddChild(NDNode* node, int z)
{
	CCNode *ccNode = node->m_pkCCNode;
	int tag = ccNode->getTag();

	AddChild(node, z, tag);
}

void NDNode::AddChild(NDNode* pkNode, int nZBuffer, int nTag)
{
	NDAsssert(m_pkCCNode != NULL && pkNode != NULL && pkNode->m_pkCCNode != NULL);
	NDAsssert(pkNode != this);

	CCNode* pkCCNode = pkNode->m_pkCCNode;

	pkNode->SetParent(this);

	m_pkCCNode->addChild(pkCCNode, nZBuffer, nTag);

	m_kChildrenList.push_back(pkNode); 
}

void NDNode::RemoveChild(NDNode* pkNode, bool bCleanUp)
{
	NDAsssert(m_pkCCNode != NULL && pkNode != NULL && pkNode->m_pkCCNode != NULL);

	std::vector<NDNode*>::iterator iter = m_kChildrenList.begin();
	for (; iter != m_kChildrenList.end(); iter++)
	{
		NDNode* ndNode = (NDNode*) *iter;
		if (ndNode->m_pkCCNode == pkNode->m_pkCCNode)
		{
			LuaObject funcObj;

			if (ndNode && ndNode->GetDestroyNotify(funcObj)
					|| funcObj.IsFunction())
			{
				LuaFunction<void> luaDestroyEventCallBack = funcObj;
				luaDestroyEventCallBack(ndNode, bCleanUp);
			}

			NDNodeDelegate* delegate =
					dynamic_cast<NDNodeDelegate*>(ndNode->GetDelegate());

			if (delegate)
			{
				delegate->OnBeforeNodeRemoveFromParent(ndNode, bCleanUp);
			}

			m_kChildrenList.erase(iter);
			ndNode->SetParent(NULL);

			if (delegate)
			{
				delegate->OnAfterNodeRemoveFromParent(ndNode, bCleanUp);
			}

			CCNode *ccNode = ndNode->m_pkCCNode;
			m_pkCCNode->removeChild(ccNode, bCleanUp);

			if (bCleanUp)
			{
				delete ndNode;
			}

			break;
		}
	}
}

void NDNode::RemoveChild(int tag, bool bCleanUp)
{
	NDAsssert(m_pkCCNode != NULL);

	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin(); iter != m_kChildrenList.end();
			iter++)
	{
		NDNode* node = (NDNode*) *iter;
		if (node->m_pkCCNode->getTag() == tag)
		{
			LuaObject funcObj;

			if (node->GetDestroyNotify(funcObj) || funcObj.IsFunction())
			{
				LuaFunction<void> luaDestroyEventCallBack = funcObj;
				luaDestroyEventCallBack(node, bCleanUp);
			}

			NDNodeDelegate* delegate =
					dynamic_cast<NDNodeDelegate*>(node->GetDelegate());

			if (delegate)
			{
				delegate->OnBeforeNodeRemoveFromParent(node, bCleanUp);
			}

			m_kChildrenList.erase(iter);
			node->SetParent(NULL);

			if (delegate)
			{
				delegate->OnAfterNodeRemoveFromParent(node, bCleanUp);
			}

			m_pkCCNode->removeChildByTag(tag, bCleanUp);

			if (bCleanUp)
			{
				delete node;
			}

			break;
		}
	}
}

void NDNode::RemoveFromParent(bool bCleanUp)
{
	NDAsssert(m_pkCCNode != NULL);

	if (m_pkParent)
	{
		m_pkParent->RemoveChild(this, bCleanUp);
	}
}

bool NDNode::ContainChild(NDNode* node)
{
	NDAsssert(m_pkCCNode != NULL && node != NULL && node->m_pkCCNode != NULL);

	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin(); iter != m_kChildrenList.end();
			iter++)
	{
		NDNode* ndNode = (NDNode*) *iter;
		if (ndNode == node)
		{
			return true;
		}
	}

	return false;
}

NDNode* NDNode::GetChild(int tag)
{
	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin(); iter != m_kChildrenList.end();
			iter++)
	{
		NDNode* pkNode = (NDNode*) *iter;
		if (pkNode && pkNode->m_pkCCNode->getTag() == tag)
		{
			return pkNode;
		}
	}
	return NULL;
}

bool NDNode::IsChildOf(NDNode* node)
{
	NDNode* pNode = GetParent();
	while (pNode)
	{
		if (pNode == node)
		{
			return true;
		}
		pNode = pNode->GetParent();
	}
	return false;
}

void NDNode::EnableDraw(bool enabled)
{
	m_bDrawEnabled = enabled;

	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin();
		iter != m_kChildrenList.end();iter++)
	{
		NDNode* node = (NDNode*) *iter;
		node->EnableDraw(m_bDrawEnabled);
	}
}

bool NDNode::DrawEnabled()
{
	return m_bDrawEnabled;
}

void NDNode::SetParam1(int nParam1)
{
	m_nParam1 = nParam1;
}

void NDNode::SetParam2(int nParam2)
{
	m_nParam2 = nParam2;
}

int NDNode::GetParam1()
{
	return m_nParam1;
}

int NDNode::GetParam2()
{
	return m_nParam2;
}

void NDNode::SetDestroyNotify(LuaObject func)
{
	m_kDelegateDestroy = func;
}

bool NDNode::GetDestroyNotify(LuaObject& func)
{
	if (!m_kDelegateDestroy.IsFunction())
	{
		return false;
	}

	func = m_kDelegateDestroy;

	return true;
}

void NDNode::AddViewer(NDCommonProtocol* viewer)
{
	RemoveViewer(viewer);

	if (NULL == viewer || viewer == this)
	{
		return;
	}

	m_listCommonViewer.push_back(viewer->QueryProtocolLink());
}

void NDNode::RemoveViewer(NDCommonProtocol* viewer)
{
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();

	while (it != m_listCommonViewer.end())
	{
		NDCommonProtocol* p = (*it).Pointer();

		if (!(!p || p == viewer))
		{
			it++;
			continue;
		}

		it = m_listCommonViewer.erase(it);
	}
}

bool NDNode::DispatchClickOfViewr(NDObject* object)
{
	bool bDeal = false;
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++)
	{
		NDCommonProtocol* p = (*it).Pointer();

		if (!p || this == p)
		{
			continue;
		}

		p->OnClick(object);

		bDeal = true;
	}

	return bDeal;
}

void NDNode::Destroy()
{
	delete this;
}

//@shader
void NDNode::DrawSetup( const char* shaderType /*=kCCShader_PositionTexture_uColor*/ )
{
	if (getShaderProgram() == NULL)
	{
		setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(shaderType));
	}

	ccGLEnable( m_glServerState );
	CCAssert(getShaderProgram(), "No shader program set for this node");

	getShaderProgram()->use();
	getShaderProgram()->setUniformForModelViewProjectionMatrix();
}

NDAction* NDNode::RunAction( NDAction* pkAction )
{
	m_pkCCNode->runAction(pkAction->getCCAction());

	return 0;
}

NS_NDENGINE_END