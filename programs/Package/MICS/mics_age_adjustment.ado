* mics_age_adjustment: program to adjust school year
* Version 1.0
* April 2020

program define mics_age_adjustment
	args data_path table_path
	
	use "`data_path'/all/mics_educvar.dta", clear
	set more off
	
	* current school year that ED question in MICS refers to
	merge m:1 country_year using "`table_path'/current_school_year_MICS.dta", keep(master match) nogenerate 

	* replace current 
	replace current = "" if current == "doesn't have the variable"
	destring current, replace

	* Create date
	* Inteview date:  hh5y=year; hh5m=month; hh5d=day  
	* Median of month
	cap drop month* 
	generate year_c = hh5y	
	merge m:1 iso_code3 year_c using "`table_path'/UIS/months_school_year/month_start.dta", keep(master match) nogenerate 
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
	
	*replace current_school_year=current_school_year+1 if (date2-date1>=12) // to fix the differences greater than 12.	
	*br if date_interview-date_school<0
			
	drop s_* date_*
	
	*-------------------------------------------------------------------------------------
	* Adjustment VERSION 1: Difference in number of days 
	*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
	*- 			Interview		: Month as presented in the survey data
	*-------------------------------------------------------------------------------------
		
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

	sort country_year
	* see gcollapse
	*gcollapse diff* adj* flag_month, by(country_year) 
	collapse diff* adj* flag_month, by(country_year)	

	save "`data_path'/all/mics_adjustment.dta", replace

end
