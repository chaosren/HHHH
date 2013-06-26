/*
 *  NDDataPersist.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-12.
 *  Copyright 2011 ����(DeNA). All rights reserved.
 *
 */

#include "NDDataPersist.h"
#include "KDirectory.h"
#include "define.h"
#include "ItemMgr.h"
//#include <direct.h>
#include "tinyxml.h"
#include "XMLReader.h"
#include "ScriptMgr.h"
#include "ObjectTracker.h"
#include "StringConvert.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#endif

/*
 �򵥵ļ����㷨 
 add by xiezhenghai
 begin.....
 */

static const unsigned char codeKey[] = {0x57, 0xf3, 0xa4, 0x38, 0xc0, 0x88, 0x7b, 0xac};
void charToHex(unsigned char src, unsigned char *dest)
{
	int hi = src / 16;      //��λ
	int lo = src % 16;      //��λ
	
	if (hi >= 0 && hi <= 9) 
		*dest++ = '0' + hi;
	else 
		*dest++ = 'A' + hi - 10;
	
	if (lo >= 0 && lo <= 9) 
		*dest++ = '0' + lo;
	else 
		*dest++ = 'A' + lo - 10;
}

unsigned char hexToChar(const unsigned char *hex)
{
	int hi = 0;
	int lo = 0;

	if (*hex >= '0' && *hex <= '9') 
	{
		hi = (*hex++ - '0') * 16;
	}
	else 
	{
		hi = (*hex++ - 'A' + 10) * 16;
	}

	if (*hex >= '0' && *hex <= '9') 
	{
		lo = *hex++ - '0';
	}
	else 
	{
		lo = *hex++ - 'A' + 10;
	}
	return  (hi + lo);
}

void simpleEncode(const unsigned char *src, unsigned char *dest)
{
	int index = 0;
	while (*src) 
	{
		*dest = (*src >> 4) + (*src % 16 << 4);        //�ߵ�λ�Ե�
		*dest = *dest ^ codeKey[index++];              //�ߵ�λ�Ե���õ���ֵ���Ӧλ��Կȡ�������
		charToHex(*dest, dest);                        //�����ֵת����16������ʽ�ַ������
		
		index = index % sizeof(codeKey);               //index��ֵ����Կ��Χ���ظ���Ѳ		 
		dest = dest + 2;                               //��Ϊ16������ʽ��ֵ���������ַ�
		src++;
	}
}

void simpleDecode(const unsigned char *src, unsigned char *dest)
{
	int index = 0;
	while (*src) 
	{
		*dest = hexToChar(src);
		*dest = *dest ^ codeKey[index++];
		*dest = (*dest >> 4) + (*dest % 16 << 4);
		
		index = index % sizeof(codeKey);		
		src = src + 2;
		dest++;
	}
}
/*
 �򵥵ļ����㷨 
 add by xiezhenghai
 end......
 */

const size_t MAX_ACCOUNT = 10;

int NDDataPersist::ms_nGameSetting = 0xFFFFFFFF; // Ĭ��ȫ��

void NDDataPersist::LoadGameSetting()
{
	NDDataPersist gs;
	gs.SaveGameSetting();
}

NDDataPersist::NDDataPersist():
m_pkAccountList(0),
m_pkDataArray(0),
m_pkAccountDeviceList(0)
{
	INC_NDOBJ("NDDataPersist");

	this->LoadData();
	this->LoadAccountList();
	this->LoadAccountDeviceList();
}

NDDataPersist::~NDDataPersist()
{
	DEC_NDOBJ("NDDataPersist");

	SAFE_RELEASE(m_pkDataArray);
	SAFE_RELEASE(m_pkAccountList);
	SAFE_RELEASE(m_pkAccountDeviceList);

// 	[dataArray release];
// 	[accountList release];
// 	[accountDeviceList release];
}

bool NDDataPersist::NeedEncodeForKey(CCString* key)
{
	if (key->isEqual(kLastServerIP) ||
		key->isEqual(kLastServerPort) ||
		key->isEqual(kLastAccountName) ||
		key->isEqual(kLastAccountPwd))
	{
		return true;
	}
	else
	{
		return false;
	}
}

