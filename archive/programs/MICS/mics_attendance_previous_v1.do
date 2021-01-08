
global data_mics "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\hl"
global aux_data "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\auxiliary_data"


use "$data_mics\Step_0_temp.dta", clear
append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\mics6\hl\Step_0_temp.dta" 
keep country* year* sex ed* hh5y code* hhweight *age*
bys country_year: egen year=median(hh5y) 
keep if year>=2015 // same result of countries with year_folder
compress
save "$data_mics/temp_dhs_attendance.dta", replace

***********************************************************
use "$data_mics/temp_dhs_attendance.dta", clear
*ed3=ever
*Age to be used: schage.
label var ed5 "Attended school during CURRENT school year"
label var ed6a "Level edu attended - CURRENT school year"
label var ed6a "Level edu attended - CURRENT school year (RECODE)"

label var ed7 "Attended school - PREVIOUS school year"
label var ed8a "Level edu attended - PREVIOUS school year"
label var ed8a "Level edu attended - PREVIOUS school year (RECODE)"

*Attending currently
gen attend_current=0 if ed5=="no"
replace attend_current=1 if ed5=="yes"

*Attending previously
gen attend_previous=0 if ed7=="no"
replace attend_previous=1 if ed7=="yes"

*Fixing the levels
bys country: tab code_ed6a,m
*codebook code_ed6a code_ed8a, tab(200)
*tab code_ed6a attend_current, m // current year
*tab code_ed8a attend_previous, m // previous year

for X in any 6 8: clonevar code_edXa_original=code_edXa // I keep the original variable
for X in any ed6a ed8a: recode code_X (23=21) (24=22) (32/33=3) (98/99=.) 

for X in any ed6a ed8a: decode code_X, gen(s_X)
for X in any ed6a ed8a: tostring code_X, gen(t_X)
foreach num of numlist 0/3 {
for X in any ed6a ed8a: replace t_X="`num'0" if t_X=="`num'"
}
for X in any ed6a ed8a: gen c_X=t_X+"_"+s_X
for X in any ed6a ed8a: replace c_X="" if c_X=="._"
replace c_ed6a="000_OutSchool" if attend_current==0
replace c_ed8a="000_OutSchool" if attend_previous==0

for X in any ed6a ed8a: tab c_X, gen(X_)

*Level attended currently for those that were OOS in the previous year
foreach num of numlist 1/12 {
	clonevar PrevOos_`num'=ed6a_`num'
	replace PrevOos_`num'=. if attend_previous!=0
}

*merge with information of duration of levels, school calendar, official age for primary, etc:
	replace country="Kyrgyzstan" if country=="KyrgyzRepublic"
	replace country="Gambia" if country=="TheGambia"
	rename country country_name_mics
	merge m:m country_name_mics using "$aux_data\country_iso_codes_names.dta" // to obtain the iso_code3
	drop if _merge==2
	drop country_name_mics country_name_WIDE iso_code2 iso_numeric country_name_dhs _merge

	gen year_original=year
	replace year=2017 if year==2018 // there is no info for 2018 in the duration database
	merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	drop year
	ren year_original year

	drop if _m==2
	drop _merge
	compress
save "$data_mics/dhs_attendance.dta", replace

	
use "$data_mics/dhs_attendance.dta", clear

collapse ed6a_1-ed6a_12 ed8a_1-ed8a_12 Prev* if schage>=5 & schage<=10 [iw=hhweight], by(iso country year prim_age_uis)
gen schage=.
order iso country year prim_age schage
br

use "$data_mics/dhs_attendance.dta", clear
collapse ed6a_1-ed6a_12 ed8a_1-ed8a_12 Prev* [iw=hhweight], by(iso country year prim_age_uis schage) 
order iso country year prim_age schage
 
 

 
