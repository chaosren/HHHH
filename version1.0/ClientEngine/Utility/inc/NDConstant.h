//
//  NDConstant.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#ifndef __NDConstant_H
#define __NDConstant_H

#define REPLACEABLE_NONE					0//�����滻��λ
#define REPLACEABLE_CAP						1//ͷ��
#define REPLACEABLE_ARMOR					2//�ؼ�
#define REPLACEABLE_SHIELD					3//����
#define REPLACEABLE_FAQI					4//����
#define REPLACEABLE_FACE					5//����
#define REPLACEABLE_HAIR					6//����
#define REPLACEABLE_EXPRESSION				7//����
#define REPLACEABLE_ONE_HAND_WEAPON_1		8//���ֽ�
#define REPLACEABLE_ONE_HAND_WEAPON_2		9//���ֵ�
#define REPLACEABLE_TWO_HAND_WEAPON			10//˫�ֽ�
#define REPLACEABLE_TWO_HAND_KNIFE			11//˫�ֵ�
#define REPLACEABLE_DUAL_SWORD				12//˫�ֽ�
#define REPLACEABLE_DUAL_KNIFE				13//˫�ֵ�
#define REPLACEABLE_TWO_HAND_WAND			14//˫����
#define REPLACEABLE_TWO_HAND_BOW			15//˫�ֹ�
#define REPLACEABLE_ONE_HAND_DAGGER			16//ذ��
#define REPLACEABLE_LEFT_SHOULDER			17//���
#define REPLACEABLE_RIGHT_SHOULDER			18//���
#define REPLACEABLE_SKIRT_STAND				19//
#define REPLACEABLE_SKIRT_WALK				20//
#define REPLACEABLE_SKIRT_SIT				21//
#define REPLACEABLE_SKIRT_LIFT_LEG			22//̧��
#define REPLACEABLE_TWO_HAND_SPEAR			23//˫��ì

// ��ҵ�����
#define MANUELROLE_HUMAN_MALE					NDPath::GetAniPath("fist_man.spr")
#define MANUELROLE_HUMAN_FEMALE					NDPath::GetAniPath("fist_man.spr")

#define MANUELROLE_FIST_MALE					NDPath::GetAniPath("tang_man.spr")
#define MANUELROLE_FIST_FEMALE					NDPath::GetAniPath("tang_woman.spr")
#define MANUELROLE_SWORD_MALE					NDPath::GetAniPath("tang_man.spr")
#define MANUELROLE_SWORD_FEMALE					NDPath::GetAniPath("tang_woman.spr")
#define MANUELROLE_CHIVALROUS_MALE				NDPath::GetAniPath("tang_man.spr")
#define MANUELROLE_CHIVALROUS_FEMALE			NDPath::GetAniPath("tang_woman.spr")

// �����㶯��
#define TRANSPORT							99
#define UPLEV_EFFECT						900
#define TASKDONE_EFFECT						901
#define ROLE_SEAT_EFFECT					902
#define DRITICAL_EFFECT						903
#define SKILL_ATKED_EFFECT					904
#define PHY_ATKED_EFFECT					905
#define ATKBACK_EFFECT						906
#define ACTIVITY_OPEN_EFFECT				907
#define MANAFULL_EFFECT						908

// ��ҵĶ�����ԭ�����泯��ߵ�
#define MANUELROLE_STAND					0
#define MANUELROLE_WALK						1
#define MANUELROLE_BATTLE_STAND				2
#define MANUELROLE_DEFENCE					3
#define MANUELROLE_DODGE					4
#define MANUELROLE_HURT						5
#define MANUELROLE_ATTACK					6
#define MANUELROLE_RELAX					7
#define MANUELROLE_SEAT						8
#define MANUELROLE_SKILL					9
#define MANUELROLE_RIDE_STAND				10
#define MANUELROLE_RIDE_WALK				11
//�������ﶯ������ﶯ��������ʹ��

