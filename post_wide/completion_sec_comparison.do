************************************************
************07-jul-2023**************************
*********************
*new completions ;) 



 
cd "C:\Users\mm_barrios-rivera\Desktop\temporary_raw"

filelist, dir("C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\2_standardised") pat("*.dta") save("std_datasets.dta") replace
 
*preserve
clear
tempfile building
save `building', emptyok

use "std_datasets.dta", clear
   local obs = _N
   forvalues i=1/`obs' {
   use "C:\Users\mm_barrios-rivera\Desktop\temporary_raw\std_datasets.dta" in `i', clear
   local f = dirname + "/" + filename
   local filename = filename 
   tokenize "`filename'" ,  parse("_")
   	local isocode=upper("`3'")
	local survey=subinstr("`7'", ".dta", "",.)
	local year=upper("`5'") 

   use "`f'", clear
	di "`isocode'"
	di "`survey'"
	di "`year'"
	*check if there's the vars we need
	 capture describe comp_lowsec comp_upsec lowsec_age1 upsec_age1 schage hhweight
	 set trace on
		if _rc == 0 {
			
		*Usual completion calculatiuon 
		foreach X in  lowsec upsec {
		generate comp_`X'_v2 = comp_`X' if schage >= `X'_age1 + 3 & schage <= `X'_age1 + 5
				}
			*extra completion calculation 
			
			gen comp_lowsec_1519 = comp_lowsec if inrange(schage, 15, 19)
			gen comp_upsec_2024 = comp_upsec if inrange(schage, 20, 24)
			
			*keep variables q necesitamos
			gen iso_code="`isocode'"
			capture gen year="`year'"
			capture gen survey= "`survey'"
			keep iso_code survey year comp*  lowsec_age1 upsec_age1 hhweight
			
			*collapse y añadir 

			collapse (mean) comp_lowsec_1519 comp_upsec_2024 comp_lowsec_v2 comp_upsec_v2  lowsec_age1 upsec_age1 (count) comp_lowsec_1519_no=comp_lowsec_1519 comp_upsec_2024_no=comp_upsec_2024 comp_lowsec_v2_no=comp_lowsec_v2 comp_upsec_v2_no=comp_upsec_v2 [weight=hhweight], by(iso_code survey year)
				*gen category="Total"	
				*save "comp_comparison_`1'_`3'.dta", replace
				append using `building'
				save `"`building'"', replace 
		
			clear 		
						}
		else { 
     di "moving on cause there's not all the variables i need " 
	 clear
	 }
	 set trace off 
 } 
	

 *run a loop to collect all the collapsed results
 
 use `building', clear
 
 save "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\comp_comparison.dta"
 export excel using "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\comp_comparison_secondary.xlsx", firstrow(variables) replace
 
/*
cd "C:\Users\Lenovo PC\Desktop\multiproposito\lit_beyond"
local theFiles: dir . files "*.dta"
clear
append using `theFiles'
*/

  *merge m:1 iso_code using "C:\Users\Lenovo PC\OneDrive - UNESCO\WIDE files\2023\country_names_key.dta" , keep(match master)

   *save "C:\Users\Lenovo PC\Desktop\multiproposito\literacy_morecohorts.dta", replace
		