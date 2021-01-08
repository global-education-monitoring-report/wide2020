
global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_1ybefore_no


global dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global tryout "$dir\WIDE\WIDE_EU_SILC\Tryout"
global data "$dir\Data\EU_SILC"
global data_raw "$dir\WIDE\WIDE_EU_SILC\data"
global aux_data "$dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"


global dir "C:\Users\Rosa_V\Dropbox\WIDE_EU_SILC"
global tryout "$dir\Tryout"
global data_raw "$dir\data"
global aux_data "$dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"

************************************************************************************************************
************************************************************************************************************
*Don't have some years:
	* BG, MT, RO	    : starts 2007 
	* CH 				: starts 2007 and doesn't have 2017
	* HR				: starts 2010
	* RS				: starts 2013 & doesn't have 2017
	* IE, IS, NO, UK 	: Don't have 2017 

set more off
foreach X in D H P R {
foreach Y in AT BE CY CZ DE DK EE EL ES FI FR HU IT LT LU LV NL PL PT SE SI SK BG MT RO CH HR RS IE IS NO UK {
foreach num in 05 07 09 11 13 15 17 {
	cap insheet using "$data\\`Y'\\20`num'\UDB_c`Y'`num'`X'.csv", clear
	cap display "****************************************"
	cap display " `Y' `X' 20`num' "
	cap display "****************************************"

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
foreach Y in AT BE CY CZ DE DK EE EL ES FI FR HU IT LT LU LV NL PL PT SE SI SK BG MT RO CH HR RS IE IS NO UK {
foreach num in 05 07 09 11 13 15 17 {
	cap use "$data\\`Y'\\20`num'\UDB_c`Y'`num'R.dta", clear
	cap display "****************************************"
	cap display " `Y' 20`num' "
	cap display "****************************************"
	cap merge 1:1 individual_id using "$data\\`Y'\\20`num'\UDB_c`Y'`num'P.dta", gen(merge_persons)
	cap merge m:1 household_id using "$data\\`Y'\\20`num'\UDB_c`Y'`num'H.dta", gen(merge_hh1)
	cap merge m:1 household_id using "$data\\`Y'\\20`num'\UDB_c`Y'`num'D.dta", gen(merge_hh2)
	cap compress
	cap save "$data_raw\All\\`Y'_20`num'.dta", replace
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
replace code_country="GR" if code_country=="EL" // Greece
replace code_country="GB" if code_country=="UK" // *United Kingdom iso_code2 in reality is GB, not UK

codebook code_country, tab(100)

gen year=substr(household_id,4,4)
gen cy=code_country+"_"+year
destring year, replace
*tab year

count
gen iso_code2=code_country
merge m:1 iso_code2 using "$aux_data\country_iso_codes_names.dta", keepusing(iso_code3 country) keep(match) nogen
drop code_country

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
order iso_code* country year cy sex age urban wealth region individual_id household_id hhweight
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

codebook t_pe040, tab(100)

*Creating the completion variables (directly from pe040)

for X in any prim lowsec upsec: gen comp_X=0 if t_pe040!=.
replace comp_prim=1 if t_pe040>=1 & comp_prim==0
replace comp_lowsec=1 if t_pe040>=2 & comp_lowsec==0
replace comp_upsec=1 if t_pe040>=3 & comp_upsec==0

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

drop comp_upsec_1524 comp_prim_2024


gen eduyears=.
replace eduyears=0 if t_pe040==0
replace eduyears=years_prim if t_pe040==1
replace eduyears=years_lowsec if t_pe040==2
replace eduyears=years_upsec if t_pe040==3
replace eduyears=years_upsec+1 if (t_pe040==4|t_pe040==5)
replace eduyears=years_higher if t_pe040==6
replace eduyears=years_higher+2 if t_pe040==7
replace eduyears=years_higher+4 if t_pe040==8

*Preschool variable
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)
gen before1y=1 if age==prim_age0-1
gen presch1ybefore=preschool if before1y==1
drop before1y

ren presch1ybefore preschool_1ybefore
gen preschool_1ybefore_no=preschool_1ybefore

*Fix the region names
gen reg_original=region
do "$dir\WIDE\WIDE_EU_SILC\programs\region_names.do"
ren urban location
tab reg_original if region==""
replace region=reg_original if region==""


foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524  {
cap gen `var'_no=`var'
}
compress
*Drop variables that I dont use
drop cy before1y reg_original regionnew
save "$data_raw\Step2.dta", replace

use "$data_raw\Step2.dta", clear
*collapse comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 *age0 *age1 *dur presch* [iw=hhweight], by(country year iso_code2 iso_code3)
*save "$dir\WIDE\WIDE_EU_SILC\comparisons\collapse_EU-SILC.dta", replace


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
	use "$data_raw\Step2.dta", clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country iso_code3 year `tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "$data_raw"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/15 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen survey="EU-SILC"
replace category="total" if category==""
tab category

*-- Fixing for missing values in categories
for X in any wealth sex: decode X, gen(X_s)
for X in any wealth sex: drop X
for X in any wealth sex: ren X_s X

codebook $categories_collapse, tab(100)

for X in any $categories_collapse: drop if category=="X" & X==""
for X in any sex wealth region: drop if category=="location X" & (location==""|X=="")
for X in any wealth region: drop if category=="sex X" & (sex==""|X=="")
for X in any region: drop if category=="wealth X" & (wealth==""|X=="")

drop if category=="location sex wealth" & (location==""|sex==""|wealth=="")
drop if category=="sex wealth region" & (sex==""|wealth==""|region=="")
drop if category=="location sex wealth region"

*Putting the names in the same format as the others
for X in any $categories_collapse total: replace category=proper(category) if category=="X"
replace category="Location & Sex" if category=="location sex"
replace category="Location & Sex & Wealth" if category=="location sex wealth"
replace category="Location & Wealth" if category=="location wealth"
replace category="Sex & Region" if category=="sex region"
replace category="Sex & Wealth" if category=="sex wealth"
replace category="Sex & Wealth & Region" if category=="sex wealth region"
replace category="Wealth & Region" if category=="wealth region"

* Categories that are not used:
drop if category=="location region"|category=="location sex region"|category=="location wealth region"

for X in any $categories_collapse: rename X, proper

codebook category, tab(100)
*Now I throw away those that have large differences (per level)
merge m:1 country year using "$dir/comparisons/results.dta", keepusing(flag*) nogen
drop if flag_lfs==1
order iso_code3 country survey year category Sex Location Wealth Region comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* comp_prim_1524* comp_lowsec_1524* comp_upsec_2029* preschool_1ybefore*
drop comp_lowsec_2024-flag_LFS_country
for X in any comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore: ren X X_m
order iso_code3 country survey year category Sex Location Wealth Region *_m *_no

save "$data_raw\EU_SILC_May31.dta", replace
export delimited "$data_raw\EU_SILC_May31.csv", replace


*for X in any comp_upsec_v2 comp_upsec_2024: replace X=. if flag_lfs==1


****************************************************************************************************************************************
****************************************************************************************************************************************

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


*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------


** CHECKS FOR WEIRD CASES
*codebook rl020 rl030 rl040, tab(100)
tab cy preschool
tab rl010 cy if country=="Germany"


*Checks for Slovenia
gen t=0
replace t=1 if pe040>=2
replace t=. if pe040==.

gen age2=year-rb080


*Luxembourg (most of the years)
tab pe040 year if country=="Luxembourg", m
bys year: tab age comp_lowsec if country=="Luxembourg", m
table year [iw=hhweight]  if country=="Luxembourg" & (age>=17 & age<=19), c(mean comp_lowsec) 
table year [iw=hhweight]  if country=="Luxembourg" & (age>=19 & age<=21), c(mean comp_lowsec) 

*Slovenia
sum comp_lowsec [iw=hhweight] if country=="Slovenia" & year==2005 & (age>=17 & age<=19)
sum comp_lowsec [iw=hhweight] if country=="Slovenia" & year==2005 & (age2>=17 & age2<=19)

sum comp_lowsec [iw=hhweight] if country=="Slovenia" & year==2005 & (age>=18 & age<=20)
sum comp_lowsec [iw=hhweight] if country=="Slovenia" & year==2005 & (age2>=18 & age2<=20)

*Belgium 2005
sum comp_lowsec [iw=hhweight] if country=="Belgium" & year==2005 & (age>=16 & age<=18)
sum comp_lowsec [iw=hhweight] if country=="Belgium" & year==2005 & (age2>=16 & age2<=18)

sum comp_lowsec [iw=hhweight] if country=="Belgium" & year==2005 & (age>=17 & age<=19)
sum comp_lowsec [iw=hhweight] if country=="Belgium" & year==2005 & (age2>=17 & age2<=19)


tab age comp_lowsec if country=="Belgium" & year==2005

*France 2013
tab pe040 if country=="France" & year==2013, m
tab age comp_lowsec if country=="France" & year==2013
sum comp_lowsec [iw=hhweight] if country=="France" & year==2013 & (age>=17 & age<=19)
sum comp_lowsec [iw=hhweight] if country=="France" & year==2013 & (age2>=17 & age2<=19)

sum comp_lowsec [iw=hhweight] if country=="France" & year==2013 & (age>=18 & age<=20)

*Latvia 2005
tab pe040 if country=="Latvia" & year==2005, m
tab pe040 if country=="Latvia" & year==2005, m

sum comp_lowsec [iw=hhweight] if country=="Latvia" & year==2005 & (age>=18 & age<=20)
sum comp_lowsec [iw=hhweight] if country=="Latvia" & year==2005 & (age2>=18 & age2<=20)

codebook rl010, tab(100)
tab rl010 year, m
