**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2015.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

clear
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"

**Join house only variable of li_urbrur 
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia\Namibia Household_level_2015_16.dta"
keep region constituency psu segment du hh li_urbrur
*Add personal variables (age, sex) but keep match only
merge 1:m region constituency psu segment du hh using Namibia_ind_level_tab.dta, nogen
*perfect match!


*Calulating wealth variables
*Adjusted per capita income (APCI) (ND/adult/year)
xtile hhwealthindex = apci  [aw=wgt_ind], nquantiles(5)

save Namibia_2015.dta, replace

************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"
use Namibia_2015, clear 

local country Namibia 
local sex q01_02
local urbanrural li_urbrur // location
local hhweight wgt_ind //
local age q01_06_y
local wealth hhwealthindex
local region region

*Sex
rename `sex' sex
recode sex (2=1) (1=0)
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
label define REGION 1 "Karas" 2 "Erongo" 3 "Hardap" 4 "Kavango East" 5 "Kavango West" 6 "Khomas" 7 "Kunene" 8 "Ohangwena" 9 "Omaheke" 10 "Omusati" 11 "Oshana" 12 "Oshikoto" 13 "Otjozondjupa" 14 "Zambezi", replace
*rename `region' region
label values region REGION


*Location (urban-rural)
rename `urbanrural' location
recode location (1 98 = 1) (99 = 0) // semi urban is urban 
label define location 1 "Urban" 0 "Rural"
label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"
save Namibia_2015.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"
use Namibia_2015, clear 

gen country_year="Namibia"+"_"+"2015"
gen year=2017
gen iso_code2="NA"
gen iso_code3="NAM"
gen country = "Namibia"
gen survey="NHIES"

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
*7-3-2 start at 7y

// 1	No formal education
// 2	Primary
// 3	Secondary
// 4	Tertiary
// 5	Not stated

local highestlevelattended attain 

recode `highestlevelattended' (1=0) (2=1) (3=2) (4=9) (5=.) , gen(highestlevelattended)
*fix with eduyears
*q03_10 // current enrolee 
replace highestlevelattended=0 if inlist(q03_10, 0, 1, 2, 3, 4, 5, 6)
replace highestlevelattended=1 if inlist(q03_10, 7, 8, 9)
replace highestlevelattended=2 if inlist(q03_10, 10, 11)
replace highestlevelattended=3 if inlist(q03_10, 13, 14, 15) & highestlevelattended<=2
*q03_05  // past enrolee 
replace highestlevelattended=0 if inlist(q03_05, 0, 1, 2, 3, 4, 5, 6) 
replace highestlevelattended=1 if inlist(q03_05, 7, 8, 9) & highestlevelattended<=1
replace highestlevelattended=2 if inlist(q03_05, 10, 11) & highestlevelattended<=1
replace highestlevelattended=3 if inlist(q03_05, 13, 14, 15) & highestlevelattended<=2

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

gen eduyears=q03_10 // current enrolee 
replace eduyears=q03_05  // past enrolee 
replace eduyears=. if q03_10>27  // something that might be a DK 
 
*DATA COLLECTION DAYS OF THE SURVEY
*MAIN REPORT
*p24:
// The NHIES 2015/2016 was conducted within the provisions of the Statistics Act No.9 of 2011. There were two major fieldwork
// activities: the pilot survey that was undertaken from February 2015 to March 2015 and the main survey that was undertaken
// from April 2015 to March 2016.

*According to some web: 
*Dates:  The school year begins in January. 
*http://www.moe.gov.na/files/downloads/c4b_APPROVED%20SCHOOL%20CALENDAR%20FOR%202015.pdf 

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.

gen schage = age 

*?% of households have a difference of over 6 months=> no adjustment 


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

	 generate attend_preschool   = 1 if q03_09_mj == 2 // enrolled in preschool 
	 replace attend_preschool    = 0 if q03_03 == 2 // not currently attending 
	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?"
generate attend = 1 if q03_03 == 1
replace attend  = 0 if q03_03 == 2 //
replace attend  = . if q03_03 > 2 // missing 

recode attend (1=0) (0=1), gen(no_attend)

***
// 7 University
// 8 Post Graduate
// 9 Teacher Training
***
generate high_ed = 1 if inlist(q03_09_mj, 7, 8, 9) 
*use level attending now 
capture generate attend_higher = 1 if attend == 1 & high_ed == 1
capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
capture replace attend_higher  = 0 if attend == 0
capture generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

***
***Out-of-school: eduout_prim eduout_lowsec eduout_upsec
***
replace q03_09_mj=. if q03_09_mj>9
* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
generate eduout = no_attend
capture replace eduout  = . if (attend == 1 & q03_09_mj == .) | age == . 


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if attain>1
replace edu0  = 1 if q03_02==2
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
gen overage2plus= 0 if attend==1 & inlist(q03_09_mj, 3)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 1/6 {
				local i=`i'+1
				replace overage2plus=1 if q03_10==`grade' & schage>prim_age0+1+`i' & overage2plus!=. 
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
recode q03_01 (2=0) (1=1), gen(literacy)
replace literacy=. if age<15
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literacy

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"
save Namibia_microdata.dta, replace

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

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"


set more off
set trace on
foreach i of numlist 0/15 {
	use Namibia_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2015"
gen country_year="Namibia"+"_"+year
destring year, replace
gen iso_code2="NA"
gen iso_code3="NAM"
gen country = "Namibia"
gen survey="NHIES"
replace category="total" if category==""

	global categories_collapse location sex wealth region
	
	*-- Fixing for missing values in categories
	for X in any $categories_collapse: decode X, gen(X_s)
	for X in any $categories_collapse: drop X
	for X in any $categories_collapse: ren X_s X

	*Putting the names in the same format as the others
	global categories_collapse location sex wealth region
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
	
	*For Namibia there are some ghost categories in region and sex and location making extra observations here. Drop the observations of this 'false category'
	drop if region=="" & category=="Region" 
	drop if region=="" & category=="Sex Region" 
	drop if region=="" & category=="Wealth Region" 
	drop if region=="" & category=="Sex Wealth Region" 
	drop if sex=="" & category=="Sex" 
	drop if sex=="" & category=="Location Sex"
	drop if sex=="" & category=="Sex Region" 
	drop if sex=="" & category=="Sex Wealth"
	drop if sex=="" & category=="Location Sex Wealth" 
	drop if sex=="" & category=="Sex Wealth Region" 
	drop if location=="" & category=="Location" 
	drop if location=="" & category=="Location Sex" 
	drop if location=="" & category=="Location Wealth" 
	drop if location=="" & category=="Location Sex Wealth" 



save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Namibia\indicators_Namibia_2015.dta", replace

