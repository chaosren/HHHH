#include "ImageNumber.h"
#include "NDUtil.h"
#include "NDPath.h"
#include "define.h"
#include "NDSharedPtr.h"
#include "ObjectTracker.h"

#define title_image (NDPath::GetImgPath("titles.png"))
//#define title_image ([[NSString stringWithFormat:@"%s", NDPath::GetImgPath("titles.png")] UTF8String])

//小号红色数字图形文件，数字的宽，高
#define SMALL_RED_NUMBER_FIGURE_IMAG		"Res00/Number/SmallRedFigure.png"
#define SMALL_RED_NUMBER_FIGURE_SIZE_W		32
#define SMALL_RED_NUMBER_FIGURE_SIZE_H		38
//小号绿色数字图形文件，数字的宽，高
#define SMALL_GREEN_NUMBER_FIGURE_IMAG		"Res00/Number/SmallGreenFigure.png"
#define SMALL_GREEN_NUMBER_FIGURE_SIZE_W	32
#define SMALL_GREEN_NUMBER_FIGURE_SIZE_H	38

//大号红色数字图形文件，数字的宽，高
#define BIG_RED_NUMBER_FIGURE_IMAG			"Res00/Number/BigRedFigure.png"
#define BIG_RED_NUMBER_FIGURE_SIZE_W		64
#define BIG_RED_NUMBER_FIGURE_SIZE_H		76
//大号绿色数字图形文件，数字的宽，高
#define BIG_GREEN_NUMBER_FIGURE_IMAG		"Res00/Number/BigGreenFigure.png"
#define BIG_GREEN_NUMBER_FIGURE_SIZE_W		64
#define BIG_GREEN_NUMBER_FIGURE_SIZE_H		76

static PictureNumber* PictureNumber_SharedInstance = NULL;

PictureNumber::PictureNumber()
{
	NDAsssert(PictureNumber_SharedInstance == NULL);

	for (unsigned int i = 0;
		i < sizeof(m_picTitleGlod) / sizeof(m_picTitleGlod[0]); i++)
	{
		m_picTitleGlod[i] = NULL;
	}
	for (unsigned int i = 0;
		i < sizeof(m_picTitleRed) / sizeof(m_picTitleRed[0]); i++)
	{
		m_picTitleRed[i] = NULL;
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallGold) / sizeof(m_picSmallGold[0]); i++)
	{
		m_picSmallGold[i] = NULL;
	}
	for (unsigned int i = 0; i < sizeof(m_picBigRed) / sizeof(m_picBigRed[0]);
		i++)
	{
		m_picBigRed[i] = NULL;
	}
	for (unsigned int i = 0;
		i < sizeof(m_picBigGreen) / sizeof(m_picBigGreen[0]); i++)
	{
		m_picBigGreen[i] = NULL;
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallWhite) / sizeof(m_picSmallWhite[0]); i++)
	{
		m_picSmallWhite[i] = NULL;
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallRed) / sizeof(m_picSmallRed[0]); i++)
	{
		m_picSmallRed[i] = NULL;
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallGreen) / sizeof(m_picSmallGreen[0]); i++)
	{
		m_picSmallGreen[i] = NULL;
	}
	m_picTitleSplit = NULL;
}

PictureNumber::~PictureNumber()
{
	PictureNumber_SharedInstance = NULL;

	for (unsigned int i = 0;
		i < sizeof(m_picTitleGlod) / sizeof(m_picTitleGlod[0]); i++)
	{
		delete m_picTitleGlod[i];
	}
	for (unsigned int i = 0;
		i < sizeof(m_picTitleRed) / sizeof(m_picTitleRed[0]); i++)
	{
		delete m_picTitleRed[i];
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallGold) / sizeof(m_picSmallGold[0]); i++)
	{
		delete m_picSmallGold[i];
	}
	for (unsigned int i = 0; i < sizeof(m_picBigRed) / sizeof(m_picBigRed[0]);
		i++)
	{
		delete m_picBigRed[i];
	}
	for (unsigned int i = 0;
		i < sizeof(m_picBigGreen) / sizeof(m_picBigGreen[0]); i++)
	{
		delete m_picBigGreen[i];
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallWhite) / sizeof(m_picSmallWhite[0]); i++)
	{
		delete m_picSmallWhite[i];
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallRed) / sizeof(m_picSmallRed[0]); i++)
	{
		delete m_picSmallRed[i];
	}
	for (unsigned int i = 0;
		i < sizeof(m_picSmallGreen) / sizeof(m_picSmallGreen[0]); i++)
	{
		delete m_picSmallGreen[i];
	}
	delete m_picTitleSplit;
}

