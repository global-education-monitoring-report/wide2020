* dhs_education_out: program to create education out
* Version 1.0
* April 2020

program define dhs_education_out
	args data_path table_path
	
	
	use "`data_path'/all/dhs_educvar.dta", clear
	set more off

	*Age
	replace age = . if age >= 98
	
	*before it had the restriction "if adj==1" . I'll show both adjusted and unadjusted and a flag that says if it should be adjusted!
	generate ageA = age - 1 
	rename age ageU

	*Attendance to higher educ
	recode hv121 (1/2=1) (8/9=.), generate(attend)
	
	*Out of school
	generate eduout = .
	replace eduout = 0 if inlist(hv121, 1, 2)
	replace eduout = 1 if hv121 == 0 
	replace eduout = . if ageU == .
	replace eduout = . if inlist(hv121, 8, 9, .)
	replace eduout = . if inlist(hv122, 8, 9) & eduout == 0 
	replace eduout = 1 if hv122 == 0

	*those whose highest ed level is preschool.. DO NOT ADD THIS LINE, makes it really different to UIS estimates!! See the version 4 for the results!
	*replace eduout=1 if hv106==0  
	
	* Completion indicators (version A & B) with age limits 
	
	*Age limits for Version A and B
	foreach Y in A B {
		foreach X in prim upsec {
			foreach AGE in ageU ageA {
				gen comp_`X'_v2_`Y'_`AGE' = comp_`X'_`Y' if `AGE' >= `X'_age1 + 3 & `AGE' <= `X'_age1 + 5 
			}
		}
	}

	merge m:1 country_year using "`data_path'/all/dhs_adjustment.dta", keepusing(adj1_norm) keep(master match) nogenerate
	rename adj1_norm adjustment

	*Creating the appropiate age according to adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1

	*Age limits 
	foreach AGE in agestandard  {
		for X in any prim upsec: cap generate comp_X_v2_A = comp_X_A if `AGE' >= X_age1 + 3 & `AGE' <= X_age1 + 5
	}

	*-- Collapse for comparison with UIS (adjusted vs not adjusted)
	*collapse (mean) comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* prim_age* lowsec_age* upsec_age*  [iw=hv005], by(country_year country iso_code3 year adjustment)

	*Dropping adjusted ages and the _ageU indicators (but keep ageU)
	cap drop *ageA *_ageU

	*I keep the version B
	for X in any prim lowsec upsec: ren comp_X_B comp_X

	*Age limits 
	foreach AGE in agestandard  {
		for X in any prim lowsec upsec: generate comp_X_v2=comp_X if `AGE'>=X_age1+3 & `AGE'<=X_age1+5
		generate comp_prim_1524=comp_prim if `AGE'>=15 & `AGE'<=24
		generate comp_upsec_2029=comp_upsec if `AGE'>=20 & `AGE'<=29
		*gen comp_higher_2529=comp_higher if `AGE'>=25 & `AGE'<=29
		generate comp_lowsec_1524=comp_lowsec if `AGE'>=15 & `AGE'<=24
	}

	*-- Collapse comparing hv108 & hv109
	*collapse (mean) comp_prim_v2 comp_prim_v2_A comp_lowsec_v2 comp_upsec_v2 comp_upsec_v2_A prim_age* lowsec_age* upsec_age*  [iw=hv005], by(country_year country iso_code3 year adjustment)

	*Dropping the A version (not going to be used)
	cap drop *_A

	* FOR UIS request
	generate comp_prim_aux   = comp_prim   if agestandard >= lowsec_age1 + 3 & agestandard <= lowsec_age1 + 5
	generate comp_lowsec_aux = comp_lowsec if agestandard >= upsec_age1 + 3 & agestandard <= upsec_age1 + 5


	*With age limits
	generate eduyears_2024 = eduyears if agestandard >= 20 & agestandard <= 24
	foreach X in 2 4 {
		generate edu`X'_2024 = 0
			replace edu`X'_2024 = 1 if eduyears_2024 < `X'
			replace edu`X'_2024 = . if eduyears_2024 == .
	}

	* Never been to school
	recode hv106 (0=1) (1/3=0) (4/9=.), generate(edu0)
	generate never_prim_temp = 1 if (hv106 == 0 | hv109 == 0) & (hv107 == . & hv123 == .)
	replace edu0 = 1 if eduyears == 0 | never_prim_temp == 1
	replace edu0 = . if eduyears == .

	foreach AGE in agestandard  {
		gen edu0_prim1 = edu0 if `AGE' >= prim_age0 + 3 & `AGE' <= prim_age0 + 6
		*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
		*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
	}

	drop never_prim_temp edu0

	generate attend_higher = 0
	replace attend_higher = 1 if inlist(hv121, 1, 2) & hv122 == 3
	replace attend_higher = . if inlist(hv121, 8, 9) | inlist(hv122, 8, 9)


	*Durations for out-of-school
	generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
		
	*Creating variables for Bilal: attendance to each level by age
	*https://dhsprogram.com/Data/Guide-to-DHS-Statistics/School_Attendance_Ratios.htm

	keep country_year year age* iso_code3 hv007 sex location wealth hhweight region comp_* eduout* attend* cluster prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv122 hv124 years_*

	foreach AGE in agestandard {
		for X in any prim lowsec upsec: generate eduout_X = eduout if `AGE' >= X_age0_eduout & `AGE' <= X_age1_eduout
		generate attend_higher_1822 = attend_higher if `AGE' >= 18 & `AGE' <= 22
	}
	drop attend_higher
	
	* necessary for fcollapse
	
	* neccesary for fcollapse in summary function
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	
	foreach var in `vars' {
	cap sdecode `var', replace
	cap tostring `var', replace
	}
	
	rename ageU age
	
	* Create variables for count of observations
	foreach var of varlist `varlist_m'  {
			gen `var'_no=`var'
	}

	compress
	save  "`data_path'/all/dhs_educvar.dta", replace

end
