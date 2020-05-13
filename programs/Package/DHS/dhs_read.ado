* dhs_read: program to read the datasets and append all in one file
* Version 2.0
* April 2020

program define dhs_read
	args data_path table_path

	
	* read IR and MR files to get ethnicity and religion
	local modules ir mr 
	
	foreach module of local modules {
		
		cap mkdir "`data_path'/temporal/`module'"
		cd `data_path'
		
		import excel "`table_path'/filenames.xlsx", sheet(dhs_`module'_files) firstrow cellrange (:D2) clear 
		levelsof filepath, local(filepath) clean

		foreach file of local filepath {

			*read a file
			use *v001 *v002 *v130 *v131 *v150 using "`file'", clear

			rename *, lower
			for X in any v001 v002 v130 v131 v150: cap rename mX X
			for X in any v001 v002 v130 v131 v150 : cap generate X=.
			
			* only keep the household head
			keep if v150 == 1 
			
			tokenize "`file'", parse("/")
			generate country = "`1'" 
			generate year_folder = `3'
			catenate country_year = country year_folder
			catenate hh_id = country_year v001  v002
			drop v150 v001 v002
			
			foreach var of varlist v130 v131{ 
				cap sdecode `var', replace
				cap replace `var' = lower(`var')
				cap replace_character
				cap replace `var' = stritrim(`var')
				cap replace `var' = strltrim(`var')
				cap replace `var' = strrtrim(`var')
			}
			
			cap label drop _all
			
			compress
			save "`data_path'/temporal/`module'/`1'_`3'", replace
			
		}
		
		cd "`data_path'/temporal/`module'/"
	
		fs *.dta
		append using `r(files)', force
		save "`data_path'/temporal/dhs_`module'.dta" , replace
	}
	
	use "`data_path'/temporal/dhs_ir.dta", clear
	append using "`data_path'/temporal/dhs_mr.dta"
	
	erase `data_path'/temporal/dhs_ir.dta
	erase `data_path'/temporal/dhs_mr.dta
	
	rename v130 religion
	rename v131 ethnicity
	
	
	compress
	save "`data_path'/temporal/dhs_religion_ethnicity.dta", replace

	
	* read pr files
	import excel "`table_path'/filenames.xlsx", sheet(dhs_pr_files) cellrange (:D2) firstrow clear 
	levelsof filepath, local(filepath) clean

	* create local macros from dictionary
	import excel "`table_path'/dhs_dictionary_setcode.xlsx", sheet(dictionary) firstrow clear 
	* dhs variables to keep first
	levelsof name, local(dhsvars) clean
	* dhs variables to decode
	levelsof name if encode == "decode", local(dhsvars_decode) clean
	* dhs variables to keep last
	levelsof name if keep == 1, local(dhsvars_keep) clean 
	
	cd `data_path'
	
	cap mkdir "`data_path'/temporal"

		
	* read all files 
	foreach file of local filepath {

		*read a file
		use "`file'", clear

		*lowercase all variables
		rename *, lower
						  
		*select common variables between the dataset and the mics dictionary (1st column)
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
		cap renamefrom using "`table_path'/dhs_dictionary_setcode.xlsx", filetype(excel)  if(!missing(rename)) raw(name) clean(rename) label(varlab_en) keepx
		
		*create numeric variables for easy recoding
		for X in any sex wealth location: generate X_n = X
		for X in any sex wealth location: drop X
		for X in any sex wealth location: rename X_n X
		
		*create ids variables
		catenate country_year = country year_folder
		
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

		
		* add religion and ethnicity
		merge m:1 hh_id using "`data_path'/temporal/dhs_religion_ethnicity.dta", keepusing (ethnicity religion) keep(master match) nogenerate
		
			
		*save each file in temporal folder
		compress 
		save "`data_path'/temporal/`1'_`3'_pr.dta", replace
}


	cd "`data_path'/temporal/"
	
	* append all the datasets
	fs *.dta
	append using `r(files)', force

	* remove temporal folder and files
	cap rmdir "`data_path'/temporal"
	
	* save all dataset in a single one
	compress
	save "`data_path'/dhs_read.dta", replace

end



