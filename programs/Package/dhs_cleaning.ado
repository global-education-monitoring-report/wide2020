* dhs_cleaning: program to clean the data (fixing and recoding variables)
* Version 1.0
* April 2020

program define dhs_cleaning
	args input_path tables_path uis_path output_path 

cd `input_path'

*Fixing categories and creating variables

* read the master data
use "`input_path'", clear
set more off


*create ids variables
* ID for each country year: Variable country_year. Year of survey can be different from the year in the name of the folder
catenate country_year = country year_file, p("_")

* Country dhs code
generate country_code_dhs = substr(hv000, 1, 2)

*Round of DHS
generate round_dhs = substr(hv000, 3, 1)
replace round_dhs = "4" if country_year == "VietNam_2002"


*Individual ids
generate zero = string(0)
	
*Special cases IDs for countries: Honduras_2005, Mali_2001, Peru_2012, Senegal_2005
if (country_year=="Honduras_2005"|country_year=="Mali_2001"|country_year=="Peru_2012"|country_year=="Senegal_2005") {
	if hvidx <= 9 {
	catenate individual_id = country_year hhid zero hvidx 
	}
	else {
	catenate individual_id = country_year hhid hvidx 
	}
else {
	if hvidx <= 9 {
	catenate individual_id = country_year hv001 hv002 zero hvidx 
	} 
	else {
	catenate individual_id = country_year hv001 hv002 hvidx
	}
}

*gen n=1
*bys country_year individual_id: egen d_count=sum(n)
*tab d_count
*br individual country_year hv001_s hv002_s hvidx_s if d_count>=2
*tab country_year if d_count>=2 // problems with ID of Turkey 2008...
*drop n d_count


*Household ids
catenate hh_id = country_year hv001 hv002 
rename hhid hhid_original

drop hv000
 
*Cluster variable
rename hv001 cluster

*drop hhid

* "Official" Year of the survey is hv007. 
* I median of year

	* COUNTRIES WITH DIFFERENT CALENDAR: the years/months don't coincide with the Gregorian Calendar
	
	*replace_many read auxiliary tables to fix values by replace
	replace_many "dhs_fix_date_month.csv" hv006 hv006_replace country_year

	replace_many "dhs_fix_date_year.csv" hv007 hv007_replace country_year hv006
	
	* Other countrys
	replace_many "dhs_fix_date_year2.csv" hv007 hv007_replace country_year
	
	* For Peru, we have to drop the observations for years not included in that country_year
	drop if (hv007 == 2003 | hv007 == 2004 | hv007 == 2005 | hv007 == 2006) & country_year == "Peru_2007" 

	 * Fix format of years
	foreach num of numlist 0/9 {   
		replace hv007=199`num' if hv007==9`num'
	}
	
	*Missing in the day or month of interview
	*Take the 1st of the month (Colombia_1990", Indonesia_1991, Indonesia_1994)
	replace hv016 = 1 if hv016 ==.  
	
	*Take the month in the middle of the 2 fieldwork dates (Colombia_1990)
	replace hv006 = 7 if hv006 == .  
		
	*Inconsistency in number of days for the month. 7567 cases
	*Countries: Afghanistan 2015; Ethiopia (2000, 20011, 2016); Nepal (2001,2006,2011,2016); Nigeria 2008 (1 case)
	*Months that don't have 31 days...
	replace hv016 = 30 if hv016 == 31 &  inlist(hv006, 4, 6, 9, 11)
	* February
	replace hv016 = 28 if hv016 >= 29 & hv006 == 2 
	* Months don't have 32 days
	replace hv016 = 31 if hv016 > 31 & inlist(hv006, 1, 3, 5, 7, 8, 10, 12)
	replace hv016 = 30 if hv016 > 31 & inlist(hv006, 4, 6, 9, 11)
	
	*Create the variable YEAR
	bys country_year: egen year = median(hv007)
	
	* Delete the countries that have the median year of 1999
	drop if year <= 1999 


*-----------------------------------------------------------------------------------------------
* Merge with Duration in years, start age and names of countries (codes_dhs, mics_dhs, iso_code, WIDE names)
*isocodes
import delimited "country_iso_codes_names.csv" ,  varnames(1) encoding(UTF-8) clear
keep country_code_dhs iso_code3
drop if country_code_dhs == ""
tempfile isocode
save `isocode'

merge m:1 country_code_dhs using `isocode', keep(master match) nogenerate

*Now we have year 2018, but the database of duration only has until 2017
rename year year_original
generate year = year_original
replace year = 2017 if year_original >= 2018

merge m:1 iso_code3 year using "`table_path'", keep(match master) nogenerate
drop year
rename year_original year

drop lowsec_age_uis upsec_age_uis
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
rename prim_age_uis prim_age0
	
compress 
save "`input_path'", replace
}


