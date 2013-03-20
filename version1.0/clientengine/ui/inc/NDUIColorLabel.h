//---------------------------------------------------------------
//  NDUIColorLabel.h
//
//  Created by zhangwq 2013/03/20
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//---------------------------------------------------------------

#pragma once

#include "NDUILabel.h"

NS_NDENGINE_BGN

class NDUIColorLabel : public NDUILabel
{
	DECLARE_CLASS(NDUIColorLabel)
	NDUIColorLabel();
	~NDUIColorLabel();

public:
	virtual void draw();

protected:
	virtual void debugDraw();
};

NS_NDENGINE_END