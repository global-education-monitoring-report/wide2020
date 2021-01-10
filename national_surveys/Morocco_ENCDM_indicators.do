**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2019.do MOSTLY

*IMPORTANT FOR MOROCCO: There was a survey and a census in the same year, I am using the survey ENCDM because it has information on wealth (census doesnt)
*Using  ENQUÊTE NATIONALE SUR LA CONSOMMATION ET LES DÉPENSES DES MÉNAGES 2014 : MICRODONNÉES ANONYMISÉES (OPEN DATA)

************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

*Need to append the house information to the individuals
*Already transformed from sav to dta
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Morocco\encdm"
use encdm_ind, clear
merge m:1 N_m__nage using encdm_hh, nogen
*perfect match, dont keep _m
save Morocco_2014.dta, replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Morocco\encdm"
use Morocco_2014.dta, clear 

local country Morocco 
local sex Sexe
local urbanrural Milieu // location
local hhweight coef_indiv //
local age Age
local wealth Quintiles
local region R__gion_12

*Sex
rename `sex' sex
recode sex (1=1) (2=0)
label define sex 1 "Male" 0 "Female"
label val sex sex

*Weight
rename `hhweight' hhweight
lab var hhweight "HH weight"

*Age
label var `age' "Age at the date of the interview"
clonevar age=`age' 

* Wealth
rename `wealth' wealth
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth

*Region fixing accents
rename `region' region


*Location (urban-rural)
rename `urbanrural' location
recode location (1 = 1) (2 = 0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Tanzania\Raw_dataset"
save Morocco_2014.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Morocco\encdm"
use Morocco_2014.dta, clear 

gen country_year="Morocco"+"_"+"2014"
gen year=2014
gen iso_code2="MA"
gen iso_code3="MAR"
gen country = "Morocco"
gen survey="ENCDM"

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=4 // according to ISCED, some 3-4 and one 5 years for medicine
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur

	*Ages for completion
	gen lowsec_age0=prim_age0+prim_dur
	gen upsec_age0=lowsec_age0+lowsec_dur
	for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1

*Following this 
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 9=higher
*local levelattendingcurrentyear P1088
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence



local highestlevelattended S5_9

recode `highestlevelattended' (0=0) (1=0) (11 12 13 14 15 16=0) (2 17 18 19 21 22 23=1) (24 25 31=2) (32 33 41 42=3) (34 25=4) (43 44 45=6)(46=7) (47=8) , gen(highestlevelattended)
*recode `levelattendingcurrentyear' (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600=6) (700=7) (800=8), gen(levelattendingcurrentyear)


***Completion variables:  comp_prim_v2 comp_lowsec_v2 comp_upsec_v2  comp_prim_1524 comp_lowsec_1524 comp_upsec_2029

for X in any prim lowsec upsec: gen comp_X=0 if highestlevelattended!=.
replace comp_prim=1 if highestlevelattended >= 1 & comp_prim == 0
replace comp_lowsec=1 if highestlevelattended >= 2 & comp_lowsec == 0
replace comp_upsec=1 if highestlevelattended >= 3 & comp_upsec == 0

*Age limits
foreach X in prim lowsec upsec {
foreach AGE in age {
	gen comp_`X'_v2=comp_`X' if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5
	gen comp_`X'_1524=comp_`X' if `AGE'>=15 & `AGE'<=24
	gen comp_`X'_2024=comp_`X' if `AGE'>=20 & `AGE'<=24
}
}

gen comp_upsec_2029=comp_upsec if age>=20 & age<=29
gen comp_upsec_2029_no=comp_upsec_2029

// foreach AGE in schage  {
// 		generate comp_prim_1524   = comp_prim if `AGE' >= 15 & `AGE' <= 24
// 		generate comp_upsec_2029  = comp_upsec if `AGE' >= 20 & `AGE' <= 29
// 		generate comp_lowsec_1524 = comp_lowsec if `AGE' >= 15 & `AGE' <= 24
// 	}

