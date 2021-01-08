
*For Rosa
global data_raw_mics "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\Data\MICS"
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS"

global programs_mics "$gral_dir\programs\mics\mics2&3"
global aux_programs "$programs_mics\auxiliary"

global aux_data "$gral_dir\data\auxiliary_data"
global data_mics "$gral_dir\data\mics\mics3"


*Vars to keep
global vars_keep_mics "hhid hvidx hv000 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124"
global categories sex urban region wealth
set more off

*****************************************************************************************************
*	Preparing databases to append later (MICS 3)
*----------------------------------------------------------------------------------------------------
global vars_mics4 hh1 hh2 hh5* hh6* hh7* hl1 hl3 hl4 hl5* hl6 ed1 ed3* ed5* ed4* ed6* ed7* ed8* windex5 schage hhweight religion ethnicity region
global list4 hh6 hh7 ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed8b religion ethnicity region schage hl5y hl5m hl5d 

/*
set more off
include "${aux_programs}\survey_list_mics3_hl"
foreach file in $survey_list_mics_hl {
	use "$data_raw_mics/`file'", clear
		tokenize "`file'", parse("\")
		gen country = "`1'" 
		gen year_folder = `3'
		
	cap rename *, lower
	
if (country=="Cuba" & year_folder==2006) | (country=="Somalia" & year_folder==2006) {
		label define missing 99 "missing"
		for X in any ed4 ed5 ed6a ed6b ed7 ed8a ed8b wlthind5 hl3: cap gen X=99  // for Cuba 2006. Those vars didn't exist. 
		for X in any ed4 ed5 ed6a ed6b ed7 ed8a ed8b wlthind5 hl3: cap label values X missing // Generated with missing labels
	}
if (country=="Djibouti" & year_folder==2006)|(country=="Iraq" & year_folder==2006)|(country=="Jamaica" & year_folder==2005){
		label define missing 99 "missing"
		for X in any wlthind5: cap gen X=99  // Djibouti2006, Iraq2006 has only missing wlthind5
		for X in any wlthind5: cap label values X missing // Generated with missing labels
	}
	
	cap rename wlthind5 windex5
	if (country=="CentralAfricanRepublic" & year_folder==2006) | (country=="CotedIvoire" & year_folder==2006)|(country=="Mauritania" & year_folder==2007) ///
	|(country=="Turkmenistan" & year_folder==2006) {
		cap drop ed3 ed6 ed8 // for CentralAfricanRepublic 2006 and CotedIvoire 2006. Dropping extra info to avoid confusion
		cap drop ed6c ed8c hh5a hh5b hh6aw hh6am hh6ac // dropping for Mauritania 2007
		cap gen ed5=. // for Mauritania 2007, Turkmenistan 2006
	}
	
	if (country=="Thailand" & year_folder==2005) {
		drop ed4a
	}

	rename (ed5 hl6) (ed5_ hl6_) // keeps variable h6 in sample in case we need it. Allows me to replace later on
	rename (ed2 ed3a ed3b ed4 hl5) (ed3 ed4a ed4b ed5 hl6) // re numerating to match names of MICS 4&5. See Excel file track_DHS_MICS_LG_v2, questionnaires_compare tab

	if (country=="Bangladesh" & year_folder==2006){
		cap drop hh7a hh7b // for Bangladesh 2006. Dropping extra info of District-subdistrict. We will use only region 
	}
	if (country=="BosniaandHerzegovina" & year_folder==2006)|(country=="Djibouti" & year_folder==2006) {
		drop hh7
		cap ren hh7_det hh7 // has weird name for regions in Bosnia
	    cap ren hh7a hh7 // Djibouti 2006
	}
	if (country=="Malawi" & year_folder==2006) {
		cap ren (hhreg hc1a hc1b) (hh7 religion ethnicity) 
	}
	if (country=="BosniaandHerzegovina" & year_folder==2006) {
		cap ren (hc1b) (ethnicity) 
	}
	if (country=="VietNam" & year_folder==2006) {
		cap ren (hc1a ethnic hl5a1 hl5a2 hl5a3) (religion ethnicity hl5d hl5m hl5y) 
		for X in any hl5d hl5m hl5y: cap gen X_nr=X
		cap drop hl5d hl5m hl5y
		for X in any hl5d hl5m hl5y: cap ren X_nr X
		
	}
	if (country=="Bangladesh" & year_folder==2006)|(country=="Belize" & year_folder==2006)|(country=="BurkinaFaso" & year_folder==2006) ///
	  |(country=="Cameroon" & year_folder==2006)|(country=="CentralAfricanRepublic" & year_folder==2006)|(country=="CotedIvoire" & year_folder==2006) ///
	  |(country=="Gambia" & year_folder==2005)|(country=="Georgia" & year_folder==2005)|(country=="Ghana" & year_folder==2006) ///
	  |(country=="Guinea-Bissau" & year_folder==2006)|(country=="Mongolia" & year_folder==2005)|(country=="Suriname" & year_folder==2006) ///
	  |(country=="Thailand" & year_folder==2005)|(country=="Togo" & year_folder==2006)|(country=="Vanuatu" & year_folder==2007) {
		cap ren (hc1a hc1c) (religion ethnicity) 
	}
	if (country=="Albania" & year_folder==2005)|(country=="Burundi" & year_folder==2005)|(country=="SierraLeone" & year_folder==2005) ///
	   |(country=="Zimbabwe" & year_folder==2009) {
		cap ren (hc1a) (religion) 
	}
	if (country=="TrinidadandTobago" & year_folder==2006) {
		cap ren (hl13 hl14) (religion ethnicity)
	}
	
	if (country=="Montenegro" & year_folder==2005)|(country=="Serbia" & year_folder==2005) {
		cap ren (hc1a hc1c) (religion ethnicity) //Montenegro 2005 saving just numbers
		for X in any hl5ad hl5am hl5ay: cap gen X_nr=X
		cap drop hl5ad hl5am hl5ay
		for X in any hl5ad hl5am hl5ay: cap ren X_nr X
	}
	if (country=="Turkmenistan" & year_folder==2006) {
		for X in any hl5am hl5ay: cap gen X_nr=X
		cap drop hl5am hl5ay
		for X in any hl5am hl5ay: cap ren X_nr X
	}
	if (country=="Guyana" & year_folder==2006)|(country=="Kazakhstan" & year_folder==2006)|(country=="Kyrgyzstan" & year_folder==2005) ///
		|(country=="LaoPDR" & year_folder==2006)|(country=="TFYRMacedonia" & year_folder==2005) {
		cap drop ethnicity
		cap ren (hl4e hl4r hh1a) (ethnicity religion hh7) // This one has info of etnicity and religion in Guyana
		cap ren (hc1c) (ethnicity) // renaming ethnicity for Kazakhstan 2006,LaoPDR 2006, TFYRMacedonia 2005
		cap ren hc1a religion // renaming religion for Kyrgyzstan 2005,LaoPDR 2006, TFYRMacedonia 2005
	}
	
	for X in any hh7a hh7r region: cap ren X hh7 // for alternatives names of region
	for X in any y m d: cap ren hl5aX hl5X

	
	if (country=="Nigeria" & year_folder==2007)|(country=="Bangladesh" & year_folder==2006)|(country=="BurkinaFaso" & year_folder==2006) ///
		|(country=="Burundi" & year_folder==2005)|(country=="Cameroon" & year_folder==2006)|(country=="CentralAfricanRepublic" & year_folder==2006) ///
		|(country=="Cuba" & year_folder==2006) | (country=="CotedIvoire" & year_folder==2006) |(country=="Guinea-Bissau" & year_folder==2006) ///
		|(country=="Guyana" & year_folder==2006)|(country=="Iraq" & year_folder==2006)|(country=="Malawi" & year_folder==2006) ///
		|(country=="Mongolia" & year_folder==2005)|(country=="Somalia" & year_folder==2006)|(country=="Suriname" & year_folder==2006) ///
		|(country=="SyrianAR" & year_folder==2006)|(country=="Tajikistan" & year_folder==2005)|(country=="Thailand" & year_folder==2005) ///
		|(country=="TrinidadandTobago" & year_folder==2006)|(country=="Turkmenistan" & year_folder==2006)|(country=="Uzbekistan" & year_folder==2006) {
		cap label define HH5Y `3' "`3'", modify 
		cap label define LABN `3' "`3'", modify 
		drop hh5y
		gen hh5y=`3'
	}
		if (country=="Thailand" & year_folder==2005) {
		gen a=hh5m
		drop hh5m 
		ren a hh5m
	}
	if (country=="Belarus" & year_folder==2005)|(country=="BosniaandHerzegovina" & year_folder==2006)|(country=="Georgia" & year_folder==2005) ///
		|(country=="TFYRMacedonia" & year_folder==2005)|(country=="Serbia" & year_folder==2005)|(country=="Ukraine" & year_folder==2005) {
		label define HH5Y `3' "`3'", modify // Georgia and Ukraine only needed to change ln for hl1 but doing this does not change other variables
		drop hh5y
		gen hh5y=`3'
		ren ln hl1 //renaming line number. 
	}
	if country=="Mozambique" & year_folder==2008 {
	cap ren (dia mes ano) (hh5d hh5m hh5y)  // for Mozambique 2008 
	}

	for X in any $list4 windex5 ed1 hl5y hh5y: cap gen X=.

	keep $vars_mics4 country year*

	for X in any ed4a ed4b ed6a ed6b: gen X_nr=X // create the numbers (without labels) for ed4a, ed6b etc
	for X in any $list4 : cap decode X, gen(label_X)
	
	if (country=="Burundi" & year_folder==2005)|(country=="Montenegro" & year_folder==2005)|(country=="Serbia" & year_folder==2005)| ///
	   (country=="Turkmenistan" & year_folder==2006)|(country=="VietNam" & year_folder==2006) {
	for X in any d m y: gen label_hl5X=hl5X // for Burundi, Montenegro, Serbia,Turkmenistan, VietNam that has info of hl5y,hl5m,hl5d. I create duplicate better
	}
	
	drop $list4 
	for X in any $list4 : cap ren label_X X // this one has the labels
	cap label drop _all
	compress
	save "$data_mics\hl\countries\\`1'`3'", replace
}

********************************************************************************
* 	Appending all the databases
********************************************************************************

cd "$data_mics\hl\countries"
local allfiles : dir . files "*.dta"

use "Nigeria2007.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

*Drop unnecessary variables

*drop yearsc hh6r hh7a1 hh7a2
*drop ed7 ed8a ed8b //Variables for previous school year (not available for all country years)

*drop ed3a-ed5a ed6c-ed8c
drop hh5 hh5c hh6a hh6b hh6aa hh7a hh7b hh7c hh7d hh7e hh7f hh7new hh6w hh7w ed3aa ed6c ed6d ed6e ed6f ed6g ed6h hl5a  hl5_1 hl5nova ed3x ed3y ed8x ed8y ///
	hh5c hh6w hh7w ed3x ed3y ed8x ed8y hh6r ed5a ed3tt ed6tt ed8tt
compress
save "$data_mics\hl\hl_append_mics_3.dta", replace


**************************************************************************
*	Translate. Only for STATA 14 or later
**************************************************************************
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics\hl"
unicode analyze "hl_append_mics_3.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "hl_append_mics_3.dta"


*/

