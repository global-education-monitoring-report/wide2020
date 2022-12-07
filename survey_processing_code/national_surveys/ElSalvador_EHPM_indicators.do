**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2019.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************


**Transform personal dataset from SPSS format
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"
usespss EHPM2019.sav
save EHPM2019.dta

*Calulating wealth variables
*Total per capita net income of the households
xtile hhwealthindex = ingfa [aw=fac00], nquantiles(5)

save ElSalvador_2019.dta, replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"
use ElSalvador_2019, clear 

local country ElSalvador 
local sex r104
local urbanrural area // location
local hhweight fac00 //
local age r106
local wealth hhwealthindex
local region region

*Sex
rename `sex' sex
recode sex (1=1) (2=0)
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
*gen departamento = substr(ubigeo, 1, 2)
*destring departamento, replace
*label define depto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Prov. Const. del Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali" , replace
*rename `region' region
*label values region depto


*Location (urban-rural)
rename `urbanrural' location
*recode location (1/6 = 1) (0 = 0) no need
label define location 1 "Urban" 0 "Rural"
label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"
save ElSalvador_2019.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"
use ElSalvador_2019.dta, clear 

gen country_year="ElSalvador"+"_"+"2019"
gen year=2019
gen iso_code2="SV"
gen iso_code3="SLV"
gen country = "El Salvador"
gen survey="EHPM"

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=5.5 // according to ISCED, between 3.5 years to 8 years in medicine
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


//                             36         1->0  Parvularia (1° a 3°)
//                         27,148         2->gr Básica (1° a 9°)
//                         11,328         3->gr Media (10° a 13°)
//                          3,292         4->6  Superior universitario (1° a
//                                           	15°)
//                            777         5->5  Superior no universitario (1° a
//                                           	3°)
//                             32         6->1  Educación especial (ciclos I,
//                                           	II, III, IV)
//                          1,451         8->0 	Ninguno

*6-3-3 start at 7-13-16ys

local highestlevelattended r215a 

recode `highestlevelattended' (8 1=0) (2=1) (3=2) (5=5) (4=9), gen(highestlevelattended)
replace highestlevelattended=0 if r215a==2 & inlist(r215b, 1, 2, 3, 4, 5) // incomplete primary
replace highestlevelattended=1 if r215a==2 & inlist(r215b, 6, 7, 8) // complete primary, incomplete lowsec
replace highestlevelattended=2 if r215a==2 & inlist(r215b, 9) // complete lowsec
replace highestlevelattended=2 if r215a==3 & inlist(r215b, 10, 11) // complete lowsec, incomplete upsec
replace highestlevelattended=3 if r215a==3 & inlist(r215b, 12, 13) // complete upsec
replace highestlevelattended=0 if r215a==6 & inlist(r215b, 1, 2, 3) // special education that lasts 4 years, less than 4
replace highestlevelattended=1 if r215a==6 & inlist(r215b, 4) // special education that lasts 4 years, 4 years equivalent to primary 
*fix: completing this variable with level attending 
replace highestlevelattended=0 if r204==1 
replace highestlevelattended=0 if r204==2 & inlist(r204g, 1, 2, 3, 4, 5) // incomplete primary
replace highestlevelattended=1 if r204==2 & inlist(r204g, 6, 7, 8) // complete primary, incomplete lowsec
replace highestlevelattended=2 if r204==2 & inlist(r204g, 9) // complete lowsec
replace highestlevelattended=2 if r204==3 & inlist(r204g, 10, 11) // complete lowsec, incomplete upsec
replace highestlevelattended=3 if r204==3 & inlist(r204g, 12, 13) // complete upsec


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

*6-3-3 start at 7-13-16ys
//                             36         1->0  Parvularia (1° a 3°)
//                         27,148         2->gr Básica (1° a 9°)
//                         11,328         3->gr Media (10° a 13°)
//                          3,292         4->6  Superior universitario (1° a
//                                           	15°)
//                            777         5->5  Superior no universitario (1° a
//                                           	3°)
//                             32         6->1  Educación especial (ciclos I,
//                                           	II, III, IV)
//                          1,451         8->0 	Ninguno


