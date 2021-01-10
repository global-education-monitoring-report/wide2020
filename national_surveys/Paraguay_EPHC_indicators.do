**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2019.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

*Seemingly all we need is in REG02
clear
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"
usespss REG02_EPHC_ANUAL_2019.sav
rename *, lower
save Paraguay_2019.dta, replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"
use Paraguay_2019, clear 

local country Paraguay 
local sex p06
local urbanrural area // location
local hhweight fex //
local age p02
local wealth quintili
local region dpto

*Sex
rename `sex' sex
recode sex (1=1) (6=0)
label define sex 1 "Male" 0 "Female"
label val sex sex

*Weight
rename `hhweight' hhweight
lab var hhweight "HH weight"

*Age
label var `age' "Age at the date of the interview"
clonevar age=`age' 

* Wealth
rename `wealth' wealth
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth

*Region fixing accents
rename `region' region

*Location (urban-rural)
rename `urbanrural' location
recode location (1 = 1) (6 = 0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"
save Paraguay_2019.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"
use Paraguay_2019, clear 

gen country_year="Paraguay"+"_"+"2019"
gen year=2017
gen iso_code2="PY"
gen iso_code3="PRY"
gen country = "Paraguay"
gen survey="EPHC"

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=5 // according to ISCED, some 3-4 and one 5 years for medicine
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur

	*Ages for completion
	gen lowsec_age0=prim_age0+prim_dur
	gen upsec_age0=lowsec_age0+lowsec_dur
	for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1

*Following this 
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 9=higher
*local levelattendingcurrentyear P1088
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence
*6-3-3 start 6y
*https://www.educacionyfp.gob.es/argentina/dam/jcr:2334af62-4034-476d-8aac-8808342fae2d/estudiar%20en%20paraguay-v102018.pdf

// Sin instrucción					0			=> 0
// Educación especial				101:112		=> 0
// Educación Inicial				210:212		=> 0
// EEB 1ª al 6ª (Primaria)			301:306		=> 0 correct 306 to 1
// EEB 7º al 9º						407:409		=> 1 correct 409 to 2
// Secundario Básico				501:503		=> 2 correct 503 to 3
// Bachiller Humanístico/Científico	604:607		=> 2 correct 606 607 to 3
// Bachiller Técnico/Comercial		704:706		=> 2 correct 706 707 to 3
// Bachillerato a distancia			803			=> 3 
// Educación Media Científica		901:903		=> 2 correct 903 to 3
// Educación Media Técnica			1001:1003	=> 2 correct 1003 to 3
// Educación Media Abierta			1101:1103	=> 2 correct 1103 to 3
// Educ. Básica Bilingüe para personas Jóvenes y Adultas	1201:1204 => 1 correct 1204 to 2  
// Educ. Media a Distancia para Jóvenes y Adultos			1301:1304 => 2 correct 1304 to 3
// Educ. Básica Alternativa de Jóvenes y Adultos			1401:1403 => 1 correct 1403 to 2
// Educ. Media Alternativa de Jóvenes y Adultos				1501:1504 => 2 correct 1504 to 3
// Educ. Media para Jóvenes y Adultos						1601:1604 => 2 correct 1604 to 3
// Formación profesional no Bachillerato de la Media		1701:1703 => 4
// Programa de Alfabetización								1801	  => 1
// Grado especial/Programas especiales						1900	  => 3
// Técnica Superior											2001:2004 => 5
// Formación Docente										2101:2104 => 5
// Profesionalización Docente								2201:2206 => 5
// Formación Militar/Policial								2301:2304 => 5
// Universitario											2401:2406 => 3 correct 2404:2406 to 6
// NR								9999
// NA								8888


local highestlevelattended ed0504 

recode `highestlevelattended' (0/306=0) (407/409=1) (501/706 901/1103 1301/1304 1501/1604=2) (803 1900 2401/2406=3) (1701/1703=4) (2001/2304=5), gen(highestlevelattended)
replace highestlevelattended=1 if ed0504==306 
replace highestlevelattended=2 if ed0504==409
replace highestlevelattended=3 if ed0504==503
replace highestlevelattended=3 if ed0504==606
replace highestlevelattended=3 if ed0504==607
replace highestlevelattended=3 if ed0504==706
replace highestlevelattended=3 if ed0504==707
replace highestlevelattended=3 if ed0504==903
replace highestlevelattended=3 if ed0504==1003
replace highestlevelattended=3 if ed0504==1103

