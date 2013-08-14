---------------------------------------------------
--描述: 精英特权数据配置
--时间: 2013.4.26
--作者: tzq
---------------------------------------------

EPDataConfig = {}
local p = EPDataConfig;

--精英特权类型
p.E_EP_TYPE =
{
	EP_TYPE_BEGIN = 0,
	EP_TYPE_SPORT = 1,						--竞技场挑战次数增加3次
	EP_TYPE_EQUIP_UPGRAGE = 2,				--强化装备暴击几率增加（vip3生效）        

	
	
	--祭祀免費功能
	EP_TYPE_SACRIFICE_SHENNONG_TIME = 3,	--每日免费祭祀神农3次（次日生效）	
	EP_TYPE_SACRIFICE_PANGU_TIME = 19,		--每日免费祭祀盘古2次（次日生效）	
	EP_TYPE_SACRIFICE_FUXI_TIME = 5,		--每日免费祭祀伏羲2次（次日生效）
	EP_TYPE_SACRIFICE_NVWA_TIME = 6,		--每日免费祭祀女娲2次（次日生效）
	--祭祀增強按鈕
	EP_TYPE_SACRIFICE_SHENNONG_MONEY = 8,	--祭祀神农基础银币增加20%	
	EP_TYPE_SACRIFICE_FUXI_REPUTE = 15,		--祭祀伏羲基础声望增加20%	
	EP_TYPE_SACRIFICE_NVWA_STONE = 11,		--祭祀女娲额外获得一个宝石
	--徵收特權功能
	EP_TYPE_LEVY_MONEY_FIRST = 12,			--征收银币增加20%
	EP_TYPE_LEVY_MONEY_SECOND = 20,			--征收银币增加50%
	EP_TYPE_LEVY_DOUBLE = 22,				--征收有几率两倍暴击
	
	EP_TYPE_HISTORIC_TIME = 16,				--每天多三次免费古迹寻宝
	EP_TYPE_GRAIN_TIME = 14,				--运粮次数额外增加一次
	

	EP_TYPE_MAKE_FIRST_HOLE = 13,			--给100级装备打一个额外的孔
	EP_TYPE_MAKE_HOLE_SECOND = 18,			--给100级装备打第二个额外的孔
	
	
	EP_TYPE_SUCCINCT = 7,					--每天免费至尊洗一次（次日生效）
	EP_TYPE_INSTANCE_MONEY_FIRST = 9,		--副本银币掉落翻倍


	EP_TYPE_DINNER_STAMINA = 4,				--宴会获得军令几率提升20%
	EP_TYPE_DINNER_MONEY = 17,				--宴会获得基础银币增加30%
	EP_TYPE_DINNER_STAMINA_FIRST = 10,		--宴会获得军令时，出两个概率增加30%
	EP_TYPE_DINNER_STAMINA_SECOND = 21,		--宴会获得军令时，出两个概率增加70%


	EP_TYPE_EXTRA_STAMINA = 23,				--每天免费获得3个额外的军令（次日生效）
	EP_TYPE_INSTANCE_MONEY_SECOND = 24,		--副本银币掉落x5倍					
	
	EP_TYPE_END,
};

--MsgElitePrivilege.tbElPriInfo  { {byte bType, int nValue}, {byte bType, int nValue},}
function p.GetEPValue(eEpType)
	
	local ret = MsgElitePrivilege.tbElPriInfo[eEpType];
	
	if ret == nil then
		return 0;
	else
		return ret;
	end
end


function p.TestElietPrivilege()
	
	MsgElitePrivilege.tbElPriInfo = {};
	
	for i = 1, 25 do
		local tbInfo = {};
		tbInfo.bType = i;
		tbInfo.nValue = 7;
		MsgElitePrivilege.tbElPriInfo[tbInfo.bType] = tbInfo.nValue;
	end
	
end








