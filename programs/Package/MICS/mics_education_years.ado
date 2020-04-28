* mics_education_years: program to compute the years of education by country
* Version 2.0
* April 2020

program define mics_education_years
	args data_path table_path 

	* read auxiliary table to calculate eduyears 
	import delimited "`table_path'/mics_group_eduyears.csv",  varnames(1) encoding(UTF-8) clear
	tempfile group
	save `group'
	
	* read the main data
	use "`data_path'/all/mics_clean.dta", clear
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
	if  group == 0 {
		replace eduyears = ed4b
	 }
	 *GROUP 1*
	 else if group == 1 {
		replace eduyears = ed4b
		replace eduyears = . if code_ed4 == 50
	 }
	 *GROUP 2*
	 else if group == 2 {
	 	replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <=16
		replace eduyears = ed4b - 14 if ed4b >= 21 & ed4b <= 27 
		replace eduyears = ed4b - 17 if ed4b >= 31 & ed4b <= 35 
		replace eduyears = 0         if (ed4b_label == "moins d'un an au primaire" | ed4b_label == "moins d'un an au secondaire" | ed4b_label == "moins d'un an a l'universite")
	 }
	 *GROUP 3*
	 else if group == 3 {
		replace eduyears = ed4b      if ed4b >= 0  & ed4b <= 20 
		replace eduyears = ed4b - 7  if ed4b >= 21 & ed4b <= 23
		replace eduyears = ed4b - 18 if ed4b == 32
		replace eduyears = ed4b - 27 if ed4b >= 41 & ed4b <= 43
		replace eduyears = ed4b - 37 if ed4b >= 52 & ed4b <= 55
	 }
	 *GROUP 4*
	 else if group == 4 {
		replace eduyears = 0                if ed4b >= 1  & ed4b <= 3 
		replace eduyears = ed4b - 10        if ed4b >= 10 & ed4b <= 16
		replace eduyears = ed4b - 14        if ed4b >= 20 & ed4b <= 26 
		replace eduyears = years_upsec      if ed4b == 30 | ed4b == 40
		replace eduyears = years_upsec + 2  if ed4b == 31 
		replace eduyears = years_upsec + 3  if ed4b == 32 | ed4b == 33
		replace eduyears = years_upsec      if ed4b == 40 & country_year == "Nigeria_2011" 
		replace eduyears = years_higher 	if ed4b == 42 
		replace eduyears = years_higher + 2 if ed4b == 43
	 }
	 *GROUP 5*
	 else if group == 5 {
		replace eduyears = 0                if ed4b >= 1  & ed4b <= 3 
		replace eduyears = ed4b - 10        if ed4b >= 10 & ed4b <= 16 
		replace eduyears = ed4b - 14        if ed4b >= 20 & ed4b <= 26 
		replace eduyears = years_upsec      if ed4b == 30  
		replace eduyears = years_upsec + 2  if ed4b == 31 | ed4b == 34
		replace eduyears = years_upsec + 3  if ed4b == 32 | ed4b == 33
		replace eduyears = years_higher 	if ed4b == 35 
		replace eduyears = years_higher + 2 if ed4b == 36 
	 }
	 *GROUP 6*
	 else if group == 6 {
		replace eduyears = ed4b - 10 if ed4b >= 11 & ed4b <= 15 
		replace eduyears = ed4b - 15 if ed4b >= 21 & ed4b <= 24 
		replace eduyears = ed4b - 21 if ed4b >= 31 & ed4b <= 33 
		replace eduyears = ed4b - 28 if ed4b >= 41 & ed4b <= 43 
		replace eduyears = ed4b - 38 if ed4b >= 51 & ed4b <= 57 
	 }
	 *GROUP 7*
	 else if group == 7 {
		replace code_ed4a = 1 if ed4b <= years_prim 
		replace code_ed4a = 2 if ed4b > years_prim  & ed4b <= years_upsec 
		replace code_ed4a = 3 if ed4b > years_upsec & ed4b <. & ed4b < 97 
		replace code_ed4a = 0 if (ed3 == "currently attending kindergarten" | ed3 == "never attended school") 
		replace eduyears = ed4b 
	 }
	 *GROUP 8*
	 else if group == 8 {
	 	replace eduyears = ed4b                         if inlist(code_ed4a, 1, 21, 22)
		replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3 
	 }
	 *GROUP 9*
	 else if group == 9 {
		replace code_ed4a = 50 if (ed4b == 10 | ed4b == 20) 
		replace eduyears = ed4b - 10                    if ed4b >= 11 & ed4b <= 17 
		replace eduyears = ed4b - 13                    if ed4b >= 21 & ed4b <= 26 
		replace eduyears = years_upsec + 0.5*higher_dur if ed4b_label == "attended/currently attending higher education"
		replace eduyears = years_higher                 if ed4b_label == "completed higher education"  
		*replace eduyears=. if code_ed4a==50  
	 }
	 *GROUP 10*
	 else if group == 10 {
	 	replace eduyears = ed4b                if inlist(code_ed4a, 1, 2, 21, 22, 23) 
		replace eduyears = ed4b + years_upsec  if inlist(code_ed4a, 3, 32, 33)
		replace eduyears = ed4b + years_higher if code_ed4a == 40 
		replace eduyears = ed4b + years_lowsec if code_ed4a == 24 & country_year == "Kazakhstan_2015"
	 }
	 *GROUP 11*
	 else if group == 11 {
		replace eduyears = ed4b                if inlist(ed4a_nr, 0, 1, 2, 3) 
		replace eduyears = ed4b + years_lowsec if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 0, 1, 2) 
		replace eduyears = ed4b + years_upsec  if inlist(ed4a_nr, 4, 5) & inlist(ed4b, 3, 4) 
		replace eduyears = ed4b + years_upsec  if ed4a_nr == 6
	 }
	 *GROUP 12*
	 else if group == 12 {
	 	replace eduyears = ed4b                if inlist(code_ed4a, 1, 2, 21, 22)
		replace eduyears = ed4b + years_lowsec if code_ed4a == 24 
		replace eduyears = ed4b + years_upsec  if code_ed4a == 3 
	 }
	 *GROUP 13*
	 else if group == 13 {
	 	replace eduyears = ed4b                if inlist(code_ed4a, 1, 2, 21)
		replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) 
		replace eduyears = ed4b + years_upsec  if inlist(code_ed4a, 3, 32, 33)
		replace eduyears = ed4b + years_higher if code_ed4a == 40
	 }
	 *GROUP 14*
	 else if group == 14 {
		replace eduyears = ed4b                if inlist(code_ed4a, 1, 60, 70) 
		replace eduyears = ed4b + years_prim   if inlist(code_ed4a, 2, 21, 23) 
		replace eduyears = ed4b + years_lowsec if inlist(code_ed4a, 22, 24) 
		replace eduyears = ed4b + years_upsec  if inlist(code_ed4a, 3, 32, 33)
		replace eduyears = ed4b + years_higher if code_ed4a == 40
	
		*replace eduyears=years_prim if ed4b_label=="primary school of nfeep" & country_year=="Mongolia_2013"
		*replace eduyears=years_lowsec if ed4b_label=="basic school of nfeep" & country_year=="Mongolia_2013"
		*replace eduyears=years_prim if ed4b_label=="high school of nfeep" & country_year=="Mongolia_2013"
	 }
	 *GROUP 15*
	 else if group == 15 {
		replace eduyears = ed4b + years_lowsec - 3 if code_ed4a == 22 
	
	 }
	 *GROUP 16*
	 else if group == 16 {
	 	replace eduyears = ed4b                 if code_ed4a == 1
		replace eduyears = ed4b + years_prim    if code_ed4a == 21
		replace eduyears = ed4b + years_lowsec  if inlist(code_ed4a, 22, 24)
		replace eduyears = ed4b + years_upsec   if code_ed4a == 3
	 }
	 *GROUP 17*
	 else if group == 17 {
		replace eduyears = ed4b 			   if code_ed4a == 1
		replace eduyears = ed4b + 8 		   if code_ed4a == 2
		replace eduyears = ed4b + years_lowsec if code_ed4a == 3 
	 }
	 *GROUP 18*
	 else if group == 18 {
		replace eduyears = ed4b 			   if inlist(code_ed4a, 1, 21, 22)
		replace eduyears = ed4b + years_lowsec if code_ed4a == 24
		replace eduyears = ed4b + years_upsec  if inlist(code_ed4a, 3, 33)
	 }
	 *GROUP 19*
	 else if group == 19 {
		replace eduyears = years_higher + 2 if code_ed4a == 40
	 }
	 *GROUP 20*
	 else if group == 20 {
	 	replace eduyears = ed4b                         if code_ed4a == 70
		replace eduyears = ed4b + years_prim            if code_ed4a == 21
		replace eduyears = ed4b + years_lowsec          if code_ed4a == 22 
		replace eduyears = years_upsec + 0.5*higher_dur if code_ed4a == 3
		replace eduyears = years_upsec + 0.2*higher_dur if code_ed4a == 32 
		replace eduyears = years_higher + 2             if code_ed4a == 40

	 }
	 *GROUP 21*
	 else if group == 21 {
	 	replace code_ed4a = 3  if inlist(ed4b_label, "bachelor", "diploma")
		replace code_ed4a = 40 if inlist(ed4b_label, "master", "> master")
		replace code_ed4a = 0  if  ed4b_label == "pre primary"
		replace eduyears = ed4b + 1 
		replace eduyears = 0   if ed4b_label == "no grade" 
	 }
	 *GROUP 22*
	 else if group == 22 {
		replace eduyears = ed4b             if (ed4b >= 0 & ed4b <= 10)
		replace eduyears = 10               if ed4b_label == "slc" 
		replace eduyears = years_upsec      if ed4b_label == "plus 2 level" 
		replace eduyears = years_higher     if ed4b_label == "bachelor" 
		replace eduyears = years_higher + 2 if ed4b_label == "masters" 
		replace eduyears = 0                if ed4b_label == "preschool" 
	 }
	 else {
		replace eduyears = eduyears
	 }
	 
	 
	* Recode for all country_years
	replace eduyears = 97 if ed4b == 97 | ed4b_label == "inconsistent"
	replace eduyears = 98 if ed4b == 98 | ed4b_label == "don't know"
	replace eduyears = 99 if ed4b == 99 | inlist(ed4b_label, "missing", "doesn't answer", "missing/dk")
	replace eduyears = 0  if ed4b == 0
	
	* save data
	compress
	save "`data_path'/all/mics_educvar.dta", replace
	
end
	
