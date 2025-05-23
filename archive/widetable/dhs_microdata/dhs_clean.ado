* dhs_clean: program to clean the data (fixing and recoding variables)
* Version 2.0
* April 2020

program define dhs_clean
	args output_path 
	
	*create auxiliary tempfiles from setcode table to fix values later
	local vars sex location date duration ethnicity region religion hv122 hv109 calendar calendar2
	findfile dhs_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	local dic `r(fn)'
	set more off
	
	foreach X in `vars'{
		import excel "`dic'", sheet(`X') firstrow clear 
		for Y in any sex_replace location_replace hv122_replace hv109_replace hv007: capture destring Y, replace
		tempfile fix`X'
		save `fix`X''
	}
	
	*fix some uis duration
	cd "`c(sysdir_personal)'/"
	*local uisfile : dir . files "UIS_duration_age_*.dta"
	*findfile `uisfile', path("`c(sysdir_personal)'/")
	findfile UIS_duration_age_25072018.dta, path("`c(sysdir_personal)'/")
	use "`r(fn)'", clear
	catenate country_year = country year, p("_")
	
	merge m:m iso_code3 year using `fixduration', keep(match master) keepusing(*_replace)
	replace prim_dur_uis   = prim_dur_replace[_n] if _merge == 3 & prim_dur_replace != .
	replace lowsec_dur_uis = lowsec_dur_replace[_n] if _merge == 3 & lowsec_dur_replace != .
	replace upsec_dur_uis  = upsec_dur_replace[_n] if _merge == 3 & upsec_dur_replace != .
	replace prim_age_uis   = prim_age0_replace[_n] if _merge == 3 & prim_age0_replace != .
	drop _merge *_replace
	tempfile fixduration_uis
	save `fixduration_uis'
	
	findfile country_iso_codes_names.dta, path("`c(sysdir_personal)'/")
	use "`r(fn)'", clear
	keep country_name_dhs country_code_dhs iso_code3 
	drop if country_code_dhs == ""
	tempfile isocode
	save `isocode'
		
	* read the master data
	use "`output_path'/DHS/data/dhs_read.dta", clear
	set more off

	*Fixing categories and creating variables
	replace hv007 = year_folder if hv007 < 1980
	replace_many `fixlocation' location location_replace
	replace_many `fixsex' sex sex_replace
	replace_many `fixhv109' hv109 hv109_replace
	replace_many `fixhv122' hv122 hv122_replace
	replace_many `fixregion' region region_replace country 
	replace_many `fixreligion' religion religion_replace
	replace_many `fixethnicity' ethnicity ethnicity_replace
	replace_many `fixdate' hv006 hv006_replace country_year
	replace_many `fixcalendar' hv007 hv007_replace country_year hv006
	replace_many `fixcalendar2' hv007 hv007_replace country_year 
	
	generate temp1 = substr(religion, 1, 7)
	replace religion = "pentecostal" if inlist(temp1, "penteco", "penteco")
	replace religion = "protestant" if inlist(temp1, "protest", "prostes")
	replace religion = "catholic" if temp1 == "roman c"
	replace religion = "seventh-day adventist" if temp1 == "seventh"
	replace religion = "traditional" if inlist(temp1, "taditio", "traditi")| religion == "tradicionalist"
	drop temp1
	
