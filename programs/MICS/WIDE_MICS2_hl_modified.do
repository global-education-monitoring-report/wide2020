*For Rosa
global data_raw_mics "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\Data\MICS"
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS"

global programs_mics "$gral_dir\programs\mics\mics2&3"
global aux_programs "$programs_mics\auxiliary"

global aux_data "$gral_dir\data\auxiliary_data"
global data_mics "$gral_dir\data\mics\mics2"



*Vars to keep
global vars_keep_mics "hhid hvidx hv000 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124"
global categories sex urban region wealth
set more off

*****************************************************************************************************
*	Preparing databases to append later (MICS 2)
*----------------------------------------------------------------------------------------------------
global vars_mics4 hh1 hh2 hh5* hh6* hh7* hl1 hl3 sex age hl5* ed1 ed3* ed4* ed5* ed6* ed7* ed8* windex5 schage hhweight religion ethnicity region rel_head
global list4 hh6 hh7 ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed8b religion ethnicity region schage  // hl5y hl5m hl5d hh7r ed3x ed4 ed4ax

*****************
/*
set more off
include "${aux_programs}\survey_list_mics2_hl"
foreach file in $survey_list_mics_hl {
	use "$data_raw_mics/`file'", clear
		tokenize "`file'", parse("\")
		gen country = "`1'" 
		gen year_folder = `3'
		
	cap rename *, lower
	
	*Here to homogenize variables for all MICS2 first
	/*
	if (country=="Botswana" & year_folder==2000) {
		ren (p13 p14 p06 p07) (ed16a ed16b sex age)
		ren p03 h13
		ren weight hhweight // missing info for individual id
	}
	*/
	if (country=="Albania" & year_folder==2000) {
		cap ren (hli4a) (hl4y)
	}
	if (country=="Cameroon" & year_folder==2000) {
		cap ren (hi7a) (region)
	}
		if (country=="DRCongo" & year_folder==2000) {
		cap drop age // it already exists variable of age but for tranches
	}
	if (country=="Guinea-Bissau" & year_folder==2000) {
		cap ren (afid) (hi1) // had to rename them like this to capture cluster and HH id
	}
	if (country=="Guyana" & year_folder==2000) {
		cap egen id=concat(hirgn hi1) // Has a problem for individual id. It is hirgn+hi1+hi2+hl1
		destring id, replace
		drop hi1
		ren id hi1
	}
	if (country=="Indonesia" & year_folder==2000)|(country=="Mongolia" & year_folder==2000) {
		cap ren (hl2) (rel_head) //only case with rel_head
	}
	if (country=="Indonesia" & year_folder==2000) {
		cap gen hi3m=2 // Interviews conducted in February-2000
		cap gen hi3y=2000
	}
	if (country=="Iraq" & year_folder==2000) {
		cap drop hl1
		cap ren (hl100) (hl1) 
	}
	if (country=="Kenya" & year_folder==2000) {
		cap replace hi3y=2000 //Year was set up as 0
		cap ren hl4a rel_head
		cap gen year_birth=hl3y+1900
		cap replace year_birth=hl3y+2000 if hl3y==0 & hl4<2
		cap gen cum_year=hl4+year_birth // cumulative age+years_birth should be around 2000. Otherwise, missing
		cap tab cum_year
		cap gen yearbi=.
		cap replace yearbi=year_birth if (cum_year>1997|cum_year<2002) // takes only those which year+age is around 2000. Otherwise, missing
		cap replace yearbi=99 if (cum_year<1998|cum_year>2001)
		cap replace yearbi=. if hl3y==.
		cap drop hl3y year_birth cum_year
		cap ren yearbi hl3y
		cap ren (hld hl3m hl3y) (hl4d hl4m hl4y)
	}
	if (country=="LaoPDR" & year_folder==2000) {
		cap ren (hl5d hl5m hl5y) (hl4d hl4m hl4y) // I rename them as MICS2 to match later on better 
		cap ren (hl15 hi7b hi16s) (rel_head region ethnicity)
		cap gen sixdigits=int(hid/1000)
		gen newvar = mod(hhmid,100000)
		cap drop hi1 hi2
		cap ren (sixdigits newvar) (hi1 hi2) //better idea was to extract info from hhmid which is already correct
		cap ren ed1 ed14
	}
	/*if (country=="Lesotho" & year_folder==2000) {
		cap ren (hi6a) (region)
	}*/
	if (country=="Myanmar" & year_folder==2000) {
		cap gen fourdigits=int(hid/100)
		cap gen line = mod(hhmid,100)
		cap drop hi1 hl1
		cap ren (fourdigits line) (hi1 hl1) //better idea was to extract info from hhmid which is already correct		
	}
	if (country=="Philippines" & year_folder==1999) {
		cap replace hi1=15 if province==55 & hi2==16 & hi1==. // First missings after sort province hi1 hi2 hl1. For province=55, hi2=16. Checking, for hi1=15, hi2=16 is missing in order. It corresponds to this
		cap replace hi1=46 if province==58 & hi2==7 & hi1==. // First missings after sort province hi1 hi2 hl1. For province=58, hi2=7 . Checking, for hi1=46, hi2=7  is missing in order. It corresponds to this
		cap egen clust=concat(province hi1) // Has a problem for individual id. It is province+hi1+mhcn+hi2+hl1
		destring clust, replace
		cap egen id=concat(mhcn hi2)
		destring id, replace
		drop hi1 hi2
		ren (clust id)(hi1 hi2)
		cap ren (hl3a province) (rel_head hi7)
	}
	if (country=="Rwanda" & year_folder==2000) {
		cap ren (province) (region)
	}
	if (country=="Senegal" & year_folder==2000) {
	cap ren (hl3aam hl3aaa) (hl4m hl4y)
	}
	if (country=="SouthSudan" & year_folder==2000)|(country=="Sudan" & year_folder==2000)|(country=="Togo" & year_folder==2000) {
		cap gen fourdigits=int(hid/1000)
		cap gen clus = mod(hid,10000)
		cap drop hi1 hi2
		cap ren (fourdigits clus) (hi1 hi2) //better idea was to extract info from hhmid which is already correct		
	}
	if (country=="Suriname" & year_folder==2000) {
		cap gen fourdigits=int(hid/1000)
		cap gen clus = mod(hid,10000)
		cap drop hi2 hi1
		cap ren (fourdigits clus) (hi1 hi2) //better idea was to extract info from hhmid which is already correct		
	}
	if (country=="TrinidadandTobago" & year_folder==2000) {
	cap ren (tthl6 tthl7 tthld tthlm tthly) (ethnicity religion hl4d hl4m hl4y)
	cap drop hi1 hi2
	cap gen hi1 = hi7
	cap gen double hi2 = hid //better idea was to redefine hi1 and hi2 in this way
	}
	if (country=="VenezuelaBR" & year_folder==2000) {
	cap ren (secvii33 seci_ent) (rel_head hi7)
	}
	if (country=="VietNam" & year_folder==2000) {
	cap ren hi7 region
	cap ren hi7a hi7
	cap gen hi3y=2000 // survey conducted in 2000
	cap gen double digits=int(hid/10000)
	cap drop hi1
	cap ren digits hi1
	}
	if (country=="Zambia" & year_folder==2000) {
	cap ren (hl9b hl1a hl1b ynais menq yenq) (rel_head hl4d hl4m hl4y hi3m hi3y)
	cap destring hi6, replace
	label define urbany 1 "rural" 2 "urban"
	label values hi6 urbany	
	cap destring hid, replace
	cap format hid %25.0f
	cap gen double digits=int(hid/1000000)
	cap format digits %25.0f
	cap drop hi1
	cap ren digits hi1
	
	}
	*Generating missing variables with zeros
	for X in any wlthind5 hl3 hi6 hi7 ed14 ed17 ed18 ed19 ed20a ed20b ed22a ed22b rel_head hl4d hl4m hl4y hi3d hi3m hi3y: cap gen X=.
	
	*renaming id, region,sex,age,urban,wealth to match with MICS3&4&5
	cap ren (hi1 hi2 hi6 hi7 hl3 hl4 wlthind5) (hh1 hh2 hh6 hh7 sex age windex5) 
	*renaming date interview
	cap ren (hi3d hi3m hi3y) (hh5d hh5m hh5y)
	*renaming birth date
	cap ren (hl4d hl4m hl4y) (hl5d hl5m hl5y)
	*renaming education
	cap rename (ed14 ed15 ed16a ed16b ed18 ed20a ed20b ed21 ed22a ed22b) (ed1 ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed8b) // re numerating to match names of MICS 3&4&5. See Excel file track_DHS_MICS_LG_v2, questionnaires_compare tab
	*renaming religion ethnicity
	if (country=="Chad" & year==2000) {
		cap ren (hi9a hi9b) (ethnicity religion) 
	}
	for X in any hh7a hh7r region: cap ren X hh7 // for alternatives names of region

	for X in any $list4 windex5 schage ed1 hl5y hh5y hl3: cap gen X=.

	keep $vars_mics4 country year*

	for X in any ed4a ed4b ed6a ed6b: gen X_nr=X // create the numbers (without labels) for ed4a, ed6b etc
	for X in any $list4 : cap decode X, gen(label_X)
	if (country=="Chad" & year==2000) {
		cap gen label_ethnicity=ethnicity // to keep info at least as number. No code exists
		tostring label_ethnicity, replace
	}
	if (country=="Philippines" & year==1999)|(country=="VenezuelaBR" & year_folder==2000) {
		cap gen label_hh7=hh7 // to keep info at least as number. No code exists
		tostring label_hh7, replace
	}
	drop $list4 
	for X in any $list4 : cap ren label_X X // this one has the labels
	cap label drop _all
	*replacing rel_head
	cap replace hl3=rel_head
	drop rel_head
	compress
	save "$data_mics\hl\countries\\`1'`3'", replace
}

