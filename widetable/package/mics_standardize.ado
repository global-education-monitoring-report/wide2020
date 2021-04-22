* mics_standardize: program to calculate a standard dataset ready to 
* Version 2.0
* April 2020

program define mics_standardize 
	args output_path 

	* COMPUTE THE YEARS OF EDUCATION BY COUNTRY 

	* read auxiliary table to calculate eduyears 
	findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	import excel "`r(fn)'", sheet(group_eduyears) firstrow clear 
	tempfile group
	save `group'
	
	* read the main data
	use "`output_path'/MICS/data/mics_clean.dta", clear
	set more off
	merge m:1 country_year using `group', keep(match master) nogenerate
	

	* create the variable
	generate eduyears = .
	rename ed4b ed4b_label
	rename ed4b_nr ed4b
	
	replace ed4b = 0 if code_ed4a == 0 & country_year == "Suriname_2018"
	replace ed4b = ed4b-2 if code_ed4a == 1 & country_year == "Suriname_2018"

	* Consider the ed4b == 94 as missing
	*replace ed4b = 99 if ed4b == 94
	
	* replace eduyears according to which group it belongs
	
	
	replace eduyears = ed4b if group == 0
	
	replace eduyears = ed4b if group == 1
	replace eduyears = . if code_ed4 == 50 & group == 1
		
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 2
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 27 & group == 2
	replace eduyears = ed4b - 17 if ed4b >= 30 & ed4b <= 35 & group == 2
		
	replace eduyears = ed4b if ed4b >= 0 & ed4b <= 20 & group == 3
	replace eduyears = ed4b - 7 if ed4b >= 21 & ed4b <= 23 & group == 3
	replace eduyears = ed4b - 18 if ed4b == 32 & group == 3
	replace eduyears = ed4b - 27 if ed4b >= 41 & ed4b <= 43 & group == 3
	replace eduyears = ed4b - 37 if ed4b >= 52 & ed4b <= 55 & group == 3
	
	replace eduyears = 0 if ed4b >= 1  & ed4b <= 3  & group == 4
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 4
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 26 & group == 4
	replace eduyears = years_upsec if inlist(ed4b, 30, 40) & group == 4
	replace eduyears = years_upsec + 2 if inlist(ed4b, 31, 41) & group == 4
	replace eduyears = years_upsec + 3 if inlist(ed4b, 32, 33) & group == 4
	replace eduyears = years_higher if ed4b == 42 & group == 4
	replace eduyears = years_higher + 2 if ed4b == 43 & group == 4
	
	replace eduyears = 0 if ed4b >= 1  & ed4b <= 3 & group == 5
	replace eduyears = ed4b - 10 if ed4b >= 10 & ed4b <= 16 & group == 5
	replace eduyears = ed4b - 14 if ed4b >= 20 & ed4b <= 26 & group == 5
	replace eduyears = years_upsec if ed4b == 30 & group == 5
	replace eduyears = years_upsec + 2 if inlist(ed4b, 31, 34) & group == 5
	replace eduyears = years_upsec + 3 if inlist(ed4b, 32, 33) & group == 5
	replace eduyears = years_higher if ed4b == 35 & group == 5
	replace eduyears = years_higher + 2 if ed4b == 36 & group == 5
	
	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 15 & group == 6
	replace eduyears = ed4b - 15 if ed4b >= 21 & ed4b <= 24 & group == 6
	replace eduyears = ed4b - 21 if ed4b >= 31 & ed4b <= 33 & group == 6
	replace eduyears = ed4b - 28 if ed4b >= 41 & ed4b <= 43 & group == 6
	replace eduyears = ed4b - 38 if ed4b >= 51 & ed4b <= 57 & group == 6
	
	replace code_ed4a = 1 if ed4b <= years_prim & group == 7
	replace code_ed4a = 2 if ed4b > years_prim  & ed4b <= years_upsec & group == 7
	replace code_ed4a = 3 if ed4b > years_upsec & ed4b <. & ed4b < 97 & group == 7
	replace code_ed4a = 0 if (ed3 == "currently attending kindergarten" | ed3 == "never attended school") & group == 7
	replace eduyears = ed4b if group == 7
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 21, 22) & group == 8
	replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 & group == 8
	
	replace code_ed4a = 50 if (ed4b == 10 | ed4b == 20) & group == 9
	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 17 & group == 9
	replace eduyears = ed4b - 13 if ed4b >= 21 & ed4b <= 26 & group == 9
	replace eduyears = years_upsec + 0.5*higher_dur if ed4b_label == "attended/currently attending higher education" & group == 9
	replace eduyears = years_higher if ed4b_label == "completed higher education" & group == 9
	*replace eduyears=. if code_ed4a==50  
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21, 22, 23) & group == 10
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 10
	replace eduyears = ed4b + years_higher if code_ed4a == 40 & group == 10
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & country_year == "Kazakhstan_2015" & group == 10
	
	capture replace eduyears = ed4b if inlist(ed4a_nr, 0, 1, 2, 3) & group == 11
	capture replace eduyears = ed4b + years_lowsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 0, 1, 2) & group == 11
	capture replace eduyears = ed4b + years_upsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 3, 4) & group == 11
	capture replace eduyears = ed4b + years_upsec if ed4a_nr == 6 & group == 11
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21, 22) & group == 12
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & group == 12
	replace eduyears = ed4b + years_upsec if code_ed4a == 3 & group == 12 
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 2, 21) & group == 13
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 13
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 13
	replace eduyears = ed4b + years_higher if code_ed4a == 40 & group == 13
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 60, 70) & group == 14
	replace eduyears = ed4b + years_prim if inlist(code_ed4a, 2, 21, 23) & group == 14
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 14
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 14
	replace eduyears = ed4b + years_higher if code_ed4a == 40  & group == 14
	replace eduyears = ed4b + years_lowsec - 3 if (code_ed4a == 22 & country_year == "Thailand_2012")
	replace eduyears = years_prim if (ed4b_label == "primary school of nfeep" & country_year == "Mongolia_2013")
	replace eduyears = years_lowsec if (ed4b_label == "basic school of nfeep" & country_year == "Mongolia_2013")
	replace eduyears = years_prim if (ed4b_label == "high school of nfeep" & country_year == "Mongolia_2013")
	replace eduyears = years_higher + 2 if code_ed4a == 40 & country_year == "Sudan_2014"
	
	replace eduyears = ed4b if (ed4b >= 0 & ed4b <= 10) & group == 15
	replace eduyears = 10 if ed4b_label == "slc" & group == 15
	replace eduyears = years_upsec if ed4b_label == "plus 2 level" & group == 15
	replace eduyears = years_higher if ed4b_label == "bachelor" & group == 15
	replace eduyears = years_higher + 2	 if ed4b_label == "masters" & group == 15
	replace eduyears = 0 if ed4b_label == "preschool" & group == 15

	replace eduyears = ed4b if code_ed4a == 1 & group == 16
	replace eduyears = ed4b + years_prim if code_ed4a == 21 & group == 16
	replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) & group == 16
	replace eduyears = ed4b + years_upsec if code_ed4a == 3 & group == 16
	
	replace eduyears = ed4b if code_ed4a == 1 & group == 17 
	replace eduyears = ed4b + 8 if code_ed4a == 2 & group == 17
	replace eduyears = ed4b + years_lowsec if code_ed4a == 3 & group == 17
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 21, 22) & group == 18
	replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & group == 18
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 33) & group == 18
	
	replace eduyears = years_higher + 2 if code_ed4a == 40 & group == 19
	
	replace eduyears = ed4b if code_ed4a == 70 & group == 20
	replace eduyears = ed4b + years_prim if code_ed4a == 21 & group == 20
	replace eduyears = ed4b + years_lowsec if code_ed4a == 22 & group == 20
	replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 & group == 20
	replace eduyears = years_upsec + 0.2*higher_dur if code_ed4a == 32 & group == 20
	replace eduyears = years_higher + 2 if code_ed4a == 40 & group == 20
	
	replace code_ed4a = 3 if inlist(ed4b_label, "bachelor", "diploma") & group == 21
	replace code_ed4a = 40 if inlist(ed4b_label, "master", "> master") & group == 21
	replace code_ed4a = 0 if  ed4b_label == "pre primary" & group == 21
	replace eduyears = ed4b + 1 if group == 21
	replace eduyears = 0 if ed4b_label == "no grade" & group == 21
	
	replace eduyears = ed4b if inlist(code_ed4a, 1, 60, 70) & group == 22	
	replace eduyears = ed4b + years_prim if inlist(code_ed4a, 2, 21, 22) & group == 22	
	replace eduyears = ed4b + years_lowsec if (code_ed4a == 24) & group == 22	  
	replace eduyears = ed4b + years_upsec if inlist(code_ed4a, 3, 32, 33) & group == 22	
	replace eduyears = ed4b + years_higher if (code_ed4a == 40) & group == 22	
	
		
	/*
	0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 98 "don't know" 99 "missing/doesn't answer" ///
	21 "lower secondary" 23 "voc/tech/prof as lowsec" ///
	22 "upper secondary" 24 "voc/tech/prof as upsec" ///
	32 "post-secondary or superior no university" 33 "voc/tech/prof as higher" ///
	40 "post-graduate (master, PhD, etc)" ///
	**IM INVENTING THIS 41 "Master" 42 "Phd or doctoral degree"
	50 "special/literacy program" 51 "adult education" ///
	60 "general school (ex. Mongolia, Turkmenistan)" ///
	70 "primary+lowsec (ex. Sudan & South Sudan)" ///
	80 "not formal/not regular/not standard" ///
	*/
	
	*NEW STUFF
	replace eduyears=ed4b if inlist(code_ed4a, 1, 60, 70)  
	replace eduyears=ed4b+years_prim if inlist(code_ed4a, 2, 21, 23)
	replace eduyears=ed4b+years_lowsec if inlist(code_ed4a, 22, 24)
	replace eduyears=ed4b+years_upsec if inlist(code_ed4a, 3, 32, 33) 
	
	*NEW STUFF PARTICULAR FOR SOME COUNTRIES
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Montenegro_2018"
	replace eduyears=ed4b if(code_ed4a==1|code_ed4a==21|code_ed4a==22|code_ed4a==3) & country_year=="Bangladesh_2019"
	replace eduyears=ed4b+years_lowsec-3 if code_ed4a==22 & country_year=="Kiribati_2018"
	replace eduyears=ed4b if(code_ed4a==1|code_ed4a==21|code_ed4a==22) & country_year=="Qatar_2012"
	replace eduyears=ed4b+years_prim-5 if ed4a=="2" & country_year=="TFYRMacedonia_2018"
	
	replace eduyears=16 if code_ed4a==3 & ed4b==13 & country_year=="Qatar_2012" // University
	replace eduyears=18 if code_ed4a==3 & ed4b==14 & country_year=="Qatar_2012" // Masters
	replace eduyears=16 if code_ed4a==3 & ed4b==15 & country_year=="Qatar_2012" // PHD
	replace eduyears=16 if code_ed4a==3 & ed4b==16 & country_year=="Qatar_2012" // Other
	
 	replace eduyears=13 if code_ed4a==3 & ed4b==13 & old_ed6==1 & country_year=="Bangladesh_2019"
 	replace eduyears=14 if code_ed4a==3 & ed4b==14 & old_ed6==1 & country_year=="Bangladesh_2019"
 	replace eduyears=15 if code_ed4a==3 & ed4b==15 & old_ed6==1 & country_year=="Bangladesh_2019"
 	replace eduyears=16 if code_ed4a==3 & ed4b==16 & old_ed6==1 & country_year=="Bangladesh_2019"
 	replace eduyears=18 if code_ed4a==3 & ed4b==17 & old_ed6==1 & country_year=="Bangladesh_2019"
 	replace eduyears=18 if code_ed4a==3 & ed4b==18 & old_ed6==1 & country_year=="Bangladesh_2019"
 	replace eduyears=12 if code_ed4a==3 & ed4b==13 & old_ed6==2 & country_year=="Bangladesh_2019"
 	replace eduyears=13 if code_ed4a==3 & ed4b==14 & old_ed6==2 & country_year=="Bangladesh_2019"
 	replace eduyears=14 if code_ed4a==3 & ed4b==15 & old_ed6==2 & country_year=="Bangladesh_2019"
 	replace eduyears=15 if code_ed4a==3 & ed4b==16 & old_ed6==2 & country_year=="Bangladesh_2019"
 	replace eduyears=17 if code_ed4a==3 & ed4b==17 & old_ed6==2 & country_year=="Bangladesh_2019"
 	replace eduyears=17 if code_ed4a==3 & ed4b==18 & old_ed6==2 & country_year=="Bangladesh_2019"

	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_Comms_2019"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_Comms_2019"

	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_2019"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_2019"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Montenegro_RS_2018"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Macedonia_RS_2018"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_Comms_2013"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_Comms_2013"
	
	replace eduyears=ed4b+years_prim-5 if code_ed4a==21 & country_year=="Kosovo_2013"
	replace eduyears=ed4b+years_prim-9 if code_ed4a==22 & country_year=="Kosovo_2013"
	
	replace eduyears=ed4b+years_lowsec-3 if code_ed4a==22 & country_year=="Thailand_2019" // stair issue upsec
	replace eduyears=ed4b+years_upsec+6 if code_ed4a==41 & country_year=="Thailand_2019" // Master assuming 6 years of bachelor
	replace eduyears=ed4b+years_upsec+6+2 if code_ed4a==42 & country_year=="Thailand_2019" // Doctoral degree assuming 2 years of master

	* Recode for all country_years
	replace eduyears = 97 if code_ed4a == 97 | ed4b_label == "inconsistent" 
	replace eduyears = 98 if code_ed4a == 98 | ed4b_label == "don't know"
	replace eduyears = 99 if code_ed4a == 99 | inlist(ed4b_label, "missing", "doesn't answer", "missing/dk")
	replace eduyears = 0 if code_ed4a == 0
	replace eduyears = . if eduyears >= 99
	capture replace eduyears = eduyears - 1 if ed_completed == "no" & (eduyears <= 97)
	replace eduyears = 30 if eduyears >= 30 & eduyears < 90
	

		
	* COMPUTE EDUCATION COMPLETION (the level reached in primary, secondary, etc.)
	generate lowsec_age0 = prim_age0 + prim_dur
	generate upsec_age0  = lowsec_age0 + lowsec_dur
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur - 1

	* VERSION C to fix eduyears
	* Recoding those with zero to a lower level of education 
	* Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!
	*replace eduyears = years_prim if eduyears == 0 & inlist(code_ed4a, 2, 21, 23)
	*replace eduyears = years_lowsec if eduyears == 0 & inlist(code_ed4a, 22, 24)
	*replace eduyears = years_upsec if eduyears == 0 & inlist(code_ed4a, 3, 32, 33)
	*replace eduyears = years_higher if eduyears == 0 & code_ed4a == 40
	
		*******COMPLETION_LVL base**********

 	*Completion each level without Age limits 
 	foreach Z in prim lowsec upsec higher {
 		generate comp_`Z' = 0
 		replace comp_`Z' = 1 if eduyears >= years_`Z'
		replace comp_`Z' = . if inlist(eduyears, 97, 98, 99, .)
		replace comp_`Z' = 0 if ed3 == "no"
 		replace comp_`Z' = 0 if code_ed4a == 0
 	}
	
		*******TERTIARY COMPLETION RATE**********
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
		

	* Recoding ED5: "Attended school during current school year?"
	capture generate attend = 1 if ed5 == "yes" | ed5_nr == 1
	capture replace attend  = 0 if ed5 == "no" | ed5_nr == 0
	
	* save data
	compress
	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
	
	* ADJUST SCHOOL YEAR
	use "`output_path'/MICS/data/mics_standardize.dta", clear
	set more off
	
	* current school year that ED question in MICS refers to
	*findfile current_school_year_MICS.dta, path("`c(sysdir_personal)'/")
	*merge m:1 country_year using "`r(fn)'", keep(master match) nogenerate 
	gen current_school_year=""
	replace current_school_year="2010" if country=="Somalia"
	replace current_school_year="2018" if country=="CostaRica"
	replace current_school_year="2018" if country=="TFYRMacedonia"
	replace current_school_year="2017" if country=="DRCongo"
	replace current_school_year="2018" if country=="Montenegro"
	replace current_school_year="2019" if country=="Bangladesh"
	replace current_school_year="2017" if country=="Ghana"
	replace current_school_year="2016" if country=="Togo"
	replace current_school_year="2018" if country=="Turkmenistan"
	replace current_school_year="2011" if country=="Qatar"
	replace current_school_year="2018" if country=="Kiribati"
	replace current_school_year="2018" if country=="Guinea-Bissau"

	replace current_school_year="2019" if country=="Kosovo_Comms"
	replace current_school_year="2019" if country=="Kosovo"
	replace current_school_year="2018" if country=="Montenegro_RS"
	replace current_school_year="2018" if country=="Macedonia_RS"
	replace current_school_year="2019" if country=="Serbia_RS"

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
	replace current_school_year = current_school_year - 1 if (date_interview - date_school) < 0  
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
	save "`output_path'/MICS/data/mics_adjustment.dta", replace

	* COMPUTE IF SOMEONE DOES NOT GO TO SCHOOL (education out)
	use "`output_path'/MICS/data/mics_standardize.dta", clear
	set more off
	
	// 	*Completion each level with Age limits
 	generate ageA = age-1
 	generate ageU = age

	*Creating age groups for preschool
	generate age_group = 1 if inlist(ageU, 3, 4)
	replace age_group  = 2 if ageU == 5
	replace age_group  = 3 if inlist(ageU, 6, 7, 8)

	label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
	label values age_group age_group

	generate presch_before = 1 if (ed7 == "yes" | ed7 == "1") & code_ed8a == 0
	capture generate attend_primary = 1 if attend == 1 & inlist(code_ed6a, 1, 60, 70)
	capture replace attend_primary  = 0 if attend == 1 & code_ed6a == 0
	capture replace attend_primary  = 0 if attend == 0
		
	* generate no_attend the attend complement
	capture recode attend (1=0) (0=1), gen(no_attend)

	* generate eduout
	* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
	capture generate eduout = no_attend
	capture replace eduout  = . if (attend == 1 & code_ed6a == .) | age == . | (inlist(code_ed6a,. , 98, 99) & eduout == 0)
	capture replace eduout  = 1 if code_ed6a == 0 | ed3 == "no" 
	*Code_ed6a=80/90 affects countries Nigeria 2011, Nigeria 2016, Mauritania 2015, SouthSudan 2010, Sudan 2010 2014
	capture  replace eduout = 1 if code_ed6a == 80 
	capture  replace eduout = 1 if code_ed6a == 90 
	*special cases
	capture replace eduout = no_attend if country_year == "Nepal_2014"
	capture replace eduout = . if (ed6b == "missing" | ed6b == "don't know") & eduout == 0 & country_year == "Nepal_2014"
	capture replace eduout = 1 if ed6b == "preschool" | ed3 == "no" & country_year == "Nepal_2014"
	capture replace eduout = no_attend if country_year == "Barbados_2012"
	capture replace eduout = . if attend == 1 & code_ed6a == . & country_year == "Barbados_2012"
	capture replace eduout = . if inlist(code_ed6a, 98, 99) & eduout == 0 & country_year == "Barbados_2012"
	capture replace eduout = . if ed6a_nr == 0 & country_year == "Barbados_2012"
	capture replace eduout = 1 if ed3 == "no" & country_year == "Barbados_2012"
	
	
