/*
 *  NDUtility.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "NDUtility.h"
#import "CCScheduler.h"
#import "NDDirector.h"
#import "ccMacros.h"
#include "NDString.h"
#include "NDUIDialog.h"
#import "CGPointExtension.h"
#import "CCDrawingPrimitives.h"
#include "Battle.h"
#include "NDMapMgr.h"
#include "InitMenuScene.h"
#include "ItemMgr.h"
#include "GlobalDialog.h"
#include "TutorUILayer.h"
#include "UserStateUILayer.h"
#include "VendorUILayer.h"
#include "NDPath.h"
#include "BeatHeart.h"
#import "UIDevice-Hardware.h"
#import "NDUISynLayer.h"
#include "BattleFieldData.h"
#include "BattleMgr.h"
#include "CPet.h"
#include "SMLoginScene.h"
#include "ScriptGlobalEvent.h"
#include "Chat.h"
#include "Drama.h"
#include "ScriptGameData.h"
#import "SimpleAudioEngine_objc.h"

using namespace NDEngine;

#define USE_ADVANCE_PICTURE (1)









bool IsPointInside(CGPoint pt, CGRect rect)
{
	return (pt.x >= rect.origin.x &&
		pt.y >= rect.origin.y &&
		pt.x <= rect.size.width + rect.origin.x &&
		pt.y <= rect.size.height + rect.origin.y);
}

int GetNumBits(int num)
{
	int bits = 0;
	while (num > 0) {
		bits++;
		num /= 10;
	}
	
	return bits;
}

bool VerifyUnsignedNum(const std::string strnum)
{
	if (strnum.empty()) return false;
	
	for_vec(strnum, std::string::const_iterator)
	{
		if (!isdigit(*it)) return false;
	}
	
	return true;
}

void DrawRecttangle(CGRect rect, ccColor4B color)
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();
	
	GLfloat vertices[8] = { 
		rect.origin.x, winSize.height - rect.origin.y - rect.size.height, 
		rect.origin.x + rect.size.width, winSize.height - rect.origin.y - rect.size.height, 
		rect.origin.x, winSize.height - rect.origin.y, 
		rect.origin.x + rect.size.width, winSize.height - rect.origin.y
	};
	
	GLbyte colors[16] = {
		color.r, color.g, color.b, color.a,
		color.r, color.g, color.b, color.a,
		color.r, color.g, color.b, color.a,
		color.r, color.g, color.b, color.a
	};
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glVertexPointer(2, GL_FLOAT, 0, vertices);		
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
	
	glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
}

void DrawPolygon(CGRect rect, ccColor4B color, GLuint lineWidth)
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	float scale		= NDDirector::DefaultDirector()->GetScaleFactor();	
	
	glLineWidth(lineWidth);
	glColor4ub(color.r, color.g, color.b, color.a); 
	
    /*
	if (CompareEqualFloat(scale, 0.0f))
	{
     */
		CGPoint vertices[4] = {
			ccp(rect.origin.x, winSize.height - rect.origin.y - rect.size.height), 
			ccp(rect.origin.x + rect.size.width, winSize.height - rect.origin.y - rect.size.height),
			ccp(rect.origin.x + rect.size.width, winSize.height - rect.origin.y),
			ccp(rect.origin.x, winSize.height - rect.origin.y)			
		}; 
		ccDrawPoly(vertices, 4, true);
    /*
	}
	else
	{
		CGPoint vertices[4] = {
			ccp(rect.origin.x / scale, (winSize.height - rect.origin.y - rect.size.height) / scale), 
			ccp((rect.origin.x + rect.size.width) / scale, (winSize.height - rect.origin.y - rect.size.height) / scale),
			ccp((rect.origin.x + rect.size.width) / scale, (winSize.height - rect.origin.y) / scale),
			ccp(rect.origin.x / scale, (winSize.height - rect.origin.y) / scale)			
		}; 
		ccDrawPoly(vertices, 4, true);
	}*/
	
	glColor4ub(255, 255, 255, 255); 
}

