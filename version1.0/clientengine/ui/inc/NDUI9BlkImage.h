//
//  NDUIImage.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-18.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef __NDUI9BlkImage_H
#define __NDUI9BlkImage_H

#include "NDUINode.h"
#include "NDCombinePicture.h"

namespace NDEngine
{
	class NDUI9BlkImage : public NDUINode
	{
		DECLARE_CLASS(NDUI9BlkImage)
		NDUI9BlkImage();
		~NDUI9BlkImage();

	public:

		void SetPicture(NDPicture* pic, bool clearPicOnFree = false);
		NDPicture* GetPicture() { return m_pic;}
		void SetPictureLua(NDPicture* pic);
        void SetBlockSize(int nSize) { m_nBlockSize = nSize; }
		CCSize GetPicSize();
		virtual void draw();
	private:
		NDPicture* m_pic;
        NDPicture* m_BgBlock[9];
		bool m_clearPicOnFree;
        int m_nBlockSize;
	};
}
#endif
