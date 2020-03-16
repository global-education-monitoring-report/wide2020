clear
global data_path "path"

* get a list of files with the extension .dta in directory 
cd $data_path
local allfiles : dir . files "*.dta"

mkdir "$data_path\temporal"

* read all files 
foreach file of local allfiles {
  *read a file
  use `"`file'"', clear
  
  *lowercase all variables
  cap rename *, lower
  
  *rename variables 	
  
  *select variables
  
  
  *generate variables with file name
  tokenize "`file'", parse("_")
	gen country = "`1'" 
	gen year_folder = `3'

  compress 
  save "$data_path\temporal\\`1'_`3'_hl", replace
}

*append all
set more off
foreach f of local allfiles {
	qui append using `f'
}

*Remove temporal folder and files
rmdir "$data_path\temporal"

*Drop unnecessary variables
drop   ed8b  //hh6r hh7a1 hh7a2

*Order variables
order country year_folder hh1 hh2 hl1 hl3 hl4 hl5d hl5m hl5y hl7 ed1 ed3 ed4a  ed4b hh6 hh7 region ethnicity religion hhweight windex5 schage

 //ed6a_nr ed5 ed6a ed6b ed6b_nr ed4b_nr 


compress
save "$data_path\all\hl_mics_4&5.dta", replace


end

