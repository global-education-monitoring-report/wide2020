* mics_standardize: program to calculate a standard dataset ready to be processed further in R
* Version 3.0
* May 2021
* Latest updates:
*   added full_literacy 
*	added attend_higher_5 
*	added eduout_preprim
* May 2022 update: disability added as a new category 


*February 2022 update: updated variable code_ed6a into level_attending into the microdata



program define mics_standardize_standalone
	syntax, data_path(string) output_path(string) country_code(string) country_year(string) 

	*****************************READ OR DATASET INTAKE**********************************
	
	* create folder
	cd "`output_path'"
	capture mkdir "`output_path'/MICS"
	cd "`output_path'/MICS"
	capture mkdir "`output_path'/MICS/data"
	cd "`output_path'/MICS/data"
	capture mkdir "`output_path'/MICS/data/temporal"
	
	findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	import excel "`r(fn)'", sheet(dictionary) firstrow clear 
	* mics variables to keep first
	levelsof original_name, local(micsvars) clean
	* mics variables to decode
	levelsof standard_name if encode == "decode", local(micsvars_decode) clean
	* mics variables to keep last
	levelsof standard_name if keep == 1, local(micsvars_keep) clean 
	* mics numeric variables
	levelsof standard_name if numeric == 1 & keep == 1, local(micsvars_keepnum) clean
	* mics string variables
	levelsof standard_name if numeric == 0 & keep == 1, local(micsvars_keepstr) clean
		
	*isocodes-country names with and without spaces
	set more off
	findfile country_iso_codes_names.dta, path("`c(sysdir_personal)'/")
	use "`r(fn)'", clear
	keep country country_name_mics iso_code3
	drop if country_name_mics == ""
	tempfile isocode
	save `isocode'
	
		*read the file: now it depends on the country-year input 
		*Old directory system
		*use "`data_path'\\MICS\\`country_name'\\`country_year'\hl.dta", clear
		*New directory system
		use "`data_path'\\`country_code'_`country_year'_MICS\hl.dta", clear
		set more off 
					
		*lowercase all variables
		capture rename *, lower
		capture rename *_* **		
		
		*select common variables between the dataset and the mics dictionary (1st column)
		ds
		local datavars `r(varlist)'
		local common : list datavars & micsvars
		keep `common' 
		ds
		
		
		*generate variables with file name
		* merge with iso code3 table, BUT CAPITALIZE OR WON'T MATCH
		gen iso_code3=upper("`country_code'")
		merge m:1 iso_code3 using "`isocode'", keep(match) nogenerate
		rename country complete_country_name
		rename country_name_mics country
		generate year_folder = `country_year'
			
		***IMPORTANT!!!! RENAMING OF VARIABLES FOR MICS 6 SURVEYS only
 		if (year_folder >= 2017) {
		for X in any ed1 ed2a ed3 ed4 ed5a ed5b ed6 ed7 ed8 ed9 ed10a ed10b ed11 ed12 ed13a ed13b ed13c ed13d ed13x ed13z ed13nr ed14 ed15 ed16a ed16b: capture rename X old_X
 		gen ed3 = old_ed4
			capture confirm variable ed4a
    if !_rc {
    }
    else {
 		gen ed4a = old_ed5a
    }
		gen ed4b = old_ed5b
 		gen ed5 = old_ed9
		
		capture confirm variable ed6a
    if !_rc {
	   replace ed6a = old_ed10a if country=="Mongolia" & year_folder==2018
    }
    else {
 		gen ed6a = old_ed10a
    }
 		*gen ed6b = old_ed10b
		gen ed7 = old_ed15
		gen ed8a = old_ed16a
 		gen ed8b = old_ed16b
 		capture gen ed3_check=old_ed8
 		gen ed_completed=old_ed6
		*sdecode ed_completed, replace
		}
		

		*fix names
		if (country == "Palestine" & year_folder == 2010) {
			capture rename ed4a ed4b 
			capture rename ed4 ed4a  
			capture rename hlweight hhweight
		}
		if country == "Jamaica" {
			capture rename hh6b hh7
		}
		if (country == "Mali" & year_folder == 2015) {
			capture drop ed6a
			capture rename ed6n ed6a
			capture rename ed6c ed6b
		}
		if (country == "Mali" & year_folder == 2009) {
			capture drop ethnicity
			capture rename hc1c ethnicity 
		}
		if (country == "Panama" & year_folder == 2013) {
			 capture drop religion
			 capture rename hc1a religion
		}
		if (country == "TrinidadandTobago" & year_folder == 2011) {
			 capture drop religion
			 capture rename hl15 religion
		}
		if (country == "Uruguay" & year_folder == 2012) {
			drop windex5 region hh7
			rename windex55 windex5
		}
		if (country == "SaintLucia" & year_folder == 2012) {
			capture drop windex5
			capture rename windex51 windex5
		}
		if (country == "Palestine" & year_folder == 2014) {
			for X in any 4 6 8: capture drop edXa edXb
			for X in any 4 6 8: capture rename edXap edXa 
			for X in any 4 6 8: capture rename edXbp edXb 
			for X in any 4 6 8: capture drop edXap edXbp
		}
		
		
		for X in any hh7a hh7r: capture rename X region 
		for X in any region: capture rename X hh7
		capture drop region
		for X in any ethnie ethnicidad: capture rename X ethnicity
		
		* create numeric variables 
		for X in any ed4a ed4b ed5 ed6a ed6b ed8a ed8b schage: capture generate X_nr = X
		for X in any ed4a_nr ed6a_nr ed8a_nr: capture recode X (8 = 98) (9 = 99)
		
		* drop schage missing values 
		capture replace schage_nr = . if schage_nr >= 150
		capture drop schage
		capture rename schage_nr schage
			
		
		*decode and change strings values to lower case
		ds
		local datavars `r(varlist)'
		local common : list datavars & micsvars
		local common_decode : list common & micsvars_decode
		
			
		* remove special character and space in string variables
		foreach var of varlist `common_decode'{ 
			capture tostring `var', replace
			capture sdecode  `var', replace
			capture replace  `var' = "missing" if `var' == ""
			capture replace  `var' = lower(`var')
			capture replace_character `var'
			capture replace  `var' = stritrim(`var')
			capture replace  `var' = strltrim(`var')
			capture replace  `var' = strrtrim(`var')
		 }

		 if (country == "DominicanRepublic" & year_folder == 2014) {
			 generate religion = ethnicity
			 replace ethnicity = "" 
		}
				
		*create ids variables
		catenate country_year  = country year_folder, p("_")
		catenate hh_id 	       = country_year hh1 hh2, p(no) 
		catenate individual_id = country_year hh1 hh2 hl1, p(no)
		
		
		*create variables doesnt exist 
		for X in any `micsvars_keepnum': capture generate X = .
		for X in any `micsvars_keepstr': capture generate X = ""
		*order `micsvars_keep'
		
		

		if (country == "Cuba" | country == "Nepal") {
			for X in any ed4a ed4b ed5 ed6a ed6b ed8a ed8b schage: capture generate X_nr = X
		}
		
		*rename some variables 
		findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
		*Renamefrom is failing because of partofcountry
		capture renamefrom using "`r(fn)'", filetype(excel) if(!missing(rename)) raw(standard_name) clean(rename) label(varlab_en) keepx
		if (country != "Somalia") {
		gen sex = hl4
		gen age = hl6
		gen location = hh6 
		gen region = hh7
		gen wealth = windex5
		}
		
		compress 
		
	
	save "`output_path'/MICS/data/mics_read.dta", replace
	
	
	*****************************CLEAN  OR DATA HOMOGENIZATION**********************************

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
  
	

	*fix some uis duration
	cd "`c(sysdir_personal)'/"
	*local uisfile : dir . files "UIS_duration_age_*.dta"
	*findfile `uisfile', path("`c(sysdir_personal)'/")
	*findfile UIS_duration_age_25072018.dta, path("`c(sysdir_personal)'/")
	*need to check!! assuming no change in the world in 2018 nor 2019
	findfile UIS_duration_age_30082021.dta, path("`c(sysdir_personal)'/")
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
		
	capture replace code_ed4a = 40 if ed4b_nr == 43 & country_year == "Nigeria_2011"  
	capture replace code_ed4a = 40 if ed4b_nr == 36 & country_year == "Nigeria_2016"  
		
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
	*merge m:1 country using "`isocode'", keep(match master) nogenerate
	
	* merge with information of duration of levels, school calendar, official age for primary, etc:
	egen year = median(hh5y)
	
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

	
	*****************************STANDARDIZE  OR INDICATOR CALCULATION**********************************


	* COMPUTE THE YEARS OF EDUCATION BY COUNTRY 

	* read auxiliary table to calculate eduyears 
	findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	import excel "`r(fn)'", sheet(group_eduyears) firstrow clear 
	tempfile group
	save `group'
	
	* read the main data
	use "`output_path'/MICS/data/mics_clean.dta", clear
	set more off
	merge m:1 country_year using `group', keep(match master) nogenerate
	

	* create the variable
	generate eduyears = .
	rename ed4b ed4b_label
	rename ed4b_nr ed4b
	
	replace ed4b = 0 if code_ed4a == 0 & country_year == "Suriname_2018"
	replace ed4b = ed4b-2 if code_ed4a == 1 & country_year == "Suriname_2018"

	* Consider the ed4b == 94 as missing
	*replace ed4b = 99 if ed4b == 94
	
	* replace eduyears according to which group it belongs
	
	
	replace eduyears = ed4b if group == 0
	
	replace eduyears = ed4b if group == 1
	replace eduyears = . if code_ed4 == 50 & group == 1
		
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 2
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 27 & group == 2
	replace eduyears = ed4b - 17 if ed4b >= 30 & ed4b <= 35 & group == 2
		
	replace eduyears = ed4b if ed4b >= 0 & ed4b <= 20 & group == 3
	replace eduyears = ed4b - 7 if ed4b >= 21 & ed4b <= 23 & group == 3
	replace eduyears = ed4b - 18 if ed4b == 32 & group == 3
	replace eduyears = ed4b - 27 if ed4b >= 41 & ed4b <= 43 & group == 3
	replace eduyears = ed4b - 37 if ed4b >= 52 & ed4b <= 55 & group == 3
	
	replace eduyears = 0 if ed4b >= 1  & ed4b <= 3  & group == 4
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 4
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 26 & group == 4
	replace eduyears = years_upsec if inlist(ed4b, 30, 40) & group == 4
	replace eduyears = years_upsec + 2 if inlist(ed4b, 31, 41) & group == 4
	replace eduyears = years_upsec + 3 if inlist(ed4b, 32, 33) & group == 4
	replace eduyears = years_higher if ed4b == 42 & group == 4
	replace eduyears = years_higher + 2 if ed4b == 43 & group == 4
	
	replace eduyears = 0 if ed4b >= 1  & ed4b <= 3 & group == 5
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 5
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 26 & group == 5
	replace eduyears = years_upsec if ed4b == 30 & group == 5
	replace eduyears = years_upsec + 2 if inlist(ed4b, 31, 34) & group == 5
	replace eduyears = years_upsec + 3 if inlist(ed4b, 32, 33) & group == 5
	replace eduyears = years_higher if ed4b == 35 & group == 5
	replace eduyears = years_higher + 2 if ed4b == 36 & group == 5
	
	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 15 & group == 6
	replace eduyears = ed4b - 15 if ed4b >= 21 & ed4b <= 24 & group == 6
	replace eduyears = ed4b - 21 if ed4b >= 31 & ed4b <= 33 & group == 6
	replace eduyears = ed4b - 28 if ed4b >= 41 & ed4b <= 43 & group == 6
	replace eduyears = ed4b - 38 if ed4b >= 51 & ed4b <= 57 & group == 6
	
	replace code_ed4a = 1 if ed4b <= years_prim & group == 7
	replace code_ed4a = 2 if ed4b > years_prim  & ed4b <= years_upsec & group == 7
	replace code_ed4a = 3 if ed4b > years_upsec & ed4b <. & ed4b < 97 & group == 7
	replace code_ed4a = 0 if (ed3 == "currently attending kindergarten" | ed3 == "never attended school") & group == 7
	replace eduyears = ed4b if group == 7
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 21, 22) & group == 8
	replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 & group == 8
	
	replace code_ed4a = 50 if (ed4b == 10 | ed4b == 20) & group == 9
	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 17 & group == 9
	replace eduyears = ed4b - 13 if ed4b >= 21 & ed4b <= 26 & group == 9
	replace eduyears = years_upsec + 0.5*higher_dur if ed4b_label == "attended/currently attending higher education" & group == 9
	replace eduyears = years_higher if ed4b_label == "completed higher education" & group == 9
	*replace eduyears=. if code_ed4a==50  
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21, 22, 23) & group == 10
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 10
	replace eduyears = ed4b + years_higher if code_ed4a == 40 & group == 10
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & country_year == "Kazakhstan_2015" & group == 10
	
	capture replace eduyears = ed4b if inlist(ed4a_nr, 0, 1, 2, 3) & group == 11
	capture replace eduyears = ed4b + years_lowsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 0, 1, 2) & group == 11
	capture replace eduyears = ed4b + years_upsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 3, 4) & group == 11
	capture replace eduyears = ed4b + years_upsec if ed4a_nr == 6 & group == 11
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21, 22) & group == 12
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & group == 12
	replace eduyears = ed4b + years_upsec if code_ed4a == 3 & group == 12 
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21) & group == 13
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 13
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 13
	replace eduyears = ed4b + years_higher if code_ed4a == 40 & group == 13
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 60, 70) & group == 14
	replace eduyears = ed4b + years_prim if inlist(code_ed4a, 2, 21, 23) & group == 14
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 14
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 14
	replace eduyears = ed4b + years_higher if code_ed4a == 40  & group == 14
	replace eduyears = ed4b + years_lowsec - 3 if (code_ed4a == 22 & country_year == "Thailand_2012")
	replace eduyears = years_prim if (ed4b_label == "primary school of nfeep" & country_year == "Mongolia_2013")
	replace eduyears = years_lowsec if (ed4b_label == "basic school of nfeep" & country_year == "Mongolia_2013")
	replace eduyears = years_prim if (ed4b_label == "high school of nfeep" & country_year == "Mongolia_2013")
	replace eduyears = years_higher + 2 if code_ed4a == 40 & country_year == "Sudan_2014"
	
	replace eduyears = ed4b if (ed4b >= 0 & ed4b <= 10) & group == 15
	replace eduyears = 10 if ed4b_label == "slc" & group == 15
	replace eduyears = years_upsec if ed4b_label == "plus 2 level" & group == 15
	replace eduyears = years_higher if ed4b_label == "bachelor" & group == 15
	replace eduyears = years_higher + 2	 if ed4b_label == "masters" & group == 15
	replace eduyears = 0 if ed4b_label == "preschool" & group == 15

	replace eduyears = ed4b if code_ed4a == 1 & group == 16
	replace eduyears = ed4b + years_prim if code_ed4a == 21 & group == 16
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 16
	replace eduyears = ed4b + years_upsec if code_ed4a == 3 & group == 16
	
	replace eduyears = ed4b if code_ed4a == 1 & group == 17 
	replace eduyears = ed4b + 8 if code_ed4a == 2 & group == 17
	replace eduyears = ed4b + years_lowsec if code_ed4a == 3 & group == 17
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 21, 22) & group == 18
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & group == 18
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 33) & group == 18
	
	replace eduyears = years_higher + 2 if code_ed4a == 40 & group == 19
	
	replace eduyears = ed4b if code_ed4a == 70 & group == 20
	replace eduyears = ed4b + years_prim if code_ed4a == 21 & group == 20
	replace eduyears = ed4b + years_lowsec if code_ed4a == 22 & group == 20
	replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 & group == 20
	replace eduyears = years_upsec + 0.2*higher_dur if code_ed4a == 32 & group == 20
	replace eduyears = years_higher + 2 if code_ed4a == 40 & group == 20
	
	replace code_ed4a = 3 if inlist(ed4b_label, "bachelor", "diploma") & group == 21
	replace code_ed4a = 40 if inlist(ed4b_label, "master", "> master") & group == 21
	replace code_ed4a = 0 if  ed4b_label == "pre primary" & group == 21
	replace eduyears = ed4b + 1 if group == 21
	replace eduyears = 0 if ed4b_label == "no grade" & group == 21
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 60, 70) & group == 22	
	replace eduyears = ed4b + years_prim if inlist(code_ed4a, 2, 21, 22) & group == 22	
	replace eduyears = ed4b + years_lowsec if (code_ed4a == 24) & group == 22	  
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 22	
	replace eduyears = ed4b + years_higher if (code_ed4a == 40) & group == 22	
	
		
	/*
	0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 98 "don't know" 99 "missing/doesn't answer" ///
	21 "lower secondary" 23 "voc/tech/prof as lowsec" ///
	22 "upper secondary" 24 "voc/tech/prof as upsec" ///
	32 "post-secondary or superior no university" 33 "voc/tech/prof as higher" ///
	40 "post-graduate (master, PhD, etc)" ///
	**IM INVENTING THIS 41 "Master" 42 "Phd or doctoral degree"
	50 "special/literacy program" 51 "adult education" ///
	60 "general school (ex. Mongolia, Turkmenistan)" ///
	70 "primary+lowsec (ex. Sudan & South Sudan)" ///
	80 "not formal/not regular/not standard" ///
	*/
	
	*NEW STUFF
	replace eduyears=ed4b if inlist(code_ed4a, 1, 60, 70)  
	replace eduyears=ed4b+years_prim if inlist(code_ed4a, 2, 21, 23)
	replace eduyears=ed4b+years_lowsec if inlist(code_ed4a, 22, 24)
	replace eduyears=ed4b+years_upsec if inlist(code_ed4a, 3, 32, 33) 
	
	*NEW STUFF PARTICULAR FOR SOME COUNTRIES
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Montenegro_2018"
	replace eduyears=ed4b if(code_ed4a==1|code_ed4a==21|code_ed4a==22|code_ed4a==3) & country_year=="Bangladesh_2019"
	replace eduyears=ed4b+years_lowsec-3 if code_ed4a==22 & country_year=="Kiribati_2018"
	replace eduyears=ed4b if(code_ed4a==1|code_ed4a==21|code_ed4a==22) & country_year=="Qatar_2012"
	replace eduyears=ed4b+years_prim-5 if ed4a=="2" & country_year=="TFYRMacedonia_2018"
	
	replace eduyears=ed4b if ed4a=="2" & country_year=="Guyana_2019"
	replace eduyears=ed4b if ed4a=="3" & country_year=="Guyana_2019"

	replace eduyears=ed4b+years_lowsec-2 if ed4a=="3" & country_year=="Malawi_2019"
	replace eduyears=ed4b if ed4a=="2" & country_year=="Samoa_2019"
	replace eduyears=ed4b if ed4a=="2" & country_year=="Tuvalu_2019"
	replace eduyears=ed4b if ed4a=="2" & country_year=="Belarus_2019"
	replace eduyears=ed4b if ed4a=="3" & country_year=="Belarus_2019"
	replace eduyears=ed4b if ed4a=="3" & country_year=="Nepal_2019"
	replace eduyears=ed4b if ed4a=="4" & country_year=="Nepal_2019"
	replace eduyears=ed4b if ed4a=="5" & country_year=="Nepal_2019"
	
// 	replace eduyears=ed4b+years_prim if code_ed4a==2 &  inlist(ed4b, 1, 2) & country_year=="Lesotho_2018" // incomplete lowsec
// 	replace eduyears=ed4b+years_prim if code_ed4a==2 &  inlist(ed4b, 3, 4) & country_year=="Lesotho_2018" // complete lowsec , incomplete upsec
// 	replace eduyears=ed4b+years_prim if code_ed4a==2 & inlist(ed4b, 5) & country_year=="Lesotho_2018" // complete upsec
	replace eduyears=ed6b2+ed4b if code_ed4a==23 & ed6b1==1 & country_year=="Lesotho_2018" // recalculate for vocational (variable ed6b2 for previous ed + grades of vocational edu ed5b/ed4b here )

	replace eduyears=16 if code_ed4a==3 & ed4b==13 & country_year=="Qatar_2012" // University
	replace eduyears=18 if code_ed4a==3 & ed4b==14 & country_year=="Qatar_2012" // Masters
	replace eduyears=16 if code_ed4a==3 & ed4b==15 & country_year=="Qatar_2012" // PHD
	replace eduyears=16 if code_ed4a==3 & ed4b==16 & country_year=="Qatar_2012" // Other
	
//  	replace eduyears=13 if code_ed4a==3 & ed4b==13 & old_ed6==1 & country_year=="Bangladesh_2019"
//  	replace eduyears=14 if code_ed4a==3 & ed4b==14 & old_ed6==1 & country_year=="Bangladesh_2019"
//  	replace eduyears=15 if code_ed4a==3 & ed4b==15 & old_ed6==1 & country_year=="Bangladesh_2019"
//  	replace eduyears=16 if code_ed4a==3 & ed4b==16 & old_ed6==1 & country_year=="Bangladesh_2019"
//  	replace eduyears=18 if code_ed4a==3 & ed4b==17 & old_ed6==1 & country_year=="Bangladesh_2019"
//  	replace eduyears=18 if code_ed4a==3 & ed4b==18 & old_ed6==1 & country_year=="Bangladesh_2019"
//  	replace eduyears=12 if code_ed4a==3 & ed4b==13 & old_ed6==2 & country_year=="Bangladesh_2019"
//  	replace eduyears=13 if code_ed4a==3 & ed4b==14 & old_ed6==2 & country_year=="Bangladesh_2019"
//  	replace eduyears=14 if code_ed4a==3 & ed4b==15 & old_ed6==2 & country_year=="Bangladesh_2019"
//  	replace eduyears=15 if code_ed4a==3 & ed4b==16 & old_ed6==2 & country_year=="Bangladesh_2019"
//  	replace eduyears=17 if code_ed4a==3 & ed4b==17 & old_ed6==2 & country_year=="Bangladesh_2019"
//  	replace eduyears=17 if code_ed4a==3 & ed4b==18 & old_ed6==2 & country_year=="Bangladesh_2019"

	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_Comms_2019"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_Comms_2019"

	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_2019"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_2019"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Montenegro_RS_2018"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Macedonia_RS_2018"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_Comms_2013"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_Comms_2013"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_2013"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_2013"
	
	replace eduyears=ed4b+years_lowsec-3 if code_ed4a==22 & country_year=="Thailand_2019" // *stairs* issue upsec
	replace eduyears=ed4b+years_upsec+6 if code_ed4a==41 & country_year=="Thailand_2019" // Master assuming 6 years of bachelor
	replace eduyears=ed4b+years_upsec+6+2 if code_ed4a==42 & country_year=="Thailand_2019" // Doctoral degree assuming 2 years of master

	* Recode for all country_years
	replace eduyears = 97 if code_ed4a == 97 | ed4b_label == "inconsistent" 
	replace eduyears = 98 if code_ed4a == 98 | ed4b_label == "don't know"
	replace eduyears = 99 if code_ed4a == 99 | inlist(ed4b_label, "missing", "doesn't answer", "missing/dk")
	replace eduyears = 0 if code_ed4a == 0
	replace eduyears = . if eduyears >= 99
	capture replace eduyears = eduyears - 1 if ed_completed == "no" & (eduyears <= 97)
	capture replace eduyears = eduyears - 1 if ed_completed == 2 & (eduyears <= 97)

	replace eduyears = 30 if eduyears >= 30 & eduyears < 90
	
			
	* COMPUTE EDUCATION COMPLETION (the level reached in primary, secondary, etc.)
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur - 1

	* VERSION C to fix eduyears
	* Recoding those with zero to a lower level of education 
	* Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!
	*replace eduyears = years_prim if eduyears == 0 & inlist(code_ed4a, 2, 21, 23)
	*replace eduyears = years_lowsec if eduyears == 0 & inlist(code_ed4a, 22, 24)
	*replace eduyears = years_upsec if eduyears == 0 & inlist(code_ed4a, 3, 32, 33)
	*replace eduyears = years_higher if eduyears == 0 & code_ed4a == 40
	
		*******COMPLETION_LVL base**********

 	*Completion each level without Age limits 
 	foreach Z in prim lowsec upsec higher {
 		generate comp_`Z' = 0
 		replace comp_`Z' = 1 if eduyears >= years_`Z'
		replace comp_`Z' = . if inlist(eduyears, 97, 98, 99, .)
		replace comp_`Z' = 0 if ed3 == "no"
 		replace comp_`Z' = 0 if code_ed4a == 0
 	}
	
		*******TERTIARY COMPLETION RATE**********
	*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		*replace comp_higher_`X'yrs = 1	if eduyears >= years_upsec + `X'
		replace comp_higher_`X'yrs = . if inlist(eduyears, ., 97, 98, 99)
		replace comp_higher_`X'yrs = 0 if ed3 == "no"  
		replace comp_higher_`X'yrs = 0 if code_ed4a == 0 
	}
	replace comp_higher_2yrs = 1 if eduyears >= years_upsec + 2
	replace comp_higher_4yrs = 1 if eduyears >= years_upsec + 4
		

	* Recoding ED5: "Attended school during current school year?"
	capture generate attend = 1 if ed5 == "yes" | ed5_nr == 1
	capture replace attend  = 0 if ed5 == "no" | ed5_nr == 0
	
	* save data
	compress
	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
	
	* ADJUST SCHOOL YEAR
	use "`output_path'/MICS/data/mics_standardize.dta", clear
	set more off
	
	* current school year that ED question in MICS refers to
	*findfile current_school_year_MICS.dta, path("`c(sysdir_personal)'/")
	*merge m:1 country_year using "`r(fn)'", keep(master match) nogenerate 
	gen current_school_year=""
	replace current_school_year="2010" if country=="Somalia"
	replace current_school_year="2018" if country=="CostaRica"
	replace current_school_year="2018" if country=="TFYRMacedonia"
	replace current_school_year="2017" if country=="DRCongo"
	replace current_school_year="2018" if country=="Montenegro"
	replace current_school_year="2019" if country=="Bangladesh"
	replace current_school_year="2017" if country=="Ghana"
	replace current_school_year="2016" if country=="Togo"
	replace current_school_year="2018" if country=="Turkmenistan"
	replace current_school_year="2011" if country=="Qatar"
	replace current_school_year="2018" if country=="Kiribati"
	replace current_school_year="2018" if country=="Guinea-Bissau"

	replace current_school_year="2019" if country=="Kosovo_Comms"
	replace current_school_year="2019" if country=="Kosovo"
	replace current_school_year="2018" if country=="Montenegro_RS"
	replace current_school_year="2018" if country=="Macedonia_RS"
	replace current_school_year="2019" if country=="Serbia_RS"

	* replace current 
	replace current = "" if current == "doesn't have the variable"
	destring current, replace

	* Create date
	* Inteview date:  hh5y=year; hh5m=month; hh5d=day  
	* Median of month
	capture drop month* 
	generate year_c = hh5y	
	findfile month_start.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 year_c using "`r(fn)'", keep(master match) nogenerate 
	drop max_month min_month diff year_c

	* replace missing in school year by the interview year
	replace current_school_year = hh5y if current_school_year == .
	catenate s_school    = month_start current_school_year, p("/")
	catenate s_interview = hh5m hh5y, p("/") 

	* create official month of start
	generate date_school    = date(s_school, "MY",2000) 
	* create school year of reference
	generate date_interview = date(s_interview, "MY",2000)
		
	* fix the negative differences
	replace current_school_year = current_school_year - 1 if (date_interview - date_school) < 0  
	*replace current_school_year=current_school_year+1 if (date2-date1>=12) 
	drop s_* date_*
	
	* Adjustment VERSION 1: Difference in number of days 
	*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
	*- 			Interview		: Month as presented in the survey data
	generate month_start_norm = month_start
	*Taking into account the days	
	generate one = string(1)
	for X in any norm max min: catenate s_school1_X = one month_start_X current_school_year,  p("/")
	catenate s_interview1 = hh5d hh5m hh5y,  p("/")
	
	for X in any norm max min: generate date_school1_X = date(s_school1_X, "DMY",2000) 
	generate date_interview1 = date(s_interview1, "DMY", 2000)
		
	*Without taking into account the days
	for X in any norm max min: catenate s_school2_X = month_start_X current_school_year, p("/")
	catenate s_interview2 = hh5m hh5y, p("/")
	
	* create official month of start
	for X in any norm max min: generate date_school2_X = date(s_school2_X, "MY",2000) 
	* create school year of reference
	generate date_interview2 = date(s_interview2, "MY",2000)

	*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
	*Median difference is >=6.
	*50% of hh have 6 months of difference or more
	*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

	foreach M in norm max min {
		foreach X in 1 2 {
			generate diff`X'_`M' = (date_interview`X' - date_school`X'_`M')
			bys country_year: egen median_diff`X'_`M' = median(diff`X'_`M')
			generate adj`X'_`M' = 0
			replace adj`X'_`M' = 1 if median_diff`X'_`M' >= 182
		}
	}

	hashsort country_year
	gcollapse diff* adj* flag_month, by(country_year) fast
	save "`output_path'/MICS/data/mics_adjustment.dta", replace

	* COMPUTE IF SOMEONE DOES NOT GO TO SCHOOL (education out)
	use "`output_path'/MICS/data/mics_standardize.dta", clear
	set more off
	
	// 	*Completion each level with Age limits
 	generate ageA = age-1
 	generate ageU = age

	*Creating age groups for preschool
	generate age_group = 1 if inlist(ageU, 3, 4)
	replace age_group  = 2 if ageU == 5
	replace age_group  = 3 if inlist(ageU, 6, 7, 8)

	label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
	label values age_group age_group

	generate presch_before = 1 if (ed7 == "yes" | ed7 == "1") & code_ed8a == 0
	capture generate attend_primary = 1 if attend == 1 & inlist(code_ed6a, 1, 60, 70)
	capture replace attend_primary  = 0 if attend == 1 & code_ed6a == 0
	capture replace attend_primary  = 0 if attend == 0
		
	* generate no_attend the attend complement
	capture recode attend (1=0) (0=1), gen(no_attend)

	* generate eduout
	* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
	capture generate eduout = no_attend
	capture replace eduout  = . if (attend == 1 & code_ed6a == .) | age == . | (inlist(code_ed6a,. , 98, 99) & eduout == 0)
	capture replace eduout  = 1 if code_ed6a == 0 | ed3 == "no" 
	*Code_ed6a=80/90 affects countries Nigeria 2011, Nigeria 2016, Mauritania 2015, SouthSudan 2010, Sudan 2010 2014
	capture  replace eduout = 1 if code_ed6a == 80 
	capture  replace eduout = 1 if code_ed6a == 90 
	*special cases
	capture replace eduout = no_attend if country_year == "Nepal_2014"
	capture replace eduout = . if (ed6b == "missing" | ed6b == "don't know") & eduout == 0 & country_year == "Nepal_2014"
	capture replace eduout = 1 if ed6b == "preschool" | ed3 == "no" & country_year == "Nepal_2014"
	capture replace eduout = no_attend if country_year == "Barbados_2012"
	capture replace eduout = . if attend == 1 & code_ed6a == . & country_year == "Barbados_2012"
	capture replace eduout = . if inlist(code_ed6a, 98, 99) & eduout == 0 & country_year == "Barbados_2012"
	capture replace eduout = . if ed6a_nr == 0 & country_year == "Barbados_2012"
	capture replace eduout = 1 if ed3 == "no" & country_year == "Barbados_2012"
	
	capture generate eduout_preprim = eduout 
	*Goes to preschool is not considered as out of school in this variable
	capture replace eduout_preprim = 0 if code_ed6a == 0 
	
	
//	
// 	generate attend_mauritania = 0
//     replace attend_mauritania = 1 if ed5 == "yes"
//     replace attend_mauritania = . if ed5 == "missing"
//     recode attend_mauritania (1=0) (0=1), gen(eduout_mauritania)
//     replace eduout_mauritania = . if inlist(code_ed6a, 98, 99) & eduout_mauritania == 0
// 	replace eduout_mauritania = 1 if code_ed6a == 0 
// 	replace eduout_mauritania = 1 if ed3 == "no"
// 	replace eduout = eduout_mauritania if country_year == "Mauritania_2011"
// 	drop eduout_mauritania
	
	* Merging with adjustment
	merge m:1 country_year using "`output_path'/MICS/data/mics_adjustment.dta", keepusing(adj1_norm) nogenerate
	rename adj1_norm adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1
	capture drop *ageU *ageA 

	*Confirming that schage is available (for example, it is not available for South Sudan 2010)
	*replace schage = age if schage==. 
	bys country_year: egen temp_count = count(schage)
	replace schage = age if temp_count == 0 & adjustment == 0
	replace schage = age-1 if temp_count == 0 & adjustment == 1
	drop temp_count
	
		
	*******OUT OF SCHOOL**********
	for X in any prim_dur lowsec_dur upsec_dur prim_age0 : rename X X_comp

	*Durations for OUT-OF-SCHOOL & ATTENDANCE
	rename year year_original
	generate year = year_original
	replace year = 2017 if year_original >= 2018
	cd "`c(sysdir_personal)'/"
	*local uisfile : dir . files "UIS_duration_age_*.dta"
	*findfile `uisfile', path("`c(sysdir_personal)'/")
	findfile UIS_duration_age_01102020.dta, path("`c(sysdir_personal)'/")
	*use "`r(fn)'", clear
	merge m:1 iso_code3 year using "`r(fn)'", keep(master match) nogenerate
	drop year
	rename year_original year
	drop lowsec_age_uis upsec_age_uis
		
	for X in any prim_dur lowsec_dur upsec_dur: rename X_uis X_eduout
	rename prim_age_uis prim_age0_eduout

	capture generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	capture generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
	*******/OUT OF SCHOOL**********
		
	*******LESS THAN 4 YEARS OF SCHOOLING**********
	*dropping edu2 
		generate edu4 = 0
		replace edu4  = 1 if eduyears < 4
		replace edu4  = . if eduyears == .
	*******/LESS THAN 4 YEARS OF SCHOOLING**********

	***********OVER-AGE PRIMARY ATTENDANCE**************
	**MICS6 version
	*Over-age primary school attendance
	*Percentage of children in primary school who are two years or more older than the official age for grade.
	if (year_folder >= 2017) {
	gen overage2plus= 0 if attend_primary==1
	gen primarygrades=old_ed10b if code_ed6a==1 & old_ed10b<90
	levelsof primarygrades, local(primgrades) clean
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if old_ed10b==`grade' & schage>prim_age0_comp+1+`i'
                 }
				 }
	*MICS 5 and older version
				 if (year_folder < 2017) {
	gen overage2plus= 0 if attend_primary==1
	gen primarygrades=ed6b if code_ed6a==1 &  inlist(ed6b, "1", "2", "3", "4", "5", "6", "7", "8","9")
	levelsof primarygrades, local(primgrades) clean
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if ed6b=="`grade'" & schage>prim_age0_comp+1+`i'
                 }
				 }
	***********/OVER-AGE PRIMARY ATTENDANCE**************
	
	*******HIGHER EDUCATION ATTENDANCE**********
	generate high_ed       = 1 if inlist(code_ed6a, 3, 32, 33, 40, 41, 42)
	capture generate attend_higher = 1 if attend == 1 & high_ed == 1
	capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
	capture replace attend_higher  = 0 if attend == 0
	
	generate attend_higher_5 = attend_higher if schage >= upsec_age1 + 1 & schage <= upsec_age1 + 5

	
	*******/HIGHER EDUCATION ATTENDANCE**********
	

	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
	*Now run the code to attach and merge the literacy variables
	
	destring year, replace
	
**************************************************************	
**************************** 	Adding extra modules section
**************************************************************
****************************

*WM Module check and merge
cd "`data_path'\\`country_code'_`country_year'_MICS\"

capture confirm file wm.dta 
if _rc == 0 {
use "wm.dta", clear
gen iso_code3=upper("`country_code'")
generate year_folder = `country_year'
capture rename ln LN 
		   capture confirm variable LN 
				if !_rc {	
				}
					else {
					*Special case for Mexico 2015, and other surveys
					   capture rename WM4 LN 
						}
		   
		   *First check if literacy variable exists, if not, delete that file 
		   capture confirm variable WB14
			if !_rc {
		   	*Adding this to check for the MASS MEDIA AND ICT module and capture it if variables exist
			 capture confirm variable MT2 
				if !_rc {
							di "Both literacy and mass media exist "
							***RECODE ABLE TO READ TEST VAR***
							recode WB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy)
							recode WB14 (1 2 = 0) (3 = 1) (4 6 9 = .), gen(full_literacy)
							*keep identifyer vars and literacy
							* 1 cannot read at all
							* 2 able to read only parts of sentence
							* 3 able to read whole sentence
							* 4 no sentence in required language
							* 9 no response
							  capture confirm variable LN
										if !_rc {
										rename LN hl1, replace
										}
										else {
										rename ln hl1, replace
										}

							rename HH1 hh1, replace
							rename HH2 hh2, replace
							rename WM6Y hh5y, replace
							capture rename WAGE age, replace
							gen sex="Female"

							capture confirm variable AF12
							if !_rc {
										keep iso_code3 year_folder sex hh1 hh2 hl1 WB14 literacy MT* full_literacy AF*
										
									}
							else {
										keep iso_code3 year_folder sex hh1 hh2 hl1 WB14 literacy MT* full_literacy
									}
							
				compress
				merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
				save "`output_path'/MICS/data/mics_standardize.dta", replace
										
						}
						
					else {
							di "Only literacy exists, keeping " "`f'"
							
							***RECODE ABLE TO READ TEST VAR***
							recode WB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy)
							recode WB14 (1 2 = 0) (3 = 1) (4 6 9 = .), gen(full_literacy)
							*keep identifyer vars and literacy
							* 1 cannot read at all
							* 2 able to read only parts of sentence
							* 3 able to read whole sentence
							* 4 no sentence in required language
							* 9 no response
							  capture confirm variable LN
										if !_rc {
										rename LN hl1, replace
										}
										else {
										rename ln hl1, replace
										}
							rename HH1 hh1, replace
							rename HH2 hh2, replace
							capture rename WAGE age, replace
							gen sex="Female"
														
							capture confirm variable AF12
							if !_rc {
									  keep iso_code3 year_folder sex hh1 hh2 hl1 WB14 literacy full_literacy AF* disability
	  								rename disability wdisability
									sdecode wdisability, replace 
								  }
							else {
									 keep iso_code3 year_folder sex hh1 hh2 hl1 WB14 literacy full_literacy
     								}
							
							compress
							tempfile wm_selection
							save "`wm_selection'"
							
							merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
							save "`output_path'/MICS/data/mics_standardize.dta", replace
									}
			
							}
				   
		else {
		 	  *Adding this in case only mass media ict exists
			 capture confirm variable MT2 
				if !_rc {
							*keep identifyer vars and literacy
							  capture confirm variable LN
										if !_rc {
										rename LN hl1, replace
										}
										else {
										rename ln hl1, replace
										}

							rename HH1 hh1, replace
							rename HH2 hh2, replace
							capture rename WAGE age, replace
							gen sex="Female"

							capture confirm variable AF12
							if !_rc {							
								keep iso_code3 year_folder sex hh1 hh2 hl1 MT* AF* disability
								rename disability wdisability
								sdecode wdisability, replace 
								}
							else {
							    keep iso_code3 year_folder sex hh1 hh2 hl1 MT*
							}
								
							compress
							tempfile wm_selection
							save "`wm_selection'"
							
							merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
							save "`output_path'/MICS/data/mics_standardize.dta", replace
									
													}
					else {
							di "Maybe there's only adult functioning module"
							capture confirm variable AF12
							if !_rc {		
							capture confirm variable LN
										if !_rc {
										rename LN hl1, replace
										}
										else {
										rename ln hl1, replace
										}

							rename HH1 hh1, replace
							rename HH2 hh2, replace
							gen sex="Female"
								keep iso_code3 year_folder sex hh1 hh2 hl1 AF* disability
								rename disability wdisability
								sdecode wdisability, replace 
								compress
							tempfile wm_selection
							save "`wm_selection'"
							
							merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
							save "`output_path'/MICS/data/mics_standardize.dta", replace
								}
							else {
									clear
									}						
							
			
			}
								}
			
         