********************************************************************************
* 	Appending all the databases
********************************************************************************

cd "$data_mics\hl\countries"
local allfiles : dir . files "*.dta"
use "Albania2000.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

*Drop unnecessary variables

drop hl55 hl5
*drop hh5 hh5c hh6a hh6b hh6aa hh7a hh7b hh7c hh7d hh7e hh7f hh7new hh6w hh7w ed3aa ed6c ed6d ed6e ed6f ed6g ed6h hl5a  hl5_1 hl5nova ed3x ed3y ed8x ed8y ///
compress
save "$data_mics\hl\hl_append_mics_2.dta", replace

**************************************************************************
*	Translate. Only for STATA 14 or later
**************************************************************************
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics\hl"
unicode analyze "hl_append_mics_2.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "hl_append_mics_2.dta"




*/
*************************************************************************
*	Fixing categories and creating variables
**************************************************************************
set more off
use "$data_mics\hl\hl_append_mics_2.dta", clear

* ID for each country year: Variable country_year
*year of survey (in the data) can be different from the year in the name of the folder. Or there can be 2 years in the data as the survey expanded through 2 years
*Important because eduvars can change through years for the same country
cap ren year_file year_folder
gen country_year=country+ "_" +string(year_folder)

*Individual ids
gen hh1_s=string(hh1, "%25.0f")
gen hh2_s=string(hh2, "%25.0f")
gen individual_id = country_year+" "+hh1_s+" "+hh2_s+" "+string(hl1)    
ren hh1_s cluster
ren hh2_s hhid
drop hh1* hh2* hl1 ed1
*codebook individual_id // uniquely identifies people
*Dealing with duplicates for CotedIvore. After checking, those are just repeated and have same info twice.
duplicates tag individual_id, gen(dup)
drop dup
duplicates drop if country=="CotedIvoire"
*isid individual_id // checking uniquely identifies people