void NDDataPersist::SetData(unsigned int index, CCString* key, const char* data)
{
	if (!key || !data) return;

	//CCMutableDictionary<const char*>* dic = LoadDataDiction(index);
	CCDictionary* dic = LoadDataDiction(index);

	NDAsssert(dic != nil);

	CCString* nsObj = CCString::stringWithCString( CONVERT_UTF8_TO_GBK( data ));
	
	if (NeedEncodeForKey(key)) 
	{
		unsigned char encData[1024] = {0x00};
		simpleEncode((const unsigned char*)data, encData);

		CCString* nsObj = CCString::stringWithCString( CONVERT_UTF8_TO_GBK((const char*)encData ));
	}
	
	//[dic setObject:nsObj forKey:key];
	dic->setObject(nsObj,key->getCString());
}

const char* NDDataPersist::GetData(unsigned int index, CCString* key)
{
	static char decData[1024] = {0};
	memset(decData, 0x00, sizeof(decData));
	
	//CCMutableDictionary<const char*>* dic = LoadDataDiction(index);
	CCDictionary* dic = LoadDataDiction(index);
	NDAsssert(dic != nil);

	CCString* str = (CCString*)dic->objectForKey(key->getCString());

	if (str == NULL) // ��ֵ�Բ�����, ����
	{ 
		SetData(index, key, "");
		return decData;
	}

	if (NeedEncodeForKey(key)) 
	{
		simpleDecode(
			(const unsigned char*) CONVERT_GBK_TO_UTF8(str->getCString()), //@todo:androidת��������.
			(unsigned char*)decData);

		return decData;
	}
	else 
	{
		return str->getCString();
	}
}

void NDDataPersist::SaveData()
{
//	[dataArray writeToFile:this->GetDataPath() atomically:YES];
	//dataArray->writeToFile(GetDataPath(),YES);
}

void NDDataPersist::SaveLoginData()
{
	this->SaveData();
}

//CCMutableDictionary<const char*>* NDDataPersist::LoadDataDiction(unsigned int index)
CCDictionary* NDDataPersist::LoadDataDiction(unsigned int index)
{
	NDAsssert(m_pkDataArray != nil);
	
	//CCMutableDictionary<const char*>* dic = nil;
	CCDictionary* dic = nil;
	
	if (m_pkDataArray->count() > index)
	{
		//dic = (CCMutableDictionary<const char*>*)m_pkDataArray->getObjectAtIndex(index);
		dic = (CCDictionary*)m_pkDataArray->objectAtIndex(index);
	}
	
	if (dic == nil)
	{ // ���ݲ�����,��ʼ��
		for (unsigned int i = m_pkDataArray->count(); i <= index; i++) 
		{
			//dic = new CCMutableDictionary<const char*>;
			dic = new CCDictionary();
			m_pkDataArray->insertObject(dic,i);
			SAFE_DELETE(dic);
// 			[dataArray insertObject:dic atIndex:i];
// 			[dic release];
		}
	}
	
	return dic;
}

void NDDataPersist::LoadData()
{
 	CCStringRef filePath = this->GetDataPath();

	XMLReader kReader;

	m_pkDataArray = new CCArray();
	
	if (!kReader.initWithFile(filePath->getCString()))
	{
		return;
	}

	XMLReader::FileDataPtr pkMap = kReader.getMapWithContentsOfFile();

	if (0 == pkMap)
	{
		return;
	}
	
	for (XMLReader::FileData::iterator it = pkMap->begin();
		it != pkMap->end();it++)
	{
		CCDictionary* pkDic =  new CCDictionary();

		string strKey = "";
		string strVal = "";
		
		strKey = it->first;
		strVal = it->second;

		pkDic->setObject(new CCString(strVal.c_str()), strKey);

		m_pkDataArray->addObject(pkDic);
	}
}

CCString* NDDataPersist::GetDataPath()
{
//	NSString dir = [kDataFileName stringByDeletingLastPathComponent];

	// 	NSString dir = new CCString("");
	// 
	// 	if (!KDirectory::isDirectoryExist(dir->toStdString().c_str())) 
	// 	{
	// 		if (!KDirectory::createDir(dir->toStdString().c_str()))
	// 		{
	// 			return nil;
	// 		}
	// 	}


	return pkDataFileName;
//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
//							     NSDocumentDirectory, NSUserDomainMask, YES); 
//	NSString *documentsDirectory = [paths objectAtIndex:0]; 
//	return [documentsDirectory stringByAppendingPathComponent:kDataFileName];
}

CCString* NDDataPersist::GetAccountListPath()
{
	return new CCString("");
}

void NDDataPersist::LoadAccountList()
{
}

