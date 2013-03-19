/*
*
*/

#ifndef NDSCROLLIMAGENUMBER_H
#define NDSCROLLIMAGENUMBER_H

#include "define.h"
#include "NDObject.h"
#include "ImageNumber.h"

NS_NDENGINE_BGN

using namespace std;

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

	virtual void draw();

	bool SetScrollNumber(int uiNumber,float fSecond,FontType eType,bool bWithSign = false);

protected:

	CC_SYNTHESIZE(float,m_fScrollTime,ScrollTime);
	CC_SYNTHESIZE(int,m_nScrollNumber,ScrollNumber);			///< 每一位（个位百位千位）从0到9的时间 @郭浩

	CC_SYNTHESIZE_READONLY(vector<unsigned int>,m_kBits,Bits);

	FontType m_eFontType;

private:
};

NS_NDENGINE_END

#endif