void DrawLine(CGPoint fromPoint, CGPoint toPoint, ccColor4B color, GLuint lineWidth)
{	
	NDDirector& director	= *(NDDirector::DefaultDirector());
	CGSize winSize			= director.GetWinSize();
	
	glLineWidth(lineWidth);
	glColor4ub(color.r, color.g, color.b, color.a);
	
	ccVertex2F vertices[2];

	vertices[0].x	= fromPoint.x;
	vertices[0].y	= winSize.height - fromPoint.y;
	vertices[1].x	= toPoint.x;
	vertices[1].y	= winSize.height - toPoint.y;
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_LINES, 0, 2);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	glColor4ub(255, 255, 255, 255);
}

void DrawCircle(CGPoint center, float r, float a, int segs, ccColor4B color)
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	CGPoint glCenter = ccp(center.x, winSize.height - center.y);
	
	glColor4ub(color.r, color.g, color.b, color.a);
	
	int additionalSegment = 1;
	
	const float coef = 2.0f * (float)M_PI/segs;
	
	float *vertices = (float *)malloc( sizeof(float)*2*(segs+2));
	if( ! vertices )
		return;
	
	memset( vertices,0, sizeof(float)*2*(segs+2));
	
	for(int i=0;i<=segs;i++)
	{
		float rads = i*coef;
		float j = r * cosf(rads + a) + glCenter.x;
		float k = r * sinf(rads + a) + glCenter.y;
		
		vertices[i*2] = j;
		vertices[i*2+1] =k;
	}
	vertices[(segs+1)*2] = glCenter.x;
	vertices[(segs+1)*2+1] = glCenter.y;
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_TRIANGLE_FAN, 0, segs+additionalSegment);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
	free( vertices );
	
	glColor4ub(255, 255, 255, 255); 
}

void DrawFrame(int borderColor, int x, int y, int width, int height) {
	
	int y2 = y + height - 1, x2 = x + width - 1;
	
	ccColor4B clr = INTCOLORTOCCC4(borderColor);
	DrawRecttangle(CGRectMake(x - 1, y - 1, 4, 4), clr); // 左上角框
	DrawRecttangle(CGRectMake(x2 - 3, y - 1, 4, 4), clr); // 右上角框
	
	DrawRecttangle(CGRectMake(x - 1, y2 - 3, 4, 4), clr); // 左下角框
	DrawRecttangle(CGRectMake(x2 - 3, y2 - 3, 4, 4), clr); // 右下角框
	
	DrawLine(CGPointMake(x, y + 5), CGPointMake(x + 5, y + 5), clr, 1);
	DrawLine(CGPointMake(x + 5, y), CGPointMake(x + 5, y + 5), clr, 1);
	DrawLine(CGPointMake(x2, y + 5), CGPointMake(x2 - 5, y + 5), clr, 1);
	DrawLine(CGPointMake(x2 - 5, y), CGPointMake(x2 - 5, y + 5), clr, 1);
	
	DrawLine(CGPointMake(x2, y2 - 5), CGPointMake(x2 - 5, y2 - 5), clr, 1);
	DrawLine(CGPointMake(x2 - 5, y2), CGPointMake(x2 - 5, y2 - 5), clr, 1);
	DrawLine(CGPointMake(x, y2 - 5), CGPointMake(x + 5, y2 - 5), clr, 1);
	DrawLine(CGPointMake(x + 5, y2), CGPointMake(x + 5, y2 - 5), clr, 1);
	
	DrawLine(CGPointMake(x + 5, y), CGPointMake(x + width - 6, y), clr, 1);
	DrawLine(CGPointMake(x + 5, y2), CGPointMake(x + width - 6, y2), clr, 1);
	
	DrawLine(CGPointMake(x, y + 5), CGPointMake(x, y2 - 5), clr, 1);
	DrawLine(CGPointMake(x2, y + 5), CGPointMake(x2, y2 - 5), clr, 1);
}

