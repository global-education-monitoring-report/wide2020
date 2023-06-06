************************************************
***********WIDE beyond**************************
************19-may-2023**************************

*structure taken from literacy_beyond

clear 
 use "C:\Users\Lenovo PC\ado\personal\repository_inventory.dta"

 keep if inlist(roundmics, 6, 5)
 
 drop if iso=="TUV"
  drop if iso=="WSM"

 
 levelsof fullname, local(mics6surveys)


**# *WOMEN'S LOOP #
 

 set trace on
 set tracedepth 1
**Now call MICS_standardize RECURSIVELY

foreach survey of local mics6surveys {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		tokenize "`survey'", parse(_)
		
		clear
		local isocode=upper("`1'")
		set obs 1
		gen iso_code3="`isocode'"
		gen year="`3'"
		
*WM Module check 
cd "C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`1'_`3'_MICS\"

capture confirm file wm.dta 
if _rc == 0 {
use "wm.dta", clear
gen iso_code3=upper("`1'")
generate year = `3'

		  	   *check if HIV variables exists, if not, move on
	   		   capture describe HA1 HA2 HA3 HA4 HA5 HA6 HA7

			if _rc == 0 {
				
				* Women who have comprehensive knowledge about HIV prevention includes women who know of the two ways of HIV prevention (having only one faithful uninfected partner (HA2=1) and using a condom every time (HA4=1)),
				*who know that a healthy looking person can be HIV-positive (HA7=1), 
				*and who reject the two most common misconceptions (two most common of HA3=2, HA6=2, HA5=2, and any other local 
				* misconception added to the questionnaire).
				
				*clean missing and dks 
				 forval num = 2/7 {
               replace HA`num'=. if HA`num' == 8 | HA`num' == 9
					}
					
				*For the 2 of the 3 part
				foreach k in 3 5 6 {
				replace HA`k' = 0 if HA`k'==1
				replace HA`k' = 1 if HA`k'==2
				egen HA`k'mean = mean(HA`k')
								}
				*this is the least common misconception (the one that should not count in the evaluation)
				gen maxaverage = max(HA3mean, HA5mean, HA6mean)
				
				gen csm= 0 
				foreach k in 3 5 6 {
				replace csm = csm + 1 if HA`k'==1 & HA`k'mean!=maxaverage
								}

				*Give a point for HA7 healthy "Percentage who know that a healthy-looking person can be HIV-positive".
				replace csm = csm+1 if HA7==1
				
				*Find two most common misconceptions between mosquito supernatural sharingFood HA3 HA5 HA6
				gen knowThree = 1 if csm==3
				
				*count twoWays = onePartner condomUse (100).
				gen knowBoth = 1 if HA2==1 & HA4==1
				
				gen comprehensiveknowledge = 0 if inlist(HA1, 1, 2)
				replace comprehensiveknowledge = 1 if knowBoth == 1 & knowThree == 1
				
				gen sex="Female"
				*weight wmweight
				keep iso year comprehensiveknowledge sex wmweight
				*collapse (mean) contraceptive  (count) count=contraceptive [aw=wmweight], by(iso year sex literacy_wm HH6)
				*capture drop if literacy_wm==.
				collapse (mean) comprehensiveknowledge  (count) count=comprehensiveknowledge [aw=wmweight], by(iso year sex)
				*save as dta in a particular place
				cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
				*save "literacy_wm_`1'_`3'.dta", replace
				save "HIV_wm_`1'_`3'.dta", replace

    						}
			else {
				display "no HIV module"
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
		
	
*MN Module check and merge
cd "C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`1'_`3'_MICS\"

capture confirm file mn.dta 
if _rc == 0 {
use "mn.dta", clear
gen iso_code3=upper("`1'")
generate year = `3'

		  	   *check if HIV module exists, if not, move on
	   		   capture describe MHA1 MHA2 MHA3 MHA4 MHA5 MHA6 MHA7 

			if _rc == 0 {
				
				*clean missing and dks 
				 forval num = 2/7 {
               replace MHA`num'=. if MHA`num' == 8 | MHA`num' == 9
					}
					
				*For the 2 of the 3 part
				foreach k in 3 5 6 {
				replace MHA`k' = 0 if MHA`k'==1
				replace MHA`k' = 1 if MHA`k'==2
				egen MHA`k'mean = mean(MHA`k')
								}
				*this is the least common misconception (the one that should not count in the evaluation)
				gen maxaverage = max(MHA3mean, MHA5mean, MHA6mean)
				
				gen csm= 0 
				foreach k in 3 5 6 {
				replace csm = csm + 1 if MHA`k'==1 & MHA`k'mean!=maxaverage
								}

				*Give a point for HA7 healthy "Percentage who know that a healthy-looking person can be HIV-positive".
				replace csm = csm+1 if MHA7==1
				
				*Find two most common misconceptions between mosquito supernatural sharingFood HA3 HA5 HA6
				gen knowThree = 1 if csm==3
				
				*count twoWays = onePartner condomUse (100).
				gen knowBoth = 1 if MHA2==1 & MHA4==1
				
				gen comprehensiveknowledge = 0 if inlist(MHA1, 1, 2)
				replace comprehensiveknowledge = 1 if knowBoth == 1 & knowThree == 1
				
				gen sex="Male"
				
				*weight wmweight
				keep iso year sex comprehensiveknowledge  mnweight 
				*collapse (mean) pro_violence  (count) count=pro_violence [aw=mnweight], by(iso year sex literacy_mn HH6)
				collapse (mean) comprehensiveknowledge  (count) count=comprehensiveknowledge [aw=mnweight], by(iso year sex )
				*save as dta in a particular place
				cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
				save "HIV_mn_`1'_`3'.dta", replace
				*save "literacy_mn_`1'_`3'.dta", replace


    						}
			else {
				display "there's no HIV module available "
									}
							}   
else { 
    di "Men module not available in this survey"
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
  
  drop _m
  
  replace country = "Turks and Caicos Is" in 73
replace country = "Turks and Caicos Is" in 74
export excel using "C:\Users\Lenovo PC\Documents\GEM UNESCO MBR\GitHub\wide2020\post_wide\HIV_knowledge_mics.xlsx"



