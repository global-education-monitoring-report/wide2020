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

*************************

use "$data_raw\Step2.dta", clear
codebook rl010, tab(100)
tab rl010 year, m

*Recode vars
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)

tab cy preschool
tab rl010 cy if country=="Germany"

gen before1y=1 if age==prim_age0-1
gen presch1ybefore=preschool if before1y==1

collapse comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 *age0 *age1 *dur presch* [iw=hhweight], by(country year)



*** FOR ADJUSTMENT


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

