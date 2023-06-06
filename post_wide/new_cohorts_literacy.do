************************************************
***********WIDE beyond**************************
************18-APR-2023**************************

clear 
cd "C:\Users\Lenovo PC\Desktop\temporary_raw"


 filelist, dir("C:\Users\Lenovo PC\UNESCO\GEM Report - WIDE Data NEW\2_standardised") pat("*.dta") save("std_datasets.dta") replace
        

use "std_datasets.dta", clear
   local obs = _N
   forvalues i=1/`obs' {
   use "C:\Users\Lenovo PC\Desktop\temporary_raw\std_datasets.dta" in `i', clear
   local f = dirname + "/" + filename
   local filename = filename 
   tokenize "`filename'" ,  parse("_")
   	local isocode=upper("`3'")
	local survey=subinstr("`7'", ".dta", "",.)
	local year=upper("`5'") 

   use "`f'", clear
	*di "`isocode'"
	*di "`survey'"
	*di "`year'"
	*check if there's the vars we need
	 capture describe hh_edu_head_prim literacy_1524 literacy_1549 literacy sex wealth location
		if _rc == 0 {
			*calcular el nuevo literacy cohort 
			gen literacy_2549=literacy_1549 if age >= 25 & age <= 49
			*keep variables q necesitamos
			gen iso_code="`isocode'"
			capture gen year="`year'"
			capture gen survey= "`survey'"
			keep iso_code survey year sex wealth hh_edu_head_prim location literacy_1524 literacy_2549 hhweight
			*select tuples
			global categories_collapse location sex wealth hh_edu_head_prim
			tuples $categories_collapse, display
			
			save "C:\Users\Lenovo PC\Desktop\temporary_raw\\`1'_`3'_tocollapse.dta", replace
			
			/*
			tuple15: location sex wealth hh_edu_head
			tuple14: location sex wealth
			tuple13: location sex hh_edu_head
			tuple12: location wealth hh_edu_head
			tuple11: sex wealth hh_edu_head
			tuple10: location sex
			tuple9: location wealth
			tuple8: location hh_edu_head
			tuple7: sex wealth
			tuple6: sex hh_edu_head
			tuple5: wealth hh_edu_head
			tuple4: location
			tuple3: sex
			tuple2: wealth
			tuple1: hh_edu_head
			*/
				
			cd  "C:\Users\Lenovo PC\Desktop\temporary_std"
			*collapse y añadir 

			
			foreach i of numlist 0/4 6/7 9/10 {
				use "C:\Users\Lenovo PC\Desktop\temporary_raw\\`1'_`3'_tocollapse.dta", clear
				qui tuples $categories_collapse, display
				collapse (mean) literacy_1524 literacy_2549 (count) no_literacy_1524=literacy_1524 no_literacy_2549=literacy_2549 [weight=hhweight], by(iso_code survey year `tuple`i'')
				gen category="`tuple`i''"	
				save "result`i'.dta", replace
				 
			}


			* Appending the results
			cd  "C:\Users\Lenovo PC\Desktop\temporary_std"
			use "result0.dta", clear
			gen t_0=1
			foreach i of numlist 0/4 6/7 9/10 {
				append using "result`i'"
			}
			drop if t_0==1
			drop t_0
			
			*guardar 
			cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
			save "literacy_cohorts_`1'_`3'.dta", replace
			clear 		
			
			}
		else { 
     di "moving on cause there's not all the variables i need " 
	 clear
	 }
 } 
	

 *run a loop to collect all the collapsed results 
cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
local theFiles: dir . files "*.dta"
clear
append using `theFiles'

  merge m:1 iso_code using "C:\Users\Lenovo PC\OneDrive - UNESCO\WIDE files\2023\country_names_key.dta" , keep(match master)

   save "C:\Users\Lenovo PC\Desktop\multiproposito\literacy_morecohorts.dta", replace
		
           
