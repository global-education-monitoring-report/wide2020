* mics_read: program to read the MICS datasets and append all in one file
* Version 3.1
* May 2020

program define mics_read
	args data_path output_path nf country_name country_year
	
	local nf = `nf'+1
	* create folder
	cd "`output_path'"
	capture mkdir "`output_path'/MICS"
	cd "`output_path'/MICS"
	capture mkdir "`output_path'/MICS/data"
	cd "`output_path'/MICS/data"
	capture mkdir "`output_path'/MICS/data/temporal"
	findfile filenames.xlsx, path("`c(sysdir_personal)'/")
	import excel  "`r(fn)'", sheet(mics_hl_files) firstrow clear 
	local nrow: di _N + 1
	
	
	if (`nf' > `nrow') {
		import excel  "`r(fn)'", sheet(mics_hl_files) firstrow cellrange (:D`nrow') clear
	} 
	else{
		import excel  "`r(fn)'", sheet(mics_hl_files) firstrow cellrange (:D`nf') clear 
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
	
	cd "`data_path'/MICS"
	
	* read all files 
	foreach file of local filepath {

		*read a file
		use "`file'", clear
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
		tokenize `file', parse("/")
			generate country = "`1'" 
			generate year_folder = `3'
			
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
		
		if (year_folder >= 2017) {
			*egen year_folder = median(hh5y)

			drop ed3 ed7 
			rename ed4 ed3
			for X in any a b: rename ed5X ed4X

			rename ed9 ed5
			capture drop ed6a
			for X in any a b: rename ed10X ed6X

			rename ed15 ed7
			for X in any a b: rename ed16X ed8X

			rename ed8 ed3_check
			rename ed6 ed_completed 
			sdecode ed_completed, replace
		}
		
		*create numerics variables 
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
		capture renamefrom using "`r(fn)'", filetype(excel) if(!missing(rename)) raw(standard_name) clean(rename) label(varlab_en) keepx
						
		*compress and save each file in a temporal folder
		compress 
		save "`output_path'/MICS/data/temporal/`1'_`3'_hl", replace
	}

	* change dir to temporal folder
	cd "`output_path'/MICS/data/temporal"
    clear all
    	
	* append all files
	fs *.dta
	append using `r(files)', force
	compress
	save "`output_path'/MICS/data/mics_read.dta", replace
	
	set more off
	clear
	cd "`output_path'/MICS/data/"
	unicode analyze "mics_read.dta"
	unicode encoding set ibm-912_P100-1995
	unicode translate "mics_read.dta"
	
	* remove temporal folder and files
	rmfiles , folder("`output_path'/MICS/data/temporal") match("*.dta") rmdirs
	cd "`output_path'/MICS/data/"
	capture rmdir "temporal"
end
