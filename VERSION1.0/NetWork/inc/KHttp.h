#ifndef __KT_KHTTP_H
#define __KT_KHTTP_H

#include "KData.h"
#include "KTcpClientSocket.h"

typedef void (*NotifyCallback)( void* param, int percent, int pos, int filelen );

class KHttp  
{
public:
	KHttp();
	virtual ~KHttp();

	int getStatusCode() const;
	int getContentLength() const;
	void setCookie( KData cookie );
	int getHttpFile( const KData& fullUrl, const KData& savefile, int startpos=0 );
	int getHttpFile( const KData& server, const KData& httpfile, const KData& savefile, int startpos=0 );
	int getHttpFile( const KData& fullUrl, char*& saveBuf);

	int getHttpFileMemory( const KData& server, const KData& httpfile, char** pKData );
	void setNotifyCallback( NotifyCallback callback, void* param, int percent=10 );
	void clear();
	void setUserAgent( const KData& agent );
	KData getRespFieldValue( const KData& field );
	void  ParseParam(KData &dPathData);

	int getHttpFileLength(const KData & fullUrl);
	
	void setTimeout( long timeout );
	 void setHttpProxy( const KData& proxy );

	unsigned int getReadBytes();
	unsigned int getWriteBytes();

	void pause();
	void resume();
	void stop();
	int getWriteLen();
	int getFileLen();

	unsigned char ToHex(unsigned char x);   
	std::string UrlEncode(const std::string& str); 
	
protected:
	NotifyCallback m_pNotifyCallback;
	KTcpClientSocket m_clientSock;
	void*	m_pNotifyParam;
	KData	m_dtCookie;
	KData	m_dtUserAgent;
	KData    m_dtHttpProxy;
	KData	m_dtHttpServer;
	KData	m_dtHttpFile;
	int		m_iContentLength;							
	int		m_iStatusCode;						
	int		m_iNotifyPercent;
	int		m_iNotifyGap;
	int		m_iNotifyPos;
	bool	m_bChunked;
	bool	m_bPause;
	int		m_iWriteLen;
	int		m_iLength;
	long	m_timeout;
	unsigned int	m_iReadedBytes;
	unsigned int	m_iWritedBytes;
	KConnection m_kCnnect;

	//��¼�˿ں�
	int    m_iServerPort;
	int    m_bWriteBufFlag;
	char*  m_pWriteBuf;
	KData  m_dtParam;


public:
	void clearParam();
	void addParam( const char* name, const char* val );
	map<KData,KData> _paramMap;
	map<KData,KData> _respHeadMap;
};

#endif
