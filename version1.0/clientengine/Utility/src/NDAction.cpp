#include "NDAction.h"
#include <assert.h>

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDAction,NDObject)

NDAction::NDAction()
{
	m_pkCCAction = 0;
	m_pkTargetNode = 0;
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

void NDAction::SetTarget( NDNode* pkTarget )
{
	assert(pkTarget);
	m_pkCCAction->setTarget(pkTarget->getCCNode());
}

NDNode* NDAction::GetTarget()
{
	return m_pkTargetNode;
}

void NDAction::SetTag( int nTag )
{
	m_pkCCAction->setTag(nTag);
}

int NDAction::GetTag()
{
	return m_pkCCAction->getTag();
}

IMPLEMENT_CLASS(NDFiniteTimeAction,NDAction)

NDFiniteTimeAction::NDFiniteTimeAction()
{

}

NDFiniteTimeAction::~NDFiniteTimeAction()
{

}

NS_NDENGINE_END