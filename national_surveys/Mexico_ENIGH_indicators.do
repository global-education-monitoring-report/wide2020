**Adapting widetable for other surveys

************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************


** Append all the databases
clear
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\poblacion.dta"
merge m:1 folioviv foliohog using "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\concentradohogar.dta", nogen
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\Mexico_2018.dta", replace

************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\Mexico_2018.dta",  clear

*Diccionario de datos
* https://www.inegi.org.mx/rnm/index.php/catalog/511/data_dictionary?idPro=

local country Mexico 
local sex sexo // poblacion
local urbanrural tam_loc // recode tam_loc
local hhweight factor // concentradohogar 
local age edad // poblacion
local wealth est_socio // se podria usar est_socio, hay 4 niveles
local region ubica_geo // concentradohogar, substr ubica_geo 

*Country
gen year="2018"
gen country_year="`country'"+"_"+year
destring year, replace
gen iso_code2="MX"
gen iso_code3="MEX"
gen country = "Mexico"
gen survey="ENIGH"

*Sex
destring `sex', replace
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
destring `wealth' , replace
rename `wealth' wealth
label define wealth 1 "Low" 2 "Medium Low" 3 "Medium High" 4 "High" 
label values wealth wealth

*Region fixing accents
gen entidadfederativa = substr(`region',1,2)
*La capital de México es el Distrito Federal (Ciudad de México), donde tienen sede los Poderes de la Unión (Ejecutivo, Legislativo y Judicial). La división política de México se compone de 32 entidades federativas: Aguascalientes, Baja California, Baja California Sur, Campeche, Coahuila, Colima, Chiapas, Chihuahua, Durango, Distrito Federal, Guanajuato, Guerrero, Hidalgo, Jalisco, México, Michoacán, Morelos, Nayarit, Nuevo León, Oaxaca, Puebla, Querétaro, Quintana Roo, San Luis Potosí, Sinaloa, Sonora, Tabasco, Tamaulipas, Tlaxcala, Veracruz, Yucatán, y Zacatecas.

destring entidadfederativa, replace
*https://es.wikipedia.org/wiki/Regiones_de_M%C3%A9xico

gen region = 1 if inlist(entidadfederativa, 1, 11, 22, 24, 32) // Centronorte
replace region = 2 if inlist(entidadfederativa, 9, 15, 17) // Centrosur
replace region = 3 if inlist(entidadfederativa, 5, 19, 28) // Noreste
replace region = 4 if inlist(entidadfederativa, 2, 3, 8, 10, 25, 26) // Noroeste
replace region = 5 if inlist(entidadfederativa, 18, 14, 6, 16) // Occidente
replace region = 6 if inlist(entidadfederativa, 21, 30, 29, 13) // Oriente
replace region = 7 if inlist(entidadfederativa, 4, 23, 27, 31) // Sureste
replace region = 8 if inlist(entidadfederativa, 7, 12, 20) // Suroeste

label define region 1 "Centronorte" 2 "Centrosur" 3 "Noreste" 4 "Noroeste" 5 "Occidente" 6 "Oriente" 7 "Sureste" 8 "Suroeste", replace
label values region region


*Location (urban-rural)
// 1	Localidades con 100 000 y más habitantes
// 2	Localidades con 15 000 a 99 999 habitantes
// 3	Localidades con 2 500 a 14 999 habitantes
// 4	Localidades con menos de 2 500 habitantes
*https://www.inegi.org.mx/eventos/2015/poblacion/doc/p-walterrangel.pdf