*************************************************************************
*	Fixing categories and creating variables
**************************************************************************
set more off
use "$data_mics\hl\hl_append_mics_3.dta", clear

* ID for each country year: Variable country_year
*year of survey (in the data) can be different from the year in the name of the folder. Or there can be 2 years in the data as the survey expanded through 2 years
*Important because eduvars can change through years for the same country
cap ren year_file year_folder
gen country_year=country+ "_" +string(year_folder)

*Individual ids
gen hh1_s=string(hh1, "%25.0f")
gen individual_id = country_year+" "+hh1_s+" "+string(hh2)+" "+string(hl1)    
ren hh1_s cluster
gen hhid=string(hh2)
drop hh1* hh2 hl1 ed1
*codebook individual_id // uniquely identifies people
*isid individual_id // checking uniquely identifies people


*Sex
ren hl4 sex
recode sex (2=0) (9=.) (3/4=.)
label define sex 0 "female" 1 "male"
label values sex sex

*Age
ren hl6 age
	gen ageA=age-1 // before it had the restriction "if adj==1" . I'll show both adjusted and unadjusted and a flag that says if it should be adjusted!
	ren age ageU

*Urban
replace hh6=lower(hh6)
gen urban=.
replace urban=0 if (hh6=="rural"|hh6=="rural with road"|hh6=="rural without road"|hh6=="rural, coastal"|hh6=="rural, interior"|hh6=="non urban")
replace urban=1 if (hh6=="urbain"|hh6=="urban"|hh6=="urban (municipality)"|hh6=="urban non-slum (metro city)"|hh6=="urban slum"|hh6=="urbana"|hh6=="urbano")
replace urban=1 if (hh6=="ouagadougou"|hh6=="autres villes") & country=="BurkinaFaso" // the rest are rural
replace urban=1 if hh6=="kma"  & country=="Jamaica" // it is Kingston Metropolitan area
replace urban=0 if hh6=="tribal" & country=="Bangladesh"
label define urban 0 "rural" 1 "urban" 2 "camps"
label values urban urban

*codebook hh6 urban, tab(100)

*Wealth

*codebook windex5
ren windex5 wealth
*tab country_year if wealth==99
replace wealth=. if wealth==99 // the countries with wealth=99 have missing for everything

*Weight: already named hhweight

*Region (solving name of regions to be done later)
*- Need to check what is the real variable identifying the region
include "$aux_programs\regions_mics3.do"
include "$aux_programs\ethnicity_religion_mics3.do"
for X in any religion ethnicity: replace X="" if X=="Missing/DK"|X=="Missing"
*codebook ethnicity, tab(200)

