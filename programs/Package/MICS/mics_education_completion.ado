* mics_education_completion: program to compute the level reached in primary, secondary, etc.
* Version 2.0
* April 2020

program define mics_education_completion
	args data_path 

	* read data
	use "`data_path'/all/mics_educvar.dta", clear
	set more off

	* Ages for completion
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur - 1

	* VERSION C to fix eduyears
	* Recoding those with zero to a lower level of education 
	* Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!
	replace eduyears = years_prim 	if eduyears == 0 & inlist(code_ed4a, 2, 21, 23)
	replace eduyears = years_lowsec if eduyears == 0 & inlist(code_ed4a, 22, 24)
	replace eduyears = years_upsec 	if eduyears == 0 & inlist(code_ed4a, 3, 32, 33)
	replace eduyears = years_higher if eduyears == 0 & code_ed4a == 40
		
	* Without Age limits 
	* I consider that those with or with more years than those necessary for completing that level to have completed that level.
	foreach X in prim lowsec upsec higher {
		generate comp_`X' = 0
			replace comp_`X' = 1	if eduyears >= years_`X'
			replace comp_`X' = . 	if inlist(eduyears, 97, 98, 99)
			replace comp_`X' = 0 	if ed3 == "no" | code_ed4a == 0 
	}
		

	* Age limits
	generate ageA = age-1
    generate ageU = age
	
	foreach X in prim lowsec upsec {
		foreach AGE in ageU ageA {
			generate comp_`X'_v2_`AGE' = comp_`X' if `AGE' >= `X'_age1+3 & `AGE' <= `X'_age1+5
		}
	}

	* Recoding ED5: "Attended school during current school year?"
	generate attend = 1 if ed5 == "yes" 
	replace attend  = 0 if ed5 == "no"

	* save data
	compress
	save "`data_path'/all/mics_educvar.dta", replace

end
	