void NDDataPersist::AddAcount(const char* account, const char* pwd)
{	
	if (account) 
	{
		unsigned char encAccount[1024] = {0x00};
		simpleEncode((const unsigned char*)account, encAccount);
		
		//CCMutableArray<CCObject*>* accountNode = new CCMutableArray<CCObject*>;
		CCArray* accountNode = new CCArray();

		accountNode->addObject(new CCString((const char*)encAccount));
		//[accountNode addObject:[NSString stringWithUTF8String:(const char*)encAccount]];
		
		if (pwd)
		{
			unsigned char encPwd[1024] = {0x00};
			simpleEncode((const unsigned char*)pwd, encPwd);
			//[accountNode addObject:[NSString stringWithUTF8String:(const char*)encPwd]];

			accountNode->addObject(new CCString((const char*)encPwd));
		}
		
		for (int i = 0; i < m_pkAccountList->count(); i++) 
		{
			CCArray* tmpAccountNode = (CCArray*)m_pkAccountList->objectAtIndex(i);
			CCStringRef tmpAccount = (CCString*)tmpAccountNode->objectAtIndex(0);

			if (tmpAccount->isEqual(new CCString((const char*) encAccount)))
			{
				m_pkAccountList->removeObject(tmpAccount);
			}

// 			if ([tmpAccount isEqual:[NSString stringWithUTF8String:(const char*)encAccount]]) 
// 			{
// 				[accountList removeObject:tmpAccountNode];
// 				break;
// 			}
		}
		
		if (m_pkAccountList->count() >= MAX_ACCOUNT) 
		{
			//[accountList removeObjectAtIndex:0];
			m_pkAccountList->removeObjectAtIndex(0);
		}
		
		m_pkAccountList->addObject(accountNode);
		//[accountList addObject:accountNode];
		
		accountNode->release();
	}	
}

void NDDataPersist::GetAccount(VEC_ACCOUNT& vAccount)
{
	vAccount.clear();
	
// 	NSEnumerator *enumerator;
// 	enumerator = [accountList objectEnumerator];
	
	CCArray* account = 0;

	for (int i = 0;i < m_pkAccountList->count();i++)
	{
		account = (CCArray*)m_pkAccountList->objectAtIndex(i);
		CCString* acc = (CCString*)account->objectAtIndex(0);
		CCString* pwd = 0;

		if (account->count() > 1)
		{
			pwd = (CCString*)account->objectAtIndex(1);
		}

		unsigned char decAcc[1024] = {0x00};
		unsigned char decPwd[1024] = {0x00};

		simpleDecode((const unsigned char*)acc->getCString(), decAcc);
		simpleDecode((const unsigned char*)pwd->getCString(), decPwd);

		vAccount.push_back(PAIR_ACCOUNT((const char*)decAcc, (const char*)decPwd));
	}

	/***
	* objective-c�ľɴ���
	* �ѱ��滻 ����
	*/
// 	while ((account = accountList->) != nil)
// 	{
// 		string acc = [(NSString)[(NSArray*)account objectAtIndex:0] UTF8String];
// 		string pwd;
// 		if ([account count] > 1) 
// 		{
// 			pwd = [(NSString)[(NSArray*)account objectAtIndex:1] UTF8String];
// 		}
// 		
// 		unsigned char decAcc[1024] = {0x00};
// 		unsigned char decPwd[1024] = {0x00};
// 		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
// 		simpleDecode((const unsigned char*)pwd.c_str(), decPwd);
// 		vAccount.push_back(PAIR_ACCOUNT((const char*)decAcc, (const char*)decPwd));
// 	}
}

void NDDataPersist::SaveAccountList()
{
//	[accountList writeToFile:this->GetAccountListPath() atomically:YES];
	m_pkAccountList->writeToFile(GetAccountListPath(),YES);
}

CCString* NDDataPersist::GetAccountDeviceListPath()
{
	return 0;
}

void NDDataPersist::LoadAccountDeviceList()
{
	CCStringRef filePath = GetAccountDeviceListPath();

	/***
	* ����Ϊ�ɴ��� ����
	*/
// 	NSString *filePath = this->GetAccountDeviceListPath();
// 	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
// 	{ 
// 		accountDeviceList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
// 	}
// 	else
// 	{
// 		accountDeviceList = [[NSMutableArray alloc] init];
// 	}	
}

