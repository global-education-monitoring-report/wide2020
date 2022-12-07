
global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 preschool_1ybefore *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_1ybefore_no


global dir "C:\Users\taiku\Documents\GEM UNESCO MBR\ourdrive_EU_SILC\WIDE_EU_SILC"
global tryout "$dir\Tryout"
global data_raw "$dir\data"
global aux_data "$dir\data\auxiliary_data"

************************************************************************************************************
************************************************************************************************************
*Don't have some years:
	* BG, MT, RO	    : starts 2007 
	* CH 				: starts 2007 and doesn't have 2017
	* HR				: starts 2010
	* RS				: starts 2013 & doesn't have 2017
	* IE, IS, NO, UK 	: Don't have 2017 
***********************************************************************************************************
*2021: I'm not able to replicate the append of all the dataset, but from this on it can run

*for this new calculation we'll focus only on 2015 and 2017 surveys that change some key coding 

// use "C:\Users\taiku\Documents\GEM UNESCO MBR\ourdrive_EU_SILC\WIDE_EU_SILC\data\EU_SILC_full.dta"
// split individual_id, parse(" ")
// tab individual_id2
// keep if inlist( individual_id2 , "2015", "2017")
// save "C:\Users\taiku\Documents\GEM UNESCO MBR\ourdrive_EU_SILC\WIDE_EU_SILC\data\EU_SILC_1517.dta"

*
	
use "$data_raw\EU_SILC_1517.dta", clear
gen code_country=substr(household_id,1,2)
*Fix to the name of countries (Greece)
replace code_country="GR" if code_country=="EL" // Greece
replace code_country="GB" if code_country=="UK" // *United Kingdom iso_code2 in reality is GB, not UK

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
egen wealth=xtile(hx090), n(5) by(country) weight(hhweight)

*xtile wealth =  [aw=hhweight], nquantiles(5)
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth
drop hx090

*Region
clonevar region=db040
*drop db040
replace region="" if region=="."
*codebook region
*tab cy if region=="" // DE, NL, PT, SI

*Fix the region names
gen reg_original=region
do "$dir\programs\region_names.do"
ren urban location
tab reg_original if region==""
replace region=reg_original if region==""


order iso_code* country year cy sex age location wealth region individual_id household_id hhweight
compress
save "$data_raw\Step1.dta", replace

************************************************************************************************************
************************************************************************************************************
use "$data_raw\Step1.dta", clear
merge m:1 iso_code3 year using "$aux_data\UIS_duration_age_01102020.dta", keepusing(prim_age_uis prim_dur_uis lowsec_dur_uis upsec_dur_uis) keep(match) nogen
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

*Short cycle of secondary: 1 years
*Bachelor: 3 years

*Creating the completion variables (directly from pe040)

for X in any prim lowsec upsec: gen comp_X=0 if t_pe040!=.
replace comp_prim=1 if t_pe040>=1 & comp_prim==0
replace comp_lowsec=1 if t_pe040>=2 & comp_lowsec==0
replace comp_upsec=1 if t_pe040>=3 & comp_upsec==0

***COMPLETION***
*Basic levels
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

*Higher levels
gen highlevl=pe040 
gen comp_higher_rev_2y=0
replace comp_higher_rev_2y=1 if (highlevl==500)
replace comp_higher_rev_2y=. if highlevl==.
**500 instead of 5 works for 2017 and 2015 codebooks
*However, 5 used to be equivalent to "1st & 2nd stage of tertiary education"
*Now 500 is now "Short cycle tertiary (PB010>2013)(Top coding: 500 & above)" 
*is this a mistake? 

gen comp_higher_rev_4y=0
replace comp_higher_rev_4y=1 if (highlevl==600 | highlevl==700 |highlevl==800)
replace comp_higher_rev_4y=. if highlevl==.
**600 to 800 only available in 2017 surveys
*600 = Bachelor or equivalent (PB010>2013) 
*700 Master or equivalent (PB010>2013) 
*800 Doctorate or equivalent (PB010>2013) 

gen agegroup_2529=1 if age>=25 & age<=29
gen agegroup_3034=1 if age>=30 & age<=34 // added

gen comp_higher_2yrs_2529=comp_higher_rev_2y if agegroup_2529==1
gen comp_higher_4yrs_2529=comp_higher_rev_4y if agegroup_2529==1
gen comp_higher_4yrs_3034=comp_higher_rev_4y if agegroup_3034==1
*Desist of 4yrs counts because there's no information except for Poland?

