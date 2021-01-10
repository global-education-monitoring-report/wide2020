
use "$data_dhs\PR\Step_1.dta", clear

*keep only one observation per household: have a database at the household level
*keep if hvidx==1
keep hv006 hv007 hv016 country year country_year iso_code3

*Merge with info about reference school year:
merge m:1 country_year using  "$aux_data\temp\current_school_year_DHS.dta"
drop if _merge==2 // this includes the data from 2016 that needs to be added
drop _merge
drop yearwebpage currentschoolyearDHSreport

gen year_c=hv007
merge m:m iso_code3 year_c using "$aux_data\UIS\months_school_year\month_start.dta"
drop if _merge==2
drop _merge max_month min_month diff

*All countries have month_start. Malawi_2015 has now the month 9 (OK)
	ren school_year current_school_year

*For those with missing in school year, I replace by the interview year
gen missing_current_school_year=1 if current_school_year==.
replace current_school_year=hv007 if current_school_year==.

*-------------------------------------------------------------------------------------
* Adjustment VERSION 1: Difference in number of days 
*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
*- 			Interview		: Month as presented in the survey data
*-------------------------------------------------------------------------------------
	
	gen month_start_norm=month_start
	
*Taking into account the days	
	for X in any norm max min: gen s_school1_X=string(1)+"/"+string(month_start_X)+"/"+string(current_school_year)
	gen s_interview1=string(hv016)+"/"+string(hv006)+"/"+string(hv007) // date of the interview created with the original info

	for X in any norm max min: gen date_school1_X=date(s_school1_X, "DMY",2000) 
	gen date_interview1=date(s_interview1, "DMY",2000)
	
*Without taking into account the days
	for X in any norm max min: gen s_school2_X=string(month_start_X)+"/"+string(current_school_year)
	gen s_interview2=string(hv006)+"/"+string(hv007) // date of the interview created with the original info
	
	for X in any norm max min: gen date_school2_X=date(s_school2_X, "MY",2000) // official month of start... plus school year of reference
	gen date_interview2=date(s_interview2, "MY",2000)

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*50% of hh have 6 months of difference or more
*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

foreach M in norm max min {
foreach X in 1 2 {
	gen diff`X'_`M'=(date_interview`X'-date_school`X'_`M')
	gen temp`X'_`M'=mod(diff`X'_`M',365) 
	replace diff`X'_`M'=temp`X'_`M' if missing_current_school_year==1
	bys country_year: egen median_diff`X'_`M'=median(diff`X'_`M')
	gen adj`X'_`M'=0
	replace adj`X'_`M'=1 if median_diff`X'_`M'>=182
}
}

sort country_year
collapse diff* adj* flag_month, by(country_year)		
	
save "$data_dhs\PR\dhs_adjustment.dta", replace
*/
