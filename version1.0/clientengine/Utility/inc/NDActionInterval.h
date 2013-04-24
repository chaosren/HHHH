/*
*
*/

#ifndef NDACTIONINTERVAL_H
#define NDACTIONINTERVAL_H

#include "define.h"
#include "NDObject.h"
#include "CCActionInterval.h"
#include "NDAction.h"
#include "CCShake.h"

NS_NDENGINE_BGN

using namespace cocos2d;

class NDActionInterval:public NDObject
{
	DECLARE_CLASS(NDActionInterval);

public:

	NDActionInterval();
	virtual ~NDActionInterval();

	static bool DestroyAction(NDActionInterval* pkDestroy);

	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCActionInterval*,m_pkCCActionInterval,CCActionInterval);

private:
};

class NDSequence:public NDActionInterval
{
	DECLARE_CLASS(NDSequence)

public:

	NDSequence();
	virtual ~NDSequence();

	bool InitWithTwoActions(NDFiniteTimeAction *pActionOne, NDFiniteTimeAction *pActionTwo);
	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCSequence*,m_pkCCSquence,CCSquence);

private:
};

class NDRepeat:public NDActionInterval
{
	DECLARE_CLASS(NDRepeat)

public:

	NDRepeat();
	virtual ~NDRepeat();

protected:
private:
};

class NDRotateTo:public NDActionInterval
{
	DECLARE_CLASS(NDRotateTo)

public:

	NDRotateTo();
	virtual ~NDRotateTo();

	static NDRotateTo* CreateRotateToAction(float duration, float fDeltaAngle);

	virtual void StartWithTarget(NDNode* pTarget);
	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCRotateTo*,m_pkCCRotateTo,CCRotateTo);

private:
};

class NDRotateBy:public NDActionInterval
{
	DECLARE_CLASS(NDRotateBy)

public:

	NDRotateBy();
	virtual ~NDRotateBy();

	static NDRotateBy* CreateRotateBy(float duration, float fDeltaAngle);

	virtual void StartWithTarget(NDNode* pTarget);

	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCRotateBy*,m_pkCCRotateBy,CCRotateBy);

private:
};

class NDMoveTo:public NDActionInterval
{
	DECLARE_CLASS(NDMoveTo)

public:

	NDMoveTo();
	virtual ~NDMoveTo();

	static NDMoveTo* CreateMoveTo(float duration, float x,float y);

	virtual void StartWithTarget(NDNode* pTarget);

	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCMoveTo*,m_pkCCMoveTo,CCMoveTo);

private:
};

class NDMoveBy:public NDActionInterval
{
	DECLARE_CLASS(NDMoveBy);

public:

	NDMoveBy();
	virtual ~NDMoveBy();

	static NDMoveBy* CreateMoveBy(float duration, float x,float y);

	virtual void StartWithTarget(NDNode* pTarget);

	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCMoveBy*,m_pkCCMoveBy,CCMoveBy);

private:
};

class NDShake:public NDActionInterval
{
	DECLARE_CLASS(NDShake)

public:

	NDShake();
	virtual ~NDShake();

	static NDShake* CraeteShake(float d, float strength);
	static NDShake* CraeteShakeWithStrength(float d, float strength_x, float strength_y);

	virtual void StartWithTarget(NDNode* pTarget);

	virtual bool IsDone();
	virtual void Stop();

protected:

	CC_SYNTHESIZE(CCShake*,m_pkCCShake,CCShake);

private:
};

NS_NDENGINE_END

#endif