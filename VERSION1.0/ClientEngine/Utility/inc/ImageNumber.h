/**
 *
 */
#ifndef IMAGENUMBER_H
#define IMAGENUMBER_H

#include "platform.h"
#include "NDUIImage.h"
#include "NDPicture.h"
#include "NDUILayer.h"
#include <vector>

using namespace NDEngine;

class PictureNumber
{
	PictureNumber();
	~PictureNumber();
public:
	static PictureNumber* SharedInstance();
	//uiNumber must between 0 and 9
	NDPicture* TitleGoldNumber(unsigned int uiNumber);
	CCSize GetTitleGoldNumberSize();

	NDPicture* TitleRedNumber(unsigned int uiNumber);
	CCSize GetTitleRedNumberSize();

	NDPicture* TitleSplit();
	CCSize GetTitleSplitSize();

	// 0 ~ 9 / + -
	NDPicture* BigRed(unsigned int index);
	NDPicture* BigGreen(unsigned int index);
	NDPicture* SmallWhite(unsigned int index);
	NDPicture* SmallRed(unsigned int index);
	NDPicture* SmallGreen(unsigned int index);
	NDPicture* SmallGold(unsigned int index);

	CCSize GetBigRedSize();
	CCSize GetSmallWhiteSize();
	CCSize GetSmallRedSize();
	CCSize GetSmallGoldSize();

private:
	NDPicture* m_picTitleGlod[10];
	NDPicture* m_picTitleRed[10];
	NDPicture* m_picSmallGold[10];
	NDPicture* m_picTitleSplit;
	// 0 ~ 9 / + -
	NDPicture* m_picBigRed[13];
	// 0 ~ 9 / + -
	NDPicture* m_picBigGreen[13];
	// 0 ~ 9 / + -
	NDPicture* m_picSmallWhite[13];
	NDPicture* m_picSmallRed[13];
	NDPicture* m_picSmallGreen[13];
};

class ImageNumber: public NDUILayer
{
	DECLARE_CLASS (ImageNumber)
	ImageNumber();
	virtual ~ImageNumber();
public:
	void SetTitleRedNumber(unsigned int uiNumber, unsigned int interval = 0);
	void SetTitleRedTwoNumber(unsigned int uiNumber_1, unsigned int uiNumber_2,
			unsigned int interval = 0);

	void SetBigRedNumber(int uiNumber, bool bWithSign = false);
	void SetBigRedTwoNumber(int uiNumber_1, int uiNumber_2);

	void SetBigGreenNumber(int uiNumber, bool bWithSign = false);
	void SetSmallGreenNumber(int uiNumber, bool bWithSign = false);
	void SetSmallWhiteNumber(int uiNumber, bool bWithSign = false);
	void SetSmallRedNumber(int uiNumber, bool bWithSign = false);
	void SetSmallRedTwoNumber(unsigned int uiNumber_1, unsigned int uiNumber_2);
	void SetSmallGoldNumber(int num);

	void Initialization();
	CCSize GetNumberSize();

	void NumberBits(unsigned int uiNumber, /*out*/
		std::vector<unsigned int>& kBits);
	unsigned int exp(unsigned int uiValue, unsigned int uiNumber);
	unsigned int SetTitleRedNumber(bool bCleanUp, unsigned int uiNumber,
		unsigned int uiInterval, unsigned int uiStartPosition);

	CCSize m_kSize;

private:
};

#endif