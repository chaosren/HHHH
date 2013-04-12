//
//  NDDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDDirector.h"
#include "ccMacros.h"
#include "CCEGLView.h"
#include "CCTexture2D.h"
#include "CCTextureCache.h"
#include "CCTouchDispatcher.h"
#include "NDPicture.h"
#include "NDAnimationGroupPool.h"
#include "define.h"
#include "CCTransition.h"
#include "CCPointExtension.h"
#include "ObjectTracker.h"
#include "NDPicture.h"
#include "NDMapData.h"
#include "NDAnimationGroupPool.h"

using namespace cocos2d;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDDirector, NDObject)

static NDDirector* gs_pkNDDirectorDefaultDirector = NULL;

NDDirector::NDDirector()
{
	INC_NDOBJ_RTCLS;

	NDAsssert(gs_pkNDDirectorDefaultDirector == NULL);

	m_pkDirector = CCDirector::sharedDirector();
	m_pkSetViewRectNode = NULL;
	m_bResetViewRect = false;
	m_pkTransitionSceneWait = NULL;
	m_eTransitionSceneType = eTransitionSceneNone;
}

NDDirector::~NDDirector()
{
	DEC_NDOBJ_RTCLS;

	SAFE_DELETE (m_pkTransitionSceneWait);

	SAFE_RELEASE( m_pkDirector );

	gs_pkNDDirectorDefaultDirector = NULL;
}

NDDirector* NDDirector::DefaultDirector()
{
	if (gs_pkNDDirectorDefaultDirector == NULL)
	{
		gs_pkNDDirectorDefaultDirector = new NDDirector();
	}
	return gs_pkNDDirectorDefaultDirector;
}

void NDDirector::RemoveDelegate(NDObject* receiver)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;

		if (obj == receiver)
		{
			m_delegates.erase(iter);
			break;
		}
	}
}

void NDDirector::TransitionAnimateComplete()
{
	if (!m_pkTransitionSceneWait)
	{
		return;
	}

	switch (m_eTransitionSceneType)
	{
	case eTransitionSceneReplace:
		ReplaceScene (m_pkTransitionSceneWait);
		break;
	case eTransitionScenePush:
		PushScene(m_pkTransitionSceneWait);
		break;
	case eTransitionScenePop:
		PopScene(NULL, false);
	default:
		break;
	}

	m_pkTransitionSceneWait = NULL;
}

void NDDirector::SetTransitionScene(NDScene *scene, TransitionSceneType type)
{
	m_pkTransitionSceneWait = scene;

	m_eTransitionSceneType = type;

	m_pkDirector->pushScene(CCTransitionFade::transitionWithDuration(1.2f, (CCScene *)scene->getCCNode()));
	//[m_director pushScene:[CCTransitionFadeTR transitionWithDuration:1.2f scene:(CCScene *)scene->m_ccNode]];

	/*
	 static bool right = true;
	 if (right)
	 [m_director pushScene:[CCMoveInRTransition transitionWithDuration:0.6f scene:(CCScene *)scene->m_ccNode]];
	 else
	 [m_director pushScene:[CCMoveInLTransition transitionWithDuration:0.6f scene:(CCScene *)scene->m_ccNode]];

	 right = !right;
	 */
}


void NDDirector::RunScene(NDScene* scene)
{
// 	//@zwq
// 	if (m_pkDirector->getRunningScene())
// 	{
// 		m_kScenesStack.push_back(scene);
// 		m_pkDirector->replaceScene((CCScene *) scene->m_ccNode);
// 	}
// 	else
// 	{
// 		m_kScenesStack.push_back(scene);
// 		m_pkDirector->runWithScene((CCScene *) scene->m_ccNode);
// 	}

	LOGD("Entry run scene,scene value is %d",(int)scene);

	m_kScenesStack.push_back(scene);

	LOGD("ready to runwithscene,scene->m_ccNode value is %d",(int)(scene->getCCNode()));

	m_pkDirector->runWithScene((CCScene *) scene->getCCNode());
}

