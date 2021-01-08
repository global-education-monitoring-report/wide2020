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


global data_mics "C:\Users\Rosa_V\Desktop\data_mics"


*Vars to keep
global vars_mics4 hh1 hh2 hh5* hl1 hl3 hl4 hl5* hl6 hl7 hh6* hh7* ed1 ed3* ed4* ed5* ed6* ed7* ed8* windex5 schage hhweight religion ethnicity region windex5
global list4 hh6 hh7 ed3 ed4a ed4b ed5 ed6b ed6a ed7 ed8a religion ethnicity hh7r ed3x ed4 ed4ax region 
global vars_keep_mics "hhid hvidx hv000 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124"
global categories sex urban region wealth
*global extra_keep ...// for the variables that I want to add later ex. cluster

*****************************************************************************************************
*	Preparing databases to append later (MICS 4 & 5)
*----------------------------------------------------------------------------------------------------


* CREATING INDIVIDUAL DATABASES FOR EACH OF THE COUNTRIES

set more off
include "$aux_programs\survey_list_mics_hl"
foreach file in $survey_list_mics_hl {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_folder = `3'
	
cap rename *, lower
cap label drop HH5_Y HH5 HL5_Y HL5 // for the years of the interview in Mongolia
cap label drop LABC // for Palestine 
if country=="Palestine" & year_folder==2010 {
	cap ren ed4a ed4b // for Palestine -> ed4: shows edulevel, ed4a: years of education
	cap ren ed4 ed4a  // for Palestine ->  ed4: shows edulevel, ed4a: years of education
	cap ren hlweight hhweight // for Palestine 2010
}
if country=="Palestine" & year_folder==2014 {
	drop ed4a ed4b ed6a ed6b ed8a ed8b
	for X in any 4a 4b 6a 6b 8a 8b: cap ren edXp edX 
}
if country=="Jamaica" {
	cap ren hh6b hh7 // for Jamaica  
}

if country=="Mali" & year_folder==2015 {
	drop ed6a
	cap ren ed6n ed6a
	cap ren ed6c ed6b
}

for X in any hh7a hh7r: cap ren X region // for alternatives names of region
for X in any y m d: cap ren hh5_X hh5X
for X in any y m d: cap ren hl5_X hl5X
for X in any region: cap ren X hh7
for X in any 4 6 8: cap ren edX_a edXa 
for X in any 4 6 8: cap ren edX_b edXb 

*For ethnicity & religion

cap ren ethnie ethnicity
cap ren ethnicidad ethnicity

if country=="Mali" & year_folder==2009 {
	cap ren hc1c ethnicity
}
if country=="Panama" & year_folder==2013 {
	cap ren hc1a religion
}
if country=="TrinidadandTobago" & year_folder==2011 {
	cap ren hl15 religion
}
if country=="Uruguay" & year_folder==2012 {
	cap drop windex5
	cap ren windex5_5 windex5
}
if country=="SaintLucia" & year_folder==2012 {
	cap drop windex5
	cap ren windex51 windex5
}

cap drop hh71
cap drop hh72r

for X in any $list4 windex5 schage ed1 hl5y hh5y: cap gen X=.
for X in any ed6b hhweight: cap gen X =. // for Palestine. I am going to fix that country later as special cases

keep $vars_mics4 country year*

for X in any ed8a ed8b: cap gen X=.
for X in any ed4a ed4b ed6a ed6b ed8a ed8b: gen X_nr=X // create the numbers (without labels) for ed4a, ed6b etc
for X in any $list4 : cap decode X, gen(temp_X)
for X in any ed3 ed7 ed5: cap tostring X, gen(temp_X) // for Palestine
drop $list4 
for X in any $list4 : cap ren temp_X X
cap label drop _all
compress
save "$data_mics\hl\countries\\`1'`3'", replace
}

********************************************************************************
* 	Appending all the databases
********************************************************************************

cd "$data_mics\hl\countries"
local allfiles : dir . files "*.dta"
use "Iraq2011.dta", clear
gen id_c=1

foreach f of local allfiles {
	qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

*Drop unnecessary variables
drop hh6r hh7a1 hh7a2
*drop ed7 ed8a ed8b //Variables for previous school year (not available for all country years)
drop ed8b //Variables for previous school year (not available for all country years)

order country year_folder hh1 hh2 hl1 hl3 hl4 hl5d hl5m hl5y hl7 ed1 ed3 ed4a ed4a_nr ed4b ed4b_nr ///
ed5 ed6a ed6a_nr ed6b ed6b_nr hh6 hh7 region ethnicity religion hhweight windex5 schage 
drop ed4ame-ed8c

compress
save "$data_mics\hl\hl_append_mics_4&5.dta", replace


**************************************************************************
*	Translate
**************************************************************************
set more off
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics\hl"
unicode analyze "hl_append_mics_4&5.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "hl_append_mics_4&5.dta"


*************************************************************************
*	Creating categories
**************************************************************************

use "$data_mics\hl\hl_append_mics_4&5.dta", clear
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
	drop hh1* hh2 hl1 hl7 ed1
	*codebook individual_id // uniquely identifies people
	
	*Need info interview for Thailand. It is in the hh module
	merge m:1 hh_id using "$data_raw_mics\Thailand\dates.dta", update
	drop if _merge==2
	drop _merge
	*drop hh_id 
	
*	YEAR OF THE SURVEY:  "Official" Year of the survey (interview) is hh5y. 
* 	Inteview date:  hh5y=year; hh5m=month; hh5d=day  
	replace hh5y=year_folder if country_year=="Nepal_2014" // year for Nepal is 2070 and 2071...
	recode hh5m (11=2) (12=3) (1=4) (2=5) (3=6) if country_year=="Nepal_2014" // changes months for Nepal (different system)

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
	replace urban=0 if (hh6=="rural"|hh6=="rural coastal"|hh6=="rural interior"|hh6=="rural with road"|hh6=="rural without road"|hh6=="rural y menores de 5 mil habitantes"|hh6==""|hh6=="non-municipal")
	replace urban=1 if (hh6=="urbain"|hh6=="urban"|hh6=="urbana"|hh6=="urbano"|hh6=="municipal")
	replace urban=1 if hh6=="kma" & country=="Jamaica"
	replace urban=1 if hh6=="capital city"|hh6=="aimag center"|hh6=="soum center" // for Mongolia
	replace urban=2 if (hh6=="camp"|hh6=="camps") // In Palestine

label define urban 0 "rural" 1 "urban" 2 "camps"
label values urban urban

*Wealth
ren windex5 wealth

*Weight: already named hhweight

*codebook ethnicity, tab(200)

*Fixes regions, ethnicity, religion
include "$aux_programs\regions_mics4&5"
include "$aux_programs\ethnicity_religion_mics4&5"

drop hl3
compress
save "$data_mics\hl\Step_0.dta", replace


***************************************************************************************************************************************************************
***************************************************************************************************************************************************************

use "$data_mics\hl\Step_0.dta", clear
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
 
foreach var of varlist ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a {
	replace `var'=lower(`var')
	replace `var'=stritrim(`var')
	replace `var'=strltrim(`var')
	replace `var'=strrtrim(`var')
}

foreach var of varlist ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a {
	replace `var' = "no" if (`var'=="nao"|`var'=="non")
	replace `var' = "yes" if (`var'=="si"|`var'=="sim"|`var'=="oui")
	replace `var' = "missing" if (`var'=="em falta"|`var'=="manquant"|`var'=="omitido"|`var'=="no reportado")
	replace `var' = "doesn't answer" if (`var' =="nr"|`var'=="non declare/pas de reponse"|`var'=="no responde")
	replace `var' = "don't know" if (`var'=="dk"|`var'=="no sabe"|`var'=="nao sabe"|`var'=="ns"|`var'=="ne sait pas"|`var'=="nsp")
	replace `var' = "inconsistent" if (`var'=="inconsistente"|`var'=="incoherent"|`var'=="incoherence"|`var'=="incoherencia"|`var'=="incoherente")
	replace `var' = "" if (`var'==".")
}
*-----------------------------------------------------------------------------------------------------------

