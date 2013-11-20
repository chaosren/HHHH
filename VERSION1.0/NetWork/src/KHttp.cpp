#include "KHttp.h"
#include "KTcpClientSocket.h"
#include "kathy.h"
#include "KFile.h"
#include "KCondition.h"
#include "cpLog.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

const static int MTU = 1500;
const KData CRLF = "\r\n";
const KData SP = " ";

KHttp::KHttp() :
m_iContentLength(0),
m_iNotifyPercent(0),
m_iNotifyPos(0)
{
	m_pNotifyCallback = NULL;
	m_pNotifyParam = NULL;
	m_bChunked = false;
	m_bPause = false;
	m_timeout = -1;
	m_iReadedBytes = 0;
	m_iWritedBytes = 0;
	m_iServerPort = 80; //�˿�Ĭ��Ϊ80
	m_bWriteBufFlag = false; 
	m_pWriteBuf = NULL;
}

KHttp::~KHttp()
{

}

void KHttp::setTimeout(long timeout)
{
	m_timeout = timeout;
}

void KHttp::setHttpProxy(const KData& proxy)
{
	//cpLog(LOG_DEBUG, "VHttp set http proxy: %s", proxy.getData());
	m_dtHttpProxy = proxy;
}

void KHttp::clear()
{
	m_iContentLength = 0;
	m_iStatusCode = 0;
	m_iNotifyPercent = 0;
	m_iNotifyGap = 0;
	m_iNotifyPos = 0;
}

void KHttp::setCookie(KData cookie)
{
	m_dtCookie = cookie;
}

int KHttp::getStatusCode() const
{
	return m_iStatusCode;
}

int KHttp::getContentLength() const
{
	return m_iContentLength;
}

void KHttp::setNotifyCallback(NotifyCallback callback, void* param, int percent)
{
	m_pNotifyCallback = callback;
	m_pNotifyParam = param;
	m_iNotifyPercent = percent;
}

void Trim(string &strString)
{
	int nStart = strString.find_first_not_of(" \t");
	int nEnd = strString.find_last_not_of(" \t");
	strString = strString.substr(nStart,nEnd - nStart + 1);
}

//��������
void  KHttp::ParseParam(KData &dPathData)
{	   
	KData kTempData = dPathData;
	int nPos = kTempData.find("?");
	if (nPos == -1)
	{
		return;
	}

	//������·���Լ�������
	dPathData = kTempData.substr(0, nPos);
	m_dtParam = kTempData.substr(nPos + 1);
}

unsigned char KHttp::ToHex(unsigned char x)   
{   
    return  x > 9 ? x + 55 : x + 48;   
} 

std::string KHttp::UrlEncode(const std::string& str)  
{  
	std::string strTemp = "";  
	size_t length = str.length();  
	for (size_t i = 0; i < length; i++)  
	{  
		if (isalnum((unsigned char)str[i]) ||   
			(str[i] == '-') ||  
			(str[i] == '_') ||   
			(str[i] == '.') ||   
			(str[i] == '~'))  
			strTemp += str[i];  
		else if (str[i] == ' ')  
			strTemp += "+";  
		else  
		{  
			strTemp += '%';  
			strTemp += ToHex((unsigned char)str[i] >> 4);  
			strTemp += ToHex((unsigned char)str[i] % 16);  
		}  
	}  
	return strTemp;  
}

int KHttp::getHttpFile( const KData& fullUrl, char*& saveBuf)
{
	string strPath = fullUrl;
	Trim(strPath);
	KData dtServer;
	KData dtFile;
	KData kDTFullUrl = strPath;
	KData dtTemp;
	m_bWriteBufFlag	= true;
	m_pWriteBuf = saveBuf;
	KData dAdd = "/";

	LOGD("kDTFullUrl is %s",kDTFullUrl.getDataBuf());

	if (isEqualNoCase(kDTFullUrl.substr(0, 7), "http://"))
	{
		kDTFullUrl = kDTFullUrl.substr(7);
	}

	int nPos = kDTFullUrl.find("/");

	if (nPos == -1)
	{
		LOGERROR("nPos = -1");
		return 0;
	}
	else
	{
		dtTemp = kDTFullUrl.substr(0, nPos);
		int nPortPos = dtTemp.find(":");
		if (nPortPos != -1)
		{
			dtServer = dtTemp.substr(0, nPortPos);
			m_iServerPort = int(dtTemp.substr(nPortPos + 1));

		}
		else
		{
			dtServer = kDTFullUrl.substr(0, nPos);
		}

		//dtFile = kDTFullUrl.substr(nPos + 1);
		dtFile = kDTFullUrl.substr(nPos);
		m_dtParam = "";
		ParseParam(dtFile);
	}
	m_dtParam = UrlEncode(m_dtParam);
	dtFile = dtFile + "?" + m_dtParam; 
	//dtFile = dAdd + dtFile;
	return getHttpFile(dtServer, dtFile, "", 0);
}

