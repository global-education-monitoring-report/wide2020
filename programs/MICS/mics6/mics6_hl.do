*For Desktop-Work
*global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
*global data_raw_mics "$gral_dir\Data\MICS"

*For laptop
*global gral_dir "C:\Users\Rosa_V\Dropbox"
*global data_raw_mics "$gral_dir\WIDE\Data\MICS"

*global programs_mics "$gral_dir\WIDE\WIDE_DHS_MICS\programs\mics"
*global aux_programs "$programs_mics\auxiliary"
*global aux_data "$gral_dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
*global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"


global data_mics "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\hl"
*Vars to keep
global vars_mics6 hh1 hh2 hh5* hl1 hl3 hl4 hl5* hl6 hl7 hh6* hh7* ed1 ed3* ed4* ed5* ed6* ed7* ed8* windex5 schage hhweight religion ethnicity region windex5 disability caretakerdis
global list6 hh6 hh7 ed3 ed4a ed4b ed5 ed6b ed6a ed7 ed8a religion ethnicity hh7r ed3x ed4 ed4ax region disability caretakerdis
global vars_keep_mics "hhid hvidx hv000 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124"
global categories sex urban region wealth
*global extra_keep ...// for the variables that I want to add later ex. cluster

*****************************************************************************************************
*	Preparing databases to append later (MICS 4 & 5)
*----------------------------------------------------------------------------------------------------


* CREATING INDIVIDUAL DATABASES FOR EACH OF THE COUNTRIES

foreach country in Iraq KyrgyzRepublic LaoPDR SierraLeone Suriname TheGambia Tunisia Lesotho Madagascar Mongolia Zimbabwe Georgia {
 set more off
 use "C:\Users\Rosa_V\Dropbox\WIDE\Data\MICS\\`country'\hl.dta", clear
 gen country="`country'"
 include "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\programs\auxiliary\mics6_standardizes_hl.do"
 save "$data_mics\countries\\`country'.dta", replace
}

********************************************************************************
* 	Appending all the databases
********************************************************************************

cd "$data_mics\countries"
local allfiles : dir . files "*.dta"
use "Iraq.dta", clear
gen id_c=1

