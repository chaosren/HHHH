/*
*
*/

#ifndef NDACTIONINTERVAL_H
#define NDACTIONINTERVAL_H

#include "define.h"
#include "NDObject.h"
#include "CCActionInterval.h"

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

	CCActionInterval* m_pkActionInterval;

private:
};

class NDSequence:public NDActionInterval
{
	DECLARE_CLASS(NDSequence)

public:

	NDSequence();
	virtual ~NDSequence();

	bool InitWithTwoActions(CCFiniteTimeAction *pActionOne, CCFiniteTimeAction *pActionTwo);

protected:
private:
};

NS_NDENGINE_END

#endif