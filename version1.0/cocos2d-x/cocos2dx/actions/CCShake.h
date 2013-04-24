//
//  NDClassFactory.h
//  NDClassFactory
//
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//	
//	@author 郭浩
//
//	－－介绍－－
//	動作特效，抖動效果

#ifndef CCSHAKE_H
#define CCSHAKE_H

#include "CCActionInterval.h"

NS_CC_BEGIN

class CC_DLL CCShake : public CCActionInterval
{
public:

	CCShake();
	virtual ~CCShake();
	static CCShake* create(float d, float strength );
	static CCShake* createWithStrength(float d, float strength_x, float strength_y );

	bool initWithDuration(float d, float strength_x, float strength_y );
	void startWithTarget(CCNode *pTarget);
	void stop(void);

protected:

	void update(float fDeltaTime);

	float m_fInitialX;
	float m_fInitialY;
	float m_fStrengthX;
	float m_StrengthY;
};
NS_CC_END

#endif