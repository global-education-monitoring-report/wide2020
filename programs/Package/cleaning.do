use "$raw_data\all\cleaning.dta", clear
set more off


* REGIONS
*merge with auxiliary data of regions names
	merge m:1 iso_code3 region insheet "$aux_data\recoding\mics_fix_regions.csv" 
	drop if _merge == 2
	replace region = new_region[_n] if _merge == 3
	drop new_region _merge

	
* RELIGION	
*merge with auxiliary data of religion names
	merge m:1 religion insheet "$aux_data\recoding\mics_fix_religion.csv" 
	replace religion = new_religion[_n] if _merge == 3
	drop new_religion _merge

	
* ETHNICITY
*merge with auxiliary data of ethnicity names
	merge m:1 ethnicity insheet "$aux_data\recoding\mics_fix_ethnicity.csv" 
	replace ethnicity = new_ethnicity[_n] if _merge == 3
	drop new_religion _merge

	
* EDUCATION DURATION
*merge with auxiliary data of duration 
	merge m:1 iso_code3 year insheet "$aux_data\recoding\mics_changes_duration_stage.csv" 
	replace prim_dur  = new_prim_dur[_n] if _merge == 3 & new_prim_dur != .
	replace lowsec_dur = new_lowsec_dur[_n] if _merge == 3 & new_lowsec_dur != .	
	replace upsec_dur = new_upsec_dur[_n] if _merge == 3 & new_upsec_dur != .
	replace prim_age0 = new_prim_age0[_n] if _merge == 3 & new_prim_age0 != .
	drop new_prim_dur new_lowsec_dur new_upsec_dur new_prim_age0 _merge

	
* EDUCATION LEVEL
*merge with auxiliary data of education levels
	merge m:1 iso_code3 year edu_level insheet "$aux_data\recoding\mics_recode_edulevels.csv" 
	replace edu_level  = new_edu_level[_n] if _merge == 3 


compress
save "$raw_data\all\cleaning.dta", replace
