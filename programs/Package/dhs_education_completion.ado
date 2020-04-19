* dhs_education_completion: program to create education variables and categories 
* Version 1.0
* April 2020

program define dhs_education_completion
	args input_path table1_path table2_path uis_path output_path 

cd `input_path'


use "`input_path'.dta", clear
set more off

*Creating the variables for EDUOUT indicators
	for X in any prim_dur lowsec_dur upsec_dur: generate X_eduout = X 
	generate prim_age0_eduout = prim_age0
	

*FOR COMPLETION: Changes to match UIS calculations
*Changes to duration
import delimited "dhs_changes_duration_stage.csv" ,  varnames(1) encoding(UTF-8) clear
drop iso_code3 message
tempfile fixduration
save `fixduration'

*fix some uis duration
use `uis_path', clear
merge m:1 country_year using `fixduration', keep(match master) nogenerate
replace prim_dur_uis   = prim_dur_replace[_n] if _merge == 3 & prim_dur_replace!=.
replace lowsec_dur_uis = lowsec_dur_replace[_n] if _merge == 3 & lowsec_dur_replace !=.
replace upsec_dur_uis  = upsec_dur_replace[_n] if _merge == 3 & upsec_dur_replace !=.
replace prim_age_uis   = prim_age0_replace[_n] if _merge == 3 & prim_age_replace !=.
tempfile fixduration_uis
save `fixduration_uis'

merge m:1 iso_code3 year using "`fixduration_uis'", keep(match master)  nogenerate
drop lowsec_age_uis upsec_age_uis 


*Questions to UIS
*- Burkina Faso 2010 (DHS) should use age 6 or 7 as start age? The start age changes from 7 to 6 in 2010, the school year starts in October.
*- Egypt 2005 DHS: prim dur changes from 5 to 6 in 2005. Should we use 5 or 6 for year 2005 considering that school years starts in September.
*- Armenia 2010 DHS: All the interviews were in 2010, but UIS says it is year 2011 and has put duration and ages of that year. We put duration and age for 2010 and our results match UNICEF'S
*Education: hv107, hv108, hv109, hv121
compress 
save "`input_path'", replace

end

