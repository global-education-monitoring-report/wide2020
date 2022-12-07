**********
**EU-LFS**

*30/11 first version compatible with 2015-2019 files
*18/01 working version 
*24/01 first try , left to do is region variable 
*24/11 extended compatibility with older surveys, dedicated .do for region rename until 2010


program define LFS_standalone
	syntax, country_code(string) country_year(string) 


*Read csv file 
cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`country_code'_`country_year'_LFS\"
	fs *.csv
	di "Opening " `r(files)'
	import delimited using `r(files)', clear
	set more off
	
*******Set up category variables: for the moment sex region and location. Wealth we're trying a new definition, so it's for the moment stopped. 

gen iso_code3 = "`country_code'"
capture gen year = "`country_year'"

*Rename weight (Yearly weighting factor (also called COEFF in yearly files))
rename coeff hhweight

**Sex , same variable but need to recode from
*1 Male 
*2 Female -> 0 
recode sex (1 = 1) (2 = 0)
label define sex 1 "Male" 0 "Female", replace
label values sex sex


**Wealth, is there but for AT2018 56% of individuals are not coded into it, otherwise recode from deciles into quintiles

*recode incdecil (99 = .) (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 8 = 4) (9 10 = 5), gen (wealth)
*search missings in case not installed
*missings dropvars wealth, force

*Wealth not available in...CZ2018 CZ2019 FI2018 IS2015 IS2016 IS2017 IS2018 IS2019 NO2015-2019 SI2019 SE2015-2019
*Luxembourg has 80% missings
*RO has 70% missings

*Region, it has its own do file compatible up to 2010

do "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Code\LFS_region_names.do"

**Location (urban-rural), decide how to recode 3 categories of degurba
/*
1 Cities (Densely-populated area)
2 Towns and suburbs (Intermediate density area)
3 Rural area (Thinly-populated area)
*/

recode degurba (1 2 = 1) (3 = 0) , gen(location)
label define location 1 "Urban" 0 "Rural"
label values location location



**********Indicators 

**Import durations from UIS
findfile UIS_duration_age_01102020.dta, path("`c(sysdir_personal)'/")
merge m:1 iso_code3 year using "`r(fn)'", keep(master match) nogenerate

***************IMPORTANT: EDUCATION IS DECLARED FROM 15 YEARS OLD-ONWARDS IN 5 YEARS COHORTS, SO AGE VARIABLE MIGHT BE MISLEADING AT FIRST GLANCE

*Separate ED variables for 2010-2013 and 2014-2019 
*Check them for explanations

 if year <= 2013 {
 do "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Code\LFS_isced97_indicators.do"
 }
 else if year > 2013 {
 do "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Code\LFS_isced11_indicators.do"
       }

************************** END OF INDICATOR CALCULATION 

foreach var in comp_lowsec_1524 comp_lowsec_1519_v2 comp_upsec_2029 comp_upsec_2024_v2 eduyears_2024 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 attend_higher_2024  {
cap gen `var'_no=`var'
}
compress

save "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\lfs_microdata.dta", replace


********EXTRA: saving microdata for ABC models

cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\microdata"
save "LFS_`country_code'_`country_year'.dta", replace

cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\"

use "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\lfs_microdata.dta", clear

***********************************************************

*global categories_collapse location sex wealth region 
global categories_collapse location sex region 

global varlist_m comp_lowsec_1524 comp_lowsec_1519_v2 comp_upsec_2029 comp_upsec_2024_v2 eduyears_2024 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 attend_higher_2024 age *_uis 
global varlist_no comp_lowsec_1524_no comp_lowsec_1519_v2_no comp_upsec_2029_no comp_upsec_2024_v2_no eduyears_2024_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no attend_higher_2024_no

tuples $categories_collapse, display


set more off
foreach i of numlist 0/15 {
	use "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\lfs_microdata.dta", clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [aweight=hhweight], by(country iso_code3 year `tuple`i'')
	gen category="`tuple`i''"
	cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\Results"
	save "result`i'.dta", replace
}

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\Results"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen survey="EU-LFS"
replace category="Total" if category==""
tab category

*Erase all the result files and microdata, for the moment
capture erase "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\lfs_microdata.dta"

local workdir "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\Results"
cd "`workdir'"
local datafiles: dir "`workdir'" files "*.dta"
foreach datafile of local datafiles {
        rm "`datafile'"
}


global varlist_m comp_lowsec_1524 comp_lowsec_1519_v2 comp_upsec_2029 comp_upsec_2024_v2 eduyears_2024 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 attend_higher_2024

* Eliminate those with less than 30 obs
	foreach var of varlist $varlist_m  {
			replace `var' = . if `var'_no < 30
	}
	
*RENAME COHORTS TIME
/* Manos email 7/11/22
-	Despite the slightly different age groups, the calculated indicators should be merged with the standard indicators and not be different indicators, i.e.
o	comp_lowsec_1519_v2 should be comp_lowsec_v2
o	comp_upsec_2024_v2 should be comp_uppsec_v2
*/
rename comp_lowsec_1519_v2 comp_lowsec_v2_m
rename comp_upsec_2024_v2 comp_upsec_v2_m
	
	
*order iso_code3 country survey year category Sex Location Wealth Region *_m *_no
order iso_code3 country survey year category sex location region *_m
order  *_no , last



*Save individual files
cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Indicators"
save "indicators_`country_code'_`country_year'.dta", replace
	
end