void DrawTriangle(CGPoint first, CGPoint second, CGPoint third, ccColor4B color)
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();
	
	GLfloat vertices[6] = { 
		first.x, winSize.height - first.y, 
		second.x, winSize.height - second.y, 
		third.x, winSize.height - third.y
	};
	
	GLbyte colors[12] = {
		color.r, color.g, color.b, color.a,
		color.r, color.g, color.b, color.a,
		color.r, color.g, color.b, color.a,
	};
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glVertexPointer(2, GL_FLOAT, 0, vertices);		
	glDrawArrays(GL_TRIANGLES, 0, 3);	
	
	glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

std::string changeToChineseSign(std::string old)
{
	if (old.empty())
	{
		return "";
	}
	
	NDString ndstr(old);
	
	ndstr.replace(NDString(","), NDString("，"));
	ndstr.replace(NDString("."), NDString("。"));
	ndstr.replace(NDString("!"), NDString("！"));
	ndstr.replace(NDString("?"), NDString("？"));
	ndstr.replace(NDString(":"), NDString("："));
	ndstr.replace(NDString("("), NDString("（"));
	ndstr.replace(NDString(")"), NDString("）"));
	
	ndstr.replace(NDString("。。。。。。"), NDString("......"));
	ndstr.replace(NDString("。。。。。"), NDString("....."));
	ndstr.replace(NDString("。。。。"), NDString("...."));
	ndstr.replace(NDString("。。。"), NDString("..."));
	ndstr.replace(NDString("。。"), NDString(".."));
	
	return std::string(ndstr.getData());
}

void showDialog(const char* title, const char* content)
{
	NDUIDialog *dialog = new NDUIDialog;
	dialog->Initialization();
	dialog->Show(title, content, NULL, NULL);
}

void showDialog(const char* content)
{
	showDialog(NDCommonCString("error"), content);
}

CGSize getStringSize(const char* pszStr, uint fontSize)
{
	CGSize sz = CGSizeMake(0.0f, 0.0f);
	
	//fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();
	
	if (pszStr) {
		NSString* str = [NSString stringWithUTF8String:pszStr];
		sz = [str sizeWithFont:[UIFont fontWithName:FONT_NAME size:fontSize]];
	}
	
	return sz;
}

CGSize getStringSizeMutiLine(const char* pszStr, uint fontSize, CGSize contentSize)
{
	CGSize sz = CGSizeZero;
	
	if (!pszStr)
	{
		return sz;
	}
	
	//fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();
	
	NSString *nstext = [NSString stringWithUTF8String:pszStr];
	sz = [nstext sizeWithFont:[UIFont fontWithName:FONT_NAME size:fontSize] 
			constrainedToSize:contentSize];
	
	return sz;
}

// 退出游戏,返回主界面时统一做释放及各模块初始化操作
void quitGame(bool bTipNet/*=false*/)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if( NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusStoped )
    {
        NDDataTransThread::DefaultThread()->Stop();
	}
    
	CloseProgressBar;
	ScriptGlobalEvent::OnEvent(GE_QUITGAME);
    Chat::Release();
    BattleMgrObj.quitBattle(false);
	Battle::ResetLastTurnBattleAction();  
	GameScene::ClearAllPosText();
	DramaObj.QuitGame();
//	BeatHeartMgrObj.Stop();
	NDMapMgrObj.quitGame();
	ItemMgrObj.quitGame();
	PetMgrObj.DelAll();
//	TutorUILayer::reset();
//	UserStateUILayer::reset();
//	VendorUILayer::reset();
//	
	BattleField::quitGame();
	
	CGlobalDialog::getSingleton().quitGame();
	
	BattleMgrObj.ReleaseAllBattleSkill();
	
	while (NDDirector::DefaultDirector()->PopScene());
	
	NDDirector::DefaultDirector()->ReplaceScene(CSMLoginScene::Scene());
	
	//ScriptGameDataObj.DelAllData();
    
    //[SimpleAudioEngine end];
	ScriptGlobalEvent::OnEvent(GE_LOGIN_GAME);
    [pool release];
}

