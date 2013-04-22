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

IMPLEMENT_CLASS(NDSequence,NDObject)

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

IMPLEMENT_CLASS(NDRepeat,NDObject)

NDRepeat::NDRepeat()
{
	
}

NDRepeat::~NDRepeat()
{

}

IMPLEMENT_CLASS(NDRotateTo,NDObject)

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

NS_NDENGINE_END