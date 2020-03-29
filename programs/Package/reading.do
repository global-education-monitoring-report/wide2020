clear
global data_path "path"
global aux_data_path "path"

* get a list of files with the extension .dta in directory 

cd $data_path
local allfiles : dir . files "*.dta"

mkdir "$data_path/temporal"


* mics variables to keep
import delimited "$aux_data_path/mics_variables_nameslabels.csv", clear varnames(1) encoding(UTF-8)
keep name 
duplicates drop name, force
sxpose, clear firstnames
ds
local micsvars `r(varlist)'


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

  compress 
  save "$data_path/temporal/`1'_`3'_hl", replace
}


cd $data_path/temporal
local allfiles : dir . files "*.dta", respectcase

*standarize variables format 

* ssc install fs 
* append all
fs *.dta
append using `r(files)'


* remove temporal folder and files
rmdir "$data_path/temporal"

* save all dataset in a single one
compress
save "$data_path/all/hl_mics_reading.dta", replace


