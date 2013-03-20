/*
 *  IphoneInput.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "IphoneInput.h"
#include "NDDirector.h"
#include "define.h"
#include "CCDirector.h"
#include "UIKit/UITextField.h"
#include "UIKit/UIWindow.h"
#include "UIKit/UIDevice.h"
#include "Foundation/NSNotification.h"
#include "EAGLView.h"
#include "UsePointPls.h"

using namespace NDEngine;


////////////////////////////////////////////////////////////////////////////////
//
//                  @interface: NSIphoneInput
//
////////////////////////////////////////////////////////////////////////////////


//static CGFloat s_fMove	= 0.0f;
@interface NSIphoneInput : NSObject <UITextFieldDelegate>
{
	UITextField* tfContent;
	CIphoneInput* _iphoneInput;
	BOOL _bAutoAjust;
	CGFloat _fKeyBoardHeight;
	//CGFloat _fMove;
}

@property(nonatomic, retain) UITextField* tfContent;

-(void)SetIphoneInput:(CIphoneInput*) input;
-(void)AutoAdjust:(BOOL) bAuto;
-(void)orientationChanged:(NSNotification *)notification;
-(void)KeyBoardWillShow:(NSNotification*)notification;
-(void)keyBoardWasHidden:(NSNotification*)notification;
-(void)ChangeView:(float) fMove;

@end

@implementation NSIphoneInput

@synthesize tfContent;

-(id) init
{
	if( (self=[super init]) ) 
	{
		tfContent			= nil;
		_iphoneInput		= NULL;
		_bAutoAjust			= false;
		_fKeyBoardHeight	= 162.0f;//216.0f;
		//_fMove				= 0.0f;
	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(KeyBoardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:UIDeviceOrientationDidChangeNotification 
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyBoardWasHidden:) 
													 name:UIKeyboardDidHideNotification
                                                   object:nil];
#ifdef __IPHONE_5_0
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0) 
		{
            [[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(KeyBoardWillShow:) 
													     name:UIKeyboardWillChangeFrameNotification 
													   object:nil];
        }
#endif
	}
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIDeviceOrientationDidChangeNotification 
												  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIKeyboardWillShowNotification 
												  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];

#ifdef __IPHONE_5_0
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (version >= 5.0) 
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:UIKeyboardWillChangeFrameNotification 
													  object:nil];
	}
#endif
	[self ChangeView: 0.0f];
	[tfContent resignFirstResponder];
	[tfContent removeFromSuperview];
	[tfContent release];
	[super dealloc];
}

-(void) orientationChanged:(NSNotification *)notification
{
#if 0
	if (tfContent == nil)
	{
		return;
	}
	CGAffineTransform t = tfContent.transform;
	UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];

	BOOL bChangeKeyBoardPlace	= FALSE;

    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        tfContent.transform = CGAffineTransformRotate(t, 3.141592f);
		bChangeKeyBoardPlace	= TRUE;
    }

    if (orientation == UIDeviceOrientationLandscapeRight)
	{
        tfContent.transform		= CGAffineTransformRotate(t, 3.141592f);
		bChangeKeyBoardPlace	= TRUE;
    }
	if (bChangeKeyBoardPlace)
	{
		[tfContent resignFirstResponder];
	}
#endif
}

-(void)KeyBoardWillShow:(NSNotification*)notification
{
	if (nil == tfContent || NO == [tfContent isFirstResponder])
	{
		return;
	}

	NSDictionary* info	= [notification userInfo];
	CGSize kbSize		= [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	_fKeyBoardHeight	= kbSize.width;
	CGRect bounds	= tfContent.frame;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if (UIDeviceOrientationLandscapeLeft == orientation)
	{
		CGRect rectScr	= [[UIScreen mainScreen] bounds];
		if (bounds.origin.x < _fKeyBoardHeight)
		{
			[self ChangeView: bounds.origin.x - _fKeyBoardHeight];
		}
	}
    else if (UIDeviceOrientationLandscapeRight == orientation)
	{
		CGRect rectScr	= [[UIScreen mainScreen] bounds];
		float fH		= rectScr.size.width - bounds.origin.x - bounds.size.width;
		if (fH  < _fKeyBoardHeight)
		{
			[self ChangeView:_fKeyBoardHeight - fH];
		}
	}
}

-(void)keyBoardWasHidden:(NSNotification*)notification
{
	if (nil == tfContent || NO == [tfContent isFirstResponder])
	{
		return;
	}
	[self ChangeView: 0.0f];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (_bAutoAjust && tfContent)
	{
		CGRect bounds	= tfContent.frame;

        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

        if (UIDeviceOrientationLandscapeLeft == orientation)
		{
            if (bounds.origin.x < _fKeyBoardHeight)
            {
                [self ChangeView: bounds.origin.x - _fKeyBoardHeight];
			}
		}
        else if (UIDeviceOrientationLandscapeRight == orientation)
		{
			CGRect rectScr	= [[UIScreen mainScreen] bounds];
			float fH		= rectScr.size.width - bounds.origin.x - bounds.size.width;
			if (fH  < _fKeyBoardHeight)
			{
				[self ChangeView:_fKeyBoardHeight - fH];
			}
		}
	}
    
	if (_iphoneInput)
	{
		_iphoneInput->SetInputState(true);
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (_bAutoAjust && tfContent)
	{
		[self ChangeView: 0.0f];
	}
    
    if (_iphoneInput)
	{
		CInputBase* input = _iphoneInput->GetInputDelegate();
		if (input)
		{
            input->OnInputFinish(input);
		}
	}
	
	if (_iphoneInput)
	{
		_iphoneInput->SetInputState(false);
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (_iphoneInput)
	{
		CInputBase* input = _iphoneInput->GetInputDelegate();
		if (input && !input->OnInputReturn(input))
		{
			return NO;
		}
	}
	[tfContent resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
													   replacementString:(NSString *)string
{
	if (_iphoneInput)
	{
		CInputBase* input = _iphoneInput->GetInputDelegate();
		if (input && !input->OnInputTextChange(input, [string UTF8String]))
		{
			return NO;
		}
        
        unsigned int nLengthLimit = _iphoneInput->GetLengthLimit();
        //** chh 2012-08-14 **//
        if(range.location >= nLengthLimit){
            return NO;
        }
	}
	
	return YES;
}

