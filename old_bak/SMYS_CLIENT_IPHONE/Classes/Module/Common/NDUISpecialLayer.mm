/*
 *  NDUISpecialLayer.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUISpecialLayer.h"

IMPLEMENT_CLASS(NDUIChildrenEventLayer, NDUILayer)

bool NDUIChildrenEventLayer::TouchBegin(NDTouch* touch)
{
	CGPoint beginTouch = touch->GetLocation();
	
	if (!(CGRectContainsPoint(this->GetScreenRect(), beginTouch) && this->IsVisibled() && this->EventEnabled())) 
		return false;
	
	for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
	{
		NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
		
		//un visibled node dont accept event
		if (!uiNode->IsVisibled()) 
		{
			continue;
		}
		
		//un receive event node dont accept event
		if (!uiNode->EventEnabled()) 
		{
			continue;
		}
		
		//un darwed dont accept event
		if (!uiNode->DrawEnabled()) 
		{
			continue;
		}
		
		//NDUILayer need dispatch event
		if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIChildrenEventLayer))) 
		{
			NDUIChildrenEventLayer* uiLayer = (NDUIChildrenEventLayer*)uiNode;
			if (uiLayer->TouchBegin(touch))
				return true;
			else 
				continue;
		}
		
		//touch event deal.....
		CGRect nodeFrame = uiNode->GetScreenRect();
		
		if (CGRectContainsPoint(nodeFrame, beginTouch)) 
		{
			return NDUILayer::TouchBegin(touch);
		}
	}
	
	return false;
}

//////////////////////////////////////

IMPLEMENT_CLASS(NDUITopLayer, NDUILayer)

NDUITopLayer::NDUITopLayer()
{
}

NDUITopLayer::~NDUITopLayer()
{
}

void NDUITopLayer::Initialization()
{
	NDUILayer::Initialization();
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
}

bool NDUITopLayer::TouchBegin(NDTouch* touch)
{
	m_beginTouch = touch->GetLocation();
	
	if (!CGRectContainsPoint(this->GetScreenRect(), m_beginTouch))
	{
		return false;
	}
	
	std::vector<NDNode*> tmplist = GetChildren();
	
	if (tmplist.empty())
	{
		return false;
	}
	
	std::vector<NDNode*>::iterator it = tmplist.begin();
	for (; it != tmplist.end(); it++) 
	{
		NDNode *node = (*it);
		if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
		{
			NDUINode *uinode = (NDUINode*)node;
			if (uinode->IsVisibled() && this->IsVisibled() && this->EventEnabled()) 
			{
				this->DispatchTouchBeginEvent(m_beginTouch);
				return true;
			}
		}
		
	}
	
	return false;
}

////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUITopLayerEx, NDUILayer)

NDUITopLayerEx::NDUITopLayerEx()
{
}

NDUITopLayerEx::~NDUITopLayerEx()
{
}

void NDUITopLayerEx::Initialization()
{
	NDUILayer::Initialization();
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
}

bool NDUITopLayerEx::TouchBegin(NDTouch* touch)
{
	m_beginTouch = touch->GetLocation();
	
	std::vector<NDNode*> tmplist = GetChildren();
	
	if (tmplist.size() != 1 || !tmplist[0]->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		return false;
	}
	
	NDUINode *node = (NDUINode *)(tmplist[0]);
	if (!node || !node->IsVisibled()) 
	{
		return false;
	}
	
	if (!CGRectContainsPoint(node->GetScreenRect(), m_beginTouch))
	{
		node->SetVisible(false);
	}	
	
	return NDUILayer::TouchBegin(touch);
}

////////////////////////////////////////////////
//蒙板层
IMPLEMENT_CLASS(NDUIMaskLayer, NDUILayer)

NDUIMaskLayer::NDUIMaskLayer()
{
	INIT_AUTOLINK(NDUIMaskLayer);
}

NDUIMaskLayer::~NDUIMaskLayer()
{
}

void NDUIMaskLayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetBackgroundColor(ccc4(125, 125, 125, 125));
	
	this->SetTouchEnabled(false);
}

