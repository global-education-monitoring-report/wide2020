
global data_mics "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\hl"
global aux_data "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\auxiliary_data"


use "$data_mics\Step_0_temp.dta", clear
append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\mics6\hl\Step_0_temp.dta" 
keep country* year* sex ed* hh5y code* hhweight *age* hh_id
bys country_year: egen year=median(hh5y) 
keep if year>=2015 // same result of countries with year_folder

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


*We only want those "at the primary starting age" 
keep if schage==prim_age_uis
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

*Checking the levels by country and only keeping the oos, preschool, prim
*tab ed6b_nr code_ed6a if country=="Turkmenistan", m
*codebook ed6b_nr code_ed6a if country=="Turkmenistan", tab(100)
for X in any 6 8: replace code_edXa=1 if code_edXa==60 & edXb_nr<=3 // general school coded as primary for those up until grade 3 (duration of primary)


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

codebook code_ed6a code_ed8a, tab(100)
clonevar level_current=code_ed6a
clonevar level_previous=code_ed8a
for X in any current previous: replace level_X=. if level_X>1
for X in any current previous: decode level_X, gen(t_X)
for X in any current previous: drop level_X
for X in any current previous: rename t_X level_X

for X in any current previous: replace level_X="OOS" if attend_X==0

tab level_previous level_current 

for X in any current previous: tab level_X, gen(X)
for X in any current previous: ren X1 XOos
for X in any current previous: ren X2 XPreschool
for X in any current previous: ren X3 XPrimary

compress
save "$data_mics/dhs_attendance.dta", replace


*	
use "$data_mics/dhs_attendance.dta", clear
gen lowsec_age0=prim_age0+prim_dur
gen upsec_age0=lowsec_age0+lowsec_dur

for X in any prim lowsec upsec: gen prim_age1=X_age0+X_dur-1
	
clonevar prim_age_0=prim_age_uis
gen prim_age_1=prim_age_0+prim_dur_uis
	
*households with children in primary-school age
gen temp1=1 if prim_age_0>=schage & schage<=prim_age_1
bys hhid: egen temp2=sum(temp1)



tab level_current if level_previous=="OOS" & country=="Kazakhstan", m
tab level_current if  country=="Kazakhstan", m
tab level_previous if  country=="Kazakhstan", m
tab attend_current if  country=="Kazakhstan", m
tab attend_previous if  country=="Kazakhstan", m



use "$data_mics/dhs_attendance.dta", clear
drop if level_previous==""
collapse currentOos currentPreschool currentPrimary [iw=hhweight], by(iso country year prim_age_uis level_previous)
ren prim_age_uis PrimaryStartAge
order iso country year PrimaryStartAge level_previous
sort country year level_previous
save "$data_mics/dhs_attendance_c1.dta", replace


use "$data_mics/dhs_attendance.dta", clear
drop if level_previous==""
collapse previousOos previousPreschool previousPrimary [iw=hhweight], by(iso country year prim_age_uis )
ren prim_age_uis PrimaryStartAge
order iso country year PrimaryStartAge 
sort country year
br
ren previousOos previous_1
ren previousPreschool previous_2
ren previousPrimary previous_3
reshape long previous_, i(iso country year) j(prev)
ren previous_ share_previous
gen level_previous="OOS" if prev==1
replace level_previous="preschool" if prev==2
replace level_previous="primary" if prev==3
drop prev
order iso country year PrimaryStartAge level_previous share
save "$data_mics/dhs_attendance_c2.dta", replace

use "$data_mics/dhs_attendance_c1.dta"
merge 1:1 iso country year PrimaryStartAge level_previous using "$data_mics/dhs_attendance_c2.dta", keepusing(share)
drop _merge
br

