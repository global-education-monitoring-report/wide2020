* dhs_read: program to read the datasets and append all in one file
* Version 1.0
* April 2020

program define dhs_read
	args data_path table_path

	* table to get country_year
	import delimited "`table_path'/dhs_country_year.csv", clear varnames(1) encoding(UTF-8)
	tempfile countryyear
	save `countryyear'
	
	cd `data_path'
	local allfiles : dir . files "*.dta"

	cap mkdir "`data_path'/temporal"
	
	* DHS variables to keep first
	import delimited "`table_path'/dhs_dictionary.csv", clear varnames(1) encoding(UTF-8)
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
	keep name
	sxpose, clear firstnames
	ds
	local dhsvars_decode `r(varlist)'

	* DHS variables to keep last
	restore
	keep if keep == 1
	keep name
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

		*create variables doesnt exist 
		for X in any `dhsvars_keep': cap generate X = .
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
		renamefrom using "`table_path'/dhs_renamevars.csv", filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlab_en) keepx
				
		*create numeric variables for easy recoding
		for X in any sex wealth location: generate X_n = X
		for X in any sex wealth location: drop X
		for X in any sex wealth location: rename X_n X
		
		*generate country_year using file name
		generate file = "`file'"
		replace file =  substr(file, 1, strlen(file) - 4)
		merge m:1 file using `countryyear', keep(master match) nogenerate
		drop file 
		
		generate country = substr(country_year, 1, strlen(country_year) -5)
		
		*create ids variables
		
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
		rename hhid hhid_original

		
		*Religion
		*merge m:1 hh_id using "$data_dhs\dhs_ethnicity_religion_v2.dta", keepusing (ethnicity religion) keep(master match)
		
		*save each file in temporal folder
		compress 
		save "`data_path'/temporal/`file'", replace
}


	cd "`data_path'/temporal/"
	local all : dir . files "*.dta", respectcase

	* append all the datasets
	* ssc install fs 
	fs *.dta
	append using `r(files)', force

	* remove temporal folder and files
	cap rmdir "`data_path'/temporal"
	
	* make the output folder
	cap makedir"`data_path'/all"
	
	* save all dataset in a single one
	compress
	save "`data_path'/all/dhs_read.dta", replace

end