** RECODING ED3 "ever attended school or pre-school?
*	Only for Palestine_2010: values of ed3 = 0, 3, 4, 8: 
*				0=Currently attending kindergarten; 1=Currently attending school; 2=attended school and dropped out
*				3=attended school and graduated; 4=never attended school, 8=don't know

	replace ed3="yes" if (ed3=="0"|ed3=="1"|ed3=="2"|ed3=="3") & country_year=="Palestine_2010"
	replace ed3="no" if (ed3=="4") & country_year=="Palestine_2010"
	replace ed3="don't know" if (ed3=="8") & country_year=="Palestine_2010"

** RECODING ED5 "Currently attending school"
*	Only for Palestine 2010, values of ed5 = 1, 2, 9 -->   1=yes, 2=no, 9=missing
	replace ed5="yes" if ed5=="1" &  country_year=="Palestine_2010"
	replace ed5="no" if ed5=="2" & country_year=="Palestine_2010"
	replace ed5="missing" if ed5=="9" & country_year=="Palestine_2010"
	
*for X in any ed3 ed4a ed4b ed5 ed6a ed6b ed7 ed8a: codebook X, tab(100)

*---- 2) Creation of the new var & recoded: Re-codify the levels of ed4a & ed6a according to the NEW value labels

for X in any ed4a ed6a ed8a: gen code_X=X_nr

* The standard edulevel label for ed4a is : 0 "preschool" 1 "primary" 2 "secondary" 3 "higher" 8 "don't know" 9 "missing/doesn't answer" 
* The NEW value label for edulevel to be applied to code_ed4a

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
	
* Case 1) Countries that have same as the standard edulevel code (0=preschool, 1=primary, 2=secondary, 3=higher).
* 		  I only need to recode (8=98) (9=99). Do it for all country years:

* Case 2) Countries that need recoding of the edulevel to be in line with the NEW value labels
foreach var of varlist code_ed4a code_ed6a code_ed8a {
	recode `var' (2=21) (3=22) (4=3) if country_year=="Algeria_2012"
	
	recode `var' (0/2=0) (3=1) (4=2) (5=32) (6=3) if country_year=="Barbados_2012"
	recode `var' (2=21) (3=22) (4/5=24) (6=3) if country_year=="Belarus_2012"
	recode `var' (2=21) (4=22) (5=3) (6=23) (7=1) if country_year=="Belize_2011"
	recode `var' (2=1) (3=21) (4=22) (5=3) (96=80) if country_year=="Belize_2015"
	recode `var' (2=21) (3=22) (4=3) if country_year=="Benin_2014"
	recode `var' (2/4=2) (5=3) if country_year=="Bhutan_2010"
	recode `var' (1=70) (2=22) if country_year=="BosniaandHerzegovina_2011"
	
	recode `var' (2=21) (3/4=24) (5=3) if (country_year=="Cuba_2010"|country_year=="Cuba_2014")
	recode `var' (2=21) (3/4=24) (5=3) if (country_year=="Cuba_2010"|country_year=="Cuba_2014")
	
	recode `var' (1=70) (2=22) if country_year=="DominicanRepublic_2014" // ed4a=1 included both primary and lower secondary
	
	recode `var' (10=0) (11=1) (12=21) (13/14=22) (15=32) (16=3) (17=50) if country_year=="ElSalvador_2014"
	
	recode `var' (2=21) (3=22) (4=24) (5=32) (6=3) if country_year=="Ghana_2011"
	recode `var' (4=24) if country_year=="Guinea-Bissau_2014"
	
	recode `var' (3=2) (4=33) (5=3) (6=40) (7=80) if country_year=="Iraq_2011" //changed	
	
	recode `var' (3=24) (4=3) if country_year=="Kazakhstan_2010"
	recode `var' (2=21) (3=22) (4=24) (5=3) if country_year=="Kazakhstan_2015"
	recode `var' (2=21) (3=22) (4/5=33) (6=3) if country_year=="Kyrgyzstan_2014"
	
	recode `var' (2=21) (3=22) (4=32) (5=3) if country_year=="LaoPDR_2011"
	
	recode `var' (2=21) (3=22) (4=3) if country_year=="Mali_2009"
	recode `var' (2=21) (3=22) (4=24) (5=3) if country_year=="Mali_2015"
	recode `var' (3=2) (4=3) (5/6=90) if country_year=="Mauritania_2011"
	recode `var' (4/5=90) if country_year=="Mauritania_2015"
	recode `var' (2=21) (3/4=22) (5=23) (6=24) (7=33) (8/9=3) (10/11=40) if country_year=="Mexico_2015"
	recode `var' (1=60) (2=24) (3=3) (4=80) if country_year=="Mongolia_2010"
	recode `var' (2=60) (3=24) (4=3) if country_year=="Mongolia_2013"
	recode `var' (1=70) (2=22) if country_year=="Montenegro_2013"
	
	recode `var' (4=80) if (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")

	recode `var' (1=70) (2=22) if country_year=="Palestine_2014"
	recode `var' (1=0) (2=50) (3=1) (4=24) (5=2) (6=32) (7=3) (8/10=40) if country_year=="Panama_2013"
	recode `var' (0/1=50) (2=0) (3=1) (4=21) (5=22) (6=32) (7=3) if country_year=="Paraguay_2016"

	*recode `var' (2=21) (3=22) (4/5=24) (6=3) if country_year=="RepublicofMoldova_2012" // plyvatent/PTS & College/technical as Upper secondary...Problems to classify technical?
	recode `var' (2=21) (3=22) (4=24) (5=33) (6=3) if country_year=="RepublicofMoldova_2012" // plyvatent/PTS as Upper secondary. "College/technical" as higher

	recode `var' (0/1=0) (2=70) (3=22) (4=3) if (country_year=="Serbia_2010"|country_year=="Serbia_2014") // changed from before
	recode `var' (0=90) (1=0) (2/4=70) (5/9=22) (10=32) (11=3) (12=40) if country_year=="Sudan_2014"
	recode `var' (2=50) (3=21) (4=22) (5=50) (6=3) (7=80) if country_year=="Suriname_2010"
	recode `var' (2=21) (3=22) (4=3) if (country_year=="Swaziland_2010"|country_year=="Swaziland_2014")
	
	recode `var' (1=70) (2=22) if country_year=="TFYRMacedonia_2011"
	recode `var' (2=21) (3=22) (4=24) (5=33) (6=3) (7/8=40) if country_year=="Thailand_2012" // changed after checking the codes and durations. Be careful with this way of presenting ed4b vs ed4a
	recode `var' (3/5=3) (6/7=40) if country_year=="Thailand_2015"
	recode `var' (2=21) (3=22) (4=3) if country_year=="Togo_2010"
	recode `var' (3=24) (4=3) if country_year=="TrinidadandTobago_2011"
	*recode `var' (2=21) (3=22) (4=3) (5/7=24) if country_year=="Tunisia_2011"
	recode `var' (2=21) (3=22) (4=3) (5/6=24) (7=33) if country_year=="Tunisia_2011"
	recode `var' (1=60) (2/3=32) (4=3) if country_year=="Turkmenistan_2015"
	
	recode `var' (3/4=24) (5=3) if country_year=="Ukraine_2012"
	recode `var' (3=2) (4=33) (5=3) if country_year=="Uruguay_2012" // changed
	
	recode `var' (2=21) (3=22) (4/5=3) if (country_year=="VietNam_2010"|country_year=="VietNam_2013")
}
* Special cases for ed6a: categories ed4a != categories ed6a.
*	Palestine_2010, SaintLucia_2012, SouthSudan_2010, Sudan_2010, Sudan_2014 (checked that Sudan 2014 is not different coding: Assas=Basic Education)


	replace code_ed6a=70 if ed6a_nr==1 & country_year=="Palestine_2010"
	replace code_ed6a=22 if ed6a_nr==2 & country_year=="Palestine_2010"

	recode code_ed4a (1=70) (2=21) (3=2) (4=32) (5=3) if country_year=="SaintLucia_2012"
	recode code_ed6a (1=1) (3=2) (4=32) (5=3) if country_year=="SaintLucia_2012"
	recode code_ed8a (1=1) (2=21) (3=2) (4=32) (5=3) if country_year=="SaintLucia_2012"

	recode code_ed4a (1=70) (2=21) (3=22) (4=32) (5=3) (6=40) (7=90) (8=51) if country_year=="Sudan_2010"
	for X in any code_ed6a code_ed8a: recode X (1=70) (2=22) (3=32) (4=3) (5=40) (6=90) (7=51) if country_year=="Sudan_2010"
	
	recode code_ed4a (1=70) (2=21) (3=22) (4=32) (5=3) (6=40) (7=90) (8=51)  if country_year=="SouthSudan_2010"
	for X in any code_ed6a code_ed8a: recode X (1=70) (2=22) (3=32) (4=3) (5=40) (6=90) (7=51)  if country_year=="SouthSudan_2010"

 *Nigeria: 
	replace code_ed4a=40 if ed4b_nr==43 & country_year=="Nigeria_2011"  // for those "higher than higher"
	replace code_ed4a=40 if ed4b_nr==36 & country_year=="Nigeria_2016"  // for those "higher than higher"
		

