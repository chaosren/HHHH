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

	typedef enum __tagFontType
	{
		Font_SmallRed,
		Font_MaxCount
	}FontType;

	NDScrollImageNumber();
	virtual ~NDScrollImageNumber();

	bool SetScrollNumber(int uiNumber,FontType eType,bool bWithSign = false);

protected:

	FontType m_eFontType;

private:
};

NS_NDENGINE_END

#endif