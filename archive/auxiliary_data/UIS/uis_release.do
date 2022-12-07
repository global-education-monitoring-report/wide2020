global aux_data "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\auxiliary_data"
global uis_data "$aux_data\UIS"

*---------------------------------------------------------------------------------------------------------------------------------------------
clear
import delimited using "$uis_data\UIS_release_09272019.csv"
ren *, lower
keep stat_unit edu_level sex wealth_quintile location ref_area time_period obs_value
ren time_period year_uis

ren stat_unit indicator
ren ref_area iso_code2
ren obs_value value_
ren wealth_quintile wealth

replace indicator="comp" if indicator=="CR"
replace indicator="eduout" if indicator=="ROFST_PHH"

replace edu_level="prim" if edu_level=="L1"
replace edu_level="lowsec" if edu_level=="L2"
replace edu_level="upsec" if edu_level=="L3"

replace sex="Female" if sex=="F"
replace sex="Male" if sex=="M"
replace location="Rural" if location=="RUR"
replace location="Urban" if location=="URB"

for X in any sex location wealth: replace X="Total" if X=="_T"
for X in any 1 2 3 4 5: replace wealth="Quintile X" if wealth=="QX"

tab edu_level indicator, m
gen stat=""
for X in any prim lowsec upsec: replace stat="comp_X" if edu_level=="X" & indicator=="comp"
for X in any prim lowsec upsec: replace stat="eduout_X" if edu_level=="X"  & indicator=="eduout"
drop edu_level indicator
tab stat

reshape wide value_, i(iso_code2 year sex location wealth) j(stat) string

for X in any prim lowsec upsec: ren value_comp_X comp_X
for X in any prim lowsec upsec: ren value_eduout_X eduout_X

gen category=""
replace category="Total" if sex=="Total" & location=="Total" & wealth=="Total"
for X in any sex location wealth: replace X="" if category=="Total"
for X in any sex location wealth: replace X="" if X=="Total"
replace category="Sex" if sex!="" & location=="" & wealth==""
replace category="Location" if sex=="" & location!="" & wealth==""
replace category="Wealth" if sex=="" & location=="" & wealth!=""
replace category="Sex & Location" if sex!="" & location!="" & wealth==""
replace category="Sex & Wealth" if sex!="" & location=="" & wealth!=""
replace category="Location & Wealth" if sex=="" & location!="" & wealth!=""
replace category="Sex & Location & Wealth" if sex!="" & location!="" & wealth!=""
br

*merge to have iso_code3
merge m:1 iso_code2 using "$aux_data\country_iso_codes_names.dta", keepusing(iso_code3 country)
drop if _merge==2
drop _merge
order iso* country year category sex location wealth comp_p comp_l comp_u eduout_p eduout_l eduout_u
compress
save "$uis_data\UIS_release_09272019.dta", replace

***************************
*Merging it with the source
use "$uis_data\UIS_release_09272019.dta", clear
merge m:m iso_code3 year_uis using "$uis_data\UIS_indicators_29Nov2018_with_metadata.dta", keepusing(year survey survey_uis)
*br if category=="Total" & _merge==1
*br if country=="Mexico" & year_uis==1992

