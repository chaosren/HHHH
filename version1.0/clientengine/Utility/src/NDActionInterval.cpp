#include "NDActionInterval.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDActionInterval,NDObject)

NDActionInterval::NDActionInterval()
{
	m_pkCCActionInterval = 0;
}

NDActionInterval::~NDActionInterval()
{
	m_pkCCActionInterval = 0;
}

bool NDActionInterval::IsDone()
{
	return m_pkCCActionInterval->isDone();
}

void NDActionInterval::Stop()
{
	m_pkCCActionInterval->stop();
}

bool NDActionInterval::DestroyAction( NDActionInterval* pkDestroy )
{
	if (0 == pkDestroy)
	{
		return false;
	}

	SAFE_DELETE(pkDestroy);

	return true;
}

IMPLEMENT_CLASS(NDSequence,NDActionInterval)

NDSequence::NDSequence()
{

}

NDSequence::~NDSequence()
{

}

bool NDSequence::InitWithTwoActions( NDFiniteTimeAction *pActionOne,
									NDFiniteTimeAction *pActionTwo)
{
	return m_pkCCSquence->initWithTwoActions(pActionOne->getCCFiniteTimeAction(),
		pActionTwo->getCCFiniteTimeAction());
}

bool NDSequence::IsDone()
{
	return m_pkCCSquence->isDone();
}

void NDSequence::Stop()
{
	m_pkCCSquence->stop();
}

IMPLEMENT_CLASS(NDRepeat,NDActionInterval)

NDRepeat::NDRepeat()
{
	
}

NDRepeat::~NDRepeat()
{

}

IMPLEMENT_CLASS(NDRotateTo,NDActionInterval)

NDRotateTo::NDRotateTo()
{
	m_pkCCRotateTo = 0;
}

NDRotateTo::~NDRotateTo()
{
	m_pkCCRotateTo = 0;
}

void NDRotateTo::StartWithTarget( NDNode* pTarget )
{
	m_pkCCRotateTo->startWithTarget(pTarget->getCCNode());
}

NDRotateTo* NDRotateTo::CreateRotateToAction( float duration, float fDeltaAngle )
{
	CCRotateTo* pkCCRotate = CCRotateTo::create(duration,fDeltaAngle);
	NDRotateTo* pkRotate = new NDRotateTo;
	pkRotate->setCCRotateTo(pkCCRotate);

	return pkRotate;
}

bool NDRotateTo::IsDone()
{
	return m_pkCCRotateTo->isDone();
}

void NDRotateTo::Stop()
{
	m_pkCCRotateTo->stop();
}

IMPLEMENT_CLASS(NDRotateBy,NDActionInterval)

NDRotateBy::NDRotateBy()
{
	m_pkCCRotateBy = 0;
}

NDRotateBy::~NDRotateBy()
{
	m_pkCCRotateBy = 0;
}

void NDRotateBy::StartWithTarget( NDNode* pTarget )
{
	m_pkCCRotateBy->startWithTarget(pTarget->getCCNode());
}

NDRotateBy* NDRotateBy::CreateRotateBy( float duration, float fDeltaAngle )
{
	NDRotateBy* pkRotate = new NDRotateBy;
	CCRotateBy* pkCCRotateBy = CCRotateBy::create(duration,fDeltaAngle);

	pkRotate->setCCRotateBy(pkCCRotateBy);

	return pkRotate;
}

bool NDRotateBy::IsDone()
{
	return m_pkCCRotateBy->isDone();
}

void NDRotateBy::Stop()
{
	m_pkCCRotateBy->stop();
}

IMPLEMENT_CLASS(NDMoveTo,NDActionInterval)

NDMoveTo::NDMoveTo()
{
	m_pkCCMoveTo = 0;
}

NDMoveTo::~NDMoveTo()
{
	m_pkCCMoveTo = 0;
}

void NDMoveTo::StartWithTarget( NDNode* pTarget )
{
	m_pkCCMoveTo->startWithTarget(pTarget->getCCNode());
}

bool NDMoveTo::IsDone()
{
	return m_pkCCMoveTo->isDone();
}

void NDMoveTo::Stop()
{
	m_pkCCMoveTo->stop();
}

NDMoveTo* NDMoveTo::CreateMoveTo( float duration, float x,float y)
{
	NDMoveTo* pkMoveTo = new NDMoveTo;
	CCMoveTo* pkCCMoveTo = CCMoveTo::create(duration,CCPointMake(x,y));
	pkMoveTo->setCCMoveTo(pkCCMoveTo);

	return pkMoveTo;
}

IMPLEMENT_CLASS(NDMoveBy,NDActionInterval)

NDMoveBy::NDMoveBy()
{
	m_pkCCMoveBy = 0;
}

NDMoveBy::~NDMoveBy()
{
	m_pkCCMoveBy = 0;
}

NDMoveBy* NDMoveBy::CreateMoveBy( float duration, float x,float y )
{
	NDMoveBy* pkMoveBy = new NDMoveBy;
	CCMoveBy* pkCCMoveBy = CCMoveBy::create(duration,CCPointMake(x,y));

	pkMoveBy->setCCMoveBy(pkCCMoveBy);

	return pkMoveBy;
}

void NDMoveBy::StartWithTarget( NDNode* pTarget )
{
	m_pkCCMoveBy->startWithTarget(pTarget->getCCNode());
}

bool NDMoveBy::IsDone()
{
	return m_pkCCMoveBy->isDone();
}

void NDMoveBy::Stop()
{
	m_pkCCMoveBy->stop();
}

IMPLEMENT_CLASS(NDShake,NDActionInterval)

NDShake::NDShake()
{
	m_pkCCShake = 0;
}

NDShake::~NDShake()
{
	m_pkCCShake = 0;
}

NDShake* NDShake::CraeteShake(float d, float strength )
{
	NDShake* pkShake = new NDShake;
	CCShake* pkCCShake = CCShake::create(d,strength);

	pkShake->setCCShake(pkCCShake);

	return pkShake;
}

NDShake* NDShake::CraeteShakeWithStrength( float d, float strength_x, float strength_y )
{
	NDShake* pkShake = new NDShake;
	CCShake* pkCCShake = CCShake::createWithStrength(d,strength_x,strength_y);

	pkShake->setCCShake(pkCCShake);

	return pkShake;
}

void NDShake::StartWithTarget( NDNode* pTarget )
{
	m_pkCCShake->startWithTarget(pTarget->getCCNode());
}

bool NDShake::IsDone()
{
	return m_pkCCShake->isDone();
}

void NDShake::Stop()
{
	m_pkCCShake->stop();
}

NS_NDENGINE_END