***************************
*Creating categories
***************************
*Sex
*ren hl4 sex. Already done before
recode sex (2=0) (9=.) (3/4=.) (7=.)
label define sex 0 "female" 1 "male"
label values sex sex

*Age
*ren hl6 age. Already done before
	gen ageA=age-1 // before it had the restriction "if adj==1" . I'll show both adjusted and unadjusted and a flag that says if it should be adjusted!
	ren age ageU


*Urban
replace hh6=lower(hh6)
gen urban=.
replace urban=0 if (hh6=="rural"|hh6=="rurales")
replace urban=1 if (hh6=="urbain"|hh6=="urbaines"|hh6=="urban"|hh6=="urbana"|hh6=="urbano")
replace urban=1 if hh6=="antananarivo" |hh6=="chef lieu faritany" | hh6=="antsirabe ville" //for Madagascar

label define urban 0 "rural" 1 "urban" 2 "camps"
label values urban urban

*codebook urban hh6, tab(100)
*table country_year, c(mean urban)

*Wealth
ren windex5 wealth
*codebook wealth, tab(100)
*table country_year, c(mean wealth)

*Weight: already named hhweight

*codebook ethnicity, tab(200)

*Region (solving name of regions to be done later)
*- Need to check what is the real variable identifying the region
include "$aux_programs/regions_mics2.do"
include "$aux_programs/ethnicity_religion_mics3.do"
*the ethnicity for Chad-2000 is impossible to know because it only has numbers with no code in its dictionary
replace ethnicity="" if country_year=="Chad_2000"
for X in any religion ethnicity: replace X="" if X=="Missing/DK"|X=="Missing"

** CHANGES TO EDUCATION VARIABLES
* ed3= ever attended school
* ed4a= highest level of edu (ever) 
* ed5= currently attending
* ed6a= current level of edu

*---- 1. Changes to Edu labels

global clean "ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a ed8b"

* Eliminates alpha-numeric characters to ease reading
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

************CHECK THIS FOR RE CODING code_ed4a code_ed6a later on
*I added this save to save time


** Fix to missing in years, months and days of interview
*codebook hh5y hh5d hh5m, tab(200) //  Phillipines 1999 doesn't have interview date info
replace hh5y=year_folder if country_year=="Philippines_1999"  // obtained from CH module
replace hh5m=11 if country_year=="Philippines_1999" // obtained from CH module
replace hh5y=year_folder if hh5y==. // 138 cases only
*Many countries don't have day of interview. Some don't have month



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