- (void)SetIphoneInput:(CIphoneInput*) input
{
	_iphoneInput	= input;
}

- (void)AutoAdjust:(BOOL) bAuto
{
	_bAutoAjust		= bAuto;
}

-(void)ChangeView:(float) fMove
{
#if 0
	float fMoveDis	= -(s_fMove) + fMove;
	s_fMove			= fMove;
	
	CGAffineTransform t = [[CCDirector sharedDirector] openGLView].transform;
	[[CCDirector sharedDirector] openGLView].transform = CGAffineTransformTranslate(t, -fMoveDis, 0);
#endif
}

@end



////////////////////////////////////////////////////////////////////////////////
//
//                  CIphoneInput
//
////////////////////////////////////////////////////////////////////////////////

CIphoneInput::CIphoneInput()
{
	m_inputDelegate	= NULL;
	m_textFieldWrapper	= NULL;
	m_bAutoAdjust	= false;
	m_bInputState	= false;
	m_bShow			= false;
}

CIphoneInput::~CIphoneInput()
{
    if (m_bShow)
	{
		[m_textFieldWrapper.tfContent resignFirstResponder];
		[m_textFieldWrapper.tfContent removeFromSuperview];
	}
	[m_textFieldWrapper release];
}

UITextField* CIphoneInput::getTextField() const
{
	return m_textFieldWrapper ? m_textFieldWrapper.tfContent : NULL;
}

void CIphoneInput::Init()
{
	m_textFieldWrapper	= [[NSIphoneInput alloc] init];

    this->initTextField();
    
	[m_textFieldWrapper SetIphoneInput:this];
	
    [[EAGLView sharedEGLView] addSubview : m_textFieldWrapper.tfContent];
}

void CIphoneInput::initTextField()
{
    // init text field
	UITextField* tf = [[UITextField alloc] init];
	tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.textColor = [UIColor blackColor];
	tf.returnKeyType = UIReturnKeyDone;
	tf.delegate = m_textFieldWrapper;


	/*
     ccDeviceOrientation cor = [[CCDirector sharedDirector] deviceOrientation];
     if ((ccDeviceOrientation)UIDeviceOrientationLandscapeLeft == cor)
     {
     tf.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
     }
     else if ((ccDeviceOrientation)UIDeviceOrientationLandscapeRight == cor)
     {
     tf.transform = CGAffineTransformMakeRotation(-3.141592f/2.0f);
     }*/
    
    m_textFieldWrapper.tfContent	=  tf;
    
    [tf release];
}