string getStringTime(long nSeconds)
{
	NSDate* endTime = [NSDate dateWithTimeIntervalSince1970:nSeconds];
	NSString* strEndTime = [endTime description];
	NSString* retStr = [strEndTime substringWithRange:NSMakeRange(5, 11)];
	return [retStr UTF8String];
}

std::string getNextMonthDay(long nSeconds)
{
	NSDateComponents *comps = [[NSDateComponents alloc] init]; 
	
	NSInteger unitFlags = kCFCalendarUnitMonth | kCFCalendarUnitDay;
	[comps setMonth:1];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate dateWithTimeIntervalSince1970: nSeconds] options:0] ;
	
	[comps release];
	
	comps = [calendar components:unitFlags fromDate:date];
	NSString *ret = [NSString stringWithFormat:@"%d%s%d%s", 
					 [comps month],
					 NDCommonCString("month"),
					 [comps day],
					 NDCommonCString("day") ];	
	
	return [ret UTF8String];
}

static char COPY_DATA[1024] = {0X00};

const char* GetCopyCacheData()
{
	return COPY_DATA;
}

void CopyDataToCopyCache(const char* data)
{
	memset(COPY_DATA, 0x00, sizeof(COPY_DATA));
	if (strlen(data) < sizeof(COPY_DATA)) 
	{
		strcpy(COPY_DATA, data);
	}
	else 
	{
		memcpy(COPY_DATA, data, sizeof(COPY_DATA) - 1);
	}
}

std::string cutBytesToString(NSInputStream* stream, int iType)
{
	if (stream == nil)
	{
		return "";
	}
	
	[stream setProperty:[NSNumber numberWithInt:0] forKey:NSStreamFileCurrentOffsetKey];
	
	std::vector<unsigned short> vec;
	
	while ([stream hasBytesAvailable])
	{
		unsigned char byteBufL[1] = {0x00};
		unsigned char byteBufH[1] = {0x00};
		int readLen = [stream read:byteBufL maxLength:1];
		if ( !readLen ) 
		{
			break;
		}
		
		readLen = [stream read:byteBufH maxLength:1];
		if ( !readLen ) 
		{
			return std::string("");
		}
		
		unsigned short ch = (unsigned short) ((unsigned short)byteBufH[0] & 0xff | ((unsigned short)(byteBufL[0] & 0xff) << 8));
		
		if (ch != 9632) // '■' = 9632
		{
			if (iType == 1) 
			{
				vec.push_back(ch);
			} 
			else if (iType == 0)
			{
				break;
			}
		} 
		else 
		{
			iType--;
		}
	}
	
	if (vec.size())
	{
		NSString *tmp = [NSString stringWithCharacters:(const unichar *)&(vec[0]) length:vec.size()];
		return std::string([tmp UTF8String]);
	}
	
	return std::string("");
}

std::string loadPackInfo(int param)
{
	if (param == UPDATEURL)
	{
		return GetUpdateUrl();
	}
	else if (param != STRPARAM)
	{
		return "";
	}
	
	std::string channelIni = NDEngine::NDPath::GetResourcePath().append("channel.ini"); 
	FILE* f = fopen(channelIni.c_str(), "rt");
	
	if (!f) return "IPHONE_BYWX";
	
	char buf[1025] = { 0x00 };
	fgets(buf, 1024, f);
	fclose(f);
	
	char ret[1025] = { 0x00 };
	char* ptr = buf;
	char* ptr2 = ret;
	while (*ptr != '\0') 
	{
		if (*ptr == ',')
			break;
		*ptr2++ = *ptr++;
	}
	
	return ret;
}

