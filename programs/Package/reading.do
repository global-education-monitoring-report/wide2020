clear
global data_path "path"
global aux_data_path "path"

* get a list of files with the extension .dta in directory 

cd $data_path

local allfiles : dir . files "*.dta"

mkdir "$data_path/temporal"


* mics variables to keep
import delimited "$aux_data_path/mics_dictionary.csv", clear varnames(1) encoding(UTF-8)
tempfile dictionary
save `dictionary'
keep name 
duplicates drop name, force
sxpose, clear firstnames
ds
local micsvars `r(varlist)'

* mics variables to decode
use `dictionary', clear
*save `"`dictionary'"', replace
drop if encode != "decode"
keep name_new
sxpose, clear firstnames
ds
local micsvars_decode `r(varlist)'


* read all files 
foreach file of local allfiles {

  *read a file
  use "`file'", clear
  
  *lowercase all variables
  capture rename *, lower
  
  *generate variables with file name
  tokenize `file', parse("_")
	generate country = "`1'" 
	generate year_file = `3'
	
   *label new variables
    label variable country "Country name"
	label variable year_file "File year"
  
	*select common variables 
	ds
	local datavars `r(varlist)'
	local common : list datavars & micsvars
	*display "`common'"
	keep `common'
	ds
	
	*rename 
	fix_names
	
	*encoding and changing strings values to lower case
	foreach var of local `micsvars_decode' {
	 cap sdecode `var', replace
	 replace `var' = lower(`var')
	 *replace `var'=stritrim(`var')
	 *replace `var'=strltrim(`var')
	 *replace `var'=strrtrim(`var')
	}
	
	* improve this to palestine 2010
	*for X in any ed3 ed7 ed5: cap tostring X, gen(temp_X)
	*drop ed3 ed7 ed5
	*for X in any ed3 ed7 ed5: cap rename temp_X X
	
	*save each file in temporal folder
  compress 
  save "$data_path/temporal/`1'_`3'_hl", replace
}


cd $data_path/temporal
local allfiles : dir . files "*.dta", respectcase

* append all
* ssc install fs 
fs *.dta
append using `r(files)'


* remove temporal folder and files
rmdir "$data_path/temporal"

* save all dataset in a single one
compress
save "$data_path/all/mics_reading.dta", replace