foreach f of local allfiles {
	qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

order country year_folder hh1 hh2 hl1 hl3 hl4 hl5* hl7 ed1 ed3 ed4a ed4a_nr ed4b ed4b_nr ed_completed ///
ed5 ed6a ed6a_nr ed6b ed6b_nr hh6 hh7 region ethnicity hhweight windex5 schage 

*there is no religion?
label var ed_completed "Ever completed that grade/year"
compress
save "$data_mics\hl_append_mics_6.dta", replace


**************************************************************************
*	Translate
**************************************************************************
set more off
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics"
unicode analyze "hl_append_mics_6.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "hl_append_mics_6.dta"


*************************************************************************
*	Creating categories
**************************************************************************

use "$data_mics\hl_append_mics_6.dta", clear
set more off
* ID for each country year: Variable country_year
*year of survey (in the data) can be different from the year in the name of the folder. Or there can be 2 years in the data as the survey expanded through 2 years
*Important because eduvars can change through years for the same country
	cap ren year_file year_folder
	gen country_year=country+ "_" +string(year_folder)

*Individual ids
	gen hh1_s=string(hh1, "%25.0f")
	gen individual_id = country_year+" "+hh1_s+" "+string(hh2)+" "+string(hl1)
    gen hh_id= country_year+" "+hh1_s+" "+string(hh2)
	ren hh1 cluster
	cap drop hh1* hh2 hl1 hl7 ed1
	codebook individual_id // uniquely identifies people
	
*	YEAR OF THE SURVEY:  "Official" Year of the survey (interview) is hh5y. 
* 	Inteview date:  hh5y=year; hh5m=month; hh5d=day  
	codebook hh5*, tab(100)

***************************
*Creating categories
***************************
*Sex
ren hl4 sex
	recode sex (2=0) (9=.) (3/4=.)
	label define sex 0 "female" 1 "male"
	label values sex sex

*Age
ren hl6 age
gen ageA=age-1
gen ageU=age

*Urban
replace hh6=lower(hh6)
gen urban=.
*codebook hh6
	replace urban=0 if (hh6=="rural"|hh6=="rural coastal"|hh6=="rural interior"|hh6=="rural with road"|hh6=="rural without road")
	replace urban=1 if (hh6=="urbain"|hh6=="urban")

label define urban 0 "rural" 1 "urban" 2 "camps"
label values urban urban
drop hh6

*Wealth
ren windex5 wealth

*Weight: already named hhweight

*codebook ethnicity, tab(200)

*Fixes regions, ethnicity, religion (later)

drop hl3
compress
save "$data_mics\Step_0.dta", replace


***************************************************************************************************************************************************************
***************************************************************************************************************************************************************

use "$data_mics\Step_0.dta", clear
set more off

*****************************************************
** RECODES EDU LEVEL VARIABLES
*****************************************************

* ed3= ever attended school
* ed4a= highest level of edu (ever) 
* ed5= currently attending
* ed6a= current level of edu

*---- 1. Changes to Edu labels

* Eliminates alpha-numeric characters & accents
foreach var of varlist ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a {
	replace `var' = subinstr(`var', "-", " ",.) 
	replace `var' = subinstr(`var', "ă", "a",.)
	replace `var' = subinstr(`var', "ŕ", "a",.)
	replace `var' = subinstr(`var', "ĂĄ", "a",.)
	replace `var' = subinstr(`var', "ĂŁ", "a",.)
	replace `var' = subinstr(`var', "ĂŠ", "e",.)
	replace `var' = subinstr(`var', "č", "e",.)
	replace `var' = subinstr(`var', "ń", "n",.) 
	replace `var' = subinstr(`var', "á", "a",.)
	replace `var' = subinstr(`var', "à", "a",.)
	replace `var' = subinstr(`var', "è", "e",.)
	replace `var' = subinstr(`var', "é", "e",.)
	replace `var' = subinstr(`var', "í", "i",.)
	replace `var' = subinstr(`var', "ó", "o",.)
	replace `var' = subinstr(`var', "ú", "u",.)
 }
 
foreach var of varlist ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed_completed {
	replace `var'=lower(`var')
	replace `var'=stritrim(`var')
	replace `var'=strltrim(`var')
	replace `var'=strrtrim(`var')
}

foreach var of varlist ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed_completed {
	replace `var' = "no" if (`var'=="nao"|`var'=="non")
	replace `var' = "yes" if (`var'=="si"|`var'=="sim"|`var'=="oui")
	replace `var' = "missing" if (`var'=="em falta"|`var'=="manquant"|`var'=="omitido"|`var'=="no reportado")
	replace `var' = "doesn't answer" if (`var' =="nr"|`var'=="non declare/pas de reponse"|`var'=="no responde"|`var'=="no response")
	replace `var' = "don't know" if (`var'=="dk"|`var'=="no sabe"|`var'=="nao sabe"|`var'=="ns"|`var'=="ne sait pas"|`var'=="nsp")
	replace `var' = "inconsistent" if (`var'=="inconsistente"|`var'=="incoherent"|`var'=="incoherence"|`var'=="incoherencia"|`var'=="incoherente")
	replace `var' = "" if (`var'==".")
}
*-----------------------------------------------------------------------------------------------------------

** RECODING ED3 "ever attended school or pre-school?
* codebook ed3, tab(100) // ok

** RECODING ED5 "Currently attending school"
* codebook ed5, tab(100) // ok
	
for X in any ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a: codebook X, tab(100)

*---- 2) Creation of the new var & recoded: Re-codify the levels of ed4a & ed6a according to the NEW value labels

for X in any ed4a ed6a ed8a: gen code_X=X_nr

* The standard edulevel label for ed4a is : 0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 8 "don't know" 9 "missing/doesn't answer" 
* The NEW value label for edulevel to be applied to code_ed4a


	
* Case 1) Countries that have same as the standard edulevel code (0=preschool, 1=primary, 2=secondary, 3=higher).
* 		  I only need to recode (8=98) (9=99). Do it for all country years:
compress
save "$data_mics\Step_0_a.dta", replace

*******************************************************************************
*******************************************************************************

use "$data_mics\Step_0_a.dta", clear

label define edulevel_new ///
	0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 98 "don't know" 99 "missing/doesn't answer" ///
	21 "lower secondary" 23 "voc/tech/prof as lowsec" ///
	22 "upper secondary" 24 "voc/tech/prof as upsec" ///
	32 "post-secondary or superior no university" 33 "voc/tech/prof as higher" ///
	40 "post-graduate (master, PhD, etc)" ///
	50 "special/literacy program" 51 "adult education" ///
	60 "general school (ex. Mongolia, Turkmenistan)" ///
	70 "primary+lowsec (ex. Sudan & South Sudan)" ///
	80 "not formal/not regular/not standard" ///
	90 "khalwa/coranique (ex. Mauritania, SouthSudan, Sudan)" 

	
