**Adapting widetable for other surveys

************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

**Generate income quintiles 
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Brazil\PNADanualvisita1.dta", clear
gen householdincome = VD5010 
// VD5010 Rendimento domiciliar 
// Per capita household income (usual for all works and effective from other sources) (including income from transportation / food card / ticket)
//  (excluding the income of persons whose condition in the household was a pensioner, domestic servant or relative of the domestic servant) 

xtile hhwealthindex = householdincome [pw=V1032], nquantiles(5)
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Brazil\PNADanualvisita1.dta", replace
**



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Brazil\PNADanualvisita1.dta", clear


local country Brazil 
local sex V2007
local urbanrural  V1022
local hhweight V1032
*Two possible weights 
*V1032 1st visit annual weight with correction of non-interview with post stratification by population projection
local age V2009
local wealth hhwealthindex
local region UF
local ethnicity V2010



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

*Ethnicity
gen ethnicity=`ethnicity'

*Location (urban-rural)
rename `urbanrural' location
recode location (1=1) (2=0)
label define location 1 "Urban" 0 "Rural"
label val location location

compress


************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

**************************

*Following this 
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 
*		 9=HIGHER
*V3009A not clean, but has all levels
local levelattendingcurrentyear V3003A
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence

// recode VD3004, maybe use V3009A as another
// 0<-1	Sem instrução e menos de 1 ano de estudo
// code with another<-2	Fundamental incompleto ou equivalente 
// 2<-3	Fundamental completo ou equivalente
// 2<-4	Médio incompleto ou equivalente
// 3<-5	Médio completo ou equivalente
// code with another<-6	Superior incompleto ou equivalente
// 6 but code with another for 7 and 8<-7	Superior completo 
// 	Não aplicável

// V3013 Qual foi o último ano/série/semestre que ... concluiu com aprovação, neste curso que frequentou anteriormente
// 0<-01	Primeira (o)
// 0<-02	Segunda (o)
// 0<-03	Terceira (o)
// 0<-04	Quarta (o)
// 1<-05	Quinta (o)
// 1<-06	Sexta (o)
// 1<-07	Sétima (o)
// 1<-08	Oitava (o)
// 2<-09	Nona (o)
// 2<-10	Décimo
// 2<-11	Décimo primeiro
// 3<-12	Décimo segundo
**This is misleading, instead 

// VD3005 Anos de estudo (pessoas de 5 anos ou mais de idade) padronizado para o Ensino fundamental com duração de 9 anos

// V3009A Qual foi o curso mais elevado que ... frequentou anteriormente?
// 02	Pré-escola
// 03	Classe de alfabetização - CA
// 04	Alfabetização de jovens e adultos
// 05	Antigo primário (elementar)
// 06	Antigo ginásio (médio 1º ciclo)
// 07	Regular do ensino fundamental ou do 1º grau
// 08	Educação de jovens e adultos (EJA) ou supletivo do 1º grau
// 09	Antigo científico, clássico, etc. (médio 2º ciclo)
// 10	Regular do ensino médio óu do 2º grau
// 11	Educação de jovens e adultos (EJA) ou supletivo do 2º grau
// 12	Superior - graduação
// 13	Especialização de nível superior
// 14	Mestrado
// 15	Doutorado



local highestlevelattended VD3004
*VD3004 Highest level of education achieved (people aged 5 and over) standardized for 9-year elementary school
recode `highestlevelattended' (1=0) (3=2) (4=2) (5=3) (7=6), gen(highestlevelattended)
replace highestlevelattended=0 if inlist(VD3004, ., 2) & inlist(V3013, 0, 1, 2, 3, 4) // years before primary completion
replace highestlevelattended=1 if inlist(VD3004, ., 2) & inlist(V3013, 5, 6, 7, 8) //years before low sec completion
replace highestlevelattended=2 if inlist(VD3004, ., 2) & inlist(V3013, 9, 10, 11) //3 years of upsec
replace highestlevelattended=3 if inlist(VD3004, ., 2) & inlist(V3013, 12) //completed upsec
replace highestlevelattended=9 if inlist(VD3004, .,  6, 7) & inlist(VD3005, 14, 15, 16, 17) // must have higher ed for the number of years
replace highestlevelattended=7 if inlist(VD3004, .,  6, 7) & inlist(V3009A, 13) // master
replace highestlevelattended=8 if inlist(VD3004, .,  6, 7) & inlist(V3009A, 14) //phd


*recode `levelattendingcurrentyear' (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600=6) (700=7) (800=8), gen(levelattendingcurrentyear) // not used actlly


***Completion variables:  comp_prim_v2 comp_lowsec_v2 comp_upsec_v2  comp_prim_1524 comp_lowsec_1524 comp_upsec_2029