*order country year_folder survey cluster country_year individual_id round urban age schage hhweight wealth religion ethnicity region sex hl* hh* ed3* ed4* ed6*

*****************************************************
** CHANGES TO EDUCATION VARIABLES
*****************************************************

* ed3= ever attended school
* ed4a= highest level of edu (ever) 
* ed5= currently attending
* ed6a= current level of edu

*---- 1. Changes to Edu labels

global clean "ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed8b"

* Checking weird names
foreach var of varlist $clean {
		cap tab `var'
}

* Eliminates alpha-numeric caracters
foreach var of varlist $clean {
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
 
foreach var of varlist $clean {
	replace `var'=lower(`var')
	replace `var'=stritrim(`var')
	replace `var'=strltrim(`var')
	replace `var'=strrtrim(`var')
}

foreach var of varlist $clean {
	replace `var' = "no" if (`var'=="nao"|`var'=="non")
	replace `var' = "yes" if (`var'=="si"|`var'=="sim"|`var'=="oui")
	replace `var' = "missing" if (`var'=="em falta"|`var'=="manquant"|`var'=="omitido"|`var'=="no reportado")
	replace `var' = "doesn't answer" if (`var' =="nr"|`var'=="non declare/pas de reponse"|`var'=="no responde")
	replace `var' = "don't know" if (`var'=="dk"|`var'=="no sabe"|`var'=="nao sabe"|`var'=="ns"|`var'=="ne sait pas"|`var'=="nsp")
	replace `var' = "inconsistent" if (`var'=="inconsistente"|`var'=="incoherent")
}


*Homogenizing codes after comparing ed4a vs ed6a so they have same codes. No need to adjust codes. They are ok for codes and duration

*---- 2) Creation of the new var & recoded: Re-codify the levels of ed4a & ed6a according to the NEW value labels

for X in any ed4a ed6a: gen code_X=X_nr

*The standard edulevel label is : 0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 8 "don't know" 9 "missing/doesn't answer" 
* The NEW value label for edulevel

label define edulevel_new ///
	0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 97 "inconsistent" 98 "don't know" 99 "missing/doesn't answer" ///
	21 "lower secondary" 23 "voc/tech/prof as lowsec" ///
	22 "upper secondary" 24 "voc/tech/prof as upsec" ///
	32 "post-secondary or superior no university" 33 "voc/tech/prof as higher" ///
	40 "post-graduate (master, PhD, etc)" ///
	50 "special/literacy program" 51 "adult education" ///
	60 "general school (ex. Mongolia, Turkmenistan)" ///
	70 "primary+lowsec (ex. Sudan & South Sudan)" ///
	80 "not formal/not regular/not standard" 90 "khalwa/coranique/religious (ex. Mauritania, Sudan)" 

* I do this recode for all country_years once and for all. I don't need to do it later again
	for X in any ed4a ed6a: replace code_X=97 if (X=="inconsistent")
	for X in any ed4a ed6a: replace code_X=98 if X=="don't know"
	for X in any ed4a ed6a: replace code_X=99 if (X=="missing"|X=="doesn't answer"|ed4a=="missing/dk")


* Case 1) Countries that have same as the standard edulevel code (0=preschool, 1=primary, 2=secondary, 3=higher). 
* 		  I only need to recode (8=98) (9=99)

