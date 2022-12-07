**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2019.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************


**Transform 3 modules
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"
usespss P_2019_Terceros.sav
save P_2019_Terceros.dta
clear
usespss HyP_2019_Terceros.sav
save HyP_2019_Terceros.dta
clear
usespss H_2019_Terceros.sav
save H_2019_Terceros.dta

*but save HyP_2019_Terceros.dta has all the variables 

*Calulating wealth variables
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay\HyP_2019_Terceros.dta", clear
*Total income of the households
xtile hhwealthindex = HT11 [aw=pesoano], nquantiles(5)


save Uruguay_2019.dta, replace

************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"
use Uruguay_2019, clear 

local country Uruguay 
local sex e26
local urbanrural region_4 // location
local hhweight pesoano //
local age e27
local wealth hhwealthindex
local region estred13

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
*Join all montevideos and zona metropolitana
recode `region' (1/5=13), gen(region)
label define departamento 1 "Montevideo Bajo" 2 "Montevideo Medio Bajo" 3 "Montevideo Medio" 4 "Montevideo Medio Alto" 5 "Montevideo Alto" 6 "Zona Metropolitana" 7 "Interior Norte" 8 "Costa Este" 9 "Litoral Norte" 10 "Litoral Sur" 11 "Centro Norte" 12 "Centro Sur" 13 "Montevideo Y Zona Metropolitana"
label values region departamento


*Location (urban-rural)
rename `urbanrural' location
recode location (1/3 = 1) (4 = 0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"
save Uruguay_2019.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"
use Uruguay_2019, clear 

gen country_year="Uruguay"+"_"+"2019"
gen year=2019
gen iso_code2="UY"
gen iso_code3="URY"
gen country = "Uruguay"
gen survey="ECH"

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

*all levels are in several questions, big recode
*6-3-3 system start at 6y
*https://es.wikipedia.org/wiki/Sistema_educativo_de_Uruguay#Educaci%C3%B3n_formal

*Levels considered in survey : first transformation, conditional on finishing that level, then recode for incomplete with immediate inferior level 
// Pre-escolar		193 => 0
// Primaria			197 => 1
// Media			201 => 2
// Magisterio		215 => 4
// Universitario	218 => 6
// Terciaria		221 => 4
// Posgrado			224 => 7
// Ens técnica 		212 => 3


gen highestlevelattended=.  
*first overwrite in ascending order of levels
replace highestlevelattended=0 if inlist(e193, 1, 2) // assisted or assisting to preschool 
replace highestlevelattended=1 if inlist(e197_1, 1) // primary
replace highestlevelattended=2 if inlist(e201_1, 1) // media
replace highestlevelattended=3 if inlist(e212_1, 1) // e tecnica
replace highestlevelattended=4 if inlist(e215_1, 1) // magisterio
replace highestlevelattended=4 if inlist(e221_1, 1) // terciaria no univ
replace highestlevelattended=6 if inlist(e218_1, 1) // univ
replace highestlevelattended=7 if inlist(e224_1, 1) // posgrado

*now complete immediate inferior if assisted but not finished 
replace highestlevelattended=0 if inlist(e197_1, 2) // primary
replace highestlevelattended=1 if inlist(e201_1, 2) // media
replace highestlevelattended=2 if inlist(e212_1, 2) // e tecnica
replace highestlevelattended=3 if inlist(e215_1, 2) // magisterio
replace highestlevelattended=3 if inlist(e221_1, 2) // terciaria no univ
replace highestlevelattended=5 if inlist(e218_1, 2) // univ
replace highestlevelattended=6 if inlist(e224_1, 2) // posgrado

*now fix lowsec-upsec with years, but not overwrite higher levels
*ciclo basico is lowsec
replace highestlevelattended=1 if inlist(e51_4, 1, 2) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // incomplete
replace highestlevelattended=2 if inlist(e51_4, 3) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // complete
*bachilleratos is upsec
replace highestlevelattended=2 if inlist(e51_5, 1, 2) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // incomplete
replace highestlevelattended=3 if inlist(e51_5, 3) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // complete
replace highestlevelattended=2 if inlist(e51_6, 1, 2) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // incomplete
replace highestlevelattended=3 if inlist(e51_6, 3) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // complete

*now fix ens tecnica according to requisite
replace highestlevelattended=4 if inlist(e51_7_1, 1) & inlist(e212_1, 1) & inlist(highestlevelattended, 0, 1, 2, 3, 4)   // ask upsec to enter
replace highestlevelattended=3 if inlist(e51_7_1, 2) & inlist(e212_1, 1) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // ask lowsec to enter
replace highestlevelattended=3 if inlist(e51_7_1, 3) & inlist(e212_1, 1) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // ask primary to enter
replace highestlevelattended=3 if inlist(e51_7_1, 1) & inlist(e212_1, 2) & inlist(highestlevelattended, 0, 1, 2, 3, 4)  // ask upsec to enter
replace highestlevelattended=2 if inlist(e51_7_1, 2) & inlist(e212_1, 2) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // ask lowsec to enter
replace highestlevelattended=1 if inlist(e51_7_1, 3) & inlist(e212_1, 2) & inlist(highestlevelattended, 0, 1, 2, 3, 4) // ask primary to enter


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

gen eduyears=.  
*replace if they finished or not, avoiding value=9
replace eduyears=0 if inlist(e193, 1, 2) // assisted or assisting to preschool 
replace eduyears=e51_2 if inlist(e197_1, 1, 2) & inlist(e51_2, 1, 2, 3, 4, 5, 6) // primary
replace eduyears=e51_3 if inlist(e197_1, 1, 2) & inlist(e51_3, 1, 2, 3, 4) // primary

replace eduyears=years_prim+e51_4 if inlist(e201_1, 1, 2) & inlist(e51_4, 1, 2, 3)  // media ciclo basico
replace eduyears=years_lowsec+e51_5 if inlist(e201_1, 1, 2) & inlist(e51_5, 1, 2, 3)  // media bachillerato 1
replace eduyears=years_lowsec+e51_6 if inlist(e201_1, 1, 2) & inlist(e51_6, 1, 2, 3) // media bachillerato 2

*etecnica
replace eduyears=years_upsec+e51_7 if inlist(e51_7_1, 1) & inlist(e212_1, 1, 2) & inlist(e51_7, 1, 2, 3, 4)   // ask upsec to enter
replace eduyears=years_lowsec+e51_7 if inlist(e51_7_1, 2) & inlist(e212_1, 1, 2) & inlist(e51_7, 1, 2, 3, 4) // ask lowsec to enter
replace eduyears=years_prim+e51_7 if inlist(e51_7_1, 3) & inlist(e212_1, 1, 2) & inlist(e51_7, 1, 2, 3, 4) // ask primary to enter

replace eduyears=years_upsec+e51_8 if inlist(e215_1, 1, 2) & inlist(e51_8, 1, 2, 3, 4)   // magisterio
replace eduyears=years_upsec+e51_9 if inlist(e218_1, 1, 2) & inlist(e51_9, 1, 2, 3, 4, 5, 6, 7, 8)   // universitario
replace eduyears=years_upsec+e51_10 if inlist(e221_1, 1, 2) & inlist(e51_10, 1, 2, 3, 4)   // terciaria no univ
replace eduyears=years_upsec+e51_9+e51_11 if inlist(e221_1, 1, 2) & inlist(e51_11, 1, 2, 3, 4) & inlist(e51_9, 1, 2, 3, 4, 5, 6, 7, 8)   // posgrado
replace eduyears=years_upsec+4+e51_11 if inlist(e221_1, 1, 2) & inlist(e51_11, 1, 2, 3, 4) & inlist(e51_9, 0, 9)   // posgrado if no years of bachelor assume 4 
 
*DATA COLLECTION DAYS OF THE SURVEY
*http://anda.ine.gob.bo/index.php/catalog/84#metadata-data_collection
*During all year
tab mes 

*According to some web: 
*Dates:  The school year begins in March. 
*https://es.wikipedia.org/wiki/Sistema_educativo_de_Uruguay#Educaci%C3%B3n_formal

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

	 generate attend_preschool   = 1 if e193 == 1 // enrolled in preschool 
	 replace attend_preschool    = 0 if e193 == 3 //not attending 
	 replace attend_preschool    = 0 if e193 == 2 //attended in the past
	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?"
generate attend = 0 if e49 == 2
*replace attending for all levels 
replace attend = 1 if e193 == 1 | e197 == 1 | e201 == 1 | e215 == 1 | e218 == 1 | e221 == 1 | e212 == 1 | e224 == 1  //assisting current year, any level

recode attend (1=0) (0=1), gen(no_attend)

***
// superior no universitaria	4
// superior universitaria	5
// maestria/doctorado	6


***
generate high_ed = 1 if inlist(highestlevelattended, 4, 5, 6, 7) 
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
capture replace eduout  = . if (attend == 1 & highestlevelattended == .) | age == . 


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if attend==1
replace edu0  = 1 if e49==2
replace edu0  = 1 if eduyears == 0
replace edu0  = 1 if inlist(highestlevelattended, 0) //preschool


generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(highestlevelattended, .)
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
gen overage2plus= 0 if attend==1 & inlist(e197, 1)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 1/6 {
				local i=`i'+1
				replace overage2plus=1 if e51_2==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
recode e48 (2=0) (1=1), gen(literacy)
replace literacy=. if age<15
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literacy

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore preschool_3 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"
save Uruguay_microdata.dta, replace

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

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"


set more off
set trace on
foreach i of numlist 0/15 {
	use Uruguay_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Uruguay"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2019"
gen country_year="Uruguay"+"_"+year
destring year, replace
gen iso_code2="UY"
gen iso_code3="URY"
gen country = "Uruguay"
gen survey="ECH"
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
 
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Peru\indicators_Uruguay_2019.dta", replace

