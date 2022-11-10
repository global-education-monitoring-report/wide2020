**********
**EU-LFS**

*30/11 first version compatible with 2015-2019 files
*18/01 working version 
*24/01 first try , left to do is region variable 
*9/11/22 new wealth definition, region recode, location recode 

program define LFS_standalone
	syntax, country_code(string) country_year(string) 


*Read csv file 
cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`country_code'_`country_year'_LFS\"
	fs *.csv
	di "Opening " `r(files)'
	import delimited using `r(files)', clear
	set more off
	
*******Set up category variables: for the moment just sex wealth and location

*Rename weight (Yearly weighting factor (also called COEFF in yearly files) )
rename coeff hhweight

**Sex , same variable but need to recode from
*1 Male 
*2 Female -> 0 
recode sex (1 = 1) (2 = 0)
label define sex 1 "Male" 0 "Female", replace
label values sex sex


**Wealth, is there but for AT2018 56% of individuals are not coded into it, otherwise recode from deciles into quintiles

recode incdecil (99 = .) (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 8 = 4) (9 10 = 5), gen (wealth)
*search missings in case not installed
missings dropvars wealth, force

*Wealth not available in...CZ2018 CZ2019 FI2018 IS2015 IS2016 IS2017 IS2018 IS2019 NO2015-2019 SI2019 SE2015-2019
*Luxembourg has 80% missings
*RO has 70% missings


*R*egion, omg, variable region see excel Countrycodes and zips


**Location (urban-rural), decide how to recode 3 categories of degurba
recode degurba (1 2 = 1) (3 = 0) , gen(location)
label define location 1 "Urban" 0 "Rural"
label values location location



**********Indicators 

gen iso_code3 = "`country_code'"
capture gen year = "`country_year'"

**Import durations from UIS
findfile UIS_duration_age_01102020.dta, path("`c(sysdir_personal)'/")
merge m:1 iso_code3 year using "`r(fn)'", keep(master match) nogenerate



***************IMPORTANT: EDUCATION IS DECLARED FROM 15 YEARS OLD-ONWARDS IN 5 YEARS COHORTS, SO AGE VARIABLE MIGHT BE MISLEADING

*** Completion of main levels (important one is upsec)

// ISCED 0: Early childhood education (‘less than primary’ for educational attainment)
// ISCED 1: Primary education
// ISCED 2: Lower secondary education
// ISCED 3: Upper secondary education
// ISCED 4: Post-secondary non-tertiary education
// ISCED 5: Short-cycle tertiary education
// ISCED 6: Bachelor’s or equivalent level
// ISCED 7: Master’s or equivalent level
// ISCED 8: Doctoral or equivalent level

// 0 No formal edu or below ISCED
// 100 ISCED 1
// 200 ISCED 2 (incl. ISCED 3 programmes of duration of less than 
// 2 years) 
// 302 ISCED 3 programme of duration of 2 years and more,
// sequential (i.e. access to next ISCED 3 programme only)
// 303 ISCED 3 programme of duration of 2 years and more,
// terminal or giving access to ISCED 4 only
// 304 ISCED 3 with access to ISCED 5, 6 or 7
// 300 ISCED 3 programme of duration of 2 years and more, without 
// possible distinction of access to other ISCED levels
// 400 ISCED 4
// 500 ISCED 5
// 600 ISCED 6
// 700 ISCED 7
// 800 ISCED 8
// 999 Not applicable (child less than 15 years)
// .   No answer

recode  hat11lev (0 100 = 0 ) (200/800 = 1) (999 . = .), gen(comp_lowsec)
recode  hat11lev (0 100 200 = 0 ) (300/800 = 1) (999 . = .), gen(comp_upsec)

**comp_lowsec_1524
gen comp_lowsec_1524 = comp_lowsec if age == 17 | age == 22

**comp_lowsec_1519 would be equivalent to _v2
gen comp_lowsec_1519_v2 = comp_lowsec if age == 17 