void CIphoneInput::Show()
{
	if (m_textFieldWrapper.tfContent && nil == m_textFieldWrapper.tfContent.superview)
	{
        [[EAGLView sharedEGLView] addSubview : m_textFieldWrapper.tfContent];
		[m_textFieldWrapper.tfContent becomeFirstResponder];
	}
	m_bShow		= true;
}

void CIphoneInput::Hide()
{
	if (m_textFieldWrapper.tfContent && nil != m_textFieldWrapper.tfContent.superview)
	{
		[m_textFieldWrapper.tfContent resignFirstResponder];
		[m_textFieldWrapper.tfContent removeFromSuperview];
	}
	m_bShow		= false;
}

bool CIphoneInput::IsShow()
{
	return m_bShow;
}
void CIphoneInput::SetFrame(float fX, float fY, float fW, float fH)
{
    CCSize winsize = CCDirector::sharedDirector()->getWinSize(); // in points
    float fScale	= RESOURCE_SCALE;
	
	// convert pixel into points
    if (CCDirector::sharedDirector()->getOpenGLView()->isRetinaEnabled())
	{
		fX	/= fScale;
		fY	/= fScale;
		fW	/= fScale;
		fH	/= fScale;
	}
	
#if 0
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent)
	{
        UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
        
        if (UIDeviceOrientationLandscapeLeft == orientation)
		{
            m_textFieldWrapper.tfContent.frame	= CGRectMake(winsize.height - fY - fH, fX, fH, fW);
			m_textFieldWrapper.tfContent.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
		}
        else if (UIDeviceOrientationLandscapeRight == orientation)
		{
			m_textFieldWrapper.tfContent.frame	= CGRectMake(fY, winsize.width - fX - fW, fH, fW);
			m_textFieldWrapper.tfContent.transform = CGAffineTransformMakeRotation(-3.141592f/2.0f);
		}
	}
#else
    m_textFieldWrapper.tfContent.frame	= CGRectMake(0, 0, winsize.width, 30);
#endif
}

void CIphoneInput::SetInputDelegate(CInputBase* input)
{
	m_inputDelegate = input;
}

CInputBase* CIphoneInput::GetInputDelegate()
{
	return m_inputDelegate;
}

void CIphoneInput::SetText(const char* text)
{
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent)
	{
		NSString *content = [NSString stringWithUTF8String:(text == NULL ? "" : text)];
		m_textFieldWrapper.tfContent.text = content;
	}
}

const char* CIphoneInput::GetText()
{
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent && m_textFieldWrapper.tfContent.text)
	{
		return [m_textFieldWrapper.tfContent.text UTF8String];
	}
	
	return "";
}

void CIphoneInput::EnableSafe(bool bEnable)
{
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent)
	{
		m_textFieldWrapper.tfContent.secureTextEntry = bEnable;
	}
}

void CIphoneInput::EnableAutoAdjust(bool bEnable)
{
	if (m_textFieldWrapper && m_textFieldWrapper)
	{
		[m_textFieldWrapper AutoAdjust:bEnable];
	}
	
	m_bAutoAdjust	= bEnable;
}

bool CIphoneInput::IsInputState()
{
	return m_bInputState;
}

void CIphoneInput::SetStyleNone()
{
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent)
	{
		m_textFieldWrapper.tfContent.borderStyle = UITextBorderStyleNone;
	}
}
void CIphoneInput::SetTextColor(float fR, float fG, float fB, float fA)
{
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent)
	{
        //alwasy black color
		m_textFieldWrapper.tfContent.textColor = //[UIColor colorWithRed:fR green:fB blue:fB alpha:fA];
                                                [UIColor blackColor];
	}
}
void CIphoneInput::SetFontSize(int nFontSize)
{
	if (m_textFieldWrapper && m_textFieldWrapper.tfContent)
	{
		m_textFieldWrapper.tfContent.font = [UIFont systemFontOfSize:nFontSize*RESOURCE_SCALE];
	}
}
void CIphoneInput::SetInputState(bool bSet)
{
	m_bInputState	= bSet;
}
//////////////////////////////////////////////////////
void CIphoneInput::SetLengthLimit(unsigned int nLengthLimit)
{
    m_usLengthLimit = nLengthLimit;
}
//////////////////////////////////////////////////////
unsigned int CIphoneInput::GetLengthLimit(void)
{
    return m_usLengthLimit;
}