*To check duration of levels	
gen level=string(ed4a_nr)+"_"+ed4a
bys country_year: tab ed4b_nr level, m
codebook level if country_year=="Georgia_2018", tab(100)
	
	
*Kyr: (7) 4+5+2
*Lao: (6) 5+4+3 --> coincides with data :)
*TUN: (6) 6+3+4 --> coincides with data :)
*SUR: (6) 6+4+3  changed through years!
*SLE: (6) 6+3+4  changed through years!
*IRQ: problems with level codes
*TheGambia: (7) 6+3+3 --> Coincides with data. Problems with the othe level codes
* Added later:
*Lesotho:   (6) 7+3+2 --> coincides with data, but check the level for "vocational"
*Madagascar:(6) 5+4+3 --> coincides with data :)
*Mongolia:  (6) 5+4+3 --> especial case
*Zimbabwe:  (6) 7+2+4 --> doesn't coincide with data. Data says that lowsec is 4y & upsec 2y
*Georgia: (6) 6+3+3 
	


* Countries that need recoding of the edulevel to be in line with the NEW value labels

foreach var of varlist code_ed4a code_ed6a code_ed8a {
	recode `var' (2=21) (3=24) (4=22) (5=24) (6=3) (7=40) (8=98) (9=99) if country_year=="Iraq_2018"
	recode `var' (2=21) (3=22) (4=32) (5=3) if country_year=="KyrgyzRepublic_2018"
	recode `var' (2=21) (3=22) (4=32) (5=3) (8=98) if country_year=="LaoPDR_2017"
	recode `var' (2=21) (3=22) (4=3) (5 6 9=23) (7=24) (8=33) if country_year=="Tunisia_2018" 
	recode `var' (2=21) (3=22) (4=3) (5=33) if country_year=="SierraLeone_2017" // vocation/technical/nursing/teacher classified as HIGHER
	recode `var' (0/1=0) (2=1) (3=21) (4=22) (5=3) if country_year=="Suriname_2018"
	recode `var' (2=21) (3=22) (4 5=33) (6=3) if country_year=="TheGambia_2018" // vocational & diploma as post-secondary... check this later if needed
	recode `var' (4=23) (8=98) (9=99) if country_year=="Lesotho_2018" // vocational as lowsec... check this later if needed
	recode `var' (4=23) (2=21) (3=22) (4=3) (8=98) (9=99) if country_year=="Madagascar_2018"
	recode `var' (1=60) (3=23) (4=3) (8=98) (9=99) if country_year=="Mongolia_2018" // to check: vocational as lowsec? Also, problems in higher duration (30 years)
	recode `var' (1=60) (2=21) (3=23) (4=22) (5=24) (6 7=33) (8=3) (9 10=40) if country_year=="Zimbabwe_2019" // need to CORRECT, info not consistent
	recode `var' (2=21) (3=22) (4=24) (5=33) (6=3) (8=98) (9=99) if country_year=="Georgia_2018" // check vocational.. what does "on the base of" means?
}


 * Recode for all country_years. I don't need to do it later again
	for X in any ed4a ed6a ed8a: replace code_X=97 if (X=="inconsistent")
	for X in any ed4a ed6a ed8a: replace code_X=98 if X=="don't know"
	for X in any ed4a ed6a ed8a: replace code_X=99 if (X=="missing"|X=="doesn't answer"|X=="missing/dk")

* Putting labels to the values
	for X in any code_ed4a code_ed6a code_ed8a: label values X edulevel_new 
	
compress
save "$data_mics\Step_0_temp.dta", replace
*****************************************************

use "$data_mics\Step_0_temp.dta", clear
set more off
bys country_year: egen year=median(hh5y)

*merge with information of duration of levels, school calendar, official age for primary, etc:
	gen iso_code3=""
	replace iso_code3="IRQ" if country=="Iraq"
	replace iso_code3="KGZ" if country=="KyrgyzRepublic"
	replace iso_code3="LAO" if country=="LaoPDR"
	replace iso_code3="SLE" if country=="SierraLeone"
	replace iso_code3="SUR" if country=="Suriname"
	replace iso_code3="GMB" if country=="TheGambia"
	replace iso_code3="TUN" if country=="Tunisia"
	replace iso_code3="LSO" if country=="Lesotho"
	replace iso_code3="MDG" if country=="Madagascar"
	replace iso_code3="MNG" if country=="Mongolia"
	replace iso_code3="ZWE" if country=="Zimbabwe"
	replace iso_code3="GEO" if country=="Georgia"

	rename country country_name_mics
	*Input the iso_code

	*The durations for 2018 are not available, so I create a "fake year"
	ren year year_original
	gen year=year_original
	replace year=year_original-1 if year_original==2018
	replace year=year_original-2 if year_original==2019
	merge m:1 iso_code3 year using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\data_created\auxiliary_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	drop year
	ren year_original year
	drop if _m==2
	drop _merge
	drop lowsec_age_uis upsec_age_uis

	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
	ren prim_age_uis prim_age0
	gen higher_dur=4 // provisional
	
	*CHANGES IN DURATION
	
	*CHANGES IN START AGE
		