********************************************************************
*Fixing countries' codes which have differences in ed4a and ed6a. Re coding to match with ed4a
********************************************************************
	recode code_ed6a (2=1) (3=2) (4=3) if country_year=="Albania_2000"
	recode code_ed6a (1=0) (2=1) (3=2) if country_year=="BoliviaPS_2000"
	recode code_ed6a (1=0) (2=1) (3=2) (5=90) if country_year=="Burundi_2000"
	recode code_ed6a (1=0) (2=1) (3=2)  if country_year=="Comoros_2000"
	recode code_ed6a (97=9)  if country_year=="Guinea-Bissau_2000"
	recode code_ed6a (1=0) (2=1) (3=2)  if country_year=="Iraq_2000"
	recode code_ed6a (1=0) (2=1) (3=2) (4=3)  if country_year=="LaoPDR_2000"
	recode code_ed6a (1=0) (3=4) (5=9) (7=99)  if country_year=="Mongolia_2000"
	recode code_ed6a (2=0) (3=2) (4=3) (5=4)  if country_year=="Myanmar_2000"
	recode code_ed6a (1=0) (2=1) (3=2) (4=3) (6=5)  if country_year=="Rwanda_2000"
	recode code_ed6a (1=0) (2=1) (3=2) if country_year=="SaoTomeandPrincipe_2000"
	recode code_ed6a (1=0) (2=1) (3=2) if country_year=="SierraLeone_2000"
	recode code_ed6a (1=0) (2=1) (3=2) if country_year=="Tajikistan_2000"
	recode code_ed6a (1=0) (2=1) (3=2) if country_year=="Uzbekistan_2000"

* Case 1) Countries that have same as the standard edulevel code (0=preschool, 1=primary, 2=secondary, 3=higher). 
* 		  I only need to recode (8=98) (9=99)


