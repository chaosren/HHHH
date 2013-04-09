//
//  NDUI9BlkImage.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-18.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "NDUI9BlkImage.h"
#include "ObjectTracker.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUI9BlkImage, NDUINode)
	
	NDUI9BlkImage::NDUI9BlkImage()
	{
		INC_NDOBJ_RTCLS
		m_pic = NULL;
		m_clearPicOnFree = false;
        m_BgBlock[0] = m_BgBlock[1] = m_BgBlock[2] = m_BgBlock[3] = m_BgBlock[4] = m_BgBlock[5] = m_BgBlock[6] = m_BgBlock[7] = m_BgBlock[8] = 0;
	}
	
	NDUI9BlkImage::~NDUI9BlkImage()
	{
		DEC_NDOBJ_RTCLS
		if (m_clearPicOnFree) 
		{
			delete m_pic;
		}
	}
	
	void NDUI9BlkImage::SetPicture(NDPicture* pic, bool clearPicOnFree)
	{
		if (m_clearPicOnFree) 
		{
			delete m_pic;
		}
		
		m_pic = pic;
		m_clearPicOnFree = clearPicOnFree;
        int controlSize = pic->GetSize().width/3;
        
        //1
        {
            CCRect rectSrc(0, 0, controlSize, controlSize);
            m_BgBlock[0] = pic->Copy();
            m_BgBlock[0]->Cut(rectSrc);
        }
        //2
        {
            CCRect rectSrc(controlSize, 0, controlSize, controlSize);
            m_BgBlock[1] = pic->Copy();
            m_BgBlock[1]->Cut(rectSrc);
        }
        //3
        {
            
            CCRect rectSrc(controlSize*2, 0, controlSize, controlSize);
            m_BgBlock[2] = pic->Copy();
            m_BgBlock[2]->Cut(rectSrc);
        }
        //4
        {
            
            CCRect rectSrc(0, controlSize, controlSize, controlSize);
            m_BgBlock[3] = pic->Copy();
            m_BgBlock[3]->Cut(rectSrc);
        }
        //5
        {
            
            CCRect rectSrc(controlSize, controlSize, controlSize, controlSize);
            m_BgBlock[4] = pic->Copy();
            m_BgBlock[4]->Cut(rectSrc);
        }
        //6
        {
            CCRect rectSrc(controlSize*2, controlSize, controlSize, controlSize);
            m_BgBlock[5] = pic->Copy();
            m_BgBlock[5]->Cut(rectSrc);
            
        }
        //7
        {
            CCRect rectSrc(0, controlSize*2, controlSize, controlSize);
            m_BgBlock[6] = pic->Copy();
            m_BgBlock[6]->Cut(rectSrc);
            
        }
        //8
        {
            CCRect rectSrc(controlSize, controlSize*2, controlSize, controlSize);
            m_BgBlock[7] = pic->Copy();
            m_BgBlock[7]->Cut(rectSrc);
            
        }
        //9
        {
            CCRect rectSrc(controlSize*2, controlSize*2, controlSize, controlSize);
            m_BgBlock[8] = pic->Copy();
            m_BgBlock[8]->Cut(rectSrc);
            
        }
	}
	
	void NDUI9BlkImage::SetPictureLua(NDPicture* pic)
	{
		this->SetPicture(pic, true);
	}
	
	CCSize NDUI9BlkImage::GetPicSize()
	{
		if (!m_pic)
		{
			return CCSizeZero;
		}
		
		return m_pic->GetSize();
	}
	
	void NDUI9BlkImage::draw()
	{
		if (!isDrawEnabled()) return;
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
            int controlSize = m_pic->GetSize().width/3;
            int marginSize = this->m_nBlockSize;
            if(marginSize <= 0)
                marginSize = controlSize;
            CCRect rect = this->GetScreenRect();
            //1
			if (m_BgBlock[0])
			{
                CCRect rectTarget(rect.origin.x, rect.origin.y, marginSize, marginSize);
				m_BgBlock[0]->DrawInRect(rectTarget);
			}
            //2
			if (m_BgBlock[1])
			{
                CCRect rectTarget(rect.origin.x+marginSize, rect.origin.y, rect.size.width-marginSize*2, marginSize);
				m_BgBlock[1]->DrawInRect(rectTarget);
			}
            //3
			if (m_BgBlock[2])
            {
                CCRect rectTarget(rect.origin.x+rect.size.width-marginSize, rect.origin.y, marginSize, marginSize);
				m_BgBlock[2]->DrawInRect(rectTarget);
            }
            //4
			if (m_BgBlock[3])
            {
                CCRect rectTarget(rect.origin.x, rect.origin.y+marginSize, marginSize, rect.size.height-marginSize*2);
				m_BgBlock[3]->DrawInRect(rectTarget);
            }
            //5
			if (m_BgBlock[4])
            {
                CCRect rectTarget(rect.origin.x+marginSize, rect.origin.y+marginSize, rect.size.width-marginSize*2, rect.size.height-marginSize*2);
				m_BgBlock[4]->DrawInRect(rectTarget);
            }
            //6
			if (m_BgBlock[5])
            {
                CCRect rectTarget(rect.origin.x+rect.size.width-marginSize, rect.origin.y+marginSize, marginSize, rect.size.height-marginSize*2);
				m_BgBlock[5]->DrawInRect(rectTarget);
                
            }
            //7
			if (m_BgBlock[6])
            {
                CCRect rectTarget(rect.origin.x, rect.origin.y+rect.size.height-marginSize, marginSize, marginSize);
				m_BgBlock[6]->DrawInRect(rectTarget);
                
            }
            //8
			if (m_BgBlock[7])
            {
                CCRect rectTarget(rect.origin.x+marginSize, rect.origin.y+rect.size.height-marginSize, rect.size.width-marginSize*2, marginSize);
				m_BgBlock[7]->DrawInRect(rectTarget);
                
            }
            //9
			if (m_BgBlock[8])
            {
                CCRect rectTarget(rect.origin.x+rect.size.width-marginSize, rect.origin.y+rect.size.height-marginSize, marginSize, marginSize);
				m_BgBlock[8]->DrawInRect(rectTarget);
            }
            
		}		

		//使用NDPicture了，这里不需要debugDraw()了.
	}
}