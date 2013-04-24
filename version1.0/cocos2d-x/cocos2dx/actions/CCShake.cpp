#include "CCShake.h"
#include "cocos2d.h"

NS_CC_BEGIN

CCShake::CCShake()
{
	m_fInitialX = 0.0f;
	m_fInitialY = 0.0f;
	m_fStrengthX = 0.0f;
	m_StrengthY = 0.0f;
}

CCShake::~CCShake()
{

}

CCShake* CCShake::create( float d, float strength )
{
	return createWithStrength( d, strength, strength );
}

CCShake* CCShake::createWithStrength(float duration, float strength_x, float strength_y)
{
	CCShake *pRet = new CCShake();

	if (pRet && pRet->initWithDuration(duration, strength_x, strength_y))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}

	return pRet;
}

bool CCShake::initWithDuration(float duration, float strength_x, float strength_y)
{
	if (CCActionInterval::initWithDuration(duration))
	{
		m_fStrengthX = strength_x;
		m_StrengthY = strength_y;
		return true;
	}

	return false;
}

static float fgRangeRand( float min, float max )
{
	float rnd = ((float)rand()/(float)RAND_MAX);
	return rnd * (max - min) + min;
}

void CCShake::update(float fDeltaTime)
{
	float fRandX = fgRangeRand( -m_fStrengthX, m_fStrengthX ) * fDeltaTime;
	float fRandY = fgRangeRand( -m_StrengthY, m_StrengthY ) * fDeltaTime;

	m_pTarget->setPosition( ccpAdd(ccp(m_fInitialX, m_fInitialY),ccp( fRandX, fRandY)));
}

void CCShake::startWithTarget(CCNode *pTarget)
{
	CCActionInterval::startWithTarget( pTarget );

	m_fInitialX = pTarget->getPosition().x;
	m_fInitialY = pTarget->getPosition().y;
}

void CCShake::stop(void)
{
	getTarget()->setPosition( ccp( m_fInitialX, m_fInitialY ) );

	CCActionInterval::stop();
}

NS_CC_END