* Case 2) Countries that need recoding of the edulevel to be in line with the NEW value labels
foreach var of varlist code_ed4a code_ed6a {
	*recode `var' (1=0) (2=1) (3=22) (4=3) (7=99) (9=98) if country_year=="Albania_2000" 
	recode `var' (1=1) (2=70) (3=22) (4=3) (7=99) (9=98) if country_year=="Albania_2000" 
	recode `var' (1=0) (2=1) (3=21) (4=22) (5=3) (7=3) (6=32) (7=99) (9=98) if country_year=="Azerbaijan_2000" // vocational as post-secondary based on ISCED
	*recode `var' (4=80) (7=99) (9=98) if country_year=="BoliviaPS_2000" 
	recode `var' (1=70) (2=22) (4=80) (7=99) (9=98) if country_year=="BoliviaPS_2000" 
	recode `var' (1=0) (2=70) (3=22) (4/5=3) (6=80) (9=98) if country_year=="BosniaandHerzegovina_2000" 
	recode `var' (4=80) (9=98) if country_year=="Burundi_2000" 
	recode `var' (1/2=1) (3=2) (4=80) (5=3) (7=99) (9=98) if country_year=="Cameroon_2000"
	recode `var' (1=0) (2=1) (3=2) (4=3) (5=80) (7=99) (9=98) if country_year=="CentralAfricanRepublic_2000" 
	recode `var' (4=80) (7=99) (9=98) if country_year=="Chad_2000" 
	recode `var' (4=80) (7=99) (9=98) if country_year=="Comoros_2000" 
	recode `var' (3=80) (4=3) (5=40) (7=99) (9=98) if country_year=="DRCongo_2000" 
	recode `var' (4=80) (7=99) (9=98) if country_year=="CotedIvoire_2000"
	recode `var' (1=0) (2=70) (3=22) (4=3) (7=99) (9=98) if country_year=="DominicanRepublic_2000" //changed from LG
	recode `var' (1=0) (2=1) (3=2) (4=3) (7=99) (9=98) if country_year=="EquatorialGuinea_2000"
	recode `var' (2=21) (3=22) (4=22) (5=3) (6/7=90) (8=80) (97=99) (9=98) if country_year=="Gambia_2000" //Vocational as 22
	*recode `var' (2=21) (3=22) (4=3) (5=80) (7=99) (9=98) if country_year=="Guinea-Bissau_2000"
	recode `var' (2=1) (3=2) (4=3) (5=80) (7=99) if country_year=="Guinea-Bissau_2000"
	recode `var' (1=0) (2=1) (3=2) (4=3) (5=80) (7=99) (9=98) if country_year=="Guyana_2000"
	recode `var' (2=90) (5=90) (3=80) (6=80) (4=21) (7=22) (8=90) (9=24) (10/11=3) (12/13=3) if country_year=="Indonesia_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="Iraq_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="Kenya_2000"
	*recode `var' (4=80) (7=99) (9=98) if country_year=="LaoPDR_2000" 
	recode `var' (2=21) (3=22) (4=80) (7=99) (9=98) if country_year=="LaoPDR_2000" // Similar to coding in LaoPDR2006
	recode `var' (1=0) (2=1) (3=2) (4=3) (8=98) (7=99) (9=98) if country_year=="Madagascar_2000"
	recode `var' (1=0) (2=1) (3=21) (4=22) (5=80) (6=98) (7=99) (9=98) if country_year=="RepublicofMoldova_2000"
	recode `var' (1=98) (2=1) (3=21) (4=22) (5=24) (6=32) (7=3) (9=98) if country_year=="Mongolia_2000"
	recode `var' (1=80) (2=1) (3=2) (4/5=3) (7=99) (9=98) if country_year=="Myanmar_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="Niger_2000"
	recode `var' (4=90) (5=98) (7=99) (9=98) if country_year=="Philippines_1999"
	recode `var' (2=21) (3=2) (4=3) (5=80) (96=97) (97=99) (99=98) if country_year=="Rwanda_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="SaoTomeandPrincipe_2000"
	recode `var' (1=0) (2=1) (3=21) (4=22) (5=3) (6=80) (7=99) (9=98) if country_year=="Senegal_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="SierraLeone_2000"
	recode `var' (1=0) (2=1) (3=2) (4=3) (5=80) (7=99) (9=98) if country_year=="Sudan_2000"
	*recode `var' (1=0) (2=1) (3=2) (4=3) (5=80) (7=99) (9=98) if country_year=="SouthSudan_2000"	
	recode `var' (1=0) (2=70) (3=22) (4=3) (5=80) (7=99) (9=98) if country_year=="SouthSudan_2000"	
	
	recode `var' (1=0) (2=1) (3=21) (4=22) (5=3) (7=99) (9=98) if country_year=="Suriname_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="Tajikistan_2000"
	recode `var' (2=21) (3=22) (4=80) (5=0) (6/7=99) (9=98) if country_year=="Togo_2000"
	
	recode `var' (0=99) (1=0) (2=1) (3=2) (4=3) (5/9=99) (7=99) (9=98) if country_year=="TrinidadandTobago_2000"
	recode `var' (4=80) (7=99) (9=98) if country_year=="Uzbekistan_2000"
	recode `var' (0=99) (1=0) (2=1) (3=2) (4=24) (5=3) (7=99) (6/9=98) if country_year=="VenezuelaBR_2000"
	recode `var' (2=21) (3=22) (4=80) (5=24) (6=3) (7=99) (9=98) if country_year=="VietNam_2000"
	recode `var' (1=0) (2=1) (3=2) (7=99) (9=98) if country_year=="Zambia_2000"
}

for X in any code_ed4a code_ed6a: label values X edulevel_new 

compress
save "$data_mics\hl\Step_1_modified.dta", replace

*----------------------------------------------------------------

/*
*---------------------------------------
** 		AGE ADJUSTMENT
*---------------------------------------
set more off
use "$data_mics\hl\Step_0_modified.dta", clear
keep country_year hh5d hh5m hh5y iso_code3
	merge m:1 country_year using "$aux_data\temp\current_school_year_MICS.dta" // current school year that ED question in MICS refers to
	drop if _merge==2 
	drop _merge 
	drop MICSround
	
* See Excel track_DHS_MICS_LG_v2, tab missing current_school_year for the list of changes
	*MICS2 (LG has to confirm this...)
	
replace current_school_year="" if (current_school_year=="doesn't have the variable"|current_school_year=="questionnaire not available" ///
	|current_school_year=="not in the questionnaire"|current_school_year=="report not available"|current_school_year=="doesn't say in the questionnaire")
	
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
save "$data_mics\hl\mics2_adjustment.dta", replace
*/


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

********************************************************************************************************************************************************
*******************************************************************************************************************************
	
use "$data_mics\hl\Step_1_modified.dta", clear	
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
	*None

*-----------------------------------------------------------------------------------------------
*Creating the dropped ages, taking into account the new durations
*Ages for completion
	gen lowsec_age0=prim_age0+prim_dur
	gen upsec_age0=lowsec_age0+lowsec_dur
	for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1


*With info of duration of primary and secondary I can also compare official duration with the years of education completed..
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur
	*drop *_dur
	
compress
save "$data_mics\hl\Step_2_modified.dta", replace




*********************************************************************************************************************************

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

*****************************
***** DEFINING EDUYEARS NOW
*****************************

	set more off
	use "$data_mics\hl\Step_2_modified.dta", clear

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
	*Burundi
	replace eduyears=ed4b if country_year=="Burundi_2000" & (code_ed4a==0|code_ed4a==1|code_ed4a==2|code_ed4a==3)
	replace eduyears=0 if country_year=="Burundi_2000" & (code_ed4a==80)
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Burundi_2000"	
	
	*Zambia (changed by Rosa)
	replace eduyears=ed4b if country_year=="Zambia_2000"
	replace eduyears=0 if country_year=="Zambia_2000" & (code_ed4a==80)
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Zambia_2000"	
	
	
	*Chad 2000. Stairs but need to fix 
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="Chad_2000"
	replace eduyears=ed4b-10+years_prim if (code_ed4a==2) & country_year=="Chad_2000"
	replace eduyears=ed4b-20+years_upsec if (code_ed4a==3) & country_year=="Chad_2000"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Chad_2000"
	*Kenya 2000. Few changes
	replace eduyears=ed4b if country_year=="Kenya_2000" & code_ed4a!=80
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Kenya_2000"
	*Madagascar 2000. Few changes
	replace eduyears=ed4b if country_year=="Madagascar_2000" & code_ed4a!=0
	replace eduyears=0 if country_year=="Madagascar_2000" & code_ed4a==0
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Madagascar_2000"
	*RepublicofMoldova 2000. Few changes
	replace eduyears=ed4b if country_year=="RepublicofMoldova_2000" & code_ed4a!=80
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="RepublicofMoldova_2000"
	*Myanmar 2000. Few changes
	replace eduyears=ed4b if country_year=="Myanmar_2000" & code_ed4a!=80
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Myanmar_2000"	
	*Philippines 1999. Few changes
	replace eduyears=ed4b if country_year=="Philippines_1999" & (code_ed4a==0|code_ed4a==1)
	replace eduyears=ed4b-4 if country_year=="Philippines_1999" & (code_ed4a==2|code_ed4a==3) //higher missing, only 38 persons
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Philippines_1999"

*Azerbaijan
	replace eduyears=ed4b if country_year=="Azerbaijan_2000" & (code_ed4a==1|code_ed4a==21|code_ed4a==22)
	replace eduyears=years_upsec+ed4b if country_year=="Azerbaijan_2000" & (code_ed4a==3)
	*For those that have more years than the level duration (few cases)?? need to do it?? Bilal said no
	replace eduyears=0 if code_ed4a==0 & country_year=="Azerbaijan_2000"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Azerbaijan_2000"

	*Guinea-Bissau (Rosa)
	replace eduyears=ed4b if country_year=="Guinea-Bissau_2000" & (code_ed4a==0|code_ed4a==1|code_ed4a==2)
	replace eduyears=ed4b+years_upsec if country_year=="Guinea-Bissau_2000" & (code_ed4a==3)
	
	
*-------------------------------------------------------------------------------------------------------
*--1c) STAIRS BUT DOESN'T SAY HOW MANY YEARS IN HIGHER ED

*VietNam 2000
replace eduyears=ed4b if (code_ed4a==1|code_ed4a==21|code_ed4a==22|code_ed4a==24) & country_year=="VietNam_2000"
for Y in any 97 98 99:	replace eduyears=Y if ed4b==Y & country_year=="VietNam_2000"
replace eduyears=years_upsec+0.5*higher_dur if code_ed4a==3 & country_year=="VietNam_2000" // ask about this assumption!!
replace eduyears=0 if (code_ed4a==0) & country_year=="VietNam_2000"
for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="VietNam_2000"

*-----------------------------------------------------------------------------------------------------------
*2) For those FLAT
*-----------------------------------------------------------------------------------------------------------

*		2a) FLAT 
foreach country_year in Albania_2000 BoliviaPS_2000 BosniaandHerzegovina_2000 Cameroon_2000 CentralAfricanRepublic_2000 Comoros_2000 DominicanRepublic_2000 DRCongo_2000 CotedIvoire_2000 EquatorialGuinea_2000 Gambia_2000 ///
					Guyana_2000 Iraq_2000 LaoPDR_2000 Niger_2000 Rwanda_2000 Senegal_2000 SierraLeone_2000 SouthSudan_2000 Suriname_2000 Tajikistan_2000 Togo_2000 TrinidadandTobago_2000 ///
					Uzbekistan_2000 {
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==60|code_ed4a==70) & country_year=="`country_year'"
	replace eduyears=ed4b+years_prim if (code_ed4a==2|code_ed4a==21|code_ed4a==23) & country_year=="`country_year'" 
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"  
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'" 
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'" 
	replace eduyears=0 if code_ed4a==0 & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if code_ed4a==YY & country_year=="`country_year'"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
}
*Fixing one case of ed4b=96 for Suriname
replace eduyears=99 if ed4b==96 & country_year=="Suriname_2000"
for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Suriname_2000"

	*Sudan_2000 VenezuelaBR_2000 Flat but primary of 8 years
