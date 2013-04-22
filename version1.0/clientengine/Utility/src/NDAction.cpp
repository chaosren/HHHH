#include "NDAction.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDAction,NDObject)

NDAction::NDAction()
{
	m_pkCCAction = 0;
}

NDAction::~NDAction()
{
	m_pkCCAction = 0;
}

bool NDAction::IsDone()
{
	return m_pkCCAction->isDone();
}

void NDAction::Stop()
{
	m_pkCCAction->stop();
}

void NDAction::Step( float fDeltaTime )
{
	m_pkCCAction->step(fDeltaTime);
}

void NDAction::StartWithTarget(NDNode* pkTarget)
{
	m_pkCCAction->startWithTarget(pkTarget->getCCNode());
}

const char* NDAction::Description()
{
	return m_pkCCAction->description();
}

NS_NDENGINE_END