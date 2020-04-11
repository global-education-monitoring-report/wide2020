
cd $aux_data_path

* read the master data
use "$data_path/all/mics_reading.dta", clear
set more off

* FIX SEVERAL VARIABLES

*replace year of the survey by year_file if it is wrong
replace hh5y = year_file if  (hh5y - year_file) > 3

*replace_many read auxiliary tables to fix values by replace
* data
replace_many "mics_fix_date.csv" hh5m hh5m_replace country year_file

* region
replace_many "mics_fix_region.csv" region region_replace country 

* religion	
replace_many "mics_fix_religion.csv" religion religion_replace

* ethnicity
replace_many "mics_fix_ethnicity.csv" ethnicity

* education duration
replace_many "mics_changes_duration_stage.csv" 

* urban
replace_many "mics_setcode.csv" urban urban_replace

* sex
replace_many "mics_setcode.csv" sex sex_replace


* FIX EDUCATION VARIABLES 
* ed3
replace_many "mics_setcode.csv" ed3 ed3_replace

* ed4a
replace_many "mics_setcode.csv" ed4a ed4a_replace

* ed4b
replace_many "mics_setcode.csv" ed4b ed4b_replace

* ed5
replace_many "mics_setcode.csv" ed5 ed5_replace

* ed6a
replace_many "mics_setcode.csv" ed6a ed6a_replace

* ed6b
replace_many "mics_setcode.csv" ed6b ed6b_replace

* ed7
replace_many "mics_setcode.csv" ed7 ed7_replace

* ed8a
replace_many "mics_setcode.csv" ed8a ed8a_replace


*generate code variables
for X in any ed4a ed6a ed8a: gen code_X = X_rn
tostring code_*, replace


* EDUCATION LEVEL
*ed4a

import delimited "mics_recode_edulevel.csv" ,  varnames(1) encoding(UTF-8) clear
tostring code_*, replace
preserve
tempfile fixleveled4a
save `fixleveled4a'

*ed6a
rename (code_ed4a code_ed4a_replace) (code_ed6a code_ed6a_replace)
tempfile fixleveled6a
save `fixleveled6a'

*ed8a
rename (code_ed6a code_ed6a_replace) (code_ed8a code_ed8a_replace)
tempfile fixleveled8a
save `fixleveled8a'
*merge with auxiliary data of education levels for ed4a, ed6a, ed8a

merge m:1 country year_file code_ed4a using "`fixleveled4a'"
replace code_ed4a  = code_ed4a_replace[_n] if _merge == 3 

merge m:1 country year code_ed6a using "`fixleveled6a'"
replace code_ed6a  = code_ed6a_replace[_n] if _merge == 3 

merge m:1 country year code_ed8a using "`fixleveled8a'"
replace code_ed8a  = code_ed8a_replace[_n] if _merge == 3 


*merge with information of duration of levels, school calendar, official age for primary, etc:
bys country_year: egen year=median(hh5y)
	rename country country_name_mics
	merge m:m country_name_mics using "$aux_data/country_iso_codes_names.dta" // to obtain the iso_code3
	drop if _merge==2
	drop country_name_mics country_name_WIDE iso_code2 iso_numeric country_name_dhs _merge
	merge m:1 iso_code3 year using "$aux_data/UIS/duration_age/UIS_duration_age_25072018.dta"
	drop if _m==2
	drop _merge
	drop lowsec_age_uis upsec_age_uis
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
	ren prim_age_uis prim_age0
	gen higher_dur=4 // provisional

	
*merge with auxiliary data of duration 
merge m:1 country year usign "`fixduration'"
replace prim_dur  = new_prim_dur[_n] if _merge == 3 & new_prim_dur != .
replace lowsec_dur = new_lowsec_dur[_n] if _merge == 3 & new_lowsec_dur != .	
replace upsec_dur = new_upsec_dur[_n] if _merge == 3 & new_upsec_dur != .
replace prim_age0 = new_prim_age0[_n] if _merge == 3 & new_prim_age0 != .
drop new_prim_dur new_lowsec_dur new_upsec_dur new_prim_age0 _merge


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur + lowsec_dur
	gen years_upsec  = prim_dur + lowsec_dur + upsec_dur
	gen years_higher = prim_dur + lowsec_dur + upsec_dur + higher_dur

compress
save "$raw_data/all/cleaning.dta", replace
