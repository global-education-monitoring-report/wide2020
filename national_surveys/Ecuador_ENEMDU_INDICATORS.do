**Adapting widetable for other surveys
*THE MODEL OF THIS CODE IS TAKEN FROM EU_SILC_June2018.do MOSTLY


************************************************************************************************************
*************PART 1: merge surveys and categories calculations**********************************************
************************************************************************************************************

*Calulating wealth variables

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador\ENEMDU_acumulada_BDDpersona2018.dta", clear

*Total per capita income
xtile hhwealthindex = ingpc [aw=fexp], nquantiles(5)

save Ecuador_2018.dta, replace



************************************************************************************************************
*************PART 2: rename and define category variables **************************************************
************************************************************************************************************


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"
use Ecuador_2018, clear 

local country Ecuador 
local sex p02
local urbanrural area // location
local hhweight fexp //
local age p03
local wealth hhwealthindex
local region prov

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
decode prov, gen(provincias)
replace provincias = proper(provincias)
replace provincias="Cañar" if provincias=="CañAr"
replace provincias="Los RíOs" if provincias=="Los Ríos"
replace provincias="Los Ríos" if provincias=="Los RíOs"
replace provincias="Santo Domingo De Los Tsáchilas" if provincias=="Santo Domingo De Los TsáChilas"
replace provincias="Sucumbíos" if provincias=="SucumbíOs"
replace provincias="Bolívar" if provincias=="BolíVar"
drop prov
encode provincias, gen(prov)
drop provincias
rename `region' region


*Location (urban-rural)
rename `urbanrural' location
recode location (1 = 1) (2 = 0)
label define location 1 "Urban" 0 "Rural"
label val location location

*Ethnicity, get rid of few others
recode p15 (8=.), gen(ethnicity)
tab ethnicity
label val ethnicity p15


compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"
save Ecuador_2018.dta, replace



************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"
use Ecuador_2018, clear 

gen country_year="Ecuador"+"_"+"2018"
gen year=2017
gen iso_code2="EC"
gen iso_code3="ECU"
gen country = "Ecuador"
gen survey="ENEMDU"

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

// ninguno					1	0	
// centro de alfabetización	2	0	correct years
// primaria					4	0	correct complete primary
// educación básica			5	0	correct primary lowsec
// secundaria				6	2	correct low y up sec
// educación  media			7	2	correct upsec 
// superior no universitario8	5	
// superior universitario	9	6	
// post-grado				10	7	
*See questionnaire to understand many names page 2

local highestlevelattended p10a 

