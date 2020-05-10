* mics_education_out: program to compute if someone does not go to school
* Version 1.0
* April 2020

program define mics_education_out
	args data_path table_path 
	
	* read data
	use "`data_path'/all/mics_educvar.dta", clear
	set more off

	*Creating age groups for preschool
	generate age_group = 1 if inlist(ageU, 3, 4)
	replace age_group  = 2 if ageU == 5
	replace age_group  = 3 if inlist(ageU, 6, 7, 8)

	label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
	label values age_group age_group

	generate presch_before = 1 if (ed7 == "yes" | ed7 == "1") & code_ed8a == 0
		
	generate attend_primary = 1 if attend == 1 & inlist(code_ed6a, 1, 60, 70)
	replace attend_primary  = 0 if attend == 1 & code_ed6a == 0
	replace attend_primary  = 0 if attend == 0
		
	* enrolment rate in pre-primary relative to the population, by single age
	* can be created with attend_preschool, with no restriction of preschool before

	* generate no_attend the attend complement
	recode attend (1=0) (0=1), gen(no_attend)

	* generate eduout
	* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
	generate eduout = no_attend
	replace eduout  = . if (attend == 1 & code_ed6a == .) | age == . | (inlist(code_ed6a,. , 98, 99) & eduout == 0)
	replace eduout  = 1 if code_ed6a == 0 | ed3 == "no" 
	*Code_ed6a=80/90 affects countries Nigeria 2011, Nigeria 2016, Mauritania 2015, SouthSudan 2010, Sudan 2010 2014
	* level attended=not formal/not regular/not standard
	replace eduout = 1 if code_ed6a == 80 
	* level attended=khalwa/coranique (ex. Mauritania, SouthSudan, Sudan)
	replace eduout = 1 if code_ed6a == 90 
	

	*special cases: Barbados 2012, Nepal 2014
	if country_year == "Nepal_2014"{
		replace eduout = no_attend
		replace eduout = . if (ed6b == "missing" | ed6b == "don't know") & eduout == 0
		replace eduout = 1 if ed6b == "preschool" | ed3 == "no"
	}

	if country_year == "Barbados_2012"{
		replace eduout = no_attend
		replace eduout = . if (attend == 1 & code_ed6a == .)
		replace eduout = . if inlist(code_ed6a, 98, 99) & eduout == 0
		replace eduout = . if ed6a_nr == 0 
		replace eduout = 1 if ed3 == "no"
	}

	*Mauritania 2011
	if country_year == "Mauritania_2011" {
		replace attend = 0
		replace attend = 1 if ed5 == "yes"
		replace attend = . if ed5 == "missing"

		recode attend (1=0) (0=1), generate(eduout)
		replace eduout = . if inlist(code_ed6a, 98, 99) & eduout == 0
		replace eduout = 1 if code_ed6a == 0 
		replace eduout = 1 if ed3 == "no"
	}

	* Merging with adjustment
	merge m:1 country_year using "`data_path'/all/mics_adjustment.dta", keepusing(adj1_norm) nogen
	rename adj1_norm adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1
	cap drop *ageU *ageA 

	*Confirming that schage is available (for example, it is not available for South Sudan 2010)
	bys country_year: egen temp_count = count(schage)
	replace schage = age if temp_count == 0 & adjustment == 0
	replace schage = age-1 if temp_count == 0 & adjustment == 1
	drop temp_count

	*Age limits for completion and out of school
	*Age limits 
	foreach X in prim lowsec upsec {
		generate comp_`X'_v2 = comp_`X' if schage >= `X'_age1 + 3 & schage <= `X'_age1 + 5
	}

	* FOR UIS request
	generate comp_prim_aux   = comp_prim   if schage >= lowsec_age1 + 3 & schage <= lowsec_age1 + 5
	generate comp_lowsec_aux = comp_lowsec if schage >= upsec_age1 + 3  & schage <= upsec_age1 + 5


	*foreach AGE in agestandard  {
	foreach AGE in schage  {
		generate comp_prim_1524   = comp_prim if `AGE' >= 15 & `AGE' <= 24
		generate comp_upsec_2029  = comp_upsec if `AGE' >= 20 & `AGE' <= 29
		generate comp_lowsec_1524 = comp_lowsec if `AGE' >= 15 & `AGE' <= 24
	}

	*With age limits
	*gen eduyears_2024=eduyears if agestandard>=20 & agestandard<=24
	generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24
	
	foreach X in 2 4 {
		generate edu`X'_2024 = 0
		replace edu`X'_2024  = 1 if eduyears_2024 < `X'
		replace edu`X'_2024  = . if eduyears_2024 == .
	}

	* NEVER BEEN TO SCHOOL
	generate edu0 = 0 if ed3 == "yes"
	replace edu0  = 1 if ed3 == "no"
	replace edu0  = 1 if code_ed4a == 0
	replace edu0  = 1 if eduyears == 0

	foreach AGE in schage  {
		gen edu0_prim=edu0 if `AGE' >= prim_age0 + 3 & `AGE'<=prim_age0 + 6
		*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
		*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
	}
	drop edu0

	*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		*replace comp_higher_`X'yrs = 1	if eduyears >= years_upsec + `X'
		replace comp_higher_`X'yrs = . 	if inlist(eduyears, ., 97, 98, 99)
		replace comp_higher_`X'yrs = 0 	if ed3 == "no"  
		replace comp_higher_`X'yrs = 0 	if code_ed4a == 0 
	}
	replace comp_higher_2yrs = 1 if eduyears >= years_upsec + 2
	replace comp_higher_4yrs = 1 if eduyears >= years_upsec + 4

	*Ages for completion higher
	foreach X in 2 4{
		generate comp_higher_`X'yrs_2529 = comp_higher_`X'yrs if schage >= 25 & schage <= 29
	}
	foreach X in 4{
		generate comp_higher_`X'yrs_3034 = comp_higher_`X'yrs if schage >= 30 & schage <= 34
		drop comp_higher_`X'yrs 
	}

	for X in any prim_dur lowsec_dur upsec_dur prim_age0 : rename X X_comp

		
	*Durations for OUT-OF-SCHOOL & ATTENDANCE 
	merge m:1 iso_code3 year using "`table_path'/UIS/duration_age/UIS_duration_age_25072018.dta", keep(master match) nogenerate
	drop lowsec_age_uis upsec_age_uis
		
	for X in any prim_dur lowsec_dur upsec_dur: rename X_uis X_eduout
	rename prim_age_uis prim_age0_eduout

	generate lowsec_age0_eduout = prim_age0_eduout   + prim_dur_eduout
	generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
		
	*Age limits for out of school
	foreach X in prim lowsec upsec {
		generate eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}

	*Age limit for Attendance:
	*-- PRESCHOOL 3
	generate attend_preschool   = 1 if attend == 1 & code_ed6a == 0
	replace attend_preschool    = 0 if attend == 1 & code_ed6a != 0
	replace attend_preschool    = 0 if attend == 0
	generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	generate preschool_1ybefore = attend_preschool if schage == prim_age0_eduout - 1

	*-- HIGHER ED
	generate high_ed       = 1 if inlist(code_ed6a, 3, 32, 33, 40)
	generate attend_higher = 1 if attend == 1 & high_ed == 1
	replace attend_higher  = 0 if attend == 1 & high_ed != 1
	replace attend_higher  = 0 if attend == 0
	generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

	* Create variables for count of observations
	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
	foreach var of varlist `varlist_m' {
			generate `var'_no = `var'
	}
	
	* neccesary for fcollapse in summary function
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	
	foreach var in `vars' {
	cap sdecode `var', replace
	cap tostring `var', replace
	}
	
		
	* save data		
	compress
	save "`data_path'/all/mics_educvar.dta", replace

end
	