*7-4-2 start at 7
*this uses ISCED info too
*EDUYEARS will combine level and highest level-grade attended
// original code	level-recode	eduyears
// Pre-Primary		0	0	0
// Nursery			1	0	0
// Adult Education	2	1	7
// Primary - Year 1	11	0	1
// Primary - Year 2	12	0	2
// Primary - Year 3	13	0	3
// Primary - Year 4	14	0	4
// Primary - Year 5	15	0	5
// Primary - Year 6	16	0	6
// Primary - Year 7	17	1	7
// Primary - Year 8	18	1	8
// Training Aft Primary	19	1	8
// Form I			21	1	8
// Form II			22	1	9
// Form III		23	1	10
// Form IV		24	2	11
// Training After Secondary	25	2	12
// Form V		31	2	12
// Form VI		32	3	13
// Training After Form VI	33	3	14
// Diploma					34	4	15
// Other Course				35	4	14
// University - Year 1	41	3	14
// University - Year 2	42	3	15
// University - Year 3	43	6	16
// University - Year 4	44	6	17
// University - Year 5+	45	6	18
// Masters	46	7	20
// PHD	47	8	24

gen eduyears=.
replace eduyears=0 if inlist(S5_9, 1, 0)  // before school 
replace eduyears=1  if inlist(S5_9, 11) // primary 1st grade etc
replace eduyears=2  if inlist(S5_9, 12) // primary 2nd grade
replace eduyears=3  if inlist(S5_9, 13) // 
replace eduyears=4 if inlist(S5_9, 14) //
replace eduyears=5  if inlist(S5_9, 15) // 
replace eduyears=6 if inlist(S5_9, 16) // 
replace eduyears=7  if inlist(S5_9, 2, 17) // primary year 7
replace eduyears=8  if inlist(S5_9, 18, 19, 21) // 
replace eduyears=9  if inlist(S5_9, 22) // 
replace eduyears=10  if inlist(S5_9, 23) // 
replace eduyears=11 if inlist(S5_9, 24) // 
replace eduyears=12  if inlist(S5_9, 25, 31) // 
replace eduyears=13  if inlist(S5_9, 32) // 
replace eduyears=14  if inlist(S5_9, 33, 35, 41) // 
replace eduyears=15  if inlist(S5_9, 34, 42) // 
replace eduyears=16 if inlist(S5_9, 43) // 
replace eduyears=17  if inlist(S5_9, 44) // 
replace eduyears=18  if inlist(S5_9, 45) // 
replace eduyears=20  if inlist(S5_9, 46) // master 
replace eduyears=24  if inlist(S5_9, 47) // phd

 
*DATA COLLECTION DAYS OF THE SURVEY
*Data collection took place over 12 consecutive months from December 2017 to November 2018. 
tab date
*diary date, that is 14 day one has Jan2019 records...


*According to some web: 
*Dates:  The school year begins in January and has two terms (January to June and July to December).
*https://africaid.org/tanzanias-school-system-an-overview/

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.

gen schage = age

*40% of households have a difference of over 6 months=> no adjustment 


***
***Mean years of education: eduyears_2024
***
generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24

***
***Pre-primary education attendance: preschool_1ybefore 
***
*Percentage of children attending any type of pre–primary education programme, 
*(i) as 3–4 year olds and NOT THIS
*(ii) 1 year before the official entrance age to primary. THIS

gen preschool=1 if S5_7==1 | S5_7==0
gen before1y=1 if age==prim_age0-1
gen preschool_1ybefore=preschool if before1y==1
drop before1y

*IMPORTANT: preschool_3 is not calculated because the attendance question is limited to 5y+ people

*P8586: "Attended school during current school year?"
generate attend = 1 if S5_4 == 1
replace attend  = 0 if S5_4 == 2
recode attend (1=0) (0=1), gen(no_attend)

***
*Taking this categories into the higher variable 
// Diploma					34	4	15
// Other Course				35	4	14
// University - Year 1	41	3	14
// University - Year 2	42	3	15
// University - Year 3	43	6	16
// University - Year 4	44	6	17
// University - Year 5+	45	6	18
// Masters	46	7	20
// PHD	47	8	24

***
generate high_ed = 1 if inlist(S5_7, 34, 35, 41, 42, 43, 44, 45, 46, 47) 
*use level attending now 
capture generate attend_higher = 1 if attend == 1 & high_ed == 1
capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
capture replace attend_higher  = 0 if attend == 0
capture generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

***
***Out-of-school: eduout_prim eduout_lowsec eduout_upsec
***
* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
generate eduout = no_attend
capture replace eduout  = . if (attend == 1 & S5_7 == .) | age == . 

*this from UIS_duration_age_01102020.dta
*gen prim_age0 = 7
*gen prim_dur = 7
*gen lowsec_dur = 4
*gen upsec_dur = 2