//	
// 	generate attend_mauritania = 0
//     replace attend_mauritania = 1 if ed5 == "yes"
//     replace attend_mauritania = . if ed5 == "missing"
//     recode attend_mauritania (1=0) (0=1), gen(eduout_mauritania)
//     replace eduout_mauritania = . if inlist(code_ed6a, 98, 99) & eduout_mauritania == 0
// 	replace eduout_mauritania = 1 if code_ed6a == 0 
// 	replace eduout_mauritania = 1 if ed3 == "no"
// 	replace eduout = eduout_mauritania if country_year == "Mauritania_2011"
// 	drop eduout_mauritania
	
	* Merging with adjustment
	merge m:1 country_year using "`output_path'/MICS/data/mics_adjustment.dta", keepusing(adj1_norm) nogenerate
	rename adj1_norm adjustment
	generate agestandard = ageU if adjustment == 0
	replace agestandard = ageA if adjustment == 1
	capture drop *ageU *ageA 

	*Confirming that schage is available (for example, it is not available for South Sudan 2010)
	*replace schage = age if schage==. 
	bys country_year: egen temp_count = count(schage)
	replace schage = age if temp_count == 0 & adjustment == 0
	replace schage = age-1 if temp_count == 0 & adjustment == 1
	drop temp_count
	
		
	*******OUT OF SCHOOL**********
	for X in any prim_dur lowsec_dur upsec_dur prim_age0 : rename X X_comp

	*Durations for OUT-OF-SCHOOL & ATTENDANCE
	rename year year_original
	generate year = year_original
	replace year = 2017 if year_original >= 2018
	cd "`c(sysdir_personal)'/"
	*local uisfile : dir . files "UIS_duration_age_*.dta"
	*findfile `uisfile', path("`c(sysdir_personal)'/")
	findfile UIS_duration_age_01102020.dta, path("`c(sysdir_personal)'/")
	*use "`r(fn)'", clear
	merge m:1 iso_code3 year using "`r(fn)'", keep(master match) nogenerate
	drop year
	rename year_original year
	drop lowsec_age_uis upsec_age_uis
		
	for X in any prim_dur lowsec_dur upsec_dur: rename X_uis X_eduout
	rename prim_age_uis prim_age0_eduout

	capture generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
	capture generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
	for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1
	*******/OUT OF SCHOOL**********
		
	*******LESS THAN 4 YEARS OF SCHOOLING**********
	*dropping edu2 
		generate edu4 = 0
		replace edu4  = 1 if eduyears < 4
		replace edu4  = . if eduyears == .
	*******/LESS THAN 4 YEARS OF SCHOOLING**********

	***********OVER-AGE PRIMARY ATTENDANCE**************
	**MICS6 version
	*Over-age primary school attendance
	*Percentage of children in primary school who are two years or more older than the official age for grade.
	if (year_folder >= 2017) {
	gen overage2plus= 0 if attend_primary==1
	gen primarygrades=old_ed10b if code_ed6a==1 & old_ed10b<90
	levelsof primarygrades, local(primgrades) clean
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if old_ed10b==`grade' & schage>prim_age0_comp+1+`i'
                 }
				 }
	*MICS 5 and older version
				 if (year_folder < 2017) {
	gen overage2plus= 0 if attend_primary==1
	gen primarygrades=ed6b if code_ed6a==1 &  inlist(ed6b, "1", "2", "3", "4", "5", "6", "7", "8","9")
	levelsof primarygrades, local(primgrades) clean
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if ed6b=="`grade'" & schage>prim_age0_comp+1+`i'
                 }
				 }
	***********/OVER-AGE PRIMARY ATTENDANCE**************
	
	*******HIGHER EDUCATION ATTENDANCE**********
	generate high_ed       = 1 if inlist(code_ed6a, 3, 32, 33, 40, 41, 42)
	capture generate attend_higher = 1 if attend == 1 & high_ed == 1
	capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
	capture replace attend_higher  = 0 if attend == 0
	*******/HIGHER EDUCATION ATTENDANCE**********
	

	save "`output_path'/MICS/data/mics_standardize.dta", replace
	
	*Now run the code to attach and merge the literacy variables
	
	cd "`c(sysdir_personal)'/"
	do widetable_literacy_mics_std
	***FINISH LITERACY CALCULATION***
	replace literacy_1549 = 1 if eduyears >= years_lowsec

		
	local vars country_year iso_code3 year adjustment location sex wealth region ethnicity religion
	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = "" if `var' == "."
	}
	
	generate edu0 = 0 if ed3 == "yes"
	replace edu0  = 1 if ed3 == "no"
	replace edu0  = 1 if code_ed4a == 0
	replace edu0  = 1 if eduyears == 0
	
	capture generate attend_preschool   = 1 if attend == 1 & code_ed6a == 0
	capture replace attend_preschool    = 0 if attend == 1 & code_ed6a != 0
	capture replace attend_preschool    = 0 if attend == 0
	
	rename prim_age0_eduout prim_age0
	
	*getting rid of unnecesary variables
	drop MWB14	WB14 old_ed3 old_ed4 old_ed5a old_ed5b old_ed6	old_ed7	old_ed8	old_ed9	old_ed10a old_ed10b	old_ed15 old_ed16a	old_ed16b	year_folder	ed4b_label	ed3_check	D	E	F	G	H	I	J	prim_dur_comp	lowsec_dur_comp	upsec_dur_comp	prim_age0_comp	prim_dur_replace lowsec_dur_replace	upsec_dur_replace	prim_age_replace	 

	gen survey="MICS"
		
	* save data		
	compress
	save "`output_path'/MICS/data/mics_standardize.dta", replace
	display "You can find the file in `output_path'/MICS/data/"

end
