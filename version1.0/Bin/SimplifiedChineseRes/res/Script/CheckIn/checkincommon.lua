---------------------------------------------------
--描述: 签到一些数据以及公共接口实现
--时间: 2013.7.31
--作者: tzq
---------------------------------------------------
CheckInCommon = {}
local p = CheckInCommon;

--一年中每个月对应的天数
p.Month_day_num = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

--2013年一月一日为星期二,所以这个值初始化为1
p.BeginYear = 2013;
p.MonthFlag = 1;

--获取是否为闰年的标志
function p.GetLeapYearFlag(nYear)
	if (math.fmod(nYear, 4) == 0 and math.fmod(nYear, 100) == 0 ~= 0) 
	   or math.fmod(nYear, 400) == 0 then
		return 1;
	else
		return 0;
	end
end

--获取某月的天数
function p.GetDaysFromMonth(nYearIndex, nMonIndex)
	local nRet = p.Month_day_num[nMonIndex];
	
	--传入数据校验
	if nYearIndex < p.BeginYear or 
	   nYearIndex > 2030 or
	   nMonIndex < 1 or
	   nMonIndex > 12 then
		return 0;
	end
	
	if nMonIndex == 2 then
		local bLeapYearFlag = p.GetLeapYearFlag(p.BeginYear);
		if bLeapYearFlag then
			nRet = nRet + 1;
		end 
	end
	
	return nRet;
end


--根据传入的年月，获取这个月一号为星期几
function p.GetWeekFromYearAndMonth(nYear, nMonth)
	local nRet = 0;
	local nFlag = p.MonthFlag;
	
	--传入数据校验
	if nYear < p.BeginYear or 
	   nYear > 2030 or
	   nMonth < 1 or
	   nMonth > 12 then
		return nRet;
	end
	
	local nNum = nYear - p.BeginYear;
	
	for i = 1, nNum do
		local bLeapYearFlag = p.GetLeapYearFlag(p.BeginYear + i);
		nFlag = nFlag + bLeapYearFlag;
	end
	
	--计算出当前年一月对应的flag
	nFlag = math.fmod(nNum * 365 + nFlag, 7);
	
	for i = 1, nMonth - 1 do
		nFlag = math.fmod(nFlag + p.Month_day_num[i], 7); 
	end
	
	if nMonth > 2 and
	   p.GetLeapYearFlag(nYear) == 1 then
	   nFlag = math.fmod(nFlag + 1, 7);
	end
	
	nFlag = math.fmod(nFlag + 1, 7);
	
	return nFlag;
end

function p.GetDayStr(iYear, iMonth, iDay)
    local str = "";
    str = iYear.."年"..iMonth.."月"..iDay.."日";
	return str;
end


