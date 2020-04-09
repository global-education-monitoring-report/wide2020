clear
global data_path "path"
global aux_data_path "path"

* get a list of files with the extension .dta in directory 

cd $data_path/dta

local allfiles : dir . files "*.dta"

capture mkdir "$data_path/temporal"


* mics variables to keep first
import delimited "$aux_data_path/mics_dictionary.csv", clear varnames(1) encoding(UTF-8)
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
keep if keep == 1
keep name_new
sxpose, clear firstnames
ds
local micsvars_keep `r(varlist)'

* read all files 
foreach file of local allfiles {

  *read a file
  use "`file'", clear
  
  *lowercase all variables
  capture rename *, lower
  
  
	*select common variables 
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
	
	*encoding and changing strings values to lower case
	local common_decode : list common & micsvars_decode
	
	foreach var of varlist `common_decode'{ 
		cap sdecode `var', replace
		cap replace `var' = lower(`var')
		*replace `var' = stritrim(`var')
		*replace `var' = strltrim(`var')
		*replace `var' = strrtrim(`var')
	 }
	 
		
	if country == "Palestine" & year_file == 2010 {
		for X in any ed3 ed7 ed5: cap tostring X, gen(temp_X)
		drop ed3 ed7 ed5
		for X in any ed3 ed7 ed5: cap rename temp_X X
	}
	
	*create new variables
	*ssc install catenate
	catenate country_year  = country year_file, p("_")
	catenate individual_id = country_year hh1 hh2 hl1, p(no)
	catenate hh_id         = country_year hh1 hh2, p(no) 

	*Add info interview for Thailand. It is in the hh module -> improve
	 
	*if country_year == "Thailand_2015" {
	*preserve
		*use "$data_path/dta/hh/Thailand_2015_hh.dta", clear
		*cap rename *, lower
		*keep hh1 hh2 hh5m hh5y
		*generate country_year = "Thailand_2015"
		*catenate hh_id = country_year hh1 hh2, p(no) 
		*tempfile th_hh
		*save `th_hh'
	*restore
		*merge m:1 hh_id using "`th_hh'", update
		*drop if _merge==2
		*drop _merge
   *}
	
	*creating variables doesnt exist
	for X in any `micsvars_keep': cap gen X=.
	order `micsvars_keep'
	
	*rename variables
	renamefrom using $aux_data_path/mics_rename.csv, filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlab_en) keepx
	
	*save each file in temporal folder
  	
	compress 
	save "$data_path/temporal/`1'_`3'_hl", replace
}


cd $data_path/temporal
local allfiles : dir . files "*.dta", respectcase

* append all
* ssc install fs 
fs *.dta
append using `r(files)', force


* remove temporal folder and files
rmdir "$data_path/temporal"

* save all dataset in a single one
compress
save "$data_path/all/mics_reading.dta", replace


