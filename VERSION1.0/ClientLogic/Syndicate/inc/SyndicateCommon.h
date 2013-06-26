/*
 *  SyndicateCommon.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-1.
 *  Copyright 2011 (����)DeNA. All rights reserved.
 *
 */

#ifndef __SYNDICATE_COMMON_H__
#define __SYNDICATE_COMMON_H__

#include "define.h"
#include "basedefine.h"
#include <string>

using namespace std;

enum SYNDICATE_ACTION {
	APPLY_SYN = 0, // ����������,��Ҫβ�����id
	QUERY_APPLY_LIST = 1, // ��ѯ�����б�,��Ҫβ��ҳ��
	APPROVE_ACCEPT = 2, // ����ͨ��, β��idUser+ TQMBStrUserName
	APPROVE_REFUSE = 3, // �����ܾ�, β�� idUser
	DONATE_MONEY = 4, // ��Ǯ,β�� money(UINT)
	DEMISE_SYN = 5, // ����, β���°���id
	QUIT_SYN = 6, // �˳�����
	MODIFY_SYN_ANNOUNCE = 7, // �޸İ��ɹ���,β���¹���,(���������ϲ���)
	ELEVATE_MBR = 8, // ��γ�Ա,β�汻����˵�id
	DEBASE_MBR = 9, // ��ͳ�Ա, β�汻����˵�id
	KICK_OUT_MBR = 10, // ��������,(���������ϲ���)
	DONATE_WOOD					= 11,		// ����ľ��, nVal
	DONATE_STONE				= 12,		// ����ʯ��, nVal
	DONATE_PAINT				= 13,		// ��������, nVal
	DONATE_COAL					= 14,		// �����ڽ�, nVal
	DONATE_EMONEY				= 15,		// ����Ԫ��, nVal
	
	ACT_APPLY_REG_SYN		= 16,		// Ӧ������, idSyn
	ACT_QUERY_REG_SYN_LIST		= 17,		// ��ѯӦ�������б�, btPage(��0��ʼ)
	ACT_QUERY_REG_SYN_INFO		= 18,		// ��ѯӦ��������Ϣ, idSyn
	ACT_UPGRADE_SYN			= 19,		// ��������
	ACT_QUERY_SYN_UPGRADE_INFO	= 20,		// ��ѯ����������Ϣ
	ACT_QUERY_SYN_STORAGE		= 21,		// ��ѯ���Ųֿ�
	ACT_ASSIGN_MBR_RANK		= 22,		// ������ְ, idElevated, btNewRank
	ACT_RESIGN			= 23,		// ��ְ
	ACT_DISMISS_SYN				= 24,		// ��ɢ����
	ACT_QUERY_OFFICER			= 25,		// ��ѯ��ְ��Ա, btRank (��10)
	ACT_ELECTION				= 26,		// ��ѡְλ, btRank (����ֵ)
	ACT_QUERY_VOTE_LIST			= 27,		// ��ѯͶƱ�б�
	ACT_QUERY_VOTE_INFO			= 28,		// �鿴ͶƱ��ϸ��Ϣ, idVote
	ACT_CANCEL_VOTE				= 29,		// ȡ��ͶƱ, idVote
	ACT_VOTE_YES				= 30,		// Ͷ�޳�Ʊ, idVote
	ACT_VOTE_NO					= 31,		// Ͷ����Ʊ, idVote
};

enum SYNDICATE_ANSWER {
	APPROVE_ACCEPT_OK = 7, // ����ͨ��ok
	APPROVE_ACCEPT_FAIL = 8, // ����ͨ��ʧ��
	APPROVE_REFUSE_OK = 10, // �����ܾ�ok
	QUIT_SYN_OK = 17, // �˳�ok
	KICK_OUT_MBR_OK = 29, // ���˳ɹ�
	ANS_REG_SYN_INFO		= 51,		// Ӧ��������Ϣ, strTitle, strInfo
	ANS_SYN_UPGRADE_INFO	= 52,		// ����������Ϣ, SYN_UP_INFO
	ANS_QUERY_SYN_STORAGE	= 53,		// ���Ųֿ�, STORAGE_INFO
	ANS_SYN_PANEL_INFO		= 54,		// �鿴���˾�����Ϣ, strInfo
	ANS_SYN_LIST_INFO		= 55,		// ���������еľ�����Ϣ, strTitle, strInfo
	ANS_QUERY_OFFICER		= 56,		// �·���ְ��Ա�б�, OFFICER_LIST
	ANS_QUERY_VOTE_LIST		= 57,		// �·�ͶƱ�б�, VOTE_LIST
	ANS_QUERY_VOTE_INFO		= 58,		// �·�ͶƱ��ϸ��Ϣ, VOTE_INFO
	ANS_UPDATE_SYN_MBR_RANK	= 59,		// ����ְλ, btNewRank
};