PictureNumber* PictureNumber::SharedInstance()
{
	if (PictureNumber_SharedInstance == NULL)
	{
		PictureNumber_SharedInstance = new PictureNumber();
	}
	return PictureNumber_SharedInstance;
}

NDPicture* PictureNumber::TitleGoldNumber(unsigned int uiNumber)
{
	if (uiNumber >= sizeof(m_picTitleGlod) / sizeof(m_picTitleGlod[0]))
	{
		return NULL;
	}

	if (!m_picTitleGlod[uiNumber])
	{
		m_picTitleGlod[uiNumber] = NDPicturePool::DefaultPool()->AddPicture(
			title_image);
		int nIDx = uiNumber - 1;

		if (nIDx == -1)
		{
			nIDx = 9;
		}

		m_picTitleGlod[uiNumber]->Cut(CCRectMake(120 + nIDx * 20,
			24,GetTitleGoldNumberSize().width, GetTitleGoldNumberSize().height));
	}
	return m_picTitleGlod[uiNumber];
}

NDPicture* PictureNumber::TitleRedNumber(unsigned int uiNumber)
{
	if (uiNumber >= sizeof(m_picTitleRed) / sizeof(m_picTitleRed[0]))
	{
		return NULL;
	}

	if (!m_picTitleRed[uiNumber])
	{
		m_picTitleRed[uiNumber] = NDPicturePool::DefaultPool()->AddPicture(
			title_image);
		m_picTitleRed[uiNumber]->Cut(CCRectMake(80 + uiNumber * 20,
			48,GetTitleRedNumberSize().width, GetTitleRedNumberSize().height));
	}
	return m_picTitleRed[uiNumber];
}

NDPicture* PictureNumber::TitleSplit()
{
	if (!m_picTitleSplit)
	{
		m_picTitleSplit = NDPicturePool::DefaultPool()->AddPicture(title_image);
		m_picTitleSplit->Cut(CCRectMake(60, 48,
			GetTitleSplitSize().width, GetTitleSplitSize().height));
	}
	return m_picTitleSplit;
}

CCSize PictureNumber::GetTitleGoldNumberSize()
{
	return CCSizeMake(16, 16);
}

CCSize PictureNumber::GetTitleRedNumberSize()
{
	return CCSizeMake(9, 12);
}

CCSize PictureNumber::GetTitleSplitSize()
{
	return CCSizeMake(11, 11);
}

NDPicture* PictureNumber::SmallRed(unsigned int index)
{
	if (index > 12)
	{
		return NULL;
	}

	if (!m_picSmallRed[index])
	{
		m_picSmallRed[index] = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPath(SMALL_RED_NUMBER_FIGURE_IMAG));
		m_picSmallRed[index]->Cut(
			CCRectMake(GetSmallRedSize().width * index, 0,
			GetSmallRedSize().width, GetSmallRedSize().height));
	}

	return m_picSmallRed[index];
}

NDPicture* PictureNumber::SmallGreen(unsigned int index)
{
	if (index > 12)
	{
		return NULL;
	}

	if (!m_picSmallGreen[index])
	{
		m_picSmallGreen[index] = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPath(SMALL_GREEN_NUMBER_FIGURE_IMAG));
		m_picSmallGreen[index]->Cut(
			CCRectMake(GetSmallRedSize().width * index, 0,
			GetSmallRedSize().width, GetSmallRedSize().height));
	}

	return m_picSmallGreen[index];
}

NDPicture* PictureNumber::SmallWhite(unsigned int index)
{
	if (index > 12)
	{
		return NULL;
	}

	if (!m_picSmallWhite[index])
	{
		m_picSmallWhite[index] = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPath("uiNumber_1.png"));
		m_picSmallWhite[index]->Cut(
			CCRectMake(GetSmallWhiteSize().width * index, 0,
			GetSmallWhiteSize().width, GetSmallWhiteSize().height));
	}

	return m_picSmallWhite[index];
}

NDPicture* PictureNumber::BigGreen(unsigned int index)
{
	if (index > 12)
	{
		return NULL;
	}

	if (!m_picBigGreen[index])
	{
		m_picBigGreen[index] = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPath(BIG_GREEN_NUMBER_FIGURE_IMAG));
		m_picBigGreen[index]->Cut(
			CCRectMake(GetBigRedSize().width * index, 0,
			GetBigRedSize().width, GetBigRedSize().height));
	}

	return m_picBigGreen[index];
}

