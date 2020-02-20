
set processors 2

*For my laptop
global gral_dir "C:\Users\Rosa_V\Desktop\WIDE"
global data_raw_dhs "C:\Users\Rosa_V\Dropbox\WIDE\Data\DHS"
global programs_dhs "$gral_dir\WIDE\WIDE_DHS\programs"
global programs_dhs_aux "$programs_dhs\auxiliary"
global aux_data "$gral_dir\WIDE\data_created\auxiliary_data"
global data_dhs "$gral_dir\WIDE\WIDE_DHS\data"
global temp "$data_dhs\temp"


*----------------------------------------------------------------------------------


for X in any IR MR: cap mkdir "$data_dhs\X\\countries"


set more off
include "$programs_dhs_aux\survey_list_IR"

foreach file in $survey_list_IR {
use "$data_raw_dhs/`file'", clear

	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_folder= `3'

ren *, lower
for X in any v001 v002 v130 v131 v150: cap ren mX X
keep if v150==1 // only keep the household head
keep country* year* v001 v002 v130 v131 v150

gen country_year=country+ "_"+string(year_folder)
for X in any v001 v002: gen X_s=string(X, "%25.0f")
gen hh_id = country_year+" "+v001_s+" "+v002_s
for X in any v001 v002 v130 v131 v150 : cap gen X=.

for X in any v130 v131: cap decode X, gen(temp_X)
for X in any v130 v131: cap tostring X, gen(temp_X)
drop v130 v131
for X in any v130 v131: cap ren temp_X X
cap label drop _all
drop v150 v001* v002*
compress
save "$data_dhs\IR\countries\\`1'`3'", replace
}


set more off
include "$programs_dhs_aux\survey_list_MR"

foreach file in $survey_list_MR {
use "$data_raw_dhs/`file'", clear

	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_folder= `3'

ren *, lower
for X in any v001 v002 v130 v131 v150: cap ren mX X
keep if v150==1 // only keep the household head
keep country* year* v001 v002 v130 v131 v150

gen country_year=country+ "_"+string(year_folder)
for X in any v001 v002: gen X_s=string(X, "%25.0f")
gen hh_id = country_year+" "+v001_s+" "+v002_s
for X in any v001 v002 v130 v131 v150 : cap gen X=.

for X in any v130 v131: cap decode X, gen(temp_X)
for X in any v130 v131: cap tostring X, gen(temp_X)
drop v130 v131
for X in any v130 v131: cap ren temp_X X
cap label drop _all
drop v150 v001* v002*
compress
save "$data_dhs\MR\countries\\`1'`3'", replace
}


** APPENDING ALL THE DATABASES

cd "$data_dhs\IR\countries"
local allfiles : dir . files "*.dta"

use "Afghanistan2015.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

save "$data_dhs\IR\dhs_IR.dta" , replace

*-----------
cd "$data_dhs\MR\countries"
local allfiles : dir . files "*.dta"

use "Afghanistan2015.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

save "$data_dhs\MR\dhs_MR.dta" , replace


use "$data_dhs\IR\dhs_IR.dta", clear
append using "$data_dhs\MR\dhs_MR.dta"
save "$data_dhs\IR\dhs_IR_MR_append.dta", replace


*---------------------------------------------------------------------------------------------------------

*Translate: I tried with encoding "ISO-8859-1" and it didn't work
set more off
clear
cd "$data_dhs\IR"
unicode analyze "dhs_IR_MR_append.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "dhs_IR_MR_append.dta"


use "$data_dhs\IR\dhs_IR_MR_append.dta", clear
ren v130 religion
ren v131 ethnicity
include "$programs_dhs_aux\dhs_fixes_religion_ethnicity.do" 
compress
save "$data_dhs\dhs_ethnicity_religion_v2.dta"