recode `highestlevelattended' (1 2 4 5=0) (6 7=2) (8=5) (9=6) (10=7), gen(highestlevelattended)
replace highestlevelattended=0 if p10a==2 & inlist(p10b, 0, 1, 2, 3, 4, 5) // alfabetización maximo es primaria 
replace highestlevelattended=1 if p10a==2 & inlist(p10b, 6, 7, 8, 9, 10) // alfabetización maximo es primaria 
replace highestlevelattended=0 if p10a==4 & inlist(p10b, 0, 1, 2, 3, 4, 5) // primaria incompleta 
replace highestlevelattended=1 if p10a==4 & inlist(p10b, 6) // primaria completa
replace highestlevelattended=0 if p10a==5 & inlist(p10b, 0, 1, 2, 3, 4, 5) // basica prim incompleta
replace highestlevelattended=1 if p10a==5 & inlist(p10b, 6, 7, 8) // basica lowsec incompleto
replace highestlevelattended=2 if p10a==5 & inlist(p10b, 9, 10) // basica lowsec
replace highestlevelattended=1 if p10a==6 & inlist(p10b, 0, 1, 2) // secundaria incompleta
replace highestlevelattended=2 if p10a==6 & inlist(p10b, 3, 4, 5) // secundaria lowsec
replace highestlevelattended=3 if p10a==6 & inlist(p10b, 6) // secundaria upsec
replace highestlevelattended=2 if p10a==7 & inlist(p10b, 1, 2) // media/bachillerato incompleto
replace highestlevelattended=3 if p10a==7 & inlist(p10b, 3) // media/bachillerato

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

*6-3-3 start at 6

// ninguno					1	0	
// centro de alfabetización	2	0	correct years
// primaria					4	0	correct complete primary
// educación básica			5	0	correct primary lowsec
// secundaria				6	2	correct low y up sec
// educación  media			7	2	correct upsec 
// superior no universitario8	5	
// superior universitario	9	6	
// post-grado				10	7	
*See questionnaire to understand many names page 2

gen eduyears=.
replace eduyears=0 if inlist(p10a, 1)  // no level 
replace eduyears=p10b  if inlist(p10a, 2, 4, 5) // primary , basica, alfabetización 
replace eduyears=years_prim+p10b  if inlist(p10a, 6) // secondary
replace eduyears=years_lowsec+p10b  if inlist(p10a, 7) // media/bachillerato
replace eduyears=years_upsec+p10b  if inlist(p10a, 8) // superior no universitaria incompleta y completa
replace eduyears=years_upsec+p10b if inlist(p10a, 9) // superior universitaria incompleta y completa
replace eduyears=years_higher+4.5+p10b  if inlist(p10a, 10) // assuming bachelor of 4.5 years 

//  *Años promedio de escolaridad                        
// gen escol =0 if p10a==1
// replace escol = 0 if p10a==2 & p10b==0
// replace escol = 2 if p10a==2 & p10b==1
// replace escol = 4 if p10a==2 & p10b==2
// replace escol = 6 if p10a==2 & p10b==3
// replace escol = 7 if p10a==2 & p10b==4
// replace escol = 8 if p10a==2 & p10b==5
// replace escol = 9 if p10a==2 & p10b==6
// replace escol = 10 if p10a==2 & p10b==7
// replace escol = 11 if p10a==2 & p10b==8
// replace escol = 12 if p10a==2 & p10b==9
// replace escol = 13 if p10a==2 & p10b==10
// replace escol = 1 if p10a==3
// replace escol = (1 + p10b) if p10a==4
// replace escol = p10b if p10a==5
// replace escol = (7+p10b) if p10a==6
// replace escol = (10+p10b) if p10a==7
// replace escol = (13+p10b) if p10a==8
// replace escol = (13+p10b) if p10a==9
// replace escol = (18+p10b) if p10a==10

 
*DATA COLLECTION DAYS OF THE SURVEY
*http://anda.ine.gob.bo/index.php/catalog/84#metadata-data_collection
*During all year since its a cumulated survey, but theres no info on the month

*According to some web: 
*Dates:  The school year begins differently according to region, for Sierra amazonia SEPTIEMBRE
*https://educacion.gob.ec/estudiantes-de-sierra-amazonia-inician-clases-este-03-de-septiembre/
*https://www.elcomercio.com/actualidad/abril-inicio-clases-costa-ministeriodeeducacion.html#:~:text=Los%20estudiantes%20del%20ciclo%20Costa,16%20de%20abril%20del%202018.


*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Calculating if (month_interv-month_school)>=6 months.

gen schage = age - 1

*% of households have a difference of over 6 months=> no adjustment 


***
***Mean years of education: eduyears_2024
***
generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24

***
***Pre-primary education attendance: this survey has no information on people younger than 5 years old, nor a question on preschool 
***
// *Percentage of children attending any type of pre–primary education programme, 
// *(i) as 3–4 year olds and NOT THIS
// *(ii) 1 year before the official entrance age to primary. THIS
//
// 	 generate attend_preschool   = 1 if p308a == 1 // enrolled in preschool 
// 	 replace attend_preschool    = 0 if p306 == 2 //not enrolled in current year in anything
// 	 replace attend_preschool    = 0 if p307 == 2 //not assisting
// 	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
// 	 generate preschool_1ybefore = attend_preschool if schage == prim_age0 - 1


*P8586: "Attended school during current school year?" 5+ years old
generate attend = 1 if p07 == 1 //attending 
replace attend  = 0 if p07 == 2 | p07 == 3 //not assisting

recode attend (1=0) (0=1), gen(no_attend)

***
// superior no universitario8	5	
// superior universitario	9	6	
// post-grado				10	7

***
generate high_ed = 1 if inlist(p10a, 8, 9, 10) 
*use highest level + attending 
capture generate attend_higher = 1 if attend == 1 & high_ed == 1
capture replace attend_higher  = 0 if attend == 1 & high_ed != 1
capture replace attend_higher  = 0 if attend == 0
capture generate attend_higher_1822 = attend_higher if schage >= 18 & schage <= 22

***
***Out-of-school: eduout_prim eduout_lowsec eduout_upsec
***
* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
generate eduout = no_attend
capture replace eduout  = . if (attend == 1 & p10a == .) | age == . 


*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0 & schage <= `X'_age1
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
*S5_1 Did [NAME] ever go to school?
generate edu0 = 0 if p10a>1
replace edu0  = 1 if p10a==0
replace edu0  = 1 if eduyears == 0
// replace edu0  = 1 if inlist(p301a, 2) //preschool


generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(p10a, .)
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
gen overage2plus= 0 if attend==1 & inlist(p10a, 4)
*There are 6 years of primary
	local i=0
    foreach grade of numlist 1/6 {
				local i=`i'+1
				replace overage2plus=1 if p10b==`grade' & schage>prim_age0+1+`i'
                 }

* Literacy, tested on 14+ years old people
*SELF REPORTED: can you read and write?
// recode p308c (2=0) (1=1), gen(literacy)
// replace literacy=. if age<15
// label def literacy 0 " Illiterate/Semi-literate" 1 "Literate"
// label val literacy literacy

*Literacy following the code of ENEMDU
gen literacy=0 if (p03>=15 & p03<=98 & p10a >=6 & p10a<=10)
replace literacy=0 if (p03>=15 & p03<=98 & p10a >=1 & p10a<=5 & p11==1)
replace literacy =1 if (p03>=15 & p03<=98 & p10a >=1 & p10a<=5 & p11==2)

*GET RID OF PRESCHOOL
foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy {
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"
save Ecuador_microdata.dta, replace

************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

global categories_collapse location sex wealth region ethnicity
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024  attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no

tuples $categories_collapse, display
/*
. tuples $categories_collapse, display
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

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"

*TAKES LONG
set more off
set trace on
foreach i of numlist 0/12 14/19 21 23/26 29 {
	use Ecuador_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/12 14/19 21 23/26 29 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2018"
gen country_year="Ecuador"+"_"+year
destring year, replace
gen iso_code2="EC"
gen iso_code3="ECU"
gen country = "Ecuador"
gen survey="ENEMDU"
replace category="total" if category==""
tab category

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024  attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus literacy *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no eduyears_2024_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_no literacy_no


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
order iso_code2 iso_code3 country survey year country_year category Region Location Wealth Sex ethnicity
save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\Ecuador\indicators_Ecuador_2018.dta", replace

