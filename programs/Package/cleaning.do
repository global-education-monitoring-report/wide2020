*read auxiliary tables to fix values

* DATE
import delimited "$aux_data_path/mics_fix_date.csv" , encoding(UTF-8) clear
tempfile fixdates
save `fixdates'

* REGION
import delimited "$aux_data_path/mics_fix_region.csv" , encoding(UTF-8) clear
tempfile fixregions
save `fixregion'

* RELIGION	
import delimited "$aux_data_path/mics_fix_religion.csv" , encoding(UTF-8) clear
tempfile fixreligion
save `fixreligion'

* ETHNICITY
import delimited "$aux_data_path/mics_fix_ethnicity.csv" , encoding(UTF-8) clear
tempfile fixethnicity
save `fixethnicity'

* EDUCATION DURATION
import delimited "$aux_data_path/mics_recode_edulevel.csv" , encoding(UTF-8) clear
tempfile fixlevel
save `fixlevel'

use "$data_path/all/mics_reading.dta", clear
set more off

* remove special character in values and labels
replace_character

*create new variables
*ssc install catenate
catenate country_year  = country year_file
catenate individual_id = country_year hh1 hh2 hl1
catenate hh_id         = country_year hh1 hh2 

*fix several variables

*replace year of the survey by year_file if it is wrong
hh5y = year_file if  (hh5y - year_file) > 3

*merge with auxiliary data of calendar
merge m:1 hh5m using "`fixdate'"
replace hh5m = new_hh5m[_n] if _merge == 3
drop new_hh5m _merge
	

*merge with auxiliary data of regions names
	merge m:1 iso_code3 region using "`fixregion'"
	drop if _merge == 2
	replace region = new_region[_n] if _merge == 3
	drop new_region _merge

*merge with auxiliary data of religion names
	merge m:1 religion using "`fixreligion'"
	replace religion = new_religion[_n] if _merge == 3
	drop new_religion _merge

	
*merge with auxiliary data of ethnicity names
	merge m:1 ethnicity using "`fixethnicity'"
	replace ethnicity = new_ethnicity[_n] if _merge == 3
	drop new_religion _merge

	
*merge with auxiliary data of duration 
	merge m:1 iso_code3 year usign "`fixduration'"
	replace prim_dur  = new_prim_dur[_n] if _merge == 3 & new_prim_dur != .
	replace lowsec_dur = new_lowsec_dur[_n] if _merge == 3 & new_lowsec_dur != .	
	replace upsec_dur = new_upsec_dur[_n] if _merge == 3 & new_upsec_dur != .
	replace prim_age0 = new_prim_age0[_n] if _merge == 3 & new_prim_age0 != .
	drop new_prim_dur new_lowsec_dur new_upsec_dur new_prim_age0 _merge

	
*merge with auxiliary data of education levels
	merge m:1 iso_code3 year edu_level using "`fixlevel'"
	replace edu_level  = new_edu_level[_n] if _merge == 3 


compress
save "$raw_data/all/cleaning.dta", replace