int KHttp::getHttpFile(const KData& fullUrl, const KData& savefile,
		int startpos)
{
	string strPath = fullUrl;
	Trim(strPath);
	KData dtServer;
	KData dtFile;
	KData kDTFullUrl = strPath;
	KData dtTemp;
	m_bWriteBufFlag = false;

	LOGD("kDTFullUrl is %s",kDTFullUrl.getDataBuf());

	if (isEqualNoCase(kDTFullUrl.substr(0, 7), "http://"))
	{
		kDTFullUrl = kDTFullUrl.substr(7);
	}

	int nPos = kDTFullUrl.find("/");

	if (nPos == -1)
	{
		LOGERROR("nPos = -1");
		return 0;
	}
	else
	{
		dtTemp = kDTFullUrl.substr(0, nPos);
		int nPortPos = dtTemp.find(":");
		if (nPortPos != -1)
		{
			dtServer = dtTemp.substr(0, nPortPos);
			m_iServerPort = int(dtTemp.substr(nPortPos + 1));

		}
		else
		{
			dtServer = kDTFullUrl.substr(0, nPos);
		}

		dtFile = kDTFullUrl.substr(nPos);
		//m_dtParam = "";
		//ParseParam(dtFile);
	}


	return getHttpFile(dtServer, dtFile, savefile, startpos);
}

void KHttp::setUserAgent(const KData& agent)
{
	m_dtUserAgent = agent;
}

