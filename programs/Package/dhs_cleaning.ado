
*/
**************************************************************************
*			Fixing categories and creating variables
**************************************************************************
foreach part in part1 part2 part3 {
use "$data_dhs\PR\dhs_PR_append_`part'.dta" , clear
*use "$data_dhs\PR\dhs_PR_append_part3.dta" , clear
set more off

* ID for each country year: Variable country_year. Year of survey can be different from the year in the name of the folder
catenate country_year = country year_folder, p("_")

* Country dhs code
generate country_code_dhs = substr(hv000, 1, 2)

*Round of DHS
generate round_dhs = substr(hv000, 3, 1)
drop hv000
replace round_dhs = "4" if country_year == "VietNam_2002"

*Individual ids
for X in any hv001 hv002 hvidx: gen X_s = string(X, "%25.0f")
generate individual_id = country_year+" "+hv001_s+" "+hv002_s+" "+hvidx_s

*Special cases IDs for countries: Honduras_2005, Mali_2001, Peru_2012, Senegal_2005
replace individual_id=country_year+" "+hhid+" "+hvidx_s if (country_year=="Honduras_2005"|country_year=="Mali_2001"|country_year=="Peru_2012"|country_year=="Senegal_2005")
replace individual_id=country_year+" "+hhid+" "+"0"+hvidx_s if country_year=="Peru_2012"
replace individual_id=country_year+" "+hhid+" "+" "+hvidx_s if hvidx<=9 & (country_year=="Mali_2001"|country_year=="Honduras_2005"|country_year=="Senegal_2005") 

*codebook individual_id // uniquely identifies all except Turkey 2008


*gen n=1
*bys country_year individual_id: egen d_count=sum(n)
*tab d_count
*br individual country_year hv001_s hv002_s hvidx_s if d_count>=2
*tab country_year if d_count>=2 // problems with ID of Turkey 2008...
*drop n d_count


*Household ids
catenate hh_id = country_year hv001_s hv002_s 
rename hhid hhid_original
drop *_s

*Cluster variable
rename hv001 cluster

*drop hhid

* "Official" Year of the survey is hv007. 
* I median of year

*Fixing problems with year: variable hv007
*codebook hv007, tab(100)


	replace hv007=1990 if hv007==. & country_year=="Colombia_1990" 
	replace hv007=2000 if hv007==0 & (country_year=="Gabon_2000"|country_year=="Bangladesh_1999"|country_year=="India_1998")
	replace hv007=2001 if hv007==1 & country_year=="Gabon_2000" 	// label was 2001, but the value said 1
	replace hv007=2002 if hv007==2 & country_year=="VietNam_2002" 	// label was 2002, but the value said 2

	* COUNTRIES WITH DIFFERENT CALENDAR: the years/months don't coincide with the Gregorian Calendar
	
	*replace_many read auxiliary tables to fix values by replace
	replace_many "mics_fix_date_month.csv" hv006 hv006_replace country_year

	replace_many "mics_fix_date_year.csv" hv007 hv007_replace country_year
		
	
	drop if (hv007==2003|hv007==2004|hv007==2005|hv007==2006) & country_year=="Peru_2007" // For Peru, we have to drop the observations for years not included in that country_year

	foreach num of numlist 0/9 {    //Fix format of years
		replace hv007=199`num' if hv007==9`num'
	}
	
	*Missing in the day or month of interview
	replace hv016=1 if (country_year=="Colombia_1990"|country_year=="Indonesia_1991"|country_year=="Indonesia_1994") // Take the 1st of the month
	replace hv006=7 if hv006==. & country_year=="Colombia_1990"  // Take the month in the middle of the 2 fieldwork dates
		
	*Inconsistency in number of days for the month. 7567 cases
	*Countries: Afghanistan 2015; Ethiopia (2000, 20011, 2016); Nepal (2001,2006,2011,2016); Nigeria 2008 (1 case)
	replace hv016=30 if hv016==31 & (hv006==4|hv006==6|hv006==9|hv006==11) & (country=="Afghanistan"|country=="Ethiopia"|country=="Nepal"|country=="Nigeria") // Months that don't have 31 days...
	replace hv016=28 if hv016>=29 & hv006==2 & (country=="Afghanistan"|country=="Ethiopia"|country=="Nepal"|country=="Nigeria") // Most of the cases are for February
	replace hv016=31 if hv016==32 & (hv006==5|hv006==7) & (country=="Nepal")

*Create the variable YEAR
	bys country_year: egen year=median(hv007)
	drop if year<=1999 // drop the countries that have the median year of 1999

	bys country: tab hv016 hv006 
	

*-----------------------------------------------------------------------------------------------
* Merge with Duration in years, start age and names of countries (codes_dhs, mics_dhs, iso_code, WIDE names)
*isocodes
import delimited "country_iso_codes_names.csv" ,  varnames(1) encoding(UTF-8) clear
keep country_code_dhs iso_code3
drop if country_code_dhs==""
tempfile isocode
save `isocode'

merge m:1 country_code_dhs using `isocode', keep(master match) nogenerate

*Now we have year 2018, but the database of duration only has until 2017
rename year year_original
generate year = year_original
replace year = 2017 if year_original >= 2018

merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta", keep(match master) nogenerate
drop year
rename year_original year
drop lowsec_age_uis upsec_age_uis
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0
	
compress 
*save "$data_dhs\PR\Step0_part3.dta", replace
save "$data_dhs\PR\Step0_`part'.dta", replace
}



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