// 	foreach var of varlist ethnicity {
// 		replace `var' = subinstr(`var', " et ", " & ",.) 
// 		replace `var' = subinstr(`var', " and ", " & ",.)
// 		replace `var' = subinstr(`var', " ou ", "/",.)
// 	}
	replace region = subinstr(region, " ou ", "/",.)
	
	*local vars region ethnicity religion
	local vars region religion

	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = proper(`var')
		replace `var' = subinstr(`var', "'A", "'a",.) 
		replace `var' = subinstr(`var', "'I", "'i",.) 
		replace `var' = subinstr(`var', "-E", "-e",.) 
		replace `var' = subinstr(`var', "'D", "'d",.)
		replace `var' = subinstr(`var', "'S", "'s",.)
		replace `var' = subinstr(`var', "'T", "'t",.) 
		replace `var' = subinstr(`var', "'Z", "'z",.) 
	}
	
	if country == "Philippines" { 
		replace region = subinstr(region, "Ii ", "II ",.) 
		replace region = subinstr(region, "Iii ", "III ",.) 
		replace region = subinstr(region, "Iv ", "IV ",.) 
		replace region = subinstr(region, "Iva ", "IVa ",.) 
		replace region = subinstr(region, "Ivb ", "IVb ",.) 
		replace region = subinstr(region, "Vi ", "VI ",.) 
		replace region = subinstr(region, "Vii ", "VII ",.) 
		replace region = subinstr(region, "Viii ", "VIII ",.) 
		replace region = subinstr(region, "Ix ", "IX ",.) 
		replace region = subinstr(region, "Xi ", "XI ",.) 
		replace region = subinstr(region, "Xii ", "XII ",.) 
		replace region = subinstr(region, "Xiii ", "XIII ",.) 
	}
	if country == "DominicanRepublic" {
		replace region = subinstr(region, " Iii", " III",.) 
		replace region = subinstr(region, " Ii", " II",.) 
		replace region = subinstr(region, " Iv", " IV",.) 
		replace region = subinstr(region, " Viii", " VIII",.)
		replace region = subinstr(region, " Vii", " VII",.) 
		replace region = subinstr(region, " Vi", " VI",.) 
	}
	
	replace region = "DRD" if region == "Drd" & country == "Tajikistan"
	replace region = "NWFP" if region == "Nwfp"
	replace region = "SNNPR" if region == "Snnpr"
	
	* For Peru, we have to drop the observations for years not included in that country_year
	drop if inlist(hv007, 2003, 2004, 2005, 2006) & country_year == "Peru_2007" 
	
	 * Fix format of years
	foreach num of numlist 0/9 {   
		replace hv007 = 199`num' if hv007 == 9`num'
	}
	
	*Missing in the day or month of interview
	*Take the 1st of the month (Colombia_1990", Indonesia_1991, Indonesia_1994)
	replace hv016 = 1 if hv016 ==.  
	*Take the month in the middle of the 2 fieldwork dates (Colombia_1990)
	replace hv006 = 7 if hv006 == .  
		
	*Inconsistency in number of days for the month. 7567 cases
	replace hv016 = 30 if hv016 == 31 &  inlist(hv006, 4, 6, 9, 11)
	replace hv016 = 28 if hv016 >= 29 & hv006 == 2 
	replace hv016 = 31 if hv016 > 31 & inlist(hv006, 1, 3, 5, 7, 8, 10, 12)
	replace hv016 = 30 if hv016 > 31 & inlist(hv006, 4, 6, 9, 11)
	
	*Create the variable YEAR
	bys country_year: egen year = median(hv007)
	
	* Delete the countries that have the median year of 1999
	drop if year <= 1999 

	* Merge with Duration in years, start age and names of countries (codes_dhs, mics_dhs, iso_code, WIDE names)
	merge m:1 country_code_dhs using `isocode', keep(master match) nogenerate

	*Now we have year 2018, but the database of duration only has until 2017
	rename year year_original
	generate year = year_original
	replace year = 2017 if year_original >= 2018

	*FOR COMPLETION: Changes to match UIS calculations
	merge m:1 iso_code3 year using "`fixduration_uis'", keep(match master) nogenerate
	drop year 
	rename year_original year
	
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
	rename prim_age_uis prim_age0
	*drop lowsec_age_uis upsec_age_uis
	
	*Creating the variables for EDUOUT indicators
	for X in any prim_dur lowsec_dur upsec_dur: generate X_eduout = X 
	generate prim_age0_eduout = prim_age0
	
	* labelling
 	label define location 0 "Rural" 1 "Urban"
	label define sex 0 "Female" 1 "Male"
	label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
	for Z in any location sex wealth: capture label values Z Z


	compress 
	save "`output_path'/DHS/data/dhs_clean.dta", replace

end