*Changes according to UIS (agreed with Bilal)
	for X in any 4 6 8: replace code_edXa=21 if edXa_nr==4 & (edXb_nr==0|edXb_nr==1|edXb_nr==2|edXb_nr==3) & country_year=="Uruguay_2012"
	for X in any 4 6 8: replace code_edXa=22 if edXa_nr==4 & (edXb_nr==4|edXb_nr==5|edXb_nr==6) & country_year=="Uruguay_2012"
	
	for X in any 4 6 8: replace code_edXa=22 if edXa_nr==4 &(edXb_nr==0|edXb_nr==1|edXb_nr==2|edXb_nr==3) & country_year=="Iraq_2011"
	for X in any 4 6 8: replace code_edXa=33 if edXa_nr==4 &(edXb_nr==4|edXb_nr==5) & country_year=="Iraq_2011"

	for X in any 4 6 8: replace code_edXa=22 if (edXa_nr==4|edXa_nr==5) & (edXb_nr==0|edXb_nr==1|edXb_nr==2) & country_year=="Kyrgyzstan_2014"
	for X in any 4 6 8: replace code_edXa=33 if (edXa_nr==4|edXa_nr==5) & (edXb_nr==3|edXb_nr==4) & country_year=="Kyrgyzstan_2014"		
		
		
 * Recode for all country_years. I don't need to do it later again
	for X in any ed4a ed6a ed8a: replace code_X=97 if (X=="inconsistent")
	for X in any ed4a ed6a ed8a: replace code_X=98 if X=="don't know"
	for X in any ed4a ed6a ed8a: replace code_X=99 if (X=="missing"|X=="doesn't answer"|X=="missing/dk")

* Putting labels to the values
	for X in any code_ed4a code_ed6a code_ed8a: label values X edulevel_new 
	
compress
save "$data_mics\hl\Step_0_temp.dta", replace
*****************************************************



/*
** BILAL'S REQUEST

use "$data_mics\hl\Step_0_temp.dta", clear
keep ed5 ed6* code_ed6* country* *age hhweight 
order country* age *weight
replace schage=age if schage==. // Cuba, south sudan, sudan

*codebook ed5 code_ed6a, tab(100) 

codebook ed5

gen attend=0 if ed5=="no" 
replace attend=1 if ed5=="yes"
replace attend=0 if (code_ed6a==50|code_ed6a==80)
tab attend

recode attend (0=1) (1=0), gen (no_attend)

*br if code_ed6a==. & attend==1 // nepal 2014 has levels in other variable

*bys schage: tab attend
*tab code_ed6a attend if schage==10, m

*All levels
gen a_preschool=1 if inlist(code_ed6a, 0) 
gen a_primary=1 if inlist(code_ed6a,1)
gen a_secondary=1 if inlist(code_ed6a, 2)
gen a_lowsec=1 if inlist(code_ed6a, 21, 23)
gen a_upsec=1 if inlist(code_ed6a, 22, 24)
gen a_higher=1 if inlist(code_ed6a, 3, 32, 33, 40)
*Others
gen a_general=1 if inlist(code_ed6a, 60)
gen a_primlow=1 if inlist(code_ed6a, 70)
gen a_khalwa=1 if inlist(code_ed6a, 90)

foreach var in preschool primary secondary lowsec upsec higher general primlow khalwa { 
	gen attend_`var'=0 if attend==1
	replace attend_`var' =1 if a_`var'==1 & attend_`var' ==0
	replace attend_`var'=. if (attend==.|code_ed6a==.)
}

drop if schage>=100 |schage==-1
collapse (mean) no_attend attend* [weight=hhweight], by(country_year schage)
export delimited using "$data_mics/MICS_age_attendance.csv", replace
save "$data_mics/MICS_age_attendance.dta", replace

egen tot=rowtotal(attend_preschool-attend_khalwa)
tab tot

*/


use "$data_mics\hl\Step_0_temp.dta", clear
set more off
bys country_year: egen year=median(hh5y)

*merge with information of duration of levels, school calendar, official age for primary, etc:
	rename country country_name_mics
	merge m:m country_name_mics using "$aux_data\country_iso_codes_names.dta" // to obtain the iso_code3
	drop if _merge==2
	drop country_name_mics country_name_WIDE iso_code2 iso_numeric country_name_dhs _merge
	merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	drop if _m==2
	drop _merge
	drop lowsec_age_uis upsec_age_uis
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
	ren prim_age_uis prim_age0
	gen higher_dur=4 // provisional
	
	*CHANGES IN DURATION
	replace upsec_dur=3 	if country_year=="BosniaandHerzegovina_2011" // UIS suggested this change
	replace lowsec_dur=3	if (country_year=="Mauritania_2011"|country_year=="Mauritania_2015") // checked with UIS
	*For Mongolia, upsec_dur=2 for Mongolia_2010, but Mongolia_2013 we take upsec=3 as suggested by UIS
	*replace prim_dur=4 if prim_dur==5 & country_year=="Mongolia_2010"|country_year=="Mongolia_2013"
	replace prim_dur=4 		if country_year=="Montenegro_2013"
	replace prim_dur=4 		if country_year=="TFYRMacedonia_2011"
	replace prim_dur=3 		if country_year=="Turkmenistan_2015"
	replace lowsec_dur=5 	if country_year=="Turkmenistan_2015"	
	
	*CHANGES IN START AGE
	replace prim_age0=7 	if country_year=="TFYRMacedonia_2011"
	replace prim_age0=7 	if country_year=="Montenegro_2013" 
		