else { 
    di "Women module not available in this survey"
} 

*end of wm extraction


*****************************************
*Mn module search and merge

  
cd "`data_path'\\`country_code'_`country_year'_MICS\"
  
capture confirm file mn.dta 
if _rc == 0 {
use "mn.dta", clear
gen iso_code3=upper("`country_code'")
generate year_folder = `country_year'
   capture rename ln LN 
		   capture confirm variable MWB14
			if _rc == 0 {
			di "Something exists, keeping " "`f'"
		    *Adding this to check for the MASS MEDIA AND ICT module and capture it if variables exist
			 capture confirm variable MMT2 
				if !_rc {
							capture confirm variable MAF12 
							if !_rc {
							keep iso_code3 year_folder HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4 MMT* MAF* mdisability
							sdecode mdisability, replace 
							}
							else {
							keep iso_code3 year_folder HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4 MMT* 
							}
							
						}
					else {
							capture confirm variable MAF12 
							if !_rc {
							keep iso_code3 year_folder HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4 MAF* mdisability
							sdecode mdisability, replace 
							}
							else {
							keep iso_code3 year_folder HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4
									}							
						}
					recode MWB14 (1 = 0) (2 3 = 1) (4 9 = .), gen(literacy)
					recode MWB14 (1 2 = 0) (3 = 1) (4 6 9 = .), gen(full_literacy)
							* 1 cannot read at all
							* 2 able to read only parts of sentence
							* 3 able to read whole sentence
							* 4 no sentence in required language
							* 9 no response
							
					*keep identifyer vars and literacy
					capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								capture rename ln hl1, replace
								capture rename HL1 hh1, replace
								}
					rename HH1 hh1, replace
					rename HH2 hh2, replace
					rename MWM6D hh5d, replace
					rename MWM6M hh5m, replace
					rename MWM6Y hh5y, replace
					rename MWB4 age
					gen sex="Male"
					capture duplicates drop iso_code3 year_folder hh1 hh2 hl1 , force
					compress
					tempfile mn_selection
					save "`mn_selection'"
					
					merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
					save "`output_path'/MICS/data/mics_standardize.dta", replace
 		  		      }
		else {
		 	  *Adding this in case only mass media ict exists
			 capture confirm variable MMT2 
				if !_rc {
				
				capture confirm variable MAF12 
							if !_rc {
							keep iso_code3 year_folder HH1 HH2 LN MMT* MAF* mdisability
							sdecode mdisability, replace 
							}
							else {
							keep iso_code3 year_folder HH1 HH2 LN MMT*
									}				
								compress
							  capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								rename ln hl1, replace
								}
							gen sex="Male"
							rename HH1 hh1, replace
							rename HH2 hh2, replace
							capture duplicates drop iso_code3 year_folder hh1 hh2 hl1 , force
							tempfile mn_selection
							save "`mn_selection'"
							merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
							save "`output_path'/MICS/data/mics_standardize.dta", replace
													}
					else {
							capture confirm variable MAF12 
							if !_rc {
							capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								capture rename ln hl1, replace
								capture rename HL1 hh1, replace
								}
					rename HH1 hh1, replace
					rename HH2 hh2, replace
							keep iso_code3 year_folder HH1 HH2 LN MAF* mdisability
							sdecode mdisability, replace 
							capture duplicates drop iso_code3 year_folder hh1 hh2 hl1 , force
							tempfile mn_selection
							save "`mn_selection'"
							merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
							      }
							else {
								di "Clearing because neither literacy nor mass media/ict nor adult functioning variables exists in " "`f'"
							clear					
								}
							}
			
			}
				
					}
			
         }
		 


