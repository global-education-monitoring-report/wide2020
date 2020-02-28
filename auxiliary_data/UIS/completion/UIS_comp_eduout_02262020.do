
*** LAPTOP
global folder "C:\Users\Rosa_V\Dropbox\WIDE\WIDE"
global aux_data "$folder\auxiliary_data"
global dir "$aux_data\UIS\completion"

*** PC
global folder "P:\WIDE"
global aux_data "$folder\auxiliary_data"
global dir "$aux_data\UIS\completion"


foreach level in prim lowsec upsec {
foreach indicator in comp eduout {

	insheet using "$dir\csv\UIS_`indicator'_`level'_02262020.csv", clear
	set more off
	keep edu_level sex wealth_quintile location ref_area time_period obs_value obs_status
	ren time_period year_uis
	ren ref_area iso_code2
	ren obs_value `indicator'_`level'_uis
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

/*
foreach level in prim lowsec upsec {
	foreach indicator in comp eduout {
	erase "$dir\UIS_`indicator'_`level'_02262020.dta"
}
}
*/

**************************************************

use "$dir\UIS_comp_eduout_02262020.dta", clear // it is like formerly named "UIS_completion_16Nov2018.dta"
codebook iso_code3 //155countries, previously 114 countries
gen year=year_uis
*I merge with the latest metadata that UIS has sent us
merge m:1 iso_code3 year using "$aux_data\UIS\sources\HH surveys metadata_UIS September release_2018.11.16.dta", keepusing(survey year uisreferenceyear surveyyear)
br if _m==2
drop if _m==2 // solo Bangladesh MICS 2009
drop _m




*Now I merge with the database I had before about "sources" to complete those that don't have sources right now.
br year*
merge m:1 iso_code3 year_uis using "$aux_data\UIS\sources\UIS_sources_02262020.dta"
br if _m==2 & year_uis>=2000 // these were released before, but now they were taken out
drop if _m==2
count if _m==1 & category=="Total"
br country year* survey source* if _m==1 & category=="Total"
br country year* survey source* if _m==3 & category=="Total"
drop _merge

*Drop Argentina 2011 because doesn't have "Total" only Urban
drop if country=="Argentina" & survey=="MICS" & year==2011

replace survey=source_uis if survey=="" & source_uis!=""
br if survey==source_uis // 416 out of 426 observations
br if survey!=source_uis & survey!="" & source_uis!="" 
br if survey!=source_uis & survey!="" & source_uis=="" 
*gen survey_uis=survey
drop iso_code2 country_source_uis nr_order source_uis_original
drop status*
drop year
compress
br if survey=="" // solve this cases later. Seems that are not NATIONAL surveys
save "$dir\UIS_comp_eduout_02262020_with_sources.dta", replace