void NDDataPersist::AddAccountDevice(const char* account)
{	
	if (account) 
	{
		unsigned char encAccount[1024] = {0x00};
		simpleEncode((const unsigned char*)account, encAccount);
		
		for (NSUInteger i = 0; i < m_pkAccountList->count(); i++) 
		{
			CCString* tmpAccountNode = (CCString*)m_pkAccountList->objectAtIndex(i);
			if (!tmpAccountNode) continue;

			CCString* strAccount = CCString::stringWithCString( CONVERT_UTF8_TO_GBK( (const char*)encAccount ));
			if (tmpAccountNode->isEqual( strAccount ))
			{
				return;
			}
		}
		
		CCString* str = CCString::stringWithCString( CONVERT_UTF8_TO_GBK((const char*)encAccount));
		m_pkAccountDeviceList->addObject( str );
	}	
}

#if 0
bool NDDataPersist::HasAccountDevice(const char* account)
{
	/***
	* �ɴ��� ����
	*/

	if (!account)
	{
		return true;
	}
	
	CCStringRef tmpAccountNode = CCString::stringWithUTF8String(account);

// 	NSEnumerator *enumerator;
// 	enumerator = [accountDeviceList objectEnumerator];
// 	
// 	NSString tmpAccountNode = [NSString stringWithUTF8String:account];
	
	id object = 0;

	for (int i = 0;i < m_pkAccountDeviceList->count();i++)
	{
		string acc = ((CCString*)m_pkAccountDeviceList->objectAtIndex(i))->getUtf8String();
		unsigned char decAcc[1024] = {0};

		simpleDecode((const unsigned char*)acc.c_str(),decAcc);

		CCStringRef strRef = CCString::stringWithUTF8String((const char*)decAcc);
		if (tmpAccountNode->isEqual( strRef ))
		{
			return true;
		}
	}

// 	while ((object = [enumerator nextObject]) != nil)
// 	{
// 		string acc = [(NSString)object UTF8String];
// 		
// 		unsigned char decAcc[1024] = {0x00};
// 		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
// 		
// 		if ([tmpAccountNode isEqual:[NSString stringWithUTF8String:(const char*)decAcc]]) 
// 		{
// 			return true;
// 		}
// 	}
	
	return false;
}
#endif

void NDDataPersist::SaveAccountDeviceList()
{
	//[accountDeviceList writeToFile:this->GetAccountDeviceListPath() atomically:YES];
}

void NDDataPersist::SetGameSetting(GAME_SETTING type, bool bOn)
{
	if (bOn) 
	{
		ms_nGameSetting |= type;
	} 
	else
	{
		ms_nGameSetting &= ~type;
	}
}

bool NDDataPersist::IsGameSettingOn(GAME_SETTING type)
{
	return NDDataPersist::ms_nGameSetting & type;
}

void NDDataPersist::SaveGameSetting()
{
	CCString* strGameSetting = CCString::stringWithFormat("%d",ms_nGameSetting);
	SetData( kGameSettingData, strGameSetting, CONVERT_GBK_TO_UTF8(strGameSetting->getCString()));//@todo:androidת��������.
	SaveData();

	/***
	* ����Ϊ�ɴ��� ����
	*/
// 	NSString strGameSetting = [NSString stringWithFormat:@"%d", s_gameSetting];
// 	this->SetData(kGameSettingData, kGameSetting, [strGameSetting UTF8String]);
// 	this->SaveData();
}

///////////////////////////////////////
//�ʼ�����plist

const NSUInteger max_player_save_count = 5;
const NSUInteger max_mail_save_count = 20;