else { 
    di "Men module not available in this survey"
} 
*end of mn extraction

****************
***CH MODULE: MOTHERS OF <5 Y-O CHILDREN***
*begin of ch extraction* 
cd "`data_path'\\`country_code'_`country_year'_MICS\"
  
capture confirm file ch.dta 
if _rc == 0 {
use "ch.dta", clear
capture rename *, upper
gen iso_code3=upper("`country_code'")
generate year_folder = `country_year'
*homogenizing variables

   capture rename ln LN 
		   *Check for EARLY CHILDHOOD DEVELOPMENT module (EC questions)
		   capture confirm variable EC1
			if _rc == 0 {
					capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								capture rename ln hl1, replace
								capture rename HL1 hl1, replace
								*Mexico 2015
								capture rename UF4 hl1, replace
								}
					rename HH1 hh1, replace
					rename HH2 hh2, replace
					***2021 NEW: check if FCF/UCF VARIABLES ARE AVAILABLE TO SAVE THEM 
					capture confirm variable UCF2
						 if !_rc {
											keep iso_code3 year_folder hh1 hh2 hl1 EC* UCF* CDISABILITY
											rename UCF# FCF#
											sdecode CDISABILITY, replace
						}
						else {
						capture confirm variable FCF2
								if !_rc {
												keep iso_code3 year_folder hh1 hh2 hl1 EC* FCF* CDISABILITY
												sdecode CDISABILITY, replace
								}
								else {
								 				keep iso_code3 year_folder hh1 hh2 hl1 EC* 

																}
						}
					
					*There are ch modules with no variables to construct ecd***
					capture confirm variable EC8
						if !_rc {
					***There is a change in variable names/numbers between MICS, so there are two versions to calculate the ecd variable***
					capture confirm variable EC17
						if !_rc {
							for X in any EC8 EC9 EC10 EC11 EC13 EC14 EC15: recode X (2=0) (8/9=.)
							for X in any EC12 EC16 EC17: recode X (1=0) (2=1) (8/9=.)
							 ** Literacy & numeracy (identifies at least 10 letters of alphabet / reads 4 simple words / knows numbers 1-10)
							 gen sum_litnum = EC8 + EC9 + EC10
							 gen litnum=0
							 replace litnum=1 if sum_litnum>=2 & sum_litnum!=.
							 replace litnum=. if EC8==. & EC9==. & EC10==.
							 ** Physical (able to pick up small object / too sick to play)
							gen physical=0
							replace physical=1 if EC11==1 | EC12==1
							replace physical=. if EC11==. & EC12==.
							** Learning (can follow instructions / able to do something independently)
							gen learns=0
							replace learns=1 if EC13==1 | EC14==1
							replace learns=. if EC13==. & EC14==.
							** SocioEm (gets along w other children / kicks bites or hits others / distracted easily )
							 gen sum_socioem = EC15 + EC16 + EC17
							 gen socioem=0
							 replace socioem=1 if sum_socioem>=2 & sum_socioem!=.
							 replace socioem=. if EC15==. & EC16==. & EC17==.
							**** ECD index
								gen sum_ecd=litnum+physical+learns+socioem
								gen ecd=0
								replace ecd=1 if sum_ecd>=3 & sum_ecd!=.
								replace ecd=. if litnum==. & physical==. & learns==. & socioem==.
								drop sum_*
							}
						else {
							for X in any EC6 EC7 EC8 EC9 EC11 EC12 EC13: recode X (2=0) (8/9=.)
							for X in any EC10 EC14 EC15: recode X (1=0) (2=1) (8/9=.)
							 ** Literacy & numeracy (identifies at least 10 letters of alphabet / reads 4 simple words / knows numbers 1-10)
							 gen sum_litnum= EC6 + EC7 + EC8
							 gen litnum=0
							 replace litnum=1 if sum_litnum>=2 & sum_litnum!=.
							 replace litnum=. if EC6==. & EC7==. & EC8==.
							 ** Physical (able to pick up small object / too sick to play)
							gen physical=0
							replace physical=1 if EC9==1 | EC10==1
							replace physical=. if EC9==. & EC10==.
							** Learning (can follow instructions / able to do something independently)
							gen learns=0
							replace learns=1 if EC11==1 | EC12==1
							replace learns=. if EC11==. & EC12==.
							** SocioEm (gets along w other children / kicks bites or hits others / distracted easily )
							 gen sum_socioem=EC13 + EC14 + EC15
							 gen socioem=0
							 replace socioem=1 if sum_socioem>=2 & sum_socioem!=.
							 replace socioem=. if EC13==. & EC14==. & EC15==.
							**** ECD index
								gen sum_ecd=litnum+physical+learns+socioem
								gen ecd=0
								replace ecd=1 if sum_ecd>=3 & sum_ecd!=.
								replace ecd=. if litnum==. & physical==. & learns==. & socioem==.
								drop sum_*
								tab ecd
							}
						}
						else {
						 di "CH module does not have EC variables needed to calculate ECD index"
						 }
					compress
					tempfile ch_selection
					save "`ch_selection'"
					
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
										   }
		else {
							di "Early Childhood Development submodule is not there, but child functioning might be"
							capture rename ln LN 
		   *Check for EARLY CHILDHOOD DEVELOPMENT module (EC questions)
		  					capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								capture rename ln hl1, replace
								capture rename HL1 hl1, replace
									}
					rename HH1 hh1, replace
					rename HH2 hh2, replace
							capture confirm variable UCF1 
						 if !_rc {
						     di "Early Childhood Development submodule is not there, but child functioning is"
											keep iso_code3 year_folder hh1 hh2 hl1 UCF* CDISABILITY
											rename UCF# FCF#
											sdecode CDISABILITY, replace
											compress
					tempfile ch_selection
					save "`ch_selection'"
					
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						
						}
						else {
						capture confirm variable FCF1
								if !_rc {
							  di "Early Childhood Development submodule is not there, but child functioning is"

												keep iso_code3 year_folder hh1 hh2 hl1 FCF* CDISABILITY
												sdecode CDISABILITY, replace
												compress
					tempfile ch_selection
					save "`ch_selection'"
					
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						
								}
								else {
						 di "Neither Early Childhood Development nor child functioning modules are available"
						 clear
										}
						}
				}
			
			} // this one is closing whatever you do with ch.dta
				
	   
		 