*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur

compress
save "$data_mics\hl\Step_1.dta", replace




*******************************************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************************************


/*

*count if ed4a=="missing"|ed4a=="doesn't answer"|ed4a=="don't know"
*tab code_ed4a if (ed4a=="missing"|ed4a=="doesn't answer"|ed4a=="don't know"|ed4a=="missing/dk")
*tab ed4a if code_ed4a==98|code_ed4a==99


use "$data_mics\hl\Step_1.dta", clear

	for X in any ed4a ed6a: decode code_X, gen(code_X_label)
	for X in any ed4a ed6a: gen code_X_full1	=string(code_X)+" "+code_X_label
	for X in any ed4b ed6b: gen X_full1	=string(X_nr, "%02.0f")+" "+X // so that the string for ed4b_nr has a leading zero

	cap log close
	log using "$data_mics\hl\logs\1_RECODED ed4a vs ed4b.log", replace
	bys country_year: tab ed4b_full1 code_ed4a_full1, m
	log close
	
	cap log close
	log using "$data_mics\hl\logs\1_RECODED ed6a vs ed6b.log", replace
	bys country_year: tab ed6b_full1 code_ed6a_full1, m
	log close
	
*/	


*******************************************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************************************


use "$data_mics\hl\Step_1.dta", clear
set more off
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

*Countries that have levels 21, 22, etc

*-------------------------------------------------------------------------------------------------------
*--1a) The Stairs are already created and I don't need to do other changes: Afghanistan_2010, ElSalvador_2014
	replace eduyears=ed4b if country_year=="Afghanistan_2010"
	
	replace eduyears=ed4b if country_year=="ElSalvador_2014"
	replace eduyears=. if code_ed4a==50 & country_year=="ElSalvador_2014"

*-------------------------------------------------------------------------------------------------------
*--1b) STAIRS AND HAS INFO OF YEAR IN HIGHER ED
* Cameroon_2014
	replace eduyears=ed4b-10 if ed4b>=11 & ed4b<=16 & country_year=="Cameroon_2014"
	replace eduyears=ed4b-14 if ed4b>=21 & ed4b<=27 & country_year=="Cameroon_2014"
	replace eduyears=ed4b-17 if ed4b>=31 & ed4b<=35 & country_year=="Cameroon_2014"
	replace eduyears=0 if (ed4b_label=="moins d'un an au primaire"|ed4b_label=="moins d'un an au secondaire" |ed4b_label=="moins d'un an a l'universite") & country_year=="Cameroon_2014"
	
* CentralAfricanRepublic_201
	replace eduyears=ed4b if ed4b>=0 & ed4b<=20 & country_year=="CentralAfricanRepublic_2010"
	replace eduyears=ed4b-7 if ed4b>=21 & ed4b<=23 & country_year=="CentralAfricanRepublic_2010"
	replace eduyears=ed4b-18 if ed4b==32 & country_year=="CentralAfricanRepublic_2010" //following value labels
	replace eduyears=ed4b-27 if ed4b>=41 & ed4b<=43 & country_year=="CentralAfricanRepublic_2010" //following value labels
	replace eduyears=ed4b-37 if ed4b>=52 & ed4b<=55 & country_year=="CentralAfricanRepublic_2010" //following value labels
	
* Nigeria 2011 & 2016: Need to check the value labels of ed4b
	*- Nigeria 2011: Codes were in the value labels for ed4b
	*- Nigeria 2016: Codes extracted from the questionnaire: 
		*30 (same as 2011) =Never completed NCE, AL, OND, Higher Technical , HND, BSc. 
		*31 (same as 2011) = NCE  
		*32 (same as 2011) =AL/OND  
		*33 (same as 2011)= Higher Technical/TTC  
		*34 (in 2011 was code 41)= HND
		*35 (in 2011 was code 42)= BSC 
		*36 (in 2011 was code 43)= Post Graduate

	replace eduyears=0 if ed4b>=1 & ed4b<=3 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	replace eduyears=ed4b-10 if ed4b>=10 & ed4b<=16 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	replace eduyears=ed4b-14 if ed4b>=20 & ed4b<=26 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	replace eduyears=years_upsec if ed4b==30 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")

	replace eduyears=years_upsec+2 if ed4b==31 & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	replace eduyears=years_upsec+3 if (ed4b==32|ed4b==33) & (country_year=="Nigeria_2011"|country_year=="Nigeria_2016")
	
	replace eduyears=years_upsec if ed4b==40 & country_year=="Nigeria_2011" // ??

	replace eduyears=years_upsec+2 	if (ed4b==41 & country_year=="Nigeria_2011")|(ed4b==34 & country_year=="Nigeria_2016")
	replace eduyears=years_higher 	if (ed4b==42 & country_year=="Nigeria_2011")|(ed4b==35 & country_year=="Nigeria_2016")
	replace eduyears=years_higher+2 if (ed4b==43 & country_year=="Nigeria_2011")|(ed4b==36 & country_year=="Nigeria_2016")  // those higher than higher
	

	* LaoPDR_2011
	replace eduyears=ed4b-10 if ed4b>=11 & ed4b<=15 & country_year=="LaoPDR_2011"
	replace eduyears=ed4b-15 if ed4b>=21 & ed4b<=24 & country_year=="LaoPDR_2011"
	replace eduyears=ed4b-21 if ed4b>=31 & ed4b<=33 & country_year=="LaoPDR_2011"
	replace eduyears=ed4b-28 if ed4b>=41 & ed4b<=43 & country_year=="LaoPDR_2011"
	replace eduyears=ed4b-38 if ed4b>=51 & ed4b<=57 & country_year=="LaoPDR_2011"

*--1b.1) *** SPECIAL CASE: STAIRS AND HAS INFO OF YEAR IN HIGHER ED 

	*	Palestine 2010: According to 2016 WIDE version
	replace code_ed4a=1 if ed4b<=years_prim & country_year=="Palestine_2010"
	replace code_ed4a=2 if ed4b>years_prim & ed4b<=years_upsec & country_year=="Palestine_2010"
	replace code_ed4a=3 if ed4b>years_upsec & ed4b<. & ed4b<97 & country_year=="Palestine_2010"
	replace code_ed4a=0 if (ed3=="currently attending kindergarten"|ed3=="never attended school") & country_year=="Palestine_2010"

	replace eduyears=ed4b if country_year=="Palestine_2010"
	
*-------------------------------------------------------------------------------------------------------
*--1c) STAIRS BUT DOESN'T SAY HOW MANY YEARS IN HIGHER ED

*Vietnam 2010, Vietnam 2013 (no value labels for ed4b)
foreach country_year in VietNam_2010 VietNam_2013 {
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==21|code_ed4a==22) & country_year=="`country_year'" 
	replace eduyears=years_upsec+0.5*higher_dur if code_ed4a==3 & country_year=="`country_year'" // no info on ed4b about years completed in higher. ask about this assumption!!
}

* Zimbabwe 2014: changes according to labels of ed4b
	replace code_ed4a=50 if (ed4b==10|ed4b==20) & country_year=="Zimbabwe_2014" // special primary and special secondary
	replace eduyears=ed4b-10 if ed4b>=11 & ed4b<=17 & country_year=="Zimbabwe_2014"
	replace eduyears=ed4b-13 if ed4b>=21 & ed4b<=26 & country_year=="Zimbabwe_2014"
	replace eduyears=years_upsec+0.5*higher_dur if ed4b_label=="attended/currently attending higher education" & country_year=="Zimbabwe_2014" // attended, currently attending higher education (+0.5*higher_dur?)
	replace eduyears=years_higher if ed4b_label=="completed higher education" & country_year=="Zimbabwe_2014" // Completed higher education
	replace eduyears=. if code_ed4a==50 & country_year=="Zimbabwe_2014" 

