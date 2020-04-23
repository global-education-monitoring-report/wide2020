* dhs_summary:
* Version 1.0
* April 2020

program define dhs_summary
	args input_path output_path 
	
	*odbc load, exec("SELECT age, sex FROM dhs;")
	
	* load a few variables from  a dta file
	 use country sex hhweight location wealth using `input_path' 
	
	* CREATING THE DISSAGREGATION VARIABLES & weight

	*table country_year [iw=hhweight], c(mean comp_prim_v2 mean comp_lowsec_v2 mean comp_upsec_v2)

	label define location 0 "rural" 1 "urban"
	label define sex 0 "female" 1 "male"
	label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"

	for Z in any location sex wealth: label values Z Z

	*Converting the categories to strings
	foreach var in location sex wealth {
		cap sdecode `var', replace
		cap replace `var'=proper(`var')
	}
	
	
	ren ageU age

	order country_year iso_code3 year hhweight age* hv007 $categories_collapse comp_* eduout* edu* attend* $extra_vars round adjustment
	compress
	*save "$data_dhs\PR\Step3_part3.dta", replace
	save "$data_dhs\PR\Step3_`part'.dta", replace
	}



	*********************************************************************************************************************************
	global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
	global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
	global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
	global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no


	foreach part in part1 part2 part3 {
	use "$data_dhs\PR\Step3_`part'.dta", clear
	*use "$data_dhs\PR\Step3_part3.dta", clear
	set more off

	*Dropping variables
	drop hhid hvidx individual_id lowsec_age0 upsec_age0 prim_age1 lowsec_age1 upsec_age1 eduyears adjustment

	*--The year is the median of the year of interview
	drop year
	bys country_year: egen year=median(hv007)

	*Create variables for count of observations
	foreach var of varlist $varlist_m  {
			gen `var'_no=`var'
	}

	keep country_year iso_code3 year $categories_collapse hhweight $varlist_m $varlist_no comp_prim_aux comp_lowsec_aux
	compress
	*save "$data_dhs\PR\Step4_part3.dta", replace
	save "$data_dhs\PR\Step4_`part'.dta", replace
	}

	***************
	*https://www.stata.com/meeting/baltimore17/slides/Baltimore17_Correia.pdf

	cap mkdir "$data_dhs\PR\collapse"


	/*
	cd "$data_dhs\PR\collapse"
	foreach part in part1 part2 part3 {
	*foreach part in part3 {
	use "$data_dhs\PR\Step4_`part'.dta", clear
	set more off
	tuples $categories_collapse, display
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		preserve
		collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year `tuple`i'')
		*collapse (mean) $varlist_m comp_prim_aux comp_lowsec_aux (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year `tuple`i'')
		gen category="`tuple`i''"
		cap gen part="`part'"
		save "result`i'_`part'.dta", replace
		restore
	}
	}
	*/

	* Appending the results
	cd "$data_dhs\PR\collapse"
	cap use "result0_part1.dta", clear
	gen t_0=1
	foreach part in part1 part2 part3 {
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		append using "result`i'_`part'"
	}
	}
	gen survey="DHS"
	include "$gral_dir/WIDE/programs/standardizes_collapse_dhs_mics.do"

	save "$data_dhs\PR\dhs_collapse_by_categories_v10.dta", replace
	export delimited "$data_dhs\PR\dhs_collapse_by_categories_v10.csv", replace

end
