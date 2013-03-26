/*
*
*/

#ifndef NDSHAKESPRITE_H
#define NDSHAKESPRITE_H

#include "define.h"
#include "NDUIImage.h"

NS_NDENGINE_BGN

class NDShakeSprite:public NDUIImage
{
	DECLARE_CLASS(NDShakeSprite)

public:

	NDShakeSprite();
	virtual ~NDShakeSprite();

	virtual void draw();
	virtual void CallbackFunction();

protected:

	CC_SYNTHESIZE(CCNode*,m_pkTargetNode,ShakeNode);
	CC_SYNTHESIZE(CCPoint,m_kFirstPosition,FirstPosition);
	CC_SYNTHESIZE_READONLY(cc_timeval,m_kLastUpdateTimeVal,LastUpdateTime);

private:
};

NS_NDENGINE_END

#endif