*generate lowsec_age0 = prim_age0 + prim_dur
*generate upsec_age0  = lowsec_age0 + lowsec_dur
*for X in any prim lowsec upsec: capture generate X_age1 = X_age0 + X_dur - 1

*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if S5_1==1
replace edu0  = 1 if S5_1==2
replace edu0  = 1 if inlist(S5_9, 0, 1, 2)
replace edu0  = 1 if eduyears == 0

generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(S5_9, .)
	}

	replace comp_higher_2yrs = 1 if eduyears >= years_upsec + 2
	replace comp_higher_4yrs = 1 if eduyears >= years_upsec + 4

	*Ages for completion higher
	foreach X in 2 4{
		generate comp_higher_`X'yrs_2529 = comp_higher_`X'yrs if schage >= 25 & schage <= 29
	}
	foreach X in 4{
		generate comp_higher_`X'yrs_3034 = comp_higher_`X'yrs if schage >= 30 & schage <= 34
		drop comp_higher_`X'yrs 
	}
***	
***Less than 2/4 years of schooling: edu2_2024 edu4_2024
***
	
	foreach X in 2 4 {
		generate edu`X'_2024 = 0
		replace edu`X'_2024  = 1 if eduyears_2024 < `X'
		replace edu`X'_2024  = . if eduyears_2024 == .
	}

*Over-age primary school attendance
*Percentage of children in primary school who are two years or more older than the official age for grade.
gen overage2plus= 0 if attend==1 & inlist(S5_7, 11, 12, 13, 14, 15, 16, 17, 19)
*There are 7 years of primary
	local i=0
    foreach grade of numlist 11/19 {
				local i=`i'+1
				replace overage2plus=1 if S5_7==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*S6_2 is the test
recode S6_2 (6=0) (1/4=1) (5 7=.), gen(literacy)
*complete with self reported literacy? S6_1
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literac

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Tanzania\Raw_dataset"
save Tanzania_microdata.dta, replace

************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no preschool_1ybefore_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no

tuples $categories_collapse, display
/*
tuples $categories_collapse, display
tuple1: region
tuple2: wealth
tuple3: sex
tuple4: location
tuple5: wealth region
tuple6: sex region
tuple7: sex wealth
tuple8: location region
tuple9: location wealth
tuple10: location sex
tuple11: sex wealth region
tuple12: location wealth region
tuple13: location sex region
tuple14: location sex wealth
tuple15: location sex wealth region
*/

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Tanzania\Raw_dataset"


set more off
set trace on
foreach i of numlist 0/15 {
	use Tanzania_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Tanzania\Raw_dataset"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2017"
gen country_year="Tanzania"+"_"+year
destring year, replace
gen iso_code2="TZ"
gen iso_code3="TZA"
gen country = "U. R. Tanzania"
gen survey="HBS"
replace category="total" if category==""
tab category

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no preschool_1ybefore_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no


*-- Fixing for missing values in categories
for X in any wealth sex: decode X, gen(X_s)
for X in any wealth sex: drop X
for X in any wealth sex: ren X_s X

codebook $categories_collapse, tab(100)

*Putting the names in the same format as the others
*for X in any $categories_collapse total: replace category=proper(category) if category=="X"
replace category="Location & Sex" if category=="location sex"
replace category="Location & Sex & Wealth" if category=="location sex wealth"
replace category="Location & Wealth" if category=="location wealth"
replace category="Sex & Region" if category=="sex region"
replace category="Sex & Wealth" if category=="sex wealth"
replace category="Sex & Wealth & Region" if category=="sex wealth region"
replace category="Wealth & Region" if category=="wealth region"

* Categories that are not used:
drop if category=="location region"|category=="location sex region"|category=="location wealth region"|category=="location sex wealth region"

for X in any $categories_collapse: rename X, proper

// *Now I throw away those that have large differences (per level)
// merge m:1 country year using "$dir/comparisons/results.dta", keepusing(flag*) nogen
// drop if flag_lfs==1
// order iso_code3 country survey year category Sex Location Wealth Region comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* comp_prim_1524* comp_lowsec_1524* comp_upsec_2029* preschool_1ybefore*
// drop comp_lowsec_2024-flag_LFS_country
// for X in any comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore: ren X X_m
// order iso_code3 country survey year category Sex Location Wealth Region *_m *_no

*order iso_code country year country_year survey category location sex wealth region ethnicity religion
order iso_code2 iso_code3 country survey year country_year category Region Location Wealth Sex  
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Tanzania\indicators_Tanzania_2017.dta"