* Case 2) Countries that need recoding of the edulevel to be in line with the NEW value labels
foreach var of varlist code_ed4a code_ed6a {
	recode `var' (6=80) (8=98) (9=99) if country_year=="Nigeria_2007"
	recode `var' (2=21) (3=22) (4=3)  if country_year=="Albania_2005" // higher in questionnaire corresponds to upper sec, secondary to lower sec
	recode `var' (8=98) (9=99) (6=50) if country_year=="Bangladesh_2006" // 06_ngo/mosque based/adult literacy program classified as 50
	recode `var' (4=21) (5=24) (6=80) if country_year=="Belarus_2005"
	recode `var' (2=21) (3=22) (4=3) (5=40) (6=24) (8=98) (9=99) if country_year=="Belize_2006"
	*recode `var' (4=3) (6=80) (8=98) (9=99) if country_year=="BosniaandHerzegovina_2006"
	recode `var' (1=70) (2=22) (3/4=3) (6=80) (8=98) (9=99) if country_year=="BosniaandHerzegovina_2006"
	recode `var' (2=21) (3=22) (4=3) (8=98) (9=99) if country_year=="BurkinaFaso_2006"
	recode `var' (6=80) (8=98) (9=99) if country_year=="Burundi_2005"
	recode `var' (3=2) (4=3) (5=90) (6=80) (8=98) (9=99) if country_year=="Cameroon_2006"
	recode `var' (6=80) (8=98) (9=99) if country_year=="CentralAfricanRepublic_2006"
	recode `var' (2=21) (3/4=24) (5=3) (8=98) (9=99) if (country_year=="Cuba_2006")
	recode `var' (6=80) (8=98) (9=99) if country_year=="CotedIvoire_2006"
	recode `var' (6=80) (8=98) (9=99) if country_year=="Djibouti_2006"
	recode `var' (4=2) (6=80) (10=0) (11/12=90) if country_year=="Gambia_2005" // Vocational is secondary?
	recode `var' (6=80) (8=98) (9=99) if country_year=="Georgia_2005"
	recode `var' (10=1) (20=21) (30=22) (40=24) (50=32) (60=3) (29/69=98) (90=98) if country_year=="Ghana_2006"
	*recode `var' (2=21) (3=22) (4=3) (6=80) (8=98) (9=99) if country_year=="Guinea-Bissau_2006"
	recode `var' (3/4=3) (6=80) (8=98) (7=99) if country_year=="Guinea-Bissau_2006"
	recode `var' (3=32) (4=3) (6=80) (8=98) (9=99) if country_year=="Guyana_2006"
	recode `var' (2=21) (3=22) (4=33) (5/6=3) (7=80) (8=98) (9=99) if country_year=="Iraq_2006"
	recode `var' (4/6=98) (5=80) (8=98) (9=99) if country_year=="Jamaica_2005"
	recode `var' (3=24) (4=3) (8=98) (9=99) if country_year=="Kazakhstan_2006"
	recode `var' (6=90) (8=98) (9=99) if country_year=="Kyrgyzstan_2005"
	recode `var' (6=80) (8=98) (9=99) if country_year=="LaoPDR_2006"
	*recode `var' (6=80) (8=98) (9=99) if country_year=="TFYRMacedonia_2005"
	recode `var' (1=70) (2=22) (6=80) (8=98) (9=99) if country_year=="TFYRMacedonia_2005"
	recode `var' (6=80) (8=98) (9=99) if country_year=="Malawi_2006"
	recode `var' (4/5=90) (6=80) (8=98) (9=99) if country_year=="Mauritania_2007"
	recode `var' (1=60) (2=24) (3/4=3) (5=90) (6=80) (8=98) (9=99) if country_year=="Mongolia_2005"
	*recode `var' (3/4=3) (5=0) (8=98) (9=99) if country_year=="Montenegro_2005" //5 for those in 1 year of primary, so didn't complete primary
	recode `var' (1=70) (2=22) (3/4=3) (5=0) (8=98) (9=99) if country_year=="Montenegro_2005"
	recode `var' (1/2=1) (3=21) (4=22) (5/6=23) (7/8=24) (9=3) if country_year=="Mozambique_2008"
	recode `var' (4=3) (5=0) (6=80) (8=98) (9=99) if country_year=="Serbia_2005"
	recode `var' (6=80) (8=98) (9=99) if country_year=="SierraLeone_2005"
	recode `var' (4=90) (6=80) (8=98) (9=99) if country_year=="Somalia_2006"
	recode `var' (2=50) (3=21) (4=22) (5=50) (6=3) (7=80) (8=98) (9=99) if country_year=="Suriname_2006"
	recode `var' (2=21) (3=22) (4=32) (5=3) (8=98) (9=99) if country_year=="SyrianAR_2006" // 4 is academy, I assume 32
	recode `var' (3=32) (4=3) (6=80) (8=98) (9=99) if country_year=="Tajikistan_2005" // 03=32 special secondary as vocational
	recode `var' (6=80) (8=98) (9=99) if country_year=="Thailand_2005"
	recode `var' (2=21) (3=22) (4=3) (5=80) (8=98) (9=99) if country_year=="Togo_2006"
	recode `var' (4=40) (5=33) (8=98) (9=99) if country_year=="TrinidadandTobago_2006"
	recode `var' (3=32) (4=3)  (8=98) (9=99) if country_year=="Turkmenistan_2006" // 03=32 special secondary as vocational
	recode `var' (6=80) (8=98) (9=99) if country_year=="Ukraine_2005"
	recode `var' (3=32) (4=3) (6=80) (8=98) (9=99) if country_year=="Uzbekistan_2006" // 03=32 special secondary as vocational	
	recode `var' (6=80) (8=98) (9=99) if country_year=="Vanuatu_2007" // 6: vocational school-rural training
	recode `var' (2=21) (3=22) (4=80) (5=24) (6=32) (7=3) (8=98) (9=99) if country_year=="VietNam_2006" // checked with ISCED Excel
	recode `var' (1/2=1) (3/4=2) (5/6=3) (7=80) (8=98) (9=99) if country_year=="Yemen_2006"
	recode `var' (10=1) (20=2) (30=3) if country_year=="Zimbabwe_2009"	
}

************CHECK THIS FOR RE CODING code_ed4a code_ed6a later on
*I added this save to save time

for X in any code_ed4a code_ed6a: label values X edulevel_new 


compress
save "$data_mics\hl\Step_0_modified.dta", replace


**********************************************************************************************************************************
**********************************************************************************************************************************

/*
*---------------------------------------
** 		AGE ADJUSTMENT
*---------------------------------------

set more off
use "$data_mics\hl\Step_0_modified.dta", clear
keep country_year hh5d hh5m hh5y iso_code3
	merge m:1 country_year using "$aux_data\temp\current_school_year_MICS.dta" // current school year that ED question in MICS refers to
	drop if _merge==2 
	drop _merge MICSround

replace current_school_year="" if (current_school_year=="doesn't have the variable"|current_school_year=="questionnaire not available" ///
	|current_school_year=="not in the questionnaire"|current_school_year=="report not available")

destring current_school_year, replace

gen year_c=hh5y
cap	drop month* 
merge m:m iso_code3 year_c using "$aux_data\UIS\months_school_year\month_start.dta"
drop if _merge==2
drop _merge max_month min_month diff

*All countries have month_start. Malawi_2015 has now the month 9 (OK)
	cap ren school_year current_school_year

*For those with missing in school year, I replace by the interview year
gen missing_current_school_year=1 if current_school_year==.
replace current_school_year=hh5y if current_school_year==.

*-------------------------------------------------------------------------------------
* Adjustment VERSION 1: Difference in number of days 
*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
*- 			Interview		: Month as presented in the survey data
*-------------------------------------------------------------------------------------
	
	gen month_start_norm=month_start
	
*Taking into account the days	
	for X in any norm max min: gen s_school1_X=string(1)+"/"+string(month_start_X)+"/"+string(current_school_year)
	gen s_interview1=string(hh5d)+"/"+string(hh5m)+"/"+string(hh5y) // date of the interview created with the original info

	for X in any norm max min: gen date_school1_X=date(s_school1_X, "DMY",2000) 
	gen date_interview1=date(s_interview1, "DMY",2000)
	
*Without taking into account the days
	for X in any norm max min: gen s_school2_X=string(month_start_X)+"/"+string(current_school_year)
	gen s_interview2=string(hh5m)+"/"+string(hh5y) // date of the interview created with the original info
	
	for X in any norm max min: gen date_school2_X=date(s_school2_X, "MY",2000) // official month of start... plus school year of reference
	gen date_interview2=date(s_interview2, "MY",2000)

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*50% of hh have 6 months of difference or more
*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

foreach M in norm max min {
foreach X in 1 2 {
	gen diff`X'_`M'=(date_interview`X'-date_school`X'_`M')
	gen temp`X'_`M'=mod(diff`X'_`M',365) 
	replace diff`X'_`M'=temp`X'_`M' if missing_current_school_year==1
	bys country_year: egen median_diff`X'_`M'=median(diff`X'_`M')
	gen adj`X'_`M'=0
	replace adj`X'_`M'=1 if median_diff`X'_`M'>=182
}
}

sort country_year
collapse diff* adj* flag_month, by(country_year)		
	
save "$data_mics\hl\mics3_adjustment.dta", replace

*/

**********************************************************************************************************************************
/*
for X in any ed4a ed6a: gen temp_X_nr=string(X_nr, "%02.0f") // Converts it to a string containing leading zeros kept to have a proper order
for X in any ed4a ed6a: gen X_full=temp_X_nr + "_" + X
drop temp_ed4a_nr temp_ed6a_nr

foreach x in 4 6 {
	log using "$data_mics\hl\logs\ed`x'a_full.log", replace
	bys country_year: tab ed`x'a_full, missing
	log close

	cap log close
	log using "$data_mics\hl\logs\ed`x'b_vs_ed`x'a_full.log", replace
	bys country_year: tab ed`x'b ed`x'a_full, missing
	log close
	
	cap log close
	log using "$data_mics\hl\logs\ed`x'b_vs_ed`x'a_full_number.log", replace
	bys country_year: tab ed`x'b_nr ed`x'a_full, missing
	log close
}
*/

**********************************************************************************************************************************
**********************************************************************************************************************************

use "$data_mics\hl\Step_0_modified.dta", clear
set more off
*keep if country_year=="Bangladesh_2006"|country_year=="Belize_2006"|country_year=="Djibouti_2006"|country_year=="LaoPDR_2006"|country_year=="Mongolia_2005"

