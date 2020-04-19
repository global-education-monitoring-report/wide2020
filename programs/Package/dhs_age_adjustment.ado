
*-----------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------

*************************************************************
*	AGE ADJUSTMENT
*************************************************************

foreach part in part1 part2 part3 {
use "$data_dhs\PR\Step0_`part'.dta", clear
*use "$data_dhs\PR\Step0_part3.dta", clear
set more off

keep hv006 hv007 hv016 country year country_year iso_code3

*Merge with info about reference school year:
merge m:1 country_year using  "$aux_data\temp\current_school_year_DHS.dta", keep(match master) nogenerate
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


*tab hv007 if country_year=="PapuaNewGuinea_2016" // span of 3 years... affects adjustment?

*-------------------------------------------------------------------------------------
* Adjustment VERSION 1: Difference in number of days 
*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
*- 			Interview		: Month as presented in the survey data
*-------------------------------------------------------------------------------------
	
	generate month_start_norm = month_start
	
*Taking into account the days	
	for X in any norm max min: generate s_school1_X=string(1)+"/"+string(month_start_X)+"/"+string(current_school_year)
	catenate s_interview1 = hv016 hv006 hv007, p("/") // date of the interview created with the original info

	for X in any norm max min: generate date_school1_X = date(s_school1_X, "DMY", 2000) 
	generate date_interview1 = date(s_interview1, "DMY", 2000)
	
*Without taking into account the days
	for X in any norm max min: catenate s_school2_X = month_start_X current_school_year, p("/")
	catenate s_interview2 = hv006 hv007, p("/") // date of the interview created with the original info
	
	for X in any norm max min: generate date_school2_X = date(s_school2_X, "MY", 2000) // official month of start... plus school year of reference
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
collapse diff* adj* flag_month, by(country_year)		

*save "$data_dhs\PR\dhs_adjustment_part3.dta", replace
save "$data_dhs\PR\dhs_adjustment_`part'.dta", replace
}


use "$data_dhs\PR\dhs_adjustment_part1.dta", clear
append using "$data_dhs\PR\dhs_adjustment_part2.dta"
append using "$data_dhs\PR\dhs_adjustment_part3.dta"
save "$data_dhs\PR\dhs_adjustment.dta", replace
*for X in any 1 2 3: erase "$data_dhs\PR\dhs_adjustment_partX.dta"


**************************************************************************************************************************
**************************************************************************************************************************
*-------------------------------------------------------------------------------
*	CREATING EDUC VARIABLES AND CATEGORIES
*-------------------------------------------------------------------------------

foreach part in part1 part2 part3{
use "$data_dhs\PR\Step0_`part'.dta", clear
*use "$data_dhs\PR\Step0_part3.dta", clear
set more off

*Creating the variables for EDUOUT indicators
	for X in any prim_dur lowsec_dur upsec_dur: generate X_eduout = X 
	generate prim_age0_eduout = prim_age0
	

*FOR COMPLETION: Changes to match UIS calculations
*Changes to duration
import delimited "dhs_changes_duration_stage.csv"  ,  varnames(1) encoding(UTF-8) clear
drop iso_code3 message
tempfile fixduration
save `fixduration'

*fix some uis duration
use `uis_path', clear
merge m:1 country_year using `fixduration', keep(match master) nogenerate
replace prim_dur_uis   = prim_dur_replace[_n] if _merge == 3 & prim_dur_replace!=.
replace lowsec_dur_uis = lowsec_dur_replace[_n] if _merge == 3 & lowsec_dur_replace !=.
replace upsec_dur_uis  = upsec_dur_replace[_n] if _merge == 3 & upsec_dur_replace !=.
replace prim_age_uis   = prim_age0_replace[_n] if _merge == 3 & prim_age_replace !=.
tempfile fixduration_uis
save `fixduration_uis'

merge m:1 iso_code3 year using "`fixduration_uis'", keep(match master)  nogenerate
drop lowsec_age_uis upsec_age_uis 


*Questions to UIS
*- Burkina Faso 2010 (DHS) should use age 6 or 7 as start age? The start age changes from 7 to 6 in 2010, the school year starts in October.
*- Egypt 2005 DHS: prim dur changes from 5 to 6 in 2005. Should we use 5 or 6 for year 2005 considering that school years starts in September.
*- Armenia 2010 DHS: All the interviews were in 2010, but UIS says it is year 2011 and has put duration and ages of that year. We put duration and age for 2010 and our results match UNICEF'S
*Education: hv107, hv108, hv109, hv121
compress 
*save "$data_dhs\PR\Step1_part3.dta", replace
save "$data_dhs\PR\Step1_`part'.dta", replace
}


***************************************************************