std::string GetSoftVersion()
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist" inDirectory:nil];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if (dict)
	{
		NSString *version = [dict objectForKey:@"CFBundleVersion"];
		if (version)
			return [version UTF8String];
	}	
	return "1.0.0.0";
}

std::string GetIosVersion()
{
	NSMutableDictionary* configDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	if (configDict) 
	{
		NSString *version = [configDict objectForKey:@"ProductVersion"];
		if (version) 
			return [version UTF8String];
	}
	return "3.0";
}

std::string GetChannelInfo()
{
	std::string channelIni = NDEngine::NDPath::GetResourcePath().append("channel.ini"); 
	FILE* f = fopen(channelIni.c_str(), "rt");
	if (f) 
	{
		char buf[1025] = { 0x00 };
		fgets(buf, 1024, f);
		fclose(f);
		
		char ret[1025] = { 0x00 };
		char* ptr = buf;
		char* ptr2 = ret;
		while (*ptr != '\0') 
		{
			if (*ptr != ',') 
				*ptr2++ = *ptr++;
			else 
				break;
		}
		return ret;
	}
	return "";
}
std::string GetUpdateUrl()
{
	std::string channelIni = NDEngine::NDPath::GetResourcePath().append("channel.ini"); 
	FILE* f = fopen(channelIni.c_str(), "rt");
	if (f) 
	{
		char buf[1025] = { 0x00 };
		fgets(buf, 1024, f);
		fclose(f);
		
		char ret[1025] = { 0x00 };
		char* ptr = buf;
		char* ptr2 = ret;
		while (*ptr != '\0') 
		{
			if (*ptr++ == ',')
				break;
		}
		
		while ((*ptr2++ = *ptr++)); 
		
		return ret;
	}
	return "";
}

bool IsSupportPrecisionPic()
{
	static bool bfirstCall = true;
	static bool bSupport = false;
	
	if (!bfirstCall) return bSupport;
	
	switch ([[UIDevice currentDevice] platformType])
	{
		case UIDevice1GiPhone: bSupport = false;				//IPHONE_1G_NAMESTRING;
		case UIDevice3GiPhone: bSupport = false;				//IPHONE_3G_NAMESTRING;
		case UIDevice3GSiPhone:	bSupport = false;				//IPHONE_3GS_NAMESTRING;
		case UIDevice4iPhone:	bSupport = true;				//IPHONE_4_NAMESTRING;
		case UIDevice5iPhone:	bSupport = true;				//IPHONE_5_NAMESTRING;
		case UIDeviceUnknowniPhone: bSupport = false;			//IPHONE_UNKNOWN_NAMESTRING;
			
		case UIDevice1GiPod: bSupport = false;					//IPOD_1G_NAMESTRING;
		case UIDevice2GiPod: bSupport = false;					//IPOD_2G_NAMESTRING;
		case UIDevice3GiPod: bSupport = false;					//IPOD_3G_NAMESTRING;
		case UIDevice4GiPod: bSupport = false;					//IPOD_4G_NAMESTRING;
		case UIDeviceUnknowniPod: bSupport = false;				//IPOD_UNKNOWN_NAMESTRING;
			
		case UIDevice1GiPad : bSupport = false;					//IPAD_1G_NAMESTRING;
		case UIDevice2GiPad : bSupport = false;					//IPAD_2G_NAMESTRING;
			
		case UIDeviceAppleTV2 : bSupport = false;				//APPLETV_2G_NAMESTRING;
			
		case UIDeviceiPhoneSimulator: bSupport = false;			//IPHONE_SIMULATOR_NAMESTRING;
		case UIDeviceiPhoneSimulatoriPhone: bSupport = false;	//IPHONE_SIMULATOR_IPHONE_NAMESTRING;
		case UIDeviceiPhoneSimulatoriPad: bSupport = false;		//IPHONE_SIMULATOR_IPAD_NAMESTRING;
			
		case UIDeviceIFPGA: bSupport = false;					//IFPGA_NAMESTRING;
			
		default: bSupport = false;								//IPOD_FAMILY_UNKNOWN_DEVICE;
	}
	
	bfirstCall = false;
	
	return bSupport;
}

