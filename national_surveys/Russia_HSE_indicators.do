**Adapting widetable for other surveys

************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

set more off

**
clear
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia\2019HSEindividuals.dta"
xtile hhwealthindex = J60 [aw=inwgt], nquantiles(5)

**

save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia\Russia_2019.dta", replace


************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia\Russia_2019.dta", clear

local country Russia 
local sex H5
local urbanrural status
local hhweight inwgt
local age age
local wealth hhwealthindex
local region region

*Sex
rename `sex' sex
recode sex (1=1) (2=0)
label define sex 1 "Male" 0 "Female"
label val sex sex

*Weight
ren `hhweight' hhweight
lab var hhweight "HH weight"

*Age
label var `age' "Age at the date of the interview"
*clonevar age=`age' 


* Wealth
rename `wealth' wealth
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth

*Region
*rename `region' region

*Location (urban-rural)
rename `urbanrural' location
recode location (1 2 3 = 1) (4=0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia\Russia_2019.dta", replace


************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

gen country_year="Russian-Federation"+"_"+"2019"
destring year, replace
gen iso_code2="RU"
gen iso_code3="RUS"
gen country = "Russian Federation"
gen survey="HSE"
merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=4 // bachelor ACCORDING TO ICSED
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
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 
*local levelattendingcurrentyear P1088
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence

*code j72
// should depend on grade<-1	GENERAL OR INCOMPLETE SECONDARY SCHOOL
// should depend on grade<-2	COMPLETE SECONDARY SCHOOL
// 3<-3	PROFESSIONAL COURSES OF DRIVING, TRACTOR DRIVING, ACCOUNTING, TYPING etc.
// 3<-4	VOCATIONAL TRAINING SCHOOL WITHOUT SECONDARY EDUCATION
// 4<-5	VOCATIONAL TRAINING SCHOOL WITH SECONDARY EDUCATION, TECHNICAL TRADE SCHOOL
// 4<-6	TECHNICAL COMMUNITY COLLEGE, MEDICAL, MUSIC, PEDAGOGICAL, ART TRAINING SCHOOL
// 4<-10	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING SPECIALIST DIPLOMA
// 6<-11	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING BACHELOR`S DEGREE
// 7<-12	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING MASTER`S DEGREE
// 8<-13	PHD DEGREE
// 8<-14	DOCTORAL DEGREE
// 4<-15	INSTITUTE, UNIVERSITY, ACADEMY - SECONDARY VOCATIOANAL EDUCATION DIPLOMA
// 7<-16	POST-GRADUATE PROGRAMME WITHOUT HIGHER DEGREE DIPLOMA
// 6<-17	RESIDENCY TRAINING, INTERNSHIP
// 99999997	DOES NOT KNOW
// 99999998	REFUSES TO ANSWER

local highestlevelattended J72_18A
recode `highestlevelattended' (1=0) (2=3) (3=3) (4=3) (5=4) (6=4) (10=4) (11=6) (12=7) (13=8) (14=8) (15=4) (16=7) (17=6), gen(highestlevelattended)
*4-5-2 for prim.lowsec.upsec
replace highestlevelattended=0 if J72_18A==1 & inlist(J70_1, 0, 1, 2, 3) // less than complete primary
replace highestlevelattended=1 if J72_18A==1 & inlist(J70_1, 4, 5, 6, 7, 8) // primary
replace highestlevelattended=2 if J72_18A==1 & inlist(J70_1, 9, 10 ) // lowsec
replace highestlevelattended=3 if J72_18A==1 & inlist(J70_1, 11 ) // upsec WHEN 11y

replace highestlevelattended=1 if J72_18A==1 & inlist(J70_1, 7, 8) // primary
replace highestlevelattended=2 if J72_18A==2 & inlist(J70_1, 9, 10 ) // lowsec  
replace highestlevelattended=3 if J72_18A==2 & inlist(J70_1, 11, 12 ) // upsec WHEN 11y  

*this is for kids to complete the variable
replace highestlevelattended=0 if inlist(K3_1, 0, 1, 2, 3) // less than complete primary
replace highestlevelattended=1 if inlist(K3_1, 4, 5, 6, 7, 8) // primary
replace highestlevelattended=2 if inlist(K3_1, 9, 10, 11 ) // lowsec


// *full labels
// 1	GENERAL OR INCOMPLETE SECONDARY SCHOOL
// 2	COMPLETE SECONDARY SCHOOL
// 3	PROFESSIONAL COURSES OF DRIVING, TRACTOR DRIVING, ACCOUNTING, TYPING etc.
// 4	VOCATIONAL TRAINING SCHOOL WITHOUT SECONDARY EDUCATION
// 5	VOCATIONAL TRAINING SCHOOL WITH SECONDARY EDUCATION, TECHNICAL TRADE SCHOOL
// 6	TECHNICAL COMMUNITY COLLEGE, MEDICAL, MUSIC, PEDAGOGICAL, ART TRAINING SCHOOL
// 7	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING MASTER`S DEGREE PROGRAMM
// 8	POST-GRADUATE COURSES, RESIDENCY
// 9	POST GRADUATE DEGREE
// 10	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING SPECIALIST DIPLOMA
// 11	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING BACHELOR`S DEGREE
// 12	INSTITUTE, UNIVERSITY, ACADEMY INCLUDING MASTER`S DEGREE
// 13	PHD DEGREE
// 14	DOCTORAL DEGREE
// 15	INSTITUTE, UNIVERSITY, ACADEMY - SECONDARY VOCATIOANAL EDUCATION DIPLOMA
// 16	POST-GRADUATE PROGRAMME WITHOUT HIGHER DEGREE DIPLOMA
// 17	RESIDENCY TRAINING, INTERNSHIP
// 99999997	DOES NOT KNOW
// 99999998	REFUSES TO ANSWER
// 99999999	NO ANSWER



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


