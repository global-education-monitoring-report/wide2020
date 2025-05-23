************************************************
***********WIDE UPDATE**************************
************14-05-2021**************************

** 03/09 update :  To obtain MICS round, we added the file "MICS_round_03092021.dta" so that the round will be incorporated into the std files. 

***********************************************************************
*This new module follows a new logic in the update of MICS/DHS surveys:
*TO ONLY UPDATE NEW DATASETS, ON A SEQUENTIAL BASIS********************
***********************************************************************

global raw_path "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
global std_path "C:\Users\taiku\UNESCO\GEM Report - 2_standardised"

**FIRST STEP: SCAN THE RAW DATA directory and get a list of survey IDs
local raw_list_dhs : dir "$raw_path" dirs "*dhs*"
local raw_list_mics : dir "$raw_path" dirs "*mics*"


**SECOND STEP: SCAN THE STANDARDIZED directory and get a list of survey IDS
local done_list_dhs : dir "$std_path" dirs "*dhs*"
local done_list_mics : dir "$std_path" dirs "*mics*"

**THIRD STEP: generate a new list of surveys to be processed
local process_list_dhs : list raw_list_dhs-done_list_dhs
local process_list_mics : list raw_list_mics-done_list_mics


di "The following DHS surveys will be processed" 
foreach filepath of local process_list_dhs {
   di "`filepath'"
}

di "The following MICS surveys will be processed" 
foreach filepath of local process_list_mics {
   di "`filepath'"
}


set trace on
set tracedepth 1
**Now call MICS_standardize RECURSIVELY
local dpath "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
local opath "C:\Users\taiku\Desktop\temporary_std"
foreach survey of local process_list_mics {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		tokenize "`survey'", parse(_)
		mics_standardize_standalone,  data_path(`dpath') output_path(`opath') country_code("`1'") country_year("`3'") 
		
		*Add round number (1-6)
		clear
		local isocode=upper("`1'")
		set obs 1
		gen iso_code3="`isocode'"
		gen year="`3'"
		findfile MICS_round_03092021.dta, path("`c(sysdir_personal)'/")
		merge m:1 iso_code3 year using "`r(fn)'", keep(match master)  nogenerate
		levelsof round, local(round)
		clear
		
		mics_standardize_standalone,  data_path(`dpath') output_path(`opath') country_code("`1'") country_year("`3'") 

		
		gen round="`round'"
		capture mkdir  "C:\Users\taiku\UNESCO\GEM Report - 2_standardised\\`isocode'_`3'_MICS"		
		cd "C:\Users\taiku\UNESCO\GEM Report - 2_standardised\\`isocode'_`3'_MICS"
		save "std_`isocode'_`3'_MICS.dta", replace
		display "You can find the standardized files for all surveys in C:\Users\taiku\UNESCO\GEM Report - 2_standardised"
		clear
     }
set trace off	 


	 set trace on
	 set tracedepth 1
**Now call DHS_standardize RECURSIVELY
local dpath "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
local opath "C:\Users\taiku\UNESCO\GEM Report - WIDE Data NEW\2_standardised"
foreach survey of local process_list_dhs {
         di "Now processing" " `survey'"
         *Directly run widetable with one survey
			tokenize "`survey'", parse(_)
		dhs_standardize_standalone,  data_path(`dpath') output_path(`opath')  country_code("`1'") country_year("`3'")
		local isocode=upper("`1'")
		capture mkdir  "C:\Users\taiku\UNESCO\GEM Report - 2_standardised\\`isocode'_`3'_DHS"
		cd "C:\Users\taiku\UNESCO\GEM Report - 2_standardised\\`isocode'_`3'_DHS"
		save "std_`isocode'_`3'_DHS.dta", replace
		clear
     }
set trace off	 
