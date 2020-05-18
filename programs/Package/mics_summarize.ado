* mics_summarize: program to summarize the mics indicators (mean and total estimation)
* Version 3.0
* April 2020

program define mics_summarize
	args data_path output_path 
	
	* automate file names using current date 
	local today : di %tdDNCY daily("$S_DATE", "DMY")
			
	* create a temporal folder
	cd "`output_path'"
	capture mkdir "`output_path'/MICS/"
	capture mkdir "`output_path'/MICS/temporal/"
	cd "`output_path'/MICS/temporal"
	
	* combine categories 
	local categories_collapse location sex wealth region ethnicity religion
	tuples `categories_collapse'
	
	* defining local macro
	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
	
	local varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no
	
	local varsby country_year iso_code3 year adjustment
	
	local keepvars location sex wealth region ethnicity religion hhweight comp_prim_aux comp_lowsec_aux comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no country_year iso_code3 year adjustment
	
	* mean estimation 
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		use `keepvars' using "`data_path'/MICS/mics_calculate.dta", clear
		gcollapse (mean) `varlist_m' comp_prim_aux comp_lowsec_aux [aw = hhweight], by(`varsby' `tuple`i'') fast
		save "resultm_`i'.dta", replace
	}
	
	* total estimation
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		use `keepvars' using "`data_path'/MICS/mics_calculate.dta", clear
		gcollapse (count) `varlist_no' [aw = hhweight], by(`varsby' `tuple`i'') fast
		save "resultc_`i'.dta", replace
	}
	
	* mean and total
	foreach i of numlist 0/6  12/18 20/21 31 41 {
		use  "resultm_`i'.dta", clear
		merge 1:1 country_year iso_code3 year adjustment `tuple`i'' using "resultc_`i'.dta", nogenerate
		generate category = "`tuple`i''"	
	    save "result_`i'.dta", replace
	}
	
	* delete intermediate files
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		erase "resultc_`i'.dta"
		erase "resultm_`i'.dta"
	}

	* append the results
	fs *.dta
	append using `r(files)', force
	
	*standardizes summary dhs & mics
	generate survey = "MICS"
	standarize_output

	save "`output_path'/MICS/mics_summarize_`today'.dta", replace
	export delimited "`output_path'/MICS/mics_summarize_`today'.csv", replace
	
end
