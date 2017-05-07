* Regressions with  Indiv FE, Weather by hour
* Evaluating CO2 emissions

******* Housekeeping;
# delimit ;             * assign ';' as line-ender;
version 13;           * tell Stata to use version 13, so that code will still work in future versions;
clear;                * clear anything in memory left over from previous runs;
capture log close;    * close log from previous runs (capture prevents error if no log was open);
set more off;         * allow log to be outputted without requiring keypresses;
set logtype text; 
clear matrix;
clear mata;


cd /Users/jho81/Desktop/SummerWork/;          * set working directory;

log using VPP_Environmental_Pooled.log, replace;        *start log file;
set matsize 2000;      * set largest matrix size;
set memory 256m;       * set memory to 256 MB;

****************************************REGRESSIONS FOR TOU***********************************;

/*
clear all;
use datausedinanalysis.dta;

drop if treat > 1 & treat<6;
drop if treat == 9;
drop if weekday>5;
drop if ac == 0;

drop bsdewp_1_ bsdewp_2_ bsdewp_3_ bsdewp_4_ bstemp_1_ bstemp_2_ bstemp_3_ bstemp_4_;  

gen day = day(date); 
sort accountid date datetime;

drop treat2 treat3 treat4 treat5 treat9;

collapse (first) ac_indicator bsdewp_1 bsdewp_2 bsdewp_3 bsdewp_4 bstemp_1 bstemp_2 bstemp_4 day dewp hr_weekday id
identity ihdfailure meterid month pct_failure rates readingdatetime technology temp treat treat1 treat6 treat7 treat8  
dweekday weeknum age income maxtemp failure_pct failure_ihd treatment_received ac btreat2 btreat3 btreat4
btreat5 bbstemp1 bbstemp2 bbstemp3 bbstemp4 bbsdewp2 bbsdewp3 bbsdewp4 bcons (sum) measuredkwh, by (accountid date hour);

save dataAnalysisSortedVPP.dta, replace;

*/

/* clear;
import excel zipCodeMerge.xlsx, firstrow;
destring Zip, replace;
describe;

format accountid %12.0g;
save zipCodeMerge.dta, replace;
*/

clear all; 
use dataAnalysisSortedVPP.dta;
* drop ac;

merge m:1 accountid using zipCodeMerge.dta;
drop if _merge < 3;
drop _merge;

tab Zip;
sum Zip;

gen clusterGroup = Zip;
replace clusterGroup = 1 if Zip == 73026 | Zip == 73070 | Zip == 73107 | Zip == 73120 | ///
Zip == 73132 | Zip == 73159 | Zip == 73165 | Zip == 74857 | Zip == 73069;

tab clusterGroup;

gen logkwh = 0;
replace logkwh = ln(measuredkwh);
drop ac_indicator;

matrix PercentageChangeEmissionskWh = J(24, 3, 0);

local tt 0;

global priceLevel1 = 0.045;
global priceLevel2 = 0.113;
global priceLevel3 = 0.230;
global priceLevel4 = 0.460;
global priceLevel5 = 0.460;

gen priceLevel = 1;
gen critical = 0;
gen CPPprice = 0;

	
* run critical days with VPP separately
	
*critical period residential rates, according to the Price Signals file;


* price level 2 designated times;
replace priceLevel = 2 if month == 7 & day == 1 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 7 & day == 5 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 7 & day == 6 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 7 & day == 11 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 7 & day == 12 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 11 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 12 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 15 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 16 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 26 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 29 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 8 & day == 31 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 9 & day == 2 & hour >=14 & hour <= 19;
replace priceLevel = 2 if month == 9 & day == 13 & hour >=14 & hour <= 19;

replace priceLevel = 3 if month == 7 & day == 7 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 8 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 13 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 14 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 15 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 18 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 19 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 20 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 21 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 22 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 25 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 26 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 27 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 28 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 7 & day == 29 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 9 & hour >= 14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 10 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 17 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 18 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 19 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 22 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 23 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 24 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 25 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 8 & day == 30 & hour >=14 & hour <= 19;
replace priceLevel = 3 if month == 9 & day == 1 & hour >=14 & hour <= 19;

replace priceLevel = 4 if month == 8 & day == 1 & hour >=14 & hour <= 19;
replace priceLevel = 4 if month == 8 & day == 2 & hour >=14 & hour <= 19;
replace priceLevel = 4 if month == 8 & day == 3 & hour >=14 & hour <= 19;
replace priceLevel = 4 if month == 8 & day == 4 & hour >=14 & hour <= 19;
replace priceLevel = 4 if month == 8 & day == 5 & hour >=14 & hour <= 19;
replace priceLevel = 4 if month == 8 & day == 8 & hour >=14 & hour <= 19;

replace priceLevel = 5 if month == 7 & day == 8 & hour >=13 & hour <= 19;
replace priceLevel = 5 if month == 7 & day == 15 & hour >=13 & hour <= 21;
replace priceLevel = 5 if month == 8 & day == 8 & hour >=16 & hour <= 18;
replace priceLevel = 5 if month == 8 & day == 24 & hour >=16 & hour <= 18;
replace priceLevel = 5 if month == 9 & day == 1 & hour >=15 & hour <= 19;
replace priceLevel = 5 if month == 9 & day == 13 & hour >=13 & hour <= 17;
replace priceLevel = 5 if month == 9 & day == 27 & hour >=16 & hour <= 18;


gen VPPDay = 1;	

 
replace VPPDay = 2 if month == 7 & day == 1 | month == 7 & day == 5 | 
month == 7 & day == 6 | month == 7 & day == 11 | month == 7 & day == 12 | 
month == 8 & day == 11 | month == 8 & day == 12 | month == 8 & day == 15 | 
month == 8 & day == 16 | month == 8 & day == 26 | month == 8 & day == 29 |
 month == 8 & day == 31 | month == 9 & day == 2 | month == 9 & day == 13 ;

replace VPPDay = 3 if month == 7 & day == 7  | month == 7 & day == 8 |
month == 7 & day == 13 | month == 7 & day == 14 | month == 7 & day == 15 | 
month == 7 & day == 18 | month == 7 & day == 19 | month == 7 & day == 20 | 
month == 7 & day == 21 | month == 7 & day == 22 | month == 7 & day == 25 | 
month == 7 & day == 26 | month == 7 & day == 27 | month == 7 & day == 28 | 
month == 7 & day == 29 | month == 8 & day == 9 | month == 8 & day == 10 | 
month == 8 & day == 17 | month == 8 & day == 18 | month == 8 & day == 19 | 
month == 8 & day == 22 | month == 8 & day == 23 | month == 8 & day == 24 | 
month == 8 & day == 25 | month == 8 & day == 30 | month == 9 & day == 1;

replace VPPDay = 4 if month == 8 & day == 1 | month == 8 & day == 2 | 
month == 8 & day == 3 | month == 8 & day == 4 | month == 8 & day == 5 | 
month == 8 & day == 8;

replace VPPDay = 5 if month == 7 & day == 8 | month == 7 & day == 15 | 
month == 8 & day == 8 | month == 8 & day == 24 | month == 9 & day == 1 | 
month == 9 & day == 13 | month == 9 & day == 27;
	




* All CPP days are consolidated into a single classification, VPP Day 5;


keep measuredkwh logkwh treat6 treat7 treat8 bstemp_* bsdewp_* identity VPPDay hour month day treat date;

drop if logkwh == NA;
drop if logkwh == .;
saveold VPP_for_R.dta, version(12) replace;


