*read auxiliary tables to fix values

* DATE
import delimited "$aux_data_path/mics_fix_date.csv" , encoding(UTF-8) clear
tempfile fixdate
save `fixdate'

* REGION
import delimited "$aux_data_path/mics_fix_region.csv" , encoding(UTF-8) clear
tempfile fixregion
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
import delimited "$aux_data_path/mics_changes_duration_stage.csv" , encoding(UTF-8) clear
tempfile fixlevel
save `fixlevel'

* EDUCATION LEVEL
import delimited "$aux_data_path/mics_recode_edulevel.csv" , encoding(UTF-8) clear
tempfile fixlevel
save `fixlevel'

* SEVERAL VARIABLES
* ed3
import delimited "$aux_data_path/mics_setcode.csv" , encoding(UTF-8) clear
preserve
keep ed3 ed3_replace
tempfile fixed3
save `fixed3'

* ed4a
restore
keep ed4a ed4a_replace
tempfile fixed4a
save `fixed4a'

* ed4b
restore
keep ed4b ed4b_replace
tempfile fixed4b
save `fixed4b'

* ed5
restore
keep ed5 ed5_replace
tempfile fixed5
save `fixed5'

* ed6a
restore
keep ed6a ed6a_replace
tempfile fixed6a
save `fixed6a'

* ed6b
restore
keep ed6b ed6b_replace
tempfile fixed6b
save `fixed6b'

* ed7
restore
keep ed7 ed7_replace
tempfile fixed7
save `fixed7'

* ed8a
restore
keep ed8a ed8a_replace
tempfile fixed8a
save `fixed8a'

* urban
restore
keep urban urban_replace
tempfile fixurban
save `fixurban'

* sex
restore
keep sex sex_replace
tempfile fixsex
save `fixsex'

use "$data_path/all/mics_reading.dta", clear
set more off

* remove special character in values and labels
replace_character

* rename variables
cap rename hl4 sex
cap rename hl6 age
cap rename windex5 wealth
cap rename hh6 urban
cap rename hh7 region

*fix several variables

*replace year of the survey by year_file if it is wrong
replace hh5y = year_file if  (hh5y - year_file) > 3

*merge with auxiliary data of calendar
merge m:1 hh5m using "`fixdate'"
replace hh5m = new_hh5m[_n] if _merge == 3
drop new_hh5m _merge
	
*merge with auxiliary data of regions names
merge m:1 country region using "`fixregion'"
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
merge m:1 country year usign "`fixduration'"
replace prim_dur  = new_prim_dur[_n] if _merge == 3 & new_prim_dur != .
replace lowsec_dur = new_lowsec_dur[_n] if _merge == 3 & new_lowsec_dur != .	
replace upsec_dur = new_upsec_dur[_n] if _merge == 3 & new_upsec_dur != .
replace prim_age0 = new_prim_age0[_n] if _merge == 3 & new_prim_age0 != .
drop new_prim_dur new_lowsec_dur new_upsec_dur new_prim_age0 _merge
	
*merge with auxiliary data of education levels
merge m:1 country year edu_level using "`fixlevel'"
replace edu_level  = new_edu_level[_n] if _merge == 3 

*merge with auxiliary data of ethnicity names
merge m:1 ethnicity using "`fixethnicity'"
replace ethnicity = new_ethnicity[_n] if _merge == 3
drop new_religion _merge

*merge with auxiliary data of ed3 values
merge m:1 ed3 using "`fixed3'"
replace ed3 = ed3_replace[_n] if _merge == 3
drop ed3_replace _merge

*merge with auxiliary data of ed4a values
merge m:1 ed4a using "`fixed4a'"
replace ed4a = ed4a_replace[_n] if _merge == 3
drop ed4a_replace _merge

*merge with auxiliary data of ed4b values
merge m:1 ed4b using "`fixed4b'"
replace ed4b = ed4b_replace[_n] if _merge == 3
drop ed4b_replace _merge

*merge with auxiliary data of ed5 values
merge m:1 ed5 using "`fixed5'"
replace ed5 = ed5_replace[_n] if _merge == 3
drop ed5_replace _merge

*merge with auxiliary data of ed6a values
merge m:1 ed6a using "`fixed6a'"
replace ed6a = ed6a_replace[_n] if _merge == 3
drop ed6a_replace _merge

*merge with auxiliary data of ed6b values
merge m:1 ed6b using "`fixed6b'"
replace ed6b = ed6b_replace[_n] if _merge == 3
drop ed6b_replace _merge

*merge with auxiliary data of ed7 values
merge m:1 ed7 using "`fixed7'"
replace ed7 = ed7_replace[_n] if _merge == 3
drop ed7_replace _merge

*merge with auxiliary data of ed8a values
merge m:1 ed8a using "`fixed8a'"
replace ed8a = ed8a_replace[_n] if _merge == 3
drop ed8a_replace _merge

*merge with auxiliary data of urban values
merge m:1 urban using "`fixurban'"
replace urban = urban_replace[_n] if _merge == 3
drop urban_replace _merge

*merge with auxiliary data of sex values
merge m:1 sex using "`fixsex'"
replace sex = sex_replace[_n] if _merge == 3
drop sex_replace _merge

compress
save "$raw_data/all/cleaning.dta", replace
