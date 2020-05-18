* mics_read: program to read the MICS datasets and append all in one file
* Version 3.0
* April 2020

program define mics_read
	args data_path  nf

		
	* create folder
	capture mkdir "`data_path'/MICS/temporal"

	findfile filenames.xlsx, path("`c(sysdir_personal)'/")
	if (`nf'-1) > 69{
	import excel  "`r(fn)'", sheet(mics_hl_files) firstrow cellrange (:D69) clear 
	} 
	else{
	import excel  "`r(fn)'", sheet(mics_hl_files) firstrow cellrange (:D`nf') clear 
	}
	
	levelsof filepath, local(filepath) clean

	* create local macros from dictionary
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
		  
		*lowercase all variables
		capture rename *, lower
		capture rename *_* **
		
		*select common variables between the dataset and the mics dictionary (1st column)
		ds
		local datavars `r(varlist)'
		local common : list datavars & micsvars
		*display "`common'"
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
			capture drop windex5 region hh7
			capture rename windex5_5 windex5
		}
		if (country == "SaintLucia" & year_folder == 2012) {
			capture drop windex5
			capture rename windex51 windex5
		}
		
		for X in any hh7a hh7r: capture rename X region 
		for X in any region: capture rename X hh7
		for X in any 4 6 8: capture rename edXa edXa 
		for X in any 4 6 8: capture rename edXb edXb 
		for X in any ethnie ethnicidad: capture rename X ethnicity
		
		*create numerics variables 
		for X in any ed4a ed4b ed6a ed6b ed8a schage: capture generate X_nr = X
			
		* drop schage missing values 
		capture replace schage_nr = . if schage_nr >= 150
		capture drop schage
		capture rename schage_nr schage
		
		*decode and change strings values to lower case
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
			
		*create ids variables
		catenate country_year  = country year_folder, p("_")
		catenate hh_id 		   = country_year hh1 hh2, p(no) 
		catenate individual_id = country_year hh1 hh2 hl1, p(no)
			
		*create variables doesnt exist 
		for X in any `micsvars_keepnum': capture generate X = .
		for X in any `micsvars_keepstr': capture generate X = ""
		order `micsvars_keep'

		*rename some variables 
		findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
		capture renamefrom using "`r(fn)'", filetype(excel)  if(!missing(rename)) raw(standard_name) clean(rename) label(varlab_en) keepx
							
		*compress and save each file in a temporal folder
		compress 
		save "`data_path'/MICS/temporal/`1'_`3'_hl", replace
	}

	
	* change dir to temporal folder
	cd "`data_path'/MICS/temporal"
	
	* append all files
	fs *.dta
	append using `r(files)', force

	* remove temporal folder and files
	capture rmdir "`data_path'/MICS/temporal"

	* save all dataset in a single one
	compress
	save "`data_path'/MICS/mics_read.dta", replace

end
