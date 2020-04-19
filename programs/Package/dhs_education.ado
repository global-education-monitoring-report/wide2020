
foreach part in part1 part2 part3 {
use "$data_dhs\PR\Step1_`part'.dta", clear
*use "$data_dhs\PR\Step1_part3.dta", clear
set more off
*------------------------------------------------------------------------------------------
* Creates education variables
*------------------------------------------------------------------------------------------
*****************************
*	VERSION A
*****************************

* For Completion: Version A is directly with hv109; Version B uses years of education and duration

*Creating generic variables for WIDE
* Attainment, years of education, attendance
*hv109: 0=no education, 1=incomplete primary, 2=complete primary, 3=incomplete secondary, 4=complete secondary, 5=higher
						 
*Primary
generate comp_prim_A = 0
	replace comp_prim_A = 1 if hv109 >= 2
	replace comp_prim_A = . if (hv109 == . | hv109 == 8 | hv109 == 9)

*Upper secondary
gen comp_upsec_A = 0
	replace comp_upsec_A = 1 if hv109 >= 4  //hv109=4: Complete secondary
	replace comp_upsec_A = . if (hv109 == . | hv109 == 8 | hv109 == 9)

*Higher
generate comp_higher_A = 0
	replace comp_higher_A = 1 if hv109 >= 5 //hv109=5: Higher
	replace comp_higher_A = . if (hv109 == . | hv109 == 8 | hv109 == 9)


*****************************
*	VERSION B
*****************************
* Version B: Mix of years of education completed (hv108) and duration of levels --> useful for lower secondary
*----------------------
*	DURATION OF LEVELS
*----------------------
*With the info of years that last primary and secondary I can also compare official duration with the years of education completed..
	gen years_prim		= prim_dur
	gen years_lowsec	= prim_dur + lowsec_dur
	gen years_upsec		= prim_dur + lowsec_dur + upsec_dur
	*gen years_higher	=prim_dur+lowsec_dur+upsec_dur+higher_dur

*Ages for completion
	gen lowsec_age0 = prim_age0 + prim_dur
	gen upsec_age0 = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur-1
	
*bys country_year: egen count_hv108=count(hv108)
*tab country_year if count_hv108==0
*drop count_hv108 // need to check info sh17_a sh17_b for Yemen 2013

label define hv109 0 "no education" 1 "incomplete primary" 2 "complete primary" 3 "incomplete secondary" 4 "complete secondary" 5 "higher"
label values hv109 hv109

*To analyze structure/duration of the education variables:
*bys country_year: tab hv107 hv106, m
*bys country_year: tab hv108, m
*bys country_year: tab hv108 hv109, m


*************************
***** CHANGES IN HV108
***************************


*Republic of Moldova doesn't have info on eduyears
if country_year == "RepublicofMoldova_2005"{
	replace hv108 = hv107               if (hv106 == 0 | hv106 == 1)
	replace hv108 = hv107 + years_prim  if hv106 == 2 
	replace hv108 = hv107 + years_upsec if hv106 == 3
	replace hv108 = 98                  if hv106 == 8 
	replace hv108 = 99                  if hv106 == 9 
} else if  country_year == "Armenia_2005" {
	*Changes to hv108 made in August 2019
	replace hv108 = . 
	replace hv108 = 0          if hv106 == 0  // "primary"
	replace hv108 = hv107      if hv106 == 1 // "primary"
	replace hv108 = hv107 + 5  if hv106 == 2 // "secondary"
	replace hv108 = hv107 + 10 if hv106 == 3 //"higher"
} else if country_year == "Armenia_2010" {
	replace hv108 = . 
	replace hv108 = 0          if hv106 == 0 // "primary" & secondary
	replace hv108 = hv107      if hv106 == 1 | hv106 == 2 // "primary" & secondary
	replace hv108 = hv107 + 10 if hv106 == 3  //"higher"
} else if country_year == "Egypt_2008" {
	replace hv108 = . if 
	replace hv108 = 0 if hv106 == 0 
	replace hv108 = hv107 if hv106 == 1 
	replace hv108 = hv107 + 6 if hv106 == 2 
	replace hv108 = hv107 + 12 if hv106 == 3 
} else if country_year == "Egypt_2014" {
	replace hv108 = .
	replace hv108 = 0          if hv106 == 0 
	replace hv108 = hv107      if hv106 == 1 
	replace hv108 = hv107 + 6  if hv106 == 2
	replace hv108 = hv107 + 12 if hv106 == 3 
} else if country_year == "Madagascar_2003" {
	replace hv108 = . 
	replace hv108 = 0          if hv106 == 0 
	replace hv108 = hv107      if hv106 == 1 
	replace hv108 = hv107 + 5  if hv106 == 2 
	replace hv108 = hv107 + 12 if hv106 == 3
} else if country_year == "Madagascar_2008" {
	replace hv108 = . 
	replace hv108 = 0          if hv106 == 0 
	replace hv108 = hv107      if hv106 == 1 
	replace hv108 = hv107 + 6  if hv106 == 2 // I add 6, not 5 to correct
	replace hv108 = hv107 + 13 if hv106 == 3  // I add 13, not 6 to correct
} else if country_year == "Zimbabwe_2005" {
	replace hv108 = . 
	replace hv108 = 0          if hv106 == 0  // "no education"
	replace hv108 = hv107      if hv106 == 1 // "primary"
	replace hv108 = hv107 + 7  if hv106 == 2  // "secondary"
	replace hv108 = hv107 + 13 if hv106 == 3  //"higher"	
} else {
	replace hv108 = hv108
}
*Tabs to check edu variables
*bys country_year: tab hv108, m
*bys country_year: tab hv109, m
*bys country_year: tab hv108 hv109, m
	
*Hv108: 
*Albania 2017: doesn't have hv108==10, 11
*Mali 2018: doesn't have hv108==11
*Haiti 2017, Pakistan 2018, South Africa 2016: only goes until 16 years
*Indonesia 2017, Maldives 2017, Mali 2018: only goes until 17 years

*Creating "B" variables
foreach X in prim lowsec upsec {
	cap generate comp_`X'_B = 0
	replace comp_`X'_B = 1 if hv108 >= years_`X'
	replace comp_`X'_B = . if (hv108 == . | hv108 >= 90) // here includes those ==98, ==99 
	replace comp_`X'_B = 0 if (hv108 == 0 | hv109 == 0) // Added in Aug 2019!!	
}

*For 2 countries, I use hv109 (I don't find other solution)
replace comp_upsec_B = comp_upsec_A if country_year == "Egypt_2005" // I don't know why if goes to 28.93 if I don't do this... Check difference between A & B later
compress

*save "$data_dhs\PR\Step2_part3.dta", replace
save "$data_dhs\PR\Step2_`part'.dta", replace
}
****************************************************

/*
***********************
*For Bilal's request
***********************

*https://dhsprogram.com/Data/Guide-to-DHS-Statistics/School_Attendance_Ratios.htm
*https://dhsprogram.com/pubs/pdf/DHSG4/Recode7_Map_31Aug2018_DHSG4.pdf

* HV121 Household member attended school during current school year.
* HV122 Educational level attended during current school year, with the same standardized levels as explained for HV106. (0=no education/preschool, 1=primary, 2=secondary, 3=higher)

use "$data_dhs\PR\Step2_part1.dta", clear
append using "$data_dhs\PR\Step2_part2.dta"
keep iso hv005 hv104 country* year hv105 hv12* year* prim_age0
drop country_code_dhs years_prim years_lowsec years_upsec
keep if year>=2015

ren hv105 age
ren hv005 hhweight

label define hv121 0 "no" 1 "currently attending" 2 "attended some time"
label define hv122 0 "no educ/preschool" 1 "primary" 2 "secondary" 3 "higher"
for X in any 1 2: label values hv12X hv12X

gen country_age=country_year+" "+"(AgeStart"+"="+string(prim_age0)+")"
order iso_code3 country_year country year year_folder prim_age0
compress
save "$data_dhs\PR\dhs_temp_attendance.dta", replace

*---------------------------------------------------------
use "$data_dhs\PR\dhs_temp_attendance.dta", clear

replace hv122=. if hv122==8|hv122==9
replace hv126=. if hv126==8|hv126==9

*Attendance current year
recode hv121 (1/2=1) (8/9=.), gen(attend_current)
label define yn 0 "no" 1 "yes"
label values attend_current yn


*Attendance previous year--> The variables is still 0=no, 1=yes (I checked each database)
clonevar attend_previous=hv125 

*To find out starting from what age there is info on attendance
bys country_year age: egen max_attend_current=max(attend_current)
bys country_year age: egen max_attend_previous=max(attend_previous)

bys country_year: tab age max_attend_current, m
bys country_year: tab age max_attend_previous, m

*Replacing by missing those that don't have info on edu but appear with no attending
for X in any current previous: replace attend_X=. if max_attend_X==0
drop max*

*bys country_age: tab age attend_curr if age>=3 & age<=8, m
*bys country_age: tab hv122 attend_curr if age>=3 & age<=8, m
*bys country_age: tab attend_curr if age>=3 & age<=8, m
*codebook hv122, tab(100)

gen status_current=1 if attend_current==0
replace status_current=2 if attend_current==1 & hv122==0 // pre-primary level
replace status_current=3 if attend_current==1 & hv122==1 // primary level
replace status_current=4 if attend_current==1 & hv122==2 // secondary level
replace status_current=5 if attend_current==1 & hv122==3 // higher level

tab age status_current if country=="Afghanistan"
tab age attend_current if country=="Afghanistan"

gen status_previous=1 if attend_previous==0
replace status_previous=2 if attend_previous==1 & hv126==0 // pre-primary level
replace status_previous=3 if attend_previous==1 & hv126==1 // primary level
replace status_previous=4 if attend_previous==1 & hv126==2 // secondary level
replace status_previous=5 if attend_previous==1 & hv126==3 // higher level

label define level_ed 1 "oos" 2 "preschool" 3 "primary" 4 "secondary" 5 "higher"
foreach X in current previous {
	label values status_`X' level_ed
	tab status_`X', gen(`X'_)
	ren `X'_1 `X'_oos
	ren `X'_2 `X'_preschool
	ren `X'_3 `X'_primary
	ren `X'_4 `X'_secondary
	ren `X'_5 `X'_higher	
}

*bys country_age: tab current_preschool if age>=3 & age<=8, m
*bys country_age: sum current_o current_pre current_pri if age>=3 & age<=8

* OOS last year (previous_oos==1)
*-- and oos this year (value=2)
*-- and primary this year  (value=3)
*-- and pre-primary this year  (value=4)

gen current=0 if previous_oos==1
replace current=1 if previous_oos==1 & current_oos==1
replace current=2 if previous_oos==1 & current_preschool==1
replace current=3 if previous_oos==1 & current_primary==1
replace current=4 if previous_oos==1 & current_secondary==1
replace current=5 if previous_oos==1 & current_higher==1
replace current=. if current==0 & hv122==.
label define current 1 "CurrOos" 2 "CurrPresc" 3 "CurrPrim" 4 "CurrSec" 5 "CurrHigh"
label values current current

tab current, gen(PrevOos_)
ren PrevOos_1 PrevOos_CurrOos
ren PrevOos_2 PrevOos_CurrPresc
ren PrevOos_3 PrevOos_CurrPrim
ren PrevOos_4 PrevOos_CurrSec
ren PrevOos_5 PrevOos_CurrHigh

merge m:1 country_year using "$data_dhs\PR\dhs_adjustment.dta", keepusing(adj1_norm)
drop if _merge==2
drop _merge
ren adj1_norm adjustment

*Creating the appropiate age according to adjustment
gen ageU=age
gen ageA=age-1 

gen agestandard=ageU if adjustment==0
replace agestandard=ageA if adjustment==1


collapse prim_age0 current_* previous_* PrevOos_* if age>=5 & age<=10 [iw=hhweight], by(iso_code country year)
collapse prim_age0 current_* previous_* PrevOos_* if agestandard>=5 & agestandard<=10 [iw=hhweight], by(iso_code country year)


collapse prim_age0 current_* previous_* PrevOos_* if age>=5 & age<=10 [iw=hhweight], by(iso_code country year age)

collapse prim_age0 current_* previous_* PrevOos_* [iw=hhweight], by(iso_code country year age)
collapse prim_age0 current_* previous_* PrevOos_* [iw=hhweight], by(iso_code country year agestandard)


tab comparison, m

replace comparison=. if previous_oos==1 & hv122==.

tab comparison if age>=3 & age<=8, m

ren 

br if comparison==1 & (age>=3 & age<=10)

tab country_age if attend_current==1 & comparison==1

bys country_age: tab attend_current if hv122==., m




*codebook hv121 hv129 hv122 hv123 hv124 , tab(100) // current year 
*codebook hv125 hv126 hv127 hv128, tab(100) // previous year



*hv125: 0=no, 1=yes
clonevar attend_prev=hv125
tab hv126 hv125, m
*replace attend_prev=1 if hv125==0 & hv126==0 // those in preschool (diff for oos)
*replace attend_prev=. if hv126==. & (hv125==1|hv125==2|hv125==8|hv125==.)

foreach X in hv122 hv126 {
	gen `X'c="preschool" if `X'==0
	replace `X'c="primary" if `X'==1
	replace `X'c="secondary" if `X'==2
	replace `X'c="higher" if `X'==3
}



*No attend
recode attend_curr (1=0) (0=1), gen(noattend_curr)
recode attend_prev (1=0) (0=1), gen(noattend_prev)


*tab hv122 attend, m
*tab hv122 attend if age==10, m

codebook hv122, tab(100)
tab hv122 hv121, m


for X in any preschool primary secondary higher: gen attend_curr_X=0
replace attend_curr_preschool =1 if hv122==0 
replace attend_curr_primary   =1 if hv122==1 
replace attend_curr_secondary =1 if hv122==2
replace attend_curr_higher    =1 if hv122==3
*for X in any preschool primary secondary higher: replace attend_curr_X=. if hv121==.


for X in any preschool primary secondary higher: gen attend_prev_X=0 if attend_prev==1
replace attend_prev_preschool =1 if hv126==0 & attend_prev_preschool ==0 
replace attend_prev_primary   =1 if hv126==1 & attend_prev_primary   ==0 
replace attend_prev_secondary =1 if hv126==2 & attend_prev_secondary ==0
replace attend_prev_higher    =1 if hv126==3 & attend_prev_higher    ==0
for X in any preschool primary secondary higher: replace attend_prev_X=. if (attend_prev==.|hv126==.)

tab attend_curr, 
for X in any preschool primary secondary higher: tab attend_curr_X attend_curr, m

*sum noattend attend* at_* if age==10, separator(11)

collapse noattend_curr attend_curr*  [iw=hhweight], by (iso_code3 country_year country year age)

order iso_code3 country_year country year age no_attend attend*

save "$data_dhs/DHS_age_attendance.dta", replace
export delimited using "$data_dhs/DHS_age_attendance.csv", replace

*/

foreach part in part1 part2 part3 {
use "$data_dhs\PR\Step2_`part'.dta", clear
*use "$data_dhs\PR\Step2_part3.dta", clear
set more off

*Age
ren hv105 age
replace age=. if age>=98

	gen ageA=age-1 // before it had the restriction "if adj==1" . I'll show both adjusted and unadjusted and a flag that says if it should be adjusted!
	ren age ageU

*Attendance to higher educ
recode hv121 (1/2=1) (8/9=.), gen(attend)

*------------------
*	Out of school
*------------------
*codebook hv121 hv122, tab(100)

gen eduout_1 = .
replace eduout_1 = 0 if (hv121 == 1 | hv121 == 2) // goes to school
replace eduout_1 = 1 if (hv121 == 0) // does not go to school
replace eduout_1 = . if ageU == .
replace eduout_1 = . if (hv121 == 8 | hv121 == 9 | hv121 == .)
replace eduout_1 = . if (hv122 == 8 | hv122 == 9) & eduout_1 == 0 // missing when age, attendance or level of attendance (when goes to school) is missing

gen eduout = eduout_1
replace eduout = 1 if hv122 == 0 // level attended: goes to preschool
*** replace eduout=1 if hv106==0 // those whose highest ed level is preschool.. DO NOT ADD THIS LINE, makes it really different to UIS estimates!! See the version 4 for the results!
drop eduout_1

*--------------------------------------------
* Completion indicators (version A & B) with age limits 
*--------------------------------------------
*Age limits for Version A and B
foreach Y in A B {
	foreach X in prim upsec {
		foreach AGE in ageU ageA {
			gen comp_`X'_v2_`Y'_`AGE' = comp_`X'_`Y' if `AGE' >= `X'_age1 + 3 & `AGE' <= `X'_age1 + 5 
		}
	}
}

merge m:1 country_year using "$data_dhs\PR\dhs_adjustment.dta", keepusing(adj1_norm) keep(master match) nogenerate
*merge m:1 country_year using "C:\Users\Rosa_V\Desktop\casa\dhs_adjustment.dta", keepusing(adj1_norm)
rename adj1_norm adjustment

*Creating the appropiate age according to adjustment
generate agestandard = ageU if adjustment == 0
replace agestandard = ageA if adjustment == 1

*Age limits 
foreach AGE in agestandard  {
	for X in any prim upsec: cap generate comp_X_v2_A = comp_X_A if `AGE' >= X_age1 + 3 & `AGE' <= X_age1 + 5
}

*-- Collapse for comparison with UIS (adjusted vs not adjusted)
*collapse (mean) comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* prim_age* lowsec_age* upsec_age*  [iw=hv005], by(country_year country iso_code3 year adjustment)

*Dropping adjusted ages and the _ageU indicators (but keep ageU)
cap drop *ageA *_ageU

*I keep the version B
for X in any prim lowsec upsec: ren comp_X_B comp_X

*Age limits 
foreach AGE in agestandard  {
	for X in any prim lowsec upsec: gen comp_X_v2=comp_X if `AGE'>=X_age1+3 & `AGE'<=X_age1+5
	gen comp_prim_1524=comp_prim if `AGE'>=15 & `AGE'<=24
	gen comp_upsec_2029=comp_upsec if `AGE'>=20 & `AGE'<=29
	*gen comp_higher_2529=comp_higher if `AGE'>=25 & `AGE'<=29
	gen comp_lowsec_1524=comp_lowsec if `AGE'>=15 & `AGE'<=24
}

*-- Collapse comparing hv108 & hv109
*collapse (mean) comp_prim_v2 comp_prim_v2_A comp_lowsec_v2 comp_upsec_v2 comp_upsec_v2_A prim_age* lowsec_age* upsec_age*  [iw=hv005], by(country_year country iso_code3 year adjustment)

*Dropping the A version (not going to be used)
cap drop *_A

* FOR UIS request
generate comp_prim_aux = comp_prim if agestandard >= lowsec_age1 + 3 & agestandard <= lowsec_age1 + 5
generate comp_lowsec_aux = comp_lowsec if agestandard >= upsec_age1 + 3 & agestandard <= upsec_age1 + 5

*--------------------
* Years of education
*--------------------
*codebook hv108, tab(200)
*If this eduyears would be a version, it would be version "A" because it comes directly from DHS variables.
generate eduyears = hv108
replace eduyears = 30 if hv108 >= 30 // I put the max of years as 30
replace eduyears = . if hv108 >= 90


*With age limits
generate eduyears_2024 = eduyears if agestandard >= 20 & agestandard <= 24
foreach X in 2 4 {
	generate edu`X'_2024 = 0
		replace edu`X'_2024 = 1 if eduyears_2024 < `X'
		replace edu`X'_2024 = . if eduyears_2024 == .
}

*----------------------
* Never been to school
*----------------------
recode hv106 (0=1) (1/3=0) (4/9=.), gen(edu0)
gen never_prim_temp=1 if (hv106==0|hv109==0) & (hv107==. & hv123==.)
replace edu0=1 if (eduyears==0|never_prim_temp==1)
replace edu0=. if eduyears==.

foreach AGE in agestandard  {
	gen edu0_prim1 = edu0 if `AGE' >= prim_age0 + 3 & `AGE' <= prim_age0 + 6
	*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
	*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
}

drop never_prim_temp edu0

*codebook hv121 hv122, tab(200)
generate attend_higher = 0
	replace attend_higher = 1 if [(hv121 == 1 | hv121 == 2) & hv122 == 3]
	replace attend_higher = . if [(hv121 == 8 | hv121 == 9 )|(hv122 == 8 | hv122 == 9)]


*Durations for out-of-school
	generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	generate upsec_age0_eduout = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
	
*Creating variables for Bilal: attendance to each level by age
*https://dhsprogram.com/Data/Guide-to-DHS-Statistics/School_Attendance_Ratios.htm

keep country_year year hv005 age* iso_code3 hv007 hv104 hv025 hv270 hv005 hv024 comp_* eduout* attend* $extra_vars prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv122 hv124 years_*

foreach AGE in agestandard {
	for X in any prim lowsec upsec: generate eduout_X = eduout if `AGE' >= X_age0_eduout & `AGE' <= X_age1_eduout
	generate attend_higher_1822 = attend_higher if `AGE' >= 18 & `AGE' <= 22
}
drop attend_higher

* CREATING THE DISSAGREGATION VARIABLES & weight

*weight
rename hv005 hhweight // sample weight

*table country_year [iw=hhweight], c(mean comp_prim_v2 mean comp_lowsec_v2 mean comp_upsec_v2)

*Location (Urban=1)
rename hv025 location
recode location (2=0) (9=.)
label define location 0 "rural" 1 "urban"

*Sex
ren hv104 sex
recode sex (2=0) (9=.) (3/4=.)
label define sex 0 "female" 1 "male"

*Wealth
ren hv270 wealth
label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"

for Z in any location sex wealth: label values Z Z

*Converting the categories to strings
foreach var in location sex wealth {
	cap sdecode `var', replace
	cap replace `var'=proper(`var')
}

*Region
ren hv024 region

	** Solving name of regions
		*Region: Had to be transformed to string before appending every country to avoid putting the same label to all regions
		*https://www.stata.com/manuals13/m-4string.pdf#m-4string
		qui include "$programs_dhs_aux/dhs_fixes_regions.do"

*Religion
* should see how to uniquely identify HOUSEHOLDS later
merge m:m hh_id using "$data_dhs\dhs_ethnicity_religion_v2.dta", keepusing (ethnicity religion)
drop if _merge==2 // added Aug 2019
cap drop _merge

ren ageU age

order country_year iso_code3 year hhweight age* hv007 $categories_collapse comp_* eduout* edu* attend* $extra_vars round adjustment
compress
*save "$data_dhs\PR\Step3_part3.dta", replace
save "$data_dhs\PR\Step3_`part'.dta", replace
}


