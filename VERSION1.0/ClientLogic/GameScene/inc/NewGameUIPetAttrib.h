/*
 *  NewGameUIPetAttrib.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_GAME_UI_PET_ATTRIB_H_
#define _NEW_GAME_UI_PET_ATTRIB_H_

#include "NDScene.h"
#include "ImageNumber.h"
#include "NDUICustomView.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDSprite.h"
#include "NDCommonControl.h"
#include "GameUIAttrib.h"

using namespace NDEngine;

namespace NDEngine 
{
	//////////////////////////////////////////
	
	class PetAttrInfo : public AttrInfo
	{
		DECLARE_CLASS(PetAttrInfo)
		
		void OnClickNDScrollLayer(NDScrollLayer* layer); override
		
		void OnButtonClick(NDUIButton* button); override
	};
	
#pragma mark 属性cell
	class NDPetPropCell : 
	public NDUINode
	{
		DECLARE_CLASS(NDPetPropCell)
		
		NDPetPropCell();
		
		~NDPetPropCell();
		
	public:
		void Initialization(std::string str, unsigned int uiCur, unsigned int uiMax); override
		
		void draw(); override
		
		void SetNum(unsigned int uiCur, unsigned int uiMax);
		
	private:
		NDUILabel	*m_lbKey, *m_lbValue;
		NDPicture	*m_picBg, *m_picFocus;
		ccColor4B	m_clrFocusText, m_clrNormalText;
		
		NDUIImage   *m_imageStateBar;
		NDUIRecttangle *m_rectProcess;
		
		unsigned int m_uiCur, m_uiMax;
		
		float m_fPercent;
	};
	
	class NDNamePropCell : public NDPropCell
	{
		DECLARE_CLASS(NDNamePropCell)
		
	public:

		void Initialization(); override
	};
	
	/*
	class NewGamePetNode : public NDUILayer
	{
		DECLARE_CLASS(NewGamePetNode)
	public:
		NewGamePetNode();
		~NewGamePetNode();
		
		void Initialization(bool bSelf=true); hide
		void draw(); override
		//设置宠物显示位置,相对于屏幕左上角
		void SetDisplayPos(CCPoint pos);
	private:
		CCPoint m_petPostion;
		bool	m_faceRightPet;
		NDNode	*m_petParent;
		bool	m_bSelf;
		NDSprite *m_Sprite;
	public:
		static int lookface;
	}; */
	
	/*
	class NewGameUIPetAttrib : 
	public NDUILayer, 
	public NDUIButtonDelegate, 
	public NDUIEditDelegate,
	public NDUICustomViewDelegate,
	public NDUITableLayerDelegate,
	public NDUIDialogDelegate,
	public NDPropSlideBarDelegate
	{
		friend class AttrInfo;
	public:
		enum ePetAttrBasic 
		{
			ePAB_Begin = 0,
			ePAB_LiLiang = ePAB_Begin,
			ePAB_TiZhi,
			ePAB_MinJie,
			ePAB_ZhiLi,
			ePAB_End,
		};
		
		enum ePetAttrExt
		{
			ePABE_Begin = 0,
			ePABE_GrowRate = ePABE_Begin,
			ePABE_HpRate,
			ePABE_MpRate,
			ePABE_PhyAtkRate,
			ePABE_PhyDefRate,
			ePABE_MagAtkRate,
			ePABE_MagDefRate,
			ePABE_SpeedRate,
			ePABE_End,
		};
	public:
		DECLARE_CLASS(NewGameUIPetAttrib)
		NewGameUIPetAttrib();
		~NewGameUIPetAttrib();
		
		static NewGameUIPetAttrib* GetInstance();
	private:
		static NewGameUIPetAttrib *s_intance;
	public:
		void Initialization(bool bSelf=true); hide
		void draw(); override
		void OnButtonClick(NDUIButton* button); override
		bool OnCustomViewConfirm(NDUICustomView* customView); override
		void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
		void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
		void UpdateGameUIPetAttrib();
		static std::string getPetType(int type);
		
		// new
		void OnPropSlideBarChange(NDPropSlideBar* bar, int change); override
		void SetVisible(bool visible); override
		void AddPropAlloc(NDUINode* parent);
		void AddProp(NDUINode* parent);
		void ShowAttrInfo(bool show);
	private:
		void ShowBasic();
		void ShowDetail();
		void ShowAdvance();
		
		void UpdateBasicData(int eProp, int iMin, int iMax);
		void UpdateDetailData(int eProp, int value);
		void UpdateAdvanceData(int eProp, int value);
		
		//void changeTitleFocus(int iTitleType);
		//void changeTitleImage(int iTitleType, bool bFocus);
		
		bool UpdateDetailPetName(std::string str);
		
		void setBattlePetValueToPetAttr();
		void updatePoint();
		void sendAction();
		
		void UpdateStrucPoint();
		
		// new 
		bool changePointFocus(int iPointType);
		
		void InitPropAlloc();
		
		void InitProp();
		
		void SetPlusOrMinusPicture(int eProp, bool plus, bool focus);
		void SetPropTextFocus(int eProp, bool focus);
		void UpdatePorpText(int eProp);
		void UpdatePorpAlloc();
		void UpdateSlideBar(int eProp);
		
	private:
		NDPicture *m_picBasic, *m_picBasicDown; NDUIButton *m_btnBasic;				//基本
		NDPicture *m_picDetail, *m_picDetailDown; NDUIButton *m_btnDetail;			//详细
		NDPicture *m_picAdvance, *m_picAdvanceDown; NDUIButton *m_btnAdvance;		//高级
		
		NDUILayer		*m_framePet;								//petframe
		NDUILabel		*m_lbName, *m_lbLevel, *m_lbZhuRen;
		NDUILabel		*m_lbHP, *m_lbMP, *m_lbExp;
		
		NewGamePetNode		*m_GamePetNode;
		
		NDUILayer		*m_layerPet;
		NDStateBar		*m_stateBarHP, *m_stateBarMP, *m_stateBarExp;
		
		NDUILabel		*m_lbCurProp;
		ImageNumber *m_imageNumTotalPoint, *m_imageNUmAllocPoint;	
		NDPicture		*m_picMinus;
		NDUIImage		*m_imageMinus;	
		
		NDUITableLayer  *m_tableLayerBasic;
		NDUITableLayer  *m_tableLayerDetail;
		NDUITableLayer	*m_tableLayerAdvance;
		
		enum enumTilteBtnState 
		{
			eTBS_Begin = 0,
			eTBS_Basic = eTBS_Begin,
			eTBS_Detail,
			eTBS_Advance,
			eTBS_End,
		};
		
		enumTilteBtnState m_enumTBS;
		
		int m_iFocusTitle;// 0-basic,1-detail, 2-advance
		
		bool m_bSelf;
		
	public:
		struct _stru_point 
		{
			enum  enumPointState
			{
				ps_begin   = 0,
				ps_liliang = ps_begin,
				ps_tizhi,
				ps_minjie,
				ps_zhili,
				ps_end,
			};
			struct point_state 
			{
				
				int iPoint;		//玩家分配了多少点
				int iFix;		//固定多少点
				point_state()
				{
					iPoint = 0; iFix = 0;
				}
			};
			_stru_point()
			{
				iTotal = 0; iAlloc= 0;
			}
			bool IsAlloc(enumPointState ePS)
			{
				if (ePS < ps_begin || ePS >= ps_end) return false;
				
				return m_psProperty[ePS].iPoint > 0;
			}
			int GetPoint(enumPointState ePS)
			{
				if (ePS < ps_begin || ePS >= ps_end) 
				{
					return 0;
				}
				return m_psProperty[ePS].iPoint + m_psProperty[ePS].iFix;
			}
			int GetMinPoint(enumPointState ePS)
			{
				return this->iAlloc-m_psProperty[ePS].iPoint;
			}
			bool VerifyAllocPoint()
			{
				int iPoint = 0;
				for (int i = ps_begin; i< ps_end; i++) 
				{
					iPoint += m_psProperty[i].iPoint;
				}
				return iPoint == iAlloc;
			}
			bool SetAllocPoint(enumPointState ePS, int point)
			{
				if (ePS < ps_begin || ePS >= ps_end) return false;
				
				int tmp = point-m_psProperty[ePS].iPoint;
				
				if (iAlloc+tmp > iTotal) return false;
				
				iAlloc += tmp;
				
				m_psProperty[ePS].iPoint = point;
				
				return true;
			}
			void reset() { memset(this, 0, sizeof(*this)); }
			int iTotal; //可分配点数
			int iAlloc; //已分配点数
			point_state m_psProperty[ps_end];
		};
		
		// 0 normal, 1 focus
		NDPropAllocLayer *m_pointFrame[_stru_point::ps_end];
		NDUIButton		*m_btnPointTxt[_stru_point::ps_end];
		NDUIButton		*m_btnPointMinus[_stru_point::ps_end]; NDPicture *m_picPointMinus[_stru_point::ps_end][2];
		NDUIButton		*m_btnPointPlus[_stru_point::ps_end];  NDPicture *m_picPointPlus[_stru_point::ps_end][2];
		NDUIButton		*m_btnPointCur[_stru_point::ps_end];
		
		_stru_point m_struPoint;
		
		NDUILayer *m_layerPropAlloc, *m_layerProp;
		
		NDUILabel *m_lbTotal, *m_lbAlloc;
		
		NDPropSlideBar *m_slideBar;
		
		NDUIButton *m_btnCommit;
		
		PetAttrInfo *m_attrInfo;
		bool m_attrInfoShow;
		
		int m_iFocusPointType;
		
		//BasePropNode *m_BasePropNode[ePAB_End];
		//LayerProp	*m_BaseLayerProp[ePABE_End];
		
	public:
		static std::string str_PET_ATTR_NAME; // 名字STRING
		static int int_PET_ATTR_LEVEL; // 等级INT
		static int int_PET_ATTR_EXP; // 经验INT
		static int int_PET_ATTR_LIFE; // 生命值INT
		static int int_PET_ATTR_MAX_LIFE; // 最大生命值INT
		static int int_PET_ATTR_MANA; // 魔法值INT
		static int int_PET_ATTR_MAX_MANA; // 最大魔法值INT
		static int int_PET_ATTR_STR; // 力量INT
		static int int_PET_ATTR_STA; // 体质INT
		static int int_PET_ATTR_AGI; // 敏捷INT
		static int int_PET_ATTR_INI; // 智力INT
		static int int_PET_ATTR_LEVEL_INIT; // 初始等级INT
		static int int_PET_ATTR_STR_INIT; // 初始力量INT
		static int int_PET_ATTR_STA_INIT; // 初始体质INT
		static int int_PET_ATTR_AGI_INIT; // 初始敏捷INT
		static int int_PET_ATTR_INI_INIT; // 初始智力INT
		static int int_PET_ATTR_LOYAL; // 忠诚度INT
		static int int_PET_ATTR_AGE; // 寿命INT
		static int int_PET_ATTR_FREE_SP; // 剩余技能点数INT
		static int int_PET_PHY_ATK_RATE;//物攻资质
		static int int_PET_PHY_DEF_RATE;//物防资质
		static int int_PET_MAG_ATK_RATE;//法攻资质
		static int int_PET_MAG_DEF_RATE;//法防资质
		static int int_PET_ATTR_HP_RATE; // 生命资质
		static int int_PET_ATTR_MP_RATE; // 魔法资质
		static int int_PET_MAX_SKILL_NUM;//最大可学技能数
		static int int_PET_SPEED_RATE;//速度资质
		
		static int int_PET_PHY_ATK_RATE_MAX;//物攻资质上限
		static int int_PET_PHY_DEF_RATE_MAX;//物防资质上限
		static int int_PET_MAG_ATK_RATE_MAX;//法攻资质上限
		static int int_PET_MAG_DEF_RATE_MAX;//法防资质上限
		static int int_PET_ATTR_HP_RATE_MAX; // 生命资质上限
		static int int_PET_ATTR_MP_RATE_MAX; // 魔法资质上限
		static int int_PET_SPEED_RATE_MAX;//速度资质上限
		
		static int int_PET_GROW_RATE;// 成长率
		static int int_PET_GROW_RATE_MAX;// 成长率
		static int int_PET_HIT ;//命中
		
		static int int_ATTR_FREE_POINT; //自由点数
		static int int_PET_ATTR_LEVEUP_EXP; // 升级经验
		static int int_PET_ATTR_PHY_ATK; // 物理攻击力INT
		static int int_PET_ATTR_PHY_DEF; // 物理防御INT
		static int int_PET_ATTR_MAG_ATK; // 法术攻击力INT
		static int int_PET_ATTR_MAG_DEF; // 法术抗性INT
		static int int_PET_ATTR_HARD_HIT;// 暴击
		static int int_PET_ATTR_DODGE;// 闪避
		static int int_PET_ATTR_ATK_SPEED;// 攻击速度
		static int int_PET_ATTR_TYPE;// 类型
		static int int_PET_ATTR_LOOKFACE;//外观
		static int bindStatus;//绑定状态
		static int ownerid;
		static std::string ownerName;// 主人名
	};*/
}
#endif // _NEW_GAME_UI_PET_ATTRIB_H_