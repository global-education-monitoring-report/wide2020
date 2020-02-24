*For my laptop
global data_Pdrive "C:\Users\Rosa_V\Dropbox\WIDE_DHS_MICS\data\mics"
global gral_dir "C:\Users\Rosa_V\Dropbox"

global data_raw_mics "$gral_dir\WIDE\Data\MICS"
global programs_mics "$gral_dir\WIDE_DHS_MICS\programs\mics"
global programs_mics_aux "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE_DHS_MICS\data\mics"

*New version in Desktop-Work
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global data_raw_mics "$gral_dir\Data\MICS"
global programs_mics "$gral_dir\WIDE\WIDE_DHS_MICS\programs\mics"
global programs_mics_aux "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"

*****************************************************************************************************
*	APPENDING ALL THE DATABASES (in 2 mics)
*----------------------------------------------------------------------------------------------------
set more off
include "$programs_mics_aux\survey_list_WM_mics4"
foreach file in $survey_list_WM_mics4 {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_file = `3'
	
cap rename *, lower
gen round_mics="mics4"

cap drop individual_id

cap rename hl1 ln
cap rename wm4 ln // changed

format hh1 %20.0g // modify to get the whole number
tostring hh1, gen(hh1_s) format(%25.0f)

gen space=" "
gen individual_id = country+space+string(year_file)+space+hh1_s+space+string(hh2)+space+string(ln)    


for X in any wb7 welevel: cap gen X=.
for X in any wb7 welevel: gen code_X=X
for X in any wb7 welevel: cap decode X, gen(temp_X)
for X in any wb7 welevel: cap tostring X, gen(temp_X) 
drop wb7 welevel
for X in any wb7 welevel: cap ren temp_X X
cap ren wm6_y wm6y
keep individual_id country year wb7 welevel code* wmweight round_mics wm6y wb2 wage
label drop _all
cap label drop _all
compress
save "$data_mics\wm\countries\\`1'`3'", replace
}
*****************
set more off
include "$programs_mics_aux\survey_list_WM_mics5"
foreach file in $survey_list_WM_mics5 {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_file = `3'
	
cap rename *, lower
gen round_mics="mics5"

cap drop individual_id

cap rename hl1 ln
cap rename wm4 ln // changed

format hh1 %20.0g // modify to get the whole number
tostring hh1, gen(hh1_s) format(%25.0f)

gen space=" "
gen individual_id = country+space+string(year_file)+space+hh1_s+space+string(hh2)+space+string(ln)    

cap ren wm6_y wm6y
cap gen wm6y=. // Mali 2015 doesn't have year..
for X in any wb7 welevel: cap gen X=.
for X in any wb7 welevel: gen code_X=X
for X in any wb7 welevel: cap decode X, gen(temp_X)
for X in any wb7 welevel: cap tostring X, gen(temp_X) 
drop wb7 welevel
for X in any wb7 welevel: cap ren temp_X X

keep individual_id country year wb7 welevel code* wmweight round_mics wm6y wb2 wage
label drop _all
cap label drop _all
compress
save "$data_mics\wm\countries\\`1'`3'", replace
}


*********************************************************************************************************
*********************************************************************************************************


* To append all the databases
cd "$data_mics\wm\countries"
local allfiles : dir . files "*.dta"
*di `allfiles'

use "Afghanistan2010.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c
compress
save "$data_mics\wm\wm_append_mics_4&5.dta", replace





**************************************************************************
*			Translate
**************************************************************************
set more off
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics\wm"
unicode analyze "wm_append_mics_4&5.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "wm_append_mics_4&5.dta"


*****************************************************************************************
*****************************************************************************************

cd "$data_mics\wm"
use "wm_append_mics_4&5.dta", clear

bys individual_id: gen counts_n=_n
codebook individual_id
drop if counts_n>1 // eliminate duplicates. There are no duplicates!
drop counts_n

codebook wb7, tab(100)
foreach var of varlist wb7 welevel {
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
		replace `var' = subinstr(`var', "Ă§", "c",.)
		replace `var' = subinstr(`var', "ç", "c",.)
}

foreach var of varlist wb7 welevel {
		replace `var'=lower(`var')
		replace `var'=stritrim(`var')
		replace `var'=strltrim(`var')
		replace `var'=strrtrim(`var')
}

table wb7, c (mean code_wb7 min code_wb7 max code_wb7)

*Fixing the labels (especial case of Mauritania 2011)
replace code_wb7=5 if code_wb7==4 & country=="Mauritania" & year_file==2011 