*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur

compress
save "$data_mics\Step_1.dta", replace

*******************************************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************************************


use "$data_mics\Step_1.dta", clear
set more off
* 	EDUYEARS: Going to do it for ED4 only --> this is for later: for X in any ED4 ED6: cap gen eduyears_X=.
*	Checking ed4b vs the duration of levels

	gen eduyears=. // based in ed4b original

*Rename the ed4b variables to make it easier to use
	ren ed4b ed4b_label
	ren ed4b_nr ed4b


* STRATEGY: Classify countries by how they present the "tab ed4b ed4a" : STAIRS, FLAT, OTHER
 bys country_year: tab ed4b level, m
 

*-----------------------------
*1) For those with STAIRS 
*-----------------------------

*--1b) STAIRS AND HAS INFO OF YEAR IN HIGHER ED
	* LaoPDR_2016
	replace eduyears=ed4b-10 if ed4b>=11 & ed4b<=15 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-15 if ed4b>=21 & ed4b<=24 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-21 if ed4b>=31 & ed4b<=33 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-28 if ed4b>=41 & ed4b<=43 & country_year=="LaoPDR_2017"
	replace eduyears=ed4b-38 if ed4b>=51 & ed4b<=57 & country_year=="LaoPDR_2017"
	
	
*--1d) STAIRS UNTIL SECONDARY + FLAT FOR HIGHER (has info on years higher)
*need to recode Kazakhstan_2015! Vocational is 33 not 24?? Republic of Moldova needs the same adjustment?
foreach country_year in KyrgyzRepublic_2018 {
	*Stairs for higher
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==21|code_ed4a==22|code_ed4a==23) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'"
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"
}

*--1e) STAIRS + FLAT FOR UPSEC onwards (has info on years higher)
foreach country_year in Tunisia_2018 Georgia_2018 {
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==21) & country_year=="`country_year'"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'"
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"
}

*Special case: Suriname_2018
replace ed4b=0 if code_ed4a==0 & country_year=="Suriname_2018"
replace ed4b=ed4b-2 if code_ed4a==1 & country_year=="Suriname_2018"

*		2a) FLAT with years in higher ed

foreach country_year in TheGambia_2018 SierraLeone_2017 Suriname_2018 Lesotho_2018 Madagascar_2018 Mongolia_2018 Zimbabwe_2019 {
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==60|code_ed4a==70) & country_year=="`country_year'"	// code_ed4a=70 for DominicanRepublic_2014
	replace eduyears=ed4b+years_prim if (code_ed4a==2|code_ed4a==21|code_ed4a==23) & country_year=="`country_year'" // for Belize 2011 (ed4a=23)
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"  // for Swaziland_2010 & Swaziland_2014 & Tunisia 2011, Kazakhstan_2010 
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'" // for Mexico_2015
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"  // Iraq, Thailand, Mexico have "higher than higher"
}
	
*Special version of flat	
foreach country_year in Iraq_2018 {
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==60|code_ed4a==70) & country_year=="`country_year'"	// code_ed4a=70 for DominicanRepublic_2014
	replace eduyears=ed4b+years_prim if (code_ed4a==2|code_ed4a==21|code_ed4a==22) & country_year=="`country_year'" // for Belize 2011 (ed4a=23)
	replace eduyears=ed4b+years_lowsec if (code_ed4a==24) & country_year=="`country_year'"  // for Swaziland_2010 & Swaziland_2014 & Tunisia 2011, Kazakhstan_2010 
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'" // for Mexico_2015
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"  // Iraq, Thailand, Mexico have "higher than higher"
}
	
	
	*----------------------------------------------
	*** DO THIS FOR ALL
	*----------------------------------------------
	
	* Recode for all country_years. I don't need to do it later again
	replace eduyears=97 if (ed4b==97|ed4b_label=="inconsistent")
	replace eduyears=98 if (ed4b==98|ed4b_label=="don't know")
	replace eduyears=99 if (ed4b==99|ed4b_label=="missing"|ed4b_label=="doesn't answer"|ed4b_label=="missing/dk")
	
	*Super important step (FOR ALL)
	replace eduyears=0 if ed4b==0 // this keeps the format for version B
	
	*For MICS6: incorporating info from "ed_completed
	replace eduyears=eduyears-1 if ed_completed=="no" & (eduyears<=97)
	
	tab eduyears ed_completed, m
		
