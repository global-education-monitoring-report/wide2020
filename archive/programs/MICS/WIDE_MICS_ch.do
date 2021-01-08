*For my laptop
global data_Pdrive "C:\Users\Rosa_V\Dropbox\WIDE_DHS_MICS\data\mics"
global gral_dir "C:\Users\Rosa_V\Dropbox"

global data_raw_mics "$gral_dir\WIDE\Data\MICS"
global programs_mics "$gral_dir\WIDE_DHS_MICS\programs\mics"
global programs_mics_aux "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE_DHS_MICS\data\mics"


*New version in Desktop-Work
global data_Pdrive "P:\WIDE_DHS_MICS\data\mics"
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global data_raw_mics "$gral_dir\Data\MICS"
global programs_mics "$gral_dir\WIDE\WIDE_DHS_MICS\programs\mics"
global programs_mics_aux "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"
global temp "$data_mics\temp"



*****************************************************************************************************
*	APPENDING ALL THE DATABASES (in 2 mics)
*----------------------------------------------------------------------------------------------------
*****************
set more off
include "$programs_mics_aux\survey_list_CH_mics4"
foreach file in $survey_list_CH_mics4 {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_file = `3'
cap rename *, lower
gen mics="mics4"

cap drop individual_id
cap clonevar hh1=hi1
cap clonevar hh2=hi2
cap clonevar ln=hl1

*Line variable for Mexico
if country=="Mexico" & year_file==2015 {
   ren uf4 ln
}

*For age:
     cap rename ag2y age_child // South Sudan 2010
     cap rename ag2 age_child

*Mauritania doesn't have "ec5"
if country=="Mauritania" & year_file==2011 {
   ren ec5a ec5
}

cap gen ec5=.
gen code_ec5=ec5

gen space=" "
gen individual_id = country+space+string(year_file)+space+string(hh1)+space+string(hh2)+space+string(ln)    

for X in any ec5 hl4: cap decode X, gen(temp_X)
for X in any ec5 hl4: cap tostring X, gen(temp_X) 
drop ec5 hl4
for X in any ec5 hl4: cap ren temp_X X
for X in any d m y: cap ren ag1_X ag1X
for X in any cage ag1y: cap gen X=.
for X in any ec8 ec9 ec10 ec11 ec12 ec13 ec14 ec15 ec16 ec17: cap gen X=.
cap gen uf8y=.
cap ren uf8_y uf8y
cap gen chweight=.
keep individual_id country year ec5 ec8 ec9 ec10 ec11 ec12 ec13 ec14 ec15 ec16 ec17 hl4 age_child cage* ag1* code_ec5 uf8y *weight
label drop _all
cap label drop _all
cap drop ec7*
compress
save "$data_mics\ch\countries\\`1'`3'", replace
}
*****************
set more off
include "$programs_mics_aux\survey_list_CH_mics5"
foreach file in $survey_list_CH_mics5 {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_file = `3'
cap rename *, lower
gen mics="mics5"

cap drop individual_id
cap clonevar hh1=hi1
cap clonevar hh2=hi2
cap clonevar ln=hl1

*Line variable for Mexico
if country=="Mexico" & year_file==2015 {
   ren uf4 ln
}

*For age:
     cap rename ag2y age_child // South Sudan 2010
     cap rename ag2 age_child
	 
*Mauritania doesn't have "ec5"
if country=="Mauritania" & year_file==2011 {
   ren ec5a ec5
}

cap gen ec5=.
gen code_ec5=ec5

gen space=" "
gen individual_id = country+space+string(year_file)+space+string(hh1)+space+string(hh2)+space+string(ln)    

for X in any ec5 hl4: cap decode X, gen(temp_X)
for X in any ec5 hl4: cap tostring X, gen(temp_X) 
drop ec5 hl4
for X in any ec5 hl4: cap ren temp_X X
for X in any d m y: cap ren ag1_X ag1X
for X in any cage ag1y: cap gen X=.

for X in any ec8 ec9 ec10 ec11 ec12 ec13 ec14 ec15 ec16 ec17: cap gen X=.
cap gen uf8y=.
cap ren uf8_y uf8y
cap gen chweight=.
keep individual_id country year ec5 ec8 ec9 ec10 ec11 ec12 ec13 ec14 ec15 ec16 ec17 hl4 age_child cage* ag1* code_ec5 uf8y *weight
cap drop ec7*
label drop _all
cap label drop _all
compress
save "$data_mics\ch\countries\\`1'`3'", replace
}

*********************************************************************************************************
*********************************************************************************************************


* To append all the databases
cd "$data_mics\ch\countries"
local allfiles : dir . files "*.dta"
*di `allfiles'

use "Afghanistan2010.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c
drop cage_an cage_6_an cage_11_an caged_an
drop ag1c ag1f // just for Lao PDR
compress
save "$data_mics\ch\ch_append_mics_4&5.dta", replace

**************************************************************************
*			Translate
**************************************************************************
set more off
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics\ch"
unicode analyze "ch_append_mics_4&5.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "ch_append_mics_4&5.dta"




*****************************************************************************************
*****************************************************************************************

cd "$data_mics\ch"
use "ch_append_mics_4&5.dta", clear

bys individual_id: gen counts_n=_n
drop if counts_n>1 // eliminate duplicates. There are no duplicates!
drop counts_n

foreach var of varlist ec5 {
		replace `var' = subinstr(`var', "-", " ",.) 
		replace `var' = subinstr(`var', "ă", "a",.)
		replace `var' = subinstr(`var', "ĂĄ", "a",.)
		replace `var' = subinstr(`var', "ĂŁ", "a",.)
		replace `var' = subinstr(`var', "ĂŠ", "e",.)
		replace `var' = subinstr(`var', "č", "e",.)
 		replace `var' = subinstr(`var', "ń", "n",.) 
		replace `var' = subinstr(`var', "á", "a",.)
		replace `var' = subinstr(`var', "é", "e",.)
		replace `var' = subinstr(`var', "í", "i",.)
		replace `var' = subinstr(`var', "ó", "o",.)
		replace `var' = subinstr(`var', "ú", "u",.)
 }
 