NDPicture* PictureNumber::SmallGold(unsigned int index)
{
	if (index > 9)
	{
		return NULL;
	}

	if (!m_picSmallGold[index])
	{
		m_picSmallGold[index] = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI(BIG_RED_NUMBER_FIGURE_IMAG));
		m_picSmallGold[index]->Cut(
			CCRectMake(GetSmallGoldSize().width * index, 0,
			GetSmallGoldSize().width, GetSmallGoldSize().height));
	}

	return m_picSmallGold[index];
}

NDPicture* PictureNumber::BigRed(unsigned int index)
{
	if (index > 12)
	{
		return NULL;
	}

	if (!m_picBigRed[index])
	{
		m_picBigRed[index] = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPath(BIG_RED_NUMBER_FIGURE_IMAG));
		m_picBigRed[index]->Cut(
			CCRectMake(GetBigRedSize().width * index, 0,
			GetBigRedSize().width, GetBigRedSize().height));
	}

	return m_picBigRed[index];
}

CCSize PictureNumber::GetSmallWhiteSize()
{
	return CCSizeMake(6.0f, 9.0f);
}

CCSize PictureNumber::GetSmallRedSize()
{
	return CCSizeMake(SMALL_RED_NUMBER_FIGURE_SIZE_W,
		SMALL_RED_NUMBER_FIGURE_SIZE_H);
}

CCSize PictureNumber::GetBigRedSize()
{
	return CCSizeMake(BIG_RED_NUMBER_FIGURE_SIZE_W,
		BIG_RED_NUMBER_FIGURE_SIZE_H);
}

CCSize PictureNumber::GetSmallGoldSize()
{
	return CCSizeMake(6.0f, 5.0f);
}

//////////////////////
IMPLEMENT_CLASS(ImageNumber, NDUILayer)

ImageNumber::ImageNumber()
{
	INC_NDOBJ_RTCLS
}

ImageNumber::~ImageNumber()
{
	DEC_NDOBJ_RTCLS
}

void ImageNumber::Initialization()
{
	NDUILayer::Initialization();
	SetFrameRect(CCRectZero);
	SetTouchEnabled(false);
}

CCSize ImageNumber::GetNumberSize()
{
	return m_kSize;
}

unsigned int ImageNumber::SetTitleRedNumber(bool bCleanUp, unsigned int uiNumber,
											unsigned int uiInterval, unsigned int uiStartPosition)
{
	if (bCleanUp)
	{
		RemoveAllChildren(true);
	}

	std::vector<unsigned int> kBits;
	NumberBits(uiNumber, kBits);

	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->TitleRedNumber(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				uiStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetTitleRedNumberSize().width
				+ uiInterval, 0, pkPicture->GetSize().width,
				pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	return (kBits.size()
		* (PictureNumber::SharedInstance()->GetTitleRedNumberSize().width
		+ uiInterval));
}

void ImageNumber::SetTitleRedNumber(unsigned int uiNumber, unsigned int uiInterval)
{
	m_kSize.width = SetTitleRedNumber(true, uiNumber, uiInterval, 0);
	m_kSize.height =
		PictureNumber::SharedInstance()->GetTitleRedNumberSize().height;
}

void ImageNumber::SetTitleRedTwoNumber(unsigned int uiNumber_1,
									   unsigned int uiNumber_2, unsigned int uiInterval)
{
	unsigned int uiLength = SetTitleRedNumber(true, uiNumber_1, uiInterval, 0);

	NDPicture* pkPicture = PictureNumber::SharedInstance()->TitleSplit();
	if (pkPicture)
	{
		NDUIImage* pkImage = new NDUIImage();
		pkImage->Initialization();
		pkImage->SetPicture(pkPicture);
		pkImage->SetFrameRect(
			CCRectMake(uiLength, 0, pkPicture->GetSize().width,
			pkPicture->GetSize().height));
		AddChild(pkImage);

		uiLength += uiInterval + pkPicture->GetSize().width;
	}

	m_kSize.width = uiLength + SetTitleRedNumber(false, uiNumber_2, uiInterval, uiLength);
	m_kSize.height =
		PictureNumber::SharedInstance()->GetTitleRedNumberSize().height;
}

unsigned int ImageNumber::exp(unsigned int value, unsigned int n)
{
	unsigned int uiResult = 1;
	for (unsigned int i = 0; i < n; i++)
	{
		uiResult *= value;
	}
	return uiResult;
}

void ImageNumber::NumberBits(unsigned int uiNumber,
							 std::vector<unsigned int>& kBits)
{
	kBits.clear();
	CCStringRef kStringNumber = CCString::stringWithFormat("%u", uiNumber);
	unsigned int uiLength = kStringNumber->m_sString.length();

	if (uiNumber == 0)
	{
		kBits.push_back(0);
	}
	else
	{
		for (int i = uiLength; i > 0; i--)
		{
			unsigned int v = (uiNumber / exp(10, i - 1)) % 10;
			kBits.push_back(v);
		}
	}
}

void ImageNumber::SetSmallRedNumber(int uiNumber, bool bWithSign)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	if (bWithSign) // 显示符号
	{
		int nPicIndex = 11;
		if (uiNumber > 0)
		{
			nPicIndex = 11;
		}
		else
		{
			nPicIndex = 12;
		}

		NDPicture* pkPicSign = PictureNumber::SharedInstance()->SmallRed(
			nPicIndex);
		if (pkPicSign)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicSign);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPicSign->GetSize().width,
				pkPicSign->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPicSign->GetSize().width;
		}
	}

	uiNumber = abs(uiNumber);

	std::vector<unsigned int> kBits;
	NumberBits(uiNumber, kBits);

	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallRed(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetSmallRedSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	m_kSize.width = kBits.size()
		* PictureNumber::SharedInstance()->GetSmallRedSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetSmallRedSize().height;
}