int KHttp::getHttpFile(const KData& server, const KData& httpfile,
		const KData& savefile, int startpos)
{
	LOGD("Entry getHttpFile");
	m_dtHttpServer = server;
	m_dtHttpFile = httpfile;
	m_bChunked = false;
	m_iWriteLen = startpos;
	m_iLength = 0;
	m_clientSock.close();
	m_kCnnect.close();

	_respHeadMap.clear();
	m_iNotifyPos = 0;
	m_iNotifyGap = 0;
	m_iContentLength = 0;
	m_iStatusCode = 0;
	bool bGet = (_paramMap.size() == 0);

	KFile kFile;
	KData kHttpRequest;
	KData kDataPost;

	if (bGet)
	{
		kHttpRequest = "GET ";
	}
	else
	{
		kHttpRequest = "POST ";

		if (_paramMap.size() != 0)
		{
			map<KData, KData>::iterator iter;
			for (iter = _paramMap.begin(); iter != _paramMap.end(); iter++)
			{
				if (iter != _paramMap.begin())
					kDataPost += "&";
				kDataPost += iter->first;
				kDataPost += "=";
				kDataPost += iter->second;
			}
		}
	}

	kHttpRequest += httpfile;
	kHttpRequest += " HTTP/1.1";
	kHttpRequest += CRLF;
	kHttpRequest += "Host: ";
	kHttpRequest += server;
	kHttpRequest += CRLF;
	kHttpRequest += "Accept: */*";
	kHttpRequest += CRLF;


	if (!m_dtUserAgent.isEmpty())
	{
		kHttpRequest += "User-Agent: ";
		kHttpRequest += m_dtUserAgent;
		kHttpRequest += CRLF;
	}

	if (startpos > 0)
	{
		kHttpRequest += "RANGE: bytes=";
		kHttpRequest += startpos;
		kHttpRequest += "-";
		kHttpRequest += CRLF;
	}

	kHttpRequest += "Pragma: no-cache";
	kHttpRequest += CRLF;
	kHttpRequest += "Cache-Control: no-cache";
	kHttpRequest += CRLF;
	kHttpRequest += "Connection: close";
	kHttpRequest += CRLF;

	if (!bGet)
	{
		kHttpRequest += "Content-Type: application/x-www-form-urlencoded";
		kHttpRequest += CRLF;
		kHttpRequest += "Content-Length: ";
		kHttpRequest += KData((int) kDataPost.length());
		kHttpRequest += CRLF;
	}

	kHttpRequest += CRLF;

	char szBuffer[MTU] = {0};

	if (m_dtHttpProxy.isEmpty())
	{
		LOGD("Connect to Server:  %s", server.getData() );
		//m_clientSock.setServer(server, 80);
	   m_clientSock.setServer(server, m_iServerPort);
	}
	else
	{
		LOGD("Connect to Server:  %s", m_dtHttpProxy.getData() );
		//m_clientSock.setServer(m_dtHttpProxy, 80);
		m_clientSock.setServer(m_dtHttpProxy, m_iServerPort);

	}
	m_clientSock.initSocket();
	if (!m_clientSock.connect())
	{
		LOGERROR("m_clientSock.connect() failed");
		return -1;
	}

	m_kCnnect = m_clientSock.getConn();
	m_kCnnect.setTimeout(m_timeout);

	if (m_kCnnect.writeData(kHttpRequest) != (int) kHttpRequest.length())
	{
		LOGERROR(" m_conn.writeData(httpRequest) != (int)httpRequest.length() failed");
		return -1;
	}

	m_iWritedBytes += kHttpRequest.length();

	if (!bGet)
	{
		if (m_kCnnect.writeData(kDataPost) != (int) kDataPost.length())
		{
			LOGERROR("m_conn.writeData(dtPost) != (int)dtPost.length() failed");
			return -1;
		}

		m_iWritedBytes += kDataPost.length();
	}

	int iRead = 0;

	m_iStatusCode = 0;
	bool bRun = true;

	memset(szBuffer, 0, MTU);
	if ((iRead = m_kCnnect.readLine(szBuffer, MTU)) <= 0)
	{
		LOGERROR( "Read command line err: %d", iRead );
		m_iReadedBytes += iRead;
		return 0;
	}

	KData dtKData;
	KData dtLine(szBuffer, iRead);

	if (dtLine.match(SP, &dtKData, true) == NOT_FOUND)
	{
		LOGERROR("Read command line mactch space err" );
		return 0;
	}
	if (dtKData != "HTTP/1.1" && dtKData != "HTTP/1.0")
	{
		LOGERROR( "GET HTTP HEAD ERR" );
		return 0;
	}
	if (dtLine.match(SP, &dtKData, true) == NOT_FOUND)
	{
		LOGERROR("Read command line mactch space 2 err" );
		return 0;
	}
	m_iStatusCode = (int) dtKData;

	LOGD("Ready to while ( (iRead = m_conn.readLine(buff,MTU)) > 0 )");

	while ((iRead = m_kCnnect.readLine(szBuffer, MTU)) > 0)
	{
		m_iReadedBytes += iRead;
		KData dtLine(szBuffer, iRead);

		KData dtBefVal;
		if (FOUND == dtLine.match(":", &dtBefVal, true))
		{
			dtBefVal.removeSpaces();
			dtLine.removeSpaces();

			if (isEqualNoCase(dtBefVal, "Content-Length"))
			{
				m_iLength = (int) dtLine + startpos;
				if (m_iNotifyPercent > 0 && m_iNotifyPercent <= 100)
				{
					m_iNotifyPos = m_iNotifyGap = m_iLength
							/ (100 / m_iNotifyPercent);
				}
			}
			else if (isEqualNoCase(dtBefVal, "Transfer-Encoding"))
			{
				if (isEqualNoCase(dtLine, "chunked"))
				{
					m_bChunked = true;
				}
			}
			_respHeadMap[dtBefVal] = dtLine;
		}
	}

	if (iRead < 0)
	{
		LOGERROR("read err" );
		return -1;
	}

	if (m_iStatusCode != 200 && m_iStatusCode != 206)
	{
		if (m_iStatusCode == 302)
		{
			KData dtRedirectUrl = getRespFieldValue("Location");
			LOGD("Ready to return getHttpFile( dtRedirectUrl, savefile, startpos );");
			return getHttpFile(dtRedirectUrl, savefile, startpos);
		}

		LOGERROR(" m_iStatusCode!=200 && m_iStatusCode!=206");
		return 0;
	}

	//��ʱ����Ϊ�������ļ������ʱ�� savefileû�д���ֵ
	if (savefile.length() != 0)
	{
		if (startpos <= 0)
		{
			if (!kFile.setFile(savefile, KFile::KFILE_READWRITE))
			{
				LOGERROR("open file %s err", savefile.getData() );
				return 0;
			}
		}
		else
		{
			if (!kFile.setFile(savefile, KFile::KFILE_MODIFY))
			{
				LOGERROR("open file %s err", savefile.getData() );
				return 0;
			}
			kFile.seekTo(startpos, SEEK_SET);
		}
	}


	if (m_bChunked)
	{
		unsigned char* pBuff = new unsigned char[MTU];
		int iBuffLen = MTU;

		while ((iRead = m_kCnnect.readLine(szBuffer, MTU)) > 0)
		{
			m_iReadedBytes += iRead;
			if (iRead > 8)
			{
				return -1;
			}

			int nLength = KData(szBuffer, iRead).HexToInt();

			if (nLength <= 0)
			{
				delete [] pBuff;
				return m_iWriteLen;
			}

			if (nLength > iBuffLen)
			{
				delete[] pBuff;
				iBuffLen = nLength;
				pBuff = new unsigned char[iBuffLen];
			}

			int iReaded = 0;
			memset(pBuff, 0, nLength);
			m_kCnnect.readData(pBuff, nLength, iReaded);
			m_iReadedBytes += iReaded;
			kFile.write(pBuff, iReaded);
			m_iWriteLen += iReaded;
			if (m_iLength > 0)
			{
				if (m_iWriteLen >= m_iLength)
				{
					if (m_iNotifyGap > 0)
					{
						m_pNotifyCallback(m_pNotifyParam, 100, m_iWriteLen,
							m_iLength);
					}

					break;
				}
				if (m_iNotifyGap > 0 && m_iWriteLen > m_iNotifyPos)
				{
					int nPercent = int((m_iWriteLen / (float) m_iLength) * 100);
					m_iNotifyPos += m_iNotifyGap;
					m_pNotifyCallback(m_pNotifyParam, nPercent, m_iWriteLen,
							m_iLength);
				}
			}

			if (iReaded != nLength)
			{
				delete[] pBuff;
				return m_iWriteLen;
			}

			if (m_kCnnect.readLine(szBuffer, MTU) != 0)
			{
				return m_iWriteLen;
			}
		}

		delete[] pBuff;
		return m_iWriteLen;
	}
	else
	{
		//��ȡbuffer
		if (m_bWriteBufFlag)
		{
			iRead = m_kCnnect.readn(m_pWriteBuf, 300);
		}
		else   //��ȡ�ڴ�
		{
			while ((iRead = m_kCnnect.readn(szBuffer, MTU)) > 0 && bRun)
			{
				//LOGD("m_iReadedBytes += iRead; %d",iRead);
				m_iReadedBytes += iRead;
				kFile.write((unsigned char*) szBuffer, iRead);
				m_iWriteLen += iRead;

				if (m_iLength > 0)
				{
					if (m_iWriteLen >= m_iLength)
					{
						if (m_iNotifyGap > 0)
						{
							m_pNotifyCallback(m_pNotifyParam, 100, m_iWriteLen,
								m_iLength);
						}

						break;
					}
					if (m_iNotifyGap > 0 && m_iWriteLen > m_iNotifyPos)
					{
						int nPercent = int((m_iWriteLen / (float) m_iLength) * 100);
						m_iNotifyPos += m_iNotifyGap;
						m_pNotifyCallback(m_pNotifyParam, nPercent, m_iWriteLen,
							m_iLength);
					}
				}
				while (m_bPause)
				{
					vsleep(1000);
				}
			}
		}
	}

	m_kCnnect.close();
	kFile.closeFile();

	return m_iWriteLen;
}