for X in any prim lowsec upsec: gen comp_X=0 if highestlevelattended!=.
replace comp_prim=1 if highestlevelattended >= 1 & comp_prim == 0
replace comp_lowsec=1 if highestlevelattended >= 2 & comp_lowsec == 0
replace comp_upsec=1 if highestlevelattended >= 3 & comp_upsec == 0

*This was adapted from old file keep_vars.do
** Education system information

* Primary
gen prim_age0 = 6
gen prim_age1 = 10
local primaryfirst = 1
local primarylast = 5
local prim_dur = 5
* Lower secondary
gen lowsec_age0 = 11
gen lowsec_age1 = 14
local lowsecondaryfirst = 6 
local lowersecondarylast = 9
local lowsec_dur = 4
* Upper secondary
gen upsec_age0 = 15
gen upsec_age1 = 17
local uppersecondaryfirst = 10 
local uppersecondarylast = 12
local upsec_dur = 3


*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=4 // according to ISCED
	gen years_prim   = `prim_dur'
	gen years_lowsec = `prim_dur'+`lowsec_dur'
	gen years_upsec  =`prim_dur'+`lowsec_dur'+`upsec_dur'
	gen years_higher = `prim_dur'+`lowsec_dur'+`upsec_dur'+higher_dur

	*Ages for completion
	*gen lowsec_age0=`primaryage0'+`prim_dur'
	*gen upsec_age0=`lowersecondaryage0'+`lowsec_dur'
	*for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1




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
*need to recode for 0 and grad and postgrad

gen eduyears= VD3005-1
*using ICSED theoretical durations 
replace eduyears=16 if VD3005==17 & V3009A==11 // Superior - graduação Bachelors
replace eduyears=17 if VD3005==17 & V3009A==12 //  Especialização de nível superior
replace eduyears=18 if VD3005==17 & V3009A==13 // Mestrado
replace eduyears=22 if VD3005==17 & V3009A==14 // Doutorado 


*DATA COLLECTION DAYS OF THE SURVEY
*Technical note in portuguese https://biblioteca.ibge.gov.br/visualizacao/livros/liv101708_notas_tecnicas.pdf
*Quote: "The collection of the 15 096 primary sampling units for a quarter is distributed over 12
*Weeks, in order to maintain a balance in the workload. So, every week,
*Approximately 1 310 (1/ 12 of the sample) primary sampling units are interviewed, and,
*Each month, about 5,032 primary sampling units (⅓ of the sample) are visited."

*The school year usually begins during the first week of February. There is a 2-week/4-week long winter break in July. The Brazilian school year ends the first week of December, summer in Brazil.

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.
*1/4 january - feb < 6 ; march - feb < 6
*1/4 april - feb < 6 ; june - feb < 6 
*1/4 july - feb < 6 ; september - feb > 6 --> adjust 2/3rds
*1/4 october - feb > 6 ; december - feb > 6--> adjust all
*42% or 5/12 of hh have 6 months of difference or more

destring Trimestre, replace
gen schage = age-1 if inlist(Trimestre, 4)
replace schage=age if inlist(Trimestre, 1, 2)
gen random3rd= runiform() if Trimestre==3
gen order3rd=_n-222572 if Trimestre==3 
generate adjusted3rd = order3rd <= 37115 if Trimestre==3 // one third of the 111,345 observations ==1
replace schage=age if Trimestre==3 & adjusted3rd==1
replace schage=age-1 if Trimestre==3 & adjusted3rd==0
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

// gen preschool=1 if P1088==1
// gen before1y=1 if age==prim_age0-1
// gen presch1ybefore=preschool if before1y==1
// drop before1y
//
// ren presch1ybefore preschool_1ybefore

*P8586: "Attended school during current school year?"
generate attend = 1 if V3002 == 1
replace attend  = 0 if V3002 == 2
recode attend (1=0) (0=1), gen(no_attend)

// ***
// ****Higher education attendance: attend_higher_1822
// ***
// generate high_ed = 1 if inlist(P1088, 5, 6, 7, 8)
// *use level attending now 
// capture generate attend_higher = 1 if attend == 1 & high_ed == 1
// capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
// capture replace attend_higher  = 0 if attend == 0
// capture generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

***
***Out-of-school: eduout_prim eduout_lowsec eduout_upsec
***
* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
*P1088 should be level attending?
*V3003A Qual é o curso que ... frequenta?

generate eduout = no_attend
capture replace eduout  = . if (attend == 1 & V3003A == .) | age == . //missings
capture replace eduout  = 1 if V3003A == 1  // preschool

*this from UIS_duration_age_01102020.dta
gen prim_age0_eduout = 6
gen prim_dur_eduout = 5
gen lowsec_dur_eduout = 4 
gen upsec_dur_eduout = 3