set more off
use "$data_dhs\PR\Step3_part1.dta", clear
append using  "$data_dhs\PR\Step3_part2.dta"
append using  "$data_dhs\PR\Step3_part3.dta"
drop year
bys country_year: egen year=median(hv007)
keep hhweight *age* hv007 year ///
iso_code3 country* cluster hh_id individual_id round ///
adjustment comp* edu* *attend* location sex wealth ethnicity religion region 
drop *aux*
*drop region ethnicity religion
ren hv007 year_interview
label var year "Median year of interview"
ren agestandard age_adjusted
cap drop *_ageU
drop edu0_prim1
drop *age0* *age1*
order iso country* year* *weight *id cluster age* adjustment location sex wealth ethnicity religion eduyear* comp* attend* eduout*
compress
*save "\\hqfs\tech\STATA\WIDE\microdata_Bilal\DHS_Microdata.dta", replace // this is the database I sent to Bilal
save "C:\Users\Rosa_V\Dropbox\microdata_Bilal\microdata_DHS.dta", replace // this is the database I sent to Bilal

*********************************************************************************************************************************
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no


foreach part in part1 part2 part3 {
use "$data_dhs\PR\Step3_`part'.dta", clear
*use "$data_dhs\PR\Step3_part3.dta", clear
set more off

*Dropping variables
drop hhid hvidx individual_id lowsec_age0 upsec_age0 prim_age1 lowsec_age1 upsec_age1 eduyears adjustment

*--The year is the median of the year of interview
drop year
bys country_year: egen year=median(hv007)

*Create variables for count of observations
foreach var of varlist $varlist_m  {
		gen `var'_no=`var'
}

keep country_year iso_code3 year $categories_collapse hhweight $varlist_m $varlist_no comp_prim_aux comp_lowsec_aux
compress
*save "$data_dhs\PR\Step4_part3.dta", replace
save "$data_dhs\PR\Step4_`part'.dta", replace
}

