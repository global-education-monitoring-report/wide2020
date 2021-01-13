**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2017.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************


*Just one data file
clear
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile\Casen 2017.dta"

*Variable qaut for quintiles already exists

save Chile_2017.dta, replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"
use Chile_2017, clear 

local country Chile 
local sex sexo
local urbanrural zona  // location
local hhweight expr //
local age edad
local wealth qaut
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
label define region 1 "Región de Tarapacá" 2 "Región de Antofagasta" 3 "Región de Atacama" 4 "Región de Coquimbo" 5 "Región de Valparaíso" 6 "Región del Libertador Gral. Bernardo O'Higgins" 7 "Región del Maule" 8 "Región del Biobío" 9 "Región de La Araucanía" 10 "Región de Los Lagos" 11 "Región de Aysén del Gral. Carlos Ibáñez del Campo" 12 "Región de Magallanes y de la Antártica Chilena" 13 "Región Metropolitana de Santiago" 14 "Región de Los Ríos" 15 "Región de Arica y Parinacota" 16 "Región de Ñuble", replace
*rename `region' region
label values region region


*Location (urban-rural)
rename `urbanrural' location
recode location (1 = 1) (2 = 0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"
save Chile_2017.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"
use Chile_2017, clear 

gen country_year="Chile"+"_"+"2017"
gen year=2017
gen iso_code2="CL"
gen iso_code3="CHL"
gen country = "Chile"
gen survey="CASEN"

merge m:1 iso_code3 year using "C:\ado\personal\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=4 // according to ISCED, 4-5 years licenciatura 4-7 years grado academico
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
*https://www.redatam.org/redchl/mds/casen/WebHelp/informaci_n_casen/conceptos_y_definiciones/educaci_n/tipo_de_estudios.htm
*6-2-4 starts at 6y

// Nunca asisti�							1	=>	0	
// Sala cuna								2	=>	0	
// Jard�n Infantil (Medio menor y Medio ma	3	=>	0	
// Prekinder/Kinder (Transici�n menor y Tr	4	=>	0	
// Educaci�n Especial (Diferencial)			5	=>	0	
// Primaria o Preparatoria (Sistema antigu	6	=>	0	correct for complete primary
// Educaci�n B�sica							7	=>	0	correct for complete primary and lowsec
// Humanidades (Sistema Antiguo)			8	=>	1	correct for lowsec and upsec
// Educaci�n Media Cient�fico-Humanista		9	=>	2	correct for complete upsec
// T�cnica, Comercial, Industrial o Normal	10	=>	1	correct for lowsec and upsec
// Educaci�n Media T�cnica Profesional		11	=>	2	correct for upsec 
// T�cnico Nivel Superior Incompleto (Carr	12	=>	3	
// T�cnico Nivel Superior Completo (Carrer	13	=>	4	
// Profesional Incompleto (Carreras 4  o m	14	=>	3	
// Profesional Completo (Carreras 4 o m�s	15	=>	4	
// Postgrado Incompleto						16	=>	6	
// Postgrado Completo						17	=>	7	
// No sabe/no responde						99	=>	.	

local highestlevelattended e6a 

recode `highestlevelattended' (1/7=0) (8 10=1) (9 11=2) (12 14=3) (13 15=4) (16=6) (17=7) (99=.) , gen(highestlevelattended)
replace highestlevelattended=1 if e6a==6 & inlist(e6b, 6)
replace highestlevelattended=1 if e6a==7 & inlist(e6b, 6, 7)
replace highestlevelattended=2 if e6a==7 & inlist(e6b, 8)
replace highestlevelattended=2 if e6a==8 & inlist(e6b, 6, 7)
replace highestlevelattended=3 if e6a==8 & inlist(e6b, 8)
replace highestlevelattended=2 if e6a==9 & inlist(e6b, 1, 2, 3)
replace highestlevelattended=3 if e6a==9 & inlist(e6b, 4)
replace highestlevelattended=2 if e6a==10 & inlist(e6b, 2, 3)
replace highestlevelattended=3 if e6a==10 & inlist(e6b, 4, 5, 6)
replace highestlevelattended=3 if e6a==11 & inlist(e6b, 1, 2, 3)
replace highestlevelattended=4 if e6a==11 & inlist(e6b, 4, 5)


*recode `levelattendingcurrentyear' (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600=6) (700=7) (800=8), gen(levelattendingcurrentyear)


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

*6-2-4 start at 6

gen eduyears=.

replace eduyears=0 if inlist(e6a, 1, 2, 3, 4, 5, 99)  // no level and preschool and missing
replace eduyears=e6b  if inlist(e6a, 6, 7) // primary and educacion basica 
replace eduyears=years_prim+e6b  if inlist(e6a, 8, 10) // humanidades y T�cnica, Comercial, Industrial o Normal 
replace eduyears=years_lowsec+e6b  if inlist(e6a, 9, 11 ) // Educaci�n Media T�cnica Profesional y Educaci�n Media Cient�fico-Humanista	
replace eduyears=years_upsec+e6b if inlist(e6a, 12, 13, 14, 15, 16, 17) // toda educacion superior

 
*DATA COLLECTION DAYS OF THE SURVEY
*http://anda.ine.gob.bo/index.php/catalog/84#metadata-data_collection
*During all year
codebook fecha_mes fecha_dia  

*According to some web: 
*Dates:  The school year begins in March. 
*https://www.ayudamineduc.cl/sites/default/files/cuadrocalendarioescolarregional2017.pdf

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.

gen schage = age - 1

*51.77% of households have a difference of over 6 months=> no adjustment 


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

	 generate attend_preschool   = 1 if inlist(e6a, 2, 3, 4) // enrolled in preschool 
	 replace attend_preschool    = 1 if e9te == 10 // asistio educacion parvularia
	 replace attend_preschool    = 0 if e3 == 2 //not assisting to anything
	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?"
generate attend = 1 if e3 == 1
replace attend  = 0 if e3 == 2 //not attending 

recode attend (1=0) (0=1), gen(no_attend)

***
// T�cnico Nivel Superior Incompleto (Carr	12	=>	3	
// T�cnico Nivel Superior Completo (Carrer	13	=>	4	
// Profesional Incompleto (Carreras 4  o m	14	=>	3	
// Profesional Completo (Carreras 4 o m�s	15	=>	4	
// Postgrado Incompleto						16	=>	6	
// Postgrado Completo						17	=>	7	

***
generate high_ed = 1 if inlist(e6a, 12, 13, 14, 15, 16, 17)
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
capture replace eduout  = . if (attend == 1 & e6a == .) | age == . 


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if e6a>1
replace edu0  = 1 if e5b==5 //never assisted 
replace edu0  = 1 if e6a==1 //never assisted - level 
replace edu0  = 1 if eduyears == 0
replace edu0  = 1 if inlist(e6a, 2, 3, 4) //preschool


generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(e6a, .)
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
gen overage2plus= 0 if attend==1 & inlist(e6a, 6, 7)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 1/6 {
				local i=`i'+1
				replace overage2plus=1 if e6b==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
recode e1 (2/4=0) (1=1) (5=.), gen(literacy)
replace literacy=. if age<15
label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
label val literacy literacy

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore preschool_3 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"
save Chile_microdata.dta, replace

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

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"


set more off
set trace on
foreach i of numlist 0/15 {
	use Chile_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2017"
gen country_year="Chile"+"_"+year
destring year, replace
gen iso_code2="CL"
gen iso_code3="CHL"
gen country = "Chile"
gen survey="CASEN"
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

				 

save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Chile\indicators_Chile_2017.dta", replace

