**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2017.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan\SSD_2017_HFS-W4_v02_M_STATA8\hh.dta", clear
keep state ea hh weight
**Join 2 modules
*Merge that with module of education variables 
merge 1:m state ea hh using "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan\SSD_2017_HFS-W4_v02_M_STATA8\hhmTHIS.dta", nogen
*Perfect match!

*High Frequency Survey has no questions on income...so no wealth 

save SouthSudan_2017.dta, replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"
use SouthSudan_2017, clear 

local country SouthSudan 
local sex B_7_hhm_gender
*local urbanrural estrato // no location
local hhweight weight // hh weight 
local age B_1_hhm_age
*local wealth hhwealthindex // no wealth 
local region state

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

// * Wealth
// rename `wealth' wealth
// label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
// label values wealth wealth

*Region fixing accents
rename `region' region

// *Location (urban-rural)
// rename `urbanrural' location
// recode location (1/6 = 1) (7 8 = 0)
// label define location 1 "Urban" 0 "Rural"
// label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"
save SouthSudan_2017.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"
use SouthSudan_2017, clear 

gen country_year="South Sudan"+"_"+"2017"
gen year=2017
gen iso_code2="SS"
gen iso_code3="SSD"
gen country = "South Sudan"
gen survey="HFS"

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=5 // according to ISCED, some 3-4 and one 5 years for medicine
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
*6-2-4
* KHALWA or KALWA info http://etheses.whiterose.ac.uk/185/1/uk_bl_ethos_435939.pdf 
*https://www.emerald.com/insight/content/doi/10.1108/09578239210020480/full/
// "Khalwa is a mosque school in The Sudan. Most such schools are for boys from 6 to 13 who wish to learn the Quran by memory. There are some Khalawi for girls in urban areas of the country. The teacher is a faki and the head of the Khalwa is usually referred to as a Shayah"

local highestlevelattended B_35_hhm_edu_level 
*only 2800 observations, for people older than 6 years old

// Refused to respond	-99	=>	.
// Don't know	-98	=>	.
// Kalwa	8	=>	1
// In the first year of primary school	10	=>	0
// Primary 1	11	=>	0
// Primary 2	12	=>	0
// Primary 3	13	=>	0
// Primary 4	14	=>	0
// Primary 5	15	=>	0
// Primary 6	16	=>	1
// Primary 7	17	=>	1
// Primary 8	18	=>	2
// Intermediate 1	19	=>	1
// Intermediate 2	20	=>	2
// Intermediate 3	21	=>	2
// Secondary 1	22	=>	1
// Secondary 2	23	=>	2
// Secondary 3	24	=>	2
// Secondary 4	25	=>	2
// Secondary 5	26	=>	2
// Secondary 6	27	=>	3
// Diploma	29	=>	3
// Part of University	30	=>	3
// University degree	31	=>	6
// Masters degree	32	=>	7
// Other (please specify)	1000	=>	.


