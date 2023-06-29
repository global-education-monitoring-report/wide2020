************************************************
***********WIDE beyond**************************
************15-june-2023**************************

cd "C:\Users\mm_barrios-rivera\Desktop\temporary_std"

log using nonresponse , replace
 
 use "C:\ado\personal\repository_inventory.dta" 

 keep if inlist(roundmics, 6)
 
 drop if iso=="TUV"
  drop if iso=="WSM"

 
 levelsof fullname, local(mics6surveys)


**# non response in FS LOOP #
 

* set trace on
* set tracedepth 1
**Now call MICS_standardize RECURSIVELY
foreach survey of local mics6surveys {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		tokenize "`survey'", parse(_)
		
		
use "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`1'_`3'_MICS\hl.dta", clear

 capture describe disability 

			if _rc == 0 {
gen iso_code3=upper("`1'")
generate year = `3'

gen dis_nonresponse = 1 if disability==. & inrange(HL6, 5, 17)
replace dis_nonresponse = 0 if disability!=. & inrange(HL6, 5, 17)

tab iso_code
tab year
tab dis_non
*bysort windex5 : tab dis_non
*bysort felevel : tab dis_non
*bysort melevel : tab dis_non


	   		  }
			  
			  clear
			  
	
							}   
							log close 


* set trace off	 
 
 
 *********************************************************************************************************************************
 
 
 
 translate "C:\Users\mm_barrios-rivera\Desktop\temporary_std\nonresponse.smcl"  "C:\Users\mm_barrios-rivera\Desktop\temporary_std\nonresponse.pdf", translator(smcl2pdf)

 *run a loop to collect all the collapsed results 
cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
local theFiles: dir . files "*.dta"
clear
append using `theFiles'

rename iso_code3 iso_code

*country names
  merge m:1 iso_code using "C:\Users\Lenovo PC\OneDrive - UNESCO\WIDE files\2023\country_names_key.dta" , keep(match master)