std::string platformString()
{
	return [[[UIDevice currentDevice] platformString] UTF8String];
}

void drawRectBar2(int x, int y, int color, int num1, int num2, int width) {
	int curColor = 0x0B2212;
	DrawPolygon(CGRectMake(x, y, width + 1, 5), INTCOLORTOCCC4(curColor), 1);
	
	if (num2 <= 0) {
		return;
	}
	
	int width1 = width * num1 / num2;
	if (num1 > num2) {
		width1 = width;
	}
	if (width1 == 0) {
		return;
	}
	DrawRecttangle(CGRectMake(x, y, width1, 4), INTCOLORTOCCC4(color));
}

CGRect getNewNumCut(unsigned int num, bool hightlight)
{
	if (num > 9) return CGRectZero;
	return CGRectMake(num*14, (hightlight ? 14 : 0), 14, 14);
}

void ShowAlert(const char* pszAlert)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NDCommonCString_RETNS("tip") message:[NSString stringWithUTF8String:pszAlert] delegate:nil cancelButtonTitle:NDCommonCString_RETNS("haode") otherButtonTitles:nil];
	[alert show];
	[alert release];
}

uint TimeConvert(TIME_TYPE type /*=TIME_MILLISECOND*/, time_t long_time)
{
	uint dwTime = 0;
	switch(type)
	{
		case TIME_SECOND:
			dwTime = long_time;
			break;
			
		case TIME_MINUTE:
		{
			struct tm *pTime;
			pTime = ::localtime( &long_time ); /* Convert to local time. */
			
			dwTime	=	pTime->tm_year%100*100000000 +
			(pTime->tm_mon+1)*1000000 +
			pTime->tm_mday*10000 +
			pTime->tm_hour*100 + 
			pTime->tm_min;
		}
			break;
			
		case TIME_HOUR:
		{
			struct tm *pTime;
			pTime = ::localtime( &long_time ); /* Convert to local time. */
			
			dwTime	=	pTime->tm_year*1000000 +
			(pTime->tm_mon+1)*10000 +
			pTime->tm_mday*100 +
			pTime->tm_hour;
		}
			break;
			
		case TIME_DAY:
		{
			struct tm *pTime;
			pTime = ::localtime( &long_time ); /* Convert to local time. */
			
			dwTime	=	pTime->tm_year*10000 +
			(pTime->tm_mon+1)*100 +
			pTime->tm_mday;
		}
			break;
			
		case TIME_DAYTIME: 
		{
			struct tm *pTime;
			pTime = ::localtime( &long_time ); /* Convert to local time. */
			
			dwTime	=	pTime->tm_hour*10000 + 
			pTime->tm_min *100 +
			pTime->tm_sec;
		}
			break;
			
		case TIME_STAMP: 
		{
			struct tm *pTime;
			pTime = ::localtime( &long_time ); /* Convert to local time. */
			
			dwTime	=	(pTime->tm_mon+1)*100000000 +
			pTime->tm_mday*1000000 +
			pTime->tm_hour*10000 + 
			pTime->tm_min *100 +
			pTime->tm_sec;
		}
			break;
			
		default:
			dwTime = long_time;
			break;
	}
	return dwTime;
}

