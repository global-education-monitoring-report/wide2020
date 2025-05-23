* standarize_output: program to standarize DHS and MICS output summary format
* Version 2.0
* April 2020

program define standarize_output
		
	local categories_collapse location sex wealth region ethnicity religion
	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
	local varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no
	local vars100 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec

	replace category = "total" if category == ""

	* Fixing for missing values in categories
	foreach X in `categories_collapse' {
		drop if `X' == "" & category == "`X'"
	}

	for X in any sex wealth religion ethnicity region: capture drop if category == "location X" & (location == "" | X == "")
	for X in any wealth religion ethnicity region: capture drop if category == "sex X" & (sex == "" | X == "")
	for X in any region: capture drop if category == "wealth X" & (wealth == "" | X == "")

	drop if category == "location sex wealth" & (location == "" | sex == "" | wealth == "")
	drop if category == "sex wealth region" & (sex == "" | wealth == "" | region == "")

	replace category = proper(category)
	split category, gen(c)
	generate category_original = category
	capture replace category = c1+" & "+c2 if c1! = "" & c2 != "" & c3 == ""
	capture replace category = c1+" & "+c2+" & "+c3 if c1 != "" & c2 != "" & c3 != ""
	capture drop c1 c2 c3 category_orig

	* to 100%
	foreach var of varlist `vars100' {
			replace `var'=`var'*100
	}

	* Eliminate those with less than 30 obs
	foreach var of varlist `varlist_m'  {
			replace `var' = . if `var'_no < 30
	}

	* Merge with year_uis
	capture destring year, replace
	findfile country_survey_year_uis.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 survey year using "`r(fn)'", keepusing(year_uis) keep(master match) nogenerate 
		
	*drop edu2* edu4*
	findfile country_iso_codes_names.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 using "`r(fn)'", keepusing(country)  keep(master match) nogenerate
		 
	hashsort iso_code category `categories_collapse'
	order iso_code country year country_year survey category `categories_collapse' `varlist_m' `varlist_no'

end