else { 
    di "CH (children under the age of 5) module not available in this survey"
} 

*end of ch extraction


***************************

 *begin of fs module (mothers of 5-17 years old children) extraction: 
cd "`data_path'\\`country_code'_`country_year'_MICS\"
  
capture confirm file fs.dta 
if _rc == 0 {
use "fs.dta", clear
capture rename *, upper
gen iso_code3=upper("`country_code'")
generate year_folder = `country_year'

		   *Check for FOUNDATIONAL LEARNING SKILLS sub-module 
		   capture confirm variable FL1
			if _rc == 0 {
					capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								capture rename ln hl1, replace
								capture rename HL1 hl1, replace
								}
					rename HH1 hh1, replace
					rename HH2 hh2, replace
					
					capture confirm variable UCF2 
						 if !_rc {
												keep iso_code3 year_folder hh1 hh2 hl1 FL* UCF*  FSDISABILITY
												sdecode FSDISABILITY, replace
												
						}
						else {
						capture confirm variable FCF2
								if !_rc {
												keep iso_code3 year_folder hh1 hh2 hl1 FL* FCF*  FSDISABILITY
										**for disability:all the variables coded as FCF will be renamed as UCF as its not homegeneous between surveys 
												rename FCF# UCF#
												sdecode FSDISABILITY, replace
								}
								else {
								 				keep iso_code3 year_folder hh1 hh2 hl1 FL*  

																}
					compress
					tempfile fs_selection
					save "`fs_selection'"
					
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
							
				   }
				   }
		else {
								capture confirm variable LN
								if !_rc {
								rename LN hl1, replace
								}
								else {
								capture rename ln hl1, replace
								capture rename HL1 hl1, replace
								}
					rename HH1 hh1, replace
					rename HH2 hh2, replace
								capture confirm variable UCF1 
						 if !_rc {
						     di "Early Childhood Development submodule is not there, but child functioning is"
											keep iso_code3 year_folder hh1 hh2 hl1 UCF*  FSDISABILITY
											sdecode FSDISABILITY, replace
											
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						
						}
						else {
						capture confirm variable FCF1
								if !_rc {
							  di "Early Childhood Development submodule is not there, but child functioning is"

												keep iso_code3 year_folder hh1 hh2 hl1 FCF*  FSDISABILITY
												sdecode FSDISABILITY, replace
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						
								}
								else {
						 di "Neither Foundational Learning Skills nor child functioning modules are available"
								clear
																}
															}
						}
						}
				
	   
		 