cap drop t temp
compress
save "$data_mics\Step_2.dta", replace
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
use "$data_mics\hl\Step_2.dta", clear
	decode code_ed4a, gen(code_ed4a_label)
	gen check_ed4a=string(code_ed4a)+" "+code_ed4a_label
	
	set more off
	cap log close
	log using "$data_mics\hl\logs\2_TAB eduyears code_ed4a.log", replace
	bys country_year: tab eduyears check_ed4a, m 
	log close
	
	set more off
	cap log close
	log using "$data_mics\hl\logs\2_ED4B_label eduyears.log", replace
	bys country_year: tab eduyears ed4b_label, m 
	log close
	
	set more off
	cap log close
	log using "$data_mics\hl\logs\2_ED4B_label.log", replace
	bys country_year: tab ed4b_label, m 
	log close
*/

*********************************************************************************************************
use "$data_mics\Step_2.dta", clear
set more off
*-----------------------------------------
* 		Creating the Completion indicators
*-----------------------------------------

*Ages for completion
	gen lowsec_age0=prim_age0+prim_dur
	gen upsec_age0=lowsec_age0+lowsec_dur
	for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1

	
** VERSION B: Mix of years of education completed and level duration
	ren eduyears eduyears_B // how it was already created

*-- Without Age limits
* I consider that those with or with more years than those necessary for completing that level have completed that level.

foreach X in prim lowsec upsec higher {
	gen comp_`X'_B=0
	replace comp_`X'_B=1 	if eduyears_B>=years_`X'
	replace comp_`X'_B=. 	if (eduyears_B==.|eduyears_B==97|eduyears_B==98|eduyears_B==99)
	replace comp_`X'_B=0 	if ed3=="no"  // those that never went to school have not completed!
	replace comp_`X'_B=0 	if code_ed4a==0 // those that went to kindergarten max have no completed primary.
}


*Age limits for Version B
foreach X in prim lowsec upsec {
foreach AGE in ageU ageA {
	gen comp_`X'_v2_B_`AGE'=comp_`X'_B if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5 
}
}
*----------------------------------------
* VERSION C (B with FIX): 
*----------------------------------------
	
*Fix: 
	*Recoding those with zero to a lower level of education 
	*Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!

gen eduyears_C=eduyears_B	
	replace eduyears_C=	years_prim 		if eduyears_B==0 & (code_ed4a==2|code_ed4a==21|code_ed4a==23)
	replace eduyears_C=	years_lowsec 	if eduyears_B==0 & (code_ed4a==22|code_ed4a==24)
	replace eduyears_C=	years_upsec 	if eduyears_B==0 & (code_ed4a==3|code_ed4a==32|code_ed4a==33)
	replace eduyears_C=	years_higher 	if eduyears_B==0 & code_ed4a==40
	
*-- Without Age limits 
* I consider that those with or with more years than those necessary for completing that level to have completed that level.
foreach X in prim lowsec upsec higher {
	gen comp_`X'_C=0
	replace comp_`X'_C=1	if eduyears_C>=years_`X'
	replace comp_`X'_C=. 	if (eduyears_C==.|eduyears_C==97|eduyears_C==98|eduyears_C==99)
	replace comp_`X'_C=0 	if ed3=="no"  // those that never went to school have not completed!
	replace comp_`X'_C=0 	if code_ed4a==0 // those that went to kindergarten max have no completed primary.
}
	

*Age limits for Version C
foreach X in prim lowsec upsec {
foreach AGE in ageU ageA {
	gen comp_`X'_v2_C_`AGE'=comp_`X'_C if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5
}
}

*Labels for the variables
*include "$aux_programs\labels_names.do" // labels to variables

*--------------------------------------------------------------------------------------
* 	Never been to school (edu0 created the same way as "schlnever", they are the SAME)
*--------------------------------------------------------------------------------------
*codebook ed3, tab(100) 

*------------------------------------------
*	 Attendance 
*------------------------------------------
*codebook ed5 ed6a, tab(300)
** Recoding ED5: "Attended school during current school year?"
	gen attend=1 if ed5=="yes" // equivalent to school
	replace attend=0 if ed5=="no"
gen eduout=.
compress
save "$data_mics\Step_4.dta", replace

**********************************************************************************************
**********************************************************************************************

global categories_collapse location sex wealth region ethnicity religion
global categories_subset location sex wealth
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no

/*
use "$data_mics\hl\Step_4.dta", clear
set more off

*--------- TEMPORARY
encode country_year, gen(c_n)
keep if c_n<=27

drop  region district ethnicity religion wealth hh5d hh5m hh5y urban
drop year_folder cluster hh6 individual_id hh_id country_code_dhs
compress

*Dropping the B version because it is not going to be used. 
drop *_B_ageU *_B_ageA *_B // the version C is the one to keep
drop *C_ageU *C_ageA
drop hl*
*Renaming the vars from _C
foreach var in comp_prim comp_lowsec comp_upsec comp_higher eduyears {
	rename `var'_C `var'
}
drop c_n
compress
save "$data_mics\hl\SUBSET_Step_4.dta", replace
*/

