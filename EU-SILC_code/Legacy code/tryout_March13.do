global dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global tryout "$dir\WIDE\WIDE_EU_SILC\Tryout"
global data "$dir\Data\EU_SILC"
global data_raw "$dir\WIDE\WIDE_EU_SILC\data"
global aux_data "$dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"


************************************************************************************************************
************************************************************************************************************
*Don't have some years:
	* BG, CH, MT, RO	: starts 2007 
	* CH 				: starts 2007 and doesn't have 2017
	* HR				: starts 2010
	* RS				: starts 2013 & doesn't have 2017
	* IE, IS, NO, UK 	: Don't have 2017 

set more off
foreach X in D H P R {
foreach Y in AT BE CY CZ DE DK EE EL ES FI FR HU IT LT LU LV NL PL PT SE SI SK {
foreach num in 05 11 13 14 15 16 17 {
	insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	display "****************************************"
	display " `Y' `X' 20`num' "
	display "****************************************"

	cap ren *, lower
	cap keep pb010 pb020 pb030 pb060* pb100* pb110* pe* px010 px030
	cap keep rb010 rb020 rb030 rb050* rb070* rb080* rb090* rl* rx010 rx030
	cap keep hb010 hb020 hb030 hb050* hb060* hx090*
	cap keep db010 db020 db030 db040* db090* db100*

	cap format px030 %25.0f
	for X in any pb030 px030: cap gen X_str=string(X, "%25.0f")
	cap gen individual_id=pb020+" "+string(pb010)+" "+pb030_str
	cap gen household_id =pb020+" "+string(pb010)+" "+px030_str

	cap format rx030 %25.0f
	for X in any rb030 rx030: cap gen X_str=string(X, "%25.0f")
	cap gen individual_id=rb020+" "+string(rb010)+" "+rb030_str
	cap gen household_id=rb020+" "+string(rb010)+" "+rx030_str
	
	for X in any hb030: cap gen X_str=string(X, "%25.0f")
	cap gen household_id =hb020+" "+string(hb010)+" "+hb030_str
	
	for X in any db030: cap gen X_str=string(X, "%25.0f")
	cap gen household_id =db020+" "+string(db010)+" "+db030_str

	cap tostring db040, replace
	cap drop *b010 *b020 *b030 
	cap drop *x030
	cap drop *_str
	cap compress
	cap save "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.dta", replace
*Keeping the variable in module R (all ages) because it is more complete than in module P (only 16+)
	*pb150=rb090; pb040=rb050; pb130=rb070; pb140=rb080; px020=rx020
}
}
}

set more off
foreach Y in AT BE CY CZ DE DK EE EL ES FI FR HU IT LT LU LV NL PL PT SE SI SK {
foreach num in 05 11 13 14 15 16 17 {
	use "$data\\`Y'\\20`num'\UDB_c`Y'`num'R.dta", clear
	display "****************************************"
	display " `Y' 20`num' "
	display "****************************************"
	merge 1:1 individual_id using "$data\\`Y'\\20`num'\UDB_c`Y'`num'P.dta", gen(merge_persons)
	merge m:1 household_id using "$data\\`Y'\\20`num'\UDB_c`Y'`num'H.dta", gen(merge_hh1)
	merge m:1 household_id using "$data\\`Y'\\20`num'\UDB_c`Y'`num'D.dta", gen(merge_hh2)
	compress
	save "$data_raw\All\\`Y'_20`num'.dta", replace
}
}

*****************************************************
****************************************************

** Append all the databases

cd "$data_raw\All"
local allfiles : dir . files "*.dta"
use "AT_2005.dta", clear
gen id_c=1