*EDUYEARS will combine level and highest level-grade attended
*russia has a crazy questionnaire, variable educ seems to incorporate all this 
*educ is only for 14 years old+ so im completing with grade for younger ppl 
gen eduyears=educ
replace eduyears=0 if educ>1000
replace eduyears=K3_1 if educ==. // kids born before 1994

*DATA COLLECTION DAYS OF THE SURVEY
*Start	End	Cycle
*this is collected by INT_Y H7_1 H7_2 variables, year day month
*most interviews ocurred between october-december, a few in sept and jan

*According to this web school starts SEPTEMBER
// The school year in the Russian state system runs from the first of September through to May, although some students will have to come to school during June for exams. The year is split into four terms, with short breaks in between them. In most cases, the school day starts at around 8am, and runs until 1 or 2pm. School is open five days a week, but some schools also require students to do some extra hours of school-based study over the weekends.
*https://transferwise.com/us/blog/russian-education-overview#:~:text=The%20school%20year%20in%20the,runs%20until%201%20or%202pm.

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is <6.
*0% of hh have 6 months of difference or more

gen schage = age

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

gen preschool=1 if J70_2==1
gen before1y=1 if age==prim_age0-1
gen presch1ybefore=preschool if before1y==1
drop before1y

ren presch1ybefore preschool_1ybefore

*P8586: "Attended school during current school year?"
generate attend = 1 if J70_2 == 1
replace attend  = 0 if J70_2 == 2
recode attend (1=0) (0=1), gen(no_attend)

***
****Higher education attendance: attend_higher_1822
***
*use level attending noW, BUT THIS IS HARD in this survey
*J71 Did you study or are you studying anywhere besides school? BUT THIS INCLUDES ONES WHO FINISHED 
*this is based on p23 of the questionnaire using "now study"
generate high_ed = 1 if J71==1 & J72_1A==2 // prof course1
replace high_ed = 1 if J71==1 & J72_1A2==2 // prof course2
replace high_ed = 1 if J71==1 & J72_1A3==2 // prof course3
replace high_ed = 1 if J71==1 & J72_2A==2 // ptu etc 1
replace high_ed = 1 if J71==1 & J72_3A==2 // ptu etc 2
replace high_ed = 1 if J71==1 & J72_3A2==2 // ptu etc 3 
replace high_ed = 1 if J71==1 & J72_4A==2 // tech medical
replace high_ed = 1 if J71==1 & J72_4A2==2 // tech medical 2
replace high_ed = 1 if J71==1 & J72_5A==2 // institute
replace high_ed = 1 if J71==1 & J72_5A2==2 // institute 2 
replace high_ed = 1 if J71==1 & J72_5A3==2 // institute 3
replace high_ed = 1 if J71==1 & J72_6A==2 // post grad 


capture generate attend_higher = 1 if attend == 1 & high_ed == 1
capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
capture replace attend_higher  = 0 if attend == 0
capture generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

***
***Out-of-school: eduout_prim eduout_lowsec eduout_upsec
***
* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
generate eduout = no_attend
capture replace eduout  = . if (attend == 1 &  K3_1 == 99999999) | age == . 
capture replace eduout  = 1 if P1088 == 1  

*this from UIS_duration_age_01102020.dta
gen prim_age0_eduout = 7
gen prim_dur_eduout = 4
gen lowsec_dur_eduout = 5
gen upsec_dur_eduout = 2

generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1

*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
generate edu0 = 0 if inlist(K3_1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
replace edu0  = 1 if inlist(K3_1, 0, 99999999)
replace edu0  = 1 if inlist(J70_1, 0)
replace edu0  = 1 if eduyears == 0

generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(J71, 99999999, 99999998, 99999997 )
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

	***********OVER-AGE PRIMARY ATTENDANCE**************
		
	gen overage2plus = 0 if attend==1 & J72_18A==1
	local primgrades 1 2 3 4
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if J70_1==`grade' & schage>prim_age0+1+`i' & overage2plus!=.
				replace overage2plus=1 if K3_1==`grade' & schage>prim_age0+1+`i' & overage2plus!=.
                 }

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 edu0_prim edu2_2024 edu4_2024 {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia"
save Russia_microdata.dta, replace


************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia"
use Russia_microdata.dta, clear

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec comp_higher_2yrs_2529 comp_higher_4yrs_2529 edu0_prim edu2_2024 edu4_2024  *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_1ybefore_no attend_higher_1822_no  comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no

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


set more off
set trace on
foreach i of numlist 0/15 {
	use Russia_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [aweight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

	gen year="2018"
	gen country_year="Russian-Federation"+"_"+year
	destring year, replace
	gen iso_code2="RU"
	gen iso_code3="RUS"
	gen country = "Russian-Federation"
	gen survey="HSE"
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

	cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Russia"
	save indicators_Russia_2019.dta, replace





