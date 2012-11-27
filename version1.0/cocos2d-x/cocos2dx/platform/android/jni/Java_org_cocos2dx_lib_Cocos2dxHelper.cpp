#include <stdlib.h>
#include <jni.h>
#include <android/log.h>
#include <string>
#include "JniHelper.h"
#include "cocoa/CCString.h"
#include "Java_org_cocos2dx_lib_Cocos2dxHelper.h"

#if 0
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define	LOGD(...)
#endif

#define  CLASS_NAME "org/cocos2dx/lib/Cocos2dxHelper"

static EditTextCallback s_pfEditTextCallback = NULL;
static void* s_ctx = NULL;

using namespace cocos2d;
using namespace std;

extern "C"
{
string g_apkPath;

void Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetApkPath(JNIEnv* env,
		jobject thiz, jstring apkPath)
{
	LOGD("entry Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetApkPath,g_apkPath = %s",g_apkPath.c_str());
	g_apkPath = string("/data/app/org.DeNA.DHLJ-2.apk");//JniHelper::jstring2string(apkPath);
	LOGD("leave Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetApkPath,g_apkPath = %s",g_apkPath.c_str());
}

const char * getApkPath()
{
	return g_apkPath.c_str();
}

void Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetExternalAssetPath(
		JNIEnv* env, jobject thiz, jstring externalAssetPath)
{
	const char* externalAssetPathChars = env->GetStringUTFChars(
			externalAssetPath, NULL);
	cocos2d::JniHelper::setExternalAssetPath(externalAssetPathChars);
	env->ReleaseStringUTFChars(externalAssetPath, externalAssetPathChars);
}

void showDialogJNI(const char * pszMsg, const char * pszTitle)
{
	LOGD("entry showDialogJNI");
	if (!pszMsg)
	{
		return;
	}

	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showDialog",
			"(Ljava/lang/String;Ljava/lang/String;)V"))
	{
		jstring stringArg1;

		if (!pszTitle)
		{
			stringArg1 = t.env->NewStringUTF("");
		}
		else
		{
			stringArg1 = t.env->NewStringUTF(pszTitle);
		}

		jstring stringArg2 = t.env->NewStringUTF(pszMsg);
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1,
				stringArg2);

		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(stringArg2);
		t.env->DeleteLocalRef(t.classID);
	}
}

void showEditTextDialogJNI(const char* pszTitle, const char* pszMessage,
		int nInputMode, int nInputFlag, int nReturnType, int nMaxLength,
		EditTextCallback pfEditTextCallback, void* ctx)
{
	LOGD("entry showEditTextDialogJNI");
	if (pszMessage == NULL)
	{
		return;
	}

	s_pfEditTextCallback = pfEditTextCallback;
	s_ctx = ctx;

	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showEditTextDialog",
			"(Ljava/lang/String;Ljava/lang/String;IIII)V"))
	{
		jstring stringArg1;

		if (!pszTitle)
		{
			stringArg1 = t.env->NewStringUTF("");
		}
		else
		{
			stringArg1 = t.env->NewStringUTF(pszTitle);
		}

		jstring stringArg2 = t.env->NewStringUTF(pszMessage);

		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1,
				stringArg2, nInputMode, nInputFlag, nReturnType, nMaxLength);

		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(stringArg2);
		t.env->DeleteLocalRef(t.classID);
	}
}

void Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult(
		JNIEnv * env, jobject obj, jbyteArray text)
{
	LOGD("entry Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult");
	jsize size = env->GetArrayLength(text);

	if (size > 0)
	{
		jbyte * data = (jbyte*) env->GetByteArrayElements(text, 0);
		char* pBuf = (char*) malloc(size + 1);
		if (pBuf != NULL)
		{
			memcpy(pBuf, data, size);
			pBuf[size] = '\0';
			// pass data to edittext's delegate
			if (s_pfEditTextCallback)
				s_pfEditTextCallback(pBuf, s_ctx);
			free(pBuf);
		}
		env->ReleaseByteArrayElements(text, data, 0);
	}
	else
	{
		if (s_pfEditTextCallback)
			s_pfEditTextCallback("", s_ctx);
	}
}

void terminateProcessJNI()
{
	LOGD("entry terminateProcessJNI");
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "terminateProcess",
			"()V"))
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

const char* getPackageNameJNI()
{
	LOGD("entry getPackageNameJNI");
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getCocos2dxPackageName",
			"()Ljava/lang/String;"))
	{
		jstring str = (jstring) t.env->CallStaticObjectMethod(t.classID,
				t.methodID);
		t.env->DeleteLocalRef(t.classID);
		CCString *ret = new CCString(JniHelper::jstring2string(str).c_str());
		ret->autorelease();
		t.env->DeleteLocalRef(str);

		return ret->m_sString.c_str();
	}

	return 0;
}

const char* getCurrentLanguageJNI()
{
	LOGD("entry getCurrentLanguageJNI");
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getCurrentLanguage",
			"()Ljava/lang/String;"))
	{
		jstring str = (jstring) t.env->CallStaticObjectMethod(t.classID,
				t.methodID);
		t.env->DeleteLocalRef(t.classID);
		CCString *ret = new CCString(JniHelper::jstring2string(str).c_str());
		ret->autorelease();
		t.env->DeleteLocalRef(str);

		return ret->m_sString.c_str();
	}

	return 0;
}

void enableAccelerometerJNI()
{
	LOGD("entry enableAccelerometerJNI");
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "enableAccelerometer",
			"()V"))
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void disableAccelerometerJNI()
{
	LOGD("entry disableAccelerometerJNI");
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "disableAccelerometer",
			"()V"))
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}
}