*-------------------------------------------------------------------------------------------------------

*need to recode Kazakhstan_2015! Vocational is 33 not 24?? Republic of Moldova needs the same adjustment?

*--1d) STAIRS UNTIL SECONDARY + FLAT FOR HIGHER (has info on years higher)

foreach country_year in Jamaica_2011 Kazakhstan_2015 SaoTomeandPrincipe_2014 {
	*Stairs for higher
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==21|code_ed4a==22|code_ed4a==23) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'"
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"
}

	replace eduyears=ed4b+years_lowsec if (code_ed4a==24) & country_year=="Kazakhstan_2015"
	
	*Special case: Kyrgyzstan_2014
	replace eduyears=ed4b if (ed4a_nr==0|ed4a_nr==1|ed4a_nr==2|ed4a_nr==3) & country_year=="Kyrgyzstan_2014"
	replace eduyears=ed4b+years_lowsec if (ed4a_nr==4|ed4a_nr==5) & (ed4b==0|ed4b==1|ed4b==2) & country_year=="Kyrgyzstan_2014"
	replace eduyears=ed4b+years_upsec if (ed4a_nr==4|ed4a_nr==5) & (ed4b==3|ed4b==4) & country_year=="Kyrgyzstan_2014"
	replace eduyears=ed4b+years_upsec if (ed4a_nr==6) & country_year=="Kyrgyzstan_2014"
		
	
*** Belarus: flat for upper secondary
foreach country_year in Belarus_2012 {
	*Stairs for higher
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==21|code_ed4a==22) & country_year=="`country_year'"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==24) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="`country_year'"
}

	
*--1e) STAIRS + FLAT FOR UPSEC onwards (has info on years higher)
foreach country_year in Paraguay_2016 Ukraine_2012 {
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==2|code_ed4a==21) & country_year=="`country_year'"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32) & country_year=="`country_year'"
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"
}

*-----------------------------------------------------------------------------------------------------------
*2) For those FLAT
*-----------------------------------------------------------------------------------------------------------

*		2a) FLAT with years in higher ed

foreach country_year in Algeria_2012 Bangladesh_2013 Barbados_2012 Belize_2011 Belize_2015 Benin_2014 BosniaandHerzegovina_2011 ///
	Chad_2010 CostaRica_2011 CotedIvoire_2016 Cuba_2010 Cuba_2014 DominicanRepublic_2014 DRCongo_2010 ///
	Guinea-Bissau_2014 Guyana_2014 Iraq_2011 Kazakhstan_2010 ///
	Mali_2009 Mali_2015 Mauritania_2011 Mauritania_2015 Mexico_2015 Montenegro_2013 Mongolia_2010 Mongolia_2013 ///
	Panama_2013 Palestine_2014 SaintLucia_2012 Serbia_2010 Serbia_2014 SierraLeone_2010 Sudan_2014 Suriname_2010 Swaziland_2010 Swaziland_2014 ///
	TFYRMacedonia_2011 Thailand_2012 Thailand_2015 Togo_2010 TrinidadandTobago_2011 Tunisia_2011 Turkmenistan_2015 Uruguay_2012 {

	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==60|code_ed4a==70) & country_year=="`country_year'"	// code_ed4a=70 for DominicanRepublic_2014
	replace eduyears=ed4b+years_prim if (code_ed4a==2|code_ed4a==21|code_ed4a==23) & country_year=="`country_year'" // for Belize 2011 (ed4a=23)
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="`country_year'"  // for Swaziland_2010 & Swaziland_2014 & Tunisia 2011, Kazakhstan_2010 
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==32|code_ed4a==33) & country_year=="`country_year'" // for Mexico_2015
	replace eduyears=ed4b+years_higher if (code_ed4a==40) & country_year=="`country_year'"  // Iraq, Thailand, Mexico have "higher than higher"
}
	
	replace eduyears=years_prim if ed4b_label=="primary school of nfeep" & country_year=="Mongolia_2013"
	replace eduyears=years_lowsec if ed4b_label=="basic school of nfeep" & country_year=="Mongolia_2013"
	replace eduyears=years_prim if ed4b_label=="high school of nfeep" & country_year=="Mongolia_2013"
	
* Mauritania_2011 // problems with secondary duration!=ISCED. Coranique is preschool?
		
*		2a.2) Special cases

	*Thailand 2012: flat but stairs in secondary
	replace eduyears=ed4b+years_lowsec-3 if code_ed4a==22 & country_year=="Thailand_2012" // has stairs in upsec 
	
	*Ghana_2010: taken out because it has a lot of obs that are higher than prim_dur
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="Ghana_2011"
	replace eduyears=ed4b+years_prim if (code_ed4a==21) & country_year=="Ghana_2011"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22|code_ed4a==24) & country_year=="Ghana_2011" 
	replace eduyears=ed4b+years_upsec if (code_ed4a==3) & country_year=="Ghana_2011" 

	* Malawi_2013:
	replace eduyears=ed4b if (code_ed4a==1) & country_year=="Malawi_2013"
	replace eduyears=ed4b+8 if (code_ed4a==2) & country_year=="Malawi_2013" // need to add plus 8, as that is what the data shows. Duration not consistent with ISCED
	replace eduyears=ed4b+years_lowsec if (code_ed4a==3) & country_year=="Malawi_2013" 
	
*	RepublicofMoldova_2012
	replace eduyears=ed4b if (code_ed4a==1|code_ed4a==21|code_ed4a==22) & country_year=="RepublicofMoldova_2012"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==24) & country_year=="RepublicofMoldova_2012"
	replace eduyears=ed4b+years_upsec if (code_ed4a==3|code_ed4a==33) & country_year=="RepublicofMoldova_2012"

*  	Sudan_2014
foreach country_year in Sudan_2014 {
	replace eduyears=years_higher+2 if (code_ed4a==40) & country_year=="`country_year'"
}
	
*		2a.2) FLAT without years in higher ed

*  	SouthSudan_2010 Sudan_2010 

foreach country_year in SouthSudan_2010 Sudan_2010 {
	replace eduyears=ed4b if (code_ed4a==70) & country_year=="`country_year'"
	replace eduyears=ed4b+years_prim if (code_ed4a==21) & country_year=="`country_year'"
	replace eduyears=ed4b+years_lowsec if (code_ed4a==22) & country_year=="`country_year'"
	replace eduyears=years_upsec+0.5*higher_dur if (code_ed4a==3) & country_year=="`country_year'"
	replace eduyears=years_upsec+0.2*higher_dur if (code_ed4a==32) & country_year=="`country_year'"
	replace eduyears=years_higher+2 if (code_ed4a==40) & country_year=="`country_year'"
}
	
* 2b) Flatish....

*Case: Bhutan 2010 (according to labels)
	replace code_ed4a=3 if (ed4b_label=="bachelor"|ed4b_label=="diploma") & country_year=="Bhutan_2010"
	replace code_ed4a=40 if (ed4b_label=="master"|ed4b_label=="> master") & country_year=="Bhutan_2010"
	replace code_ed4a=0 if ed4b_label=="pre primary" & country_year=="Bhutan_2010"

	replace eduyears=ed4b+1 if country_year=="Bhutan_2010"
	replace eduyears=0 if ed4b_label=="no grade" & country_year=="Bhutan_2010" // check category 17


