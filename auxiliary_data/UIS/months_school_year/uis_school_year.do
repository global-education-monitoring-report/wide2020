global aux_data "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
global uis_months "$aux_data\UIS\months_school_year"

*---------------------------------------------------------------------------------------------------------------------------------------------

* FILE FOR 2010
clear
import excel using "$uis_months\UIS_School_Year_10032011.xlsx", firstrow sheet(Sheet1)
ren *, lower
drop regioncode-countrycode h-eb
drop if year==.
duplicates drop

reshape wide month_start month_end, i(country) j(year)

replace country="Palestine" if country=="Occupied Palestinian Territory"
replace country="Libya" if country=="Libyan Arab Jamahiriya"
replace country="Cabo Verde" if country=="Cape Verde"
replace country="Sint Maarten (Dutch part)" if country=="Netherlands Antilles"
save "$uis_months\temp_month_2009-10.dta", replace


* FILE FOR 2014

clear
import excel using "$uis_months\UIS_School_Year_17042018.xlsx", firstrow sheet(Sheet1)
ren *, lower
for X in any month_start month_end: rename X201415 X2014
for X in any month_start month_end: rename X201516 X2015


replace country="Czech Republic" if country=="Czechia"
merge 1:1 country using "$uis_months\temp_month_2009-10.dta"
tab country if _m==1
tab country if _m==2
drop _merge 
drop month_end*

order country month_start2009 month_start2010 month_start2014 month_start2015

for X in any 2009 2010: gen missingX=1 if month_startX==. // *For 2014 and 2015 all observations are complete, no need for FLAG for those years

egen max_month=rowmax(month_start2009 month_start2010 month_start2014 month_start2015)
egen min_month=rowmin(month_start2009 month_start2010 month_start2014 month_start2015)


* I replace the missing when we have the same value for max and min (likely to not have changed through the years)
* I create 2 versions of month start: the max and the min....

for X in any month_start2009 month_start2010: replace X=max_month if X==. & max_month==min_month  // the values for 2014 and 2015 are complete
replace month_start2009=3 if country=="Peru"
replace month_start2009=9 if country=="Ecuador"

tab country if month_start2009==.
tab country if month_start2010==.

gen diff2009=abs(month_start2009-month_start2010)
gen diff2010=abs(month_start2010-month_start2014)
gen diff2014=abs(month_start2014-month_start2015)

gen flag_month=1 if (diff2009!=0|diff2010!=0|diff2014!=0) 
table country, c(mean diff2009 mean diff2010 mean diff2014 mean flag_month)

	foreach Y of numlist 1999/2008 2011/2013 2016/2017 {
	  gen month_start`Y'=.
	}

	foreach Y of numlist 1999/2008 {
	  replace month_start`Y'=month_start2009
	}
	
	foreach Y of numlist 2011/2013 {
	  replace month_start`Y'=month_start2014
	}
	
	foreach Y of numlist 2016/2017 {
	  replace month_start`Y'=month_start2015
	}

	
* I create 2 more versions with the maximum and the minimun!
	foreach Y of numlist 1999/2017 {
	  gen month_start_min`Y'=.
	  gen month_start_max`Y'=.
	  replace month_start_min`Y'=min_month
	  replace month_start_max`Y'=max_month
	 }

reshape long month_start month_start_min month_start_max diff missing, i(country) j(year)
replace diff=. if diff==0
order country year month_start month_start_min month_start_max max_month min_month diff missing
replace country="Bolivia, Plurinational States of" if country=="Bolivia (Plurinational State of)"
replace country="Hong Kong, China" if country=="China, Hong Kong Special Administrative Region"
replace country="Macao, China" if country=="China, Macao Special Administrative Region"
replace country="The former Yugoslav Rep. of Macedonia" if country=="The former Yugoslav Republic of Macedonia"
replace country="United States" if country=="United States of America"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="Venezuela, Bolivarian Republic of" if country=="Venezuela (Bolivarian Republic of)"
replace country="Iran, Islamic Republic of" if country=="Iran (Islamic Republic of)"
replace country="Democratic Rep. of the Congo" if country=="Democratic Republic of the Congo"
replace country="Sint Maarten" if country=="Sint Maarten (Dutch part)"

*Merging with iso code
merge m:1 country using "$aux_data\temp\country_iso_codes_names.dta"
tab country if _m==1
tab country if _m==2
drop if _merge!=3
drop _merge
drop country_name_mics country_name_WIDE iso_code2 iso_numeric country_name_dhs country_code_dhs
ren year year_c
order country iso year*
save "$uis_months\month_start.dta", replace

***************** 
erase "$uis_months\temp_month_2009-10.dta"
		
*---------------------------------------------------------------------------------------------------------------------------------------------