**********************************************************************************************************
**********************************************************************************************************

use "$data_mics\Step_4.dta", clear
set more off

*Dropping the B version because it is not going to be used. 
drop *_B_ageU *_B_ageA *_B // the version C is the one to keep
drop *C_ageU *C_ageA

*Renaming the vars from _C
foreach var in comp_prim comp_lowsec comp_upsec comp_higher eduyears {
	rename `var'_C `var'
}

*---------------
/*
*Bilal's request

*Creating age groups for preschool
gen age_group=1 if (ageU==3|ageU==4)
replace age_group=2 if ageU==5
replace age_group=3 if (ageU==6|ageU==7|ageU==8)

label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
label values age_group age_group

gen presch_before=1 if (ed7=="yes"|ed7=="1") & code_ed8a==0
tab attend if presch_before==1 // until here it is ok

gen attend_primary=1 if attend==1 & (code_ed6a==1|code_ed6a==60|code_ed6a==70)
replace attend_primary=0 if attend==1 & code_ed6a==0
replace attend_primary=0 if attend==0
*/



*enrolment rate in pre-primary relative to the population, by single age
*- can be created with attend_preschool, with no restriction of preschool before

*the new entry into pre-primary (i.e. not enrolled in education at all last year, enrolled in pre-primary this year), by single age?

cap drop eduout

recode attend (1=0) (0=1), gen(no_attend)

gen eduout=no_attend
replace eduout=. if (attend==1 & code_ed6a==.)
replace eduout=. if age==.
replace eduout=. if (code_ed6a==98|code_ed6a==99) & eduout==0 // missing when age, attendance or level of attendance (when goes to school) is missing
replace eduout=1 if code_ed6a==0 // level attended: goes to preschool 
replace eduout=1 if ed3=="no" // "out of school" if "ever attended school"=no

replace eduout=1 if code_ed6a==80 // level attended=not formal/not regular/not standard
replace eduout=1 if code_ed6a==90 // level attended=khalwa/coranique (ex. Mauritania, SouthSudan, Sudan)
*Code_ed6a=80/90 affects countries Nigeria 2011, Nigeria 2016, Mauritania 2015, SouthSudan 2010, Sudan 2010 2014

*schage available for all countries (no need to do the adjustment)

**** Age limits for completion and out of school
*Age limits 
foreach X in prim lowsec upsec {
	gen comp_`X'_v2=comp_`X' if schage>=`X'_age1+3 & schage<=`X'_age1+5

}

* FOR UIS request
gen comp_prim_aux=comp_prim if schage>=lowsec_age1+3 & schage<=lowsec_age1+5
gen comp_lowsec_aux=comp_lowsec if schage>=upsec_age1+3 & schage<=upsec_age1+5


*foreach AGE in agestandard  {
foreach AGE in schage  {
	gen comp_prim_1524=comp_prim if `AGE'>=15 & `AGE'<=24
	gen comp_upsec_2029=comp_upsec if `AGE'>=20 & `AGE'<=29
	gen comp_lowsec_1524=comp_lowsec if `AGE'>=15 & `AGE'<=24
}

*With age limits
*gen eduyears_2024=eduyears if agestandard>=20 & agestandard<=24
gen eduyears_2024=eduyears if schage>=20 & schage<=24
foreach X in 2 4 {
	gen edu`X'_2024=0
	replace edu`X'_2024=1 if eduyears_2024<`X'
	replace edu`X'_2024=. if eduyears_2024==.
}

* NEVER BEEN TO SCHOOL
gen edu0=0 if ed3=="yes"
replace edu0=1 if ed3=="no"
replace edu0=1 if (code_ed4a==0) // highest ever attended is preschool
replace edu0=1 if (eduyears==0)

*tab code_ed6a attend , m 

foreach AGE in schage  {
	gen edu0_prim=edu0 if `AGE'>=prim_age0+3 & `AGE'<=prim_age0+6
	*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
	*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
}
drop edu0