drop comp_higher_rev_2y comp_higher_rev_4y highlevl

***EDUYEARS***
gen eduyears=.
replace eduyears=0 if t_pe040==0
replace eduyears=years_prim if t_pe040==1
replace eduyears=years_lowsec if t_pe040==2
replace eduyears=years_upsec if t_pe040==3
replace eduyears=years_upsec+1 if (t_pe040==4|t_pe040==5)
replace eduyears=years_higher if t_pe040==6
replace eduyears=years_higher+2 if t_pe040==7
replace eduyears=years_higher+4 if t_pe040==8

gen eduyears_2024=eduyears if (age>=20 & age<=24)

***PRESCHOOL***
gen preschool=rl010
recode preschool (2/84=1) (85/100=.) 
**ask abt this recode
gen before1y=1 if age==prim_age0-1
gen preschool_1ybefore=preschool if before1y==1
gen preschool_3=preschool if (age>=3 & age<=4)
drop before1y

*gen preschool_1ybefore_no=preschool_1ybefore

***OUT OF SCHOOL (ONLY FOR UPSEC)***
* Out of school adolescents (upper sec) (%)
gen agegroup_upper_sec=0
replace agegroup_upper_sec=1 if (age>=upsec_age0 & age<=upsec_age1)
replace agegroup_upper_sec=. if age==.
rename pe010 enrolment

gen eduout_upsec= 0 if (agegroup_upper_sec==1)
recode eduout_upsec (0=1) if (enrolment==2)
*==2 instead of ==0 
replace eduout_upsec=. if enrolment==.

***HIGHER EDUCATION ATTENDANCE***

* Age 18-24 (for by age analysis)
gen att_higher_temp = 0
replace att_higher_temp=1 if (inlist(pe040,500,600,700,800))
*changed codes for 2017 and 2015
gen agegroup_1824=1 if age>=18 & age<=24

gen att_higher_1824 = 0 if agegroup_1824==1 & att_higher_temp!=.
replace att_higher_1824 = 1 if att_higher_temp==1 


foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduyears_2024 preschool_1ybefore preschool_3 eduout_upsec att_higher_1824 {
cap gen `var'_no=`var'
}
compress
*Drop variables that I dont use
drop cy reg_original regionnew
save "$data_raw\Step2.dta", replace

use "$data_raw\Step2.dta", clear
*collapse comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 *age0 *age1 *dur presch* [iw=hhweight], by(country year iso_code2 iso_code3)
*save "$dir\WIDE\WIDE_EU_SILC\comparisons\collapse_EU-SILC.dta", replace

global categories_collapse location sex wealth region 
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduyears_2024 preschool_1ybefore preschool_3 eduout_upsec att_higher_1824 *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduyears_2024_no preschool_1ybefore_no preschool_3_no eduout_upsec_no att_higher_1824_no

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
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\ourdrive_EU_SILC\WIDE_EU_SILC\data\collapse"

set more off
foreach i of numlist 0/15 {
	use "$data_raw\Step2.dta", clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [aweight=hhweight], by(country iso_code3 year `tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "$data_raw\collapse"
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

*codebook category, tab(100)
save "$data_raw\EU_SILC_Mar5_nocensoring.dta", replace

export delimited "$data_raw\EU_SILC_Mar4_nocensoring.csv", replace

*Now I throw away those that have large differences (per level)
***IMPORTANT! you need to re-run comparisons2021.do

merge m:1 country year using "$dir/comparisons/results.dta", keepusing(flag*) nogen
drop if flag_lfs==1
order iso_code3 country survey year category Sex Location Wealth Region comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* comp_prim_1524* comp_lowsec_1524* comp_upsec_2029* comp_higher_2yrs_2529* comp_higher_4yrs_2529* comp_higher_4yrs_3034* eduyears_2024* preschool_1ybefore* preschool_3* eduout_upsec* att_higher_1824*
*drop comp_lowsec_2024-flag_LFS_country
for X in any comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduyears_2024 preschool_1ybefore preschool_3 eduout_upsec att_higher_1824 : ren X X_m
order iso_code3 country survey year category Sex Location Wealth Region *_m *_no

save "$data_raw\EU_SILC_Mar5_censored.dta", replace
export delimited "$data_raw\EU_SILC_Mar5_censored.csv", replace


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
