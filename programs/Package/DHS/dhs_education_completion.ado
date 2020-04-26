* dhs_education_completion: program to create education completion
* Version 1.0
* April 2020

program define dhs_education_completion
	args input_path output_path 

	use "`input_path'", clear
	set more off

	* Creates education variables

	* VERSION A
	* For Completion: Version A is directly with hv109; Version B uses years of education and duration

	*Creating generic variables for WIDE
	* Attainment, years of education, attendance
	*hv109: 0=no education, 1=incomplete primary, 2=complete primary, 3=incomplete secondary, 4=complete secondary, 5=higher
							 
	*Primary
	generate comp_prim_A = 0
		replace comp_prim_A = 1 if hv109 >= 2
		replace comp_prim_A = . if (hv109 == . | hv109 == 8 | hv109 == 9)

	*Upper secondary
	generate comp_upsec_A = 0
		replace comp_upsec_A = 1 if hv109 >= 4 
		replace comp_upsec_A = . if (hv109 == . | hv109 == 8 | hv109 == 9)

	*Higher
	generate comp_higher_A = 0
		replace comp_higher_A = 1 if hv109 >= 5 
		replace comp_higher_A = . if (hv109 == . | hv109 == 8 | hv109 == 9)


	* VERSION B
	* Mix of years of education completed (hv108) and duration of levels --> useful for lower secondary

	* duration of levels 
	*With the info of years that last primary and secondary I can also compare official duration with the years of education completed..
		generate years_prim		= prim_dur
		generate years_lowsec	= prim_dur + lowsec_dur
		generate years_upsec	= prim_dur + lowsec_dur + upsec_dur
		*gen years_higher	=prim_dur+lowsec_dur+upsec_dur+higher_dur

	*Ages for completion
		generate lowsec_age0 = prim_age0 + prim_dur
		generate upsec_age0 = lowsec_age0 + lowsec_dur
		for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur-1
		
	*label define hv109 0 "no education" 1 "incomplete primary" 2 "complete primary" 3 "incomplete secondary" 4 "complete secondary" 5 "higher"
	*label values hv109 hv109

	*Creating "B" variables
	foreach X in prim lowsec upsec {
		cap generate comp_`X'_B = 0
		 	replace comp_`X'_B  = 1 if hv108 >= years_`X'
			replace comp_`X'_B  = . if (hv108 == . | hv108 >= 90) // here includes those ==98, ==99 
			replace comp_`X'_B  = 0 if (hv108 == 0 | hv109 == 0) // Added in Aug 2019!!	
	}

	*For 2 countries, I use hv109 (I don't find other solution). I don't know why if goes to 28.93 if I don't do this
	replace comp_upsec_B = comp_upsec_A if country_year == "Egypt_2005" 

	compress 
	save "`output_path'", replace

end

