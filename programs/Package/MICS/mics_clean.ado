* mics_clean: program to clean the data (fixing and recoding variables)
* Version 2.0
* April 2020

program define mics_clean
	args data_path table_path 

	cd `table_path'

	*create auxiliary tempfiles to fix values later
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

	*isocodes
	import delimited "country_iso_codes_names.csv" ,  varnames(1) encoding(UTF-8) clear
	keep country_name_mics iso_code3
	drop if country_name_mics==""
	rename country_name_mics country
	tempfile isocode
	save `isocode'

	* education duration
	import delimited "mics_fix_duration.csv"  ,  varnames(1) encoding(UTF-8) clear
	drop iso_code3 message
	tempfile fixduration
	save `fixduration'

	*fix some uis duration
	use "`table_path'/UIS/duration_age/UIS_duration_age_25072018.dta", clear
	merge m:1 country year using `fixduration', keep(match master) 
	replace prim_dur_uis   = prim_dur_replace[_n]   if _merge == 3 & prim_dur_replace   !=.
	replace lowsec_dur_uis = lowsec_dur_replace[_n] if _merge == 3 & lowsec_dur_replace !=.
	replace upsec_dur_uis  = upsec_dur_replace[_n]  if _merge == 3 & upsec_dur_replace  !=.
	replace prim_age_uis   = prim_age_replace[_n]   if _merge == 3 & prim_age_replace   !=.
	drop _merge
	tempfile fixduration_uis
	save `fixduration_uis'

	* read the master data
	use "`data_path'/all/mics_read.dta", clear
	set more off

	* FIX SEVERAL VARIABLES

	* replace year of the survey by year_file if it is wrong
	replace hh5y = year_file if  (hh5y - year_file) > 3

	* replace_many read auxiliary tables to fix values by replace

	* date
	replace_many "mics_fix_date.csv" hh5m hh5m_replace country year_file

	* region
	replace_many "mics_fix_region.csv" region region_replace country 

	* religion	
	replace_many "mics_fix_religion.csv" religion religion_replace

	* ethnicity
	replace_many "mics_fix_ethnicity.csv" ethnicity ethnicity_replace

	* location
	replace_many "mics_setcode.csv" location location_replace

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


	* generate code variables
	for X in any ed4a ed6a ed8a: cap generate code_X = X_nr
	tostring code_*, replace


	* EDUCATION LEVEL

	* merge with auxiliary data of education levels for ed4a, ed6a, ed8a

	merge m:1 country year_file code_ed4a using "`fixleveled4a'", keep(match master)  
	replace code_ed4a  = code_ed4a_replace[_n] if _merge == 3 
	drop _merge

	merge m:1 country year code_ed6a using "`fixleveled6a'", keep(match master)  
	replace code_ed6a  = code_ed6a_replace[_n] if _merge == 3 
	drop _merge

	merge m:1 country year code_ed8a using "`fixleveled8a'", keep(match master)  
	replace code_ed8a  = code_ed8a_replace[_n] if _merge == 3 
	drop _merge

		
	* convert to numeric code_*
	destring code_*, replace
	for X in any ed4a ed6a ed8a: cap replace code_X = . if X >= 97
	
	* merge with iso code3 table
	merge m:1 country using "`isocode'", keep(match master) nogenerate

	* merge with information of duration of levels, school calendar, official age for primary, etc:
	bys country_year: egen year = median(hh5y)
	merge m:1 iso_code3 year using "`fixduration_uis'", keep(match master)  nogenerate
	drop lowsec_age_uis upsec_age_uis 

	for X in any prim_dur lowsec_dur upsec_dur: rename X_uis X
	rename prim_age_uis prim_age0
	generate higher_dur = 4 

	* With info of duration of primary and secondary I can compare official duration with the years of education completed..
	generate years_prim   = prim_dur
	generate years_lowsec = prim_dur + lowsec_dur
	generate years_upsec  = prim_dur + lowsec_dur + upsec_dur
	generate years_higher = prim_dur + lowsec_dur + upsec_dur + higher_dur

	* save data 	
	compress
	save "`data_path'/all/mics_clean.dta", replace

end
