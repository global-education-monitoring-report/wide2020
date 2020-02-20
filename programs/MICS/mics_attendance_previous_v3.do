
global data_mics "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\hl"
global aux_data "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\auxiliary_data"


use "$data_mics\Step_0_temp.dta", clear
append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\mics6\hl\Step_0_temp.dta" 
keep country* year* sex ed* hh5y code* hhweight *age* hh_id ind* wealth ed_completed
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

	save "$data_mics/temp_dhs_attendance.dta", replace

********************

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

*codebook code_ed6a code_ed8a, tab(100)
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

*households with children in primary-school age
clonevar prim_age_0=prim_age_uis
gen prim_age_1=prim_age_0+prim_dur_uis

gen age_prim_range=1 if schage>=prim_age_0 & schage<=prim_age_1

bys hh_id: egen child_age_prim=sum(age_prim_range)
replace child_age_prim=1 if child_age_prim>1 & child_age_prim!=.

gen attend_current_primary=attend_current if age_prim_range==1
bys hh_id: egen child_attend_prim=max(attend_current_primary)
sort hh_id
*br hh_id prim_age_0 age_prim_range prim_age_1 schage child_* attend_current_primary
*br hh_id prim_age_0 age_prim_range prim_age_1 schage child_* attend_current_primary if child_attend_prim==0
*br hh_id prim_age_0 age_prim_range prim_age_1 schage child_* attend_current_primary if child_age_prim==1 & child_attend_prim==.

*codebook hh_id if child_age_prim==1 & child_attend_prim==. // 9000 households (out of 234420) with no info on attendance
dis (9000/234420)*100 // 3.8% of hh
replace child_attend_prim=2 if child_attend_prim==. & child_age_prim==0
tab child_attend_prim, m
label define child_attend_prim 0 "All oos" 1 "At least 1 attends primary" 2 "no primary age members"
label values child_attend_prim child_attend_prim

label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth
compress
save "$data_mics/dhs_attendance.dta", replace

******************************

use "$data_mics/dhs_attendance.dta", clear
keep if  age_prim_range==1
* Years of education: represented by ed4b_nr
ren ed4b ed4b_string
ren ed4b_nr ed4b

gen eduyears=ed4b

*Nigeria
	replace eduyears=0 if ed4b>=1 & ed4b<=3 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	replace eduyears=ed4b-10 if ed4b>=10 & ed4b<=16 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	replace eduyears=ed4b-14 if ed4b>=20 & ed4b<=26 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	
*Lao	
	replace eduyears=ed4b-10 if ed4b>=11 & ed4b<=15 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-15 if ed4b>=21 & ed4b<=24 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-21 if ed4b>=31 & ed4b<=33 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-28 if ed4b>=41 & ed4b<=43 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-38 if ed4b>=51 & ed4b<=57 & country_year=="LaoPDR_2017"

*Suriname
tab ed4a if country=="Suriname"
tab eduyears ed4a if country=="Suriname", m
	replace ed4b=0 if ed4a=="ece" & country_year=="Suriname_2018"
	replace ed4b=ed4b-2 if ed4a=="primary" & ed4b!=98 & country_year=="Suriname_2018"

	*Super important step (FOR ALL)
	replace eduyears=97 if ed4b==97|ed4b==98|ed4b==99
	replace eduyears=0 if ed4b==0 // this keeps the format for version B
	
	replace eduyears=eduyears-1 if ed_completed=="no" & (eduyears<97)
	replace eduyears=. if eduyears==97	
	replace eduyears=. if ed4b==.
tab eduyears, m
br if eduyears==32
bys country: tab eduyears, m

*Theoretical grade they should be:
gen theo_grade=(schage-prim_age_0)+1
replace theo_grade=. if schage<prim_age_0
*br prim_age_0 schage theo if schage==10
gen age_grade_gap=theo_grade-eduyears
tab age_grade_gap
bys country: tab age_grade_gap, m
replace age_grade_gap=. if age_grade_gap<=-3
replace age_grade_gap=0 if age_grade_gap<0
replace age_grade_gap=5 if age_grade_gap>=5 & age_grade_gap!=.
tab age_grade_gap, gen(gap_)
tab age_grade_gap, gen(nr_gap_)
gen nr_Oos=currentOos
drop if currentOos==.

collapse (mean) gap_* (count) nr_Oos [weight=hhweight], by(iso country year prim_age_uis currentOos)
order iso country year prim_age_uis current gap*
br




use "$data_mics/dhs_attendance.dta", clear
drop if child_attend_prim==.
collapse currentOos currentPreschool currentPrimary if schage==prim_age_0-1 [iw=hhweight], by(iso country year prim_age_uis child_attend_prim)
ren prim_age_uis PrimaryStartAge
order iso country year PrimaryStartAge child_attend_prim
sort country year child_attend_prim
save "$data_mics/dhs_attendance_household.dta", replace

use "$data_mics/dhs_attendance.dta", clear
drop if child_attend_prim==.
collapse currentOos currentPreschool currentPrimary if schage==prim_age_0-1 [iw=hhweight], by(iso country year prim_age_uis child_attend_prim wealth)
ren prim_age_uis PrimaryStartAge
order iso country year PrimaryStartAge child_attend_prim wealth
sort country year child_attend_prim wealth
save "$data_mics/dhs_attendance_household_by_wealth.dta", replace





*We only want those "at the primary starting age" & one year before
keep if (schage==prim_age_uis) |(schage==prim_age_uis-1)
compress
	

*	
use "$data_mics/dhs_attendance.dta", clear
gen lowsec_age0=prim_age0+prim_dur
gen upsec_age0=lowsec_age0+lowsec_dur





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