KData KHttp::getRespFieldValue(const KData& field)
{
	for (map<KData, KData>::iterator iter = _respHeadMap.begin();
			iter != _respHeadMap.end(); iter++)
	{
		if (isEqualNoCase(iter->first, field))
		{
			return iter->second;
		}
	}
	return "";
}

int KHttp::getHttpFileMemory(const KData& server, const KData& httpfile,
		char** ppKData)
{
	char* pKData = NULL;
	KData httpRequest = "GET ";
	httpRequest += httpfile;
	httpRequest += " HTTP/1.1";
	httpRequest += CRLF;
	httpRequest += "Host: ";
	httpRequest += server;
	httpRequest += CRLF;
	httpRequest += CRLF;
	unsigned char buff[MTU];
	KTcpClientSocket clientSock(server, 80);
	clientSock.connect();
	KConnection &conn = clientSock.getConn();
	string stringTmp = httpRequest.getData();
	conn.writeData(stringTmp);
	int iRead = 0;
	bool bFound = false;
	KData dtHead;
	int iLength = 0;
	int iWrite = 0;
	int m_iStatusCode = 0;
	bool bRun = true;
	while ((iRead = conn.readn(buff, MTU)) > 0 && bRun)
	{
		if (!bFound)
		{
			for (int i = 0; i < iRead - 4; i++)
			{
				if (buff[i] == 0x0d && buff[i + 1] == 0x0a
						&& buff[i + 2] == 0x0d && buff[i + 3] == 0x0a)
				{
					KData dtLine;
					dtHead = KData((char*) buff, i + 4);
					KData dtRequestLine, dtCode;

					if (NOT_FOUND == dtHead.match(CRLF, &dtRequestLine, false))
					{
						return -1;
					}
					if (NOT_FOUND == dtRequestLine.match("HTTP/1.1", NULL, true)
							&& NOT_FOUND
									== dtRequestLine.match("HTTP/1.0", NULL,
											true))
					{
						return -1;
					}
					if (NOT_FOUND == dtRequestLine.match(SP, NULL, true))
					{
						return -1;
					}
					if (NOT_FOUND == dtRequestLine.match(SP, &dtCode, true))
					{
						return -1;
					}
					if ((int) dtCode == 0 && (int) dtCode != 200)
					{
						return -1;
					}

					while (NOT_FOUND != dtHead.match(CRLF, &dtLine, true))
					{
						KData dtBefVal;
						if (FOUND == dtLine.match(":", &dtBefVal, true))
						{
							dtBefVal.removeSpaces();
							if (isEqualNoCase(dtBefVal, "Content-Length"))
							{
								dtLine.removeSpaces();
								iLength = (int) dtLine;
							}
						}
						else if (NOT_FOUND
								!= dtLine.match("HTTP/1.1", NULL, true))
						{
							dtLine.removeSpaces();
							dtLine.match(" ", &dtBefVal, true);
							m_iStatusCode = (int) dtBefVal;
						}

					}
					if (iLength <= 0)
					{
						return -1;
					}
					else if (m_iStatusCode != 200)
					{
						return -1;
					}
					else
					{
						pKData = new char[iLength];
					}

					memcpy(pKData, &buff[i + 4], iRead - i - 4);
					iWrite += (iRead - i - 4);
					bFound = true;

					if (iLength > 0 && iWrite == iLength)
					{
						bRun = false;
						break;
					}
				}
			}
		}
		else
		{
			memcpy(&pKData[iWrite], buff, iRead);
			iWrite += iRead;
			if (iWrite == iLength)
			{
				break;
			}
		}
	}

	conn.close();
	*ppKData = pKData;
	return iWrite;
}