recode `highestlevelattended' (-99 -98 1000=.)(10 11 12 13 14 15=0) (16 19 22=1) (18 20 21 23 24 25 26=2) (27 29 30=3) (31=6) (32=7), gen(highestlevelattended)



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

*6-3-2 start at 6

gen eduyears=. if inlist(B_35_hhm_edu_level, -99, -98, 1000)
replace eduyears=8 if B_35_hhm_edu_level==8
replace eduyears=1 if B_35_hhm_edu_level==10
replace eduyears=1 if B_35_hhm_edu_level==11
replace eduyears=2 if B_35_hhm_edu_level==12
replace eduyears=3 if B_35_hhm_edu_level==13
replace eduyears=4 if B_35_hhm_edu_level==14
replace eduyears=5 if B_35_hhm_edu_level==15
replace eduyears=6 if B_35_hhm_edu_level==16
replace eduyears=7 if B_35_hhm_edu_level==17
replace eduyears=8 if B_35_hhm_edu_level==18
replace eduyears=9 if B_35_hhm_edu_level==19
replace eduyears=10 if B_35_hhm_edu_level==20
replace eduyears=11 if B_35_hhm_edu_level==21
replace eduyears=9 if B_35_hhm_edu_level==22
replace eduyears=10 if B_35_hhm_edu_level==23
replace eduyears=11 if B_35_hhm_edu_level==24
replace eduyears=12 if B_35_hhm_edu_level==25
replace eduyears=13 if B_35_hhm_edu_level==26
replace eduyears=14 if B_35_hhm_edu_level==27
replace eduyears=12 if B_35_hhm_edu_level==29
replace eduyears=14 if B_35_hhm_edu_level==30
replace eduyears=16 if B_35_hhm_edu_level==31
replace eduyears=18 if B_35_hhm_edu_level==32
replace eduyears=. if B_35_hhm_edu_level==1000

*DATA COLLECTION DAYS OF THE SURVEY
*https://microdata.worldbank.org/index.php/catalog/2916/study-description
*- Wave 4: May - August 2017 no specific information

*According to some web: 
*Dates:  The school year begins in February. 
*http://haliaccess.org/wp-content/uploads/2018/05/SOUTH-SUDAN-EDUCATION-1.pdf

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.

gen schage = age 

*0% of households have a difference of over 6 months=> no adjustment 


***
***Mean years of education: eduyears_2024
***
generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24

***
*NO PRESCHOOL VARIABLES SINCE EDUCATION QUESTION FOR 6+ years old
// ***Pre-primary education attendance: preschool_1ybefore 
// ***
// *Percentage of children attending any type of pre–primary education programme, 
// *(i) as 3–4 year olds and NOT THIS
// *(ii) 1 year before the official entrance age to primary. THIS
//
// 	 generate attend_preschool   = 1 if p308a == 1 // enrolled in preschool 
// 	 replace attend_preschool    = 0 if p306 == 2 //not enrolled in current year in anything
// 	 replace attend_preschool    = 0 if p307 == 2 //not assisting
// 	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
// 	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?"
generate attend = 1 if B_30_hhm_edu_current == 1
replace attend  = 0 if B_30_hhm_edu_current == 0 //not attending
replace attend  = . if B_30_hhm_edu_current == -98 // DK

recode attend (1=0) (0=1), gen(no_attend)

***
// Part of University	30	=>	3
// University degree	31	=>	6
// Masters degree	32	=>	7

***
generate high_ed = 1 if inlist(B_35_hhm_edu_level, 30, 31, 32) 
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
capture replace eduout  = . if (attend == 1 & highestlevelattended == .) | age == . 


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if highestlevelattended>0
replace edu0  = 1 if B_33_hhm_edu_ever==0
replace edu0  = 1 if eduyears == 0

generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(highestlevelattended, .)
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
gen overage2plus= 0 if attend==1 & inlist(B_35_hhm_edu_level, 10, 11, 12, 13, 14, 15, 16)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 11/16 {
				local i=`i'+1
				replace overage2plus=1 if B_35_hhm_edu_level==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
recode B_28_hhm_read (0=0) (1=1) (-98=.), gen(literacy)
replace literacy=1 if B_29_hhm_write==1 & literacy==.
replace literacy=1 if B_29_hhm_write==0 & literacy==.

replace literacy=. if age<15
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literacy

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"
save SouthSudan_microdata.dta, replace

************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse sex region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024  attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no

tuples $categories_collapse, display
/*
tuples $categories_collapse, display
tuple1: region
tuple2: sex
tuple3: sex region
*/

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"


set more off
set trace on
foreach i of numlist 0/3 {
	use SouthSudan_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/3 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2017"
gen country_year="South Sudan"+"_"+year
destring year, replace
gen iso_code2="SS"
gen iso_code3="SSD"
gen country = "South Sudan"
gen survey="HFS"
replace category="total" if category==""

global categories_collapse sex region 
	
	*-- Fixing for missing values in categories
	for X in any $categories_collapse: decode X, gen(X_s)
	for X in any $categories_collapse: drop X
	for X in any $categories_collapse: ren X_s X

	*Putting the names in the same format as the others
global categories_collapse sex region 
	tuples $categories_collapse, display
	
	* DROP Categories that are not used:
	drop if category=="location region"|category=="location sex region"|category=="location wealth region"|category=="location sex wealth region"

	*Proper for all categories
	foreach i of numlist 0/`ntuples' {
	replace category=proper(category) if category=="`tuple`i''"
	}
		
	
	order iso_code3 country survey year category $categories_collapse $varlist_m $varlist_no 
	tab category
	for X in any $categories_collapse: tab X
	
	*quick fix extra variables got here 
	drop B_52_unemp_7d_dur B_53_hhm_job_search_dur
	
	drop if sex=="" & category=="Sex" 
	drop if sex=="" & category=="Sex Region" 


save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\South Sudan\indicators_SouthSudan_2017.dta", replace

