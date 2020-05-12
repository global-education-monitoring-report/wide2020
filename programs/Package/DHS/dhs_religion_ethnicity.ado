* dhs_religion_ethnicityd: program to keep religion and ethinicity from IR and MR files
* Version 1.0
* April 2020

program define dhs_religion_ethnicity
	args data_path table_path

	
	cap mkdir "`data_path'/temporal/IR"

	import excel "`table_path'/filenames.xlsx", sheet(dhs_ir_files) firstrow cellrange (:D3) clear 
	levelsof filepath, local(filepathir) clean

	foreach file of local filepathir {

		*read a file
		use "`file'", clear

		tokenize "`file'", parse("/")
		generate country = "`1'" 
		generate year_folder = `3'

		rename *, lower
		
		for X in any v001 v002 v130 v131 v150: cap rename mX X
		* only keep the household head
		keep if v150 == 1 
		keep country* year* v001 v002 v130 v131 v150
		
		catenate country_year = country year_folder

		for X in any v001 v002: gen X_s=string(X, "%25.0f")
		gen hh_id = country_year+" "+v001_s+" "+v002_s
		for X in any v001 v002 v130 v131 v150 : cap generate X=.

		for X in any v130 v131: cap decode X, gen(temp_X)
		for X in any v130 v131: cap tostring X, gen(temp_X)
		drop v130 v131
		for X in any v130 v131: cap ren temp_X X
		cap label drop _all
		drop v150 v001* v002*
		compress
		save "`data_path'/temporal/IR/`1'`3'", replace
	}


	set more off
	cap mkdir "`data_path'/temporal/MR"

	import excel "`table_path'/filenames.xlsx", sheet(dhs_mr_files) firstrow cellrange (:D3) clear 
	levelsof filepath, local(filepathmr) clean


	foreach file of local filepathmr {

		*read a file
		use "`file'", clear


		tokenize "`file'", parse("/")
		generate country = "`1'" 
		generate year_folder = `3'

		rename *, lower

		for X in any v001 v002 v130 v131 v150: cap ren mX X
		*only keep the household head
		keep if v150 == 1 
		keep country* year* v001 v002 v130 v131 v150

		catenate country_year = country year_folder
		for X in any v001 v002: gen X_s=string(X, "%25.0f")
		gen hh_id = country_year+" "+v001_s+" "+v002_s
		for X in any v001 v002 v130 v131 v150 : cap gen X=.

		for X in any v130 v131: cap decode X, gen(temp_X)
		for X in any v130 v131: cap tostring X, gen(temp_X)
		drop v130 v131
		for X in any v130 v131: cap ren temp_X X
		cap label drop _all
		drop v150 v001* v002*
		compress
		save "`data_path'/temporal/MR/`1'`3'", replace
	}


	cd "`data_path'/temporal/IR/"
	
	fs *.dta
	append using `r(files)', force
	
	save "dhs_ir.dta" , replace

	cd "`data_path'/temporal/MR/"
	
	fs *.dta
	append using `r(files)', force
	
	save "dhs_mr.dta" , replace


	use "`data_path'/temporal/IR/dhs_ir.dta", clear
	append using "`data_path'/temporal/MR/dhs_mr.dta'"
	
	rename v130 religion
	rename v131 ethnicity

	*include "$programs_dhs_aux\dhs_fixes_religion_ethnicity.do" 
	
	compress
	save "`data_path'/temporal/dhs_religion_ethnicity.dta", replace

end