void NDDirector::ReplaceScene(NDScene* pkScene, bool bAnimate/*=false*/)
{
// 	if (bAnimate) 
// 	{
// 		SetTransitionScene(pkScene, eTransitionSceneReplace);
// 
// 		return;
// 	}

	if (m_kScenesStack.size() > 0)
		{
			//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
			this->BeforeDirectorPopScene(m_kScenesStack.back(), true);
	
			NDScene* pkScene = m_kScenesStack.back();
	
			if (pkScene)
			{
				delete pkScene;
			}
	
			m_kScenesStack.pop_back();
	
			this->AfterDirectorPopScene(true);
		}
	
	BeforeDirectorPushScene(pkScene);
	m_kScenesStack.push_back(pkScene);
	m_pkDirector->replaceScene((CCScene *) pkScene->getCCNode());
	//RunScene(pkScene);
	AfterDirectorPushScene(pkScene);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
}

void NDDirector::PushScene(NDScene* scene, bool bAnimate/*=false*/)
{
// 	if (bAnimate) 
// 	{
// 		SetTransitionScene(scene, eTransitionScenePush);
// 
// 		return;
// 	}

	this->BeforeDirectorPushScene(scene);

	m_kScenesStack.push_back(scene);
	m_pkDirector->pushScene((CCScene *) scene->getCCNode());

	this->AfterDirectorPushScene(scene);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
}

bool NDDirector::PopScene(NDScene* scene/*=NULL*/, bool bAnimate/*=false*/)
{
// 	if (bAnimate && m_kScenesStack.size() >= 2) 
// 	{
// 		SetTransitionScene(m_kScenesStack[m_kScenesStack.size()-2], eTransitionScenePop);
// 
// 		return true;
// 	}

	return this->PopScene(true);
}

bool NDDirector::PopScene(bool cleanUp)
{
	if (m_kScenesStack.size() < 2)
	{
		return false;
	}

	this->BeforeDirectorPopScene(this->GetRunningScene(), cleanUp);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());

	if (cleanUp)
	{
		delete m_kScenesStack.back();
	}
	m_kScenesStack.pop_back();
	m_pkDirector->popScene();

	this->AfterDirectorPopScene(cleanUp);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());

	return true;
}

void NDDirector::PurgeCachedData()
{
	CCTextureCache::sharedTextureCache()->removeAllTextures();

	NDPicturePool::DefaultPool()->PurgeDefaultPool();

	NDAnimationGroupPool::purgeDefaultPool();

//  	if (m_pkDirector)
//  		m_pkDirector->purgeCachedData();
}

void NDDirector::Stop()
{
	m_pkDirector->end();

	while (m_kScenesStack.begin() != m_kScenesStack.end())
	{
		delete m_kScenesStack.back();
		m_kScenesStack.pop_back();
	}
}

NDScene* NDDirector::GetScene(const NDRuntimeClass* runtimeClass)
{
	for (size_t i = 0; i < m_kScenesStack.size(); i++)
	{
		NDScene* scene = m_kScenesStack.at(i);

		if (scene->IsKindOfClass(runtimeClass))
		{
			return scene;
		}
	}
	return NULL;
}

NDScene* NDDirector::GetRunningScene()
{
	if (m_kScenesStack.size() > 0)
	{
		return m_kScenesStack.back();
	}

	return NULL;
}

void NDDirector::SetViewRect(CCRect kRect, NDNode* pkNode)
{
	if (m_pkTransitionSceneWait)
	{
		return;
	}

	CCSize kWinSize = m_pkDirector->getWinSizeInPixels();

#if 1 //@check
	glEnable (GL_SCISSOR_TEST);

// 	glScissor(kWinSize.height - kRect.origin.y - kRect.size.height,
// 			kWinSize.width - kRect.origin.x - kRect.size.width, kRect.size.height,
// 			kRect.size.width);
	
	glScissor(	kRect.origin.x,
				kWinSize.height - (kRect.origin.y + kRect.size.height),
	 			kRect.size.width, 
				kRect.size.height );

#endif

	/***
	*	这里略有不同，但是可以接受，因为Mac上是调用UIDevice.h中的，这里不需要。
	*
	*	@author 郭浩
	*/

	m_pkSetViewRectNode = pkNode;
	m_bResetViewRect = true;
}

