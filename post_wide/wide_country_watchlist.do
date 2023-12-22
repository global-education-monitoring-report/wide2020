***************************
*WIDE WATCHLIST BY COUNTRY*
***************************

* LOAD WIDE latest dataset

*the new one 
import delimited "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\WIDE files\WIDE_2023_sept.csv", clear

* DROP learning observations and indicators

*learning survey list
local surveycodes "ACS LLECE PASEC PISA PISA-D PIRLS SEA-PLM TIMSS TERCE"

local n : word count `surveycodes'
forvalues i = 1/`n' {
local learningsurvey : word `i' of `surveycodes'
drop if survey=="`learningsurvey'"
}

drop mlevel1_m mlevel1_no rlevel1_m rlevel1_no slevel1_m slevel1_no mlevel2_m mlevel2_no rlevel2_m rlevel2_no slevel2_m slevel2_no mlevel3_m mlevel3_no rlevel3_m rlevel3_no slevel3_m slevel3_no mlevel4_m mlevel4_no rlevel4_m rlevel4_no slevel4_m slevel4_no

* KEEP one observation per country-year-survey 

keep if cat=="Total"
keep iso country survey year
duplicates drop

* KEEP the most recent observation per country

bysort country (year): keep if year==year[_N]

* GENERATE oldness 

gen howold = 2023-year
tab howold

* MERGE COUNTRIES that are simply not there for completeness sake

rename iso_code iso3c

merge m:1 iso3c using  "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\countries_updated.dta" 
replace country = abridged_name if _merge == 2 


* LABEL stuff

gen state="Not on WIDE yet" if _merge == 2 
replace state = "Too old" if howold >= 5 & _merge == 3
replace state = "Young enough" if howold < 5 & _merge == 3
tab state

order iso3c country survey year howold state
drop v1
sort state howold

* EXPORT to EXCEL

export excel using "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\wide_country_watchlist.xls", firstrow(variables) replace
