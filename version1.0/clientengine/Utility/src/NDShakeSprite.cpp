#include "NDShakeSprite.h"
#include "CCShake.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDShakeSprite,NDUIImage)

NDShakeSprite::NDShakeSprite()
{
	m_pkTargetNode = 0;
	CCTime kTime;
	kTime.gettimeofdayCocos2d(&m_kLastUpdateTimeVal,0);
}

NDShakeSprite::~NDShakeSprite()
{

}

void NDShakeSprite::draw()
{
	static bool bFirst = true;

	double dbTimeDelta = 0.0;
	CCTime kTime;
	cc_timeval kCurrentTime = {0};
	kTime.gettimeofdayCocos2d(&kCurrentTime,0);
	dbTimeDelta = kTime.timersubCocos2d(&m_kLastUpdateTimeVal,&kCurrentTime);

	if (dbTimeDelta / 1000.0 < 5.0)
	{
		m_pkCCNode->setScale(4.0f);
		NDUIImage::draw();
		return;
	}

	if (bFirst)
	{
		CCScaleTo* pkMoveTo = CCScaleTo::create(0.30f,1.0f,1.0f);
		CCCallFunc* pkFunc = CCCallFunc::actionWithTarget(m_pkCCNode,
			callfunc_selector(NDShakeSprite::CallbackFunction));
		m_pkCCNode->runAction(CCSequence::actions(pkMoveTo,pkFunc,0));
		bFirst = false;
	}

	static bool bFirst2 = true;

	if (dbTimeDelta / 1000.0f >= 5.3 && bFirst2)
	{
		if (m_pkTargetNode)
		{
			CCShake* pkShake = CCShake::create(0.2,8.0f);
			m_pkTargetNode->runAction(pkShake);
		}

		bFirst2 = false;
	}

	NDUIImage::draw();
}

void NDShakeSprite::CallbackFunction()
{
	int a = 10;
}

NS_NDENGINE_END