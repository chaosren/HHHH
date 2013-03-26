#include "NDShakeSprite.h"
#include "CCShake.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDShakeSprite,NDUIImage)

NDShakeSprite::NDShakeSprite()
{
	m_pkTargetNode = 0;
}

NDShakeSprite::~NDShakeSprite()
{

}

void NDShakeSprite::draw()
{
	static bool bFirst = true;

	if (bFirst)
	{
		memset(&m_kLastUpdateTimeVal,0,sizeof(cc_timeval));
		CCTime kTime;
		kTime.gettimeofdayCocos2d(&m_kLastUpdateTimeVal,0);
		CCMoveTo* pkMoveTo = CCMoveTo::create(0.50f,m_kFirstPosition);
		CCCallFunc* pkFunc = CCCallFunc::actionWithTarget(m_pkCCNode,callfunc_selector(NDShakeSprite::CallbackFunction));
		m_pkCCNode->runAction(CCSequence::actions(pkMoveTo,pkFunc,0));
		bFirst = false;
	}

	double dbTimeDelta = 0.0;
	CCTime kTime;
	cc_timeval kCurrentTime = {0};
	kTime.gettimeofdayCocos2d(&kCurrentTime,0);
	dbTimeDelta = kTime.timersubCocos2d(&m_kLastUpdateTimeVal,&kCurrentTime);

	static bool bFirst2 = true;

	if (dbTimeDelta / 1000.0f >= 0.50f && bFirst2)
	{
		if (m_pkTargetNode)
		{
			CCShake* pkShake = CCShake::create(0.25,10.0f);
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