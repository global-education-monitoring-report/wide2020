* mics_read: program to read the MICS datasets and append all in one file
* Version 2.0
* April 2020

program define mics_read
	args data_path table_path

	cd `data_path'

	local allfiles : dir . files "*.dta"
	
	* create folder
	capture mkdir "`data_path'/temporal"

	* mics variables to keep first
	import delimited "`table_path'/mics_dictionary.csv", clear varnames(1) encoding(UTF-8)
	preserve
	keep name 
	duplicates drop name, force
	sxpose, clear firstnames
	ds
	local micsvars `r(varlist)'

	* mics variables to decode
	restore
	preserve
	drop if encode != "decode"
	keep name_new
	sxpose, clear firstnames
	ds
	local micsvars_decode `r(varlist)'

	* mics variables to keep last
	restore
	preserve
	keep if keep == 1
	keep name_new
	sxpose, clear firstnames
	ds
	local micsvars_keep `r(varlist)'

	* mics numeric variables
	restore 
	preserve
	keep if numeric == 1 & keep == 1
	keep name_new
	sxpose, clear firstnames
	ds
	local micsvars_keepnum `r(varlist)'
		
	* mics string variables
	restore 
	keep if numeric == 0 & keep == 1
	keep name_new
	sxpose, clear firstnames
	ds
	local micsvars_keepstr `r(varlist)'
	
	* read all files 
	foreach file of local allfiles {

		*read a file
		use "`file'", clear
		  
		*lowercase all variables
		capture rename *, lower
			  
		*select common variables between the dataset and the mics dictionary (1st column)
		ds
		local datavars `r(varlist)'
		local common : list datavars & micsvars
		*display "`common'"
		keep `common'
		ds
			
		*rename 
		fix_names
				
		*generate variables with file name
		tokenize `file', parse("_")
			generate country = "`1'" 
			generate year_file = `3'
						
		*create numerics variables 
		for X in any ed4a ed4b ed6a ed6b ed8a schage: cap generate X_nr = X
			
		* drop schage missing values 
		cap replace schage_nr = . if schage_nr >= 150
		cap drop schage
		cap rename schage_nr schage
		
		*decode and change strings values to lower case
		local common_decode : list common & micsvars_decode
			
		* remove special character and space in string variables
		foreach var of varlist `common_decode'{ 
			cap tostring `var', replace
			cap sdecode  `var', replace
			cap replace  `var' = "missing" if `var' == ""
			cap replace  `var' = lower(`var')
			cap replace_character `var'
			cap replace  `var' = stritrim(`var')
			cap replace  `var' = strltrim(`var')
			cap replace  `var' = strrtrim(`var')
		 }
			
		*create ids variables
		catenate country_year  = country year_file, p("_")
		catenate hh_id 		   = country_year hh1 hh2, p(no) 
		catenate individual_id = country_year hh1 hh2 hl1, p(no)
			
		*create variables doesnt exist 
		for X in any `micsvars_keepnum': cap generate X = .
		for X in any `micsvars_keepstr': cap generate X = ""
		order `micsvars_keep'

		*rename some variables  (later "urban" is renamed "location". better to do it now)
		cap renamefrom using "`table_path'/mics_renamevars.csv", filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlab_en) keepx
					
		*compress and save each file in a temporal folder
		compress 
		save "`data_path'/temporal/`1'_`3'_hl", replace
	}

	
	* change dir to temporal folder
	cd `temporal_path'
	local allfiles : dir . files "*.dta", respectcase

	* append all files
	fs *.dta
	append using `r(files)', force

	* remove temporal folder and files
	capture rmdir "`data_path'/temporal"

	* save all dataset in a single one
	compress
	save "`data_path'/all/mics_read.dta", replace

end