void ImageNumber::SetSmallRedTwoNumber(unsigned int uiNumber_1, unsigned int uiNumber_2)
{
	bool bVisible = IsVisibled();

	RemoveAllChildren(true);

	int nStartPosition = 0;

	std::vector<unsigned int> kBits;
	// 数字1
	NumberBits(uiNumber_1, kBits);
	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallRed(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPicture->GetSize().width,
				pkPicture->GetSize().height));
			AddChild(pkImage);
			pkImage->SetVisible(bVisible);
			nStartPosition += pkPicture->GetSize().width;
		}
	}

	// 斜线
	NDPicture* pkPictureSlash = PictureNumber::SharedInstance()->SmallRed(10);
	if (pkPictureSlash)
	{
		NDUIImage* pkImage = new NDUIImage();
		pkImage->Initialization();
		pkImage->SetPicture(pkPictureSlash);
		pkImage->SetFrameRect(
			CCRectMake(nStartPosition, 0, pkPictureSlash->GetSize().width,
			pkPictureSlash->GetSize().height));
		AddChild(pkImage);
		pkImage->SetVisible(bVisible);
		nStartPosition += pkPictureSlash->GetSize().width;
	}

	NumberBits(uiNumber_2, kBits);
	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int bit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallRed(bit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPicture->GetSize().width,
				pkPicture->GetSize().height));
			AddChild(pkImage);
			pkImage->SetVisible(bVisible);
			nStartPosition += pkPicture->GetSize().width;
		}
	}

	m_kSize.width = nStartPosition;
	m_kSize.height = PictureNumber::SharedInstance()->GetSmallRedSize().height;
}

void ImageNumber::SetSmallWhiteNumber(int uiNumber, bool bWithSign)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	if (bWithSign) // 显示符号
	{
		int nPicIndex = 11;
		if (uiNumber > 0)
		{
			nPicIndex = 11;
		}
		else
		{
			nPicIndex = 12;
		}

		NDPicture* pkPictureSign = PictureNumber::SharedInstance()->SmallWhite(
			nPicIndex);
		if (pkPictureSign)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPictureSign);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPictureSign->GetSize().width,
				pkPictureSign->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPictureSign->GetSize().width;
		}
	}

	uiNumber = abs(uiNumber);

	std::vector<unsigned int> kBits;
	NumberBits(uiNumber, kBits);

	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallWhite(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetSmallWhiteSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	m_kSize.width = kBits.size()
		* PictureNumber::SharedInstance()->GetSmallWhiteSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetSmallWhiteSize().height;
}

