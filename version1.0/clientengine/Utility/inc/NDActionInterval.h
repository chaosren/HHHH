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

NS_NDENGINE_END

#endif