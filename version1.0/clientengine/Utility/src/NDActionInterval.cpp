#include "NDActionInterval.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDActionInterval,NDObject)

NDActionInterval::NDActionInterval()
{
	m_pkActionInterval = 0;
}

NDActionInterval::~NDActionInterval()
{
	m_pkActionInterval = 0;
}

bool NDActionInterval::IsDone()
{
	return m_pkActionInterval->isDone();
}

NS_NDENGINE_END