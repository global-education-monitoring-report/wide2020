* dhs_standardize: program to intake raw DHS surveys and standardize years of education, education completion and education out
* Version 4.0
* May 2021
* Update 19/07: Added full_literacy, literacy, eduout_preprim and ECDI calculation (for this install addon filename)
* Update 27/07: Added attend_higher_5 eduout_preprim
* Update 29/11: Fix literacy uptake from IR and MR
* Update 02/aug/22: introduce relationship to head into std file (hv101), through excel dictionary setcode file 


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
	
	local modules ir mr 
	* read IR and MR files to get ethnicity and religion
	if ("`country_name'" == "Nicaragua" | "`country_name'" == "VietNam" | "`country_name'" == "Yemen"){
	local modules ir
	}
	foreach module of local modules {
		cd "`output_path'/DHS/data/temporal/"
		capture mkdir "`output_path'/DHS/data/temporal/`module'"
		set more off
		
			*NEW directory style
			cd  "`data_path'\\`country_code'_`country_year'_DHS\"
			local thefile : dir . files "??`module'????.DTA" 
			di `thefile'
			*This is to avoid problems where one module is not available
				if missing(`"`thefile'"') { 
				di "There is no " "`module'" " module available for this survey."
						clear
												} 
				else {
						**read a file
							use *v001 *v002 *v130 *v131 *v150  using `thefile', clear
							set more off
							
							rename *, lower
							for X in any v001 v002 v130 v131 v150 : capture rename mX X
							for X in any v001 v002 v130 v131 v150 : capture generate X=.
							
							* only keep the household head
							keep if v150 == 1 
							
							catenate hh_id = v001 v002
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
			
			
	}
	
	capture use "`output_path'/DHS/data/temporal/dhs_ir.dta", clear
	capture append using "`output_path'/DHS/data/temporal/dhs_mr.dta"
	
	capture erase "`output_path'/DHS/data/temporal/dhs_ir.dta"
	capture erase "`output_path'/DHS/data/temporal/dhs_mr.dta"
	
	rename v130 religion
	rename v131 ethnicity
	
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
		
		gen iso_code3=upper("`country_code'")
		merge m:1 iso_code3 using "`isocode'", keep(match) nogenerate
		rename country complete_country_name
		rename country_name_dhs country
		generate year_folder = `country_year'
		
		*create ids variables
		catenate country_year = country year_folder, p("_")
		
// 		* Country dhs code
// 		generate country_code_dhs = substr(hv000, 1, 2)

		*Round of DHS
		generate round = substr(hv000, 3, 2)
		replace round = "4" if country_year == "VietNam_2002"

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
		if (country_year == "Honduras_2005" | country_year == "Mali_2001" | country_year == "Peru_2012" | country_year == "Senegal_2005") {
			catenate hh_id = hv001 hv002 
		}
		else {
			catenate hh_id = cluster hv002 
		}
		
		
		* add religion and ethnicity
		merge m:m hh_id using "`output_path'/DHS/data/temporal/dhs_religion_ethnicity.dta", keepusing (ethnicity religion) keep(master match) nogenerate
		*Make id to merge with BR
		catenate newid = hh_id hvidx
	
		save "`output_path'/DHS/data/dhs_read.dta", replace
		
		*¡NEW! Adding the BR (Birth recode) module to get early child development index (ECDI)*
		
		cd  "`data_path'\\`country_code'_`country_year'_DHS\"
			local brfile : dir . files "??br????.DTA" 
			di `"`brfile'"' //substitutes first instance for Target filename pattern
			
			*This is to avoid problems where one module is not available
				if missing(`"`brfile'"') { 
				di "There is no BR module available for this survey."
									} 
				else {
				use `brfile', clear
						*First: check if relevant ECDI variables exist 
						*findit findname
						 findname, varlabeltext("*kick*bite*") local(ecd9)
						 if missing(`"`ecd9'"') { 
							di "There are no ECDI variables available in this survey"
							use "`output_path'/DHS/data/dhs_read.dta", clear
									} 
						else {
							*Second: find all the variables needed
							findname, varlabeltext("*alphabet*") local(ecd1)
							if missing(`"`ecd1'"') { 
							findname, varlabeltext("*letters*") local(ecd1)
									}
							findname, varlabeltext("*can*read*") local(ecd2)
							if missing(`"`ecd2'"') { 
							findname, varlabeltext("*reads*words*") local(ecd2)
									}
																
							findname, varlabeltext("*recognize*number*") local(ecd3)
							if missing(`"`ecd3'"') { 
									findname, varlabeltext("*identif*number*") local(ecd3)
									if missing(`"`ecd3'"') { 
										findname, varlabeltext("*cite*figure*") local(ecd3)
										if missing(`"`ecd3'"') { 
										findname, varlabeltext("*knows*numbers*") local(ecd3)
											if missing(`"`ecd3'"') { 
											findname, varlabeltext("*1*to*10*") local(ecd3)
											}
									}
									}
									}
							findname, varlabeltext("*two*fingers*") local(ecd4)
							if missing(`"`ecd4'"') { 
							findname, varlabeltext("*finger*object*") local(ecd4)
								if missing(`"`ecd4'"') { 
							findname, varlabeltext("*small*object*") local(ecd4)
									}
									}
							findname, varlabeltext("*sick*play*") local(ecd5)
							if missing(`"`ecd5'"') { 
							findname, varlabeltext("*ill*play*") local(ecd5)
									}
							findname, varlabeltext("*follow*direc*") local(ecd6)
							if missing(`"`ecd6'"') { 
							findname, varlabeltext("*follow*instruc*") local(ecd6)
									}
							findname, varlabeltext("*independent*") local(ecd7)
							findname, varlabeltext("*along*with*children*") local(ecd8)
							if missing(`"`ecd8'"') { 
							findname, varlabeltext("*along*with*others*") local(ecd8)
								if missing(`"`ecd8'"') { 
								findname, varlabeltext("*agrees*with*others*") local(ecd8)
									if missing(`"`ecd8'"') { 
									findname, varlabeltext("*gets*well*other*") local(ecd8)
									}
								}
									}
							findname, varlabeltext("*kick*bite*other*") local(ecd9)
							findname, varlabeltext("*distracted*") local(ecd10)
						
														
							* recode identifies letters, reads 4 simple words, knows numbers, 
							* recode able to pick up object, can follow instructions, communicate sth independently, gets along w others
							for X in any `ecd1' `ecd2' `ecd3' `ecd4' `ecd6' `ecd7' `ecd8' : recode X (2=0) (8/9=.)
							* recode too sick to play , kick bites or hits others , distracted easily
							for X in any `ecd5' `ecd9'  `ecd10': recode X (1=0) (2 0=1) (8/9=.)

							 ** Literacy & numeracy (identifies at least 10 letters of alphabet / reads 4 simple words / knows numbers 1-10)
							 gen sum_litnum =  `ecd1' + `ecd2' + `ecd3'
							 gen litnum=0
							 replace litnum=1 if sum_litnum>=2 & sum_litnum!=.
							 replace litnum=. if  `ecd1'==. & `ecd2'==. & `ecd3'==.
							 ** Physical (able to pick up small object / too sick to play)
							gen physical=0
							replace physical=1 if `ecd4'==1 | `ecd5'==1
							replace physical=. if `ecd4'==. & `ecd5'==.
							** Learning (can follow instructions / able to do something independently)
							gen learns=0
							replace learns=1 if `ecd6'==1 | `ecd7'==1
							replace learns=. if `ecd6'==. & `ecd7'==.
							** SocioEm (gets along w other children / kicks bites or hits others / distracted easily )
							 gen sum_socioem = `ecd8' +  `ecd9' +  `ecd10'
							 gen socioem=0
							 replace socioem=1 if sum_socioem>=2 & sum_socioem!=.
							 replace socioem=. if `ecd8'==. &  `ecd9'==. &  `ecd10'==.
							**** ECD index!
								gen sum_ecd=litnum+physical+learns+socioem
								gen ecd=0
								replace ecd=1 if sum_ecd>=3 & sum_ecd!=.
								replace ecd=. if litnum==. & physical==. & learns==. & socioem==.
								drop sum_*
								
						*Keep only needed variables		
						 keep v001 v002 b16 litnum physical learns socioem ecd
						*Get rid of observations whose line number is not listed in household, this implies getting rid of dead children
						drop if b16==0 | b16==.
						*Prepare for merge, forcing removal of duplicates 
						catenate hh_id = v001 v002
						catenate newid =  hh_id b16
						duplicates drop hh_id newid, force
						*Merge n save 
						merge 1:1 hh_id newid using "`output_path'/DHS/data/dhs_read.dta", nogenerate
						save "`output_path'/DHS/data/dhs_read.dta", replace
						}
									

				}
				
				*NEW! Literacy intake from IR and MR but merge on an indivual level 
				
	local modules ir mr 
	* read IR and MR files to get literacy
	if ("`country_name'" == "Nicaragua" | "`country_name'" == "VietNam" | "`country_name'" == "Yemen"){
	local modules ir
	}
	foreach module of local modules {
		cd "`output_path'/DHS/data/temporal/"
		capture mkdir "`output_path'/DHS/data/temporal/`module'"
		set more off
		
			*NEW directory style
			cd  "`data_path'\\`country_code'_`country_year'_DHS\"
			local thefile : dir . files "??`module'????.DTA" 
			di `thefile'
			*This is to avoid problems where one module is not available
				if missing(`"`thefile'"') { 
				di "There is no " "`module'" " module available for this survey."
						clear
												} 
				else {
						**read a file
							use *v001 *v002 *v003 *v155 using `thefile', clear
							set more off
							
							rename *, lower
							for X in any  *v001 *v002 *v003 *v155: capture rename mX X
							for X in any v001 v002 v003 v150 v155 : capture generate X=.
							
							*IR works, MR works
							catenate hh_id = v001 v002
							catenate newid =  hh_id v003
						
						compress
							
						capture save "`output_path'/DHS/data/temporal/dhs_`module'.dta" , replace
						
						capture use "`output_path'/DHS/data/temporal/dhs_ir.dta", clear
						capture append using "`output_path'/DHS/data/temporal/dhs_mr.dta"
		
						capture erase "`output_path'/DHS/data/temporal/dhs_ir.dta"
						capture erase "`output_path'/DHS/data/temporal/dhs_mr.dta"
						
						rename v155 literacy
						
						compress
	
						*Merge, double checking for duplicates that arise in older DHS
						duplicates drop hh_id newid, force
						merge 1:1 hh_id newid using "`output_path'/DHS/data/dhs_read.dta", nogenerate
						save "`output_path'/DHS/data/dhs_read.dta", replace
						set more off
										
				} 
			
			
	}
	
	
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
	
	
	*****************************CLEAN OR DATA HOMOGENIZATION**********************************
	
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
	findfile UIS_duration_age_30082021.dta, path("`c(sysdir_personal)'/")
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
	
	*******LEVEL ATTENDING THE CURRENT YEAR********
	clonevar level_attending = hv122
	*0 not attending, preschool
	*1 primary
	*2 secondary
	*3 higher
	*8 dk
	*9 na (?)

	*Fixing categories and creating variables
	replace hv007 = year_folder if hv007 < 1980
	replace_many `fixlocation' location location_replace
	replace_many `fixsex' sex sex_replace
	replace_many `fixhv109' hv109 hv109_replace
	replace_many `fixhv122' hv122 hv122_replace
	replace_many `fixregion' region region_replace country 
	replace_many `fixreligion' religion religion_replac
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
	*BIG assumption for HH_EDU purposes: higher duration is of 3 years 
	gen higher_dur = 3
	gen years_higher	=prim_dur+lowsec_dur+upsec_dur+higher_dur


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
	
	*Eduout alternative version that considers children in preschool *NOT* out of school
	generate eduout_preprim = eduout 
	replace eduout_preprim = 0 if hv122 == 0 & hv121 == 2 

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
	
	generate attend_higher_5 = attend_higher if agestandard >= upsec_age1 + 1 & agestandard <= upsec_age1 + 5

	*Durations for out-of-school
	generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
	
	
		capture confirm variable hdis1
					if !_rc {
		unab disabilityvars : hdis*
        display "`disabilityvars'
		 					}
	
	capture confirm variable ecd
								if !_rc {
	keep country_year year age* iso_code3 hv007 sex location wealth religion ethnicity hhweight region comp_* eduout* attend* literacy cluster prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv101 hv122 hv123 hv124 years_* ecd*  `disabilityvars'
								}
								else {
	keep country_year year age* iso_code3 hv007 sex location wealth religion ethnicity hhweight region comp_* eduout* attend* literacy cluster prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv101 hv122 hv123 hv124 years_*  `disabilityvars'
								}
	
	


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
	rename literacy original_literacy
	recode original_literacy (0 1 = 0) (2 = 1) (3 4 9 = .), gen(full_literacy)
	recode original_literacy (0 = 0) (1 2 = 1) (3 4 9 = .), gen(literacy_1549)
	recode original_literacy (0 = 0) (1 2 = 1) (3 4 9 = .), gen(literacy)
	*0 cannot read at all
	*1 able to read only parts or whole sentence
	*2 able to read whole sentence 
	*3 no card with required language
	*4 blind/visually impaired
	*9 missing(?)
	replace literacy_1549=1 if eduyears >= years_lowsec & (age >= 15 & age <= 49)
	gen literacy_1524=literacy if age >= 15 & age <= 24
	replace literacy_1524=1 if eduyears >= years_lowsec & (age >= 15 & age <= 24)
	*******/LITERACY**********
	
	
	******DISABILITY**********

	*Now rename the AF* 
	rename hdis2 Vision 
	rename hdis4 Hearing 
	rename hdis7 Mobility // mobility = walking or climbing steps
	rename hdis6 Cognition // COGNITION=REMEMBERING OR CONCENTRATING
	rename hdis8 Self_Care // washing all over or dressing
	rename hdis5 Communication

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
	
	gen Disability_adults=0
	replace Disability_adults=1 if (inlist(Vision,3,4) | inlist(Hearing,3,4) | inlist(Mobility,3,4) | ///
	inlist(Communication,3,4) | inlist(Self_Care,3,4) | inlist(Cognition,3,4))
	replace Disability_adults=. if missing(Vision) & missing(Hearing) & missing(Mobility) & ///
	missing(Cognition) & missing(Self_Care) & missing(Communication)
	capture label define difficulty 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 

	label value Disability_adults difficulty
	
		******/DISABILITY**********

	********HOUSEHOLD EDUCATION*******
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
	
	bysort hh_id: egen head_eduyears = total(cond(hv101 == 1 , eduyears, .))
	
	generate hh_edu_head = 0
	foreach Z in prim lowsec upsec higher {
		replace hh_edu_head = hh_edu_head + 1  if head_eduyears >= years_`Z'
				 	}
	label define hh_edu_head 0 "Not completed any level of education" 1 "Completed primary" 2 "Completed lower secondary" 3 "Completed upper secondary" 4 "Completed post-secondary" 
	label value hh_edu_head hh_edu_head
	
	* Household Education 2: Get highest education of all household adults (using age, could have used relationship to head but age might be better)
		
	bysort hh_id: egen adult_eduyears = max(cond(age >= 18 , eduyears, .))
	
	generate hh_edu_adult = 0
	foreach Z in prim lowsec upsec higher {
		replace hh_edu_adult = hh_edu_adult + 1  if adult_eduyears >= years_`Z'
				 	}
	label value hh_edu_adult hh_edu_head
	
	* Mother's education : use melevel variable otherwise
	
	gen female_eduyears = eduyears if sex == "Female" // females
	bysort hh_id: egen women_eduyears = max(cond(age >= 18 , female_eduyears, .)) //adult females
	drop female_eduyears
	
	generate hh_edu_women = 0
	foreach Z in prim lowsec upsec higher {
		replace hh_edu_women = hh_edu_women + 1  if women_eduyears >= years_`Z'
				 	}
	label value hh_edu_women hh_edu_head
	
				   
	**/Household education**
	*********/HOUSEHOLD EDUCATION*******

		

	gen survey="DHS"
	compress
	
	
end