bys country_year: egen year=median(hh5y)

*merge with information of duration of levels, school calendar, official age for primary, etc:
	rename country country_name_mics
	merge m:m country_name_mics using "$aux_data\country_iso_codes_names.dta" // to obtain the iso_code3
	drop if _merge==2
	drop country country_name_WIDE iso_code2 iso_numeric-_merge
	ren country_name_mics country
	merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	*merge m:m country_code_dhs using "$aux_data\country_age_school.dta"
	drop if _m==2
	drop lowsec_age_uis upsec_age_uis _merge
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
	ren prim_age_uis prim_age0
	gen higher_dur=4 // provisional

*********************************************************
* CHANGES TO DURATION OR START AGE (to match UIS)
**********************************************************
	replace prim_dur=4 		if country_year=="Mongolia_2005"
	replace prim_age0=8 	if country_year=="Mongolia_2005"
	
	replace upsec_dur=2 	if country_year=="Uzbekistan_2006"  

*Now, we will create the dropped ages, taking into account the new durations
*Ages for completion
gen lowsec_age0=prim_age0+prim_dur
gen upsec_age0=lowsec_age0+lowsec_dur
for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1

*With info of duration of primary and secondary I can also compare official duration with the years of education completed..
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur
	
compress
save "$data_mics\hl\Step_1_modified.dta", replace


/*

*Checking missing, no answer, etc categories sum up the same
count if ed4a=="missing" | ed4a=="doesn't answer" | ed4a=="don't know"
tab code_ed4a if (ed4a=="missing" | ed4a=="doesn't answer" | ed4a=="don't know")
tab ed4a if code_ed4a==98 | code_ed4a==99

*Generating vars to have code and label. IT facilitates the coding later on for generating eduyears. Always open the log file

gen ed4a_digit=code_ed4a
decode code_ed4a, gen(ed4a_label)

gen temp_ed4a_digit=string(ed4a_digit, "%02.0f") // Converts it to a string containing leading zeros kept to have a proper order
gen temp_ed4b_digit=string(ed4b_nr, "%02.0f") // Converts it to a string containing leading zeros kept to have a proper order

for X in any ed4a: gen X_full2=temp_X_digit + "_" + ed4a_label
for X in any ed4b: gen X_full2=temp_X_digit + "_" + X
drop temp* *_digit

cap log close
log using "$data_mics\hl\logs\1_RECODED ed4a vs ed4b.log", replace
bys country_year: tab ed4b_full2 ed4a_full2, m
log close

*/


****************************
***** DEFINING EDUYEARS
*****************************

	set more off
	use "$data_mics\hl\Step_1_modified.dta", clear

	* 	EDUYEARS: Going to do it for ED4 only --> this is for later: for X in any ED4 ED6: cap gen eduyears_X=.
	*	Checking ed4b vs the duration of levels

		gen eduyears=. // based in ed4b original

	*Rename the ed4b variables to make it easier to use
		ren ed4b ed4b_label
		ren ed4b_nr ed4b
		


* STRATEGY: Classify countries by how they present the "tab ed4b ed4a" : STAIRS, FLAT, OTHER


*-----------------------------
*1) For those with STAIRS 
*-----------------------------

*-------------------------------------------------------------------------------------------------------
*--1a) The Stairs are already created and I don't need to do other changes: 
foreach country_year in Bangladesh_2006 Burundi_2005 Cameroon_2006 CentralAfricanRepublic_2006 {
	replace eduyears=ed4b if country_year=="`country_year'"	
	replace eduyears=0 if code_ed4a==0 & country_year=="`country_year'"
	replace eduyears=0 if code_ed4a==80 & country_year=="`country_year'" //added by Rosa
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}

*Vanuatu 2007
replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==3) & country_year=="Vanuatu_2007" 
replace eduyears=0 if code_ed4a==0 & country_year=="Vanuatu_2007"
replace eduyears=0 if code_ed4a==80 & country_year=="Vanuatu_2007"
for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Vanuatu_2007"	

*-------------------------------------------------------------------------------------------------------
*--1b) STAIRS AND HAS INFO OF YEAR IN HIGHER ED
* 

*Stairs but higher is flat
foreach country_year in Gambia_2005 Turkmenistan_2006 Tajikistan_2005 Uzbekistan_2006 Ukraine_2005 {
	replace eduyears=0 if code_ed4a==0 & country_year=="`country_year'" 
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==21|code_ed4a==22|code_ed4a==23|code_ed4a==24) & country_year=="`country_year'" 
	replace eduyears=years_upsec+ed4b if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}

foreach country_year in Jamaica_2005 Kyrgyzstan_2005 {
	replace eduyears=ed4b if country_year=="`country_year'" & (code_ed4a==1|code_ed4a==2|code_ed4a==24)
	replace eduyears=years_upsec+ed4b if country_year=="`country_year'" & (code_ed4a==3)
	replace eduyears=0 if code_ed4a==0 & country_year=="`country_year'"
	replace eduyears=years_prim if code_ed4a==2 & eduyears==0 & country_year=="`country_year'"
	replace eduyears=years_lowsec if code_ed4a==24 & eduyears==0 & country_year=="`country_year'"
	replace eduyears=years_upsec if code_ed4a==3 & eduyears==0 & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}


* Georgia
	replace eduyears=ed4b if country_year=="Georgia_2005" & (code_ed4a==1|code_ed4a==2)
	replace eduyears=years_upsec+ed4b if country_year=="Georgia_2005" & (code_ed4a==3)
	replace eduyears=0 if code_ed4a==0 & country_year=="Georgia_2005"
	replace eduyears=years_prim if code_ed4a==2 & eduyears==0 & country_year=="Georgia_2005"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Georgia_2005"

* Mozambique 2008
	replace eduyears=ed4b if country_year=="Mozambique_2008" & (code_ed4a==1|code_ed4a==21|code_ed4==22)
	replace eduyears=ed4b+years_prim if country_year=="Mozambique_2008" & (code_ed4a==23)
	replace eduyears=ed4b+years_lowsec if country_year=="Mozambique_2008" & (code_ed4==24)
	replace eduyears=years_upsec+ed4b if country_year=="Mozambique_2008" & (code_ed4a==3)
	replace eduyears=0 if code_ed4a==0 & country_year=="Mozambique_2008"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Mozambique_2008"


*Thailand_2005 is a mess for eduyears. We decided to substract 4 years of eduyears
foreach country_year in Thailand_2005 {
	replace eduyears=0 if country_year=="`country_year'" & (code_ed4a==0)
	replace eduyears=ed4b-4 if country_year=="`country_year'" & (code_ed4a==1|code_ed4a==2|code_ed4a==3)
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
	}

