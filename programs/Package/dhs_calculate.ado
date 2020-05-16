* dhs_calculate: program to calculate years of education, education completion and education out
* Version 2.0
* April 2020

program define dhs_calculate
	args data_path 

	* COMPUTE THE YEARS OF EDUCATION BY COUNTRY 
	
	use "`data_path'/DHS/dhs_clean.dta", clear
	set more off
	
	* CHANGES IN HV108

	*Republic of Moldova doesn't have info on eduyears
	if country_year == "RepublicofMoldova_2005"{
		replace hv108 = hv107               if (hv106 == 0 | hv106 == 1)
		replace hv108 = hv107 + years_prim  if hv106 == 2 
		replace hv108 = hv107 + years_upsec if hv106 == 3
		replace hv108 = 98                  if hv106 == 8 
		replace hv108 = 99                  if hv106 == 9 
	} 
	else if  country_year == "Armenia_2005" {
		*Changes to hv108 made in August 2019
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 5  if hv106 == 2 
		replace hv108 = hv107 + 10 if hv106 == 3 
	}
	else if country_year == "Armenia_2010" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 | hv106 == 2 
		replace hv108 = hv107 + 10 if hv106 == 3 
	}
	else if country_year == "Egypt_2008" | country_year == "Egypt_2014" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 6  if hv106 == 2 
		replace hv108 = hv107 + 12 if hv106 == 3 
	}
	else if country_year == "Madagascar_2003" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 5  if hv106 == 2 
		replace hv108 = hv107 + 12 if hv106 == 3
	}
	else if country_year == "Madagascar_2008" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 6  if hv106 == 2 
		replace hv108 = hv107 + 13 if hv106 == 3  
	}
	else if country_year == "Zimbabwe_2005" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0  
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 7  if hv106 == 2 
		replace hv108 = hv107 + 13 if hv106 == 3 
	}
	else {
		replace hv108 = hv108
	}
	
	* create eduyears, max of years as 30 
	generate eduyears = hv108
	replace eduyears = 30 if hv108 >= 30
	replace eduyears = . if hv108 >= 90

	*Hv108: 
	*Albania 2017: doesn't have hv108==10, 11
	*Mali 2018: doesn't have hv108==11
	*Haiti 2017, Pakistan 2018, South Africa 2016: only goes until 16 years
	*Indonesia 2017, Maldives 2017, Mali 2018: only goes until 17 years

	
	* COMPUTE EDUCATION COMPLETION (the level reached in primary, secondary, etc.)
	* VERSION A
	* For Completion: Version A is directly with hv109; Version B uses years of education and duration
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
		capture generate comp_`X'_B = 0
		 	replace comp_`X'_B  = 1 if hv108 >= years_`X'
			replace comp_`X'_B  = . if (hv108 == . | hv108 >= 90) 
			replace comp_`X'_B  = 0 if (hv108 == 0 | hv109 == 0) 
	}

	*For 2 countries, I use hv109 (I don't find other solution). I don't know why if goes to 28.93 if I don't do this
	replace comp_upsec_B = comp_upsec_A if country_year == "Egypt_2005" 

	compress 
	save "`data_path'/DHS/dhs_calculate.dta", replace
	

	* ADJUST SCHOOL YEAR
	
	use "`data_path'/DHS/dhs_calculate.dta", clear
	set more off

	keep hv006 hv007 hv016 country year country_year iso_code3

	*Merge with info about reference school year
	findfile current_school_year_DHS.dta, path("`c(sysdir_personal)'/")
	merge m:1 country_year using  "`r(fn)'", keep(match master) nogenerate
	drop yearwebpage currentschoolyearDHSreport

	generate year_c = hv007
	replace year_c = 2017 if year_c >= 2018 
	
	findfile month_start.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 year_c using "`r(fn)'", keep(master match) nogenerate
	drop max_month min_month diff year_c

	*All countries have month_start. Malawi_2015 has now the month 9 (OK)
	rename school_year current_school_year

	*For those with missing in school year, I replace by the interview year
	generate missing_current_school_year = 1 if current_school_year == .
	replace current_school_year = hv007 if current_school_year == .

	* Adjustment VERSION 1: Difference in number of days 
	*-	Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
	*- Interview		: Month as presented in the survey data
		
		generate month_start_norm = month_start
		
	*Taking into account the days	
		generate one = string(1)
		for X in any norm max min: catenate s_school1_X = one month_start_X current_school_year, p("/")
		*date of the interview created with the original info
		catenate s_interview1 = hv016 hv006 hv007, p("/")  

		for X in any norm max min: generate date_school1_X = date(s_school1_X, "DMY", 2000) 
		generate date_interview1 = date(s_interview1, "DMY", 2000)
		
	*Without taking into account the days
		for X in any norm max min: catenate s_school2_X = month_start_X current_school_year, p("/")
		*date of the interview created with the original info
		catenate s_interview2 = hv006 hv007, p("/") 
		
		*official month of start... plus school year of reference
		for X in any norm max min: generate date_school2_X = date(s_school2_X, "MY", 2000) 
		generate date_interview2 = date(s_interview2, "MY", 2000)

	*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
	*Median difference is >=6.
	*50% of hh have 6 months of difference or more
	*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

	foreach M in norm max min {
		foreach X in 1 2 {
			generate diff`X'_`M' = (date_interview`X' - date_school`X'_`M')
			generate temp`X'_`M' = mod(diff`X'_`M', 365) 
			replace diff`X'_`M' = temp`X'_`M' if missing_current_school_year == 1
			bys country_year: egen median_diff`X'_`M' = median(diff`X'_`M')
			generate adj`X'_`M' = 0
			replace adj`X'_`M' = 1 if median_diff`X'_`M' >= 182
		}
	}

	sort country_year

	*see gcollapse
	collapse diff* adj* flag_month, by(country_year)		

	save "$data_path/DHS/dhs_adjustment.dta", replace

	
	* COMPUTE IF SOMEONE DOES NOT GO TO SCHOOL (education out)
	
	use "`data_path'/DHS/dhs_calculate.dta", clear
	set more off

	*Age
	replace age = . if age >= 98
	
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

	* Completion indicators (version A & B) with age limits 
	
	*Age limits for Version A and B
	foreach Y in A B {
		foreach X in prim upsec {
			foreach AGE in ageU ageA {
				gen comp_`X'_v2_`Y'_`AGE' = comp_`X'_`Y' if `AGE' >= `X'_age1 + 3 & `AGE' <= `X'_age1 + 5 
			}
		}
	}

	merge m:1 country_year using "`data_path'/DHS/dhs_adjustment.dta", keepusing(adj1_norm) keep(master match) nogenerate
	rename adj1_norm adjustment

	*Creating the appropiate age according to adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1

	*Age limits 
	foreach AGE in agestandard  {
		for X in any prim upsec: capture generate comp_X_v2_A = comp_X_A if `AGE' >= X_age1 + 3 & `AGE' <= X_age1 + 5
	}

	*Dropping adjusted ages and the _ageU indicators (but keep ageU)
	capture drop *ageA *_ageU

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

	*Dropping the A version (not going to be used)
	capture drop *_A

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
		
	keep country_year year age* iso_code3 hv007 sex location wealth hhweight region comp_* eduout* attend* cluster prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv122 hv124 years_*

	foreach AGE in agestandard {
		for X in any prim lowsec upsec: generate eduout_X = eduout if `AGE' >= X_age0_eduout & `AGE' <= X_age1_eduout
		generate attend_higher_1822 = attend_higher if `AGE' >= 18 & `AGE' <= 22
	}
	drop attend_higher
	
	* neccesary for fcollapse in summary function
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	
	foreach var in `vars' {
	capture sdecode `var', replace
	capture tostring `var', replace
	}
	
	rename ageU age
	
	* Create variables for count of observations
	foreach var of varlist `varlist_m'  {
			gen `var'_no=`var'
	}

	compress
	save  "`data_path'/DHS/dhs_calculate.dta", replace
