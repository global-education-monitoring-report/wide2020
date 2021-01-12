* mics_clean: program to clean the data (fixing and recoding variables)
* Version 2.0
* April 2020

program define mics_clean
	args output_path

	*create auxiliary tempfiles from setcode table to fix values later
	local vars sex location ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a date duration ethnicity region religion code_ed4a code_ed6a code_ed8a
	findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	local dic `r(fn)'
	set more off	
	
	foreach X in `vars'{
		import excel "`dic'", sheet(`X') firstrow clear 
		capture destring sex_replace, replace
		capture tostring code_*, replace
		tempfile fix`X'
		save `fix`X''
	}
  
	*isocodes
	set more off
	findfile country_iso_codes_names.dta, path("`c(sysdir_personal)'/")
	use "`r(fn)'", clear
	keep country_name_mics iso_code3
	drop if country_name_mics == ""
	rename country_name_mics country
	tempfile isocode
	save `isocode'

	*fix some uis duration
	cd "`c(sysdir_personal)'/"
	*local uisfile : dir . files "UIS_duration_age_*.dta"
	*findfile `uisfile', path("`c(sysdir_personal)'/")
	*findfile UIS_duration_age_25072018.dta, path("`c(sysdir_personal)'/")
	*need to check!! assuming no change in the world in 2018 nor 2019
	findfile UIS_duration_age_01102020.dta, path("`c(sysdir_personal)'/")
	use "`r(fn)'", clear
	merge m:m iso_code3 year using `fixduration', keep(match master) 
	*Turning this off to see if this is a mistake
 	replace prim_dur_uis   = prim_dur_replace[_n]   if _merge == 3 & prim_dur_replace   !=.
 	replace lowsec_dur_uis = lowsec_dur_replace[_n] if _merge == 3 & lowsec_dur_replace !=.
 	replace upsec_dur_uis  = upsec_dur_replace[_n]  if _merge == 3 & upsec_dur_replace  !=.
 	replace prim_age_uis   = prim_age_replace[_n]   if _merge == 3 & prim_age_replace   !=.
	drop _merge message
	tempfile fixduration_uis
	save `fixduration_uis'

	* read the master data
	use "`output_path'/MICS/data/mics_read.dta", clear
	set more off

	* FIX SEVERAL VARIABLES
	replace hh5y = year_folder if  (hh5y - year_folder) > 3
	replace_many `fixdate' hh5m hh5m_replace country year_folder
	replace_many `fixregion' region region_replace country 
	replace_many `fixreligion' religion religion_replace
	replace_many `fixethnicity' ethnicity ethnicity_replace
	replace_many `fixlocation' location location_replace
	replace_many `fixsex' sex sex_replace
    * labelling
    label define sex 0 "Female" 1 "Male"
	label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
	for Z in any sex wealth: label values Z Z
	*for Z in any hl4 windex5: label values Z Z


	foreach var of varlist ethnicity {
		replace `var' = subinstr(`var', " et ", " & ",.) 
		replace `var' = subinstr(`var', " and ", " & ",.)
		replace `var' = subinstr(`var', " ou ", "/",.)
		replace `var' = subinstr(`var', " o ", "/",.)
	}
	replace region = subinstr(region, " ou ", "/",.)
	
	local vars location sex wealth region ethnicity religion
	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = proper(`var')
	}
	
	foreach var in region religion ethnicity {
		replace `var' = subinstr(`var', "'I", "'i",.) 
		replace `var' = subinstr(`var', "-E", "-e",.) 
		replace `var' = subinstr(`var', "'S", "'s",.) 
		replace `var' = subinstr(`var', "'T", "'t",.) 
		replace `var' = subinstr(`var', "'Z", "'z",.) 
	}
	*replace region = "Region CH" if region == "Region Ch"
	*replace region = "Region NE" if region == "Region Ne"
	*replace region = "Region SE" if region == "Region Se"
	*replace region = "DF Edo. de Mexico" if region == "Df Edo Mexico"
	*replace region = "FCT (Abuja)" if region == "Fct (Abuja)"
	*replace region = "Mid WesternTerai" if region == "Mid Westernterai"
	*replace region = "Far WesternTerai" if region == "Far Westernterai"

	* FIX EDUCATION VARIABLES 
	replace_many `fixed3' ed3 ed3_replace
	replace_many `fixed4a' ed4a ed4a_replace
	replace_many `fixed4b' ed4b ed4b_replace
	replace_many `fixed5' ed5 ed5_replace
	replace_many `fixed6a' ed6a ed6a_replace
	replace_many `fixed6b' ed6b ed6b_replace
	replace_many `fixed7' ed7 ed7_replace
	replace_many `fixed8a' ed8a ed8a_replace

	* generate code variables
	for X in any ed4a ed6a ed8a: capture generate code_X = X_nr
	
	capture replace code_ed6a = 70 if ed6a_nr == 1 & country_year == "Palestine_2010"
	capture replace code_ed6a = 22 if ed6a_nr == 2 & country_year == "Palestine_2010"
	
	* EDUCATION LEVEL
	* merge with auxiliary data of education levels for ed4a, ed6a, ed8a
	tostring code_*, replace
	replace_many `fixcode_ed4a' code_ed4a code_ed4a_replace country_year
	replace_many `fixcode_ed6a' code_ed6a code_ed6a_replace country_year
	replace_many `fixcode_ed8a' code_ed8a code_ed8a_replace country_year
	destring code_*, replace
		
	replace code_ed4a = 40 if ed4b_nr == 43 & country_year == "Nigeria_2011"  
	replace code_ed4a = 40 if ed4b_nr == 36 & country_year == "Nigeria_2016"  
		
	for X in any 4 6 8: capture replace code_edXa = 21 if edXa_nr == 4 & inlist(edXb_nr, 0, 1, 2, 3) & country_year == "Uruguay_2012"
	for X in any 4 6 8: capture replace code_edXa = 22 if edXa_nr == 4 & inlist(edXb_nr, 4, 5, 6) & country_year == "Uruguay_2012"
	
	for X in any 4 6 8: capture replace code_edXa = 22 if edXa_nr == 4 & inlist(edXb_nr, 0, 1, 2, 3) & country_year == "Iraq_2011"
	for X in any 4 6 8: capture replace code_edXa = 33 if edXa_nr == 4 & inlist(edXb_nr, 4, 5) & country_year == "Iraq_2011" 

	for X in any 4 6 8: capture replace code_edXa = 22 if inlist(edXa_nr, 4, 5) & inlist(edXb_nr, 0, 1, 2) & country_year == "Kyrgyzstan_2014"
	for X in any 4 6 8: capture replace code_edXa = 33 if inlist(edXa_nr, 4, 5) & inlist(edXb_nr, 3, 4) & country_year == "Kyrgyzstan_2014"	

	for X in any ed4a ed6a ed8a: replace code_X = 97 if X == "inconsistent"
	for X in any ed4a ed6a ed8a: replace code_X = 98 if X == "don't know"
	for X in any ed4a ed6a ed8a: replace code_X = 99 if inlist(X, "missing", "doesn't answer", "missing/dk")
    *for X in any ed4a ed6a ed8a: capture replace code_X = . if X >= 97 
	
	* merge with iso code3 table
	merge m:1 country using "`isocode'", keep(match master) nogenerate
	
	* merge with information of duration of levels, school calendar, official age for primary, etc:
	bys country_year: egen year = median(hh5y)
	
	*The durations for 2018 are not available, so I create a "fake year"
	rename year year_original
	generate year = year_original
 	replace year = 2017 if year_original >= 2018
 	merge m:1 iso_code3 year using "`fixduration_uis'", keep(match master)  nogenerate
 	drop year
 	rename year_original year
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
	save "`output_path'/MICS/data/mics_clean.dta", replace

end