*Completion of higher
foreach X in 2 4 {
	gen comp_higher_`X'yrs=0
	replace comp_higher_`X'yrs=1	if eduyears>=years_upsec+`X' //  2 or 4 years after
	replace comp_higher_`X'yrs=. 	if (eduyears==.|eduyears==97|eduyears==98|eduyears==99)
	replace comp_higher_`X'yrs=0 	if ed3=="no"  // those that never went to school have not completed!
	replace comp_higher_`X'yrs=0 	if code_ed4a==0 // those that went to kindergarten max have no completed primary.
}

*Ages for completion higher
for X in any 2 4: gen comp_higher_Xyrs_2529=comp_higher_Xyrs if schage>=25 & schage<=29
for X in any 4  : gen comp_higher_Xyrs_3034=comp_higher_Xyrs if schage>=30 & schage<=34
drop comp_higher_2yrs comp_higher_4yrs

for X in any prim_dur lowsec_dur upsec_dur prim_age0 : ren X X_comp

*-------------------------------------------------------------------------------------------------------------
*Durations for OUT-OF-SCHOOL & ATTENDANCE 
	ren year year_original
	gen year=year_original
	replace year=year_original-1 if year_original==2018
	replace year=year_original-2 if year_original==2019
	merge m:1 iso_code3 year using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\data_created\auxiliary_data\UIS\duration_age\UIS_duration_age_25072018.dta"

	drop year
	ren year_original year
	drop if _m==2
	drop _merge
	drop lowsec_age_uis upsec_age_uis
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X_eduout
	ren prim_age_uis prim_age0_eduout

	gen lowsec_age0_eduout=prim_age0_eduout+prim_dur_eduout
	gen upsec_age0_eduout=lowsec_age0_eduout+lowsec_dur_eduout
	for X in any prim lowsec upsec: gen X_age1_eduout=X_age0_eduout+X_dur_eduout-1
	
*Age limits for out of school

foreach X in prim lowsec upsec {
	gen eduout_`X'=eduout if schage>=`X'_age0_eduout & schage<=`X'_age1_eduout
}

*Age limit for Attendance:

*-- PRESCHOOL 3
gen attend_preschool=1 if attend==1 & (code_ed6a==0)
replace attend_preschool=0 if attend==1 & (code_ed6a!=0)
replace attend_preschool=0 if attend==0
gen preschool_3=attend_preschool if schage>=3 & schage<=4
gen preschool_1ybefore=attend_preschool if schage==prim_age0_eduout-1


*-- HIGHER ED
gen high_ed=1 if inlist(code_ed6a, 3, 32, 33, 40)
gen attend_higher=1 if attend==1 & (high_ed==1)
replace attend_higher=0 if attend==1 & (high_ed!=1)
replace attend_higher=0 if attend==0
gen attend_higher_1822=attend_higher if schage>=18 & schage<=22

*Create variables for count of observations
foreach var of varlist $varlist_m {
		gen `var'_no=`var'
}

		
}

cap ren urban location
*Converting the categories to string: 
cap label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"
cap label values wealth wealth

foreach var in $categories_subset {
	cap decode `var', gen(t_`var')
	cap drop `var'
	cap ren t_`var' `var'
	cap replace `var'=proper(`var')
}

*Need disability info for Madagascar (now with the fs module, then add the ch module! for preschool)
merge 1:1 country id using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\Madagascar.dta", keepusing(fsdisability) nogen
des disability fsdisa
codebook fsdisability
replace disability="Has functional difficulty" if fsdisability==1 & country=="Madagascar"
replace disability="Has no functional difficulty" if fsdisability==2 & country=="Madagascar"
drop fsdisability

merge 1:1 country id using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\wm\Madagascar.dta", keepusing(women_disability) nogen
codebook women_dis
replace disability="Has functional difficulty" if women_disability==1 & country=="Madagascar"
replace disability="Has no functional difficulty" if women_disability==2 & country=="Madagascar"
drop women_disability

merge 1:1 country id using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\mn\Madagascar.dta", keepusing(men_disability) nogen
codebook men_dis
replace disability="Has functional difficulty" if men_disability==1 & country=="Madagascar"
replace disability="Has no functional difficulty" if men_disability==2 & country=="Madagascar"
drop men_disability
compress
save "$data_mics\Step_4_temp.dta", replace

*-- For Bilal: Before collapse
use "$data_mics\Step_4_temp.dta", clear
keep hhweight schage age hh5y year ///
iso_code3 country* cluster hh_id individual_id ///
comp* edu* *attend* location sex wealth ethnicity religion region
drop *no* *aux*
drop region ethnicity religion
drop country_name_mics
ren hh5y year_interview
ren schage age_adjusted
label var year "Median year of interview"
order iso country* year* *weight *id cluster *age location sex wealth
compress
*save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\microdata_bilal\microdata_MICS6.dta", replace
save "C:\Users\Rosa_V\Dropbox\microdata_Bilal\microdata_MICS6.dta", replace

use "C:\Users\Rosa_V\Dropbox\microdata_Bilal\microdata_MICS6.dta", clear


