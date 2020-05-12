* mics_read: program to read the MICS datasets and append all in one file
* Version 3.0
* April 2020

program define mics_read
	args data_path table_path

		
	* create folder
	capture mkdir "`data_path'/temporal"

	import excel "`table_path'/filenames.xlsx", sheet(mics_hl_files) firstrow clear 
	levelsof filepath, local(filepath) clean

	* create local macros from dictionary
	import excel "`table_path'/mics_dictionary_setcode.xlsx", sheet(dictionary) firstrow clear 
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
	
	
	cd `data_path'
	
	* read all files 
	foreach file of local filepath {

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
		tokenize `file', parse("/")
			generate country = "`1'" 
			generate year_folder = `3'
						
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
		catenate country_year  = country year_folder, p("_")
		catenate hh_id 		   = country_year hh1 hh2, p(no) 
		catenate individual_id = country_year hh1 hh2 hl1, p(no)
			
		*create variables doesnt exist 
		for X in any `micsvars_keepnum': cap generate X = .
		for X in any `micsvars_keepstr': cap generate X = ""
		order `micsvars_keep'

		*rename some variables 
		cap renamefrom using "`table_path'/mics_dictionary_setcode.xlsx", filetype(excel)  if(!missing(rename)) raw(standard_name) clean(rename) label(varlab_en) keepx
							
		*compress and save each file in a temporal folder
		compress 
		save "`data_path'/temporal/`1'_`3'_hl", replace
	}

	
	* change dir to temporal folder
	cd "`data_path'/temporal"
	
	* append all files
	fs *.dta
	append using `r(files)', force

	* remove temporal folder and files
	capture rmdir "`data_path'/temporal"

	* save all dataset in a single one
	compress
	save "`data_path'/mics_read.dta", replace

end
