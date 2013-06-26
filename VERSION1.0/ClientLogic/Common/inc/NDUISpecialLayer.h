/*
 *  NDUISpecialLayer.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

// һЩ�����ô��Ĳ�

#ifndef _ND_UI_SPECIAL_LAYER_H_
#define _ND_UI_SPECIAL_LAYER_H_

#include "NDUILayer.h"

using namespace NDEngine;

// ����˼��,��NDUIChildrenLayerר��Ϊ�ӽڵ����
// gui�¼��������ӽڵ㷶Χ��ʱ�����´����¼�,�������´����¼�
class NDUIChildrenEventLayer :
public NDUILayer
{
	DECLARE_CLASS(NDUIChildrenEventLayer)
protected:
	bool TouchBegin(NDTouch* touch); override
};

//////////////////////////////////////
class NDUITopLayer : public NDUILayer
{
	DECLARE_CLASS(NDUITopLayer)
public:
	NDUITopLayer();
	~NDUITopLayer();
	
	void Initialization(); override
	bool TouchBegin(NDTouch* touch); override
};

////////////////////////////////////////////////
//����ʵ��:ֻ�ҽ�һ���ӽڵ�,����ӽڵ㲻��ʾ��������Ϣ,�������û������ʾ�Ľڵ����������ӽڵ�
class NDUITopLayerEx : public NDUILayer
{
	DECLARE_CLASS(NDUITopLayerEx)
public:
	NDUITopLayerEx();
	~NDUITopLayerEx();
	
	void Initialization(); override
	bool TouchBegin(NDTouch* touch); override
};

////////////////////////////////////////////////
//�ɰ��

/***
* ��ʱ��ע�� ����
* begin
*/
// class NDUIMaskLayer : public NDUILayer
// {
// 	DECLARE_CLASS(NDUIMaskLayer)
// 	
// public:
// 	NDUIMaskLayer();
// 	~NDUIMaskLayer();
// 
// 	void Initialization(); override
// 	
// 	DECLARE_AUTOLINK(NDUIMaskLayer)
// 	INTERFACE_AUTOLINK(NDUIMaskLayer)
// };
/***
* ��ʱ��ע�� ����
* end
*/


#endif // _ND_UI_SPECIAL_LAYER_H_