*============
* Others

*Case: DominicanRepublic_2014 // added to flat (need to check duration!)
*Case: Iraq_2011 //added to flat
	
* Case: Nepal 2014
	replace eduyears=ed4b if (ed4b>=0 & ed4b<=10) & country_year=="Nepal_2014"
	replace eduyears=10 if ed4b_label=="slc" & country_year=="Nepal_2014"
	replace eduyears=years_upsec if ed4b_label=="plus 2 level" & country_year=="Nepal_2014"
	replace eduyears=years_higher if ed4b_label=="bachelor" & country_year=="Nepal_2014"
	replace eduyears=years_higher+2 if ed4b_label=="masters" & country_year=="Nepal_2014"
	replace eduyears=0 if ed4b_label=="preschool" & country_year=="Nepal_2014"

	
	*----------------------------------------------
	*** DO THIS FOR ALL
	*----------------------------------------------
	
	* Recode for all country_years. I don't need to do it later again
	replace eduyears=97 if (ed4b==97|ed4b_label=="inconsistent")
	replace eduyears=98 if (ed4b==98|ed4b_label=="don't know")
	replace eduyears=99 if (ed4b==99|ed4b_label=="missing"|ed4b_label=="doesn't answer"|ed4b_label=="missing/dk")
	
	*Super important step (FOR ALL)
	replace eduyears=0 if ed4b==0 // this keeps the format for version B
	
		
cap drop t temp
compress
save "$data_mics\hl\Step_2.dta", replace
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


*--------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
****************************************************
** 		AGE ADJUSTMENT
****************************************************

set more off
use "$data_mics\hl\Step_2.dta", clear
merge m:1 country_year using "$aux_data\temp\current_school_year_MICS.dta" // current school year that ED question in MICS refers to
drop if _merge==2 
drop _merge

* CURRENT SCHOOL YEAR
	tab country_year if current=="doesn't have the variable" //for Cuba
	replace current="" if current=="doesn't have the variable"
	destring current, replace

*	YEAR OF THE SURVEY:  "Official" Year of the survey (interview) is hh5y. 
* 	Inteview date:  hh5y=year; hh5m=month; hh5d=day  
*---------------------------------------
* Median of month
*---------------------------------------
*Creates date


cap drop month* // drop old values
gen year_c=hh5y	
merge m:m iso_code3 year_c using "$aux_data\UIS\months_school_year\month_start.dta"
drop if _merge==2
drop _merge max_month min_month diff

*Check if all countries have month_start:
tab country_year if month_start==.

*For those with missing in school year, I replace by the interview year
tab country_year if current_school_year==. // Cuba
replace current_school_year=hh5y if current_school_year==.

