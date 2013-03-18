#include "NDScrollImageNumber.h"
#include "ImageNumber.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDScrollImageNumber,NDObject)

NDScrollImageNumber::NDScrollImageNumber()
{

}

NDScrollImageNumber::~NDScrollImageNumber()
{

}

bool NDScrollImageNumber::SetScrollNumber( int uiNumber,FontType eType,
										  bool bWithSign /*= false*/ )
{
	RemoveAllChildren(true);

	int nStartPosition = 0;

	if (bWithSign) // ÏÔÊ¾·ûºÅ
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

	return true;
}

NS_NDENGINE_END