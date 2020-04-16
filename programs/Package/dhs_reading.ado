* dhs_reading: program to read the datasets and append all in one file
* Version 1.0
* April 2020

program define dhs_reading
	args input_path tables_path uis_path output_path 

	cd `input_path'

	* Reading individual datasets and appending them all

	local allfiles : dir . files "*.dta"

	capture mkdir "`temporal_path'"
	
	* DHS variables to keep first
	import delimited "`dictionary'", clear varnames(1) encoding(UTF-8)
	preserve
	keep name 
	duplicates drop name, force
	sxpose, clear firstnames
	ds
	local dhsvars `r(varlist)'

	* DHS variables to decode
	restore
	preserve
	drop if encode != "decode"
	keep name_new
	sxpose, clear firstnames
	ds
	local dhsvars_decode `r(varlist)'

	* DHS variables to keep last
	restore
	keep if keep == 1
	keep name_new
	sxpose, clear firstnames
	ds
	local dhsvars_keep `r(varlist)'
	
	* read all files 
	foreach file of local allfiles {

	  *read a file
	  use "`file'", clear
	  
	  *lowercase all variables
	  capture rename *, lower
	  
	  
		*select common variables between the dataset and the mics dictionary (1st column)
		ds
		local datavars `r(varlist)'
		local common : list datavars & dhsvars
		*display "`common'"
		keep `common'
		ds
		
		*rename 
		*fix_names
			
		*generate variables with file name
		tokenize `file', parse("_")
			generate country = "`1'" 
			generate year_file = `3'
		
		
		*create variables doesnt exist 
		for X in any `dhsvars_keep': cap gen X=.
		order `dhsvars_keep'
		
		*create numerics variables 
		*for X in any ed4a ed4b ed6a ed6b ed8a: gen X_rn = X
		
		*decode and change strings values to lower case
		local common_decode : list common & dhsvars_decode
			
		foreach var of varlist `common_decode'{ 
			cap sdecode `var', replace
			cap tostring `var', gen(temp_`var')
			drop `var'
			cap rename temp_`var' `var'
			cap replace `var' = lower(`var')
			* remove special character in values and labels
			cap	replace_character
			cap replace `var' = stritrim(`var')
			cap replace `var' = strltrim(`var')
			cap replace `var' = strrtrim(`var')
		 }
		 		
		
		*create ids variables
		*ssc install catenate
		*catenate country_year  = country year_file, p("_")
		*catenate individual_id = country_year hh1 hh2 hl1, p(no)
		*catenate hh_id         = country_year hh1 hh2, p(no) 

		*rename some variables  (later "urban" is renamed "location". better to do it now)
		*renamefrom using `rename', filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlab_en) keepx
		
		*save each file in temporal folder
		compress 
		save "`temporal_path'/`1'_`3'_hl", replace
}

	cd `temporal_path'
	local allfiles : dir . files "*.dta", respectcase

	* append all the datasets
	* ssc install fs 
	fs *.dta
	append using `r(files)', force


	* remove temporal folder and files
	capture rmdir "`temporal_path'"

	* save all dataset in a single one
	compress
	save "`output_path'/dhs_reading.dta", replace

end