foreach country_year in BoliviaPS_2000 Sudan_2000 VenezuelaBR_2000 {
	replace eduyears=0 if (code_ed4a==0) & country_year=="`country_year'"
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==60|code_ed4a==70) & country_year=="`country_year'"	
	replace eduyears=ed4b+years_prim if (code_ed4a==2|code_ed4a==21|code_ed4a==23) & country_year=="`country_year'"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"  
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'" 
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"  
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="`country_year'"
	}
	
	
	*Had to recode to split primary from low_sec
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="Sudan_2000")
	recode code_ed4a (2=22) if (country_year=="Sudan_2000")
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="SouthSudan_2000")
	recode code_ed4a (2=22) if (country_year=="SouthSudan_2000")
	recode code_ed4a (1=21) if ed4b>years_prim & (country_year=="VenezuelaBR_2000")
	recode code_ed4a (2=22) if (country_year=="VenezuelaBR_2000")

*Indonesia
	replace eduyears=0 if (code_ed4a==0) & country_year=="Indonesia_2000" 
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="Indonesia_2000" 
	replace eduyears=years_prim if (code_ed4a==1) & country_year=="Indonesia_2000" & ed4b==8 // 8 is for completed degree
	replace eduyears=ed4b+years_prim if (code_ed4a==21) & country_year=="Indonesia_2000" 
	replace eduyears=years_lowsec if (code_ed4a==21) & country_year=="Indonesia_2000" & ed4b==8
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="Indonesia_2000" 
	replace eduyears=years_upsec if (code_ed4a==22|code_ed4a==24) & country_year=="Indonesia_2000" & ed4b==8
	replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="Indonesia_2000"
	replace eduyears=years_upsec+2 if (code_ed4a==3) & country_year=="Indonesia_2000" & ed4b==8 & (ed4a_nr==10|ed4a_nr==13) // Ask this assumption for those completed
	replace eduyears=years_upsec+3 if (code_ed4a==3) & country_year=="Indonesia_2000" & ed4b==8 & ed4a_nr==11 // Ask this assumption	for those completed
	replace eduyears=years_upsec+5 if (code_ed4a==3) & country_year=="Indonesia_2000" & ed4b==8 & ed4a_nr==12 // Ask this assumption	for those completed
	for YY in any 97 98 99:	replace eduyears=YY if code_ed4a==YY & country_year=="Indonesia_2000"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Indonesia_2000"

