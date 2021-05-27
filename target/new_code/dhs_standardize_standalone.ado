* dhs_standardize: program to intake raw DHS surveys and standardize years of education, education completion and education out
* Version 4.0
* May 2021

program define dhs_standardize_standalone
	syntax, data_path(string) output_path(string) country_code(string) country_year(string) 

	*We need to merge IR, MR and PR files for each survey
	
	*Set up this temporal directory to then append the 3 modules
	cd "`output_path'"
	capture mkdir "`output_path'/DHS"
	cd "`output_path'/DHS/"
	capture mkdir "`output_path'/DHS/data"
	cd "`output_path'/DHS/data/"
	capture mkdir "`output_path'/DHS/data/temporal"
	
	findfile country_iso_codes_names.dta, path("`c(sysdir_personal)'/")
	use "`r(fn)'", clear
	keep country_name_dhs country_code_dhs country iso_code3 
	tempfile isocode
	save `isocode'
	
	
	local modules IR MR 
	* read IR and MR files to get ethnicity and religion
	if ("`country_name'" == "Nicaragua" | "`country_name'" == "VietNam" | "`country_name'" == "Yemen"){
	local modules ir
	}
	foreach module of local modules {
		cd "`output_path'/DHS/data/temporal/"
		capture mkdir "`output_path'/DHS/data/temporal/`module'"
		set more off
		
			*Old directory style
			cd  "`data_path'\\`country_code'_`country_year'_DHS\"
			local thefile : dir . files "??`module'????.DTA" 
			di `"`thefile'"'
			
			*read a file
			use *v001 *v002 *v130 *v131 *v150 *v155 using `thefile', clear
			set more off
			
			rename *, lower
			for X in any v001 v002 v130 v131 v150 v155: capture rename mX X
			for X in any v001 v002 v130 v131 v150 v155 : capture generate X=.
			
			* only keep the household head
			keep if v150 == 1 
			
// 			generate country = "`country_name'" 
// 			generate year_folder = `country_year'
// 			catenate country_year = country year_folder, p("_")
			catenate hh_id = v001  v002
			drop v150 v001 v002
			
			foreach var of varlist v130 v131{ 
				capture sdecode `var', replace
				capture replace `var' = lower(`var')
				capture replace_character `var'
				capture replace `var' = stritrim(`var')
				capture replace `var' = strltrim(`var')
				capture replace `var' = strrtrim(`var')
			}
			
			capture label drop _all
			compress
			
		capture save "`output_path'/DHS/data/temporal/dhs_`module'.dta" , replace
	}
	
	use "`output_path'/DHS/data/temporal/dhs_ir.dta", clear
	capture append using "`output_path'/DHS/data/temporal/dhs_mr.dta"
	
	erase "`output_path'/DHS/data/temporal/dhs_ir.dta"
	capture erase "`output_path'/DHS/data/temporal/dhs_mr.dta"
	
	rename v130 religion
	rename v131 ethnicity
	rename v155 literacy
	
	compress
	save "`output_path'/DHS/data/temporal/dhs_religion_ethnicity.dta", replace
	

	* create local macros from dictionary
	findfile dhs_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	import excel "`r(fn)'", sheet(dictionary) firstrow clear 
	* dhs variables to keep first
	levelsof name, local(dhsvars) clean
	* dhs variables to decode
	levelsof name if encode == "decode", local(dhsvars_decode) clean
	* dhs variables to keep last
	levelsof name if keep == 1, local(dhsvars_keep) clean 
	
	
			cd  "`data_path'\\`country_code'_`country_year'_DHS\"
			local prfile : dir . files "??pr????.DTA" 
			di `"`prfile'"' //substitutes first instance for Target filename pattern
	
		*read the pr module
		use `prfile', clear
		
		*lowercase all variables
		rename *, lower
						  
		*select common variables between the dataset and the DHS dictionary (1st column)
		ds
		local datavars `r(varlist)'
		local common : list datavars & dhsvars
		*display "`common'"
		keep `common'
		ds
		
		*generate variables with file name
// 		generate country = "`country_name'" 
// 		generate year_folder = `country_year'

		*create variables doesnt exist 
		for X in any `dhsvars_keep': capture generate X = .
		order `dhsvars_keep'
				
		*decode and change strings values to lower case
		local common_decode : list common & dhsvars_decode
					
		foreach var of varlist `common_decode'{ 
			capture sdecode `var', replace
			capture replace `var' = lower(`var')
			* remove special character in values and labels
			capture replace_character `var'
			capture replace `var' = stritrim(`var')
			capture replace `var' = strltrim(`var')
			capture replace `var' = strrtrim(`var')
		}
				
		*rename some variables 
		findfile dhs_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
		capture renamefrom using "`r(fn)'", filetype(excel)  if(!missing(rename)) raw(name) clean(rename) label(varlab_en) keepx
		
		*create numeric variables for easy recoding
		for X in any sex wealth location: generate X_n = X
		for X in any sex wealth location: drop X
		for X in any sex wealth location: rename X_n X
		
		gen iso_code3="`country_code'"
		merge m:1 iso_code3 using "`isocode'", keep(match) nogenerate
		rename country complete_country_name
		rename country_name_dhs country
		generate year_folder = `country_year'
		
		*create ids variables
		catenate country_year = country year_folder, p("_")
		
// 		* Country dhs code
// 		generate country_code_dhs = substr(hv000, 1, 2)

		*Round of DHS
		generate round_dhs = substr(hv000, 3, 1)
		replace round_dhs = "4" if country_year == "VietNam_2002"

		*Individual ids
		generate zero = string(0)
		*Special cases IDs for countries: Honduras_2005, Mali_2001, Peru_2012, Senegal_2005
		if (country_year == "Honduras_2005" | country_year == "Mali_2001" | country_year == "Peru_2012" | country_year == "Senegal_2005") {
			if hvidx <= 9 {
			catenate individual_id = country_year hhid zero hvidx 
			}
			else {
			catenate individual_id = country_year hhid hvidx 
			}
		}
		else {
			if hvidx <= 9 {
			catenate individual_id = country_year cluster hv002 zero hvidx 
			} 
			else {
			catenate individual_id = country_year cluster hv002 hvidx
			}
		}
		
		drop zero
		
		*Household ids
		catenate hh_id = cluster hv002 
		
		* add religion and ethnicity
		merge m:m hh_id using "`output_path'/DHS/data/temporal/dhs_religion_ethnicity.dta", keepusing (ethnicity religion literacy) keep(master match) nogenerate
					
		save "`output_path'/DHS/data/dhs_read.dta", replace

	set more off
	clear
	cd "`output_path'/DHS/data/"
	unicode analyze "dhs_read.dta"
	unicode encoding set ibm-912_P100-1995
	unicode translate "dhs_read.dta"
	
	* remove temporal folder and files
	rmfiles , folder("`output_path'/DHS/data/temporal/ir") match("*.dta") rmdirs
	capture rmfiles , folder("`output_path'/DHS/data/temporal/mr") match("*.dta") rmdirs
	rmfiles , folder("`output_path'/DHS/data/temporal") match("*.dta") rmdirs
	cd "`output_path'/DHS/data/"
	capture rmdir "temporal"
	
	
	*****************************CLEAN  OR DATA HOMOGENIZATION**********************************
	
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
	*replace_many `fixethnicity' ethnicity ethnicity_replace
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

	
	*****************************STANDARDIZE  OR INDICATOR CALCULATION**********************************
	
	* COMPUTE THE YEARS OF EDUCATION BY COUNTRY 
	
	use "`output_path'/DHS/data/dhs_clean.dta", clear
	set more off

	* Mix of years of education completed (hv108) and duration of levels 
	generate years_prim	= prim_dur
	generate years_lowsec = prim_dur + lowsec_dur
	generate years_upsec = prim_dur + lowsec_dur + upsec_dur
	*gen years_higher	=prim_dur+lowsec_dur+upsec_dur+higher_dur


	*Ages for completion
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur-1

	replace hv108 = hv107               if inlist(hv106, 0, 1) & country_year == "RepublicofMoldova_2005"
	replace hv108 = hv107 + years_prim  if hv106 == 2 & country_year == "RepublicofMoldova_2005"
	replace hv108 = hv107 + years_upsec if hv106 == 3 & country_year == "RepublicofMoldova_2005"
	replace hv108 = 98                  if hv106 == 8 & country_year == "RepublicofMoldova_2005"
	replace hv108 = 99                  if hv106 == 9 & country_year == "RepublicofMoldova_2005"

	*Changes to hv108 made in August 2019
	replace hv108 = . 	   if country_year == "Armenia_2005"
	replace hv108 = 0          if hv106 == 0 & country_year == "Armenia_2005"
	replace hv108 = hv107      if hv106 == 1 & country_year == "Armenia_2005"
	replace hv108 = hv107 + 5  if hv106 == 2 & country_year == "Armenia_2005"
	replace hv108 = hv107 + 10 if hv106 == 3 & country_year == "Armenia_2005"

	replace hv108 = .          if country_year == "Armenia_2010"
	replace hv108 = 0          if hv106 == 0 & country_year == "Armenia_2010"
	replace hv108 = hv107      if (hv106 == 1 | hv106 == 2) & country_year == "Armenia_2010"
	replace hv108 = hv107 + 10 if hv106 == 3 & country_year == "Armenia_2010"
	
	replace hv108 = .          if country_year == "Egypt_2008" | country_year == "Egypt_2014" 
	replace hv108 = 0          if hv106 == 0 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = hv107      if hv106 == 1 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = hv107 + 6  if hv106 == 2 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = hv107 + 12 if hv106 == 3 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = . if country_year == "Madagascar_2003"
	replace hv108 = 0          if hv106 == 0 & country_year == "Madagascar_2003"
	replace hv108 = hv107      if hv106 == 1 & country_year == "Madagascar_2003"
	replace hv108 = hv107 + 5  if hv106 == 2 & country_year == "Madagascar_2003"
	replace hv108 = hv107 + 12 if hv106 == 3 & country_year == "Madagascar_2003"
	
	replace hv108 = . if country_year == "Madagascar_2008"
	replace hv108 = 0          if hv106 == 0 & country_year == "Madagascar_2008"
	replace hv108 = hv107      if hv106 == 1 & country_year == "Madagascar_2008"
	replace hv108 = hv107 + 6  if hv106 == 2 & country_year == "Madagascar_2008"
	replace hv108 = hv107 + 13 if hv106 == 3 & country_year == "Madagascar_2008"

	replace hv108 = . if country_year == "Zimbabwe_2005"
	replace hv108 = 0          if hv106 == 0 & country_year == "Zimbabwe_2005" 
	replace hv108 = hv107      if hv106 == 1 & country_year == "Zimbabwe_2005"
	replace hv108 = hv107 + 7  if hv106 == 2 & country_year == "Zimbabwe_2005"
	replace hv108 = hv107 + 13 if hv106 == 3 & country_year == "Zimbabwe_2005"

	foreach X in prim lowsec upsec {
		generate comp_`X' = 0
		replace comp_`X'  = 1 if hv108 >= years_`X'
		replace comp_`X'  = . if (hv108 == . | hv108 >= 90) 
		replace comp_`X'  = 0 if (hv108 == 0 | hv109 == 0) 
	}
	
	replace comp_upsec = 0 if country_year == "Egypt_2005"
	replace comp_upsec = 1 if hv109 >= 4  & country_year == "Egypt_2005"
	replace comp_upsec = . if inlist(hv109, ., 8, 9) & country_year == "Egypt_2005"
	
	compress 
	save "`output_path'/DHS/data/dhs_standardize.dta", replace
	
	* ADJUST SCHOOL YEAR
	use "`output_path'/DHS/data/dhs_standardize.dta", clear
	set more off

	keep hv006 hv007 hv016 country year country_year iso_code3

	*Merge with info about reference school year
	*findfile current_school_year_DHS.dta, path("`c(sysdir_personal)'/")
	*merge m:1 country_year using  "`r(fn)'", keep(match master) nogenerate
	*drop yearwebpage currentschoolyearDHSreport
	gen school_year=.
	replace school_year=2017 if country=="Cameroon"
	replace school_year=2017 if country=="Jordan"
	replace school_year=2017 if country=="Senegal"
	replace school_year=2016 if country=="TimorLeste"
	replace school_year=2016 if country=="Uganda"
	replace school_year=2017 if country=="Pakistan"

	generate year_c = hv007
	replace year_c = 2017 if year_c >= 2018 
	findfile month_start.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 year_c using "`r(fn)'", keep(master match) nogenerate
	drop max_month min_month diff year_c

	*All countries have month_start. Malawi_2015 has now the month 9 (OK)
	rename school_year current_school_year

	*For those with missing in school year, I replace by the interview year
	generate missing_current_school_year = 1 if current_school_year == .
	replace current_school_year = hv007 if current_school_year == .

	* Adjustment VERSION 1: Difference in number of days 
	*-	Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
	*- Interview		: Month as presented in the survey data
		
	generate month_start_norm = month_start
		
	*Taking into account the days	
	generate one = string(1)
	for X in any norm max min: catenate s_school1_X = one month_start_X current_school_year, p("/")
	*date of the interview created with the original info
	catenate s_interview1 = hv016 hv006 hv007, p("/")  

	for X in any norm max min: generate date_school1_X = date(s_school1_X, "DMY", 2000) 
	generate date_interview1 = date(s_interview1, "DMY", 2000)
		
	*Without taking into account the days
	for X in any norm max min: catenate s_school2_X = month_start_X current_school_year, p("/")
	*date of the interview created with the original info
	catenate s_interview2 = hv006 hv007, p("/") 
		
	*official month of start... plus school year of reference
	for X in any norm max min: generate date_school2_X = date(s_school2_X, "MY", 2000) 
	generate date_interview2 = date(s_interview2, "MY", 2000)

	*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
	*Median difference is >=6.
	*50% of hh have 6 months of difference or more
	*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

	foreach M in norm max min {
		foreach X in 1 2 {
			generate diff`X'_`M' = (date_interview`X' - date_school`X'_`M')
			generate temp`X'_`M' = mod(diff`X'_`M', 365) 
			replace diff`X'_`M' = temp`X'_`M' if missing_current_school_year == 1
			bys country_year: egen median_diff`X'_`M' = median(diff`X'_`M')
			generate adj`X'_`M' = 0
			replace adj`X'_`M' = 1 if median_diff`X'_`M' >= 182
		}
	}

	hashsort country_year
	gcollapse diff* adj* flag_month, by(country_year)		
	save "`output_path'/DHS/data/dhs_adjustment.dta", replace
	
	* COMPUTE IF SOMEONE DOES NOT GO TO SCHOOL (education out)
	
	use "`output_path'/DHS/data/dhs_standardize.dta", clear
	set more off

	*Age
	replace age = . if age >= 98
	generate ageA = age - 1 
	rename age ageU

	*Attendance to higher educ
	recode hv121 (1/2=1) (8/9=.), generate(attend)
	
	*Out of school
	generate eduout = .
	replace eduout = 0 if inlist(hv121, 1, 2)
	replace eduout = 1 if hv121 == 0 
	replace eduout = . if ageU == .
	replace eduout = . if inlist(hv121, 8, 9, .)
	replace eduout = . if inlist(hv122, 8, 9) & eduout == 0 
	replace eduout = 1 if hv122 == 0

	* Completion indicators with age limits 
	foreach X in prim upsec {
		foreach AGE in ageU ageA {
			generate comp_`X'_v2_`AGE' = comp_`X' if `AGE' >= `X'_age1 + 3 & `AGE' <= `X'_age1 + 5 
		}
	}
	

	merge m:1 country_year using "`output_path'/DHS/data/dhs_adjustment.dta", keepusing(adj1_norm) keep(master match) nogenerate
	rename adj1_norm adjustment

	*Creating the appropiate age according to adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1

	*Dropping adjusted ages and the _ageU indicators (but keep ageU)
	capture drop *ageA *_ageU
	
	
	*******EDUYEARS AND LESS THAN 2/4 YEARS OF SCHOOLING********
	* create eduyears, max of years as 30 
	generate eduyears = hv108
	replace eduyears = . if hv108 >= 90
	replace eduyears = 30 if hv108 >= 30 & hv108 < 90
	
	foreach X in 4 {
		generate edu`X' = 0
			replace edu`X' = 1 if eduyears < `X'
			replace edu`X' = . if eduyears == .
	}
	
	*******/EDUYEARS AND LESS THAN 2/4 YEARS OF SCHOOLING********
	
		*******HIGHER COMPLETION********

	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = 1 if hv106 == 3
		replace comp_higher_`X'yrs = 0 if hv109 == 0
		replace comp_higher_`X'yrs = 0 if hv106 == 0 
	}
	replace comp_higher_2yrs = 1 if hv106==3
	replace comp_higher_4yrs = 1 if hv106==3

	replace comp_higher_2yrs = 1 if eduyears >= years_upsec + 2
	replace comp_higher_4yrs = 1 if eduyears >= years_upsec + 4
	
	

	*******/HIGHER COMPLETION********

	*******NEVER BEEN TO SCHOOL********
	* Never been to school
	recode hv106 (0 = 1) (1/3 = 0) (4/9 = .), generate(edu0)
	generate never_prim_temp = 1 if (hv106 == 0 | hv109 == 0) & (hv107 == . & hv123 == .)
	replace edu0 = 1 if eduyears == 0 | never_prim_temp == 1
	replace edu0 = . if eduyears == .

	*******/NEVER BEEN TO SCHOOL********

	*******ATTEND HIGHER AND EDUOUT********
	generate attend_higher = 0
	replace attend_higher = 1 if inlist(hv121, 1, 2) & hv122 == 3
	replace attend_higher = . if inlist(hv121, 8, 9) | inlist(hv122, 8, 9)

	*Durations for out-of-school
	generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
	keep country_year year age* iso_code3 hv007 sex location wealth religion ethnicity hhweight region comp_* eduout* attend* literacy cluster prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv122 hv123 hv124 years_*


	*******/ATTEND HIGHER AND EDUOUT********
	
	*******OVER AGE PRIMARY ATTENDANCE**********
	*Over-age primary school attendance
	*Percentage of children in primary school who are two years or more older than the official age for grade.
	gen overage2plus= 0 if attend==1 & inlist(hv122, 1)
	levelsof prim_dur, local(primyears)
	local i=0
    foreach grade of numlist 1/`primyears' {
				local i=`i'+1
				replace overage2plus=1 if hv123==`grade' & agestandard>prim_age0+1+`i' & overage2plus!=. 
                 }
	*******/OVER AGE PRIMARY ATTENDANCE**********

	
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = "" if `var' == "."
	}
	
	rename ageU age
	gen schage=agestandard
	
	*******LITERACY**********
	*Literacy
	recode literacy (0 = 0) (1 2 = 1) (3 4 = .)
	*1 cannot read at all
	*2 able to read only parts or whole sentence
	*3 no card with required language
	*4 blind/visually impaired
	gen literacy_1524=literacy if age >= 15 & age <= 24
	replace literacy_1524=1 if eduyears >= years_lowsec & (age >= 15 & age <= 24)
	*******/LITERACY**********

	drop round_dhs lowsec_age_uis upsec_age_uis
	gen survey="DHS"
	*get useful local
	compress
	
	
end
