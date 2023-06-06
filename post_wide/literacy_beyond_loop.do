************************************************
***********WIDE beyond**************************
************18-APR-2023**************************

clear 
 use "C:\Users\Lenovo PC\ado\personal\repository_inventory.dta"

 keep if inlist(roundmics, 6)
 
 drop if iso=="TUV"
  drop if iso=="WSM"

 
 levelsof fullname, local(mics6surveys)


**# *WOMEN'S LOOP #
 

 set trace on
 set tracedepth 1
**Now call MICS_standardize RECURSIVELY
local dpath "C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\1_raw_data"
local opath "C:\Users\Lenovo PC\Desktop\temporary_std"
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
		
*WM Module check and merge
cd "C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`1'_`3'_MICS\"

capture confirm file wm.dta 
if _rc == 0 {
use "wm.dta", clear
gen iso_code3=upper("`1'")
generate year = `3'

		  	   *check if literacy and contraceptive variable exists, if not, move on
	   		   capture describe WB14 CP4K

			if _rc == 0 {
				
				*Calculate literacy
							recode WB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy)
							recode WB14 (1 2 = 0) (3 = 1) (4 6 9 = .), gen(full_literacy)
							*keep identifyer vars and literacy
							* 1 cannot read at all
							* 2 able to read only parts of sentence
							* 3 able to read whole sentence
							* 4 no sentence in required language
							* 9 no response
							gen sex="Female"
				*Calculate contraceptive use 
				*vars CP4A CP4B CP4C CP4D CP4E CP4F CP4G CP4H CP4I CP4J CP4K
				gen contraceptive=. 
				foreach k in A B C D E F G H I J K {
				replace contraceptive = 1 if CP4`k'=="`k'"
								}
				*NOT USING A METHOD TO AVOID PREGNANCY
				replace contraceptive = 0 if contraceptive==. & CP2 == 2 
				*USING A "TRADITIONAL METHOD"
				replace contraceptive = 0 if contraceptive==. & CP4L== "L"
				replace contraceptive = 0 if contraceptive==. & CP4M== "M"
				replace contraceptive = 0 if contraceptive==. & CP4X== "X"
				
				*Calculate appropriate literacy 
				gen literacy_wm = literacy if contraceptive!=. 
				
				*location HH6 
				*weight wmweight
				keep iso year sex contraceptive literacy_wm wmweight HH6
				*collapse (mean) contraceptive  (count) count=contraceptive [aw=wmweight], by(iso year sex literacy_wm HH6)
				*capture drop if literacy_wm==.
				collapse (mean) contraceptive  (count) count=contraceptive [aw=wmweight], by(iso year)
				gen category="Total"
				*save as dta in a particular place
				cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
				*save "literacy_wm_`1'_`3'.dta", replace
				save "literacy_wm_`1'_`3'_t.dta", replace

    						}
			else {
				display "there's either contraceptive or literacy variable missing"
									}
							}   
else { 
    di "Women module not available in this survey"
} 
clear 	
		     }
 set trace off	 
 

**#  **MEN'S LOOP #
 
 set trace on
 set tracedepth 1
**Now call MICS_standardize RECURSIVELY
local dpath "C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\1_raw_data"
local opath "C:\Users\Lenovo PC\Desktop\temporary_std"
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
		
	
*WM Module check and merge
cd "C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`1'_`3'_MICS\"

capture confirm file mn.dta 
if _rc == 0 {
use "mn.dta", clear
gen iso_code3=upper("`1'")
generate year = `3'

		  	   *check if literacy and attitudes against violence variable exists, if not, move on
	   		   capture describe MWB14 

			if _rc == 0 {
				
				*Calculate literacy
							recode MWB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy)
							recode MWB14 (1 2 = 0) (3 = 1) (4 6 9 = .), gen(full_literacy)
							*keep identifyer vars and literacy
							* 1 cannot read at all
							* 2 able to read only parts of sentence
							* 3 able to read whole sentence
							* 4 no sentence in required language
							* 9 no response
							gen sex="Male"
				*Calculate violence indicator  
				*vars MDV1A MDV1B MDV1C MDV1D MDV1E MDV1F
				gen pro_violence=0
				foreach k in A B C D E F {
				capture replace pro_violence = 1 if MDV1`k'==1
								}
				
				*Calculate appropriate literacy 
				gen literacy_mn = literacy 
				
				*location HH6 
				*weight wmweight
				keep iso year sex pro_violence literacy_mn mnweight HH6
				*collapse (mean) pro_violence  (count) count=pro_violence [aw=mnweight], by(iso year sex literacy_mn HH6)
				collapse (mean) pro_violence  (count) count=pro_violence [aw=mnweight], by(iso year )
				gen category="Total"
*				capture drop if literacy_mn==.
				*save as dta in a particular place
				cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
				save "literacy_mn_`1'_`3'_t.dta", replace
				*save "literacy_mn_`1'_`3'.dta", replace


    						}
			else {
				display "there's either contraceptive or literacy variable missing"
									}
							}   
else { 
    di "Women module not available in this survey"
} 
clear 	
		     }
 set trace off	 

 *run a loop to collect all the collapsed results 
cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
local theFiles: dir . files "*.dta"
clear
append using `theFiles'

rename iso_code3 iso_code

*country names
  merge m:1 iso_code using "C:\Users\Lenovo PC\OneDrive - UNESCO\WIDE files\2023\country_names_key.dta" , keep(match master)