else { 
    di "FS (children ages 5-17) module not available in this survey"
} 
*end of FS extraction

capture confirm variable hh1
if !_rc {
                       di "at least one extra module added"
               }
               else {
                       di "no extra modules were added"
					   use "`output_path'/MICS/data/mics_standardize.dta", clear

               }
			   


**************************** 	end of do widetable_literacy_mics_std***


	***FINISH LITERACY CALCULATION***
	capture confirm variable literacy
if !_rc {
		gen literacy_1549 = literacy if age >= 15 & age <= 49
		replace literacy_1549 = 1 if eduyears >= years_lowsec & literacy==.
		replace literacy_1549 = 0 if eduyears < years_lowsec & literacy==.
		gen literacy_1524=literacy_1549 if age >= 15 & age <= 24
               }
	***/FINISH LITERACY CALCULATION***
	
	***DISABILITY CALCULATION***

	*** CH: CHILD FUNCTIONING FOR CHILDREN AGE 2-4 YEARS ***

		*Based on the recommended cut-off, the disability indicator includes "a lot more" difficulty for the question on controlling behavior, and “a lot of difficulty" and "cannot do at all" for all other questions *

		* PART ONE: Creating separate variables per domain of functioning *
		
		capture confirm variable FCF7
	if !_rc {
		* SEEING DOMAIN *
		gen SEE_IND = FCF7

		gen Seeing_2to4 = 9
		replace Seeing_2to4 = 0 if inrange(SEE_IND, 1, 2)
		replace Seeing_2to4 = 1 if inrange(SEE_IND, 3, 4)
		label define see 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Seeing_2to4 see

		* HEARING DOMAIN *
		gen HEAR_IND = FCF9

		gen Hearing_2to4 = 9
		replace Hearing_2to4 = 0 if inrange(HEAR_IND, 1, 2)
		replace Hearing_2to4 = 1 if inrange(HEAR_IND, 3, 4)
		label define hear 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Hearing_2to4 hear

		* WALKING DOMAIN *
		gen WALK_IND = FCF11 // without equipment...
		replace WALK_IND = FCF13 if FCF11 == . // compared w other children how difficult is to walk
		tab WALK_IND

		gen Walking_2to4 = 9
		replace Walking_2to4 = 0 if inrange(WALK_IND, 1, 2)
		replace Walking_2to4 = 1 if inrange(WALK_IND, 3, 4)
		label define walk 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Walking_2to4 walk

		* FINE MOTOR DOMAIN * also called dexterity 
		gen FineMotor_2to4 = 9
		replace FineMotor_2to4 = 0 if inrange(FCF14, 1, 2)
		replace FineMotor_2to4 = 1 if inrange(FCF14, 3, 4)
		label define motor 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value FineMotor_2to4 motor

		* COMMUNICATING DOMAIN *
		gen COM_IND = 0
		replace COM_IND = 4 if (FCF15 == 4 | FCF16 == 4) // HIM UNDERSTANDING YOU 15, YOU UNDERSTANDING HIM 16
		replace COM_IND = 3 if (COM_IND != 4 & (FCF15 == 3 | FCF16 == 3))
		replace COM_IND = 2 if (COM_IND != 4 & COM_IND != 3 & (FCF15 == 2 | FCF16 == 2))
		replace COM_IND = 1 if (COM_IND != 4 & COM_IND != 3 & COM_IND != 1 & (FCF15 == 1 | FCF16 == 1))
		replace COM_IND = 9 if ((COM_IND == 2 | COM_IND == 1) & (FCF15 == . | FCF16 == 9))
		tab COM_IND

		gen Communication_2to4 = 9
		replace Communication_2to4 = 0 if inrange(COM_IND, 1, 2)
		replace Communication_2to4 = 1 if inrange(COM_IND, 3, 4)
		label define communicate 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Communication communicate

		* LEARNING DOMAIN *
		gen Learning_2to4 = 9 
		replace Learning_2to4 = 0 if inrange(FCF17, 1, 2)
		replace Learning_2to4 = 1 if inrange(FCF17, 3, 4)
		label define learn 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Learning_2to4 learn

		* PLAYING DOMAIN *
		gen Playing_2to4 = 9
		replace Playing_2to4 = 0 if inrange(FCF18, 1, 2)
		replace Playing_2to4 = 1 if inrange(FCF18, 3, 4)
		label define playing 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Playing_2to4 play 

		* BEHAVIOUR DOMAIN *
		gen Behaviour_2to4 = 9 
		replace Behaviour_2to4 = 0 if inrange(FCF19, 1, 4)
		replace Behaviour_2to4 = 1 if FCF19 == 5
		label define behave 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Behaviour_2to4 behave 

		* PART TWO: Creating disability indicator for children age 2-4 years *

		gen FunctionalDifficulty_2to4 = 0
		replace FunctionalDifficulty_2to4 = 1 if (Seeing_2to4 == 1 | Hearing_2to4 == 1 | Walking_2to4 == 1 | FineMotor_2to4 == 1 | Communication_2to4 == 1 | Learning_2to4 == 1 | Playing_2to4 == 1 | Behaviour_2to4 == 1) 
		replace FunctionalDifficulty_2to4 = . if (FunctionalDifficulty_2to4 != 1 & (Seeing_2to4 == 9 | Hearing_2to4 == 9 | Walking_2to4 == 9 | FineMotor_2to4 == 9 | Communication_2to4 == 9 | Learning_2to4 == 9 | Playing_2to4 == 9 | Behaviour_2to4 == 9)) 
		label define difficulty 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value FunctionalDifficulty_2to4 
		
		}