*Mongolia
	replace eduyears=0 if (code_ed4a==0) & country_year=="Mongolia_2000" 
	replace eduyears=ed4b-2 if (code_ed4a==1) & country_year=="Mongolia_2000" // weird case but it makes more sense like this
	replace eduyears=ed4b-2 if (code_ed4a==21) & country_year=="Mongolia_2000" // weird case but it makes more sense like this
	replace eduyears=ed4b if (code_ed4a==22) & country_year=="Mongolia_2000"  
	replace eduyears=ed4b+years_lowsec if (code_ed4a==24) & country_year=="Mongolia_2000"  
	replace eduyears=ed4b+years_lowsec if (code_ed4a==3|code_ed4a==32) & country_year=="Mongolia_2000"
	for YY in any 97 98 99:	replace eduyears=YY if code_ed4a==YY & country_year=="Mongolia_2000"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="Mongolia_2000"
*SaoTomeandPrincipe
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="SaoTomeandPrincipe_2000" 
	replace eduyears=ed4b if (code_ed4a==2) & country_year=="SaoTomeandPrincipe_2000" 
	replace eduyears=ed4b+years_upsec-3 if (code_ed4a==3) & country_year=="SaoTomeandPrincipe_2000" // had to this because higher starts in 3 as minimum
	for YY in any 97 98 99:	replace eduyears=YY if code_ed4a==YY & country_year=="SaoTomeandPrincipe_2000"
	for YY in any 97 98 99:	replace eduyears=YY if ed4b==YY & country_year=="SaoTomeandPrincipe_2000"
	
	
*** I NEED TO TO THIS FOR ALL
replace eduyears=97 if (ed4b_label=="inconsistent")
replace eduyears=98 if ed4b_label=="don't know"
replace eduyears=99 if (ed4b_label=="missing"|ed4b_label=="doesn't answer")

cap drop t temp
compress
save "$data_mics\hl\Step_3_modified.dta", replace

/*
for X in any ed4a ed6a: gen check_X=string(code_X)+" "+X
cap log close
set more off
log using "$data_mics\logs\2_TAB eduyears code_ed4a.log", replace
bys country year: tab eduyears check_ed4a, m 
log close
*/

***************************************************************************************************************************************************************


*********************************************************************************************************

set more off
use "$data_mics\hl\Step_3_modified.dta", clear

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

compress
save "$data_mics\hl\Step_4_modified_v2.dta", replace



