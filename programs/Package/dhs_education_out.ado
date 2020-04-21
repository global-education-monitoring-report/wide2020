* dhs_education_completion: program to create education completion
* Version 1.0
* April 2020

program define dhs_education_completion
	args input_path table1_path table2_path uis_path output_path 
	
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

end