replace highestlevelattended=3 if ed0504==1204
replace highestlevelattended=3 if ed0504==1304
replace highestlevelattended=2 if ed0504==1403
replace highestlevelattended=3 if ed0504==1504
replace highestlevelattended=3 if ed0504==1604

replace highestlevelattended=6 if ed0504==2404
replace highestlevelattended=6 if ed0504==2405
replace highestlevelattended=6 if ed0504==2406


***Completion variables:  comp_prim_v2 comp_lowsec_v2 comp_upsec_v2  comp_prim_1524 comp_lowsec_1524 comp_upsec_2029

for X in any prim lowsec upsec: gen comp_X=0 if highestlevelattended!=.
replace comp_prim=1 if highestlevelattended >= 1 & comp_prim == 0
replace comp_lowsec=1 if highestlevelattended >= 2 & comp_lowsec == 0
replace comp_upsec=1 if highestlevelattended >= 3 & comp_upsec == 0

*Age limits
foreach X in prim lowsec upsec {
foreach AGE in age {
	gen comp_`X'_v2=comp_`X' if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5
	gen comp_`X'_1524=comp_`X' if `AGE'>=15 & `AGE'<=24
	gen comp_`X'_2024=comp_`X' if `AGE'>=20 & `AGE'<=24
}
}

gen comp_upsec_2029=comp_upsec if age>=20 & age<=29
gen comp_upsec_2029_no=comp_upsec_2029

// foreach AGE in schage  {
// 		generate comp_prim_1524   = comp_prim if `AGE' >= 15 & `AGE' <= 24
// 		generate comp_upsec_2029  = comp_upsec if `AGE' >= 20 & `AGE' <= 29
// 		generate comp_lowsec_1524 = comp_lowsec if `AGE' >= 15 & `AGE' <= 24
// 	}

