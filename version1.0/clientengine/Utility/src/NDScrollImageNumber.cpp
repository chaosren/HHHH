#include "NDScrollImageNumber.h"
#include "ImageNumber.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDScrollImageNumber,NDObject)

NDScrollImageNumber::NDScrollImageNumber():
m_fScrollTime(5.0f),
m_nScrollNumber(0)
{

}

NDScrollImageNumber::~NDScrollImageNumber()
{

}

bool NDScrollImageNumber::SetScrollNumber(int uiNumber,
										  float fSecond,
										  FontType eType,
										  bool bWithSign )
{
	m_nScrollNumber = uiNumber;
	m_eFontType = eType;
	m_fScrollTime = fSecond;

	NumberBits(m_nScrollNumber, m_kBits);

	return true;
}

void NDScrollImageNumber::draw()
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	m_nScrollNumber = abs(m_nScrollNumber);

	std::vector<unsigned int> kBits;
	NumberBits(m_nScrollNumber, kBits);

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

	ImageNumber::draw();
}

NS_NDENGINE_END