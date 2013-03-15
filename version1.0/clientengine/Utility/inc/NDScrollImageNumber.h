/*
*
*/

#ifndef NDSCROLLIMAGENUMBER_H
#define NDSCROLLIMAGENUMBER_H

#include "define.h"
#include "NDObject.h"
#include "ImageNumber.h"

NS_NDENGINE_BGN

class NDScrollImageNumber:
	public NDObject,
	public ImageNumber
{
	DECLARE_CLASS(NDScrollImageNumber)

public:

	NDScrollImageNumber();
	virtual ~NDScrollImageNumber();

protected:
private:
};

NS_NDENGINE_END

#endif