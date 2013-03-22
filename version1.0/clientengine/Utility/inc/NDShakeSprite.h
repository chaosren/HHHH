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

protected:
private:
};

NS_NDENGINE_END

#endif