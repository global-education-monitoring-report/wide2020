global dir "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\auxiliary_data\UIS\completion"
global aux_data "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\auxiliary_data"

foreach level in prim lowsec upsec {
foreach indicator in comp eduout {

	insheet using "$dir\csv\UIS_`indicator'_`level'_02262020.csv", clear
	set more off
	keep edu_level sex wealth_quintile location ref_area time_period obs_value obs_status
	ren time_period year_uis
	ren ref_area iso_code2
	ren obs_value `indicator'_`level'
	ren obs_status status_`indicator'_`level'
	*What is obs_status?
	drop edu_level
	
	replace sex="Female" if sex=="F"
	replace sex="Male" if sex=="M"

	replace location="Urban" if location=="URB"
	replace location="Rural" if location=="RUR"
	
	ren wealth_quintile wealth
	for X in any 1 2 3 4 5: replace wealth="Quintile X" if wealth=="QX"
	
	for X in any sex location wealth: replace X="Total" if X=="_T"

	order iso year sex location wealth
save "$dir\UIS_`indicator'_`level'_02262020.dta", replace
}
}

global id_vars iso_code2 year sex location wealth

use "$dir\UIS_comp_prim_02262020.dta", clear
merge 1:1 $id_vars using "$dir\UIS_comp_lowsec_02262020.dta", nogen
merge 1:1 $id_vars using "$dir\UIS_comp_upsec_02262020.dta", nogen
merge 1:1 $id_vars using "$dir\UIS_eduout_prim_02262020.dta", nogen
merge 1:1 $id_vars using "$dir\UIS_eduout_lowsec_02262020.dta", nogen
merge 1:1 $id_vars using "$dir\UIS_eduout_upsec_02262020.dta", nogen

    gen category="Total" if sex=="Total" & location=="Total" & wealth=="Total" 
replace category="Sex" if sex!="Total" & location=="Total" & wealth=="Total" 
replace category="Location" if sex=="Total" & location!="Total" & wealth=="Total" 
replace category="Wealth" if sex=="Total" & location=="Total" & wealth!="Total" 
replace category="Sex & Location" if sex!="Total" & location!="Total" & wealth=="Total"
replace category="Sex & Wealth" if sex!="Total" & location=="Total" & wealth!="Total"
replace category="Location & Wealth" if sex=="Total" & location!="Total" & wealth!="Total"
replace category="Sex & Location & Wealth" if sex!="Total" & location!="Total" & wealth!="Total"

for X in any sex location wealth: replace X="" if X=="Total"
	
count
codebook category

merge m:1 iso_code2 using "$aux_data\country_iso_codes_names.dta", keepusing(iso_code3 country)
drop if _merge==2
drop _merge

order iso* country year category sex location wealth comp* eduout*
compress
save "$dir\UIS_comp_eduout_02262020.dta", replace


use "$dir\UIS_comp_eduout_02262020.dta", clear
tab iso_code3

br if category=="Total" & year>=2017



use "$uis_data\UIS_completion_16Nov2018.dta", clear


foreach level in prim lowsec upsec {
	foreach indicator in comp eduout {
	erase "$dir\UIS_`indicator'_`level'_02262020.dta"
}
}


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