foreach var of varlist ec5 hl4 {
		replace `var'=lower(`var')
		replace `var'=stritrim(`var')
		replace `var'=strltrim(`var')
		replace `var'=strrtrim(`var')
}

replace hl4="male" if hl4=="garçon"|hl4=="hombre"|hl4=="masculin"|hl4=="masculino"|hl4=="varón"
replace hl4="female" if hl4=="femenino"|hl4=="feminin"|hl4=="feminino"|hl4=="fille"|hl4=="féminin"|hl4=="hembra"|hl4=="mujer"

tab country if age_child==. // 15,517 missing values

codebook cage* , tab(100)
tab country if cage==.


count if cage==.
count if age_child==.

tab cage age_child if cage==., m
tab cage age_child if age_child==., m


tab country year_file if cage==. & age_child!=. // fix this?

tab country if ag1y==. // 24,796 missing

gen space=" "
egen country_year=concat(country space year)
drop space

table country_year, c(count code_ec5)
tab country if ec5==""
tab country if ec5=="." // Cuba doesn't have info on EC5

label define code_ec5 1 "yes" 2 "no" 8 "don't know" 9 "missing"
label values code_ec5 code_ec5
label var code_ec5 "Attends early childhood education programme (CODE)"

ren hl4 hl4_child

cap drop space
cap drop country_year 
order country year_file individual_id hl4 code_ec5 ec5 age_child ag1* cage*
cap drop ec7*
compress
save "ch_mics_4&5.dta", replace


*********** ECD index
/*
use "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS\data\mics\ch\mics6\ch_module.dta", clear
ren uf7y uf8y
drop hhweight ed5a ed5b cage_6 cage_11 caged cdisability caretakerdis windex5 psu strata seeing-dis2 physical litnum-ecd
ren ec15 ec17
ren ec14 ec16
ren ec13 ec15
ren ec12 ec14
ren ec11 ec13
ren ec10 ec12
ren ec9 ec11
ren ec8 ec10
ren ec7 ec9
ren ec6 ec8
compress
save "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS\data\mics\ch\mics6\mics_ch_standard.dta", replace
*/

use "$data_mics\ch\ch_mics_4&5.dta", clear
*ECD index
 for X in any ec8 ec9 ec10 ec11 ec13 ec14 ec15: recode X (2=0) (8/9=.)
 for X in any ec12 ec16 ec17: recode X (1=0) (2=1) (8/9=.)

*codebook ec8 ec9 ec10 ec11 ec13 ec14 ec15, tab(100)
*codebook ec12 ec16 ec17, tab(100)

append using "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS\data\mics\ch\mics6\mics_ch_standard.dta"
gen country_year=country+"_"+string(year_file)
ren uf8y year_interview
replace year_interview=year_file if country_year=="Nepal_2014"
replace year_interview=year_file if (country_year=="Mauritania_2011"|country_year=="Mauritania_2015")
replace year_interview=year_file if (country_year=="Thailand_2012"|country_year=="Thailand_2015")
bys country_year: egen year_median=median(year_interview)

replace year_median=year_file if year_median==.

 ** Literacy & numeracy
 gen sum_litnum=ec8+ec9+ec10
 gen litnum=0
 replace litnum=1 if sum_litnum>=2 & sum_litnum!=.
 replace litnum=. if ec8==. & ec9==. & ec10==.
 
 ** Physical
gen physical=0
replace physical=1 if ec11==1|ec12==1
replace physical=. if ec11==. & ec12==.

** Learning
gen learns=0
replace learns=1 if ec13==1|ec14==1
replace learns=. if ec13==. & ec14==.

** SocioEm
 gen sum_socioem=ec15+ec16+ec17
 gen socioem=0
 replace socioem=1 if sum_socioem>=2 & sum_socioem!=.
 replace socioem=. if ec15==. & ec16==. & ec17==.
 
** ECD index
gen sum_ecd=litnum+physical+learns+socioem
gen ecd=0
replace ecd=1 if sum_ecd>=3 & sum_ecd!=.
replace ecd=. if litnum==. & physical==. & learns==. & socioem==.

foreach X in 0 1 2 3 4 {
	gen domain_`X'=0
	replace domain_`X'=1 if sum_ecd==`X' & sum_ecd!=.
	replace domain_`X'=. if litnum==. & physical==. & learns==. & socioem==.
}
 
drop sum_*
compress
save "$data_mics\ch\ch_mics_4&5&6_ecd.dta", replace


use "$data_mics\ch\ch_mics_4&5&6_ecd.dta", clear
collapse litnum physical socioem learns ecd domain_* if cage>=36 & cage<=59 [iw=chweight], by(country year_median)
drop if litnum==. & physical==. & learns==. & socioem==.
replace country="Kyrgyzstan" if country=="KyrgyzRepublic"
sort country year
ren litnum LiteracyNumeracy
ren learns Learning
ren physical Physical
ren socioem SocioEmotional
ren ecd Index_ECD
br
*use "$temp/ch/ch_mics_4&5.dta", clear


erase "ch_append_mics_4&5.dta"

*Cuba doesn't have info on EC5