*Creates the labels for code_wb7
label define code_wb7 1 "cannot read at all" 2 "able to read only parts of sentence" 3 "able to read whole sentence" ///
4 "no sentence in required language" 5 "has some disability (blind, mute, etc)" 9 "missing"
label values code_wb7 code_wb7

*Creates the literacy-related variables
for X in any illiteracy semiliteracy literacy: gen X=0
replace illiteracy=1 if code_wb7==1
replace semiliteracy=1 if code_wb7==2
replace literacy=1 if code_wb7==3
for X in any illiteracy semiliteracy literacy: replace X=. if (code_wb7==.|code_wb7==4|code_wb7==5|code_wb7==9)

drop wage // age in ranges

*Fixing the year..
	replace wm6y=year_file if country=="Nepal" & year_file==2014 // year for Nepal is 2070 and 2071..
	replace wm6y=year_file if country=="Thailand" & year_file==2012
	replace wm6y=year_file if country=="Mali" & year_file==2015
	
gen year=wm6y
replace year=year_file if year==.	
bys country year_file: egen year_median=median(year)
drop wm6y
bys code_wb7: tab wb7, m

drop wb7 // in many languages, not standardized. note: for Guinea-Bissau 2014, weird that 1="Nao pode ler tudo"


label var year "year of the interview"
label var year_median "median of year per country"
ren wb2 age	

*for X in any illiteracy semiliteracy literacy: tab code_wb7 X, m
gen sex="Female"
gen survey="MICS"
compress
drop code_welevel
drop year_file
ren code_wb7 wb7
order survey country year* round individual wmwe age sex wb7 
compress
save "wm_mics_4&5.dta", replace
******************

use "$data_mics\wm\wm_mics_4&5.dta", clear
append using "$data_mics\wm\mics6_wm_literacy.dta"
drop wm6y
drop hh1 hh2 ln
drop code_welevel
replace wb7=code_wb14 if round_mics=="mics6"
drop individual_id
replace wb7=4 if wb7==6 & (country=="LaoPDR"|country=="SierraLeone") & year==2017
tab wb7 code_wb14 if round_mics=="mics6"
drop code_wb14
drop illiteracy semiliteracy literacy
foreach var of varlist welevel {
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
		replace `var' = subinstr(`var', "Ă§", "c",.)
		replace `var' = subinstr(`var', "ç", "c",.)
}

foreach var of varlist welevel {
		replace `var'=lower(`var')
		replace `var'=stritrim(`var')
		replace `var'=strltrim(`var')
		replace `var'=strrtrim(`var')
}
compress

replace welevel="none" if welevel=="niguna"|welevel=="ninguna"|welevel=="ninguno"|welevel=="aucun"|welevel=="sans instruction"|welevel=="sin escolarizacion"
replace welevel="none or pre primary" if welevel=="pre school or none/primary"|welevel=="ece, pre primary and none"|welevel=="none or ece"
replace welevel="preschool" if welevel=="prescolaire"
replace welevel="higher" if welevel=="high"|welevel=="higher/high"|welevel=="superieur"|welevel=="superior"
replace welevel="missing" if welevel=="manquant"|welevel=="manquant/nsp"|welevel=="missing/dk"
replace welevel="doesn't answer" if welevel=="no reportado/no sabe"|welevel=="no responde"|welevel=="omitido/no sabe"
replace welevel="post secondary non tertiary" if welevel=="post secondary / non tertiary"
replace welevel="primary" if welevel=="primaire"|welevel=="primaria"|welevel=="primario"
replace welevel="secondary +" if welevel=="secondaire & +"|welevel==""|welevel=="secondaire +"|welevel=="secundaria y +"|welevel=="secundario e mais"
replace welevel="secondary" if welevel=="secondaire"|welevel=="secundaria"|welevel=="secundario"
replace welevel="tertiary" if welevel=="terciaria"|welevel=="terciario"
replace welevel="university" if welevel=="universitaria"
replace welevel="upper secondary _" if welevel=="upper secondary+"

tab welevel

order  country survey year* wmweight age sex wb7 welevel
ren country country_name_mics
replace country_name_mics="Kyrgyzstan" if country_name_mics=="KyrgyzRepublic"
replace country_name_mics="Gambia" if country_name_mics=="TheGambia" 
merge m:m country_name_mics using "$gral_dir\WIDE\data_created\auxiliary_data\country_iso_codes_names.dta", keepusing(iso_code3 country)
drop if _m==2
drop _merge country_name_mics
order survey round iso country year* wmweight age sex wb7 welevel
compress
save "$data_mics\wm\mics_literacy.dta", replace


erase "wm_append_mics_4&5.dta"
*******************


*Argentina, Cuba and Palestine do not have info on LITERACY