* Nigeria 2007: Need to check the value labels of ed4b. see log file 1_RECODED ed4a vs ed4b
	replace eduyears=0 if ed4b>=1 & ed4b<=3 & (country_year=="Nigeria_2007") 
	replace eduyears=ed4b-3 if (code_ed4a==1|code_ed4a==2|code_ed4a==3) & (country_year=="Nigeria_2007")
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Nigeria_2007"
	
	* LaoPDR_2006 does not have higher info??
	replace eduyears=ed4b-10 if ed4b>=11 & ed4b<=15 & country_year=="LaoPDR_2006"
	replace eduyears=ed4b-15 if ed4b>=21 & ed4b<=26 & country_year=="LaoPDR_2006"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="LaoPDR_2006"

*VietNam 2006
replace eduyears=ed4b if (code_ed4a==1|code_ed4a==21|code_ed4a==22) & country_year=="VietNam_2006" 
replace eduyears=ed4b if code_ed4a==24 & country_year=="VietNam_2006" // ask about this assumption!!
replace eduyears=years_lowsec+0.5*upsec_dur if code_ed4a==32 & country_year=="VietNam_2006" // ask about this assumption!!
replace eduyears=years_upsec+0.5*higher_dur if code_ed4a==3 & country_year=="VietNam_2006" // ask about this assumption!!
for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="VietNam_2006"

*--1f) STAIRS + FLAT FOR UPSEC onwards (has info on years higher)
foreach country_year in Albania_2005 {
	replace eduyears=0 if ed4b==0 & country_year=="`country_year'"
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==21) & country_year=="`country_year'"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}
 
*-----------------------------------------------------------------------------------------------------------
*2) For those FLAT
*-----------------------------------------------------------------------------------------------------------

*		2a) FLAT 

foreach country_year in BosniaandHerzegovina_2006 BurkinaFaso_2006 Cuba_2006 CotedIvoire_2006 Guinea-Bissau_2006 Djibouti_2006 Guyana_2006 ///
Iraq_2006 Kazakhstan_2006 Mauritania_2007 Mongolia_2005 Montenegro_2005 SierraLeone_2005 Suriname_2006 SyrianAR_2006 TFYRMacedonia_2005 Togo_2006 Zimbabwe_2009 {
	replace eduyears=0 if code_ed4a==0 & country_year=="`country_year'"
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==60|code_ed4a==70) & country_year=="`country_year'"
	replace eduyears=ed4b+years_prim if (code_ed4a==2|code_ed4a==21|code_ed4a==23) & country_year=="`country_year'" 
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"  
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'" 

	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}

*		2a.1) Special cases

	*Belize 2006
foreach country_year in Belize_2006 {
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="`country_year'"
	replace eduyears=ed4b+years_prim if (code_ed4a==21) & country_year=="`country_year'" 
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"  
	replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="`country_year'" 
	replace eduyears=ed4b+years_upsec+4 if (code_ed4a==40) & country_year=="`country_year'" // check this assumption
	replace eduyears=0 if code_ed4a==0 & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}


	*Ghana_2010: taken out because it has a lot of obs that are higher than prim_dur
	replace eduyears=0 if (code_ed4a==0) & country_year=="Ghana_2006"
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="Ghana_2006"
	replace eduyears=ed4b+years_prim if (code_ed4a==21) & country_year=="Ghana_2006"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="Ghana_2006" 
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32) & country_year=="Ghana_2006" 

	for YY in any 97 98 99: replace eduyears=YY if ed4b==YY & country_year=="Ghana_2006" // those values have labels
	

	
	*Malawi_2006-Serbia 2005-Somalia 2006-Yemen 2006. BUT PRIMARY HAS 8 Years
foreach country_year in Malawi_2006 Serbia_2005 Somalia_2006 Yemen_2006 {
	replace eduyears=0 if (code_ed4a==0) & country_year=="`country_year'"
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="`country_year'" //primary and lower secondary are together
	replace eduyears=ed4b+years_lowsec if (code_ed4a==2) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
	*replace eduyears=years_higher if (eduyears>years_higher) & (code_ed4a==3) & country_year=="`country_year'" // Bilal said no adjustment
}
	*Had to recode to split primary from low_sec
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="TFYRMacedonia_2005")
	recode code_ed4a (2=22) if (country_year=="TFYRMacedonia_2005")
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="Malawi_2006")
	recode code_ed4a (2=22) if (country_year=="Malawi_2006")
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="Serbia_2005")
	recode code_ed4a (2=22) if (country_year=="Serbia_2005")
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="Somalia_2006")
	recode code_ed4a (2=22) if (country_year=="Somalia_2006")
	replace eduyears=98 if ed4b==66 & country_year=="Somalia_2006" & code_ed4a<24 // Don't have grades and only for prim,sec,higher
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="Yemen_2006")
	recode code_ed4a (2=22) if (country_year=="Yemen_2006")
	

	*TrinidadandTobago 2006
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="TrinidadandTobago_2006"
	replace eduyears=ed4b+years_prim if (code_ed4a==2) & country_year=="TrinidadandTobago_2006" 
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==33) & country_year=="TrinidadandTobago_2006" 
	replace eduyears=years_higher+ed4b if (code_ed4a==40) & country_year=="TrinidadandTobago_2006"  // those higher than higher
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="TrinidadandTobago_2006"
	
*Case: Belarus 2005
replace eduyears=ed4b if (code_ed4a==0|code_ed4a==1|code_ed4a==2|code_ed4a==21) & country_year=="Belarus_2005"
replace eduyears=ed4b+years_lowsec if (code_ed4a==24) & country_year=="Belarus_2005"
replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="Belarus_2005"
for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Belarus_2005"

*** I NEED TO TO THIS FOR ALL
replace eduyears=97 if (ed4b_label=="inconsistent")
replace eduyears=98 if ed4b_label=="don't know"
replace eduyears=99 if (ed4b_label=="missing"|ed4b_label=="doesn't answer")

cap drop t temp
compress
save "$data_mics\hl\Step_2_modified.dta", replace

/*
for X in any ed4a ed6a: gen check_X=string(code_X)+" "+X
cap log close
set more off
log using "$data_mics\logs\2_TAB eduyears code_ed4a.log", replace
bys country year: tab eduyears check_ed4a, m 
log close
*/



***************************************************************************************************************************************************************
set more off
use "$data_mics\hl\Step_2_modified.dta", clear

*-----------------------------------------
* 		Creating the Completion indicators
*-----------------------------------------

** VERSION B: Mix of years of education completed and level duration

	ren eduyears eduyears_B // how it was already created

*-- Without Age limits
* I consider that those with or with more years than those necessary for completing that level have completed that level.

