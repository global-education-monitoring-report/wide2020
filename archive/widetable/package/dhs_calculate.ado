* dhs_calculate: program to calculate years of education, education completion and education out
* Version 3.0
* January 2021
* Added indicators: comp_higher_2529 comp_higher_3034 attend_higher_1822 overage2plus literacy_1549

program define dhs_calculate
	args output_path 

	* COMPUTE THE YEARS OF EDUCATION BY COUNTRY 
	
	use "`output_path'/DHS/data/dhs_clean.dta", clear
	set more off

	* Mix of years of education completed (hv108) and duration of levels 
	generate years_prim	= prim_dur
	generate years_lowsec = prim_dur + lowsec_dur
	generate years_upsec = prim_dur + lowsec_dur + upsec_dur
	*gen years_higher	=prim_dur+lowsec_dur+upsec_dur+higher_dur


	*Ages for completion
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur-1

	replace hv108 = hv107               if inlist(hv106, 0, 1) & country_year == "RepublicofMoldova_2005"
	replace hv108 = hv107 + years_prim  if hv106 == 2 & country_year == "RepublicofMoldova_2005"
	replace hv108 = hv107 + years_upsec if hv106 == 3 & country_year == "RepublicofMoldova_2005"
	replace hv108 = 98                  if hv106 == 8 & country_year == "RepublicofMoldova_2005"
	replace hv108 = 99                  if hv106 == 9 & country_year == "RepublicofMoldova_2005"

	*Changes to hv108 made in August 2019
	replace hv108 = . 	   if country_year == "Armenia_2005"
	replace hv108 = 0          if hv106 == 0 & country_year == "Armenia_2005"
	replace hv108 = hv107      if hv106 == 1 & country_year == "Armenia_2005"
	replace hv108 = hv107 + 5  if hv106 == 2 & country_year == "Armenia_2005"
	replace hv108 = hv107 + 10 if hv106 == 3 & country_year == "Armenia_2005"

	replace hv108 = .          if country_year == "Armenia_2010"
	replace hv108 = 0          if hv106 == 0 & country_year == "Armenia_2010"
	replace hv108 = hv107      if (hv106 == 1 | hv106 == 2) & country_year == "Armenia_2010"
	replace hv108 = hv107 + 10 if hv106 == 3 & country_year == "Armenia_2010"
	
	replace hv108 = .          if country_year == "Egypt_2008" | country_year == "Egypt_2014" 
	replace hv108 = 0          if hv106 == 0 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = hv107      if hv106 == 1 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = hv107 + 6  if hv106 == 2 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = hv107 + 12 if hv106 == 3 & (country_year == "Egypt_2008" | country_year == "Egypt_2014" )
	replace hv108 = . if country_year == "Madagascar_2003"
	replace hv108 = 0          if hv106 == 0 & country_year == "Madagascar_2003"
	replace hv108 = hv107      if hv106 == 1 & country_year == "Madagascar_2003"
	replace hv108 = hv107 + 5  if hv106 == 2 & country_year == "Madagascar_2003"
	replace hv108 = hv107 + 12 if hv106 == 3 & country_year == "Madagascar_2003"
	
	replace hv108 = . if country_year == "Madagascar_2008"
	replace hv108 = 0          if hv106 == 0 & country_year == "Madagascar_2008"
	replace hv108 = hv107      if hv106 == 1 & country_year == "Madagascar_2008"
	replace hv108 = hv107 + 6  if hv106 == 2 & country_year == "Madagascar_2008"
	replace hv108 = hv107 + 13 if hv106 == 3 & country_year == "Madagascar_2008"

	replace hv108 = . if country_year == "Zimbabwe_2005"
	replace hv108 = 0          if hv106 == 0 & country_year == "Zimbabwe_2005" 
	replace hv108 = hv107      if hv106 == 1 & country_year == "Zimbabwe_2005"
	replace hv108 = hv107 + 7  if hv106 == 2 & country_year == "Zimbabwe_2005"
	replace hv108 = hv107 + 13 if hv106 == 3 & country_year == "Zimbabwe_2005"

	foreach X in prim lowsec upsec {
		generate comp_`X' = 0
		replace comp_`X'  = 1 if hv108 >= years_`X'
		replace comp_`X'  = . if (hv108 == . | hv108 >= 90) 
		replace comp_`X'  = 0 if (hv108 == 0 | hv109 == 0) 
	}
	
	replace comp_upsec = 0 if country_year == "Egypt_2005"
	replace comp_upsec = 1 if hv109 >= 4  & country_year == "Egypt_2005"
	replace comp_upsec = . if inlist(hv109, ., 8, 9) & country_year == "Egypt_2005"
	
	compress 
	save "`output_path'/DHS/data/dhs_calculate.dta", replace
	
	* ADJUST SCHOOL YEAR
	use "`output_path'/DHS/data/dhs_calculate.dta", clear
	set more off

	keep hv006 hv007 hv016 country year country_year iso_code3

	*Merge with info about reference school year
	*findfile current_school_year_DHS.dta, path("`c(sysdir_personal)'/")
	*merge m:1 country_year using  "`r(fn)'", keep(match master) nogenerate
	*drop yearwebpage currentschoolyearDHSreport
	gen school_year=.
	replace school_year=2017 if country=="Cameroon"
	replace school_year=2017 if country=="Jordan"
	replace school_year=2017 if country=="Senegal"
	replace school_year=2016 if country=="TimorLeste"
	replace school_year=2016 if country=="Uganda"
	replace school_year=2017 if country=="Pakistan"

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

	hashsort country_year
	gcollapse diff* adj* flag_month, by(country_year)		
	save "`output_path'/DHS/data/dhs_adjustment.dta", replace
	
	* COMPUTE IF SOMEONE DOES NOT GO TO SCHOOL (education out)
	
	use "`output_path'/DHS/data/dhs_calculate.dta", clear
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

	* Completion indicators with age limits 
	foreach X in prim upsec {
		foreach AGE in ageU ageA {
			generate comp_`X'_v2_`AGE' = comp_`X' if `AGE' >= `X'_age1 + 3 & `AGE' <= `X'_age1 + 5 
		}
	}
	

	merge m:1 country_year using "`output_path'/DHS/data/dhs_adjustment.dta", keepusing(adj1_norm) keep(master match) nogenerate
	rename adj1_norm adjustment

	*Creating the appropiate age according to adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1

	*Dropping adjusted ages and the _ageU indicators (but keep ageU)
	capture drop *ageA *_ageU
	
	*******COMPLETION********
	*for X in any prim lowsec upsec: rename comp_X_B comp_X
	*Age limits 
	foreach AGE in agestandard  {
		for X in any prim lowsec upsec: generate comp_X_v2 = comp_X if `AGE' >= X_age1+3 & `AGE' <= X_age1+5
		generate comp_prim_1524 = comp_prim if `AGE' >= 15 & `AGE' <= 24
		generate comp_upsec_2029 = comp_upsec if `AGE' >= 20 & `AGE' <= 29
		generate comp_lowsec_1524 = comp_lowsec if `AGE' >= 15 & `AGE' <= 24
	}
	*******/COMPLETION********


	*capture drop *_A
//	turn this off because no longer needed
// 	generate comp_prim_aux = comp_prim   if agestandard >= lowsec_age1 + 3 & agestandard <= lowsec_age1 + 5
// 	generate comp_lowsec_aux = comp_lowsec if agestandard >= upsec_age1 + 3 & agestandard <= upsec_age1 + 5
	
	*******EDUYEARS AND LESS THAN 2/4 YEARS OF SCHOOLING********
	* create eduyears, max of years as 30 
	generate eduyears = hv108
	replace eduyears = . if hv108 >= 90
	replace eduyears = 30 if hv108 >= 30 & hv108 < 90
	
	*With age limits
	generate eduyears_2024 = eduyears if agestandard >= 20 & agestandard <= 24
	foreach X in 2 4 {
		generate edu`X'_2024 = 0
			replace edu`X'_2024 = 1 if eduyears_2024 < `X'
			replace edu`X'_2024 = . if eduyears_2024 == .
	}
	*******/EDUYEARS AND LESS THAN 2/4 YEARS OF SCHOOLING********
	
		*******HIGHER COMPLETION********

	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = 1 if hv106 == 3
		replace comp_higher_`X'yrs = 0 if hv109 == 0
		replace comp_higher_`X'yrs = 0 if hv106 == 0 
	}
	replace comp_higher_2yrs = 1 if hv106==3
	replace comp_higher_4yrs = 1 if hv106==3

	replace comp_higher_2yrs = 1 if eduyears >= years_upsec + 2
	replace comp_higher_4yrs = 1 if eduyears >= years_upsec + 4
	
	
 	*Ages for completion higher
 	foreach X in 2 4{
 		generate comp_higher_`X'yrs_2529 = comp_higher_`X'yrs if agestandard >= 25 & agestandard <= 29
 	}
 	foreach X in 4{
 		generate comp_higher_`X'yrs_3034 = comp_higher_`X'yrs if agestandard >= 30 & agestandard <= 34
 		drop comp_higher_`X'yrs 
 	}
	
	*******/HIGHER COMPLETION********

	*******NEVER BEEN TO SCHOOL********
	* Never been to school
	recode hv106 (0 = 1) (1/3 = 0) (4/9 = .), generate(edu0)
	generate never_prim_temp = 1 if (hv106 == 0 | hv109 == 0) & (hv107 == . & hv123 == .)
	replace edu0 = 1 if eduyears == 0 | never_prim_temp == 1
	replace edu0 = . if eduyears == .

	foreach AGE in agestandard  {
		gen edu0_prim = edu0 if `AGE' >= prim_age0 + 3 & `AGE' <= prim_age0 + 6
		*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
		*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
	}
	drop never_prim_temp edu0
	*******/NEVER BEEN TO SCHOOL********

	*******ATTEND HIGHER AND EDUOUT********
	generate attend_higher = 0
	replace attend_higher = 1 if inlist(hv121, 1, 2) & hv122 == 3
	replace attend_higher = . if inlist(hv121, 8, 9) | inlist(hv122, 8, 9)

	*Durations for out-of-school
	generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
	keep country_year year age* iso_code3 hv007 sex location wealth religion ethnicity hhweight region comp_* eduout* attend* literacy cluster prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv122 hv123 hv124 years_*

	foreach AGE in agestandard {
		for X in any prim lowsec upsec: generate eduout_X = eduout if `AGE' >= X_age0_eduout & `AGE' <= X_age1_eduout
		generate attend_higher_1822 = attend_higher if `AGE' >= 18 & `AGE' <= 22
	}
	drop attend_higher
	*******/ATTEND HIGHER AND EDUOUT********

	
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = "" if `var' == "."
	}
	
	rename ageU age
	
	*******OVER AGE PRIMARY ATTENDANCE**********
	*Over-age primary school attendance
	*Percentage of children in primary school who are two years or more older than the official age for grade.
	gen overage2plus= 0 if attend==1 & inlist(hv122, 1)
	levelsof prim_dur, local(primyears)
	local i=0
    foreach grade of numlist 1/`primyears' {
				local i=`i'+1
				replace overage2plus=1 if hv123==`grade' & age>prim_age0+1+`i' & overage2plus!=. 
                 }
	*******/OVER AGE PRIMARY ATTENDANCE**********

	*******LITERACY**********
	*Literacy
	recode literacy (0 = 0) (1 2 = 1) (3 4 = .)
	*1 cannot read at all
	*2 able to read only parts or whole sentence
	*3 no card with required language
	*4 blind/visually impaired
	gen literacy_1524=literacy if age >= 15 & age <= 24
	replace literacy_1524=1 if eduyears >= years_lowsec & (age >= 15 & age <= 24)
	*******/LITERACY**********

	
	* Create variables for count of observations
	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec edu0_prim comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 attend_higher_1822 overage2plus literacy_1524
	
	foreach var of varlist `varlist_m'  {
			generate `var'_no = `var'
	}

	compress
	save  "`output_path'/DHS/data/dhs_calculate.dta", replace

end