void ImageNumber::SetBigGreenNumber(int uiNumber, bool bWithSign)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	if (bWithSign) // 显示符号
	{
		int nPicIndex = 11;
		if (uiNumber > 0)
		{
			nPicIndex = 11;
		}
		else
		{
			nPicIndex = 12;
		}

		NDPicture* pkPicSign = PictureNumber::SharedInstance()->BigGreen(
			nPicIndex);
		if (pkPicSign)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicSign);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPicSign->GetSize().width,
				pkPicSign->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPicSign->GetSize().width;
		}
	}

	uiNumber = abs(uiNumber);

	std::vector<unsigned int> kBits;
	NumberBits(uiNumber, kBits);

	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->BigGreen(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetBigRedSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	m_kSize.width = nStartPosition
		+ kBits.size()
		* PictureNumber::SharedInstance()->GetBigRedSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetBigRedSize().height;
}

void ImageNumber::SetSmallGreenNumber(int uiNumber, bool bWithSign)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	if (bWithSign) // 显示符号
	{
		int nPicIndex = 11;
		if (uiNumber > 0)
		{
			nPicIndex = 11;
		}
		else
		{
			nPicIndex = 12;
		}

		NDPicture* pkPictureSign = PictureNumber::SharedInstance()->SmallGreen(
			nPicIndex);
		if (pkPictureSign)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPictureSign);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPictureSign->GetSize().width,
				pkPictureSign->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPictureSign->GetSize().width;
		}
	}

	uiNumber = abs(uiNumber);

	std::vector<unsigned int> kBits;
	NumberBits(uiNumber, kBits);

	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallGreen(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetSmallRedSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	m_kSize.width = nStartPosition
		+ kBits.size()
		* PictureNumber::SharedInstance()->GetSmallRedSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetSmallRedSize().height;
}

void ImageNumber::SetSmallGoldNumber(int num)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	num = abs(num);

	std::vector<unsigned int> bits;
	NumberBits(num, bits);

	for (unsigned int i = 0; i < bits.size(); i++)
	{
		unsigned int bit = bits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallGold(bit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetSmallGoldSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	m_kSize.width = nStartPosition
		+ bits.size()
		* PictureNumber::SharedInstance()->GetSmallGoldSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetSmallGoldSize().height;
}

void ImageNumber::SetBigRedNumber(int uiNumber, bool bWithSign)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	if (bWithSign) // 显示符号
	{
		int pkIndex = 11;
		if (uiNumber > 0)
		{
			pkIndex = 11;
		}
		else
		{
			pkIndex = 12;
		}

		NDPicture* pkPictureSign = PictureNumber::SharedInstance()->BigRed(pkIndex);
		if (pkPictureSign)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPictureSign);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPictureSign->GetSize().width,
				pkPictureSign->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPictureSign->GetSize().width;
		}
	}

	uiNumber = abs(uiNumber);

	std::vector<unsigned int> kBits;
	NumberBits(uiNumber, kBits);

	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->BigRed(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				+ i
				* PictureNumber::SharedInstance()->GetBigRedSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage);
		}
	}

	m_kSize.width = nStartPosition
		+ kBits.size()
		* PictureNumber::SharedInstance()->GetBigRedSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetBigRedSize().height;
}

void ImageNumber::SetBigRedTwoNumber(int uiNumber_1, int uiNumber_2)
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	uiNumber_1 = abs(uiNumber_1);
	uiNumber_2 = abs(uiNumber_2);

	std::vector<unsigned int> kBits;
	// 数字1
	NumberBits(uiNumber_1, kBits);
	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->BigRed(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPicture->GetSize().width,
				pkPicture->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPicture->GetSize().width;
		}
	}

	// 斜线
	NDPicture* picSlash = PictureNumber::SharedInstance()->BigRed(10);
	if (picSlash)
	{
		NDUIImage* pkImage = new NDUIImage();
		pkImage->Initialization();
		pkImage->SetPicture(picSlash);
		pkImage->SetFrameRect(
			CCRectMake(nStartPosition, 0, picSlash->GetSize().width,
			picSlash->GetSize().height));
		AddChild(pkImage);
		nStartPosition += picSlash->GetSize().width;
	}

	NumberBits(uiNumber_2, kBits);
	for (unsigned int i = 0; i < kBits.size(); i++)
	{
		unsigned int uiBit = kBits.at(i);
		NDPicture* pkPicture = PictureNumber::SharedInstance()->BigRed(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(nStartPosition, 0, pkPicture->GetSize().width,
				pkPicture->GetSize().height));
			AddChild(pkImage);
			nStartPosition += pkPicture->GetSize().width;
		}
	}

	m_kSize.width = nStartPosition;
	m_kSize.height = PictureNumber::SharedInstance()->GetBigRedSize().height;
}