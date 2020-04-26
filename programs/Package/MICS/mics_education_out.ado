* mics_education_out: program to compute if someone does not go to school
* Version 1.0
* April 2020

program define mics_education_out
	args
	
	use "$data_mics\hl\Step_4.dta", clear
	set more off

	*--------- TEMPORARY
	encode country_year, gen(c_n)
	keep if c_n<=27

	drop  region district ethnicity religion wealth hh5d hh5m hh5y urban
	drop year_folder cluster hh6 individual_id hh_id country_code_dhs
	compress

	*Dropping the B version because it is not going to be used. 
	drop *_B_ageU *_B_ageA *_B // the version C is the one to keep
	drop *C_ageU *C_ageA
	drop hl*
	*Renaming the vars from _C
	foreach var in comp_prim comp_lowsec comp_upsec comp_higher eduyears {
		rename `var'_C `var'
	}
	drop c_n
	compress
	save "$data_mics\hl\SUBSET_Step_4.dta", replace
	*/

	**********************************************************************************************************
	**********************************************************************************************************

	use "$data_mics\hl\Step_4.dta", clear
	set more off

	*Dropping the B version because it is not going to be used. 
	drop *_B_ageU *_B_ageA *_B // the version C is the one to keep
	drop *C_ageU *C_ageA

	*Renaming the vars from _C
	foreach var in comp_prim comp_lowsec comp_upsec comp_higher eduyears {
		rename `var'_C `var'
	}

	*---------------
	/*
	*Bilal's request

	*Creating age groups for preschool
	gen age_group=1 if (ageU==3|ageU==4)
	replace age_group=2 if ageU==5
	replace age_group=3 if (ageU==6|ageU==7|ageU==8)

	label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
	label values age_group age_group

	gen presch_before=1 if (ed7=="yes"|ed7=="1") & code_ed8a==0
	tab attend if presch_before==1 // until here it is ok

	gen attend_primary=1 if attend==1 & (code_ed6a==1|code_ed6a==60|code_ed6a==70)
	replace attend_primary=0 if attend==1 & code_ed6a==0
	replace attend_primary=0 if attend==0
	*/



	*enrolment rate in pre-primary relative to the population, by single age
	*- can be created with attend_preschool, with no restriction of preschool before

	*the new entry into pre-primary (i.e. not enrolled in education at all last year, enrolled in pre-primary this year), by single age?

	cap drop eduout

	recode attend (1=0) (0=1), gen(no_attend)

	generate eduout = no_attend
		replace eduout = . if (attend == 1 & code_ed6a == .)
		replace eduout = . if age == .
		replace eduout = . if (code_ed6a == 98 | code_ed6a == 99) & eduout == 0 // missing when age, attendance or level of attendance (when goes to school) is missing
		replace eduout = 1 if code_ed6a == 0 | ed3 == "no" // level attended: goes to preschool. "out of school" if "ever attended school"=no 


		replace eduout=1 if code_ed6a==80 // level attended=not formal/not regular/not standard
		replace eduout=1 if code_ed6a==90 // level attended=khalwa/coranique (ex. Mauritania, SouthSudan, Sudan)
		*Code_ed6a=80/90 affects countries Nigeria 2011, Nigeria 2016, Mauritania 2015, SouthSudan 2010, Sudan 2010 2014


	*Especial cases: Barbados 2012, Nepal 2014
	if country_year == "Nepal_2014"{
		replace eduout = no_attend
		replace eduout = . if (ed6b == "missing" | ed6b == "don't know") & eduout == 0
		replace eduout = 1 if ed6b=="preschool" | ed3=="no"
	}

	if country_year == "Barbados_2012"{
		replace eduout = no_attend
		replace eduout = . if (attend == 1 & code_ed6a == .)
		replace eduout = . if (code_ed6a == 98 | code_ed6a == 99) & eduout == 0
		replace eduout = . if ed6a_nr == 0 // level attended: goes to preschool
		replace eduout = 1 if ed3 == "no"
	}


	*Mauritania 2011

	if country_year == "Mauritania_2011" {
		replace attend = 0
		replace attend = 1 if ed5 == "yes"
		replace attend = . if ed5 == "missing"

		recode attend (1=0) (0=1), generate(eduout)
		replace eduout = . if (code_ed6a == 98 | code_ed6a == 99) & eduout == 0
		replace eduout = 1 if code_ed6a == 0 // goes to preschool
		replace eduout = 1 if ed3 == "no"
	}


	*Merging with adjustment
	merge m:1 country_year using "$data_mics\hl\mics4&5_adjustment.dta", keepusing(adj1_norm) nogen
	rename adj1_norm adjustment

	generate agestandard = ageU if adjustment == 0
		replace agestandard = ageA if adjustment == 1
	cap drop *ageU *ageA 

	*Confirming that schage is available (for example, it is not available for South Sudan 2010)
	bys country_year: egen temp_count = count(schage)
	*tab country_year if temp_count==0
	replace schage = age if temp_count == 0 & adjustment == 0
	replace schage = age-1 if temp_count == 0 & adjustment == 1
	drop temp_count


	*Age limits for completion and out of school


	*Age limits 
	foreach X in prim lowsec upsec {
		generate comp_`X'_v2=comp_`X' if schage >= `X'_age1 + 3 & schage <= `X'_age1 + 5
	}

	* FOR UIS request
	generate comp_prim_aux = comp_prim if schage >= lowsec_age1 + 3 & schage <= lowsec_age1 + 5
	generate comp_lowsec_aux = comp_lowsec if schage >= upsec_age1 + 3 & schage <= upsec_age1 + 5


	*foreach AGE in agestandard  {
	foreach AGE in schage  {
		generate comp_prim_1524 = comp_prim if `AGE' >= 15 & `AGE' <= 24
		generate comp_upsec_2029 = comp_upsec if `AGE' >= 20 & `AGE' <= 29
		generate comp_lowsec_1524 = comp_lowsec if `AGE' >= 15 & `AGE' <= 24
	}

	*With age limits
	*gen eduyears_2024=eduyears if agestandard>=20 & agestandard<=24
	generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24
	
	foreach X in 2 4 {
		generate edu`X'_2024 = 0
			replace edu`X'_2024 = 1 if eduyears_2024 < `X'
			replace edu`X'_2024 = . if eduyears_2024 == .
	}

	* NEVER BEEN TO SCHOOL
	gen edu0 = 0 if ed3 == "yes"
	replace edu0 = 1 if ed3 == "no"
	replace edu0 = 1 if (code_ed4a == 0) // highest ever attended is preschool
	replace edu0 = 1 if (eduyears == 0)

	*tab code_ed6a attend , m 

	foreach AGE in schage  {
		gen edu0_prim=edu0 if `AGE'>=prim_age0+3 & `AGE'<=prim_age0+6
		*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
		*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
	}
	drop edu0

	*Completion of higher
	foreach X in 2 4 {
		gen comp_higher_`X'yrs=0
		replace comp_higher_`X'yrs=1	if eduyears>=years_upsec+`X' //  2 or 4 years after
		replace comp_higher_`X'yrs=. 	if (eduyears==.|eduyears==97|eduyears==98|eduyears==99)
		replace comp_higher_`X'yrs=0 	if ed3=="no"  // those that never went to school have not completed!
		replace comp_higher_`X'yrs=0 	if code_ed4a==0 // those that went to kindergarten max have no completed primary.
	}

	*Ages for completion higher
	for X in any 2 4: gen comp_higher_Xyrs_2529=comp_higher_Xyrs if schage>=25 & schage<=29
	for X in any 4  : gen comp_higher_Xyrs_3034=comp_higher_Xyrs if schage>=30 & schage<=34
	drop comp_higher_2yrs comp_higher_4yrs

	for X in any prim_dur lowsec_dur upsec_dur prim_age0 : ren X X_comp

	*-------------------------------------------------------------------------------------------------------------
	*Durations for OUT-OF-SCHOOL & ATTENDANCE 
	*"$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	merge m:1 iso_code3 year using `table_path', keep(master match) nogenerate
		drop lowsec_age_uis upsec_age_uis
		for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X_eduout
		rename prim_age_uis prim_age0_eduout

		generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
		generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
		for X in any prim lowsec upsec: gen X_age1_eduout = X_age0_eduout + X_dur_eduout-1
		
	*Age limits for out of school

	foreach X in prim lowsec upsec {
		gen eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}

	*Age limit for Attendance:

	*-- PRESCHOOL 3
	generate attend_preschool = 1 if attend == 1 & (code_ed6a == 0)
		replace attend_preschool = 0 if attend == 1 & (code_ed6a != 0)
		replace attend_preschool = 0 if attend == 0
	generate preschool_3       = attend_preschool if schage >= 3 & schage <= 4
	generate preschool_1ybefore= attend_preschool if schage == prim_age0_eduout - 1


	*-- HIGHER ED
	generate high_ed = 1 if inlist(code_ed6a, 3, 32, 33, 40)
	generate attend_higher = 1 if attend == 1 & (high_ed == 1)
		replace attend_higher = 0 if attend == 1 & (high_ed != 1)
		replace attend_higher = 0 if attend == 0
	generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

	*Create variables for count of observations
	foreach var of varlist $varlist_m {
			generate `var'_no = `var'
	}

	*Converting the categories to string: 
	capture label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"
	capture label values wealth wealth

	foreach var in $categories_subset {
		capture sdecode `var', replace
		capture replace `var' = proper(`var')
	}
	
	compress
	save "$data_mics\hl\Step_4_temp.dta", replace

	*-- For Bilal: Before collapse
	use "$data_mics\hl\Step_4_temp.dta", clear
	keep hh6 hhweight schage age hh5y year ///
	iso_code3 country* cluster hh_id individual_id ///
	adjustment comp* edu* *attend* location sex wealth ethnicity religion region district 
	drop *no* *aux*
	drop hh6 district country_code_dhs
	drop region ethnicity religion
	ren hh5y year_interview
	ren schage age_adjusted
	label var year "Median year of interview"
	order iso country* year* *weight *id cluster age* adjustment location sex wealth
	
	generate round=""
	replace round="MICS4" if year>=2009 & year<=2012
	replace round="MICS5" if year>=2013 & year<=2017
	replace round="MICS4" if (country=="Algeria"|country=="Thailand"|country=="Uruguay") & (year==2012|year==2013)
	replace round="MICS5" if country=="Bangladesh" & (year==2012|year==2013)
	
	compress
	*save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\microdata_bilal\microdata_MICS4&5.dta", replace
	save "`output_path'", replace

end
	
