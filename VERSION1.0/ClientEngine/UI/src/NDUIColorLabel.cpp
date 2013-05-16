//---------------------------------------------------------------
//  NDUIColorLabel.h
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//---------------------------------------------------------------

#include "NDUIColorLabel.h"
#include "UsePointPls.h"
#include "ObjectTracker.h"
#include "CCDrawingPrimitives.h"
#include "CCPointExtension.h"
#include "NDDebugOpt.h"

using namespace cocos2d;


NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDUIColorLabel,NDUILabel)
	
NDUIColorLabel::NDUIColorLabel()
{
	INC_NDOBJ_RTCLS
	
	m_uiRenderTimes = 1;
}
	
NDUIColorLabel::~NDUIColorLabel()
{
	DEC_NDOBJ_RTCLS
}
	
void NDUIColorLabel::draw()
{
	//-------------------------------------------
	//NOTE: DONT call NDUILabel::draw()
	//-------------------------------------------

	if (!isDrawEnabled()
		|| !NDDebugOpt::getDrawUILabelEnabled()
		|| !this->IsVisibled()) return;

	this->preDraw();

	if (!m_texture) return;
	if (m_texture->getPixelsWide() == 0 || m_texture->getPixelsHigh() == 0) return;

	NDUINode::draw();

	DrawSetup( kCCShader_PositionTexture );


	//** chh 2012-08-08 文字透明功能 **//
 	if(m_kColor.a <255)
 	{
 		ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE);
 	}
 	else
	{
		ccGLBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
	}

	ccGLBindTexture2D(m_texture->getName());

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

	//
	// Attributes
	//
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );

	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_pfCoordinates);

// #if 0
// 	if (m_bHasFontBoderColor) 
// 	{
// 		// vertex
// 		glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pfVerticesBoder);
// 
// 		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
// 	}
// #endif

	// vertex
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pfVertices);

	for (int i = 0; i < m_uiRenderTimes; i++)
	{
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}

	// restore blend state
	if(m_kColor.a <255)
	{
		ccGLBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
	}

	CHECK_GL_ERROR_DEBUG();

	debugDraw();
}

void NDUIColorLabel::debugDraw()
{
	if (!NDDebugOpt::getDrawDebugEnabled()) return;

	glLineWidth(1);
	ccDrawColor4F(1,0,0,1);
	CCPoint lb = ccp(m_pfVertices[0],m_pfVertices[1]);
	CCPoint rt = ccp(m_pfVertices[9],m_pfVertices[10]);
	ccDrawRect( lb, rt );
	ccDrawLine( lb, rt );
}

NS_NDENGINE_END