/*
*
*/

#ifndef NDACTIONINTERVAL_H
#define NDACTIONINTERVAL_H

#include "define.h"
#include "NDObject.h"
#include "CCActionInterval.h"
#include "NDAction.h"

NS_NDENGINE_BGN

using namespace cocos2d;

class NDActionInterval:public NDObject
{
	DECLARE_CLASS(NDActionInterval);

public:

	NDActionInterval();
	virtual ~NDActionInterval();

	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCActionInterval*,m_pkCCActionInterval,CCActionInterval);

private:
};

class NDSequence:public NDObject
{
	DECLARE_CLASS(NDSequence)

public:

	NDSequence();
	virtual ~NDSequence();

	bool InitWithTwoActions(NDFiniteTimeAction *pActionOne, NDFiniteTimeAction *pActionTwo);

protected:

	CC_SYNTHESIZE(CCSequence*,m_pkCCSquence,CCSquence);

private:
};

class NDRepeat:public NDObject
{
	DECLARE_CLASS(NDRepeat)

public:

	NDRepeat();
	virtual ~NDRepeat();

protected:
private:
};

class NDRotateTo:public NDObject
{
	DECLARE_CLASS(NDRotateTo)

public:

	NDRotateTo();
	virtual ~NDRotateTo();

	virtual void StartWithTarget(NDNode* pTarget);

protected:

	CC_SYNTHESIZE(CCRotateTo*,m_pkCCRotateTo,CCRotateTo);

private:
};

NS_NDENGINE_END

#endif