local quant = 0.9;
local quantDisplay = `quant' * 100;

/*
forval VPPindex = 2/4 {;
	forval tt=0/23 {;
	
		eststo: bsqreg logkwh treat6 treat7 treat8 bstemp_* bsdewp_* if hour==`tt' & VPPDay == `VPPindex',  quantile(`quant') reps(100);
	
		*prediction for baseline control;
	
		local index = `tt' + 1;
		matrix PercentageChangeEmissionskWh[`index', 1] = _b[treat6]; 
		matrix PercentageChangeEmissionskWh[`index', 2] = _b[treat7];
		matrix PercentageChangeEmissionskWh[`index', 3] = _b[treat8];
	
		replace kWhPercentChange_treat6 = exp(PercentageChangeEmissionskWh[`index', 1])-1 if treat == 1 & `tt' == hour & VPPDay == `VPPindex';
		replace kWhPercentChange_treat7 = exp(PercentageChangeEmissionskWh[`index', 2])-1 if treat == 1 & `tt' == hour & VPPDay == `VPPindex';
		replace kWhPercentChange_treat8 = exp(PercentageChangeEmissionskWh[`index', 3])-1 if treat == 1 & `tt' == hour & VPPDay == `VPPindex';
	
		replace kWhPercentSE_treat6 = _se[treat6] if treat == 1 & `tt' == hour & VPPDay == `VPPindex';
		replace kWhPercentSE_treat7 = _se[treat7] if treat == 1 & `tt' == hour & VPPDay == `VPPindex';
		replace kWhPercentSE_treat8 = _se[treat8] if treat == 1 & `tt' == hour & VPPDay == `VPPindex';
	};
	esttab using "VPP`VPPindex'_noweekend_PooledQ`quantDisplay'.csv", replace se pr2 r2;
	eststo clear;
};
	*/
	
	
	drop if VPPDay > 4 | VPPDay < 2;
	
	save PooledDemographics_VPP_Q`quantDisplay'.dta, replace;
	
	
	# delimit;
	
	local quant = 0.9;
	local quantDisplay = `quant' * 100;
	#delimit;
	clear;
	
	
	cd /Users/jho81/Desktop/SummerWork/;          * set working directory;
	
	use Quantile`quantDisplay'_BootstrapResults.dta;
	
	/*rename VPPindex VPPDay;
	rename hourIndex hour;
	
	rename treat6_std kWhPercentSE_treat6;
	rename treat7_std kWhPercentSE_treat7;
	rename treat8_std kWhPercentSE_treat8;
	
	gen kWhPercentChange_treat6 = exp(treat6_coeff)-1;
	gen kWhPercentChange_treat7 = exp(treat7_coeff)-1;
	gen kWhPercentChange_treat8 = exp(treat8_coeff)-1;
	
	save Quantile`quantDisplay'_BootstrapResults.dta, replace;
	*/
	
	clear;
	use VPP_for_R.dta;
	
	merge m:1 VPPDay hour using Quantile`quantDisplay'_BootstrapResults.dta;
	drop _merge;
	
	gen kWhPercentChange_Treat8ciUpper = kWhPercentChange_treat8 + 1.96*kWhPercentSE_treat8 ;
	gen kWhPercentChange_Treat8ciLower = kWhPercentChange_treat8 - 1.96*kWhPercentSE_treat8 ;
	
	save PooledDemographics_VPP_Q`quantDisplay'.dta, replace;
	keep if (month == 7 & day == 6) | (month == 8 & day == 4) | (month == 8 & day == 23);
	sort date treat;
	collapse (first) treat6 treat7 treat8 (mean) measuredkwh kWhPercentChange_treat6 kWhPercentChange_treat7 
	kWhPercentChange_treat8 kWhPercentChange_Treat8ciUpper kWhPercentChange_Treat8ciLower, by (date hour treat);
	save graphsFileVPP_Q`quantDisplay'.dta, replace;
	
	
	clear;
	use graphsFileVPP_Q`quantDisplay'.dta;
	
	
	
	
	twoway (line measuredkwh hour if treat == 1 & date == 18814,  lcolor(black) mcolor(black))  ///
	(line measuredkwh hour if treat == 6 & date == 18814,  lcolor(blue) mcolor(blue)) ///
	(line measuredkwh hour if treat == 7 & date == 18814,  lcolor(red) mcolor(red)) ///
	(line measuredkwh hour if treat == 8 & date == 18814,  lcolor(green) mcolor(green)), ///
	title("Electricity Consumption (kwh) vs Hour, VPP2 ") ///
	ytitle("Electricity Consumption (kwh)")  ///
	xtitle("Hour") scheme(s1color)   legend(label(1 "control") label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT")) ///
	xlabel(#5, grid)  ylabel(#5, grid) ysc(r(0 5)) xsc(r(0 25)) saving(graphConsumption_CPP, replace);
	
	graph export graphConsumption_VPP2_Q`quantDisplay'.png,   replace;
	
	
	
	twoway (line measuredkwh hour if treat == 1 & date == 18862,  lcolor(black) mcolor(black))  ///
	(line measuredkwh hour if treat == 6 & date == 18862,  lcolor(blue) mcolor(blue)) ///
	(line measuredkwh hour if treat == 7 & date == 18862,  lcolor(red) mcolor(red)) ///
	(line measuredkwh hour if treat == 8 & date == 18862,  lcolor(green) mcolor(green)), ///
	title("Electricity Consumption (kwh) vs Hour, VPP3 day ") ///
	ytitle("Electricity Consumption (kwh)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(1 "control") label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT")) ///
	xlabel(#5, grid)   ylabel(#5, grid) ysc(r(0 5)) xsc(r(0 25)) saving(graphConsumption_nonCPP.ps, replace);
	
	graph export graphConsumption_VPP3_Q`quantDisplay'.png,   replace;
	
	twoway (line measuredkwh hour if treat == 1 & date == 18843,  lcolor(black) mcolor(black))  ///
	(line measuredkwh hour if treat == 6 & date == 18843,  lcolor(blue) mcolor(blue)) ///
	(line measuredkwh hour if treat == 7 & date == 18843,  lcolor(red) mcolor(red)) ///
	(line measuredkwh hour if treat == 8 & date == 18843,  lcolor(green) mcolor(green)), ///
	title("Electricity Consumption (kwh) vs Hour, VPP4 day ") ///
	ytitle("Electricity Consumption (kwh)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(1 "control") label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT")) ///
	xlabel(#5, grid)   ylabel(#5, grid) ysc(r(0 5)) xsc(r(0 25)) saving(graphConsumption_nonCPP.ps, replace);
	
	graph export graphConsumption_VPP4_Q`quantDisplay'.png,   replace;
	
	drop if treat!= 1;
	
	gen kWhPercentChange_treat6Display = kWhPercentChange_treat6*100;
	gen kWhPercentChange_treat7Display = kWhPercentChange_treat7*100;
	gen kWhPercentChange_treat8Display = kWhPercentChange_treat8*100;
	
	gen kWhChange_Treat8ciUpperDisplay = kWhPercentChange_Treat8ciUpper*100;
	gen kWhChange_Treat8ciLowerDisplay = kWhPercentChange_Treat8ciLower*100;
	
	
	twoway   (rarea kWhChange_Treat8ciUpperDisplay kWhChange_Treat8ciLowerDisplay hour if treat == 1 & date == 18814,  /// 
	color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4) sort) ///
	(scatter kWhPercentChange_treat6Display hour if treat == 1 & date == 18814, connect(l) lcolor(blue) mcolor(blue)) ///
	(scatter kWhPercentChange_treat7Display hour if treat == 1 & date == 18814, connect(l) lcolor(red) mcolor(red)) ///
	(scatter kWhPercentChange_treat8Display hour if treat == 1 & date == 18814, connect(l) lcolor(green) mcolor(green)), ///
	title("Percentage Change, Electricity (%) vs Hour, VPP2") ///
	ytitle("Percentage Change, Electricity Consumption (%)")  ///
	xtitle("Hour") scheme(s1color)   legend(label(1 "Web Portal") label(2 "Web Portal + IHD") label(3 "Web Portal + PCT")) ///
	xlabel(#5, grid)    xsc(r(0 25)) saving(graphpercentageConsumption_CPP, replace);
	
	graph export graphpercentageConsumption_VPP2_Q`quantDisplay'.png,   replace;
	
	
	
	twoway  (rarea kWhChange_Treat8ciUpperDisplay kWhChange_Treat8ciLowerDisplay hour if treat == 1 & date == 18862,  /// 
	color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4) sort) ///
	(scatter kWhPercentChange_treat6Display hour if treat == 1 & date == 18862,  connect(l) lcolor(blue) mcolor(blue)) ///
	(scatter kWhPercentChange_treat7Display hour if treat == 1 & date == 18862,  connect(l) lcolor(red) mcolor(red)) ///
	(scatter kWhPercentChange_treat8Display hour if treat == 1 & date == 18862,  connect(l) lcolor(green) mcolor(green)), ///
	title("Percentage Change, Electricity (%) vs Hour, VPP3") ///
	ytitle("Percentage Change, Electricity Consumption (%)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(1 "Web Portal") label(2 "Web Portal + IHD") label(3 "Web Portal + PCT")) ///
	xlabel(#5, grid)    xsc(r(0 25)) saving(graphpercentageConsumption_nonCPP, replace);
	
	graph export graphpercentageConsumption_VPP3_Q`quantDisplay'.png,   replace;
	
	twoway  (rarea kWhChange_Treat8ciUpperDisplay kWhChange_Treat8ciLowerDisplay hour if treat == 1 & date == 18843,  /// 
	color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4) sort) ///
	(scatter kWhPercentChange_treat6Display hour if treat == 1 & date == 18843,  connect(l) lcolor(blue) mcolor(blue)) ///
	(scatter kWhPercentChange_treat7Display hour if treat == 1 & date == 18843,  connect(l) lcolor(red) mcolor(red)) ///
	(scatter kWhPercentChange_treat8Display hour if treat == 1 & date == 18843,  connect(l) lcolor(green) mcolor(green)), ///
	title("Percentage Change, Electricity (%) vs Hour, VPP4") ///
	ytitle("Percentage Change, Electricity Consumption (%)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(1 "Web Portal") label(2 "Web Portal + IHD") label(3 "Web Portal + PCT")) ///
	xlabel(#5, grid)    xsc(r(0 25)) saving(graphpercentageConsumption_nonCPP, replace);
	
	graph export graphpercentageConsumption_VPP4_Q`quantDisplay'.png,   replace;
	
	
	
	
	# delimit ;
	clear;
	local quant = 0.9;
	local quantDisplay = `quant' * 100;
	use PooledDemographics_VPP_Q`quantDisplay'.dta, replace;
	
	drop if treat!= 1;

	sort identity date hour;
	* drop failure_pct failure_ihd hr_weekday id ihdfailure pct_failure rates treatment_received;
	
	
	sort VPPDay hour;
	collapse (mean) measuredkwh (semean) kwhSE = measuredkwh (first) kWhPercentChange_treat6 kWhPercentChange_treat7 kWhPercentChange_treat8
	kWhPercentSE_treat6 kWhPercentSE_treat7 kWhPercentSE_treat8 kWhPercentChange_Treat8ciUpper kWhPercentChange_Treat8ciLower,  by (VPPDay hour);
	
	
	gen kwhVar = kwhSE ^ 2;
	
	gen ConsumptionChangekwh_treat6 = measuredkwh * kWhPercentChange_treat6;
	gen ConsumptionChangekwh_treat7 = measuredkwh * kWhPercentChange_treat7;
	gen ConsumptionChangekwh_treat8 = measuredkwh * kWhPercentChange_treat8;
	
	gen ConsumptionChangevar_treat6 = kwhSE^2*kWhPercentChange_treat6^2+measuredkwh^2*kWhPercentSE_treat6^2;
	gen ConsumptionChangevar_treat7 = kwhSE^2*kWhPercentChange_treat7^2+measuredkwh^2*kWhPercentSE_treat7^2;
	gen ConsumptionChangevar_treat8 = kwhSE^2*kWhPercentChange_treat8^2+measuredkwh^2*kWhPercentSE_treat8^2;
	
	gen ConsumptionChangeSE_treat6 = ConsumptionChangevar_treat6^(1/2);
	gen ConsumptionChangeSE_treat7 = ConsumptionChangevar_treat7^(1/2);
	gen ConsumptionChangeSE_treat8 = ConsumptionChangevar_treat6^(1/2);
	
	
	gen Totalkwh_treat6 = measuredkwh + ConsumptionChangekwh_treat6;
	gen Totalkwh_treat7 = measuredkwh + ConsumptionChangekwh_treat7;
	gen Totalkwh_treat8 = measuredkwh + ConsumptionChangekwh_treat8;

	sort VPPDay;
	by VPPDay: egen TotalConsumptionChangevar_treat6 = sum(ConsumptionChangevar_treat6);
	by VPPDay: egen TotalConsumptionChangevar_treat7 = sum(ConsumptionChangevar_treat7);
	by VPPDay: egen TotalConsumptionChangevar_treat8 = sum(ConsumptionChangevar_treat8);
	
	gen TotalConsumptionChangeSE_treat6 = TotalConsumptionChangevar_treat6 ^.5;
	gen TotalConsumptionChangeSE_treat7 = TotalConsumptionChangevar_treat7 ^.5;
	gen TotalConsumptionChangeSE_treat8 = TotalConsumptionChangevar_treat8 ^.5;
	
	
	
	*specific for the emissions calculations;
	merge m:1 hour using Marginal_Emissions_SPP-2011.dta;
	drop _merge;
	
	rename CO2MarginalEmissionsCoeff2011 CO2MarginalEmissionsCoeff;
	rename SO2MarginalEmissionsCoeff2011 SO2MarginalEmissionsCoeff;
	rename NOXMarginalEmissionsCoeff2011 NOXMarginalEmissionsCoeff;
	
	rename CO2MarginalEmissionsSE2011 CO2MarginalEmissionsSE;
	rename SO2MarginalEmissionsSE2011 SO2MarginalEmissionsSE;
	rename NOXMarginalEmissionsSE2011 NOXMarginalEmissionsSE;
	
	
	
	
	gen CO2Emissions_Control = measuredkwh * CO2MarginalEmissionsCoeff;
	gen SO2Emissions_Control = measuredkwh * SO2MarginalEmissionsCoeff;
	gen NOXEmissions_Control = measuredkwh * NOXMarginalEmissionsCoeff;
	
	gen CO2Emissions_ControlVar = CO2MarginalEmissionsSE^2 * kwhSE^2 + measuredkwh^2*CO2MarginalEmissionsCoeff^2;
	gen SO2Emissions_ControlVar = SO2MarginalEmissionsSE^2 * kwhSE^2 + measuredkwh^2*SO2MarginalEmissionsCoeff^2;
	gen NOXEmissions_ControlVar = NOXMarginalEmissionsSE^2 * kwhSE^2 + measuredkwh^2*NOXMarginalEmissionsCoeff^2;
	
	gen CO2Emissions_ControlSE = CO2Emissions_ControlVar^(1/2);
	gen SO2Emissions_ControlSE = SO2Emissions_ControlVar^(1/2);
	gen NOXEmissions_ControlSE = NOXEmissions_ControlVar^(1/2);
	
	
	
	
	gen CO2EmissionsChange_treat6 = ConsumptionChangekwh_treat6 * CO2MarginalEmissionsCoeff; 
	gen SO2EmissionsChange_treat6 = ConsumptionChangekwh_treat6 * SO2MarginalEmissionsCoeff;
	gen NOXEmissionsChange_treat6 = ConsumptionChangekwh_treat6 * NOXMarginalEmissionsCoeff;
	
	gen CO2EmissionsChange_treat7 = ConsumptionChangekwh_treat7 * CO2MarginalEmissionsCoeff; 
	gen SO2EmissionsChange_treat7 = ConsumptionChangekwh_treat7 * SO2MarginalEmissionsCoeff;
	gen NOXEmissionsChange_treat7 = ConsumptionChangekwh_treat7 * NOXMarginalEmissionsCoeff;
	
	gen CO2EmissionsChange_treat8 = ConsumptionChangekwh_treat8 * CO2MarginalEmissionsCoeff; 
	gen SO2EmissionsChange_treat8 = ConsumptionChangekwh_treat8 * SO2MarginalEmissionsCoeff;
	gen NOXEmissionsChange_treat8 = ConsumptionChangekwh_treat8 * NOXMarginalEmissionsCoeff;
	
	gen CO2EmissionsVar_treat6 = ConsumptionChangekwh_treat6^2 * CO2MarginalEmissionsSE^2 + CO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat6^2; 
	gen SO2EmissionsVar_treat6 = ConsumptionChangekwh_treat6^2 * SO2MarginalEmissionsSE^2 + SO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat6^2;
	gen NOXEmissionsVar_treat6 = ConsumptionChangekwh_treat6^2 * NOXMarginalEmissionsSE^2 + NOXMarginalEmissionsCoeff^2*ConsumptionChangeSE_treat6^2;;
	
	gen CO2EmissionsVar_treat7 = ConsumptionChangekwh_treat7^2 * CO2MarginalEmissionsSE^2 + CO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat7^2; 
	gen SO2EmissionsVar_treat7 = ConsumptionChangekwh_treat7^2 * SO2MarginalEmissionsSE^2 + SO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat7^2;
	gen NOXEmissionsVar_treat7 = ConsumptionChangekwh_treat7^2 * NOXMarginalEmissionsSE^2 + NOXMarginalEmissionsCoeff^2*ConsumptionChangeSE_treat7^2;;
	
	gen CO2EmissionsVar_treat8 = ConsumptionChangekwh_treat8^2 * CO2MarginalEmissionsSE^2 + CO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat8^2; 
	gen SO2EmissionsVar_treat8 = ConsumptionChangekwh_treat8^2 * SO2MarginalEmissionsSE^2 + SO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat8^2;
	gen NOXEmissionsVar_treat8 = ConsumptionChangekwh_treat8^2 * NOXMarginalEmissionsSE^2 + NOXMarginalEmissionsCoeff^2*ConsumptionChangeSE_treat8^2;
	
	

	gen CO2EmissionsSTD_treat6 = CO2EmissionsVar_treat6 ^ (1/2);
	gen SO2EmissionsSTD_treat6 = SO2EmissionsVar_treat6 ^ (1/2);
	gen NOXEmissionsSTD_treat6 = NOXEmissionsVar_treat6 ^ (1/2);
	
	gen CO2EmissionsSTD_treat7 =  CO2EmissionsVar_treat7 ^ (1/2);
	gen SO2EmissionsSTD_treat7 = SO2EmissionsVar_treat7 ^ (1/2);
	gen NOXEmissionsSTD_treat7 = NOXEmissionsVar_treat7 ^ (1/2);
	
	gen CO2EmissionsSTD_treat8 = CO2EmissionsVar_treat8 ^ (1/2);
	gen SO2EmissionsSTD_treat8 = SO2EmissionsVar_treat8 ^ (1/2);
	gen NOXEmissionsSTD_treat8 = NOXEmissionsVar_treat8 ^ (1/2);
	
	gen CO2treat8EmissionsUpper = CO2EmissionsChange_treat8+1.96*CO2EmissionsSTD_treat8;
	gen CO2treat8EmissionsLower = CO2EmissionsChange_treat8-1.96*CO2EmissionsSTD_treat8;
	
	gen SO2treat8EmissionsUpper = SO2EmissionsChange_treat8+1.96*SO2EmissionsSTD_treat8;
	gen SO2treat8EmissionsLower = SO2EmissionsChange_treat8-1.96*SO2EmissionsSTD_treat8;
	
	gen NOXtreat8EmissionsUpper = NOXEmissionsChange_treat8+1.96*NOXEmissionsSTD_treat8;
	gen NOXtreat8EmissionsLower = NOXEmissionsChange_treat8-1.96*NOXEmissionsSTD_treat8;
	
	twoway (rarea CO2treat8EmissionsUpper CO2treat8EmissionsLower hour if VPPDay == 2,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter CO2EmissionsChange_treat6 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter CO2EmissionsChange_treat7 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter CO2EmissionsChange_treat8 hour if VPPDay == 2,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("CO2 Emissions Change vs Hr, VPP2") ///
	ytitle("CO2 Change (lb CO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(CO2Change1.ps, replace);
	
	graph export CO2Change1_VPP2_Q`quantDisplay'.png, replace;
	
	twoway (rarea SO2treat8EmissionsUpper SO2treat8EmissionsLower hour if VPPDay == 2,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter SO2EmissionsChange_treat6 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter SO2EmissionsChange_treat7 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter SO2EmissionsChange_treat8 hour if VPPDay == 2,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("SO2 Emissions Change vs Hr, VPP2") ///
	ytitle("SO2 Change (lb SO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(SO2Change1.ps, replace);
	
	graph export SO2Change1_VPP2_Q`quantDisplay'.png, replace;
	
	twoway (rarea NOXtreat8EmissionsUpper NOXtreat8EmissionsLower hour if VPPDay == 2,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter NOXEmissionsChange_treat6 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter NOXEmissionsChange_treat7 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter NOXEmissionsChange_treat8 hour if VPPDay == 2,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("NOX Emissions Change vs Hr, VPP2") ///
	ytitle("NOX Change (lb NOX)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(NOXChange1.ps, replace);
	
	graph export NOXChange_VPP2_Q`quantDisplay'.png,  replace;
	

	
	
	
	twoway (rarea CO2treat8EmissionsUpper CO2treat8EmissionsLower hour if VPPDay == 4,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter CO2EmissionsChange_treat6 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter CO2EmissionsChange_treat7 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter CO2EmissionsChange_treat8 hour if VPPDay == 4,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("CO2 Emissions Change vs Hr, VPP4") ///
	ytitle("CO2 Change (lb CO2")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(CO2Change1.ps, replace);
	
	graph export CO2Change1_VPP4_Q`quantDisplay'.png, replace;
	
	twoway (rarea SO2treat8EmissionsUpper SO2treat8EmissionsLower hour if VPPDay == 4,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter SO2EmissionsChange_treat6 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter SO2EmissionsChange_treat7 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter SO2EmissionsChange_treat8 hour if VPPDay == 4,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("SO2 Emissions Change vs Hr, VPP4") ///
	ytitle("SO2 Change (lb SO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(SO2Change1.ps, replace);
	
	graph export SO2Change1_VPP4_Q`quantDisplay'.png, replace;
	
	twoway (rarea NOXtreat8EmissionsUpper NOXtreat8EmissionsLower hour if VPPDay == 4,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter NOXEmissionsChange_treat6 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter NOXEmissionsChange_treat7 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter NOXEmissionsChange_treat8 hour if VPPDay == 4,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("NOX Emissions Change vs Hr, VPP4") ///
	ytitle("NOX Change (lb NOX)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(NOXChange1.ps, replace);
	
	graph export NOXChange_VPP4_Q`quantDisplay'.png,  replace;
	
	
	
	
	/* drop if treat != 1;
	
	sort accountid date hour;
	drop failure_pct failure_ihd hr_weekday id ihdfailure pct_failure rates treatment_received;
	
	collapse (mean) measuredkwh (semean) kwhSE=measuredkwh (first) kWhPercentChange_treat6 kWhPercentChange_treat7 kWhPercentChange_treat8
	kWhPercentSE_treat6 kWhPercentSE_treat7 kWhPercentSE_treat8, by (VPPDay hour);
	
	gen kwhVar = kwhSE ^ 2;
	
	gen ConsumptionChangekwh_treat6 = measuredkwh * kWhPercentChange_treat6;
	gen ConsumptionChangekwh_treat7 = measuredkwh * kWhPercentChange_treat7;
	gen ConsumptionChangekwh_treat8 = measuredkwh * kWhPercentChange_treat8;
	
	gen ConsumptionChangevar_treat6 = kwhSE^2*kWhPercentChange_treat6^2+measuredkwh^2*kWhPercentSE_treat6^2;
	gen ConsumptionChangevar_treat7 = kwhSE^2*kWhPercentChange_treat7^2+measuredkwh^2*kWhPercentSE_treat7^2;
	gen ConsumptionChangevar_treat8 = kwhSE^2*kWhPercentChange_treat8^2+measuredkwh^2*kWhPercentSE_treat8^2;
	
	gen ConsumptionChangeSE_treat6 = ConsumptionChangevar_treat6^(1/2);
	gen ConsumptionChangeSE_treat7 = ConsumptionChangevar_treat7^(1/2);
	gen ConsumptionChangeSE_treat8 = ConsumptionChangevar_treat6^(1/2);
	
	
	gen Totalkwh_treat6 = measuredkwh + ConsumptionChangekwh_treat6;
	gen Totalkwh_treat7 = measuredkwh + ConsumptionChangekwh_treat7;
	gen Totalkwh_treat8 = measuredkwh + ConsumptionChangekwh_treat8;

	sort VPPDay;
	by VPPDay: egen TotalConsumptionChangevar_treat6 = sum(ConsumptionChangevar_treat6);
	by VPPDay: egen TotalConsumptionChangevar_treat7 = sum(ConsumptionChangevar_treat7);
	by VPPDay: egen TotalConsumptionChangevar_treat8 = sum(ConsumptionChangevar_treat8);
	
	gen TotalConsumptionChangeSE_treat6 = TotalConsumptionChangevar_treat6 ^.5;
	gen TotalConsumptionChangeSE_treat7 = TotalConsumptionChangevar_treat7 ^.5;
	gen TotalConsumptionChangeSE_treat8 = TotalConsumptionChangevar_treat8 ^.5;
	
	
	
	*specific for the emissions calculations;
	merge m:1 hour using Marginal_Emissions_SPP-2011.dta;
	drop _merge;
	
	rename CO2MarginalEmissionsCoeff2011 CO2MarginalEmissionsCoeff;
	rename SO2MarginalEmissionsCoeff2011 SO2MarginalEmissionsCoeff;
	rename NOXMarginalEmissionsCoeff2011 NOXMarginalEmissionsCoeff;
	
	rename CO2MarginalEmissionsSE2011 CO2MarginalEmissionsSE;
	rename SO2MarginalEmissionsSE2011 SO2MarginalEmissionsSE;
	rename NOXMarginalEmissionsSE2011 NOXMarginalEmissionsSE;
	
	
	
	
	gen CO2Emissions_Control = measuredkwh * CO2MarginalEmissionsCoeff;
	gen SO2Emissions_Control = measuredkwh * SO2MarginalEmissionsCoeff;
	gen NOXEmissions_Control = measuredkwh * NOXMarginalEmissionsCoeff;
	
	
	bootstrap , reps(1000): summarize CO2Emissions_Control
	
	/*
	
	gen CO2Emissions_ControlVar = CO2MarginalEmissionsSE^2 * kwhSE^2 + measuredkwh^2*CO2MarginalEmissionsCoeff^2;
	gen SO2Emissions_ControlVar = SO2MarginalEmissionsSE^2 * kwhSE^2 + measuredkwh^2*SO2MarginalEmissionsCoeff^2;
	gen NOXEmissions_ControlVar = NOXMarginalEmissionsSE^2 * kwhSE^2 + measuredkwh^2*NOXMarginalEmissionsCoeff^2;
	
	gen CO2Emissions_ControlSE = CO2Emissions_ControlVar^(1/2);
	gen SO2Emissions_ControlSE = SO2Emissions_ControlVar^(1/2);
	gen NOXEmissions_ControlSE = NOXEmissions_ControlVar^(1/2);
	
	*/
	
	
	gen CO2EmissionsChange_treat6 = ConsumptionChangekwh_treat6 * CO2MarginalEmissionsCoeff; 
	gen SO2EmissionsChange_treat6 = ConsumptionChangekwh_treat6 * SO2MarginalEmissionsCoeff;
	gen NOXEmissionsChange_treat6 = ConsumptionChangekwh_treat6 * NOXMarginalEmissionsCoeff;
	
	gen CO2EmissionsChange_treat7 = ConsumptionChangekwh_treat7 * CO2MarginalEmissionsCoeff; 
	gen SO2EmissionsChange_treat7 = ConsumptionChangekwh_treat7 * SO2MarginalEmissionsCoeff;
	gen NOXEmissionsChange_treat7 = ConsumptionChangekwh_treat7 * NOXMarginalEmissionsCoeff;
	
	gen CO2EmissionsChange_treat8 = ConsumptionChangekwh_treat8 * CO2MarginalEmissionsCoeff; 
	gen SO2EmissionsChange_treat8 = ConsumptionChangekwh_treat8 * SO2MarginalEmissionsCoeff;
	gen NOXEmissionsChange_treat8 = ConsumptionChangekwh_treat8 * NOXMarginalEmissionsCoeff;
	
	gen CO2EmissionsVar_treat6 = ConsumptionChangekwh_treat6^2 * CO2MarginalEmissionsSE^2 + CO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat6^2; 
	gen SO2EmissionsVar_treat6 = ConsumptionChangekwh_treat6^2 * SO2MarginalEmissionsSE^2 + SO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat6^2;
	gen NOXEmissionsVar_treat6 = ConsumptionChangekwh_treat6^2 * NOXMarginalEmissionsSE^2 + NOXMarginalEmissionsCoeff^2*ConsumptionChangeSE_treat6^2;;
	
	gen CO2EmissionsVar_treat7 = ConsumptionChangekwh_treat7^2 * CO2MarginalEmissionsSE^2 + CO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat7^2; 
	gen SO2EmissionsVar_treat7 = ConsumptionChangekwh_treat7^2 * SO2MarginalEmissionsSE^2 + SO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat7^2;
	gen NOXEmissionsVar_treat7 = ConsumptionChangekwh_treat7^2 * NOXMarginalEmissionsSE^2 + NOXMarginalEmissionsCoeff^2*ConsumptionChangeSE_treat7^2;;
	
	gen CO2EmissionsVar_treat8 = ConsumptionChangekwh_treat8^2 * CO2MarginalEmissionsSE^2 + CO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat8^2; 
	gen SO2EmissionsVar_treat8 = ConsumptionChangekwh_treat8^2 * SO2MarginalEmissionsSE^2 + SO2MarginalEmissionsCoeff^2*ConsumptionChangeSE_treat8^2;
	gen NOXEmissionsVar_treat8 = ConsumptionChangekwh_treat8^2 * NOXMarginalEmissionsSE^2 + NOXMarginalEmissionsCoeff^2*ConsumptionChangeSE_treat8^2;
	
	

	gen CO2EmissionsSTD_treat6 = CO2EmissionsVar_treat6 ^ (1/2);
	gen SO2EmissionsSTD_treat6 = SO2EmissionsVar_treat6 ^ (1/2);
	gen NOXEmissionsSTD_treat6 = NOXEmissionsVar_treat6 ^ (1/2);
	
	gen CO2EmissionsSTD_treat7 =  CO2EmissionsVar_treat7 ^ (1/2);
	gen SO2EmissionsSTD_treat7 = SO2EmissionsVar_treat7 ^ (1/2);
	gen NOXEmissionsSTD_treat7 = NOXEmissionsVar_treat7 ^ (1/2);
	
	gen CO2EmissionsSTD_treat8 =  CO2EmissionsVar_treat8 ^ (1/2);
	gen SO2EmissionsSTD_treat8 = SO2EmissionsVar_treat8 ^ (1/2);
	gen NOXEmissionsSTD_treat8 = NOXEmissionsVar_treat8 ^ (1/2);
	
	* expressed as hourly percent changes;
	
	
	
	gen percentCO2_treat6 = CO2EmissionsChange_treat6/CO2Emissions_Control * 100;
	gen percentCO2_treat7 = CO2EmissionsChange_treat7/CO2Emissions_Control * 100;
	gen percentCO2_treat8 = CO2EmissionsChange_treat8/CO2Emissions_Control * 100;
	
	gen percentSO2_treat6 = SO2EmissionsChange_treat6/SO2Emissions_Control * 100;
	gen percentSO2_treat7 = SO2EmissionsChange_treat7/SO2Emissions_Control * 100;
	gen percentSO2_treat8 = SO2EmissionsChange_treat8/SO2Emissions_Control * 100;
	
	gen percentNOX_treat6 = NOXEmissionsChange_treat6/NOXEmissions_Control * 100;
	gen percentNOX_treat7 = NOXEmissionsChange_treat7/NOXEmissions_Control * 100;
	gen percentNOX_treat8 = NOXEmissionsChange_treat8/NOXEmissions_Control * 100;
	
	
	gen percentCO2_treat6var = CO2EmissionsSTD_treat6^2/(CO2Emissions_Control^2) * 100^2 + 100^2*(CO2EmissionsChange_treat6/(CO2Emissions_Control^2))^2*CO2Emissions_ControlVar;
	gen percentCO2_treat7var = CO2EmissionsSTD_treat7^2/(CO2Emissions_Control^2) * 100^2 + 100^2*(CO2EmissionsChange_treat7/(CO2Emissions_Control^2))^2*CO2Emissions_ControlVar;
	gen percentCO2_treat8var = CO2EmissionsSTD_treat8^2/(CO2Emissions_Control^2) * 100^2 + 100^2*(CO2EmissionsChange_treat8/(CO2Emissions_Control^2))^2*CO2Emissions_ControlVar;
	
	gen percentSO2_treat6var = SO2EmissionsSTD_treat6^2/(SO2Emissions_Control^2) * 100^2 + 100^2*(SO2EmissionsChange_treat6/(SO2Emissions_Control^2))^2*SO2Emissions_ControlVar;
	gen percentSO2_treat7var = SO2EmissionsSTD_treat7^2/(SO2Emissions_Control^2) * 100^2 + 100^2*(SO2EmissionsChange_treat7/(SO2Emissions_Control^2))^2*SO2Emissions_ControlVar;
	gen percentSO2_treat8var = SO2EmissionsSTD_treat8^2/(SO2Emissions_Control^2) * 100^2 + 100^2*(SO2EmissionsChange_treat8/(SO2Emissions_Control^2))^2*SO2Emissions_ControlVar;
	
	gen percentNOX_treat6var = NOXEmissionsSTD_treat6^2/(NOXEmissions_Control^2) * 100^2 + 100^2*(NOXEmissionsChange_treat6/(NOXEmissions_Control^2))^2*NOXEmissions_ControlVar;
	gen percentNOX_treat7var = NOXEmissionsSTD_treat7^2/(NOXEmissions_Control^2) * 100^2 + 100^2*(NOXEmissionsChange_treat7/(NOXEmissions_Control^2))^2*NOXEmissions_ControlVar;
	gen percentNOX_treat8var = NOXEmissionsSTD_treat8^2/(NOXEmissions_Control^2) * 100^2 + 100^2*(NOXEmissionsChange_treat8/(NOXEmissions_Control^2))^2*NOXEmissions_ControlVar;
	
	
	
	gen percentCO2_treat6SD = percentCO2_treat6var ^ (.5);
	gen percentCO2_treat7SD = percentCO2_treat7var ^ (.5);
	gen percentCO2_treat8SD = percentCO2_treat8var ^ (.5);
	
	gen percentSO2_treat6SD = percentSO2_treat6var ^ (.5);
	gen percentSO2_treat7SD = percentSO2_treat7var ^ (.5);
	gen percentSO2_treat8SD = percentSO2_treat8var ^ (.5);
	
	gen percentNOX_treat6SD = percentNOX_treat6var ^ (.5);
	gen percentNOX_treat7SD = percentNOX_treat7var ^ (.5);
	gen percentNOX_treat8SD = percentNOX_treat8var ^ (.5);
	
	
	
	save PercentageChangeControltreat6-treat8_Q`quantDisplay'VPP.dta, replace;
	
	gen CO2treat8Upper = percentCO2_treat8+1.96*percentCO2_treat8SD;
	gen CO2treat8Lower = percentCO2_treat8-1.96*percentCO2_treat8SD;
	
	gen SO2treat8Upper = percentSO2_treat8+1.96*percentSO2_treat8SD;
	gen SO2treat8Lower = percentSO2_treat8-1.96*percentSO2_treat8SD;
	
	gen NOXtreat8Upper = percentNOX_treat8+1.96*percentNOX_treat8SD;
	gen NOXtreat8Lower = percentNOX_treat8-1.96*percentNOX_treat8SD;
	
	twoway (rarea CO2treat8Upper CO2treat8Lower hour if VPPDay == 2,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter percentCO2_treat6 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter percentCO2_treat7 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter percentCO2_treat8 hour if VPPDay == 2,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("CO2 Emissions Change vs Hr, VPP2") ///
	ytitle("CO2 Change (% CO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(CO2ChangeConsumption1.ps, replace);
	
	graph export CO2ChangeConsumption1_VPP2_Q`quantDisplay'.png, replace;
	
	twoway (rarea SO2treat8Upper SO2treat8Lower hour if VPPDay == 2,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter percentSO2_treat6 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter percentSO2_treat7 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter percentSO2_treat8 hour if VPPDay == 2,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("SO2 Emissions Change vs Hr, VPP2") ///
	ytitle("SO2 Change (% SO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(SO2ChangeConsumption1.ps, replace);
	
	graph export SO2ChangeConsumption1_VPP2_Q`quantDisplay'.png, replace;
	
	twoway (rarea NOXtreat8Upper NOXtreat8Lower hour if VPPDay == 2,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter percentNOX_treat6 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter percentNOX_treat7 hour if VPPDay == 2,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter percentNOX_treat8 hour if VPPDay == 2,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("NOX Emissions Change vs Hr, VPP2") ///
	ytitle("NOX Change (% NOX)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(NOXChangeConsumption1.ps, replace);
	
	graph export NOXChangeConsumption1_VPP2_Q`quantDisplay'.png,  replace;
	
	
	twoway (rarea CO2treat8Upper CO2treat8Lower hour if VPPDay == 4,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter percentCO2_treat6 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter percentCO2_treat7 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter percentCO2_treat8 hour if VPPDay == 4,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("CO2 Emissions Change vs Hr, VPP4") ///
	ytitle("CO2 Change (% CO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(CO2ChangeConsumption2.ps, replace);
	
	graph export CO2ChangeConsumption1_VPP4_Q`quantDisplay'.png, replace;
	
	twoway (rarea SO2treat8Upper SO2treat8Lower hour if VPPDay == 4,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter percentSO2_treat6 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter percentSO2_treat7 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter percentSO2_treat8 hour if VPPDay == 4,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("SO2 Emissions Change vs Hr, VPP4") ///
	ytitle("SO2 Change (% SO2)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(SO2ChangeConsumption2.ps, replace);
	
	graph export SO2ChangeConsumption1_VPP4_Q`quantDisplay'.png, replace;
	
	twoway (rarea NOXtreat8Upper NOXtreat8Lower hour if VPPDay == 4,  color(eltgreen) fintensity(inten70) lwidth(none) pstyle(p2 p3 p4))
	(scatter percentNOX_treat6 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(blue) mcolor(blue)) ///
	(scatter percentNOX_treat7 hour if VPPDay == 4,  connect(l) symbol(Oh) lcolor(red) mcolor(red)) ///
	(scatter percentNOX_treat8 hour if VPPDay == 4,  connect(l) symbol(O) lcolor(green) mcolor(green)), ///
	title("NOX Emissions Change vs Hr, VPP4") ///
	ytitle("NOX Change (% NOX)")  ///
	xtitle("Hour") scheme(s1color)  legend(label(2 "Web Portal") label(3 "Web Portal + IHD") label(4 "Web Portal + PCT") label(1 "Web Portal+PCT, 95% conf. int.")) ///
	xlabel(#5, grid)    xsc(r(0 25)) xscale(titlegap(2)) yscale(titlegap(3)) saving(NOXChangeConsumption2Pooled.ps, replace);
	
	graph export NOXChangeConsumption1_VPP4_Q`quantDisplay'.png, replace;
	
	*/
	
	collapse (sum) measuredkwh kwhVar 
	ConsumptionChangekwh_treat6  ConsumptionChangekwh_treat7 ConsumptionChangekwh_treat8 
	ConsumptionChangevar_treat6 ConsumptionChangevar_treat7 ConsumptionChangevar_treat8	
	CO2Emissions_Control SO2Emissions_Control NOXEmissions_Control 
	CO2Emissions_ControlVar SO2Emissions_ControlVar NOXEmissions_ControlVar
	CO2EmissionsChange_treat6 CO2EmissionsChange_treat7 CO2EmissionsChange_treat8
	SO2EmissionsChange_treat6 SO2EmissionsChange_treat7 SO2EmissionsChange_treat8
	NOXEmissionsChange_treat6 NOXEmissionsChange_treat7 NOXEmissionsChange_treat8
	CO2EmissionsVar_treat6 CO2EmissionsVar_treat7 CO2EmissionsVar_treat8
	SO2EmissionsVar_treat6 SO2EmissionsVar_treat7 SO2EmissionsVar_treat8
	NOXEmissionsVar_treat6 NOXEmissionsVar_treat7 NOXEmissionsVar_treat8, by (VPPDay);
	
	gen ConsumptionChangeSE_treat6 = ConsumptionChangevar_treat6 ^.2;
	gen ConsumptionChangeSE_treat7 = ConsumptionChangevar_treat7 ^.3;
	gen ConsumptionChangeSE_treat8 = ConsumptionChangevar_treat8 ^.4;
	
	gen CO2Emissions_ControlSE = CO2Emissions_ControlVar^.5; 
	gen SO2Emissions_ControlSE = SO2Emissions_ControlVar^.5; 
	gen NOXEmissions_ControlSE = NOXEmissions_ControlVar^.5;
	
	gen CO2EmissionsSE_treat6 = CO2EmissionsVar_treat6^.5; 
	gen CO2EmissionsSE_treat7 = CO2EmissionsVar_treat7^.5; 
	gen CO2EmissionsSE_treat8 = CO2EmissionsVar_treat8^.5;
	gen SO2EmissionsSE_treat6 = SO2EmissionsVar_treat6^.5; 
	gen SO2EmissionsSE_treat7 = SO2EmissionsVar_treat7^.5; 
	gen SO2EmissionsSE_treat8 = SO2EmissionsVar_treat8^.5;
	gen NOXEmissionsSE_treat6 = NOXEmissionsVar_treat6^.5; 
	gen NOXEmissionsSE_treat7 = NOXEmissionsVar_treat7^.5; 
	gen NOXEmissionsSE_treat8 = NOXEmissionsVar_treat8^.5;
	
	
	* EPA citation: https://www.epa.gov/climatechange/social-cost-carbon;
	
	local CO2_price_per_ton = 36;
	local metric_ton_to_pound = 1/2204.62;
	
	gen CO2cost_treat6 = CO2EmissionsChange_treat6 * `CO2_price_per_ton' * `metric_ton_to_pound';
	gen CO2cost_treat7 = CO2EmissionsChange_treat7 * `CO2_price_per_ton' * `metric_ton_to_pound';
	gen CO2cost_treat8 = CO2EmissionsChange_treat8 * `CO2_price_per_ton' * `metric_ton_to_pound';
	
	gen CO2cost_treat6_SE = `CO2_price_per_ton' * `metric_ton_to_pound' * CO2EmissionsVar_treat6^.5;
	gen CO2cost_treat7_SE = `CO2_price_per_ton' * `metric_ton_to_pound' * CO2EmissionsVar_treat7^.5;
	gen CO2cost_treat8_SE = `CO2_price_per_ton' * `metric_ton_to_pound' * CO2EmissionsVar_treat8^.5;
	
	local NOX_price_per_ton = 13000;
	
	gen NOXcost_treat6 = NOXEmissionsChange_treat6 * `NOX_price_per_ton' * `metric_ton_to_pound';
	gen NOXcost_treat7 = NOXEmissionsChange_treat7 * `NOX_price_per_ton' * `metric_ton_to_pound';
	gen NOXcost_treat8 = NOXEmissionsChange_treat8 * `NOX_price_per_ton' * `metric_ton_to_pound'; 
	
	gen NOXcost_treat6_SE = `NOX_price_per_ton' * `metric_ton_to_pound' * NOXEmissionsVar_treat6^.5;
	gen NOXcost_treat7_SE = `NOX_price_per_ton' * `metric_ton_to_pound' * NOXEmissionsVar_treat7^.5;
	gen NOXcost_treat8_SE = `NOX_price_per_ton' * `metric_ton_to_pound' * NOXEmissionsVar_treat8^.5;
	
	
	
	gen percentChangekwhtreat6 = (ConsumptionChangekwh_treat6)/measuredkwh * 100;
	gen percentChangekwhtreat7 = (ConsumptionChangekwh_treat7)/measuredkwh * 100;
	gen percentChangekwhtreat8 = (ConsumptionChangekwh_treat8)/measuredkwh * 100;
	
	gen percentChangekwhtreat6_var = ConsumptionChangevar_treat6/measuredkwh ^ 2 * 100^2 + (100*ConsumptionChangekwh_treat6/measuredkwh^2)^2*kwhVar; 
	gen percentChangekwhtreat7_var = ConsumptionChangevar_treat7/measuredkwh ^ 2 * 100^2 + (100*ConsumptionChangekwh_treat7/measuredkwh^2)^2*kwhVar; 
	gen percentChangekwhtreat8_var = ConsumptionChangevar_treat8/measuredkwh ^ 2 * 100^2 + (100*ConsumptionChangekwh_treat8/measuredkwh^2)^2*kwhVar; 
	
	gen percentChangekwhtreat6_SE = percentChangekwhtreat6_var ^ .5; 
	gen percentChangekwhtreat7_SE = percentChangekwhtreat7_var ^ .5; 
	gen percentChangekwhtreat8_SE = percentChangekwhtreat8_var ^ .5; 
	
	
	gen percentChangeCO2treat6 = (CO2EmissionsChange_treat6)/CO2Emissions_Control * 100;
	gen percentChangeCO2treat7 = (CO2EmissionsChange_treat7)/CO2Emissions_Control * 100;
	gen percentChangeCO2treat8 = (CO2EmissionsChange_treat8)/CO2Emissions_Control * 100;
	
	gen percentChangeCO2treat6_var = CO2EmissionsVar_treat6/CO2Emissions_Control ^ 2 * 100^2 + (100*CO2EmissionsChange_treat6/CO2Emissions_Control^2)^2*CO2Emissions_ControlVar; 
	gen percentChangeCO2treat7_var = CO2EmissionsVar_treat7/CO2Emissions_Control ^ 2 * 100^2 + (100*CO2EmissionsChange_treat7/CO2Emissions_Control^2)^2*CO2Emissions_ControlVar; 
	gen percentChangeCO2treat8_var = CO2EmissionsVar_treat8/CO2Emissions_Control ^ 2 * 100^2 + (100*CO2EmissionsChange_treat8/CO2Emissions_Control^2)^2*CO2Emissions_ControlVar; 
	
	gen percentChangeCO2treat6_SE = percentChangeCO2treat6_var ^ .5; 
	gen percentChangeCO2treat7_SE = percentChangeCO2treat7_var ^ .5; 
	gen percentChangeCO2treat8_SE = percentChangeCO2treat8_var ^ .5;
	
	
	
	gen percentChangeSO2treat6 = (SO2EmissionsChange_treat6)/SO2Emissions_Control * 100;
	gen percentChangeSO2treat7 = (SO2EmissionsChange_treat7)/SO2Emissions_Control * 100;
	gen percentChangeSO2treat8 = (SO2EmissionsChange_treat8)/SO2Emissions_Control * 100;
	
	gen percentChangeSO2treat6_var = SO2EmissionsVar_treat6/SO2Emissions_Control ^ 2 * 100^2 + (100*SO2EmissionsChange_treat6/SO2Emissions_Control^2)^2*SO2Emissions_ControlVar; 
	gen percentChangeSO2treat7_var = SO2EmissionsVar_treat7/SO2Emissions_Control ^ 2 * 100^2 + (100*SO2EmissionsChange_treat7/SO2Emissions_Control^2)^2*SO2Emissions_ControlVar; 
	gen percentChangeSO2treat8_var = SO2EmissionsVar_treat8/SO2Emissions_Control ^ 2 * 100^2 + (100*SO2EmissionsChange_treat8/SO2Emissions_Control^2)^2*SO2Emissions_ControlVar; 
	
	gen percentChangeSO2treat6_SE = percentChangeSO2treat6_var ^ .5; 
	gen percentChangeSO2treat7_SE = percentChangeSO2treat7_var ^ .5; 
	gen percentChangeSO2treat8_SE = percentChangeSO2treat8_var ^ .5;
	
	
	
	gen percentChangeNOXtreat6 = (NOXEmissionsChange_treat6)/NOXEmissions_Control * 100;
	gen percentChangeNOXtreat7 = (NOXEmissionsChange_treat7)/NOXEmissions_Control * 100;
	gen percentChangeNOXtreat8 = (NOXEmissionsChange_treat8)/NOXEmissions_Control * 100;
	
	gen percentChangeNOXtreat6_var = NOXEmissionsVar_treat6/NOXEmissions_Control ^ 2 * 100^2 + (100*NOXEmissionsChange_treat6/NOXEmissions_Control^2)^2*NOXEmissions_ControlVar; 
	gen percentChangeNOXtreat7_var = NOXEmissionsVar_treat7/NOXEmissions_Control ^ 2 * 100^2 + (100*NOXEmissionsChange_treat7/NOXEmissions_Control^2)^2*NOXEmissions_ControlVar; 
	gen percentChangeNOXtreat8_var = NOXEmissionsVar_treat8/NOXEmissions_Control ^ 2 * 100^2 + (100*NOXEmissionsChange_treat8/NOXEmissions_Control^2)^2*NOXEmissions_ControlVar; 
	
	gen percentChangeNOXtreat6_SE = percentChangeNOXtreat6_var ^ .5; 
	gen percentChangeNOXtreat7_SE = percentChangeNOXtreat7_var ^ .5; 
	gen percentChangeNOXtreat8_SE = percentChangeNOXtreat8_var ^ .5;
	
	
	
	
	save ConsumpChange_Q`quantDisplay'_VPP.dta, replace;
	
	
	
	sum;
	
	
/*

clear all;

	
	*critical period residential rates, according to the Price Signals file;
	*the rate codes 13C and 13V have identical prices;
	
	gen ControlGroupCost = measuredkwh * price;
	
	gen Consumptionkwh_treat6 = measuredkwh + ConsumptionChangekwh_treat6;
	gen Consumptionkwh_treat7 = measuredkwh + ConsumptionChangekwh_treat7;
	gen Consumptionkwh_treat8 = measuredkwh + ConsumptionChangekwh_treat8;
	
	gen Cost_treat6 = price * Consumptionkwh_treat6;
	gen Cost_treat7 = price * Consumptionkwh_treat7;
	gen Cost_treat8 = price * Consumptionkwh_treat8;
	
	replace Cost_treat6 = CPPprice * Consumptionkwh_treat6 if critical == 1;
	replace Cost_treat7 = CPPprice * Consumptionkwh_treat7 if critical == 1;
	replace Cost_treat8 = CPPprice * Consumptionkwh_treat8 if critical == 1;
	
	
	*hourly cost savings under different treatments;
	gen Savings_treat6 = Cost_treat6 - ControlGroupCost;
	gen Savings_treat7 = Cost_treat7 - ControlGroupCost;
	gen Savings_treat8 = Cost_treat8 - ControlGroupCost;
	
	
	* collapse (first) identity meterid age income CPPday (sum) measuredkwh Consumptionkwh_treat6
	* Consumptionkwh_treat7 Consumptionkwh_treat8 Cost_ControlgroupDaily = ControlGroupCost 
	* Savings_treat6 Savings_treat7 Savings_treat8,
	* by (accountid date);
	
	 collapse (first) identity meterid age income (sum) measuredkwh Consumptionkwh_treat6
	 Consumptionkwh_treat7 Consumptionkwh_treat8 Cost_ControlgroupDaily = ControlGroupCost 
	 Savings_treat6 Savings_treat7 Savings_treat8,
	 by (accountid);
	
	gen SavingsPercentage_treat6 = Savings_treat6/Cost_ControlgroupDaily * 100;
	gen SavingsPercentage_treat7 = Savings_treat7/Cost_ControlgroupDaily * 100;
	gen SavingsPercentage_treat8 = Savings_treat8/Cost_ControlgroupDaily * 100;
	
	* sort accountid CPPday; 
	
	* by accountid CPPday: egen averageSavingsPercentage_treat6 = mean(SavingsPercentage_treat6);
	* by accountid CPPday: egen averageSavingsPercentage_treat7 = mean(SavingsPercentage_treat7);
	* by accountid CPPday: egen averageSavingsPercentage_treat8 = mean(SavingsPercentage_treat8);
	
	sort accountid;
	
	rename SavingsPercentage_treat6 averageSavingsPercentage_treat6;
	rename SavingsPercentage_treat7 averageSavingsPercentage_treat7;
	rename SavingsPercentage_treat8 averageSavingsPercentage_treat8;
	
	collapse (mean) averageSavingsPercentage_treat6 
	averageSavingsPercentage_treat7 averageSavingsPercentage_treat8 
	(sd) aveSavingsPercent_treat6sd = averageSavingsPercentage_treat6
	aveSavingsPercent_treat7sd = averageSavingsPercentage_treat7 
	aveSavingsPercent_treat8sd = averageSavingsPercentage_treat8, 
	by (age income);

	save ConsumerPriceSavingstreat6-Treat5.dta, replace;
	
	
/*

use HourlySystemLambda-2011.dta;
keep if ID == 220;


local i 0;
forval i = 0/23 {;
	 local j = `i' + 1;
	 rename lambdaHour`j' Hour`i';
	 };

drop date timezone year timeStamp;

save HourlySystemLambdaOGE-2011.dta, replace;



clear all;
use dataAnalysisSorted.dta;

merge m:1 month day using HourlySystemLambdaOGE-2011.dta;
save OGE_Utility_Lambda.dta, replace;

keep if _merge == 3;
drop _merge;

drop treat* ID technology failure_pct failure_ihd hr_weekday id ihdfailure pct_failure rates treatment_received bs* btreat* bbs*;
	
*reusing the variable price with the utility's marginal	cost;
replace price = 0;
local i 0;

*lambda hourly prices are in units of $/MWh from the FERC 714 sheet;

forval i = 0/23 {;
replace price = Hour`i' if `i' == hour;
};
	
	
replace price = price/1000;
	
drop Hour* dweekday weeknum day bcons maxtemp;


gen Savings_treat6 = ConsumptionChangekwh_treat6 * price;
gen Savings_treat7 = ConsumptionChangekwh_treat7 * price;
gen Savings_treat8 = ConsumptionChangekwh_treat8 * price;
	
gen Cost_ControlgroupHourly = measuredkwh * price;

sort accountid date hour;


collapse (first) identity meterid age income CPPday (sum) measuredkwh ConsumptionChangekwh_treat6
	ConsumptionChangekwh_treat7 ConsumptionChangekwh_treat8 Cost_ControlgroupDaily = Cost_ControlgroupHourly 
	Savings_treat6 Savings_treat7 Savings_treat8,
	by (accountid date);
	
	gen SavingsPercentage_treat6 = Savings_treat6/Cost_ControlgroupDaily * 100;
	gen SavingsPercentage_treat7 = Savings_treat7/Cost_ControlgroupDaily * 100;
	gen SavingsPercentage_treat8 = Savings_treat8/Cost_ControlgroupDaily * 100;
	
	sort accountid CPPday;
	
	by accountid CPPday: egen averageSavingsPercentage_treat6 = mean(SavingsPercentage_treat6);
	by accountid CPPday: egen averageSavingsPercentage_treat7 = mean(SavingsPercentage_treat7);
	by accountid CPPday: egen averageSavingsPercentage_treat8 = mean(SavingsPercentage_treat8);
	
	collapse (mean) averageSavingsPercentage_treat6 
	averageSavingsPercentage_treat7 averageSavingsPercentage_treat8 
	(sd) aveSavingsPercent_treat6sd = averageSavingsPercentage_treat6
	aveSavingsPercent_treat7sd = averageSavingsPercentage_treat7 
	aveSavingsPercent_treat8sd = averageSavingsPercentage_treat8 
	(count) num_treat6 = averageSavingsPercentage_treat6 
	num_treat7 = averageSavingsPercentage_treat7 num_treat8 = averageSavingsPercentage_treat8,
	by (age income CPPday);

	save UtilityPriceSavingstreat6-Treat5.dta, replace;
	
	
	
	
	
	
	
	
	
	
	
	
	