// 		* Creating "traditional" disability that will only consider the 4 dimensions  seeing, hearing, walking/mobility, and communicate
//
// 		gen disability_trad = 0
// 		replace disability_trad = 1 if (Seeing_2to4 == 1 | Hearing_2to4 == 1 | Walking_2to4 == 1 | Communication_2to4 == 1 ) 
// 		replace disability_trad = . if (disability_trad != 1 & (Seeing_2to4 == 9 | Hearing_2to4 == 9 | Walking_2to4 == 9 | Communication_2to4 == 9 )) 
// 		*label define difficulty 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
// 		label value disability_trad difficulty
		


		***************************************************************************
		*** CHILD FUNCTIONING FOR CHILDREN AGE 5-17 YEARS ***

		*Based on the recommended cut-off, the disability indicator includes “daily” for the questions on anxiety and depression; and “a lot of difficulty" and "cannot do at all" for all other questions *

		* PART ONE: Creating separate variables per domain of functioning *

		*drop previously created
		capture drop *_IND
		
		capture confirm variable UCF6
	if !_rc {
		* SEEING DOMAIN *
		gen SEE_IND = UCF6

		gen Seeing_5to17 = 9
		replace Seeing_5to17 = 0 if inrange(SEE_IND, 1, 2)
		replace Seeing_5to17 = 1 if inrange(SEE_IND, 3, 4)
		*label define see 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Seeing_5to17 see

		* HEARING DOMAIN *
		gen HEAR_IND = UCF8

		gen Hearing_5to17 = 9
		replace Hearing_5to17 = 0 if inrange(HEAR_IND, 1, 2)
		replace Hearing_5to17 = 1 if inrange(HEAR_IND, 3, 4)
		*label define hear 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Hearing_5to17 hear

		* WALKING DOMAIN *
		gen WALK_IND1 = UCF10 // withour equipment, diff walking 100 meters 
		replace WALK_IND1 = UCF11 if UCF10 == 2 // without equipment, walkng 500 meters
		tab WALK_IND1

		gen WALK_IND2 = UCF14 // compared w children of the same age, diff walking 100 mt
		replace WALK_IND2 = UCF15 if (UCF14 == 1 | UCF14 == 2) // compared w children same age, diff walking 500 mt
		tab WALK_IND2

		gen WALK_IND = WALK_IND1
		replace WALK_IND = WALK_IND2 if WALK_IND1 == .
		tab WALK_IND

		gen Walking_5to17 = 9
		replace Walking_5to17 = 0 if inrange(WALK_IND, 1, 2)
		replace Walking_5to17 = 1 if inrange(WALK_IND, 3, 4)
		*label define walk 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Walking_5to17 walk 

		* SELFCARE DOMAIN *
		gen Selfcare_5to17 = 9
		replace Selfcare_5to17 = 0 if inrange(UCF16, 1, 2)
		replace Selfcare_5to17 = 1 if inrange(UCF16, 3, 4)
		*label define selfcare 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Selfcare_5to17 selfcare

		* COMMUNICATING DOMAIN *
		gen COM_IND = 0
		replace COM_IND = 4 if (UCF17 == 4 | UCF18 == 4) // diff being understood IN house, diff being understood OUTSIDE of house
		replace COM_IND = 3 if (COM_IND != 4 & (UCF17 == 3 | UCF18 == 3))
		replace COM_IND = 2 if (COM_IND != 4 & COM_IND != 3 & (UCF17 == 2 | UCF18 == 2))
		replace COM_IND = 1 if (COM_IND != 4 & COM_IND != 3 & COM_IND != 1 & (UCF17 == 1 | UCF18 == 1))
		replace COM_IND = 9 if ((COM_IND == 2 | COM_IND == 1) & (UCF17 == 9 | UCF18 == 9))
		tab COM_IND

		gen Communication_5to17 = 9
		replace Communication_5to17 = 0 if inrange(COM_IND, 1, 2) 
		replace Communication_5to17 = 1 if inrange(COM_IND, 3, 4)
		*label define communicate 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Communication_5to17 communicate

		* LEARNING DOMAIN *
		gen Learning_5to17 = 9
		replace Learning_5to17 = 0 if inrange(UCF19, 1, 2)
		replace Learning_5to17 = 1 if inrange(UCF19, 3, 4)
		label define learning 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Learning_5to17 learning

		* REMEMBERING DOMAIN *
		gen Remembering_5to17 = 9
		replace Remembering_5to17 = 0 if inrange(UCF20, 1, 2)
		replace Remembering_5to17 = 1 if inrange(UCF20, 3, 4)
		label define remembering 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Remembering_5to17 remembering

		* CONCENTRATING DOMAIN *
		gen Concentrating_5to17 = 9
		replace Concentrating_5to17 = 0 if inrange(UCF21, 1, 2)
		replace Concentrating_5to17 = 1 if inrange(UCF21, 3, 4)
		label define concentrating 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Concentrating_5to17 concentrating 

		* ACCEPTING CHANGE DOMAIN *
		gen AcceptingChange_5to17 = 9
		replace AcceptingChange_5to17 = 0 if inrange(UCF22, 1, 2)
		replace AcceptingChange_5to17 = 1 if inrange(UCF22, 3, 4)
		label define accepting 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value AcceptingChange_5to17 accepting

		* BEHAVIOUR DOMAIN * e difficulty controlling his/her behaviour
		gen Behaviour_5to17 = 9
		replace Behaviour_5to17 = 0 if inrange(UCF23, 1, 2)
		replace Behaviour_5to17 = 1 if inrange(UCF23, 3, 4)
		label define behaviour 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Behaviour_5to17 behaviour

		* MAKING FRIENDS DOMAIN *
		gen MakingFriends_5to17 = 9
		replace MakingFriends_5to17 = 0 if inrange(UCF24, 1, 2)
		replace MakingFriends_5to17 = 1 if inrange(UCF24, 3, 4)
		label define friends 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value MakingFriends_5to17 friends

		* ANXIETY DOMAIN *
		gen Anxiety_5to17 = 9
		replace Anxiety_5to17 = 0 if inrange(UCF25, 2, 5)
		replace Anxiety_5to17 = 1 if (UCF25 == 1)
		label define anxiety 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Anxiety_5to17 anxiety

		* DEPRESSION DOMAIN *
		gen Depression_5to17 = 9
		replace Depression_5to17 = 0 if inrange(UCF26, 2, 5)
		replace Depression_5to17 = 1 if (UCF26 == 1)
		label define depression 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Depression_5to17 depression

		* PART TWO: Creating disability indicator for children age 5-17 years *

		gen FunctionalDifficulty_5to17 = 0
		replace FunctionalDifficulty_5to17 = 1 if (Seeing_5to17 == 1 | Hearing_5to17 == 1 | Walking_5to17 == 1 | Selfcare_5to17 == 1 | Communication_5to17 == 1 | Learning_5to17 == 1 | Remembering_5to17 == 1 | Concentrating_5to17 == 1 | AcceptingChange_5to17 == 1 | Behaviour_5to17 == 1 | MakingFriends_5to17 == 1 | Anxiety_5to17 == 1 | Depression_5to17 == 1) 
		replace FunctionalDifficulty_5to17 = . if (FunctionalDifficulty_5to17 != 1 & (Seeing_5to17 == 9 | Hearing_5to17 == 9 | Walking_5to17 == 9 | Selfcare_5to17 == 9 | Communication_5to17 == 9 | Learning_5to17 == 9 | Remembering_5to17 == 9 | Concentrating_5to17 == 9 | AcceptingChange_5to17 == 9 | Behaviour_5to17 == 9 | MakingFriends_5to17 == 9 | Anxiety_5to17 == 9 | Depression_5to17 == 9)) 
		capture label define difficulty 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value FunctionalDifficulty_5to17 difficulty
		
		}