*6-3-3 start at 6
*see icsed mapping xls for code
gen eduyears=.
replace eduyears=0 if ed0504==0
replace eduyears=1 if ed0504==101
replace eduyears=2 if ed0504==102
replace eduyears=3 if ed0504==103
replace eduyears=4 if ed0504==104
replace eduyears=5 if ed0504==106
replace eduyears=6 if ed0504==107
replace eduyears=7 if ed0504==109
replace eduyears=9 if ed0504==210
replace eduyears=0 if ed0504==211
replace eduyears=0 if ed0504==212
replace eduyears=1 if ed0504==301
replace eduyears=2 if ed0504==302
replace eduyears=3 if ed0504==303
replace eduyears=4 if ed0504==304
replace eduyears=5 if ed0504==305
replace eduyears=6 if ed0504==306
replace eduyears=7 if ed0504==407
replace eduyears=8 if ed0504==408
replace eduyears=9 if ed0504==409
replace eduyears=10 if ed0504==501
replace eduyears=11 if ed0504==502
replace eduyears=12 if ed0504==503
replace eduyears=10 if ed0504==604
replace eduyears=11 if ed0504==605
replace eduyears=12 if ed0504==606
replace eduyears=13 if ed0504==607
replace eduyears=10 if ed0504==704
replace eduyears=11 if ed0504==705
replace eduyears=12 if ed0504==706
replace eduyears=10 if ed0504==901
replace eduyears=11 if ed0504==902
replace eduyears=12 if ed0504==903
replace eduyears=10 if ed0504==1001
replace eduyears=11 if ed0504==1002
replace eduyears=12 if ed0504==1003
replace eduyears=10 if ed0504==1101
replace eduyears=11 if ed0504==1102
replace eduyears=12 if ed0504==1103
replace eduyears=1 if ed0504==1201
replace eduyears=2 if ed0504==1202
replace eduyears=3 if ed0504==1203
replace eduyears=4 if ed0504==1204
replace eduyears=10 if ed0504==1303
replace eduyears=11 if ed0504==1304
replace eduyears=2 if ed0504==1402
replace eduyears=3 if ed0504==1403
replace eduyears=10 if ed0504==1501
replace eduyears=11 if ed0504==1502
replace eduyears=12 if ed0504==1503
replace eduyears=13 if ed0504==1504
replace eduyears=10 if ed0504==1601
replace eduyears=11 if ed0504==1602
replace eduyears=12 if ed0504==1603
replace eduyears=13 if ed0504==1604
replace eduyears=11 if ed0504==1702
replace eduyears=12 if ed0504==1703
replace eduyears=1 if ed0504==1801
replace eduyears=10 if ed0504==1900
replace eduyears=10 if ed0504==2001
replace eduyears=11 if ed0504==2002
replace eduyears=12 if ed0504==2003
replace eduyears=13 if ed0504==2101
replace eduyears=14 if ed0504==2102
replace eduyears=15 if ed0504==2103
replace eduyears=16 if ed0504==2104
replace eduyears=18 if ed0504==2202
replace eduyears=20 if ed0504==2204
replace eduyears=22 if ed0504==2206
replace eduyears=13 if ed0504==2301
replace eduyears=14 if ed0504==2302
replace eduyears=15 if ed0504==2303
replace eduyears=16 if ed0504==2304
replace eduyears=13 if ed0504==2401
replace eduyears=14 if ed0504==2402
replace eduyears=15 if ed0504==2403
replace eduyears=16 if ed0504==2404
replace eduyears=17 if ed0504==2405
replace eduyears=18 if ed0504==2406
replace eduyears=. if ed0504==9999


 
*DATA COLLECTION DAYS OF THE SURVEY
*During all year
tab trimestre 

*According to some web: 
*Dates:  The school year begins in February. 
*https://www.hoy.com.py/nacionales/calendario-escolar-2019-vuelta-a-clases-receso-de-invierno-y-feriados

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.

gen schage = age 

*33% of households have a difference of over 6 months=> no adjustment 


***
***Mean years of education: eduyears_2024
***
generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24

***
***Pre-primary education attendance: preschool_1ybefore 
***
*Percentage of children attending any type of pre–primary education programme, 
*(i) as 3–4 year olds and NOT THIS
*(ii) 1 year before the official entrance age to primary. THIS

	 generate attend_preschool   = 1 if inlist(ed0504, 210, 211, 212) // highest level is preschool 
	 replace attend_preschool   = 1 if inlist(ed08, 1) // attending preschool 
	 replace attend_preschool    = 0 if ed08 == 9 //not assisting to any
	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?"
generate attend = 1 if inlist(ed08, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18)
replace attend  = 0 if ed08 == 19 //not assisting 

recode attend (1=0) (0=1), gen(no_attend)

***
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 9=higher


***
generate high_ed = 1 if inlist(highestlevelattended, 5, 6) 
*use level attending now 
capture generate attend_higher = 1 if attend == 1 & high_ed == 1
capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
capture replace attend_higher  = 0 if attend == 0
capture generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

***
***Out-of-school: eduout_prim eduout_lowsec eduout_upsec
***
* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
generate eduout = no_attend
capture replace eduout  = . if (attend == 1 & ed08 == 99) | age == .  |(attend == 1 & ed08 == .)


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if ed0504>0
replace edu0  = 1 if ed03==6
replace edu0  = 1 if eduyears == 0
replace edu0  = 1 if inlist(ed0504, 210, 211, 212) //preschool


generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(ed0504, .)
	}

	replace comp_higher_2yrs = 1 if eduyears >= years_upsec + 2
	replace comp_higher_4yrs = 1 if eduyears >= years_upsec + 4

	*Ages for completion higher
	foreach X in 2 4{
		generate comp_higher_`X'yrs_2529 = comp_higher_`X'yrs if schage >= 25 & schage <= 29
	}
	foreach X in 4{
		generate comp_higher_`X'yrs_3034 = comp_higher_`X'yrs if schage >= 30 & schage <= 34
		drop comp_higher_`X'yrs 
	}
***	
***Less than 2/4 years of schooling: edu2_2024 edu4_2024
***
	
	foreach X in 2 4 {
		generate edu`X'_2024 = 0
		replace edu`X'_2024  = 1 if eduyears_2024 < `X'
		replace edu`X'_2024  = . if eduyears_2024 == .
	}

*Over-age primary school attendance
*Percentage of children in primary school who are two years or more older than the official age for grade.
gen overage2plus= 0 if attend==1 & inlist(ed08, 2)
gen primarygrade=ed0504-300 if inlist(ed0504, 301, 302, 303, 304, 305, 306)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 1/6 {
				local i=`i'+1
				replace overage2plus=1 if primarygrade==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
recode ed02 (6=0) (1=1) (9=.), gen(literacy)
replace literacy=. if age<15
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literacy

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore preschool_3 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"
save Paraguay_microdata.dta, replace

************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore preschool_3 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no preschool_1ybefore_no preschool_3_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no

tuples $categories_collapse, display
/*
tuples $categories_collapse, display
tuple1: region
tuple2: wealth
tuple3: sex
tuple4: location
tuple5: wealth region
tuple6: sex region
tuple7: sex wealth
tuple8: location region
tuple9: location wealth
tuple10: location sex
tuple11: sex wealth region
tuple12: location wealth region
tuple13: location sex region
tuple14: location sex wealth
tuple15: location sex wealth region
*/

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"


set more off
set trace on
foreach i of numlist 0/15 {
	use Paraguay_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2019"
gen country_year="Paraguay"+"_"+year
destring year, replace
gen iso_code2="PE"
gen iso_code3="PER"
gen country = "Paraguay"
gen survey="ENAHO"
replace category="total" if category==""
tab category

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no preschool_1ybefore_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no


*-- Fixing for missing values in categories
for X in any wealth sex: decode X, gen(X_s)
for X in any wealth sex: drop X
for X in any wealth sex: ren X_s X

codebook $categories_collapse, tab(100)

*Putting the names in the same format as the others
*for X in any $categories_collapse total: replace category=proper(category) if category=="X"
replace category="Location & Sex" if category=="location sex"
replace category="Location & Sex & Wealth" if category=="location sex wealth"
replace category="Location & Wealth" if category=="location wealth"
replace category="Sex & Region" if category=="sex region"
replace category="Sex & Wealth" if category=="sex wealth"
replace category="Sex & Wealth & Region" if category=="sex wealth region"
replace category="Wealth & Region" if category=="wealth region"

* Categories that are not used:
drop if category=="location region"|category=="location sex region"|category=="location wealth region"|category=="location sex wealth region"

for X in any $categories_collapse: rename X, proper

// *Now I throw away those that have large differences (per level)
// merge m:1 country year using "$dir/comparisons/results.dta", keepusing(flag*) nogen
// drop if flag_lfs==1
// order iso_code3 country survey year category Sex Location Wealth Region comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* comp_prim_1524* comp_lowsec_1524* comp_upsec_2029* preschool_1ybefore*
// drop comp_lowsec_2024-flag_LFS_country
// for X in any comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore: ren X X_m
// order iso_code3 country survey year category Sex Location Wealth Region *_m *_no

*order iso_code country year country_year survey category location sex wealth region ethnicity religion
order iso_code2 iso_code3 country survey year country_year category Region Location Wealth Sex  
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Paraguay\indicators_Paraguay_2019.dta", replace

