*Splitting datasets 

******************MICS*******************

***FIRST STANDARDIZE


use "C:\WIDE\output\MICS\data\mics_standardize.dta"
cd "C:\Users\taiku\UNESCO\GEM Report - wide_standardize"
levelsof country_year, local(country_year)

foreach country_year in `country_year' {
        use "C:\WIDE\output\MICS\data\mics_standardize.dta" if country_year=="`country_year'", clear // specify dhs or mics
        save std_`country_year'.dta, replace
 }  
 

***SECOND RWIDE_CALCULATE

use "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate.dta"
* or
* import delimited "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate.csv", clear

compress
*compressing is important, shriks size enormously though it takes time
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate2.dta"
cd "C:\Users\taiku\UNESCO\GEM Report - wide_calculate"
levelsof country_year, local(country_year)


foreach country_year in `country_year' {
        use "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate2.dta" if country_year=="`country_year'", clear // specify dhs or mics
        save calculate_`country_year'.dta, replace
 }  

**********************DHS*************************

***FIRST STANDARDIZE

use "C:\WIDE\output\DHS\data\dhs_standardize.dta"
cd "C:\Users\taiku\UNESCO\GEM Report - wide_standardize"
levelsof country_year, local(country_year)

foreach country_year in `country_year' {
        use "C:\WIDE\output\DHS\data\dhs_standardize.dta" if country_year=="`country_year'", clear // specify dhs or mics
        save std_`country_year'.dta, replace
 }  
 
 
***SECOND RWIDE_CALCULATE

 import delimited "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate.csv", clear
 
 compress
cd "C:\Users\taiku\UNESCO\GEM Report - wide_calculate\DHS"
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate2.dta", replace
levelsof country_year, local(country_year)


foreach country_year in `country_year' {
        use "C:\Users\taiku\Documents\GEM UNESCO MBR\Rwide_calculate2.dta" if country_year=="`country_year'", clear // specify dhs or mics
        save calculate_`country_year'.dta, replace
 }  