use "$data_mics\Step_4_temp.dta", clear
*Dropping variables
drop hl* hh5* cluster hh6*
drop ed3* ed4* ed5* ed6* ed7* ed8* code*
drop lowsec_age0* upsec_age0* prim_age1* lowsec_age1* upsec_age1*
drop years_prim years_lowsec years_upsec years_higher

compress
codebook disability, tab(200)
replace disability=lower(disability)
bys country: tab disability, m
replace disability="has functional difficulty" if disability=="1"|disability=="has functional difficulties"
replace disability="has no functional difficulty" if disability=="2"|disability=="has no functional difficulties"
replace disability="" if disability=="."|disability=="missing"

gen disab=1 if disability=="has functional difficulty"
replace disab=0 if disability=="has no functional difficulty"

bys sex: tab age disability, m

*Create variables for count of observations
foreach var of varlist $varlist_m {
		gen `var'_COUNT0=`var' if `var'==0 
		gen `var'_COUNT1=`var' if `var'==1 
}

gen dis_nr=1 if disability=="has functional difficulty"
replace dis_nr=0 if disability=="has no functional difficulty"

compress
save "$data_mics\Step_5.dta", replace

**********************************************

use "$data_mics\Step_5.dta", clear
collapse dis_nr [iweight=hhweight], by(country year age)
ren dis_nr disability_age_chronological
gen nr=age
ren age age_chronological
save "$data_mics\collapse_age_chronological.dta", replace


use "$data_mics\Step_5.dta", clear
collapse dis_nr [iweight=hhweight], by(country year schage)
gen nr=schage
ren dis_nr disability_schage
save "$data_mics\collapse_schage.dta", replace

use "$data_mics\collapse_age_chronological.dta", clear
merge 1:1 country year nr using "$data_mics\collapse_schage.dta"
keep if _m==3
drop _m
order country year nr age_chrono disability_age schage disability_schage
keep if age<=49
br
export excel using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\tables\mics6\disability_by_age.xlsx", first(var) replace 


************

use "$data_mics\Step_5.dta", clear

gen dis_eduout=dis_nr
replace dis_eduout=. if eduout_lowsec==.


gen dis_eduout=dis_nr
replace dis_eduout=. if eduout_lowsec==.




keep if country=="Gambia"



bys country: tab schage if eduout_lowsec!=. // 13 to 15


*13-15 overall (8.4%) (according to 'disability by age.xlsx’).

sum dis_nr dis_eduout if (schage>=13 & schage<=15) & country=="Gambia"
sum dis_nr dis_eduout if (schage>=13 & schage<=15) & country=="Gambia" [iweight=hhweight]

sum dis_nr dis_eduout if (age>=13 & age<=15) & country=="Gambia"
sum dis_nr dis_eduout if (age>=13 & age<=15) & country=="Gambia" [iweight=hhweight]


sum





use "$data_mics\Step_5.dta", clear

collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec (count) comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=hhweight], by(country_year iso_code3 year prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "$data_mics\collapse_total.dta", replace

use "$data_mics\Step_5.dta", clear
collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec (count) comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=hhweight], by(country_year iso_code3 year sex prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if sex==""
gen category="Sex"
save "$data_mics\collapse_sex.dta", replace


use "$data_mics\Step_5.dta", clear
collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec (count) comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=hhweight], by(country_year iso_code3 year disability prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if disability==""
gen category="Disability"
save "$data_mics\collapse_disability.dta", replace
 
use "$data_mics\Step_5.dta", clear
collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec (count) comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=hhweight], by(country_year iso_code3 year disability sex prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if disability==""|sex==""
gen category="Sex & Disability"
save "$data_mics\collapse_disability_sex.dta", replace



*************
use "$data_mics\collapse_total.dta", clear
append using "$data_mics\collapse_sex.dta"
append using "$data_mics\collapse_disability.dta"
append using "$data_mics\collapse_disability_sex.dta"

gen survey="MICS6"
gen country=country_year

for X in any comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec: replace X=. if X_no<30
order survey iso country year category sex disability comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* eduout_prim* eduout_lowsec* eduout_upsec*
drop country
merge m:1 iso_code3 using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\data_created\auxiliary_data\country_iso_codes_names.dta", keepusing(country) 
drop if _m==2
drop _merge
replace disability="Has functional difficulty" if disability=="has functional difficulty"
replace disability="Has no functional difficulty" if disability=="has no functional difficulty"
order survey iso country year
sort country category sex disability
sort category sex disability
sort country
sort category
save "$data_mics\indicators_mics6_v5.dta", replace
export delimited using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\tables\mics6\indicators_mics6_v5.csv", replace
*export excel using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\tables\mics6\indicators_mics6_v5_EXCEL.xlsx", first(var) replace 