std::string TimeConvertToStr(TIME_TYPE type, time_t long_time)
{	
	struct tm *pTime;
	pTime = ::localtime( &long_time );
	
	if (!pTime) return "";
	
	char szOut[256];
	
	memset(szOut, 0, sizeof(szOut));
	
	switch(type)
	{
		case TIME_SECOND:
			sprintf(szOut, "%d%s%d%s%d%s%d%s%d%s%d%s",
					pTime->tm_year,	NDCommonCString("year"),
					pTime->tm_mon,	NDCommonCString("month"),
					pTime->tm_mday,	NDCommonCString("day"),
					pTime->tm_hour,	NDCommonCString("hour"),
					pTime->tm_min,	NDCommonCString("minute"),
					pTime->tm_sec,	NDCommonCString("second"));
			break;
		case TIME_MINUTE:
		{
			sprintf(szOut, "%d%s%d%s%d%s%d%s%d%s",
					pTime->tm_year,	NDCommonCString("year"),
					pTime->tm_mon,	NDCommonCString("month"),
					pTime->tm_mday,	NDCommonCString("day"),
					pTime->tm_hour,	NDCommonCString("hour"),
					pTime->tm_min,	NDCommonCString("minute"));
		}
			break;
			
		case TIME_HOUR:
		{
			sprintf(szOut, "%d%s%d%s%d%s%d%s",
					pTime->tm_year,	NDCommonCString("year"),
					pTime->tm_mon,	NDCommonCString("month"),
					pTime->tm_mday,	NDCommonCString("day"),
					pTime->tm_hour,	NDCommonCString("hour"));
		}
			break;
			
		case TIME_DAY:
		{
			sprintf(szOut, "%d%s%d%s%d%s",
					pTime->tm_year,	NDCommonCString("year"),
					pTime->tm_mon,	NDCommonCString("month"),
					pTime->tm_mday,	NDCommonCString("day"));
		}
			break;
			
		case TIME_DAYTIME: 
		{
			sprintf(szOut, "%d%s%d%s%d%s",
					pTime->tm_hour,	NDCommonCString("hour"),
					pTime->tm_min,	NDCommonCString("minute"),
					pTime->tm_sec,	NDCommonCString("second")  );
		}
			break;
			
		case TIME_STAMP: 
		{
			sprintf(szOut, "%d%s%d%s%d%s%d%s%d%s",
					pTime->tm_mon,	NDCommonCString("month"),
					pTime->tm_mday,	NDCommonCString("day"),
					pTime->tm_hour,	NDCommonCString("hour"),
					pTime->tm_min,	NDCommonCString("minute"),
					pTime->tm_sec,	NDCommonCString("second"));
		}
			break;
			
		default:
			break;
	}

	return szOut;
}

NDLANGUAGE localNdLunguage = NDLANGUAGE_None; 

bool IsInSimplifiedChinese()
{
	if (localNdLunguage == NDLANGUAGE_None)
		GetLocalLanguage();
		
	return localNdLunguage == NDLANGUAGE_SimplifiedChinese;
}

bool IsTraditionalChinese()
{
	if (localNdLunguage == NDLANGUAGE_None)
		GetLocalLanguage();
	
	return localNdLunguage == NDLANGUAGE_TraditionalChinese;
}

NDLANGUAGE GetLocalLanguage()
{
	if (localNdLunguage != NDLANGUAGE_None)
		return localNdLunguage;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (defaults == nil)
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
		
		return localNdLunguage;
	}
	
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	
	if (languages == nil)
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
		
		return localNdLunguage;
	}
	
	NSString *currentLanguage = [languages objectAtIndex:0];
	
	if (currentLanguage == nil)
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
		
		return localNdLunguage;
	}
	
#ifdef DEBUG
	if ([currentLanguage isEqualToString:@"zh-Hans"])
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
	}
	else if ([currentLanguage isEqualToString:@"zh-Hant"])
	{
		localNdLunguage = NDLANGUAGE_TraditionalChinese;
	}
	else
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
	}
#else
	if ([currentLanguage isEqualToString:@"zh_Cn"])
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
	}
	else if ([currentLanguage isEqualToString:@"zh_TW"])
	{
		localNdLunguage = NDLANGUAGE_TraditionalChinese;
	}
	else
	{
		localNdLunguage = NDLANGUAGE_SimplifiedChinese;
	}
#endif
	
	return localNdLunguage;
}