#define MANUELROLE_RIDE_PET_STAND			6
#define MANUELROLE_RIDE_PET_MOVE			3
#define MANUELROLE_STAND_PET_STAND			4
#define MANUELROLE_STAND_PET_MOVE			11

#define MANUELROLE_WEAK						7
#define MANUELROLE_MOVE_TO_TARGET			8
#define MANUELROLE_MOVE_BACK				9

#define MANUELROLE_DIE						12
#define MANUELROLE_FLEE_SUCCESS				13
#define MANUELROLE_FLEE_FAIL				14

#define MANUELROLE_ATTACK_FREEHAND			15
#define MANUELROLE_DEFENCE_FREEHAND			16

#define MANUELROLE_SKILL_WARRIOR_DISTANCE	17
#define MANUELROLE_SKILL_WIZZARD_DISTANCE	18
#define MANUELROLE_SKILL_HUNTER_DISTANCE	19

#define MANUELROLE_ATTACK_ONE_HAND_WEAPON	20
#define MANUELROLE_DEFENCE_ONE_HAND_WEAPON	21

#define MANUELROLE_ATTACK_DUAL_WEAPON		22
#define MANUELROLE_DEFENCE_DUAL_WEAPON		23

#define MANUELROLE_ATTACK_TWO_HAND_WEAPON	24
#define MANUELROLE_DEFENCE_TWO_HAND_WEAPON	25

#define MANUELROLE_ATTACK_TWO_HAND_WAND		26
#define MANUELROLE_DEFENCE_TWO_HAND_WAND	27

#define MANUELROLE_ATTACK_TWO_HAND_BOW		28
#define MANUELROLE_DEFENCE_TWO_HAND_BOW		29

#define MANUELROLE_SKILL_WARRIOR_SWORD_SINGLE	30
#define MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE	31
#define MANUELROLE_SKILL_WARRIOR_SWORD_AREA		32
#define MANUELROLE_SKILL_WARRIOR_KNIFE_AREA		33
#define MANUELROLE_SKILL_WARRIOR_LION_SOAR		34
#define MANUELROLE_SKILL_WIZZARD				35
#define MANUELROLE_SKILL_ASSASIN_BOW_SINGLE		36
#define MANUELROLE_SKILL_ASSASIN_BOW_AREA		37
#define MANUELROLE_SKILL_ASSASIN_SWORD_SINGLE	38
#define MANUELROLE_ITEM_USE						39
#define MANUELROLE_SKILL_ASSASIN_PONIARD_SINGLE	40
#define MANUELROLE_SITE							42
#define MANUELROLE_CATCH_PET					43 // ��׽�����������
#define MANUELROLE_FLY_PET_STAND				44
#define MANUELROLE_FLY_PET_WALK					45
#define MANUELROLE_RIDE_BIRD_STAND				46
#define MANUELROLE_RIDE_BIRD_WALK				47
#define MANUELROLE_QIANG_NORMAL_ATTACK			48
#define MANUELROLE_QIANG_SKILL_ATTACK			49
#define MANUELROLE_RIDE_QL						50


#define SYSTEM_BG_MUSIC_KEY						"SYSTEM_BG_MUSIC"
#define SYSTEM_EF_SOUND_KEY						"SYSTEM_EF_SOUND"
#define SYSTEM_SHOW_OTHER_KEY					"SYSTEM_SHOW_OTHER"
#define SYSTEM_SHOW_NAME_KEY					"SYSTEM_SHOW_NAME"
// monster�Ķ�����ԭ�����泯�ұߵġ�
#define MONSTER_MAP_STAND						0
#define MONSTER_MAP_MOVE						1
#define MONSTER_STAND							2
#define MONSTER_DEFENCE							3
#define MONSTER_DODGE							4
#define MONSTER_HURT							5
#define MONSTER_DIE								6
#define MONSTER_ATTACK							7
#define MONSTER_SKILL_ATTACK					8
#define MONSTER_FLEE_SUCCESS					9
#define MONSTER_FLEE_FAIL						10
#define MONSTER_MOVE_TO_TARGET					11
// private static final byte MONSTER_MOVE_BACK = 12;