generate lowsec_age0_eduout = prim_age0_eduout + prim_dur_eduout
generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur_eduout
for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age0_eduout + X_dur_eduout - 1

*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}

// ***
// ***NEVER BEEN TO SCHOOL: edu0_prim
// ***
// generate edu0 = 0 if inlist(P8587, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
// replace edu0  = 1 if inlist(P8587, 1)
// replace edu0  = 1 if inlist(P1088, 1)
// replace edu0  = 1 if eduyears == 0

// generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*P8587 is highest level achieved 
*VD3004 Nível de instrução mais elevado alcançado (pessoas de 5 anos ou mais de idade) padronizado para o Ensino fundamental com duração de 9 anos


*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(VD3004, ., 1 )
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


*w all indicators
// foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 {
// gen `var'_no=`var'
// }

 ***********OVER-AGE PRIMARY ATTENDANCE**************
		
	gen overage2plus = 0 if attend==1 & V3003A==3
	local primgrades 1 2 3 4 5
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if V3006==`grade' & schage>prim_age0+1+`i' & overage2plus!=.
		}
		
	*****************************************************


foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024  comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 overage2plus   eduout_prim eduout_lowsec eduout_upsec  edu2_2024 edu4_2024 {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Brazil"
save Brazil_microdata.dta, replace


************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region ethnicity
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029   eduout_prim eduout_lowsec eduout_upsec  comp_higher_4yrs_3034 comp_higher_2yrs_2529 comp_higher_4yrs_2529 overage2plus edu2_2024 edu4_2024  *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduout_prim_no eduout_lowsec_no eduout_upsec_no  edu2_2024_no edu4_2024_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no overage2plus_no
 

// global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore attend_higher_1822 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024  *age0 *age1 *dur 
// global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_1ybefore_no attend_higher_1822_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no


tuples $categories_collapse, display
/*
tuples $categories_collapse, display
tuple1: ethnicity
tuple2: region
tuple3: wealth
tuple4: sex
tuple5: location
tuple6: region ethnicity
tuple7: wealth ethnicity
tuple8: wealth region
tuple9: sex ethnicity
tuple10: sex region
tuple11: sex wealth
tuple12: location ethnicity
tuple13: location region
tuple14: location wealth
tuple15: location sex
tuple16: wealth region ethnicity
tuple17: sex region ethnicity
tuple18: sex wealth ethnicity
tuple19: sex wealth region
tuple20: location region ethnicity
tuple21: location wealth ethnicity
tuple22: location wealth region
tuple23: location sex ethnicity
tuple24: location sex region
tuple25: location sex wealth
tuple26: sex wealth region ethnicity
tuple27: location wealth region ethnicity
tuple28: location sex region ethnicity
tuple29: location sex wealth ethnicity
tuple30: location sex wealth region
tuple31: location sex wealth region ethnicity
*/


set more off
foreach i of numlist 0/31 {
	use Brazil_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Brazil"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/31 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2019"
gen country_year="Brazil"+"_"+year
destring year, replace
gen iso_code2="BR"
gen iso_code3="BRA"
gen country = "Brazil"
gen survey="PNAD"
replace category="total" if category==""
	
	
// 	label define UF 1 "Rondônia" 2 "Acre" 3 "Amazonas" 4 "Roraima" 5 "Pará" 6 "Amapá" 7 "Tocantins" 8 "Maranhão" 9 "Piauí" 10 "Ceará" 11 "Rio Grande do Norte" 12 "Paraíba" 13 "Pernambuco" 14 "Alagoas" 15 "Sergipe" 16 "Bahia" 17 "Minas Gerais" 18 "Espírito Santo" 19 "Rio de Janeiro" 20 "São Paulo" 21 "Paraná" 22 "Santa Catarina" 23 "Rio Grande do Sul" 24 "Mato Grosso do Sul" 25 "Mato Grosso" 26 "Goiás" 27 "Distrito Federal", replace
// 	label define V2010 1 "Branca" 2 "Preta" 3 "Amarela" 4 "Parda" 5 "Indígena" 6 "Ignorado", replace
// 	label values region UF
// 	label values ethnicity V2010
//
// 	decode region, gen(region_s)
// 	decode ethnicity, gen (ethnicity_s)
//	
		global categories_collapse location sex wealth region ethnicity

	*-- Fixing for missing values in categories
	*for X in any $categories_collapse: decode X, gen(X_s)
	for X in any $categories_collapse: drop X
	for X in any $categories_collapse: ren X_s X

	*Putting the names in the same format as the others
	global categories_collapse location sex wealth region ethnicity
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

				 

save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Brazil\indicators_Brazil_2019.dta", replace