destring `urbanrural' , gen(location)
recode location (1 2 = 1) (3 4 = 0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\Mexico_2018.dta", replace

**CHECK WITH import delimited "C:\Users\taiku\Documents\GEM UNESCO MBR\WIDE_2019-01-23webfile.csv"

************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

clear 
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\Mexico_2018.dta"

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=4 // ISCED says 4-5, mexican friend says between 3 and 5, so 4
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
local highestlevelattended nivelaprob
local levelattendingcurrentyear nivel
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence

// *nivel (value recoded<-original value)
// 0<-01	Preescolar
// 0<-02	Estancias infantiles
// 0<-03	Guarderías públicas (IMSS, ISSSTE, SEDENA, SEMAR, PEMEX)
// 0<-04	Centro de Desarrollo Infantil (CENDI) o Centro Asistencial de Desarrollo Infantil (CADI)
// 0<-05	Otras guarderías
// 1<-06	Primaria
// 2<-07	Secundaria
// 3<-08	Carrera técnica con secundaria terminada
// 3<-09	Preparatoria o bachillerato
// 4<-10	Carrera técnica con preparatoria terminada
// 4<-11	Normal
// 6<-12	Profesional
// 7 or 8 depending on grado <-13	Maestría o doctorado
// *nivelaprob (value recoded<-original value)
// Valor	Categoría
// 0<-0	Ninguno
// 0<-1	Preescolar
// 1<-2	Primaria
// 2<-3	Secundaria
// 3<-4	Preparatoria o bachillerato
// 4<-5	Normal
// 4<-6	Carrera técnica o comercial
// 6<-7	Profesional
// 7<-8	Maestría
// 8<-9	Doctorado
*Following this 
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 

local highestlevelattended nivelaprob
local levelattendingcurrentyear nivel
destring `highestlevelattended' , replace
destring `levelattendingcurrentyear' , replace
destring grado, replace
destring gradoaprob, replace
destring asis_esc, replace

recode `levelattendingcurrentyear' (1 2 3 4 5=0) (6=1) (7=2) (8 9 =3) (10 11=4) (12=6), gen(levelattendingcurrentyear)
replace levelattendingcurrentyear=7 if inlist(grado, 1, 2)
replace levelattendingcurrentyear=8 if inlist(grado, 3, 4, 5)

recode `highestlevelattended' (0 1=0) (2=1) (3=2) (4 = 3) (5 6=4) (8=7) (9=8), gen(highestlevelattended)


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
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd

gen eduyears=.
replace eduyears=0 if highestlevelattended==0
replace eduyears=grado if highestlevelattended==1 // primaria 
replace eduyears=years_prim + grado if highestlevelattended==2 // low sec 
replace eduyears=years_lowsec + grado if highestlevelattended==3 // high sec
replace eduyears=years_upsec+grado if inlist(highestlevelattended, 4, 6) // post sec non tertiary etc and bachelor
replace eduyears=years_higher+grado if inlist(highestlevelattended, 7, 8) // master phd


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

gen preschool=1 if levelattendingcurrentyear==0
gen before1y=1 if age==prim_age0-1
gen presch1ybefore=preschool if before1y==1
drop before1y

ren presch1ybefore preschool_1ybefore

*P8586: "Attended school during current school year?"
generate attend = 1 if asis_esc == 1
replace attend  = 0 if asis_esc == 2
recode attend (1=0) (0=1), gen(no_attend)

***
****Higher education attendance: attend_higher_1822
***
generate high_ed = 1 if inlist(levelattendingcurrentyear, 4, 6, 7, 8)
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
capture replace eduout  = . if (attend == 1 & levelattendingcurrentyear == .) | age == . 
capture replace eduout  = 1 if levelattendingcurrentyear == 0  

*this from UIS_duration_age_01102020.dta
gen prim_age0_eduout = 6
gen prim_dur_eduout = 6
gen lowsec_dur_eduout = 3 
gen upsec_dur_eduout = 3

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
generate edu0 = 0 if inlist(highestlevelattended, 1, 2, 3, 4, 5, 6, 7, 8)
replace edu0  = 1 if inlist(highestlevelattended, 0)
replace edu0  = 1 if inlist(levelattendingcurrentyear, 0)
replace edu0  = 1 if eduyears == 0

generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(highestlevelattended, ., 0 )
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
		
	gen overage2plus = 0 if attend==1 & levelattendingcurrentyear==1
	local primgrades 1 2 3 4 5 6
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if grado==`grade' & schage>prim_age0+1+`i' & overage2plus!=.
		}
		
foreach var in comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_lowsec_2024 comp_upsec_2024 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 overage2plus{
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico"
save Mexico_microdata.dta, replace



************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024  comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 overage2plus *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_1ybefore_no attend_higher_1822_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no

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
foreach i of numlist 0/15 {
	use Mexico_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}



* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0


gen year="2018"
gen country_year="Mexico"+"_"+year
destring year, replace
gen iso_code2="MX"
gen iso_code3="MEX"
gen country = "Mexico"
gen survey="ENIGH"
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

save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Mexico\indicators_Mexico_2018.dta", replace