/*
use "$data_mics\hl\Step_4_modified_v2.dta", clear
drop comp_prim_B comp_lowsec_B comp_upsec_B comp_higher_B comp_prim_v2_B_ageU comp_prim_v2_B_ageA comp_lowsec_v2_B_ageU comp_lowsec_v2_B_ageA comp_upsec_v2_B_ageU comp_upsec_v2_B_ageA comp_higher*
drop *_higher attend_higher_1822 attend_higher_2022
drop edu2* edu4*
drop comp_prim_1524_C_ageU comp_lowsec_1524_C_ageU comp_upsec_2029_C_ageU comp_prim_1524_C_ageA comp_lowsec_1524_C_ageA comp_upsec_2029_C_ageA eduyears_2024_B eduyears_2024_C
drop comp_prim_1524_B_ageU comp_lowsec_1524_B_ageU comp_upsec_2029_B_ageU comp_prim_1524_B_ageA comp_lowsec_1524_B_ageA comp_upsec_2029_B_ageA
drop eduyears_B
ren eduyears_C eduyears
drop eduyears*

foreach X in C {
foreach Y in prim lowsec upsec  {
	ren comp_`Y'_`X' comp_`Y'
	ren comp_`Y'_v2_`X'_ageU comp_`Y'_v2_ageU 
	ren comp_`Y'_v2_`X'_ageA comp_`Y'_v2_ageA
}
}

*Merge with adjustment information
merge m:1 country_year using "$data_mics\hl\mics2_adjustment.dta"
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
label var lowsec_age0 "Start age of lower secondary"
label var upsec_age0 "Start age of upper secondary"


drop year_folder
ren hh5y year_interview

drop country
split country_year, parse("_") gen(country)
ren country1 country
drop country2
order iso_code3 country_year country year year_interv hhid cluster individual_id hhweight age* sex urban region wealth ethnicity religion adjustment comp* attend
drop hl5y-code_ed6a
drop higher_dur-years_upsec
gen survey="MICS"
for X in any cluster hhid: cap tostring X, replace

	label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"
	label values wealth wealth
	
gen round="MICS2"	
compress 
save "$gral_dir\data\before_collapse\MICS2_before_collapse.dta", replace

*/

** Step 5: will have all the other indicators!

*********************************************************************
** DATABASE TO APPEND TO MICS4&5 & DO THE GENERAL COLLAPSE
*********************************************************************

** DATABASE TO APPEND TO MICS4&5 & DO THE GENERAL COLLAPSE
global categories_collapse location sex wealth region ethnicity religion
global categories_subset location sex wealth
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no


global data_mics "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_MICS\data\mics2"
global aux_data "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\auxiliary_data"

use "$data_mics\hl\Step_4_modified_v2.dta", clear
set more off
	*Fixing the rest of the variables to make it uniform
	cap drop year
	bys country_year: egen year=median(hh5y)
	cap drop *_B_ageU *_B_ageA *_B
	
*From here on is the same as for MICS4&5
	gen age_group=1 if (ageU==3|ageU==4)
	replace age_group=2 if ageU==5
	replace age_group=3 if (ageU==6|ageU==7|ageU==8)

	label define age_group 1 "Ages 3-4" 2 "Age 5" 3 "Ages 6-8"
	label values age_group age_group

	*---------------
	*replace ed7="" if ed7=="don't know"|ed7=="manquante"|ed7=="missing"||ed7=="no aplica"|ed7=="no sabe/nr"
	*gen presch_before=1 if (ed7=="yes"|ed7=="1") & code_ed8a==0
	*tab attend if presch_before==1 // until here it is ok

	*gen attend_primary=1 if attend==1 & (code_ed6a==1|code_ed6a==60|code_ed6a==70)
	*replace attend_primary=0 if attend==1 & code_ed6a==0
	*replace attend_primary=0 if attend==0

	codebook code_ed6a, tab(100) // why does it have the code==9?
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
replace ed3="missing" if ed3=="manquante"
replace ed3="missing" if ed3=="no aplica"
replace ed3="no" if ed3== "no/not yet"
replace ed3="no" if ed3== "oui ens alphabetisation"

replace eduout=1 if ed3=="no" // "out of school" if "ever attended school"=no

replace eduout=1 if code_ed6a==80 // level attended=not formal/not regular/not standard
replace eduout=1 if code_ed6a==90 // level attended=khalwa/coranique (ex. Mauritania, SouthSudan, Sudan)

		
	*Merging with adjustment
	merge m:1 country_year using "$data_mics\hl\mics2_adjustment.dta", keepusing(adj1_norm) nogen
	ren adj1_norm adjustment



*Dropping the B version because it is not going to be used. 
cap drop *_B_ageU *_B_ageB *_B // the version C is the one to keep

*Renaming the vars from _C
foreach var in comp_prim comp_lowsec comp_upsec comp_higher eduyears {
	rename `var'_C `var'
}

gen agestandard=ageU if adjustment==0
replace agestandard=ageA if adjustment==1
cap drop *_ageU *ageA 
drop *_C

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
*drop *_2024_C

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
cap drop country_code*
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
save "C:\Users\Rosa_V\Dropbox\microdata_Bilal\microdata_MICS2.dta", replace





use "$data_mics\hl\Step_4_temp.dta", clear

drop year_folder
drop higher_dur years_prim years_lowsec years_upsec years_higher
drop attend* 
compress
save "$data_mics\hl\MICS2_Step_5", replace


**************************************************************************************************************************************
