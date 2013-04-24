#include "CCNodeLoaderLibrary.h"

#include "CCLayerLoader.h"
#include "CCLayerColorLoader.h"
#include "CCLayerGradientLoader.h"
#include "CCLabelBMFontLoader.h"
#include "CCLabelTTFLoader.h"
#include "CCSpriteLoader.h"
#include "CCScale9SpriteLoader.h"
#include "CCBFileLoader.h"
#include "CCMenuLoader.h"
#include "CCMenuItemLoader.h"
#include "CCMenuItemImageLoader.h"
#include "CCControlButtonLoader.h"
#include "CCParticleSystemQuadLoader.h"
#include "CCScrollViewLoader.h"

NS_CC_EXT_BEGIN

CCNodeLoaderLibrary::CCNodeLoaderLibrary()
{

}

CCNodeLoaderLibrary::~CCNodeLoaderLibrary()
{
	purge(true);
}

void CCNodeLoaderLibrary::registerDefaultCCNodeLoaders()
{
	registerCCNodeLoader("CCNode", CCNodeLoader::loader());
	registerCCNodeLoader("CCLayer", CCLayerLoader::loader());
	registerCCNodeLoader("CCLayerColor", CCLayerColorLoader::loader());
	registerCCNodeLoader("CCLayerGradient", CCLayerGradientLoader::loader());
	registerCCNodeLoader("CCSprite", CCSpriteLoader::loader());
	registerCCNodeLoader("CCLabelBMFont", CCLabelBMFontLoader::loader());
	registerCCNodeLoader("CCLabelTTF", CCLabelTTFLoader::loader());
	registerCCNodeLoader("CCScale9Sprite", CCScale9SpriteLoader::loader());
	registerCCNodeLoader("CCScrollView", CCScrollViewLoader::loader());
	registerCCNodeLoader("CCBFile", CCBFileLoader::loader());
	registerCCNodeLoader("CCMenu", CCMenuLoader::loader());
	registerCCNodeLoader("CCMenuItemImage", CCMenuItemImageLoader::loader());
	registerCCNodeLoader("CCControlButton", CCControlButtonLoader::loader());
	registerCCNodeLoader("CCParticleSystemQuad",
		CCParticleSystemQuadLoader::loader());
}

void CCNodeLoaderLibrary::registerCCNodeLoader(const char * pClassName,
											   CCNodeLoader * pCCNodeLoader)
{
	registerCCNodeLoader(CCString::create(pClassName), pCCNodeLoader);
}

void CCNodeLoaderLibrary::registerCCNodeLoader(CCString * pClassName,
											   CCNodeLoader * pCCNodeLoader)
{
	pClassName->retain();
	pCCNodeLoader->retain();
	mCCNodeLoaders.insert(CCNodeLoaderMapEntry(pClassName, pCCNodeLoader));
}

void CCNodeLoaderLibrary::unregisterCCNodeLoader(const char * pClassName)
{
	unregisterCCNodeLoader(CCString::create(pClassName));
}

void CCNodeLoaderLibrary::unregisterCCNodeLoader(CCString * pClassName)
{
	CCNodeLoaderMap::iterator ccNodeLoadersIterator = mCCNodeLoaders.find(
		pClassName);
	assert(ccNodeLoadersIterator != mCCNodeLoaders.end());
	ccNodeLoadersIterator->first->release();
	ccNodeLoadersIterator->second->release();
}

CCNodeLoader * CCNodeLoaderLibrary::getCCNodeLoader(CCString * pClassName)
{
	CCNodeLoaderMap::iterator ccNodeLoadersIterator = mCCNodeLoaders.find(
		pClassName);
	assert(ccNodeLoadersIterator != mCCNodeLoaders.end());
	return ccNodeLoadersIterator->second;
}

void CCNodeLoaderLibrary::purge(bool pReleaseCCNodeLoaders)
{
	if (pReleaseCCNodeLoaders)
	{
		for (CCNodeLoaderMap::iterator it = mCCNodeLoaders.begin();
			it != mCCNodeLoaders.end(); it++)
		{
			it->first->release();
			it->second->release();
		}
	}
	mCCNodeLoaders.clear();
}

static CCNodeLoaderLibrary * sSharedCCNodeLoaderLibrary = NULL;

CCNodeLoaderLibrary * CCNodeLoaderLibrary::sharedCCNodeLoaderLibrary()
{
	if (sSharedCCNodeLoaderLibrary == NULL)
	{
		sSharedCCNodeLoaderLibrary = new CCNodeLoaderLibrary();

		sSharedCCNodeLoaderLibrary->registerDefaultCCNodeLoaders();
	}
	return sSharedCCNodeLoaderLibrary;
}

void CCNodeLoaderLibrary::purgeSharedCCNodeLoaderLibrary()
{
	CC_SAFE_DELETE (sSharedCCNodeLoaderLibrary);
}

CCNodeLoaderLibrary * CCNodeLoaderLibrary::newDefaultCCNodeLoaderLibrary()
{
	CCNodeLoaderLibrary * ccNodeLoaderLibrary = CCNodeLoaderLibrary::library();

	ccNodeLoaderLibrary->registerDefaultCCNodeLoaders();

	return ccNodeLoaderLibrary;
}

NS_CC_EXT_END