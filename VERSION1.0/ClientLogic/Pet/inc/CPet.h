/*
 *  CPet.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-14.
 *  Copyright 2012 (����)DeNA. All rights reserved.
 *
 */

#pragma once

#include "Singleton.h"
#include "EnumDef.h"
#include "define.h"
#include <string>
#include <map>
#include <set>
#include "globaldef.h"

enum PET_POSITION
{
	PET_POSITION_PETBAG = 0x01,	//���ﱳ��λ(1)
	PET_POSITION_MAIN	= 0x02,	//����λ(2)
	PET_POSITION_FIGHT	= 0x04,	//��սλ(4)
	PET_POSITION_SHOW	= 0x08,	//�޳�λ(8)
	PET_POSITION_BAG	= 0x10,	//����λ(16)
	PET_POSITION_REST	= 0x20,	//��Ϣ(32)
	PET_POSITION_UNSHOW	= 0x40,	//�ջ�(64)	
};

// Ӣ�۳�����Ϣ
typedef struct _tagPetInfo
{
	std::string str_PET_ATTR_NAME; // ����STRING
	
	typedef struct _tagPetData{
		int int_PET_ID;
		int int_PET_ATTR_LEVEL; // �ȼ�INT
		int int_PET_ATTR_EXP; // ����INT
		int int_PET_ATTR_LIFE; // ����ֵINT
		int int_PET_ATTR_MAX_LIFE; // �������ֵINT
		int int_PET_ATTR_MANA; // ħ��ֵINT
		int int_PET_ATTR_MAX_MANA; // ���ħ��ֵINT
		int int_PET_ATTR_STR; // ����INT
		int int_PET_ATTR_STA; // ����INT
		int int_PET_ATTR_AGI; // ����INT
		int int_PET_ATTR_INI; // ����INT
		int int_PET_ATTR_LEVEL_INIT; // ��ʼ�ȼ�INT
		int int_PET_ATTR_STR_INIT; // ��ʼ����INT
		int int_PET_ATTR_STA_INIT; // ��ʼ����INT
		int int_PET_ATTR_AGI_INIT; // ��ʼ����INT
		int int_PET_ATTR_INI_INIT; // ��ʼ����INT
		int  int_PET_ATTR_LOYAL; // �ҳ϶�INT
		int int_PET_ATTR_AGE; // ����INT
		int int_PET_ATTR_FREE_SP; // ʣ�༼�ܵ���INT
		int int_PET_PHY_ATK_RATE;//�﹥����
		int int_PET_PHY_DEF_RATE;//�������
		int int_PET_MAG_ATK_RATE;//��������
		int int_PET_MAG_DEF_RATE;//��������
		int int_PET_ATTR_HP_RATE; // ��������
		int int_PET_ATTR_MP_RATE; // ħ������
		int int_PET_MAX_SKILL_NUM;//����ѧ������
		int int_PET_SPEED_RATE;//�ٶ�����
		
		int int_PET_PHY_ATK_RATE_MAX;//�﹥��������
		int int_PET_PHY_DEF_RATE_MAX;//�����������
		int int_PET_MAG_ATK_RATE_MAX;//������������
		int int_PET_MAG_DEF_RATE_MAX;//������������
		int int_PET_ATTR_HP_RATE_MAX; // ������������
		int int_PET_ATTR_MP_RATE_MAX; // ħ����������
		int int_PET_SPEED_RATE_MAX;//�ٶ���������
		
		int int_PET_GROW_RATE;// �ɳ���
		int int_PET_GROW_RATE_MAX;// �ɳ���
		int int_PET_HIT ;//����
		
		int int_ATTR_FREE_POINT; //���ɵ���
		int int_PET_ATTR_LEVEUP_EXP; // ��������
		int int_PET_ATTR_PHY_ATK; // ��������INT
		int int_PET_ATTR_PHY_DEF; // �������INT
		int int_PET_ATTR_MAG_ATK; // ����������INT
		int int_PET_ATTR_MAG_DEF; // ��������INT
		int int_PET_ATTR_HARD_HIT;// ����
		int int_PET_ATTR_DODGE;// ����
		int int_PET_ATTR_ATK_SPEED;// �����ٶ�
		int int_PET_ATTR_TYPE;// ����
		int int_PET_ATTR_LOOKFACE;//���
		int bindStatus;//��״̬
		int int_PET_ATTR_POSITION;
		_tagPetData(){ memset(this, 0, sizeof(*this)); }
	}PetData;
	
	int GetQuality()  { return data.int_PET_ATTR_TYPE % 10; }
	
	PetData data;
}PetInfo;

class CPetMgr : public TSingleton<CPetMgr>
{
public:
	CPetMgr();
	~CPetMgr();
	
	// ����ȡ����
	PetInfo*				GetPet(OBJID idPet);
	
	// ���򴴽�
	PetInfo*				GetPetWithCreate(OBJID idRoleID, OBJID idPet);
	
	// ��ȡĳ����ɫ���еĳ�������
	bool					GetPets(OBJID idRoleID, ID_VEC& vecid);
	
	// ��ȡĳ��λ�ó��������
	bool					GetPetWithPos(OBJID idRoleID, PET_POSITION pos, ID_VEC& vecid);
	
	// ��ȡĳ����ҵĳ�������
	PetInfo*				GetMainPet(OBJID idRoleID);
	
	// ��ȡĳ����ҵ����
	PetInfo*				GetShowPet(OBJID idRoleID);
	
	// ���ĳ����ɫ�����г�������
	bool					DelPets(OBJID idRoleID);
	
	// �����������
	bool					DelPet(OBJID idPet);
	
	bool					DelAll();
	
	// ����ĳֻ����ĳ������
	void					AddSkill(OBJID idRoleID, OBJID idPet, OBJID idSkill);
	
	// ɾ��ĳֻ����ĳ������
	bool					DelSkill(OBJID idRoleID, OBJID idPet, OBJID idSkill);
	
	// ɾ��ĳ����ɫĳֻ��������м���
	bool					DelSkill(OBJID idRoleID, OBJID idPet);
	
	// ɾ��ĳ����ɫ�����г������м���
	bool					DelSkills(OBJID idRoleID);
	
	bool					DelSkill(OBJID idPet);
	
	std::set<OBJID>&		GetSkillList(SKILL_TYPE type, OBJID idPet);
	
	bool					GetSkillList(OBJID idPet, std::set<OBJID>& setid);
	
	int						SkillSize(OBJID idPet);
	
	static unsigned int		getPetQualityColor(OBJID idType);
	
private:
	
	typedef std::map<OBJID, PetInfo*>				MAP_PETS;
	
	typedef std::map<OBJID, MAP_PETS>				MAP_ROLE_PETS;
	
	typedef std::set<OBJID>							SET_ID;
	
	typedef std::map<OBJID, SET_ID>					MAP_SKILL;
	
	typedef std::map<OBJID, MAP_SKILL>				MAP_PET_SKILL;
	
	MAP_ROLE_PETS	m_mapRolePets;
	
	MAP_PET_SKILL	m_mapPetSkill;
	
	SET_ID			m_setSkillCache;
};

#define PetMgrObj CPetMgr::GetSingleton()

std::string getPetType(int type);