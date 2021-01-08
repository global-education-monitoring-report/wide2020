* dhs_read: program to read the datasets and append all in one file
* Version 2.1
* April 2020

program define dhs_read
	args data_path output_path nf country_name country_year

	local nf = `nf'+1
	* read IR and MR files to get ethnicity and religion
	local modules ir mr 
	cd "`output_path'"
	capture mkdir "`output_path'/DHS"
	cd "`output_path'/DHS/"
	capture mkdir "`output_path'/DHS/data"
	cd "`output_path'/DHS/data/"
	capture mkdir "`output_path'/DHS/data/temporal"

	if ("`country_name'" == "Nicaragua" | "`country_name'" == "VietNam" | "`country_name'" == "Yemen"){
	local modules ir
	}
	foreach module of local modules {
		cd "`output_path'/DHS/data/temporal/"
		capture mkdir "`output_path'/DHS/data/temporal/`module'"
		set more off
		
		findfile filenames.xlsx, path("`c(sysdir_personal)'/")
		import excel "`r(fn)'", sheet(dhs_`module'_files) firstrow clear 
		local nrow: di _N + 1
		
		if (`nf' > `nrow') {
			import excel  "`r(fn)'", sheet(dhs_`module'_files) firstrow cellrange (:D`nrow') clear
		} 
		else{
			import excel  "`r(fn)'", sheet(dhs_`module'_files) firstrow cellrange (:D`nf') clear 
		}
		levelsof filepath, local(filepath) clean
		
		if ("`country_name'" != "") {
			capture keep if folder_country == "`country_name'"
			capture levelsof filepath, local(filepath) clean
		}
		if ("`country_name'" != "" & "`country_year'" != "") {
			capture tostring folder_year, replace
			capture keep if (folder_country == "`country_name'" & folder_year == "`country_year'")
			capture levelsof filepath, local(filepath) clean
		}
	
	
		foreach file of local filepath {
			cd "`data_path'/DHS/"
			*read a file
			use *v001 *v002 *v130 *v131 *v150 *v155 using "`file'", clear
			set more off
			
			rename *, lower
			for X in any v001 v002 v130 v131 v150 v155: capture rename mX X
			for X in any v001 v002 v130 v131 v150 v155 : capture generate X=.
			
			* only keep the household head
			keep if v150 == 1 
			
			tokenize "`file'", parse("/")
			generate country = "`1'" 
			generate year_folder = `3'
			catenate country_year = country year_folder, p("_")
			catenate hh_id = country_year v001  v002
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
			save "`output_path'/DHS/data/temporal/`module'/`1'_`3'", replace
			
		}
		
		cd "`output_path'/DHS/data/temporal/`module'/"
	    clear all
		fs *.dta
		append using `r(files)', force
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

	
	* read pr files
	findfile filenames.xlsx, path("`c(sysdir_personal)'/")
	import excel  "`r(fn)'", sheet(dhs_pr_files) firstrow clear 
	local nrow: di _N
	if (`nf' > `nrow') {
		import excel  "`r(fn)'", sheet(dhs_pr_files) firstrow cellrange (:D`nrow') clear 
	} 
	else{
		import excel  "`r(fn)'", sheet(dhs_pr_files) firstrow cellrange (:D`nf') clear 
	}
	levelsof filepath, local(filepath) clean
	
	if ("`country_name'" != "") {
			keep if folder_country == "`country_name'"
			levelsof filepath, local(filepath) clean
	}
	if ("`country_name'" != "" & "`country_year'" != "") {
			tostring folder_year, replace
			keep if (folder_country == "`country_name'" & folder_year == "`country_year'")
			levelsof filepath, local(filepath) clean
	}

	
	* create local macros from dictionary
	findfile dhs_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	import excel "`r(fn)'", sheet(dictionary) firstrow clear 
	* dhs variables to keep first
	levelsof name, local(dhsvars) clean
	* dhs variables to decode
	levelsof name if encode == "decode", local(dhsvars_decode) clean
	* dhs variables to keep last
	levelsof name if keep == 1, local(dhsvars_keep) clean 
	
	cd "`data_path'/DHS/"
	
	* read all files 
	foreach file of local filepath {

		*read a file
		use "`file'", clear

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
		tokenize `file', parse("/")
			generate country = "`1'" 
			generate year_folder = `3'

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
		
		*create ids variables
		catenate country_year = country year_folder, p("_")
		
		* Country dhs code
		generate country_code_dhs = substr(hv000, 1, 2)

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
		catenate hh_id = country_year cluster hv002 
		
		* add religion and ethnicity
		merge m:m hh_id using "`output_path'/DHS/data/temporal/dhs_religion_ethnicity.dta", keepusing (ethnicity religion literacy) keep(master match) nogenerate
					
		*save each file in temporal folder
		compress 
		save "`output_path'/DHS/data/temporal/`1'_`3'_pr.dta", replace
}

	cd "`output_path'/DHS/data/temporal/"
	erase "`output_path'/DHS/data/temporal/dhs_religion_ethnicity.dta"
	clear all

	* append all the datasets
	fs *.dta
	append using `r(files)', force
	compress
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
end