*------------------------------
** COPIED FROM DHS
*------------------------------

	gen s_school=string(month_start)+"/"+string(current_school_year)
	gen s_interview=string(hh5m)+"/"+string(hh5y) // date of the interview created with the original info

	gen date_school=date(s_school, "MY",2000) // official month of start... plus school year of reference
	gen date_interview=date(s_interview, "MY",2000)
	
	replace current_school_year=current_school_year-1 if date_interview-date_school<0  // to fix the negative differences!!
	*replace current_school_year=current_school_year+1 if (date2-date1>=12) // to fix the differences greater than 12.	
	*br if date_interview-date_school<0
		
	drop s_* date_*
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
	bys country_year: egen median_diff`X'_`M'=median(diff`X'_`M')
	gen adj`X'_`M'=0
	replace adj`X'_`M'=1 if median_diff`X'_`M'>=182
}
}

sort country_year
collapse diff* adj* flag_month, by(country_year)		
save "$data_mics\hl\mics4&5_adjustment.dta", replace
*/

*********************************************************************************************************


use "$data_mics\hl\Step_2.dta", clear
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
save "$data_mics\hl\Step_4.dta", replace

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

use "$data_mics\hl\Step_4.dta", clear
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


*Especial cases: Barbados 2012, Nepal 2014
gen eduout_nepal2014=no_attend
replace eduout_nepal2014=. if (ed6b=="missing"|ed6b=="don't know") & eduout_nepal2014==0
replace eduout_nepal2014=1 if ed6b=="preschool"
replace eduout_nepal2014=1 if ed3=="no"

replace eduout=eduout_nepal2014 if country_year=="Nepal_2014"
drop eduout_nepal2014

gen eduout_barbados=no_attend
replace eduout_barbados=. if (attend==1 & code_ed6a==.)
replace eduout_barbados=. if (code_ed6a==98|code_ed6a==99) & eduout_barbados==0
replace eduout_barbados=. if ed6a_nr==0 // level attended: goes to preschool
replace eduout_barbados=1 if ed3=="no"

replace eduout=eduout_barbados if country_year=="Barbados_2012"
drop eduout_barbados

*Mauritania 2011
 gen attend_mauritania=0
 replace attend_mauritania=1 if ed5=="yes"
 replace attend_mauritania=. if ed5=="missing"

recode attend_mauritania (1=0) (0=1), gen(eduout_mauritania)
replace eduout_mauritania=. if (code_ed6a==98|code_ed6a==99) & eduout_mauritania==0
replace eduout_mauritania=1 if code_ed6a==0 // goes to preschool
replace eduout_mauritania=1 if ed3=="no"

replace eduout=eduout_mauritania if country_year=="Mauritania_2011"

drop attend_mauritania eduout_mauritania

	*Merging with adjustment
merge m:1 country_year using "$data_mics\hl\mics4&5_adjustment.dta", keepusing(adj1_norm) nogen
ren adj1_norm adjustment

gen agestandard=ageU if adjustment==0
replace agestandard=ageA if adjustment==1
cap drop *ageU *ageA 

*Confirming that schage is available (for example, it is not available for South Sudan 2010)
bys country_year: egen temp_count=count(schage)
tab country_year if temp_count==0
replace schage=age if temp_count==0 & adjustment==0
replace schage=age-1 if temp_count==0 & adjustment==1
drop temp_count


*Age limits for completion and out of school


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

/*
** HERE I TEST THE NEW VARIABLES

collapse edu0_prim preschool* attend_higher_1822 comp_higher* [iw=hhweight], by(country_year)
foreach var in edu0_prim preschool_3 preschool_1ybefore attend_higher_1822  comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 {
	replace `var'=`var'*100
}
gen cy=lower(country_year)
sort cy
br
table country year [iw=hhweight], c(mean edu0_prim mean (mean comp_higher_2yrs_2529 mean comp_higher_2yrs_3034
*/

*Dropping variables
drop country_code*
drop hl* hh5* hh_id cluster hh6 district schage individual_id
drop ed3* ed4* ed5* ed6* ed7* ed8* code*
drop lowsec_age0* upsec_age0* prim_age1* lowsec_age1* upsec_age1*
drop years_prim years_lowsec years_upsec years_higher

compress


save "$data_mics\hl\Step_5.dta", replace

**********************************************

use "$data_mics\hl\Step_5.dta", clear
drop *no
collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec [weight=hhweight], by(country_year iso_code3 year adjustment prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout )

foreach var of varlist comp* eduout*{
		replace `var'=`var'*100
}
gen category="Total"
gen survey="MICS"
*Merge with year_uis
merge 1:1 iso_code3 survey year using "$aux_data/gem/country_survey_year_uis.dta", keepusing(year_uis)
drop if _merge==2
drop _merge

gen location=""
gen sex=""
gen wealth=""
merge 1:1 iso_code3 survey year_uis category location sex wealth using "$aux_data\UIS/UIS_indicators_29Nov2018_with_metadata.dta"
drop if survey!="MICS"
drop if _merge==2
drop iso_code2 country survey_uis location sex wealth year_uis
gen cy=lower(country_year)
sort cy

drop category survey _merge
order iso_code3 country_year year adjustment *_uis 

for X in any prim lowsec upsec: gen diff_comp_X=abs(comp_X_v2-comp_X_uis)
for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)

foreach Y in comp eduout {
gen flag_`Y'=0
replace flag_`Y'=1 if (diff_`Y'_prim>=3|diff_`Y'_lowsec>=3|diff_`Y'_lowsec>=3)  // Both in UIS & GEM. Diff>3
replace flag_`Y'=2 if (diff_`Y'_prim==.|diff_`Y'_lowsec==.|diff_`Y'_lowsec==.) // Only in GEM
}
for X in any comp: replace flag_X=3 if (X_prim_v2==. & X_prim_uis!=.) // Only in UIS
for X in any eduout: replace flag_X=3 if (X_prim==. & X_prim_uis!=.) // Only in UIS

for X in any comp: replace flag_X=4 if (X_prim_v2==. & X_prim_uis==.) // Neither in UIS nor in GEM. Ex: Eduout for Cuba 2010 & 2014
for X in any eduout: replace flag_X=4 if (X_prim==. & X_prim_uis==.) // Neither in UIS nor in GEM. Ex: Eduout for Cuba 2010 & 2014

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 4 "Neither in UIS nor in GEM"
for X in any comp eduout: label values flag_X flag

keep iso_code3 country_year survey year *_uis flag_comp





***************************************************************
* I put all the MICS together
use "$data_mics\hl\Step_5.dta", clear
append using "$data_mics\mics3\hl\MICS3_Step_5.dta"
append using "$data_mics\mics2\hl\MICS2_Step_5.dta"
keep country_year iso_code3 year $categories_collapse $varlist_m $varlist_no adjustment hhweight comp_prim_aux comp_lowsec_aux
order country_year iso_code3 year $categories_collapse comp_prim_aux comp_lowsec_aux $varlist_m $varlist_no adjustment hhweight 
compress
save "$data_mics\hl\All_MICS_Step_5.dta", replace


/*
cd "$data_mics\hl\collapse"
set more off
tuples $categories_collapse, display
foreach i of numlist 0/6 12/18 20/21 31 41 {
	use "$data_mics\hl\All_MICS_Step_5.dta", clear
	collapse (mean) $varlist_m comp_prim_aux comp_lowsec_aux (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year adjustment `tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
*/


* Appending the results
cd "$data_mics\hl\collapse"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/6 12/18 20/21 31 41 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0
gen survey="MICS"

**************************
*** FROM HERE IS STANDARD
**************************

replace category="total" if category==""
tab category

*-- Fixing for missing values in categories
foreach X in $categories_collapse {
drop if `X'=="" & category=="`X'"
}

for X in any sex wealth religion ethnicity region: drop if category=="location X" & (location==""|X=="")
for X in any wealth religion ethnicity region: drop if category=="sex X" & (sex==""|X=="")
for X in any region: drop if category=="wealth X" & (wealth==""|X=="")

drop if category=="location sex wealth" & (location==""|sex==""|wealth=="")
drop if category=="sex wealth region" & (sex==""|wealth==""|region=="")

replace category=proper(category)
split category, gen(c)
gen category_original=category
replace category=c1+" & "+c2 if c1!="" & c2!="" & c3==""
replace category=c1+" & "+c2+" & "+c3 if c1!="" & c2!="" & c3!=""
drop c1 c2 c3

*tab category category_orig
drop category_orig
compress

order country survey year category $categories_collapse $varlist_m $varlist_no

foreach var of varlist $vars_comp $vars_eduout comp_prim_aux comp_lowsec_aux{
		replace `var'=`var'*100
}

************* aqui se termina lo que son iguales

*Merge with year_uis
merge m:1 iso_code3 survey year using "$aux_data/gem/country_survey_year_uis.dta", keepusing(year_uis)
drop if _merge==2
drop _merge

sort iso_code category $categories_collapse
order iso_code category country_year year survey location sex wealth region ethnicity religion comp_prim_aux comp_lowsec_aux
save "$data_mics\hl\mics_AllRounds_collapse_categories_v5.dta", replace

use "$data_mics\hl\mics_AllRounds_collapse_categories_v5.dta", clear
export delimited "$data_mics\hl\mics_AllRounds_collapse_categories_v5.csv", replace

*-----------------------------------------------------------------------------------------------
*To create the flags for total

use "$aux_data\UIS\completion\UIS_completion_29Nov2018_with_sources.dta", clear
for X in any region ethnicity religion: gen X=""
save "$aux_data\UIS\completion\UIS_completion_29Nov2018_TEMP.dta", replace


use "$aux_data\UIS\completion\UIS_completion_29Nov2018_with_sources.dta", clear
keep if category=="Total"
save "$aux_data\UIS\completion\UIS_completion_29Nov2018_TOTAL.dta", replace

***********-------------------------------------------------------------------------------------------


use "$data_mics\hl\mics_AllRounds_collapse_categories_v4.dta", clear
keep if category=="Total"
append using "$gral_dir\WIDE\WIDE_DHS_MICS\data\dhs\PR\dhs_collapse_by_categories_v5.dta"
keep if category=="Total"
merge 1:1 iso_code3 survey year_uis category using "$aux_data\UIS\completion\UIS_completion_29Nov2018_TOTAL.dta"
keep if survey=="DHS"|survey=="MICS"
tab _merge
tab iso_code3 year_uis if _m==2
*Completing the info for those that _nerge==2
br if _merge==2
replace country_year=country+"_"+string(year_uis) if _merge==2
replace year=year_uis if _merge==2

for X in any prim lowsec upsec: gen diff_comp_X=abs(comp_X_v2-comp_X_uis)
for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)

*Flags for completion
gen flag_comp=0 // Both in UIS & GEM. No problem
replace flag_comp=1 if (diff_comp_prim>=3|diff_comp_lowsec>=3|diff_comp_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_comp=2 if comp_prim_uis==. // Only in GEM
replace flag_comp=3 if (comp_prim_v2==. & comp_prim_uis!=.) // Only in UIS

*Flags for out of school
gen flag_eduout=0 // Both in UIS & GEM. No problem
replace flag_eduout=1 if (diff_eduout_prim>=3|diff_eduout_lowsec>=3|diff_eduout_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_eduout=2 if eduout_prim_uis==. // Only in GEM
replace flag_eduout=3 if (eduout_prim==. & eduout_prim_uis!=.) // Only in UIS

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
for X in any comp eduout: label values flag_X flag

foreach X in comp eduout {
gen result_`X'="UIS estimates are reported" if flag_`X'==0
	replace result_`X'="Need to analyze" if flag_`X'==1
	replace result_`X'="GEM estimates are reported" if flag_`X'==2
	replace result_`X'="UIS estimates are reported" if flag_`X'==3
}

sort survey country_year
order survey country_year year comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 flag_comp result_comp diff_comp_prim diff_comp_lowsec diff_comp_upsec eduout_prim eduout_lowsec eduout_upsec flag_eduout result_eduout diff_eduout_prim diff_eduout_lowsec diff_eduout_upsec
br survey country_year year comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 flag_comp result_comp diff_comp_prim diff_comp_lowsec diff_comp_upsec eduout_prim eduout_lowsec eduout_upsec flag_eduout result_eduout diff_eduout_prim diff_eduout_lowsec diff_eduout_upsec

*save "$gral_dir\WIDE\WIDE_DHS_MICS\data\Comparison_UIS_GEM.dta", replace



************************************************************************************************************
global categories_collapse location sex wealth region ethnicity religion
global categories_subset location sex wealth
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no



*HERE I ELIMINATE THOSE <30
use "$data_mics\hl\mics_AllRounds_collapse_categories.dta", clear
append using "$gral_dir\WIDE\WIDE_DHS_MICS\data\dhs\PR\dhs_collapse_by_categories_v3.dta"
append using "$gral_dir\WIDE\WIDE_DHS_MICS\data\dhs\PR\India_collapse.dta"

merge 1:1 iso_code3 survey year_uis category location sex wealth region ethnicity religion using "$aux_data\UIS\completion\UIS_completion_29Nov2018_TEMP.dta"
keep if survey=="DHS"|survey=="MICS"
tab iso_code3 if _m==2 //these 6 plus Yemen 2013

* MERGE=2 6 countries plus Yemen 2013
 	* BDI Burundi DHS 2017 
	* BLZ Belize MICS 2016 
	* LKA Sri Lanka DHS 2006 (fata not public)
	* TLS Timor-Leste DHS 2016
	* UGA Uganda DHS 2016 
* MERGE=2 additional that just appeared	
	 *  ARG Argentina MICS 2011 			// To be dropped because it only includes URBAN.
     *  LCA Saint Lucia MICS 2012  (19 obs) // it has another name for wealth. Called windex51 before
     *  URY Uruguay MICS 2013 (19 obs) 		// it has another name for wealth. Called windex5_5 before
     *  ZMB Zambia DHS 2001 (40 obs) 		// UIS has wealth, but wealth is not in the DHS database

drop if iso_code3=="ARG" & survey=="MICS" & year_uis==2011

*Eliminate those that are less than 30
*This is to add the end after comparing with UIS
*Append to DHS.
*merge to UIS
*Compare to UIS
*Create flags bys country_year survey: gen keep=1 if diff_prim & diff_lowsec & diff_upsec=0

global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no
foreach var of varlist $varlist_no {
	gen count_`var'=1
	replace count_`var'=0 if `var'<30
}
	* Drop rows with n<30 for all variables
	egen row_keep=rowtotal(count_comp_prim_v2_no-count_eduout_upsec_no)
	* Drop rows with n<30 for all variables
	tab row_keep 
	br if row_keep==12
	br if row_keep==0
	drop if row_keep==0 & eduout_prim_uis==.
	
foreach var of varlist $varlist_m {
	replace `var'=. if `var'_no<30
}	
	
for X in any prim lowsec upsec: gen diff_comp_X=abs(comp_X_v2-comp_X_uis)

gen flag_comp=0 // Both in UIS & GEM. No problem
replace flag_comp=1 if (diff_comp_prim>=3|diff_comp_lowsec>=3|diff_comp_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_comp=2 if comp_prim_uis==. // Only in GEM
replace flag_comp=3 if (comp_prim_v2==. & comp_prim_uis!=.) // Only in UIS
replace flag_comp=. if category!="Total"
bys country_year survey: egen t_flag=max(flag_comp) 
drop flag_comp

label define flag_comp 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
label values t_flag flag_comp

decode t_flag, gen(flag_comp)
drop t_flag

bys flag_comp: tab iso_code3
drop count*
drop iso_code2*
drop diff*
drop _merge
drop row_keep
merge m:1 iso_code3 using "$aux_data/country_iso_codes_names.dta", keepusing(country)
drop if _merge==2
drop _merge
sort iso_code3 country year survey category 
order iso_code3 country year survey category $categories_collapse $vars_m $vars_no

gen categories_uis=1 if (category=="Total"|category=="Location"|category=="Sex"|category=="Wealth"|category=="Sex & Wealth"|category=="Location & Wealth"|category=="Location & Sex"|category=="Location & Sex & Wealth")

foreach X in comp_prim comp_lowsec comp_upsec {
	replace `X'_v2=`X'_uis if categories_uis==1 & flag_comp=="Both in UIS & GEM. No problem"
}

** Have to check if with the UIS replacements some have n<30

gen source="GEM"
replace source="UIS" if categories_uis==1 & flag_comp=="Both in UIS & GEM. No problem"

save "$gral_dir\WIDE\WIDE_DHS_MICS\data\GEM_UIS_AllCategories.dta", replace

use "$gral_dir\WIDE\WIDE_DHS_MICS\data\GEM_UIS_AllCategories.dta", clear
export excel "$gral_dir\WIDE\WIDE_DHS_MICS\data\GEM_UIS_AllCategories.csv", firstrow(variables) replace


*****************************************************************************
use "$gral_dir\WIDE\WIDE_DHS_MICS\data\GEM_UIS_AllCategories.dta", clear
keep if survey=="DHS"
keep if category=="Total"
replace year=year_uis if year==.
keep country year eduout_prim eduout_lowsec eduout_upsec eduout_prim_uis eduout_lowsec_uis eduout_upsec_uis

for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)
*Flags for out of school
gen flag_eduout=0 // Both in UIS & GEM. No problem
replace flag_eduout=1 if (diff_eduout_prim>=3|diff_eduout_lowsec>=3|diff_eduout_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_eduout=2 if eduout_prim_uis==. // Only in GEM
replace flag_eduout=3 if (eduout_prim==. & eduout_prim_uis!=.) // Only in UIS

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
for X in any eduout: label values flag_X flag

foreach X in eduout {
gen result_`X'="UIS estimates are reported" if flag_`X'==0
	replace result_`X'="Need to analyze" if flag_`X'==1
	replace result_`X'="GEM estimates are reported" if flag_`X'==2
	replace result_`X'="UIS estimates are reported" if flag_`X'==3
}

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------

******** THE FOLLOWING HAS EDUOUT BADLY CALCULATED

use "$gral_dir\WIDE\WIDE_DHS_MICS\data\GEM_UIS_AllCategories_v4.dta", clear
keep if survey=="DHS"
keep if category=="Total"
replace year=year_uis if year==.
keep iso_code year_uis country* year eduout*
drop *no
for X in any prim lowsec upsec: ren eduout_X_m eduout_X
merge 1:1 iso_code3 year_uis using "$aux_data\UIS\completion\UIS_completion_29Nov2018_TOTAL.dta"
keep if survey=="DHS"
keep if category=="Total"
tab _merge
replace year=year_uis if year==.
replace country_year=country+"_"+string(year_uis) if country_year==""

for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)
*Flags for out of school
gen flag_eduout=0 // Both in UIS & GEM. No problem
replace flag_eduout=1 if (diff_eduout_prim>=3|diff_eduout_lowsec>=3|diff_eduout_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_eduout=2 if eduout_prim_uis==. // Only in GEM
replace flag_eduout=3 if (eduout_prim==. & eduout_prim_uis!=.) // Only in UIS

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
for X in any eduout: label values flag_X flag

foreach X in eduout {
gen result_`X'="UIS estimates are reported" if flag_`X'==0
	replace result_`X'="Need to analyze" if flag_`X'==1
	replace result_`X'="GEM estimates are reported" if flag_`X'==2
	replace result_`X'="UIS estimates are reported" if flag_`X'==3
}
sort country_year
order survey country year eduout_prim eduout_lowsec eduout_upsec diff_eduout_prim flag_eduout result_eduout result_eduout diff_eduout_lowsec diff_eduout_upsec
br survey country year eduout_prim eduout_lowsec eduout_upsec diff_eduout_prim flag_eduout result_eduout result_eduout diff_eduout_lowsec diff_eduout_upsec
