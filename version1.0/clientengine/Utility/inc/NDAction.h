/*
*
*/

#ifndef NDACTION_H
#define NDACTION_H

#include "base_nodes/CCNode.h"
#include "CCAction.h"
#include "CCProtocols.h"
#include "sprite_nodes/CCSpriteFrame.h"
#include "sprite_nodes/CCAnimation.h"
#include <vector>
#include "NDObject.h"
#include "NDNode.h"

NS_NDENGINE_BGN

class NDAction:public NDObject
{
	DECLARE_CLASS(NDAction)

public:

	NDAction();
	virtual ~NDAction();

	virtual const char* Description();
	virtual bool IsDone();
	virtual void Stop();
	virtual void Step(float fDeltaTime);
	virtual void StartWithTarget(NDNode* pkTarget);

	void SetTarget(NDNode* pkTarget);
	NDNode* GetTarget();

	void SetTag(int nTag);
	int GetTag();

protected:

	CC_PROPERTY(CCAction*,m_pkCCAction,CCAction);
	
	NDNode* m_pkTargetNode;

private:
};

class NDFiniteTimeAction:public NDAction
{
	DECLARE_CLASS(NDFiniteTimeAction)

public:

	NDFiniteTimeAction();
	virtual ~NDFiniteTimeAction();

protected:

	CC_PROPERTY(CCFiniteTimeAction*,m_pkCCFiniteTimeAction,CCFiniteTimeAction);

private:
};

NS_NDENGINE_END

#endif