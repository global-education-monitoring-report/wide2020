* mics_standardize: program to calculate a standard dataset ready to be processed further in R
* Version 3.0
* May 2021
* Last update: added full_literacy 

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
			
		***IMPORTANT!!!! RENAME OF VARIABLES FOR MICS 6 SURVEYS only
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
    }
    else {
 		gen ed6a = old_ed10a
    }
 		*gen ed6b = old_ed10b
		gen ed7 = old_ed15
		gen ed8a = old_ed16a
 		gen ed8b = old_ed16b
 		gen ed3_check=old_ed8
 		gen ed_completed=old_ed6
		sdecode ed_completed, replace
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
		
		* create numerics variables 
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
	
	replace eduyears=ed4b+years_lowsec-3 if code_ed4a==22 & country_year=="Thailand_2019" // stair issue upsec
	replace eduyears=ed4b+years_upsec+6 if code_ed4a==41 & country_year=="Thailand_2019" // Master assuming 6 years of bachelor
	replace eduyears=ed4b+years_upsec+6+2 if code_ed4a==42 & country_year=="Thailand_2019" // Doctoral degree assuming 2 years of master

	* Recode for all country_years
	replace eduyears = 97 if code_ed4a == 97 | ed4b_label == "inconsistent" 
	replace eduyears = 98 if code_ed4a == 98 | ed4b_label == "don't know"
	replace eduyears = 99 if code_ed4a == 99 | inlist(ed4b_label, "missing", "doesn't answer", "missing/dk")
	replace eduyears = 0 if code_ed4a == 0
	replace eduyears = . if eduyears >= 99
	capture replace eduyears = eduyears - 1 if ed_completed == "no" & (eduyears <= 97)
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
	*******/HIGHER EDUCATION ATTENDANCE**********
	

	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
	*Now run the code to attach and merge the literacy variables
	
	destring year, replace
	
**************************** 	Adding extra modules section

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
			if _rc == 0 {
		   	*Adding this to check for the MASS MEDIA AND ICT module and capture it if variables exist
			 capture confirm variable MT2 
				if !_rc {
							di "Both literacy and mass media exist "
							keep iso_code3 year_folder HH1 HH2 LN WB14 WM6D WM6M WM6Y MT*
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

							capture confirm variable partofcountry
								if !_rc {
								keep iso_code3 year_folder sex hh1 hh2 hl1 partofcountry WB14 literacy full_literacy MT*
								}
								else {
								keep iso_code3 year_folder sex hh1 hh2 hl1 WB14 literacy MT* full_literacy
								}
				compress
					capture confirm variable partofcountry
					if !_rc {
					merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
					save "`output_path'/MICS/data/mics_standardize.dta", replace
					}
					else {
					merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
					save "`output_path'/MICS/data/mics_standardize.dta", replace
										}
						}
						
					else {
							di "Only literacy exists, keeping " "`f'"
							keep iso_code3 year_folder HH1 HH2 LN WB14 WM6D WM6M WM6Y 
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

							capture confirm variable partofcountry
								if !_rc {
								keep iso_code3 year_folder sex hh1 hh2 hl1 partofcountry WB14 literacy full_literacy
								}
								else {
								keep iso_code3 year_folder sex hh1 hh2 hl1 WB14 literacy full_literacy
								}
							compress
							tempfile wm_selection
							save "`wm_selection'"
							capture confirm variable partofcountry
								if !_rc {
								merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
								}
								else {
								merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
									}
			
							}
				   }
		else {
		 	  *Adding this in case only mass media ict exists
			 capture confirm variable MT2 
				if !_rc {
							keep iso_code3 year_folder HH1 HH2 LN MT* 
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

							capture confirm variable partofcountry
								if !_rc {
								keep iso_code3 year_folder sex hh1 hh2 hl1 partofcountry MT*
								}
								else {
								keep iso_code3 year_folder sex hh1 hh2 hl1 MT*
								}
							compress
							tempfile wm_selection
							save "`wm_selection'"
							capture confirm variable partofcountry
								if !_rc {
								merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
								}
								else {
								merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "C:\Users\taiku\Desktop\temporary_std\MICS\data\mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
									}
													}
					else {
							di "Clearing because neither literacy nor mass media/ict variables exists."
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
							keep iso_code3 year_folder HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4 MMT*
							
						}
					else {
							keep iso_code3 year_folder HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4
						}
					recode MWB14 (1 = 0) (2 3 = 1) (4 9 = .), gen(literacy)
					recode MWB14 (1 2 = 0) (3 = 1) (4 6 9 = .), gen(full_literacy)
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
					capture confirm variable partofcountry
						if !_rc {
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						}
						else {
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
 		  		   }
				   }
		else {
		 	  *Adding this in case only mass media ict exists
			 capture confirm variable MMT2 
				if !_rc {
							keep iso_code3 year_folder HH1 HH2 LN MMT*
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
							capture confirm variable partofcountry
								if !_rc {
								merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
								}
								else {
								merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
								save "`output_path'/MICS/data/mics_standardize.dta", replace
													}
					else {
							di "Clearing because neither literacy nor mass media/ict variables exists in " "`f'"
							clear
								}
			
			}
				
					}
			
         }
		 


