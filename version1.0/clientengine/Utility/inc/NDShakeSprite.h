/*
*
*/

#ifndef NDSHAKESPRITE_H
#define NDSHAKESPRITE_H

#include "define.h"
#include "NDSprite.h"

NS_NDENGINE_BGN

class NDShakeSprite:public NDSprite
{
	DECLARE_CLASS(NDShakeSprite)

public:

	NDShakeSprite();
	virtual ~NDShakeSprite();

	virtual void draw();

protected:
private:
};

NS_NDENGINE_END

#endif