**comp_upsec_2029
gen comp_upsec_2029 = comp_upsec if age == 22 | age == 27

**comp_lowsec_2024 would be equivalent to _v2
gen comp_upsec_2024_v2 = comp_upsec if age == 22 


*Check Austria case, is it unique or relevant for more countries 


*** Mean years of education

gen eduyears = 0 if hat11lev == 0 
replace eduyears = prim_dur_uis if hat11lev == 100
replace eduyears = prim_dur_uis + lowsec_dur_uis if hat11lev == 200
replace eduyears = prim_dur_uis + lowsec_dur_uis + upsec_dur_uis if hat11lev == 300 | hat11lev == 302 | hat11lev == 303 | hat11lev == 304
replace eduyears = prim_dur_uis + lowsec_dur_uis + upsec_dur_uis + 2 if hat11lev == 400
replace eduyears = prim_dur_uis + lowsec_dur_uis + upsec_dur_uis + 2 if hat11lev == 500
replace eduyears = prim_dur_uis + lowsec_dur_uis + upsec_dur_uis + 3 if hat11lev == 600
replace eduyears = prim_dur_uis + lowsec_dur_uis + upsec_dur_uis + 5 if hat11lev == 700
replace eduyears = prim_dur_uis + lowsec_dur_uis + upsec_dur_uis + 8 if hat11lev == 800
replace eduyears = . if hat11lev == 999 | hat11lev == .
 
**eduyears_2024
gen eduyears_2024 = eduyears if age == 22 

*** Out of school is not possible, because duration of upper secondary never coincides with the age cohorts

*** Completion of tertiary education

recode  hat11lev (0 100/400 = 0 ) (500/800 = 1) (999 . = .), gen(comp_higher_2yrs)
recode  hat11lev (0 100/500 = 0 ) (500/800 = 1) (999 . = .), gen(comp_higher_4yrs)
*This follows the definition from EU SILC : from bachelor's and higher levels count as 4 years

**comp_higher_2yrs_2529
gen comp_higher_2yrs_2529 = comp_higher_2yrs if age == 27

**comp_higher_4yrs_2529
gen comp_higher_4yrs_2529 = comp_higher_4yrs if age == 27

**comp_higher_4yrs_3034
gen comp_higher_4yrs_3034 = comp_higher_4yrs if age == 32


*** Higher education attendance

**attend_higher_1822* age does not coincide :( 

************************** END OF INDICATOR CALCULATION 

foreach var in comp_lowsec_1524 comp_lowsec_1519_v2 comp_upsec_2029 comp_upsec_2024_v2 eduyears_2024 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034  {
cap gen `var'_no=`var'
}
compress

save "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\lfs_microdata.dta", replace

use "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\Auxiliary\lfs_microdata.dta", clear



*global categories_collapse location sex wealth region 
global categories_collapse location sex wealth

global varlist_m comp_lowsec_1524 comp_lowsec_1519_v2 comp_upsec_2029 comp_upsec_2024_v2 eduyears_2024 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 age *_uis 
global varlist_no comp_lowsec_1524_no comp_lowsec_1519_v2_no comp_upsec_2029_no comp_upsec_2024_v2_no eduyears_2024_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no

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

gen survey="EU-SILC"
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


global varlist_m comp_lowsec_1524 comp_lowsec_1519_v2 comp_upsec_2029 comp_upsec_2024_v2 eduyears_2024 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 age *_uis 

* Eliminate those with less than 30 obs
	foreach var of varlist $varlist_m  {
			replace `var' = . if `var'_no < 30
	}
	
*order iso_code3 country survey year category Sex Location Wealth Region *_m *_no
order iso_code3 country survey year category Sex Location Wealth 
order  *_no , last




*Save individual files
cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Indicators"
save "indicators_`country_code'_`country_year'.dta", replace
	
end