* dhs_read: program to read the datasets and append all in one file
* Version 1.0
* April 2020

program define dhs_read
	args input_path temporal_path output_path table1_path table2_path

	cd `input_path'

	* Reading individual datasets and appending them all

	local allfiles : dir . files "*.dta"

	capture mkdir "`temporal_path'"
	
	* DHS variables to keep first
	import delimited "`table1_path'", clear varnames(1) encoding(UTF-8)
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
						
		*generate variables with file name
		tokenize `file', parse("_")
		generate country = "`1'" 
		generate year_file = `3'
				
				
		*create variables doesnt exist 
		for X in any `dhsvars_keep': cap gen X=.
		order `dhsvars_keep'
				
		*decode and change strings values to lower case
		local common_decode : list common & dhsvars_decode
					
		foreach var of varlist `common_decode'{ 
			cap sdecode `var', replace
			cap replace `var' = lower(`var')
			* remove special character in values and labels
			cap replace_character
			cap replace `var' = stritrim(`var')
			cap replace `var' = strltrim(`var')
			cap replace `var' = strrtrim(`var')
		}
				
		*rename some variables
		*renamefrom using "`table2_path'", filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlab_en) keepx
		renamefrom using "$aux_data_path/dhs_renamevars.csv", filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlab_en) keepx
		
		*create numeric variables for easy recoding
		for X in any sex wealth location: gen X_n = X
		for X in any sex wealth location: rename X_n X
		
		*create ids variables
		* ID for each country year: Variable country_year. Year of survey can be different from the year in the name of the folder
		catenate country_year = country year_file, p("_")

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

		*Household ids
		catenate hh_id = country_year cluster hv002 
		rename hhid hhid_original

		
		*Religion
		*merge m:1 hh_id using "$data_dhs\dhs_ethnicity_religion_v2.dta", keepusing (ethnicity religion) keep(master match)
		
	
		*save each file in temporal folder
		compress 
		save "temporal/`1'_`3'", replace
		*save "`temporal_path'/`1'_`3'", replace
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