gen eduyears=.
replace eduyears=0 if inlist(r215a, 1, 8)  // no level and preschool 
replace eduyears=r215b  if inlist(r215a, 2, 3) // primary, lowsec, upsec  
replace eduyears=years_upsec+r215b if inlist(r215a, 4) // superior universitaria incompleta y completa
replace eduyears=years_upsec+r215b  if inlist(r215a, 5) // superior no universitaria incompleta y completa 
replace eduyears=r215b  if inlist(r215a, 6) // special education 

 
*DATA COLLECTION DAYS OF THE SURVEY
*http://anda.ine.gob.bo/index.php/catalog/84#metadata-data_collection
*During all year
tab r015 

*According to some web: 
*Dates:  The school year begins in end of January 21th
*https://diariolibresv.com/2019/01/04/nacionales/aun-no-sabes-cuando-inician-las-clases-te-contamos-aqui/

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

	 generate attend_preschool   = 1 if r201a == 1 // goes to preschool (0-4 years old)
	 replace attend_preschool    = 0 if r201a == 2 //does not go to preschoo (0-4)
	 replace attend_preschool    = 0 if r203 == 2  //not assisting (5+ years old)
	 replace attend_preschool    = 0 if r203 == 1 & r204==1  // assisting to preschool (5+ years old)
	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?"
generate attend = 1 if r203 == 1 // assisting 5+ years
replace attend  = 0 if r203 == 2 //not assisting 5+ years
replace attend  = 1 if r201a == 1 // assisting 0-4y
replace attend  = 0 if r201a == 2 // not assisting 0-4y

recode attend (1=0) (0=1), gen(no_attend)

***
*Only these categories for higher

//       Superior universitario (1° a 15°) |      1,966       10.89       99.03
//     Superior no universitario (1° a 3°) |        138        0.76       99.80


***
generate high_ed = 1 if inlist(r204, 4, 5) 
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
capture replace eduout  = . if (attend == 1 & r204 == .) | age == . 


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if r213==2 //ever go to school 
replace edu0  = 1 if r213==1
replace edu0  = 1 if eduyears == 0
replace edu0  = 1 if inlist(r215a, 1) //preschool


generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(r215a, .)
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
gen overage2plus= 0 if attend==1 & inlist(r204, 2)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 1/6 {
				local i=`i'+1
				replace overage2plus=1 if r204g==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
recode r202a (2 3=0) (1=1), gen(literacy)
replace literacy=. if age<15
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literacy

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"
save ElSalvador_microdata.dta, replace

************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no preschool_1ybefore_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no

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

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"


set more off
set trace on
foreach i of numlist 0/15 {
	use ElSalvador_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2019"
gen country_year="ElSalvador"+"_"+year
destring year, replace
gen iso_code2="SV"
gen iso_code3="SLV"
gen country = "El Salvador"
gen survey="EHPM"
replace category="total" if category==""

	global categories_collapse location sex wealth region
	
	*-- Fixing for missing values in categories
	for X in any $categories_collapse: decode X, gen(X_s)
	for X in any $categories_collapse: drop X
	for X in any $categories_collapse: ren X_s X

	*Putting the names in the same format as the others
	global categories_collapse location sex wealth region
	tuples $categories_collapse, display
	
	* DROP Categories that are not used:
	drop if category=="location region"|category=="location sex region"|category=="location wealth region"|category=="location sex wealth region"

	*Proper for all categories
	foreach i of numlist 0/`ntuples' {
	replace category=proper(category) if category=="`tuple`i''"
	}
		
	
	order iso_code3 country survey year category $categories_collapse $varlist_m $varlist_no 
	tab category
	for X in any $categories_collapse: tab X

				 save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\El Salvador\indicators_ElSalvador_2019.dta", replace