***************
*https://www.stata.com/meeting/baltimore17/slides/Baltimore17_Correia.pdf

cap mkdir "$data_dhs\PR\collapse"


/*
cd "$data_dhs\PR\collapse"
foreach part in part1 part2 part3 {
*foreach part in part3 {
use "$data_dhs\PR\Step4_`part'.dta", clear
set more off
tuples $categories_collapse, display
foreach i of numlist 0/6 12/18 20/21 31 41 {
	preserve
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year `tuple`i'')
	*collapse (mean) $varlist_m comp_prim_aux comp_lowsec_aux (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year `tuple`i'')
	gen category="`tuple`i''"
	cap gen part="`part'"
	save "result`i'_`part'.dta", replace
	restore
}
}
*/

* Appending the results
cd "$data_dhs\PR\collapse"
cap use "result0_part1.dta", clear
gen t_0=1
foreach part in part1 part2 part3 {
foreach i of numlist 0/6 12/18 20/21 31 41 {
 	append using "result`i'_`part'"
}
}
gen survey="DHS"
include "$gral_dir/WIDE/programs/standardizes_collapse_dhs_mics.do"

save "$data_dhs\PR\dhs_collapse_by_categories_v10.dta", replace
export delimited "$data_dhs\PR\dhs_collapse_by_categories_v10.csv", replace