enum SYN_QUERY {
	QUERY_SYN_PANEL_INFO = 0, // ��ѯ���������Ϣ
	QUERY_SYN_TAXIS = 1, // ��ѯ�������а�
	QUERY_SYN_TAXIS_DETAIL = 2, // ��ѯ���������еİ�����Ϣ
	QUERY_SYN_MBR = 3, // ��ѯ���ɳ�Ա�б� (��Ҫҳ��,����BYTE)
	QUERY_SYN_ANNOUNCE = 4, // ��ѯ���ɹ���
	QUERY_SYN_INVITE = 5, // ��ѯ�����б�
	QUERY_SYN_LIST_EX = 6,
	QUERY_SYN_MBR_LIST_EX = 7, // �µĲ�ѯ����ĳһҳ��Ա��Ϣ
};

enum SYN_INVITE {
	INVITE_ACCEPT_OK = 8, // ��������,�ɹ��������,ɾ�����������¼
	INVITE_REFUSE_OK = 9, // �ܾ�����ɹ�,ɾ���������¼
	
	INVITE_USER = 100, // ����ĳ�����
	INVITE_ACCEPT = 101, // ���ܰ�������
	INVITE_REFUSE = 102, // �ܾ���������
};

enum SYNMBR_RANK {
	SYNRANK_NONE = -1,
	SYNRANK_MEMBER = 0,//��ͨ���ų�Ա
	//����
	SYNRANK_MENZHU_SHENG = 11,//����
	SYNRANK_MENZHU_SHANG = 12,//����
	SYNRANK_MENZHU_XIU = 13,//����
	SYNRANK_MENZHU_DU = 14,//����
	SYNRANK_MENZHU_JING = 15,//����
	SYNRANK_MENZHU_SI = 16,//����
	SYNRANK_MENZHU_JING1 = 17,//����
	SYNRANK_MENZHU_KAI = 18,//����
	//����
	SYNRANK_TANGZHU_TIANLONG = 51,//����
	SYNRANK_TANGZHU_QINGMU = 52,//��ľ
	SYNRANK_TANGZHU_CHIHUO = 53,//���
	SYNRANK_TANGZHU_XIJIN = 54,//����
	SYNRANK_TANGZHU_XUANSHUI = 55,//��ˮ
	SYNRANK_TANGZHU_HUANGTU = 56,//����
	//Ԫ��
	SYNRANK_YUANLAO_XUANWU = 101,//����
	SYNRANK_YUANLAO_QINGLONG = 102,//����
	SYNRANK_YUANLAO_BAIHU = 103,//�׻�
	SYNRANK_YUANLAO_ZHUQUE = 104,//��ȸ
	//�ų�
	SYNRANK_VICE_LEADER = 111,//���ų�
	SYNRANK_LEADER = 121,//�ų�
};

enum {
	ONE_PAGE_COUNT = 10,
};

void queryCreatedInSynList(Byte queryPage);

void sendQueryTaxis(Byte queryPage);

void sendQueryAllSynList(Byte queryPage);

void sendApply(int synId);

void sendQueryTaxisDetail(int synId);

void sendQueryInviteList();

void sendInviteResult(Byte state, int synId);

void sendSynElection(Byte msgAction, Byte btNewRank);

void sendQuerySynNormalInfo(Byte msgAction);

void sendSynVoteComm(Byte msgAction,int idVote);

void sendQueryAnnounce();

void sendModifyNote(const std::string& str);

void sendQueryPanelInfo();

void sendContributeSyn(Byte msgAction,int value);

void sendUpGradeSyn();

void sendInviteOther(const std::string& name);

void sendQueryApprove(int queryPage);

void sendApproveAccept(int roleId, const std::string& name);

void sendApproveRefuse(int roleId);

void sendQueryMembers(int queryPage);

void sendAssignMbrRank(int roleId, int btNewRank, int curPage);

void sendKickOut(int roleId,int curPage);

void sendLeaveDemise(int roleId,int curPage);

void sendSynDonate(int uMoney, int uEmoney, int uWood, int uStone, int uCoal, int uPaint);

std::string getCampName(int type);

std::string getRankStr(int rank);

#endif