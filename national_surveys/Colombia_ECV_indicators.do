**Adapting widetable for other surveys

************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

set more off

**
clear
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Fuerza de trabajo.dta"
egen personalincome=rsum( P8624 P6595S1 P6605S1 P6623S1 P6615S1 P8626S1 P8628S1 P8630S1 P8631S1 P8642S1)
drop if personal==0
collapse (sum) personalincome [aw= FEX_C ], by( DIRECTORIO SECUENCIA_P) cw
rename personalincome householdincome
xtile hhwealthindex = householdincome, nquantiles(5)
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\wealthindex.dta", replace
**



** Append all the databases
clear
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Educación.dta"
merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P using "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Caracteristicas y composicion del hogar.dta"
merge m:1 DIRECTORIO using "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Datos de la vivienda.dta", nogen
merge m:1 DIRECTORIO SECUENCIA_P using "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\wealthindex.dta", nogen

save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Colombia_2019.dta", replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************

clear
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Colombia_2019.dta",  


local country Colombia 
local sex P6020
local urbanrural CLASE
local hhweight FEX_C
local age P6040
local wealth hhwealthindex
local region REGION

*Sex
rename `sex' sex
recode sex (1=1) (2=0)
label define sex 1 "Male" 0 "Female"
label val sex sex

*Weight
ren `hhweight' hhweight
lab var hhweight "HH weight"

*Age
label var `age' "Age at the date of the interview"
clonevar age=`age' 

* Wealth
rename `wealth' wealth
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth

*Region fixing accents
gen region=`region'
label define REGION 1 "Caribe" 2 "Oriental" 3 "Central" 4 "Pacífica (sin valle)" 5 "Bogotá" 6 "Antioquia" 7 "Valle del Cauca" 8 "San Andrés" 9 "Orinoquía - Amazonía", replace
label values region REGION

*Location (urban-rural)
rename `urbanrural' location
recode location (1=1) (2=0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Colombia_2019.dta", replace


************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************
clear
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\Colombia_2019.dta",  

gen iso_code3="COL"
gen year=2018

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=5 // in the Bologna convention is 3 years.
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
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 
local highestlevelattended P8587
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence

recode `highestlevelattended' (1=0) (3=1) (4=2) (5=3) (6=3) (7=4) (8=3) (9=4) (10=3) (11=6) (12=6) (13=7) , gen(highestlevelattended)


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


*EDUYEARS will combine level and highest level-grade attended
gen eduyears=.
replace eduyears=0 if P8587==1
replace eduyears=P8587S1 if (P8587==3|P8587==4|P8587==5) // primaria secundaria media
replace eduyears=years_higher+P8587S1 if inlist(P8587, 6, 7, 8, 9, 10, 11) // tecnicos no magister 
replace eduyears=years_higher+5 if P8587==12 // posgrado sin titulo
replace eduyears=years_higher+5 if P8587==13 // posgrado con titulo


*DATA COLLECTION DAYS OF THE SURVEY
*Start	End	Cycle
*2019-09-02	2019-11-15	Anual

*According to Colombia Education Ministry : empieza en el mes de febrero y culmina en el mes de noviembre
*https://www.mineducacion.gov.co/1759/w3-article-364691.html?_noredirect=1

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

gen schage = age-1 

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

gen preschool=1 if P1088==1
gen before1y=1 if age==prim_age0-1
gen presch1ybefore=preschool if before1y==1
drop before1y

ren presch1ybefore preschool_1ybefore

*P8586: "Attended school during current school year?"
generate attend = 1 if P8586 == 1
replace attend  = 0 if P8586 == 2
recode attend (1=0) (0=1), gen(no_attend)

***
****Higher education attendance: attend_higher_1822
***
generate high_ed = 1 if inlist(P1088, 5, 6, 7, 8)
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
capture replace eduout  = . if (attend == 1 & P1088 == .) | age == . 
capture replace eduout  = 1 if P1088 == 1  

*this from UIS_duration_age_01102020.dta
gen prim_age0_eduout = 6
gen prim_dur_eduout = 5
gen lowsec_dur_eduout = 4 
gen upsec_dur_eduout = 2

generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1

*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
generate edu0 = 0 if inlist(P8587, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
replace edu0  = 1 if inlist(P8587, 1)
replace edu0  = 1 if inlist(P1088, 1)
replace edu0  = 1 if eduyears == 0

generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(P8587, ., 1 )
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

***********OVER-AGE PRIMARY ATTENDANCE**************
		
	gen overage2plus = 0 if attend==1 & P1088==2
	local primgrades 1 2 3 4 5
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if P1088S1==`grade' & schage>prim_age0+1+`i' & overage2plus!=.
		}

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 overage2plus {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia"
save Colombia_microdata.dta, replace


************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 overage2plus
 *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_1ybefore_no attend_higher_1822_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no  comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no overage2plus_no


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


set more off
set trace on
foreach i of numlist 0/15 {
	use Colombia_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2018"
gen country_year="Colombia"+"_"+year
destring year, replace
gen iso_code2="CO"
gen iso_code3="COL"
gen country = "Colombia"
gen survey="ECV"
replace category="total" if category==""
tab category

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


save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Colombia\indicators_Colombia_2019.dta", replace




