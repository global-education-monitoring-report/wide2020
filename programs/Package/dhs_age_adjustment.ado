* dhs_age_adjustment: program to clean the data (fixing and recoding variables)
* Version 1.0
* April 2020

program define dhs_age_adjustment
	args input_path table1_path table2_path uis_path output_path 

cd `input_path'

*	AGE ADJUSTMENT
use "`input_path'", clear
set more off

keep hv006 hv007 hv016 country year country_year iso_code3

*Merge with info about reference school year: $aux_data\temp\current_school_year_DHS.dta
merge m:1 country_year using  `table1_path', keep(match master) nogenerate
drop yearwebpage currentschoolyearDHSreport

generate year_c = hv007
replace year_c = 2017 if year_c >= 2018 // I only have data on school calendar until 2017
merge m:1 iso_code3 year_c using `table2_path', keep(master match) nogenerate
drop max_month min_month diff year_c

*All countries have month_start. Malawi_2015 has now the month 9 (OK)
rename school_year current_school_year

*For those with missing in school year, I replace by the interview year
generate missing_current_school_year = 1 if current_school_year == .
replace current_school_year = hv007 if current_school_year == .


*-------------------------------------------------------------------------------------
* Adjustment VERSION 1: Difference in number of days 
*-	Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
*- Interview		: Month as presented in the survey data
*-------------------------------------------------------------------------------------
	
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

save "$data_path/all/dhs_adjustment.dta", replace



*use "$data_dhs\PR\dhs_adjustment_part1.dta", clear
*append using "$data_dhs\PR\dhs_adjustment_part2.dta"
*append using "$data_dhs\PR\dhs_adjustment_part3.dta"
*save "$data_dhs\PR\dhs_adjustment.dta", replace
*for X in any 1 2 3: erase "$data_dhs\PR\dhs_adjustment_partX.dta"

end