else { 
    di "Men module not available in this survey"
} 
*end of mn extraction

****************

*begin of ch extraction 
cd "`data_path'\\`country_code'_`country_year'_MICS\"
  
capture confirm file ch.dta 
if _rc == 0 {
use "ch.dta", clear
gen iso_code3=upper("`country_code'")
generate year_folder = `country_year'
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
					keep iso_code3 year_folder hh1 hh2 hl1 EC* 
					
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
					capture confirm variable partofcountry
						if !_rc {
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						}
						else {
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
							}
				   }
		else {
							di "Clearing because Early Childhood Development submodule is not there"
							clear
								}
			
			}
				
	   
		 
else { 
    di "CH (children under the age of 5) module not available in this survey"
} 

*end of ch extraction

***************************

*begin of fs extraction
cd "`data_path'\\`country_code'_`country_year'_MICS\"
  
capture confirm file fs.dta 
if _rc == 0 {
use "fs.dta", clear
gen iso_code3=upper("`country_code'")
generate year_folder = `country_year'
   capture rename ln LN 
		   *Check for FOUNDATIONAL LEARNING SKILLS sub-module 
		   capture confirm variable FL1
			if _rc == 0 {
					capture rename ln LN
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
					keep iso_code3 year_folder hh1 hh2 hl1 FL*
					compress
					tempfile fs_selection
					save "`fs_selection'"
					capture confirm variable partofcountry
						if !_rc {
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 partofcountry using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
						}
						else {
						merge 1:1 iso_code3 year_folder hh1 hh2 hl1 using "`output_path'/MICS/data/mics_standardize.dta", nogenerate keep(match using) 
						save "`output_path'/MICS/data/mics_standardize.dta", replace
							}
				   }
		else {
							di "Clearing because Foundational Learning Skills submodule is not available"
							clear
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
		replace literacy_1549 = 1 if eduyears >= years_lowsec
		gen literacy_1524=literacy_1549 if age >= 15 & age <= 24
               }
	***/FINISH LITERACY CALCULATION***

              		
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
	
	**Household education**
	
	* "Household Education 1": At least one adult of the family has completed primary 
	egen hh_edu1 = max(comp_prim), by(hh_id)

	* "Household Education 2": At least one adult of the family has completed lower secondary
	egen hh_edu2 = max(comp_lowsec), by(hh_id) 

	* "Household Education 3": Most educated male in the family has at least primary
	gen male_comp_prim = comp_prim if sex=="Male"
	egen hh_edu3 = max(male_comp_prim), by(hh_id)
	drop male_comp_prim

	* "Household Education 4": Most educated female in the family has at least primary
	gen female_comp_prim = comp_prim if sex=="Female"
	egen hh_edu4 = max(female_comp_prim), by(hh_id)
	drop female_comp_prim

	* "Household Education 5": Most educated male in the family has at least lower secondary
	gen male_comp_lowsec = comp_lowsec if sex=="Male"
	egen hh_edu5 = max(male_comp_lowsec), by(hh_id)
	drop male_comp_lowsec

	* "Household Education 6": Most educated female in the family has at least lower secondary
	gen female_comp_lowsec = comp_lowsec if sex=="Female"
	egen hh_edu6 = max(female_comp_lowsec), by(hh_id)
	drop female_comp_lowsec
	
	* "Household Education 7": Most educated adult (25+ years old) in the family has at least lower secondary
	gen adult_comp_lowsec = comp_lowsec if age >= 25 
	egen hh_edu7 = max(adult_comp_lowsec), by(hh_id)
	drop adult_comp_lowsec
	
	* "Household Education 8": Literate adult (25+ years old) in the family 
		capture confirm variable literacy_1549
	if !_rc {
	egen hh_edu8 = max(literacy_1549), by(hh_id)
               }
		
	**/Household education**
	
	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
	
	*getting rid of unnecesary variables and ordering
	capture drop MWB14 WB14 old_ed3 old_ed4 old_ed5a old_ed5b old_ed6	old_ed7	old_ed8	old_ed9	old_ed10a old_ed10b	old_ed15 old_ed16a	old_ed16b	year_folder	ed4b_label	ed3_check	D	E	F	G	H	I	J	prim_dur_comp	lowsec_dur_comp	upsec_dur_comp	prim_age0_comp	prim_dur_replace lowsec_dur_replace	upsec_dur_replace	prim_age_replace	 
	capture order MMT* MT* , last
	order hh1 hh2 hl1 country year ethnicity religion sex age location region wealth, first
	
	gen survey="MICS"
	compress
	* No saving, this will be done in update.ado		
	
	
end