//NDEmailDataPersist* NDEmailDataPersist::s_intance = NULL;
//
//NDEmailDataPersist::NDEmailDataPersist()
//{
//	NDAsssert(s_intance == NULL);
//	LoadEmailData();
//}
//
//NDEmailDataPersist::~NDEmailDataPersist()
//{
//	SaveEmailData();
//	
//	if (emailArray) 
//	{
//		[emailArray release];
//		emailArray = nil;
//	}
//}
//
//NDEmailDataPersist& NDEmailDataPersist::DefaultInstance()
//{
//	if (s_intance == NULL) 
//	{
//		s_intance =  new NDEmailDataPersist;
//	}
//	
//	return *s_intance;
//}
//
//void NDEmailDataPersist::Destroy()
//{
//	if (s_intance != NULL) 
//	{
//		delete s_intance;
//		s_intance = NULL;
//	}
//}
//
//string NDEmailDataPersist::GetEmailState(int playerid,string mail)
//{
//	if (mail.empty()) 
//	{
//		return "";
//	}
//	
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
//	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
//	if (playermail == nil) {
//		return "";
//	}
//	
//	NSString *nsStr= [playermail objectForKey:[NSString stringWithUTF8String:mail.c_str()]];
//	if (nsStr == nil) {
//		return "";
//	}
//	
//	return [nsStr UTF8String];
//}
//
//void NDEmailDataPersist::AddEmail(int playerid,string mail, string state)
//{
//	if (mail.empty()) 
//	{
//		return;
//	}
//	
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
//	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
//	if (playermail == nil) {
//		if ([dic count] > max_player_save_count) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				
//				[dic removeObjectForKey:key];
//				break;
//			}
//			
//		}
//		playermail = [[NSMutableDictionary alloc] init];
//		[dic setObject:playermail forKey:strPlayer];
//		[playermail release];
//	}
//	
//	if ([playermail count] > max_mail_save_count) {
//		NSEnumerator *enumerator;
//		enumerator = [playermail keyEnumerator];
//		id key;
//		while ((key = [enumerator nextObject]) != nil) {
//			
//			[playermail removeObjectForKey:key];
//			break;
//		}
//		
//	}
//	
//	[playermail setObject:[NSString stringWithUTF8String:state.c_str()]
//				forKey:[NSString stringWithUTF8String:mail.c_str()]];
//
//}
//
//void NDEmailDataPersist::DelEmail(int playerid,string mail)
//{
//	if (mail.empty()) 
//	{
//		return;
//	}
//	
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
//	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
//	if (playermail == nil) {
//		return;
//	}
//	
//	[playermail removeObjectForKey:[NSString stringWithUTF8String:mail.c_str()]];
//}
//
//void NDEmailDataPersist::LoadEmailData()
//{
//	NSString filePath = GetEmailPath();
//	if (!filePath) 
//	{
//		emailArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		emailArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		emailArray = [[NSMutableArray alloc] init];
//	}
//	
//}
//
//void NDEmailDataPersist::SaveEmailData()
//{
//	NSString filePath = GetEmailPath();
//	if (filePath) 
//	{
//		[emailArray writeToFile:filePath atomically:YES];
//	}
//	
//	[emailArray release];
//	emailArray = nil;
//}
//
//NSString NDEmailDataPersist::GetEmailPath()
//{
//	NSString dir = [kEmailFileName stringByDeletingLastPathComponent] ;
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	return kEmailFileName;
////	if (!file) 
////	{
////		return nil;
////	}
////	
////	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
////														 NSDocumentDirectory, NSUserDomainMask, YES); 
////	NSString *documentsDirectory = [paths objectAtIndex:0]; 
////	return [documentsDirectory stringByAppendingPathComponent:file];
//}
//
//NSMutableDictionary* NDEmailDataPersist::LoadMailDiction()
//{
//	NDAsssert(emailArray != nil);
//	
//	NSMutableDictionary* dic = nil;
//	
//	if ([emailArray count] > 0) {
//		NDAsssert([emailArray count] == 1);
//		dic = (NSMutableDictionary*)[emailArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // ���ݲ�����,��ʼ��
//			dic = [[NSMutableDictionary alloc] init];
//			[emailArray addObject:dic];
//			[dic release];
//	}
//	
//	return dic;
//}

//quick talk data

