* mics_calculate: program to calculate years of education, education completion and education out
* Version 2.0
* April 2020

program define mics_calculate 
	args data_path 

	* COMPUTE THE YEARS OF EDUCATION BY COUNTRY 

	* read auxiliary table to calculate eduyears 
	findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	import excel "`r(fn)'", sheet(group_eduyears) firstrow clear 
	tempfile group
	save `group'
	
	* read the main data
	use "`data_path'/MICS/mics_clean.dta", clear
	set more off
	merge m:1 country_year using `group', keep(match master) nogenerate
	
	* create the variable
	generate eduyears = .
	rename ed4b ed4b_label
	rename ed4b_nr ed4b
	* Consider the ed4b == 94 as missing
	replace ed4b = 99 if ed4b == 94
	
	* replace eduyears according to which group it belongs
	
	*GROUP 0*
	replace eduyears = ed4b	 if group == 0
	*GROUP 1*
        replace eduyears = ed4b  if group == 1
	replace eduyears = . if code_ed4 == 50 &  group == 1
	 *GROUP 2*
 	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <=16 & group == 2
	replace eduyears = ed4b - 14 if ed4b >= 21 & ed4b <= 27 & group == 2
	replace eduyears = ed4b - 17 if ed4b >= 31 & ed4b <= 35 & group == 2
	replace eduyears = 0 if (ed4b_label == "moins d'un an au primaire" | ed4b_label == "moins d'un an au secondaire" | ed4b_label == "moins d'un an a l'universite") & group == 2
	 *GROUP 3*
	replace eduyears = ed4b if ed4b >= 0  & ed4b <= 20 & group == 3
	replace eduyears = ed4b - 7 if ed4b >= 21 & ed4b <= 23 & group == 3
	replace eduyears = ed4b - 18 if ed4b == 32 & group == 3
	replace eduyears = ed4b - 27 if ed4b >= 41 & ed4b <= 43 & group == 3
	replace eduyears = ed4b - 37 if ed4b >= 52 & ed4b <= 55 & group == 3
	 *GROUP 4*
	replace eduyears = 0 if ed4b >= 1  & ed4b <= 3 & group == 4
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 4
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 26 & group == 4
	replace eduyears = years_upsec if (ed4b == 30 | ed4b == 40) & group == 4
	replace eduyears = years_upsec + 2 if ed4b == 31  & group == 4
	replace eduyears = years_upsec + 3 if (ed4b == 32 | ed4b == 33) & group == 4
	replace eduyears = years_upsec if ed4b == 40 & country_year == "Nigeria_2011" & group == 4
	replace eduyears = years_higher if ed4b == 42   & group == 4
	replace eduyears = years_higher + 2 if ed4b == 43  & group == 4
	 *GROUP 5*
	replace eduyears = 0 if ed4b >= 1  & ed4b <= 3 & group == 5
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 5
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 26 & group == 5
	replace eduyears = years_upsec if ed4b == 30  & group == 5
	replace eduyears = years_upsec + 2 if (ed4b == 31 | ed4b == 34) & group == 5
	replace eduyears = years_upsec + 3 if (ed4b == 32 | ed4b == 33) & group == 5
	replace eduyears = years_higher if ed4b == 35 & group == 5
	replace eduyears = years_higher + 2 if ed4b == 36  & group == 5
	 *GROUP 6*
	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 15 & group == 6
	replace eduyears = ed4b - 15 if ed4b >= 21 & ed4b <= 24 & group == 6
	replace eduyears = ed4b - 21 if ed4b >= 31 & ed4b <= 33 & group == 6
	replace eduyears = ed4b - 28 if ed4b >= 41 & ed4b <= 43 & group == 6
	replace eduyears = ed4b - 38 if ed4b >= 51 & ed4b <= 57 & group == 6
	 *GROUP 7*
	replace code_ed4a = 1 if ed4b <= years_prim  & group == 7
	replace code_ed4a = 2 if ed4b > years_prim  & ed4b <= years_upsec & group == 7
	replace code_ed4a = 3 if ed4b > years_upsec & ed4b <. & ed4b < 97 & group == 7
	replace code_ed4a = 0 if (ed3 == "currently attending kindergarten" | ed3 == "never attended school") & group == 7
	replace eduyears = ed4b  if group == 7
	 *GROUP 8*
 	replace eduyears = ed4b if inlist(code_ed4a, 1, 21, 22) & group == 8
	replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 & group == 8
	 *GROUP 9*
	replace code_ed4a = 50 if (ed4b == 10 | ed4b == 20) & group == 9
	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 17  & group == 9
	replace eduyears = ed4b - 13 if ed4b >= 21 & ed4b <= 26  & group == 9
	replace eduyears = years_upsec + 0.5*higher_dur if ed4b_label == "attended/currently attending higher education"  & group == 9
	replace eduyears = years_higher if ed4b_label == "completed higher education"   & group == 9
	*replace eduyears=. if code_ed4a==50  
	 *GROUP 10*
 	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21, 22, 23) & group == 10
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 10
	replace eduyears = ed4b + years_higher if code_ed4a == 40  & group == 10
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & country_year == "Kazakhstan_2015" & group == 10
	 *GROUP 11*
	replace eduyears = ed4b if inlist(ed4a_nr, 0, 1, 2, 3) & group == 11
	replace eduyears = ed4b + years_lowsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 0, 1, 2) & group == 11
	replace eduyears = ed4b + years_upsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 3, 4) & group == 11
	replace eduyears = ed4b + years_upsec if ed4a_nr == 6 & group == 11
	 *GROUP 12*
 	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21, 22) & group == 12
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & group == 12
	replace eduyears = ed4b + years_upsec if code_ed4a == 3 & group == 12
	 *GROUP 13*
 	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21) & group == 13
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 13
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 13
	replace eduyears = ed4b + years_higher if code_ed4a == 40 & group == 13
	 *GROUP 14*
	replace eduyears = ed4b if inlist(code_ed4a, 1, 60, 70) & group == 14
	replace eduyears = ed4b + years_prim if inlist(code_ed4a, 2, 21, 23) & group == 14
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 14
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 14
	replace eduyears = ed4b + years_higher if code_ed4a == 40 & group == 14
	 *GROUP 15*
	replace eduyears = ed4b + years_lowsec - 3 if code_ed4a == 22 & group == 15
	 *GROUP 16*
 	replace eduyears = ed4b if code_ed4a == 1 & group == 16 
	replace eduyears = ed4b + years_prim if code_ed4a == 21 & group == 16
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 16
	replace eduyears = ed4b + years_upsec if code_ed4a == 3 & group == 16
	 *GROUP 17*
	replace eduyears = ed4b if code_ed4a == 1 & group == 17
	replace eduyears = ed4b + 8 if code_ed4a == 2 & group == 17
	replace eduyears = ed4b + years_lowsec if code_ed4a == 3 & group == 17
	 *GROUP 18*
	replace eduyears = ed4b if inlist(code_ed4a, 1, 21, 22) & group == 18
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & group == 18
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 33) & group == 18
	 *GROUP 19*
	replace eduyears = years_higher + 2 if code_ed4a == 40 & group == 19
	 *GROUP 20*
 	replace eduyears = ed4b if code_ed4a == 70 & group == 20
	replace eduyears = ed4b + years_prim if code_ed4a == 21 & group == 20
	replace eduyears = ed4b + years_lowsec if code_ed4a == 22 & group == 20
	replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 & group == 20
	replace eduyears = years_upsec + 0.2*higher_dur if code_ed4a == 32 & group == 20
	replace eduyears = years_higher + 2 if code_ed4a == 40 & group == 20
	 *GROUP 21*
 	replace code_ed4a = 3 if inlist(ed4b_label, "bachelor", "diploma") & group == 21
	replace code_ed4a = 40 if inlist(ed4b_label, "master", "> master") & group == 21
	replace code_ed4a = 0 if  ed4b_label == "pre primary" & group == 21
	replace eduyears = ed4b + 1 if group == 21
	replace eduyears = 0 if ed4b_label == "no grade"  & group == 21
	 *GROUP 22*
	replace eduyears = ed4b if (ed4b >= 0 & ed4b <= 10) & group == 22
	replace eduyears = 10 if ed4b_label == "slc" & group == 22
	replace eduyears = years_upsec if ed4b_label == "plus 2 level" & group == 22
	replace eduyears = years_higher if ed4b_label == "bachelor" & group == 22
	replace eduyears = years_higher + 2	 if ed4b_label == "masters" & group == 22
	replace eduyears = 0 if ed4b_label == "preschool" & group == 22
	 
	* Recode for all country_years
	replace eduyears = 97 if ed4b == 97 | ed4b_label == "inconsistent"
	replace eduyears = 98 if ed4b == 98 | ed4b_label == "don't know"
	replace eduyears = 99 if ed4b == 99 | inlist(ed4b_label, "missing", "doesn't answer", "missing/dk")
	replace eduyears = 0 if ed4b == 0

	
	* COMPUTE EDUCATION COMPLETION (the level reached in primary, secondary, etc.)
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur - 1

	* VERSION C to fix eduyears
	* Recoding those with zero to a lower level of education 
	* Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!
	replace eduyears = years_prim if eduyears == 0 & inlist(code_ed4a, 2, 21, 23)
	replace eduyears = years_lowsec if eduyears == 0 & inlist(code_ed4a, 22, 24)
	replace eduyears = years_upsec if eduyears == 0 & inlist(code_ed4a, 3, 32, 33)
	replace eduyears = years_higher if eduyears == 0 & code_ed4a == 40
		
	*Completion each level without Age limits 
	foreach Z in prim lowsec upsec higher {
		generate comp_`Z' = 0
		replace comp_`Z' = 1 if eduyears >= years_`Z'
		replace comp_`Z' = . if inlist(eduyears, 97, 98, 99)
		replace comp_`Z' = 0 if ed3 == "no"
		replace comp_`Z' = 0 if code_ed4a == 0
	}
		
	*Completion each level with Age limits
	generate ageA = age-1
	generate ageU = age
	
	foreach X in prim lowsec upsec {
		foreach AGE in ageU ageA {
			generate comp_`X'_v2_`AGE' = comp_`X' if `AGE' >= `X'_age1+3 & `AGE' <= `X'_age1+5
		}
	}

	* Recoding ED5: "Attended school during current school year?"
	generate attend = 1 if ed5 == "yes" 
	replace attend  = 0 if ed5 == "no"

	* save data
	compress
	save "`data_path'/MICS/mics_calculate.dta", replace

	
	* ADJUST SCHOOL YEAR
	use "`data_path'/MICS/mics_calculate.dta", clear
	set more off
	
	* current school year that ED question in MICS refers to
	findfile current_school_year_MICS.dta, path("`c(sysdir_personal)'/")
	merge m:1 country_year using "`r(fn)'", keep(master match) nogenerate 
		
	* replace current 
	replace current = "" if current == "doesn't have the variable"
	destring current, replace

	* Create date
	* Inteview date:  hh5y=year; hh5m=month; hh5d=day  
	* Median of month
	capture drop month* 
	generate year_c = hh5y	
	findfile month_start.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 year_c using "`r(fn)'", keep(master match) nogenerate 
	drop max_month min_month diff year_c

	* replace missing in school year by the interview year
	replace current_school_year = hh5y if current_school_year == .

	catenate s_school    = month_start current_school_year, p("/")
	catenate s_interview = hh5m hh5y, p("/") 

	* create official month of start
	generate date_school    = date(s_school, "MY",2000) 
	* create school year of reference
	generate date_interview = date(s_interview, "MY",2000)
		
	* fix the negative differences
	replace current_school_year = current_school_year - 1 if date_interview - date_school < 0  
	*replace current_school_year=current_school_year+1 if (date2-date1>=12) 
	drop s_* date_*
	
	* Adjustment VERSION 1: Difference in number of days 
	*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
	*- 			Interview		: Month as presented in the survey data
	generate month_start_norm = month_start
	*Taking into account the days	
	generate one = string(1)
	for X in any norm max min: catenate s_school1_X = one month_start_X current_school_year,  p("/")
	catenate s_interview1 = hh5d hh5m hh5y,  p("/")
	
	for X in any norm max min: generate date_school1_X = date(s_school1_X, "DMY",2000) 
	generate date_interview1 = date(s_interview1, "DMY", 2000)
		
	*Without taking into account the days
	for X in any norm max min: catenate s_school2_X = month_start_X current_school_year, p("/")
	catenate s_interview2 = hh5m hh5y, p("/")
	
	* create official month of start
	for X in any norm max min: generate date_school2_X = date(s_school2_X, "MY",2000) 
	* create school year of reference
	generate date_interview2 = date(s_interview2, "MY",2000)

	*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
	*Median difference is >=6.
	*50% of hh have 6 months of difference or more
	*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

	foreach M in norm max min {
		foreach X in 1 2 {
			generate diff`X'_`M' = (date_interview`X' - date_school`X'_`M')
			bys country_year: egen median_diff`X'_`M' = median(diff`X'_`M')
			generate adj`X'_`M' = 0
			replace adj`X'_`M' = 1 if median_diff`X'_`M' >= 182
		}
	}

	hashsort country_year
		
	gcollapse diff* adj* flag_month, by(country_year) fast
	save "`data_path'/MICS/mics_adjustment.dta", replace

	* COMPUTE IF SOMEONE DOES NOT GO TO SCHOOL (education out)
	use "`data_path'/MICS/mics_calculate.dta", clear
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
	*special cases
	replace eduout = no_attend if country_year == "Nepal_2014"
	replace eduout = . if (ed6b == "missing" | ed6b == "don't know") & eduout == 0 & country_year == "Nepal_2014"
	replace eduout = 1 if ed6b == "preschool" | ed3 == "no" & country_year == "Nepal_2014"
	replace eduout = no_attend if country_year == "Barbados_2012"
	replace eduout = . if (attend == 1 & code_ed6a == . & country_year == "Barbados_2012") 
	replace eduout = . if inlist(code_ed6a, 98, 99) & eduout == 0 & country_year == "Barbados_2012"
	replace eduout = . if ed6a_nr == 0 & country_year == "Barbados_2012"
	replace eduout = 1 if ed3 == "no" & country_year == "Barbados_2012"
	replace attend = 0 if country_year == "Mauritania_2011" 
	replace attend = 1 if ed5 == "yes" & country_year == "Mauritania_2011" 
	replace attend = . if ed5 == "missing" & country_year == "Mauritania_2011" 

	* Merging with adjustment
	merge m:1 country_year using "`data_path'/MICS/mics_adjustment.dta", keepusing(adj1_norm) nogenerate
	rename adj1_norm adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1
	capture drop *ageU *ageA 

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
	generate comp_prim_aux   = comp_prim if schage >= lowsec_age1 + 3 & schage <= lowsec_age1 + 5
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
		generate edu0_prim=edu0 if `AGE' >= prim_age0 + 3 & `AGE'<=prim_age0 + 6
		*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
		*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
	}
	drop edu0

	*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		*replace comp_higher_`X'yrs = 1	if eduyears >= years_upsec + `X'
		replace comp_higher_`X'yrs = . if inlist(eduyears, ., 97, 98, 99)
		replace comp_higher_`X'yrs = 0 if ed3 == "no"  
		replace comp_higher_`X'yrs = 0 if code_ed4a == 0 
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
	findfile UIS_duration_age_25072018.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 year using "`r(fn)'", keep(master match) nogenerate
	drop lowsec_age_uis upsec_age_uis
		
	for X in any prim_dur lowsec_dur upsec_dur: rename X_uis X_eduout
	rename prim_age_uis prim_age0_eduout

	generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
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
	capture sdecode `var', replace
	capture tostring `var', replace
	}
		
	* save data		
	compress
	save "`data_path'/MICS/mics_calculate.dta", replace

end