void KHttp::addParam(const char* name, const char* val)
{
	_paramMap[name] = val;
}

void KHttp::clearParam()
{
	_paramMap.clear();
}

void KHttp::pause()
{
	m_bPause = true;
}

void KHttp::resume()
{
	m_bPause = false;
}

void KHttp::stop()
{
	m_kCnnect.close();
	m_clientSock.close();
}

int KHttp::getWriteLen()
{
	return m_iWriteLen;
}


int KHttp::getHttpFileLength(const KData & fullUrl)
{
	KData server;
	KData httpFile;
	KData dtFullUrl = fullUrl;

	if (isEqualNoCase(dtFullUrl.substr(0, 7), "http://"))
	{
		dtFullUrl = dtFullUrl.substr(7);
	}

	int pos = dtFullUrl.find("/");
	if (pos == -1)
	{
		return -1;
	}
	else
	{
		server = dtFullUrl.substr(0, pos);
		httpFile = dtFullUrl.substr(pos);
	}

	m_bChunked = false;
	m_iWriteLen = 0;
	m_iLength = 0;
	m_clientSock.close();
	m_kCnnect.close();

	_respHeadMap.clear();
	m_iNotifyPos = 0;
	m_iNotifyGap = 0;
	m_iContentLength = 0;
	m_iStatusCode = 0;
	bool bGet = (_paramMap.size() == 0);

	KFile file;
	KData httpRequest;
	KData dtPost;

	if (bGet)
	{
		httpRequest = "GET ";
	}
	else
	{
		httpRequest = "POST ";
		map<KData, KData>::iterator iter;
		for (iter = _paramMap.begin(); iter != _paramMap.end(); iter++)
		{
			if (iter != _paramMap.begin())
				dtPost += "&";
			dtPost += iter->first;
			dtPost += "=";
			dtPost += iter->second;
		}
	}

	httpRequest += httpFile;
	httpRequest += " HTTP/1.1";
	httpRequest += CRLF;
	httpRequest += "Host: ";
	httpRequest += server;
	httpRequest += CRLF;
	httpRequest += "Accept: */*";
	httpRequest += CRLF;
	if (!m_dtUserAgent.isEmpty())
	{
		httpRequest += "User-Agent: ";
		httpRequest += m_dtUserAgent;
		httpRequest += CRLF;
	}

	httpRequest += "Pragma: no-cache";
	httpRequest += CRLF;
	httpRequest += "Cache-Control: no-cache";
	httpRequest += CRLF;
	httpRequest += "Connection: close";
	httpRequest += CRLF;

	if (!bGet)
	{
		httpRequest += "Content-Type: application/x-www-form-urlencoded";
		httpRequest += CRLF;
		httpRequest += "Content-Length: ";
		httpRequest += KData((int) dtPost.length());
		httpRequest += CRLF;
	}

	httpRequest += CRLF;

	char buff[MTU] =
	{ 0 };

	m_clientSock.setServer(server, 80);
	if (!m_clientSock.connect())
	{
		return 0;
	}

	m_kCnnect = m_clientSock.getConn();
	m_kCnnect.setTimeout(m_timeout);

	if (m_kCnnect.writeData(httpRequest) != (int) httpRequest.length())
		return 0;
	m_iWritedBytes += httpRequest.length();

	if (!bGet)
	{
		if (m_kCnnect.writeData(dtPost) != (int) dtPost.length())
			return 0;
		m_iWritedBytes += dtPost.length();
	}

	int iRead;
	m_iStatusCode = 0;

	memset(buff, 0, MTU);

	if ((iRead = m_kCnnect.readLine(buff, MTU)) <= 0)
	{
		m_iReadedBytes += iRead;
		return 0;
	}

	KData dtKData;
	KData dtLine(buff, iRead);
	if (dtLine.match(SP, &dtKData, true) == NOT_FOUND)
	{
		return 0;
	}
	if (dtKData != "HTTP/1.1" && dtKData != "HTTP/1.0")
	{
		return 0;
	}
	if (dtLine.match(SP, &dtKData, true) == NOT_FOUND)
	{
		return 0;
	}
	m_iStatusCode = (int) dtKData;

	while ((iRead = m_kCnnect.readLine(buff, MTU)) > 0)
	{
		m_iReadedBytes += iRead;
		KData dtLine(buff, iRead);

		KData dtBefVal;
		if (FOUND == dtLine.match(":", &dtBefVal, true))
		{
			dtBefVal.removeSpaces();
			dtLine.removeSpaces();
			if (isEqualNoCase(dtBefVal, "Content-Length"))
			{
				return (int) dtLine;
			}
		}
	}

	return 0;
}

int KHttp::getFileLen()
{
	return m_iLength;
}

unsigned int KHttp::getReadBytes()
{
	return m_iReadedBytes;
}

unsigned int KHttp::getWriteBytes()
{
	return m_iWritedBytes;
}