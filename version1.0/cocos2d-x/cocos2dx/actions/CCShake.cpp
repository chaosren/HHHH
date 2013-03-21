#include "CCShake.h"
#include "cocos2d.h"

NS_CC_BEGIN

// CCShake::CCShake():m_fStrengthX(0), m_StrengthY(0), m_fInitialX(0), m_fInitialY(0)
// {
// }
// 
// CCShake::~CCShake()
// {
// 
// }

CCShake::CCShake()
{

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
	return rnd*(max-min)+min;
}

void CCShake::update(float dt)
{
	float randx = fgRangeRand( -m_fStrengthX, m_fStrengthX )*dt;
	float randy = fgRangeRand( -m_StrengthY, m_StrengthY )*dt;

	m_pTarget->setPosition( ccpAdd(ccp(m_fInitialX, m_fInitialY),ccp( randx, randy)));
}

void CCShake::startWithTarget(CCNode *pTarget)
{
	CCActionInterval::startWithTarget( pTarget );

	// save the initial position
	m_fInitialX = pTarget->getPosition().x;
	m_fInitialY = pTarget->getPosition().y;
}

void CCShake::stop(void)
{
	// Action is done, reset clip position
	this->getTarget()->setPosition( ccp( m_fInitialX, m_fInitialY ) );

	CCActionInterval::stop();
}

NS_CC_END