foreach f of local allfiles {
	qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c
*Drop the flags 
drop *_f
*codebook merge_hh1 merge_hh2, tab(100)
*codebook indiv house // unique id
drop merge_hh1 merge_hh2
tab rx010 merge_persons
drop merge_persons
drop px010
drop pb060
compress
save "$data_raw\EU_SILC_full.dta", replace

*****************************************************
****************************************************
use "$data_raw\EU_SILC_full.dta", clear
gen code_country=substr(household_id,1,2)
*Fix to the name of countries (Greece)
replace code_country="GR" if code_country=="EL"
gen year=substr(household_id,4,4)
gen cy=code_country+"_"+year
destring year, replace
*tab year

gen iso_code2=code_country
merge m:1 iso_code2 using "$aux_data\country_iso_codes_names.dta", keepusing(iso_code3 country)  keep(match) nogen
drop iso_code2 code_country

*Sex
recode rb090 (1=1) (2=0), gen(sex)
label define sex 1 "Male" 0 "Female"
label val sex sex
drop rb090

* Degree of urbanization
*codebook db100, tab(100)
*tab year db100, m
*tab year if db100==.
*tab cy if db100==. //DE, NL, SI don't report location

g urban = "Intermediate or densely populated area" if (db100==1|db100==2)
replace urban = "Thinly populated area" if (db100==3)
drop db100

*Weight
ren rb050 hhweight
lab var hhweight "HH weight"

*Age
label var rb070 "Quarter of birth (rb070)"
label var rb080 "Year of birth (rb080)"
*codebook rx010, tab(100)
label var rx010 "Age at the date of the interview (rx010)"
clonevar age=rx010 
drop rx010

* Wealth
xtile wealth = hx090, nquantiles(5)
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth
drop hx090

*Region
clonevar region=db040
drop db040
replace region="" if region=="."
*codebook region
*tab cy if region=="" // DE, NL, PT, SI
order iso_code3 country year cy sex age urban wealth region individual_id household_id hhweight
compress
save "$data_raw\Step1.dta", replace

************************************************************************************************************
************************************************************************************************************
use "$data_raw\Step1.dta", clear
merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018_FLAGS.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
ren prim_age_uis prim_age0
*With info of duration of primary and secondary I can compare official duration with the years of education completed..
	gen higher_dur=3 // in the Bologna convention is 3 years.
	gen years_prim   = prim_dur
	gen years_lowsec = prim_dur+lowsec_dur
	gen years_upsec  = prim_dur+lowsec_dur+upsec_dur
	gen years_higher = prim_dur+lowsec_dur+upsec_dur+higher_dur

	*Ages for completion
	gen lowsec_age0=prim_age0+prim_dur
	gen upsec_age0=lowsec_age0+lowsec_dur
	for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1

*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 

recode pe020 (10=1) (20=2) (30/35=3) (40/45=4) (50=5) (60=6) (70=7) (80=8), gen(t_pe020)
recode pe040 (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600=6) (700=7) (800=8), gen(t_pe040)

*codebook t_pe020 t_pe040, tab(100)
tab t_pe040 year 

*Short cycle of secondary: 1 years
*Bachelor: 3 years

gen eduyears=.
replace eduyears=0 if t_pe040==0
replace eduyears=years_prim if t_pe040==1
replace eduyears=years_lowsec if t_pe040==2
replace eduyears=years_upsec if t_pe040==3
replace eduyears=years_upsec+1 if (t_pe040==4|t_pe040==5)
replace eduyears=years_higher if t_pe040==6
replace eduyears=years_higher+2 if t_pe040==7
replace eduyears=years_higher+4 if t_pe040==8


foreach X in prim lowsec upsec higher {
	gen comp_`X'=0
	replace comp_`X'=1 	if eduyears>=years_`X'
	replace comp_`X'=. 	if (eduyears==.)
	replace comp_`X'=0 	if eduyears==0 // those that went to kindergarten max have no completed primary.
}
	
*Age limits for Version B
foreach X in prim lowsec upsec {
*foreach AGE in ageU ageA {
foreach AGE in age {
	gen comp_`X'_v2=comp_`X' if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5 
}
}

foreach X in upsec {
*foreach AGE in ageU ageA {
foreach AGE in age {
	gen comp_`X'_2024=comp_`X' if `AGE'>=20 & `AGE'<=24 
}
}


compress
save "$data_raw\Step2.dta", replace

use "$data_raw\Step2.dta", clear
codebook rl010, tab(100)
tab rl010 year, m

*Recode vars
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)

tab cy preschool
tab rl010 cy if country=="Germany"


collapse comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_upsec_2024 *age0 *age1 *dur  [iw=hhweight], by(country year)

*Date of interview
codebook pb100 hb050 pb110 hb060, tab(100)

bys household_id: egen t_month=max(pb100)
bys household_id: egen t_month_m=min(pb100)

count if t_month!=t_month_m & pb100==. //934 obs
count if t_month==t_month_m & pb100==.
tab cy if t_month!=t_month_m

display 934/3318960 // less than 0.05% of total is different within households

bys household_id: egen t_year=max(pb110)
bys household_id: egen t_year2=min(pb110)



gen month_int=pb100
replace month_int=t_month if month_int==. & t_month!=.
replace month_int=hb050 if month_int==. & hb050!=. //424 changes

gen year_int=pb110
replace year_int=t_year if year_int==.
replace year_int=hb060 if year_int==. & hb060!=. // 71 changes

drop pb100 pb110 hb050 hb060

tab cy if month_int==.
tab cy if year_int==.

recode month_int (1=2) (2=5) (3=8) (4=11) // Quarters to the month in the middle of that quarter

drop iso_code2
merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018_FLAGS.dta"
tab cy if _merge==1

*** Codebook pe020 pe040
codebook pe020 pe040, tab(100)

tab pe020 year, m

tab pe040 year, m


*post sec non tertiary, short cycle tertiary assumed to be 2 years!!
*Master assumed 2 years, PhD assumed 4 years (only  229 obs) 



gen year_c=year
merge m:1 iso_code3 year_c using "$aux_data\UIS\months_school_year\month_start.dta", keepusing(month_start) keep(match) nogen
drop year_c
cap drop _merge



* Highest education level attained
rename pe040 highlevl

* Enrolment 
rename pe010 enrolment

* Current educational level attended
rename pe020 edlevel

*preschool // added
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)


************************************


codebook month_int year_int
br if month_int==.

gen year_int=



tab cy if pb100==.
tab cy if pb110==.




********************

recode pe020 (10=1) (20=2) (30/35=3) (40/45=4) (50=5) (60/80=6) if pb010==2014
recode pe040 (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600/800=6) if pb010==2014

* Highest education level attained
rename pe040 highlevl

* Enrolment 
rename pe010 enrolment

* Current educational level attended
rename pe020 edlevel

*preschool // added
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)

*Completion
codebook db040, tab(100)
tab year if db040=="" 

br if db040=="" & year==2011 // 53 obs. All in FI
tab code_c if db040=="" & year==2011

br if db040=="" & year==2014 // 3 obs. FR & HU
br if db040=="" & year==2017 // 27 obs. FR  

codebook merge_persons merge_hh1 merge_hh2, tab(100)


*Completion
for X in any 2005 2011 2013 2014 2015 2016 2017: codebook pe020 pe040 if year==X, tab(100)
for X in any  2016 : codebook pe020 pe040 if year==X, tab(100)

*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 50=short cycle tertiary, 6=bachelor; 7=postgrad 

tab code_c if year==2016 & pe020==60 // 442 obs. all in PL
tab code_c if year==2016 & pe020==70 // 229 obs. all in PL
tab code_c if year==2016 & pe020==80 // 23 obs. all in PL

tab code_c if year==2017 & pe020==60 // 505 obs. all in PL
tab code_c if year==2017 & pe020==70 // 272 obs. all in PL
tab code_c if year==2017 & pe020==80 // 25 obs. all in PL


recode pe020 (10=1) (20=2) (30/35=3) (40/45=4) (500=5) (60/80=6), gen(t1_pe020)
recode pe040 (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600/800=6), gen(t_pe040)


*preschool // added
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)
 
***============================
** Dimensions
*

* Sex
recode pb150 (1=1) (2=0), gen(sex)
label define sex 1 "Male" 0 "Female"
label val sex sex


* Degree of urbanization
g urban = "Intermediate or densely populated area" if (db100==1|db100==2)
replace urban = "Thinly populated area" if (db100==3)

* Region
rename db040 region

*if year==2005 {
*rename db040_num region_names
*}
*if year==2013 {
*g region_names =.
*}

* Wealth
xtile wealth = hx090, nquantiles(5)
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth



replace 

br if year==2017 & db040==""









*********************************************************************************************
*********************************************************************************************

foreach X in D H P R {
foreach Y in IE IS NO UK {
foreach num in 05 11 13 15 {
	insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	cap ren *, lower
	cap keep pb010 pb020 pb030 pb040* pb060* pb100* pb110* pb130* pb140* pb150* pe* px010 px020 px030
	cap keep rb010 rb020 rb030 rb050* rb070* rb080* rb090* rl* rx010 rx030 rx030
	cap keep hb010 hb020 hb030 hb050* hb060* hx080*
	cap keep db010 db020 db030 db040* db090* db100*
	cap compress
	cap save "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.dta", replace
}
}
}

foreach X in D H P R {
foreach Y in BG CH MT RO HR  {
foreach num in 11 13 15 17 {
	insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	cap ren *, lower
	cap keep pb010 pb020 pb030 pb040* pb060* pb100* pb110* pb130* pb140* pb150* pe* px010 px020 px030
	cap keep rb010 rb020 rb030 rb050* rb070* rb080* rb090* rl* rx010 rx030 rx030
	cap keep hb010 hb020 hb030 hb050* hb060* hx080*
	cap keep db010 db020 db030 db040* db090* db100*
	cap compress
	cap save "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.dta", replace
}
}
}

foreach X in D H P R {
foreach Y in BG MT RO HR  {
foreach num in 11 13 15 17 {
	insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	cap ren *, lower
	cap keep pb010 pb020 pb030 pb040* pb060* pb100* pb110* pb130* pb140* pb150* pe* px010 px020 px030
	cap keep rb010 rb020 rb030 rb050* rb070* rb080* rb090* rl* rx010 rx030 rx030
	cap keep hb010 hb020 hb030 hb050* hb060* hx080*
	cap keep db010 db020 db030 db040* db090* db100*
	cap compress
	cap save "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.dta", replace
}
}
}

foreach X in D H P R {
foreach Y in CH  {
foreach num in 11 13 15 {
	insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	cap ren *, lower
	cap keep pb010 pb020 pb030 pb040* pb060* pb100* pb110* pb130* pb140* pb150* pe* px010 px020 px030
	cap keep rb010 rb020 rb030 rb050* rb070* rb080* rb090* rl* rx010 rx030 rx030
	cap keep hb010 hb020 hb030 hb050* hb060* hx080*
	cap keep db010 db020 db030 db040* db090* db100*
	cap compress
	cap save "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.dta", replace
}
}
}

foreach X in D H P R {
foreach Y in RS {
foreach num in 13 15 {
	insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	cap ren *, lower
	cap keep pb010 pb020 pb030 pb040* pb060* pb100* pb110* pb130* pb140* pb150* pe* px010 px020 px030
	cap keep rb010 rb020 rb030 rb050* rb070* rb080* rb090* rl* rx010 rx030 rx030
	cap keep hb010 hb020 hb030 hb050* hb060* hx080*
	cap keep db010 db020 db030 db040* db090* db100*
	cap compress
	cap save "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.dta", replace
}
}
}



gen hhweight=pb040
replace hhweight=rb050 if hhweight=. & rb050!=.



cap gen individual_id=pb020+" "+string(pb010)+" "+string(pb030)
cap gen individual_id=rb020+" "+string(rb010)+" "+string(rb030)
cap gen household_id =hb020+" "+string(hb010)+" "+string(hb030)
cap gen household_id =db020+" "+string(db010)+" "+string(db030)

use "$tryout\2011\UDB_cAT11P.dta", clear
count
gen individual_id=pb020+" "+string(pb010)+" "+string(pb030)
codebook ind
save "$tryout\2011\temp\temp_P.dta", replace

use "$tryout\2011\UDB_cAT11R.dta", clear
count
gen individual_id=rb020+" "+string(rb010)+" "+string(rb030)
codebook ind
merge 1:1 individual_id using "$tryout\2011\temp\temp_P.dta", gen(_merge_persons)
br if _m==1
tab rx010 _merge // those that didn't match is because they are 16 or younger

use "$tryout\2011\UDB_cAT11H.dta", clear
count
gen household_id=hb020+" "+string(hb010)+" "+string(hb030)
codebook house // 6187
save "$tryout\2011\temp\temp_H.dta", replace


use "$tryout\2011\UDB_cAT11D.dta", clear
count
gen household_id=db020+" "+string(db010)+" "+string(db030)
codebook house // 6187
merge 1:1 household_id using "$tryout\2011\temp\temp_H.dta", gen(_merge_house)