foreach X in prim lowsec upsec higher {
	gen comp_`X'_B=0
	replace comp_`X'_B=1 	if eduyears_B>=years_`X' & eduyears_B!=.
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

*gral age limits with and without age adjustment
foreach Z in B {
foreach Y in ageU ageA {	
	for X in any prim lowsec: 	gen comp_X_1524_`Z'_`Y'=comp_X_`Z' if `Y'>=15 & `Y'<=24
	gen comp_upsec_2029_`Z'_`Y'		=comp_upsec_`Z' if `Y'>=20 & `Y'<=29
	gen comp_higher_2529_`Z'_`Y'	=comp_higher_`Z' if `Y'>=25 & `Y'<=29
	gen comp_higher_3034_`Z'_`Y'	=comp_higher_`Z' if `Y'>=30 & `Y'<=34	
}
}

* Checking values of primary completion 
tab comp_prim_v2_B_ageU [iw=hhweight] if country_year=="Bangladesh_2006"
tab comp_lowsec_v2_B_ageU [iw=hhweight] if country_year=="Bangladesh_2006"
tab comp_upsec_v2_B_ageU [iw=hhweight] if country_year=="Bangladesh_2006"
*----------------------------------------
* Creating VERSION C (B with FIX): 
*----------------------------------------	
	
*Fix: 
	*Recoding those with zero to a lower level of education 
	*Those with zero eduyears that have a level of edu higher than pre-primary, are re-categorized as having completed the last grade of the previous level!

gen eduyears_C=eduyears_B
	replace eduyears_C= years_prim 		if eduyears_B==0 & (code_ed4a==2|code_ed4a==21|code_ed4a==23)
	replace eduyears_C= years_lowsec 	if eduyears_B==0 & (code_ed4a==22|code_ed4a==24)
	replace eduyears_C= years_upsec 	if eduyears_B==0 & (code_ed4a==3|code_ed4a==32|code_ed4a==33)
	replace eduyears_C= years_higher 	if eduyears_B==0 & code_ed4a==40
	
*-- Without Age limits 
* I consider that those with or with more years than those necessary for completing that level have completed that level.
foreach X in prim lowsec upsec higher {
	gen comp_`X'_C=0
	replace comp_`X'_C=1 	if eduyears_C>=years_`X' & eduyears_C!=.
	replace comp_`X'_C=. 	if (eduyears_C==.|eduyears_C==97|eduyears_C==98|eduyears_C==99) // Incoherent, No reply, Missing
	replace comp_`X'_C=0 	if ed3=="no"  // those that never went to school have not completed!
	replace comp_`X'_C=0 	if code_ed4a==0 // those that went to kindergarten max have no completed primary.
}
	
*Age limits for Version C
foreach X in prim lowsec upsec {
	foreach AGE in ageU ageA {
		gen comp_`X'_v2_C_`AGE'=comp_`X'_C if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5
	}
}

*gral age limits with and without age adjustment
foreach Z in C {
foreach Y in ageU ageA {	
	for X in any prim lowsec: 	gen comp_X_1524_`Z'_`Y'=comp_X_`Z' if `Y'>=15 & `Y'<=24
	gen comp_upsec_2029_`Z'_`Y'		=comp_upsec_`Z' if `Y'>=20 & `Y'<=29
	gen comp_higher_2529_`Z'_`Y'	=comp_higher_`Z' if `Y'>=25 & `Y'<=29
	gen comp_higher_3034_`Z'_`Y'	=comp_higher_`Z' if `Y'>=30 & `Y'<=34	
}
}

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************

* YEARS OF EDUCATION
foreach var in B C  {
	gen eduyears_2024_`var'=eduyears_`var' 	if ageU>=20 & ageU<=24
	replace eduyears_2024_`var'=26 			if (eduyears_`var'>=26) // years of education truncated at 26 max??
	replace eduyears_2024_`var'=. 			if eduyears_`var'>=90
}