//NDQuickTalkDataPersist::NDQuickTalkDataPersist()
//{
//	this->LoadQuickTalkData();
//}
//
//NDQuickTalkDataPersist::~NDQuickTalkDataPersist()
//{
//	this->SaveQuickTalkData();
//	[quickTalkArray release];
//}
//
//NDQuickTalkDataPersist& NDQuickTalkDataPersist::DefaultInstance()
//{
//	static NDQuickTalkDataPersist obj;
//	return obj;
//}
//
//void NDQuickTalkDataPersist::GetAllQuickTalkString(int idPlayer, vector<string>& vMsg)
//{
//	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
//	
//	// û�и���ҵĿ�������¼���½�
//	if (arrMsg == nil) {
//		if ([dic count] >= QT_MAX_PLAYER_SAVE_NUM) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				[dic removeObjectForKey:key];
//				break;
//			}
//		}
//		
//		arrMsg = [[NSMutableArray alloc] initWithObjects:
//				  kSysQuickTalk1, kSysQuickTalk2, kSysQuickTalk3, kSysQuickTalk4, kSysQuickTalk5, 
//				  @"", @"", @"", @"", @"", 
//				  nil];
//		
//		[dic setObject:arrMsg forKey:strPlayer];
//		[arrMsg release];
//		
//		this->SaveQuickTalkData();
//	}
//	
//	for (NSUInteger i = 0; i < [arrMsg count]; i++) {
//		NSString msg = (NSString)[arrMsg objectAtIndex:i];
//		vMsg.push_back(string([msg UTF8String]));
//	}
//}
//
//string NDQuickTalkDataPersist::GetQuickTalkString(int idPlayer, uint uIdx)
//{
//	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
//	
//	string str;
//	
//	if (uIdx < [arrMsg count]) {
//		str = [(NSString)[arrMsg objectAtIndex:uIdx] UTF8String];
//	}
//	
//	return str;
//}
//
//void NDQuickTalkDataPersist::SetQuickTalkString(int idPlayer, uint uIdx, const string& msg)
//{
//	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
//	if (uIdx < [arrMsg count]) {
//		[arrMsg replaceObjectAtIndex:uIdx withObject:[NSString stringWithUTF8String:msg.c_str()]];
//		this->SaveQuickTalkData();
//	}
//}
//
//void NDQuickTalkDataPersist::LoadQuickTalkData()
//{
//	NSString filePath = this->GetQuickTalkPath();
//	if (!filePath) 
//	{
//		quickTalkArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		quickTalkArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		quickTalkArray = [[NSMutableArray alloc] init];
//	}
//}
//
//void NDQuickTalkDataPersist::SaveQuickTalkData()
//{
//	NSString filePath = this->GetQuickTalkPath();
//	if (filePath) 
//	{
//		[quickTalkArray writeToFile:filePath atomically:YES];
//	}
//}
//
//NSString NDQuickTalkDataPersist::GetQuickTalkPath()
//{
//	NSString dir = [kQuickTalkFileName stringByDeletingLastPathComponent] ;
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	return kQuickTalkFileName;
//}
//
//NSMutableDictionary* NDQuickTalkDataPersist::LoadQuickTalkDiction()
//{
//	NSMutableDictionary* dic = nil;
//	
//	if ([quickTalkArray count] > 0) {
//		NDAsssert([quickTalkArray count] == 1);
//		dic = (NSMutableDictionary*)[quickTalkArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // ���ݲ�����,��ʼ��
//		dic = [[NSMutableDictionary alloc] init];
//		[quickTalkArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//// ��Ʒ������
//// ѭ��λ�ƣ�������Ʒid����
//unsigned int _rotl(unsigned int value, int shift) {
//	if ((shift &= 31) == 0) {
//		return value;
//	}
//	return (value << shift) | (value >> (32 - shift));
//}
//
//unsigned int _rotr(unsigned int value, int shift) {
//	if ((shift &= 31) == 0) {
//		return value;
//	}
//	return (value >> shift) | (value << (32 - shift));
//}
//
//NDItemBarDataPersist::NDItemBarDataPersist()
//{
//	this->LoadData();
//}
//
//NDItemBarDataPersist::~NDItemBarDataPersist()
//{
//	this->SaveData();
//	[itemBarArray release];
//}
//
//NDItemBarDataPersist& NDItemBarDataPersist::DefaultInstance()
//{
//	static NDItemBarDataPersist obj;
//	return obj;
//}
//
//void NDItemBarDataPersist::GetItemBarConfigInBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo)
//{
//	NSMutableDictionary* dic = this->LoadDictionInBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	// û�и���ҵ���Ʒ����¼���½�
//	if (arr == nil) {
//		if ([dic count] >= IB_MAX_PLAYER_SAVE_NUM) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				[dic removeObjectForKey:key];
//				break;
//			}
//		}
//		
//		arr = [[NSMutableArray alloc] init];
//		
//		for (NSUInteger i = 0; i < IB_MAX_ITEM_NUM; i++) {
//			[arr addObject:[NSNumber numberWithInt:0]];
//		}
//		
//		[dic setObject:arr forKey:strPlayer];
//		[arr release];
//		
//		this->SaveData();
//	}
//	
//	for (NSUInteger i = 0; i < [arr count]; i++) {
//		NSNumber* num = (NSNumber*)[arr objectAtIndex:i];
//		int idItemType = _rotl([num unsignedIntValue], kIDShift);
//		if (idItemType >= 0) {
//			vCellInfo.push_back(ItemBarCellInfo(idItemType, i));
//		}
//	}
//}
//
//void NDItemBarDataPersist::GetItemBarConfigOutBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo)
//{
//	NSMutableDictionary* dic = this->LoadDictionOutBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	// û�и���ҵ���Ʒ����¼���½�
//	if (arr == nil) {
//		if ([dic count] >= IB_MAX_PLAYER_SAVE_NUM) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				[dic removeObjectForKey:key];
//				break;
//			}
//		}
//		
//		arr = [[NSMutableArray alloc] init];
//		
//		for (NSUInteger i = 0; i < IB_MAX_ITEM_NUM_OUT_BATTLE; i++) {
//			[arr addObject:[NSNumber numberWithInt:0]];
//		}
//		
//		[dic setObject:arr forKey:strPlayer];
//		[arr release];
//		
//		this->SaveData();
//	}
//	
//	if ([arr count] < IB_MAX_ITEM_NUM_OUT_BATTLE)
//	{
//		NSUInteger i = [arr count];
//		for (; i < IB_MAX_ITEM_NUM_OUT_BATTLE; i++) {
//			[arr addObject:[NSNumber numberWithInt:0]];
//		}
//		
//		this->SaveData();
//	}
//	
//	for (NSUInteger i = 0; i < [arr count]; i++) {
//		NSNumber* num = (NSNumber*)[arr objectAtIndex:i];
//		int idItemType = _rotl([num unsignedIntValue], kIDShift);
//		if (idItemType >= 0) {
//			vCellInfo.push_back(ItemBarCellInfo(idItemType, i));
//		}
//	}
//}
//
//void NDItemBarDataPersist::SetItemAtIndexInBattle(int idPlayer, uint uIdx, int idItemtype)
//{
//	NSMutableDictionary* dic = this->LoadDictionInBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	if (uIdx < [arr count]) {
//		[arr replaceObjectAtIndex:uIdx withObject:[NSNumber numberWithInt:_rotr(idItemtype, kIDShift)]];
//		this->SaveData();
//	}
//}
//
//void NDItemBarDataPersist::SetItemAtIndexOutBattle(int idPlayer, uint uIdx, int idItemtype)
//{
//	NSMutableDictionary* dic = this->LoadDictionOutBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	if (uIdx < [arr count]) {
//		[arr replaceObjectAtIndex:uIdx withObject:[NSNumber numberWithInt:_rotr(idItemtype, kIDShift)]];
//		this->SaveData();
//	}
//}
//
//void NDItemBarDataPersist::LoadData()
//{
//	NSString filePath = this->GetPath();
//	if (!filePath) 
//	{
//		itemBarArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		itemBarArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		itemBarArray = [[NSMutableArray alloc] init];
//	}
//}
//
//void NDItemBarDataPersist::SaveData()
//{
//	NSString filePath = this->GetPath();
//	if (filePath) 
//	{
//		[itemBarArray writeToFile:filePath atomically:YES];
//	}
//}
//
//NSString NDItemBarDataPersist::GetPath()
//{
//	NSString dir = [kItemBarFileName stringByDeletingLastPathComponent];
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	return kItemBarFileName;
//}
//
//NSMutableDictionary* NDItemBarDataPersist::LoadDictionOutBattle()
//{
//	NSMutableDictionary* dic = nil;
//	
//	if ([itemBarArray count] > 0) {
//		dic = (NSMutableDictionary*)[itemBarArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // ���ݲ�����,��ʼ��
//		dic = [[NSMutableDictionary alloc] init];
//		[itemBarArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//NSMutableDictionary* NDItemBarDataPersist::LoadDictionInBattle()
//{
//	this->LoadDictionOutBattle();
//	
//	NSMutableDictionary* dic = nil;
//	
//	if ([itemBarArray count] > 1) {
//		dic = (NSMutableDictionary*)[itemBarArray objectAtIndex:1];
//	}
//	
//	if (dic == nil) { // ���ݲ�����,��ʼ��
//		NDAsssert([itemBarArray count] == 1);
//		dic = [[NSMutableDictionary alloc] init];
//		[itemBarArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//
//#pragma mark plist ��������
////ͨ��LoadMailDiction���û�ȡ�����ֵ�,�����ֵ�ɼ���object-c���ݶ���,���ݱ���������ڹ������������Զ����
//
//NDDataPlistBasic::NDDataPlistBasic(string filename)
//{
//	dataArray = nil;
//	
//	m_filename = filename;
//	
//	LoadData();
//}
//
//NDDataPlistBasic::~NDDataPlistBasic()
//{
//	SaveData();
//	
//	[dataArray release];
//	dataArray = nil;
//}
//
//NSString NDDataPlistBasic::GetPath(string filename)
//{
//	NSString name = [NSString stringWithFormat:@"%@%s.plist", DataFilePath(), filename.c_str()];
//	NSString dir = [name stringByDeletingLastPathComponent] ;
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	
//	return name;
//}
//
//void NDDataPlistBasic::LoadData()
//{
//	NSString filePath = GetPath(m_filename);
//	if (!filePath) 
//	{
//		dataArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		dataArray = [[NSMutableArray alloc] init];
//	}
//}
//
//void NDDataPlistBasic::SaveData()
//{
//	NSString filePath = GetPath(m_filename);
//	if (filePath && dataArray) 
//	{
//		[dataArray writeToFile:filePath atomically:YES];
//	}
//}
//
//NSMutableDictionary* NDDataPlistBasic::LoadMailDiction()
//{
//	NDAsssert(dataArray != nil);
//	
//	NSMutableDictionary* dic = nil;
//	
//	if ([dataArray count] > 0) {
//		NDAsssert([dataArray count] == 1);
//		dic = (NSMutableDictionary*)[dataArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // ���ݲ�����,��ʼ��
//		dic = [[NSMutableDictionary alloc] init];
//		[dataArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//
//#pragma mark ����ύbug
//// NDQuestionDataPlist���𱣴������������(���ÿ�������10������)
//#define MAX_QUEST_BUG_COUNT_PER_DAY (10)
//#define PER_DAY_SECOND (3600 * 24)
//
//NDQuestionDataPlist::NDQuestionDataPlist() : 
//NDDataPlistBasic("questbug")
//{
//}
//
//NDQuestionDataPlist::~NDQuestionDataPlist()
//{
//}
//
//bool NDQuestionDataPlist::CanPlayerQuestCurrentDay(int playerId)
//{
//	return !IsOverCount(GetPlayerCurQuestCount(playerId));
//}
//
//void NDQuestionDataPlist::AddPlayerQuest(int playerId)
//{
//	IncPlayerQuestCount(playerId);
//}
//
//int NDQuestionDataPlist::GetPlayerCurTime(int playerId)
//{
//	NSMutableArray* quest = GetQuestData(playerId);
//	
//	if (quest == nil) return 0;
//	
//	NSNumber *num = [quest objectAtIndex:0];
//	
//	if (!num) return 0;
//	
//	return [num floatValue];
//}
//
//bool NDQuestionDataPlist::IsOverTime(double time)
//{
//	double cur = [NSDate timeIntervalSinceReferenceDate];
//	if ( int(cur - time) > PER_DAY_SECOND)
//		return true;
//		
//	return false;
//}
//
//int NDQuestionDataPlist::GetPlayerCurQuestCount(int playerId)
//{
//	NSMutableArray* quest = GetQuestData(playerId);
//	
//	if (quest == nil) return 0;
//	
//	NSNumber *num = [quest objectAtIndex:1];
//	
//	if (!num) return 0;
//	
//	return [num intValue];
//}
//
//bool NDQuestionDataPlist::IsOverCount(int count)
//{
//	if (count >= MAX_QUEST_BUG_COUNT_PER_DAY)
//		return true;
//		
//	return false;
//}
//
//NSMutableArray* NDQuestionDataPlist::GetQuestData(int playerId)
//{
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerId];
//	NSMutableArray *playerQuest = [dic objectForKey:strPlayer];
//	
//	if (playerQuest == nil) {
//		NSMutableArray *quest = [[NSMutableArray alloc] init];
//		[quest addObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]]];
//		[quest addObject:[NSNumber numberWithInt:0]];
//		
//		[dic setObject:quest forKey:strPlayer];
//		
//		[quest release];
//	}
//	
//	playerQuest = [dic objectForKey:strPlayer];
//	
//	NSNumber *num = [playerQuest objectAtIndex:0];
//	
//	if (IsOverTime([num doubleValue]))
//	{
//		ResetPlayerQuest(playerId);
//	}
//	
//	return [dic objectForKey:strPlayer];
//}
//
//void NDQuestionDataPlist::ResetPlayerQuest(int playerId)
//{
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerId];
//	NSMutableArray *playerQuest = [dic objectForKey:strPlayer];
//	
//	if (playerQuest != nil) {
//		[dic removeObjectForKey:strPlayer];
//		
//		GetQuestData(playerId);
//	}
//}
//
//void NDQuestionDataPlist::IncPlayerQuestCount(int playerId)
//{
//	NSMutableArray* quest = GetQuestData(playerId);
//	
//	if (quest == nil) return;
//	
//	NSNumber *num = [quest objectAtIndex:1];
//	
//	if (num == nil)
//		return;
//	
//	[quest replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[num intValue]+1]];
//	
//	this->SaveData();
//}
//
