clear
import excel using "$aux_data\UIS\completion\UIS_completion_02262020.xlsx", firstrow sheet(list)

drop if year==999999 // drop the years that are not used for calculations

bys iso_code3 year: gen N=_N 
tab N
drop N
label var year "year used for calculation of UIS completion indicators"

save "$aux_data\UIS\completion\UIS_completion_022620208.dta", replace


*/

use "$uis_data\UIS_completion_16Nov2018.dta", clear
ren *, lower
drop stat_unit unit_measure edu_cat age-imm_status unit_mult-decimals  
ren time_period year_uis
for X in any year_uis obs_value: destring X, replace

foreach var of varlist edu_level sex ref_area {
	decode `var', gen(t_`var')
	drop `var'
	ren t_`var' `var'
}
ren ref_area iso_code2
ren obs_value comp_

replace edu_level="prim" if edu_level=="L1"
replace edu_level="lowsec" if edu_level=="L2"
replace edu_level="upsec" if edu_level=="L3"

replace sex="Female" if sex=="F"
replace sex="Male" if sex=="M"
replace sex="Total" if sex=="_T"

reshape wide comp, i(iso_code2 year sex) j(edu_level) string
keep if sex=="Total"
drop sex

order iso year comp_prim comp_low comp_up 
codebook iso //114 countries
merge m:1 iso_code2 using "$aux_data\country_iso_codes_names.dta"
drop if _m==2
drop _merge
drop country_name_mics country_name_WIDE country_name_dhs country_code_dhs

gen year=year_uis
*I merge with the latest metadata that UIS has sent us
merge m:1 iso_code3 year using "$aux_data\UIS\sources\HH surveys metadata_UIS September release_2018.11.16.dta"
drop if _m==2
drop _m

*Now I merge with the database I had before about "sources" to complete those that don't have sources right now.
merge m:1 iso_code3 year using "$aux_data\UIS\sources\UIS_sources_02022018.dta"
drop if _m==2
br if _m==1

*Comparing the sources
count if survey==source_uis // 186 cases
tab source_uis if survey=="" & source_uis!="" // all the databases that are not DHS/MICS
replace survey=source_uis if survey=="" & source_uis!=""
br if survey==source_uis // 416 out of 426 observations
br if survey!=source_uis & survey!="" & source_uis!="" // 4 obs. I keep the latest info that UIS sent
br if survey!=source_uis & survey!="" & source_uis=="" // 6 obs. These are the newest, the ones that UIS just added.
gen survey_uis=survey
save "$uis_data\UIS_completion_02262020_with_sources.dta", replace