// 		* Creating "traditional" disability that will only consider the 4 dimensions  seeing, hearing, walking/mobility, and communication
//
// 		replace disability_trad = 0 if schage > 4
// 		replace disability_trad = 1 if (Seeing_5to17 == 1 | Hearing_5to17 == 1 | Walking_5to17 == 1 |  Communication_5to17 == 1 ) & schage > 4
// 		replace disability_trad = . if (disability_trad != 1 & (Seeing_5to17 == 9 | Hearing_5to17 == 9 | Walking_5to17 == 9 | Communication_5to17 == 9 )) & schage > 4
// 		*label define difficulty 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
// 		label value disability_trad difficulty
		
// 		* Creating disability indicator that is the combination of both FunctionalDifficulty_2to4 and FunctionalDifficulty_5to17 IF BOTH EXIST 
// 		capture confirm variable FunctionalDifficulty_2to4 FunctionalDifficulty_5to17
// 		if !_rc {
// 		egen disability_children =rowtotal(FunctionalDifficulty_2to4  FunctionalDifficulty_5to17)
// 		*there is a problem here, so we're not using this combined variable just yet (also how did this happened?)
// 				}
				

		***************************************************************************
		*** ADULTS (men and women) 18+ YEARS ***

		

		capture confirm variable AF6
	if !_rc {
			*First homogenize MAF and AF...IF MAF EXISTS...
		capture confirm variable MAF6
	if !_rc {
		foreach var of varlist AF6 AF8 AF9 AF10 AF11 AF12 {
				replace `var' = M`var' if sex=="Male"
				}
			}
	
		*Now rename the AF* 
		rename AF6 Vision 
		rename AF8 Hearing 
 		rename AF9 Mobility
 		rename AF10 Cognition // COGNITION=REMEMBERING OR CONCENTRATING
		rename AF11 Self_Care 
 		rename AF12 Communication

		gen SumPoints=0
		foreach v of var Vision Hearing Mobility Cognition Self_Care Communication {
 		replace SumPoints=SumPoints + inlist(`v',2,3,4)
 		}
 		replace SumPoints=. if missing(Vision) & missing(Hearing) & ///
 		missing(Mobility) & missing(Cognition) & missing(Self_Care) & missing(Communication)

 		gen SUM_234=. if SumPoints==.
 		replace SUM_234=1 if SumPoints==1
 		replace SUM_234=2 if SumPoints==2
 		replace SUM_234=3 if SumPoints==3
 		replace SUM_234=4 if SumPoints==4
 		replace SUM_234=5 if SumPoints==5
 		replace SUM_234=6 if SumPoints==6
 		replace SUM_234=0 if SumPoints==0 

 		gen SumPoints2=0
 		foreach v of var Vision Hearing Mobility Cognition Self_Care Communication {
 		replace SumPoints2=SumPoints2 + inlist(`v',3,4)
 		}
 		replace SumPoints2=. if missing(Vision) & missing(Hearing) & ///
 		missing(Mobility) & missing(Cognition) & missing(Self_Care) & missing(Communication)

 		gen SUM_34=. if SumPoints2==.
 		replace SUM_34=1 if SumPoints2==1
 		replace SUM_34=2 if SumPoints2==2
 		replace SUM_34=3 if SumPoints2==3
 		replace SUM_34=4 if SumPoints2==4
 		replace SUM_34=5 if SumPoints2==5
 		replace SUM_34=6 if SumPoints2==6
 		replace SUM_34=0 if SumPoints2==0
 		*tabulate SUM_34
		
		gen FunctionalDifficulty_adults=0
		replace FunctionalDifficulty_adults=1 if (inlist(Vision,3,4) | inlist(Hearing,3,4) | inlist(Mobility,3,4) | ///
		inlist(Communication,3,4) | inlist(Self_Care,3,4) | inlist(Cognition,3,4))
		replace FunctionalDifficulty_adults=. if missing(Vision) & missing(Hearing) & missing(Mobility) & ///
		missing(Cognition) & missing(Self_Care) & missing(Communication)
		capture label define difficulty 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 

		label value FunctionalDifficulty_adults difficulty
		}
		
	
		
	***/FINISH DISABILITY CALCULATION***
	
	
	
	*Fix year variable hh5y in case some of the imports contain weird values (special cases of Nepal and Ethiopia)
	replace hh5y = year_folder if  (hh5y - year_folder) > 3
	replace year = year_folder if  (year - year_folder) > 3

            		
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = "" if `var' == "."
	}
	
	generate edu0 = 0 if ed3 == "yes"
	replace edu0  = 1 if ed3 == "no"
	replace edu0  = 1 if code_ed4a == 0
	replace edu0  = 1 if eduyears == 0
	
	capture generate attend_preschool   = 1 if attend == 1 & code_ed6a == 0
	capture replace attend_preschool    = 0 if attend == 1 & code_ed6a != 0
	capture replace attend_preschool    = 0 if attend == 0
	
	rename prim_age0_eduout prim_age0
	
	
	**HOUSEHOLD EDUCATION**
	**NEW!**
	
	/* 
		Most educated adult has’ and the options would be: 
	-	0  not completed any level of education 
	-	1  completed primary
	-	2  completed lower secondary
	-	3  completed upper secondary
	-	4  completed post-secondary 
	*/

  	* Household Education 1: Considering head of household as highest education (no missings but recode categories)
	* However, it's not rare that the mother has higher education than the head 
	* New age restriction on head 
	
	bysort hh_id: egen head_eduyears = total(cond(hl3 == 1 , eduyears, .))

	generate hh_edu_head = 0
	foreach Z in prim lowsec upsec higher {
		replace hh_edu_head = hh_edu_head + 1  if head_eduyears >= years_`Z'
				 	}
	*Censoring for head of households who are older than 60 years old 
	bysort hh_id: egen head_age = total(cond(hl3 == 1 , hl6, .))
	replace hh_edu_head=. if head_age>60
	
	label define hh_edu_head 0 "Not completed any level of education" 1 "Completed primary" 2 "Completed lower secondary" 3 "Completed upper secondary" 4 "Completed post-secondary" 
	label value hh_edu_head hh_edu_head
	sdecode hh_edu_head, replace 
	
	
	* Household Education 2: Get highest education of all household adults (using age, could have used relationship to head but age might be better)
		
	bysort hh_id: egen adult_eduyears = max(cond(hl6 >= 18 , eduyears, .))
	
	generate hh_edu_adult = 0
	foreach Z in prim lowsec upsec higher {
		replace hh_edu_adult = hh_edu_adult + 1  if adult_eduyears >= years_`Z'
				 	}
	label value hh_edu_adult hh_edu_head
	sdecode hh_edu_adult, replace 

	
	* Mother's education : use melevel variable otherwise
	
	gen female_eduyears = eduyears if hl4 == 2 // females
	bysort hh_id: egen women_eduyears = max(cond(hl6 >= 18 , female_eduyears, .)) //adult females
	drop female_eduyears
	
	generate hh_edu_women = 0
	foreach Z in prim lowsec upsec higher {
		replace hh_edu_women = hh_edu_women + 1  if women_eduyears >= years_`Z'
				 	}
	label value hh_edu_women hh_edu_head
	
	* "Household Education 8": Literate adult (25+ years old) in the family 
		capture confirm variable literacy_1549
	if !_rc {
	egen hh_edu8 = max(literacy_1549), by(hh_id)
               }
			   
	**/Household education**
	
	**Level attending: manipulating code_ed6a **
	
	label define level_attending_homogenized 0 "Preschool / No level" 1 "Primary" 2 "Secondary" 24 "Voc/tech/prof as upsec" 21 "Lower secondary" 22 	"Upper secondary" 23 "Voc/tech/prof as lowsec" 32 "post-secondary or superior no university" 33 "Voc/tech/prof as higher" 40 "Post graduate (master, PhD)" 41 "Master degree" 42 "PhD or doctoral degree" 50 "Special literacy program" 51 "Adult education" 60 "General school (ex. Mongolia, Turkmenistan)" 70 "Primary+lowsec (ex. Sudan & South Sudan)" 80 "Not formal/not regular/not standard" 90 "Coranique" 97 "Inconsistent" 98 "Don't know" 99 "NA / Missing"  3 "Higher", replace

	label values code_ed6a level_attending_homogenized

	clonevar level_attending = code_ed6a
	
		
	**/Level attending: manipulating code_ed6a **

	
	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
		
	*getting rid of unnecesary variables and ordering
	capture drop MWB14 WB14 old_ed3 old_ed4 old_ed5a old_ed5b old_ed6	old_ed7	old_ed8	old_ed9	old_ed10a old_ed10b	old_ed15 old_ed16a	old_ed16b	year_folder	ed4b_label	ed3_check	D	E	F	G	H	I	J	prim_dur_comp	lowsec_dur_comp	upsec_dur_comp	prim_age0_comp	prim_dur_replace lowsec_dur_replace	upsec_dur_replace	prim_age_replace	 
	capture order MMT* MT*  , last
	order hh1 hh2 hl1 country year ethnicity religion sex age location region wealth, first
	
	gen survey="MICS"
	compress
	* No saving, this will be done in update.ado		
	
end