//���ӵĶ���
#define FLAG_ESCORT_1							0//�ھ�
#define FLAG_TEAM_1								1
#define FLAG_SUI_DYNASTY_1						2//�����
#define FLAG_TAN_DYNASTY_1						3
#define FLAG_TUJUE_DYNASTY_1					4//ͻ��
#define FLAG_ESCORT_2							5//�ھ�
#define FLAG_TEAM_2								6
#define FLAG_SUI_DYNASTY_2						7//�����
#define FLAG_TAN_DYNASTY_2						8
#define FLAG_TUJUE_DYNASTY_2					9//ͻ��
//#define EFFECT_LEVEL_UP							900
//#define EFFECT_TASK_DONE						901
//#define EFFECT_SITE								902
#define EFFECT_DRITICAL							26
//#define EFFECT_ATK_BY_MAGIC						904
//#define EFFECT_ATK_BY_PHY						905
//#define EFFECT_ATK_BACKWARDS					906
#define EFFECT_MANA_FULL						20
//#define EFFECT_MAGIC_ATK						909
#define EFFECT_BLOCK							23//38
#define EFFECT_DODGE							25//35


// ���Ķ���
#define RIDEPET_STAND							0
#define RIDEPET_MOVE							1

// �������������
#define TYPE_MANUALROLE							1
#define TYPE_ENEMYROLE							2
#define TYPE_EUDEMON							3
#define TYPE_RIDEPET							4

// ����
#define FACE_LEFT								0
#define FACE_RIGHT								1

// layer z
#define MAPLAYER_Z								0
#define MAP_MASKLAYER_Z							0
#define MAP_UILAYER_Z							1
#define DIRECT_KEY_TOP_Z						2
#define UILAYER_Z								3
#define TRADE_LAYER_Z							4
//������ʾ��Ϣz��
#define CHAT_Z									90
#define CHAT_RECORD_MANAGER_Z					91
#define CHAT_INPUT_Z							92
//�Ի��� TOP
#define UIDIALOG_Z								99
#define UISYNLAYER_Z							100
//������ɰ�z��
#define SPEEDBAR_MASK_Z							101

// layer tag
#define MAPLAYER_TAG							1
#define LOGIN_MAPLAYER_TAG                      888

#define BATTLEMAPLAYER_TAG							3001

#define UILAYER_TAG								2
// ��������Ϸ�����е�UItag
//��������
#define UILAYER_ATTRIB_TAG						3	
//��������
#define UILAYER_PET_ATTRIB_TAG					4
//�����б�
#define UILAYER_TASK_LIST_TAG						5
//����б�
#define UILAYER_PLAYER_LIST_TAG					6
//�����б�
#define UILAYER_REQUEST_LIST_TAG					7
//���а�
#define	UILAYER_PAIHANG_TAG					8			
//�����б�
#define UILAYER_GOOD_FRIEND_LIST_TAG				9
//�̵�
#define UILAYER_NPCSHOP_TAG					10
//ս������
#define UILAYER_BATTLE_SKILL_TAG			11

//��ħ������tag
#define SMGAMESCENE_TAG							3000
//��ħս������tag
#define SMBATTLESCENE_TAG							3002
//��ħ��½����tag
#define SMLOGINSCENE_TAG                        3003

//DENA sdk��ʼ������
#define DENA_SDK_LOGIN_SCENE_TAG             3004

// ��Ӫ
#define CAMP_NAME_WU		NDCommonCString("wu")
#define CAMP_NAME_TANG		NDCommonCString("CampTang")
#define CAMP_NAME_SUI		NDCommonCString("CampSui")
#define CAMP_NAME_TU		NDCommonCString("CampTuJue")

#endif