void NDDirector::ResumeViewRect(NDNode* drawingNode)
{
	if (!m_bResetViewRect)
	{
		return;
	}

	if (m_pkSetViewRectNode)
	{
		if (drawingNode == m_pkSetViewRectNode)
		{
			return;
		}

		if (drawingNode->IsChildOf(m_pkSetViewRectNode))
		{
			return;
		}
	}

	DisibleScissor();
}

void NDDirector::DisibleScissor()
{
	glDisable (GL_SCISSOR_TEST);
	m_pkSetViewRectNode = NULL;
	m_bResetViewRect = false;
}

void NDDirector::BeforeDirectorPopScene(NDScene* scene, bool cleanScene)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->BeforeDirectorPopScene(this, scene, cleanScene);
		}
	}
}

void NDDirector::AfterDirectorPopScene(bool cleanScene)
{
	std::vector<NDObject*>::iterator iter;
	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->AfterDirectorPopScene(this, cleanScene);
		}
	}
}

void NDDirector::BeforeDirectorPushScene(NDScene* scene)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->BeforeDirectorPushScene(this, scene);
		}
	}
}

void NDDirector::AfterDirectorPushScene(NDScene* scene)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->AfterDirectorPushScene(this, scene);
		}
	}
}

NDScene* NDDirector::GetSceneByTag(int nSceneTag)
{
	for (size_t i = 0; i < m_kScenesStack.size(); i++)
	{
		NDScene* scene = m_kScenesStack.at(i);
		if (scene->GetTag() == nSceneTag)
		{
			return scene;
		}
	}
	return NULL;
}

//@gc
void NDDirector::Recyle()
{
	NDPicturePool::DefaultPool()->Recyle();
	NDMapTexturePool::defaultPool()->Recyle();
	NDAnimationGroupPool::defaultPool()->Recyle();
}

//@ios
//这个比例参考960*640
//备注：这个函数适用于所有非android平台
float NDDirector::getIosScale() const
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (IS_IPAD)
    {
        return float(IPAD_POINT_SIZE_WIDTH) / 960.0;
    }
	else
    {
        return 0.5f * CCDirector::sharedDirector()->getContentScaleFactor();
    }
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	return 0.5f * CCDirector::sharedDirector()->getContentScaleFactor();
#else
	return 1.0f;
#endif
}

//@android
//返回值：	x值存放x方向的缩放比例
//			y值存放y放点的缩放比例
//这个函数仅对android手机有效
//参考960*640
CCPoint NDDirector::getAndroidScale() const
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCSize sz = CCDirector::sharedDirector()->getVisibleSize();
	return ccp( sz.width/960, sz.height/640 );
#else
	return ccp( 1,1 );
#endif
}

//返回资源缩放比例
//参考480*320
float NDDirector::getResourceScale()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return 2.0f * getAndroidScale().y; //乘2是因为是参考960*640的，不要改成1
#else
   	float scale = m_pkDirector->getContentScaleFactor();
    if (IS_IPAD)
    {
        scale *= (float(IPAD_POINT_SIZE_HEIGHT) / 320);
    }
    return scale;
#endif
}

//返回x方向坐标缩放比例
//参考960*640
float NDDirector::getCoordScaleX()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return getAndroidScale().x;
#else
    float scaleX = 0.5f * m_pkDirector->getContentScaleFactor();
    if (IS_IPHONE5)
    {
        scaleX *= IPHONE5_WIDTH_SCALE;
    }
    else if (IS_IPAD)
    {
        scaleX *= (float(IPAD_POINT_SIZE_WIDTH) / 480);
    }
    return scaleX;
#endif
}

//返回y方向坐标缩放比例
//参考960*640
float NDDirector::getCoordScaleY()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return getAndroidScale().y;
#else
	float scaleY = 0.5f * m_pkDirector->getContentScaleFactor();
    if (IS_IPAD)
    {
        scaleY *= (float(IPAD_POINT_SIZE_HEIGHT) / 320);
    }
    return scaleY;
#endif
}

NS_NDENGINE_END
