#include "NDScrollImageNumber.h"
#include "ImageNumber.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDScrollImageNumber,NDObject)

NDScrollImageNumber::NDScrollImageNumber():
m_fScrollTime(5.0f),
m_nScrollTimeEveryBit(0),
m_uiCurrentIndex(0),
m_bIsRenderingNumber(false),
m_nCurrentBit(0)
{
	memset(&m_kLastUpdateTimeVal,0,sizeof(cc_timeval));
	//m_kCurrentBits.push_back(0);
}

NDScrollImageNumber::~NDScrollImageNumber()
{

}

bool NDScrollImageNumber::SetScrollNumber(int uiNumber,
										  float fSecond,
										  FontType eType,
										  bool bWithSign )
{
	m_nScrollTimeEveryBit = uiNumber;
	m_eFontType = eType;
	m_fScrollTime = fSecond;

	memset(&m_kLastUpdateTimeVal,0,sizeof(cc_timeval));
	CCTime kTime;
	kTime.gettimeofdayCocos2d(&m_kLastUpdateTimeVal,0);

	NumberBits(m_nScrollTimeEveryBit, m_kBits);
	m_nCurrentBit = m_kBits.size();

	for (unsigned int uiIndex = 0;uiIndex < m_kBits.size();uiIndex++)
	{
		PictureVector kVector;

		for (int i = 0;i < 10;i++)
		{
			NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallRed(i);
			kVector.push_back(pkPicture);
		}

		m_kDoublePicVector.push_back(kVector);
	}

	m_bIsRenderingNumber = true;

	return true;
}

void NDScrollImageNumber::draw()
{
	if (false == m_bIsRenderingNumber)
	{
		return;
	}

	static int s_nDelta = 0;

	s_nDelta++;

	if (s_nDelta % 2 != 0)
	{
		return;
	}

	cc_timeval kCurrentTime = {0};
	double dbTimeDelta = 0.0;
	CCTime kTime;
	kTime.gettimeofdayCocos2d(&kCurrentTime,0);
	dbTimeDelta = kTime.timersubCocos2d(&m_kLastUpdateTimeVal,&kCurrentTime);

	float fDelta = static_cast<float>(dbTimeDelta / 1000.0);
	float fEveryNumberDelta = m_fScrollTime / 10.0f;

	if (m_kBits == m_kCurrentBits)
	{
		return;
	}

	RemoveAllChildren(true);

	int nStartPosition = 500;

	if (m_kCurrentBits.size() == 0)
	{
		m_kCurrentBits.push_back(0);
	}

	m_nScrollTimeEveryBit = abs(m_nScrollTimeEveryBit);

	for (unsigned int i = 0; i < m_kCurrentBits.size(); i++)
	{
		unsigned int uiBit = m_kCurrentBits[i];
		NDPicture* pkPicture = PictureNumber::SharedInstance()->SmallRed(uiBit);
		if (pkPicture)
		{
			NDUIImage* pkImage = new NDUIImage();
			pkImage->Initialization();
			pkImage->SetPicture(pkPicture);
			pkImage->SetFrameRect(
				CCRectMake(
				nStartPosition
				- i
				* PictureNumber::SharedInstance()->GetSmallRedSize().width,
				0, pkPicture->GetSize().width, pkPicture->GetSize().height));
			AddChild(pkImage,100,1000 + i);
		}

		if (m_kCurrentBits[i] + 1 <= 9)
		{
			if ((int)i >= m_nCurrentBit - 1 && m_kCurrentBits[i] == m_kBits[m_kBits.size() - 1 - i])
			{
				if (i == m_nCurrentBit - 1)
				{
					m_nCurrentBit--;
				}

				continue;
			}

			m_kCurrentBits[i] = m_kCurrentBits[i] + 1;
		}
		else
		{
			m_kCurrentBits[i] = 0;

			if (m_kCurrentBits.size() < m_kBits.size() && i == m_kCurrentBits.size() - 1)
			{
				m_kCurrentBits.push_back(1);
			}
		}
	}

	m_kSize.width = m_kBits.size()
		* PictureNumber::SharedInstance()->GetSmallRedSize().width;
	m_kSize.height = PictureNumber::SharedInstance()->GetSmallRedSize().height;

	ImageNumber::draw();
}

NS_NDENGINE_END