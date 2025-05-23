************************************************
***********WIDE UPDATE**************************
************14-05-2021**************************
*Latest update 21/09/2022: update system of feeding surveys with phase/rounds of DHS/MICS
*updated repository_inventory.dta on 21/12/2022 


***********************************************************************
*This new module follows a new logic in the update of MICS/DHS surveys:
*TO ONLY UPDATE NEW DATASETS, ON A SEQUENTIAL BASIS********************
***********************************************************************



/*
global raw_path "C:\Users\taiku\Desktop\temporary_raw"
*C:\Users\taiku\Desktop\temporary_raw
global std_path "C:\Users\taiku\Desktop\temporary_std"

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

*/


clear 
use "C:\ado\personal\repository_inventory.dta"

 keep if iso=="COM"  & year=="2022"
 levelsof fullname, local(mics6surveys)

*dec 2023 update: pick DHS phase 8 and BEN 2022 MICS

/*
 drop if iso=="FJI"
 drop if iso=="VNM"
*/

 *keep if inlist(roundmics, 6)
 *keep if iso=="DJI"

* levelsof fullname, local(mics6surveys)

/*
 keep if roundmics == 6
 
 
 keep if iso=="TCD"
  keep if inlist(phasedhs,  7, 8)
   drop if iso=="IND"

*/



   
/*
    keep if inlist(phasedhs,  7)

   drop if iso=="COL"
*/

 *problem with CUBA 2014


 *keep if survey=="DHS" & phasedhs==8
 
 *these countries have some new questions on ECD so we turn off that part of the code 
*keep if iso=="CIV" |  iso=="KEN" | iso=="TZA"
 *levelsof fullname, local(mics6surveys)
 *levelsof fullname, local(process_list_dhs)



 *whatever name of the local put the local name in the next loop 




 set trace on
 set tracedepth 1
**Now call MICS_standardize RECURSIVELY
local dpath "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\1_raw_data"
local opath "C:\Users\mm_barrios-rivera\Desktop\temporary_std"
foreach survey of local mics6surveys {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		tokenize "`survey'", parse(_)
		
		*Add round number (1-6)
		clear
		local isocode=upper("`1'")
		set obs 1
		gen iso_code3="`isocode'"
		gen year="`3'"
		findfile MICS_round_04022022.dta, path("`c(sysdir_personal)'/")
		merge m:1 iso_code3 year using "`r(fn)'", keep(match master)  nogenerate
		levelsof round, local(round)
		clear
		
		mics_standardize_standalone,  data_path(`dpath') output_path(`opath') country_code("`1'") country_year("`3'") 
		
		gen round="`round'"

		capture mkdir  "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\2_standardised\\`isocode'_`3'_MICS"		
		cd "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\2_standardised\\`isocode'_`3'_MICS"
		save "std_`isocode'_`3'_MICS.dta", replace
		clear
     }
 set trace off	 





***************************************************************
/*

 	 set trace on
   	 set tracedepth 1
  **Now call DHS_standardize RECURSIVELY
  local dpath  "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\1_raw_data"
  local opath "C:\Users\mm_barrios-rivera\Desktop\temporary_std"
  foreach survey of local process_list_dhs {
           di "Now processing" " `survey'"
           *Directly run widetable with one survey
  			tokenize "`survey'", parse(_)
  		dhs_standardize_standalone,  data_path(`dpath') output_path(`opath')  country_code("`1'") country_year("`3'")
  		local isocode=upper("`1'")
		capture gen iso_code3="`isocode'"

  		capture mkdir  "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\2_standardised\\`isocode'_`3'_DHS"
  		cd "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\2_standardised\\`isocode'_`3'_DHS"
  		save "std_`isocode'_`3'_DHS.dta", replace
  		clear
       }
   set trace off	 

*/

*no failure in 8, 7 DHS phase
*prob w COL phase 6
