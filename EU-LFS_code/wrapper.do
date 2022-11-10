************************************************
***********LFS PROCESSING**************************
************19-01-2022**************************


*Generate my country list
use "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Code\countrycodes.dta", clear
*drop if isocode3=="AUT" | isocode3=="BEL" | isocode3=="BGR"  | isocode3=="CHE"  | isocode3=="CYP"  | isocode3=="CZE"  | isocode3=="DEU"  | isocode3=="DNK"  | isocode3=="EST"

*This chooses all countries
*drop if isocode3=="AUT"
levelsof isocode3, local(isocodes) clean 

*Select number of years
numlist "2015/2019"
local yearsequence "`r(numlist)'"
di "`yearsequence'"

 set trace on
set tracedepth 1
 
**Now call LFS_standalone RECURSIVELY
foreach iso of local isocodes {
	foreach year of local yearsequence {
	 di "Now processing" " `iso'" " from year " " `year'"
	 LFS_standalone, country_code("`iso'") country_year("`year'") 
	 clear
	}
}


**Now consolidate all the indicators in a single csv file for LFS surveys

 local files : dir "" files "*.dta"
    foreach file in `files' {
        append using `file', keep(var1 var2)
    }

cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Code"


filelist, dir("C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Indicators") pat("*.dta") save("indicators_datasets.dta")
        
   
         use "indicators_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "indicators_datasets.dta" in `i', clear
           local f = dirname + "/" + filename
           use "`f'", clear
           *gen source = "`f'"
           tempfile save`i'
           save "`save`i''"
         }

		 cd ""
         use "`save1'", clear
         forvalues i=2/`obs' {
           append using "`save`i''"
         }

*save "EU-LFS_indicators_25012022.dta", replace
save "EU-LFS_indicators_17102022.dta", replace


/*
global raw_path "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Datasets"
global std_path "C:\Users\taiku\Desktop\temporary_std"

**FIRST STEP: SCAN THE RAW DATA directory and get a list of survey IDs
local raw_list_LFS : dir "$raw_path" dirs "*dhs*"


di "The following LFS surveys will be processed" 
foreach filepath of local raw_list_LFS {
   di "`filepath'"
}
*/


/*
foreach survey of local raw_list_LFS {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		 tokenize "`survey'", parse(_)
		 clear
     }
 set trace off	 */ 