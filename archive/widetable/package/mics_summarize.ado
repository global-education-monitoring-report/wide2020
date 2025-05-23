* mics_summarize: program to summarize the mics indicators
* Version 3.0
* April 2020

program define mics_summarize
	args output_path 
	
	* automate file names using current date 
	local today : di  %tdCY-N-D  daily("$S_DATE", "DMY")
	local time : di subinstr(c(current_time),":", "", .)
	
	* create a temporal folder
	cd "`output_path'/MICS/"
	capture mkdir "`output_path'/MICS/temporal/"
	cd "`output_path'/MICS/temporal/"
	
	* combine categories 
	local categories_collapse location sex wealth region ethnicity religion
	tuples `categories_collapse', display
	
	* defining local macro
	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 attend_higher_1822 edu0_prim overage2plus literacy_1524 
	
	local varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no attend_higher_1822_no overage2plus_no literacy_1524_no
	
	local varsby country_year iso_code3 year adjustment
	
	local keepvars location sex wealth region ethnicity religion hhweight comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec edu0_prim comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 attend_higher_1822 overage2plus literacy_1524 comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no  comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no attend_higher_1822_no overage2plus_no literacy_1524_no country_year iso_code3 year adjustment
	
	* mean estimation 
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		use `keepvars' using "`output_path'/MICS/data/mics_calculate.dta", clear
		set more off
		gcollapse (mean) `varlist_m'  [aw = hhweight], by(`varsby' `tuple`i'') 
		save "resultm_`i'.dta", replace
	}
	
	* count observations
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		use `keepvars' using "`output_path'/MICS/data/mics_calculate.dta", clear
		gcollapse (count) `varlist_no' [aw = hhweight], by(`varsby' `tuple`i'') 
		save "resultc_`i'.dta", replace
	}
	
	* mean and count
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		use  "resultm_`i'.dta", clear
		merge 1:1 country_year adjustment `tuple`i'' using "resultc_`i'.dta", nogenerate
		generate category = "`tuple`i''"	
	    save "result_`i'.dta", replace
	}
	
	* delete intermediate files
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		erase "resultc_`i'.dta"
		erase "resultm_`i'.dta"
	}

	* append the results
	clear all
	fs *.dta
	append using `r(files)', force
	
	*standardizes summary dhs & mics
	generate survey = "MICS"
	standarize_output

	save "`output_path'/MICS/mics_summarize_`today'T`time'.dta", replace
	export delimited "`output_path'/MICS/mics_summarize_`today'T`time'.csv", replace
	rmfiles , folder("`output_path'/MICS/temporal") match("*.dta") rmdirs
	cd "`output_path'/MICS/"
	rmdir "temporal"
end
