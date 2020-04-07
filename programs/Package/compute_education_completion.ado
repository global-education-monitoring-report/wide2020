* compute_education_completion: program to compute the level reached in primary, secondary, etc.
* Version 1.0

program define compute_education_completion

use "$data_mics\hl\Step_2.dta", clear
set more off

*Ages for completion
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur-1

* VERSION C to fix eduyears
*Recoding those with zero to a lower level of education 
*Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!

generate eduyears_C = eduyears	
	replace eduyears_C = years_prim		if eduyears == 0 & (code_ed4a ==2 | code_ed4a == 21 | code_ed4a == 23)
	replace eduyears_C = years_lowsec 	if eduyears == 0 & (code_ed4a == 22 | code_ed4a == 24)
	replace eduyears_C = years_upsec 	if eduyears == 0 & (code_ed4a == 3 | code_ed4a == 32 | code_ed4a == 33)
	replace eduyears_C = years_higher 	if eduyears == 0 & code_ed4a == 40
	
*-- Without Age limits 
* I consider that those with or with more years than those necessary for completing that level to have completed that level.
foreach X in prim lowsec upsec higher {
	generate comp_`X'_C = 0
	replace comp_`X'_C = 1	if eduyears_C >= years_`X'
	replace comp_`X'_C = . 	if (eduyears_C == . | eduyears_C == 97 | eduyears_C == 98 | eduyears_C == 99)
	replace comp_`X'_C = 0 	if ed3=="no" | code_ed4a==0// those that never went to school have not completed! those that went to kindergarten max have no completed primary.
}
	

*Age limits
foreach X in prim lowsec upsec {
	foreach AGE in ageU ageA {
		generate comp_`X'_v2_C_`AGE' = comp_`X'_C if `AGE' >= `X'_age1+3 & `AGE' <= `X'_age1+5
	}
}

* Recoding ED5: "Attended school during current school year?"
generate attend = 1 if ed5 == "yes" // equivalent to school
replace attend = 0 if ed5=="no"

generate eduout = .

compress
save "$data_mics\hl\Step_4.dta", replace

end
	
