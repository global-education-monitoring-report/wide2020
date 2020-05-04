* mics_summary: program to summarize the mics indicators comparing with UIS and GEM data
* Version 1.0
* April 2020

program define mics_summary
	args data_path table_path 
	
	* variables to keep
	local keepvars comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec hhweight 
	local keeepvarsby hhweight country_year iso_code3 year adjustment prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout
	local keepall : list keepvars & keepvarsby 
	
	* read some variables from data
	use `keepall'  using "`data_path'/all/mics_educvar.dta", clear
	set more off

	collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec [weight=hhweight], by(country_year iso_code3 year adjustment prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
	
	foreach var of varlist comp* eduout*{
		replace `var' = `var'*100
	}
	
	* create variables
	generate category = "Total"
	generate survey = "MICS"

	* merge with year_uis
	merge 1:1 iso_code3 survey year using "`table_path'/GEM/country_survey_year_uis.dta", keepusing(year_uis) keep(master match) nogenerate

	generate location = ""
	generate sex = "" 
	generate wealth = ""

	merge 1:1 iso_code3 survey year_uis category location sex wealth using "`table_path'/UIS/UIS_indicators_29Nov2018_with_metadata.dta", keep(master match) nogenerate
	drop if survey != "MICS"
	drop iso_code2 country survey_uis location sex wealth year_uis category survey
	generate cy = lower(country_year)
	sort cy

	order iso_code3 country_year year adjustment *_uis 

	for X in any prim lowsec upsec: generate diff_comp_X = abs(comp_X_v2 - comp_X_uis)
	for X in any prim lowsec upsec: generate diff_eduout_X = abs(eduout_X - eduout_X_uis)

	foreach Y in comp eduout {
		generate flag_`Y' = 0
		*Both in UIS & GEM. Diff>3
		replace flag_`Y' = 1 if (diff_`Y'_prim >= 3 | diff_`Y'_lowsec >=3 | diff_`Y'_lowsec >=3) 
		*Only in GEM
		replace flag_`Y' = 2 if (diff_`Y'_prim == . | diff_`Y'_lowsec == . | diff_`Y'_lowsec == .) 
	}

	*Only in UIS
	for X in any comp: replace flag_X = 3 if (X_prim_v2 == . & X_prim_uis != .) 
	for X in any eduout: replace flag_X = 3 if (X_prim == . & X_prim_uis != .)

	*Neither in UIS nor in GEM. Ex: Eduout for Cuba 2010 & 2014
	for X in any comp: replace flag_X = 4 if (X_prim_v2 == . & X_prim_uis == .) 
	for X in any eduout: replace flag_X = 4 if (X_prim == . & X_prim_uis == .) 

	label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff > 3" 2 "Only in GEM" 3 "Only in UIS" 4 "Neither in UIS nor in GEM"
	for X in any comp eduout: label values flag_X flag

	keep hhweight iso_code3 country_year survey year *_uis flag_comp

	* create a temporal folder
	cap mkdir "`data_path'/all/temporal/"
	
	* combine categories 
	local categories_collapse location sex wealth region ethnicity religion
	tuples `categories_collapse'
	
	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
	local varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no
	
	foreach i of numlist 0/6 12/18 20/21 31 41 {
		collapse (mean) `varlist_m' comp_prim_aux comp_lowsec_aux (count) `varlist_no' [weight = hhweight], by(country_year iso_code3 year adjustment `tuple`i'')
		generate category = "`tuple`i''"	
		save "`data_path'/all/temporal/result`i'.dta", replace
	}
	
	cd "`data_path'/all/temporal"
	local allfiles : dir . files "*.dta", respectcase
	
	* append the results
	fs *.dta
	append using `r(files)', force
	
	generate survey = "MICS"
	
	*standardizes summary dhs & mics
	standarize_output

	save "`data_path'/all/mics_summary.dta", replace
	export delimited "`data_path'/all/mics_summary.csv", replace

	
end