foreach var in B C  {
foreach X in 2 4 {
	gen edu`X'_2024_`var'=0
	replace edu`X'_2024_`var'=1		if eduyears_`var'<=`X'
	replace edu`X'_2024_`var'=. 	if [eduyears_`var'==.|(ageU>=20 & ageU<=24)]
}
}

** ATTENDANCE
*codebook ed5, tab(100)
*codebook ed6a, tab(400)

	gen attend=.
	replace attend=1 if ed5=="yes"
	replace attend=0 if ed5=="no"

	gen attend_higher=0 if attend!=.
	replace attend_higher=1 if attend==1 & (code_ed6a==3|code_ed6a==31|code_ed6a==32)

	for X in any 18 20: gen attend_higher_X22=attend_higher if ageU>=X & ageU<=22

*Labels for the variables
include "$aux_programs\labels_names.do" // labels to variables

*Countries that are affected by changes in duration
	gen dur_changes=0
	foreach x in Belize_2006 BurkinaFaso_2006 CotedIvoire_2006 Gambia_2005 LaoPDR_2006 Mauritania_2007 Mongolia_2005 SyrianAR_2006 Vanuatu_2007 ///
				 SierraLeone_2005 Burundi_2000 BoliviaPS_2000 DominicanRepublic_2000 Kenya_2000 Zambia_2000 Bangladesh_2006 Djibouti_2006 {
	cap replace dur_changes=1 if country_year=="`x'" 
}


compress
save "$data_mics\hl\Step_4_modified_v2.dta", replace


************************************************
/*
use "$data_mics\hl\Step_4_modified_v2.dta", clear
drop *_B_ageU *_B_ageA comp_higher* *_B 
*ren eduyears_C eduyears
drop hl3 ed5_ hh5d hh5m country ed4a_nr ed4b ed6a_nr ed6b_nr hh6 hh7 ed3 ed4a ed4b_label ed5 ed6* ed7 ed8* hl* code* eduyears*
drop years*
drop edu2* edu4*
drop comp_prim_1524_C_ageU-comp_upsec_2029_C_ageA
drop *_higher attend_higher_1822 attend_higher_2022
drop higher_dur lowsec_age0 upsec_age0 prim_age1 lowsec_age1 upsec_age1

foreach X in C {
foreach Y in prim lowsec upsec  {
	ren comp_`Y'_`X' comp_`Y'
	ren comp_`Y'_v2_`X'_ageU comp_`Y'_v2_ageU 
	ren comp_`Y'_v2_`X'_ageA comp_`Y'_v2_ageA
}
}

*Merge with adjustment information
merge m:1 country_year using "$data_mics\hl\mics3_adjustment.dta"
drop _merge
drop *max *min flag diff* adj2*
ren adj1_norm adjustment
order country_year urban wealth region ethnicity ageA ageU adjustment

label var year "Median of year of interview"
label var ageU "Age unadjusted"
label var ageA "Age adjusted"
label var prim_dur "Duration of primary"
label var lowsec_dur "Duration of lower secondary"
label var upsec_dur "Duration of upper secondary"
label var prim_age0 "Start age of primary"

drop year_folder
ren hh5y year_interview

split country_year, parse("_") gen(country)
ren country1 country
drop country2
order iso_code3 country_year country year year_interv hhid cluster individual_id hhweight age* sex urban region wealth ethnicity religion adjustment comp* attend
gen survey="MICS"
for X in any cluster hhid: cap tostring X, replace

label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"
label values wealth wealth

gen round="MICS3"
compress 
save "$gral_dir\data\before_collapse\MICS3_before_collapse.dta", replace

** Step 5: will have all the other indicators!

*/
*********************************************************************
** DATABASE TO APPEND TO MICS4&5 & DO THE GENERAL COLLAPSE
*********************************************************************
global categories_collapse location sex wealth region ethnicity religion
global categories_subset location sex wealth
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no


global data_mics "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\mics3"
global aux_data "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\auxiliary_data"

use "$data_mics\hl\Step_4_modified_v2.dta", clear
set more off
*Fixing the rest of the variables to make it uniform
	cap drop year
	bys country_year: egen year=median(hh5y)
	cap drop *_B_ageU *_B_ageA *_B
*----------------------------------------------	
	gen age_group=1 if (ageU==3|ageU==4)
	replace age_group=2 if ageU==5
	replace age_group=3 if (ageU==6|ageU==7|ageU==8)

	label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
	label values age_group age_group

	*---------------
	replace ed7="" if ed7=="don't know"
	*gen presch_before=1 if (ed7=="yes"|ed7=="1") & code_ed8a==0
	*tab attend if presch_before==1 // until here it is ok

	*codebook code_ed6a, tab(100) // code 6?
	gen attend_primary=1 if attend==1 & (code_ed6a==1|code_ed6a==60|code_ed6a==70)
	replace attend_primary=0 if attend==1 & code_ed6a==0
	replace attend_primary=0 if attend==0

	gen attend_preschool=1 if attend==1 & (code_ed6a==0)
	replace attend_preschool=0 if attend==1 & (code_ed6a==1|code_ed6a==60|code_ed6a==70)
	replace attend_preschool=0 if attend==0

	*for X in any attend attend_primary attend_preschool: replace X=. if presch_before==1 & attend==1 & (code_ed6a==2|code_ed6a==3|code_ed6a==21|code_ed6a==22|code_ed6a==32|code_ed6a==50|code_ed6a==90|code_ed6a==98|code_ed6a==99)

	gen no_attend=attend
	recode no_attend (1=0) (0=1)

	*enrolment rate in pre-primary relative to the population, by single age
	*- can be created with attend_preschool, with no restriction of preschool before

	*the new entry into pre-primary (i.e. not enrolled in education at all last year, enrolled in pre-primary this year), by single age?


	*tab code_ed6a attend , m 
	cap drop eduout

	gen eduout=no_attend
	replace eduout=. if (attend==1 & code_ed6a==.)
	replace eduout=. if ageU==.
	replace eduout=. if (code_ed6a==98|code_ed6a==99) & eduout==0 // missing when age, attendance or level of attendance (when goes to school) is missing
	replace eduout=1 if code_ed6a==0 // level attended: goes to preschool 

	codebook ed3, tab(100)
	replace ed3="missing" if ed3=="sem info"
	
	replace eduout=1 if ed3=="no" // "out of school" if "ever attended school"=no

	replace eduout=1 if code_ed6a==80 // level attended=not formal/not regular/not standard
	replace eduout=1 if code_ed6a==90 // level attended=khalwa/coranique (ex. Mauritania, SouthSudan, Sudan)


	*Merging with adjustment
	merge m:1 country_year using "$data_mics\hl\mics3_adjustment.dta", keepusing(adj1_norm) nogen
	ren adj1_norm adjustment
	
	*Dropping the B version because it is not going to be used. 
	cap drop *_B_ageU *_B_ageB *_B // the version C is the one to keep
	
	*Renaming the vars from _C
	foreach var in comp_prim comp_lowsec comp_upsec comp_higher eduyears {
	rename `var'_C `var'
}

gen agestandard=ageU if adjustment==0
replace agestandard=ageA if adjustment==1
cap drop *ageA
cap drop *_ageU // to keep ageU
	
*Age limits 
foreach X in prim lowsec upsec {
foreach AGE in agestandard {
	gen comp_`X'_v2=comp_`X' if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5
}
}

* FOR UIS request
gen comp_prim_aux=comp_prim if agestandard>=lowsec_age1+3 & agestandard<=lowsec_age1+5
gen comp_lowsec_aux=comp_lowsec if agestandard>=upsec_age1+3 & agestandard<=upsec_age1+5


foreach AGE in agestandard  {
	gen comp_prim_1524=comp_prim if `AGE'>=15 & `AGE'<=24
	gen comp_upsec_2029=comp_upsec if `AGE'>=20 & `AGE'<=29
	*gen comp_higher_2529=comp_higher if `AGE'>=25 & `AGE'<=29
	*gen comp_higher_3034=comp_higher if `AGE'>=30 & `AGE'<=34
	gen comp_lowsec_1524=comp_lowsec if `AGE'>=15 & `AGE'<=24
	*gen attend_higher_1822=attend_higher if `AGE'>=18 & `AGE'<=22
	*gen attend_higher_2022=attend_higher if `AGE'>=20 & `AGE'<=22
}

*I drop the "C" versions for eduyears. Eduyears was already renamed.
drop *_2024_C

*With age limits
gen eduyears_2024=eduyears if agestandard>=20 & agestandard<=24
foreach X in 2 4 {
	gen edu`X'_2024=0
	replace edu`X'_2024=1 if eduyears_2024<`X'
	replace edu`X'_2024=. if eduyears_2024==.
}

for X in any prim_dur lowsec_dur upsec_dur prim_age0 : ren X X_comp

*Durations for out-of-school
merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta"
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
	*gen eduout_`X'=eduout if schage>=`X'_age0_eduout & schage<=`X'_age1_eduout
	gen eduout_`X'=eduout if agestandard>=`X'_age0_eduout & agestandard<=`X'_age1_eduout
	}

	
*Dropping variables
drop hl* hh5* hh6 district 
drop ed3* ed4* ed5* ed6* ed7* ed8* code*
drop lowsec_age0 upsec_age0 prim_age1 lowsec_age1 upsec_age1

*Create variables for count of observations
foreach var of varlist $varlist_m {
		gen `var'_no=`var'
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

compress
save "$data_mics\hl\Step_4_temp.dta", replace


*-- For Bilal: Before collapse
use "$data_mics\hl\Step_4_temp.dta", clear
keep hhweight age* year ///
iso_code3 country* cluster individual_id ///
adjustment comp* edu* *attend* location sex wealth ethnicity religion region 
drop *no* *aux*
drop region ethnicity religion
ren agestandard age_adjusted
ren ageU age
drop age_group
label var year "Median year of interview"
order iso country* year* *weight *id cluster age* adjustment location sex wealth
compress
save "C:\Users\Rosa_V\Dropbox\microdata_Bilal\microdata_MICS3.dta", replace



use "$data_mics\hl\Step_4_temp.dta", clear
	*Drop variables not needed right now
	drop attend* no_attend 
	drop year_folder

compress
save "$data_mics\hl\MICS3_Step_5.dta", replace

********************************************

*For Metadata
use "$data_mics\hl\MICS3_Step_5.dta", clear
append using "$gral_dir\data\mics\mics2\hl\MICS2_Step_5.dta"
collapse comp_prim_v2, by(country_year adjustment prim_age0_com prim_dur_com lowsec_dur_com upsec_dur_com prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)

