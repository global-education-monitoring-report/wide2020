* Functional difficulty in the individual domains are calculated as follows:

*  - Seeing (FCF6A/B=3 or 4)
*  - Hearing (FCF8A/B=3 or 4)
*  - Walking (FCF10=3 or 4 OR FCF11=3 or 4 OR FCF14=3 or 4 OR FCF15=3 or 4
*  - Self-care (FCF16=3 or 4)
*  - Communication a) Being understood inside household (FCF17=3 or 4) or b) Being understood outside household (FCF18=3 or 4), 
*  - Learning (FCF19=3 or 4)
*  - Remembering (FCF20=3 or 4)
*  - Concentrating ((FCF21=3 or 4)
*  - Accepting change (FCF22=3 or 4)
*  - Controlling behaviour (FCF23=3 or 4)
*  - Making friends (FCF24=3 or 4)
*  - Anxiety (FCF25=1)
*  - Depression (FCF26=1).

* The percentage of children age 2-4 years with functional difficulty in at least one domain is presented in the last column.

*global folder "C:\Users\Rosa_V\Dropbox\WIDE"
global folder "C:\Users\r_vidarte-chicchon\Desktop"
global list1 seeing hearing walking selfcare communication learning remembering concentrating acceptingchange controlbehavior makingfriends anxiety depression

******************************************************************************************************************
******************************************************************************************************************
*Countries with no info on disabilities:  Lao PDR 
*Added 31 Jan: Lesotho, Madagascar, Madagascar Mongolia Zimbabwe Georgia
*Added 2 Feb: Punjab (Pakistan)

/*
foreach country in Iraq KyrgyzRepublic SierraLeone Suriname TheGambia Tunisia Lesotho Madagascar Mongolia Zimbabwe Georgia PakistanPunjab {
 use "$folder\Data\MICS\\`country'\fs.dta", clear
 *include "$folder\WIDE\WIDE_MICS\programs\auxiliary\mics6_standardizes_fs"
 include "$folder\WIDE_MICS\programs\auxiliary\mics6_standardizes_fs"
  gen country="`country'"
 save "$folder\WIDE_MICS\data\mics6\fs\\`country'.dta", replace
}
 */

 
*cd "$folder\WIDE\WIDE_MICS\data\mics6\fs" 
cd "$folder\WIDE_MICS\data\mics6\fs" 
 use Iraq.dta, clear
 append using KyrgyzRepublic.dta
 append using SierraLeone.dta
 append using Suriname.dta
 append using TheGambia.dta
 append using Tunisia.dta
 append using Lesotho.dta
 append using Madagascar.dta
 append using Mongolia.dta
 append using Zimbabwe.dta
 append using Georgia.dta
 append using PakistanPunjab.dta
 
 egen year=median(fs7y)
 ren cb3 age
 
 lookfor weight
 tab hh52
 
 gen w2=fshweight*hh52
 br fshweight hh52 w2 fsweight if w2!=fsweight
 
	gen c=1 if country=="Iraq"
	replace c=2 if country=="KyrgyzRepublic" 
	replace c=3 if country=="LaoPDR" 
	replace c=4 if country=="SierraLeone" 
	replace c=5 if country=="Suriname" 
	replace c=6 if country=="TheGambia" 
	replace c=7 if country=="Tunisia"
	replace c=8 if country=="Lesotho"
	replace c=9 if country=="Madagascar"
	replace c=10 if country=="Mongolia"
	replace c=11 if country=="Zimbabwe"
	replace c=12 if country=="Georgia"
	replace c=13 if country=="PakistanPunjab"

	gen iso_code3=""
	replace iso_code3="IRQ" if country=="Iraq"
	replace iso_code3="KGZ" if country=="KyrgyzRepublic"
	replace iso_code3="LAO" if country=="LaoPDR"
	replace iso_code3="SLE" if country=="SierraLeone"
	replace iso_code3="SUR" if country=="Suriname"
	replace iso_code3="GMB" if country=="TheGambia"
	replace iso_code3="TUN" if country=="Tunisia"
	replace iso_code3="LSO" if country=="Lesotho"
	replace iso_code3="MDG" if country=="Madagascar"
	replace iso_code3="MNG" if country=="Mongolia"
	replace iso_code3="ZWE" if country=="Zimbabwe"
	replace iso_code3="GEO" if country=="Georgia"
	replace iso_code3="PAK" if country=="PakistanPunjab"
	
replace country="Sierra Leone" if country=="SierraLeone"
replace country="Gambia" if country=="TheGambia"
replace country="Kyrgyz Republic" if country=="KyrgyzRepublic"
replace country="Pakistan (Punjab)" if country=="PakistanPunjab"

*Disability variable
 bys country: tab GEM_disability fsdisability, m
 recode fsdisability (2=0) (9=.), gen (disab) // I changed this and the values are correct now
 clonevar MICS_disability=disab
 
 foreach var of varlist disab low_prevalence {
	gen `var'_no=`var'
	gen `var'_COUNT0=`var' if `var'==0
	gen `var'_COUNT1=disab if `var'==1
}
	
 
 gen disability="Has functional difficulty" if disab==1
 replace disability="Has no functional difficulty" if disab==0
 
foreach var of varlist seeing hearing {
	gen d_`var'="Has `var' difficulty" if `var'==1
	replace d_`var'="Has no `var' difficulty" if `var'==0
}

for X in any $list1 GEM_disability MICS_disability low_prevalence: gen X_nr=X
for X in any $list1 GEM_disability MICS_disability low_prevalence: gen X_n1=X if X==1
compress

*-------------------------------------------
* OUT OF SCHOOL INDICATORS
*-------------------------------------------
*Durations for OUT-OF-SCHOOL & ATTENDANCE 
*merge with information of duration of levels, school calendar, official age for primary, etc:
	*The durations for 2018 are not available, so I create a "fake year"
	gen year_original=year
	replace year=2017 if year_original>=2018
	*merge m:1 iso_code3 year using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\data_created\auxiliary_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	merge m:1 iso_code3 year using "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\data_created\auxiliary_data\UIS\duration_age\UIS_duration_age_25072018.dta"
	drop year
	ren year_original year
	drop if _m==2
	drop _merge
	drop lowsec_age_uis upsec_age_uis
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X_eduout
	ren prim_age_uis prim_age0_eduout

	gen lowsec_age0_eduout=prim_age0_eduout+prim_dur_eduout
	gen upsec_age0_eduout=lowsec_age0_eduout+lowsec_dur_eduout
	for X in any prim lowsec upsec: gen X_age1_eduout=X_age0_eduout+X_dur_eduout-1
save "temp_fs_5-17.dta", replace

*------ OUT OF SCHOOL -----------------------------	
	
use "temp_fs_5-17.dta", clear
codebook cb7 cb8a, tab(100)
bys country: tab cb7, m
bys country: tab cb8a, m
bys country: tab cb8a, m nol

codebook cb7_string cb8a_string cb8b_string, tab(100)
codebook cb7 cb8a cb8b, tab(100)

tab cb7 cb7_string, nol

gen attend=0
replace attend=1 if cb7==1
replace attend=. if cb7==.|cb7==9

gen attend1=0
replace attend1=1 if cb7_string=="oui"|cb7_string=="yes"
replace attend1=. if cb7_st==""|cb7_st=="no response"

compare attend attend1 // they are the same, I drop attend1
drop attend1

codebook cb8a_st, tab(100)
tab cb8a cb8a_st

bys country: tab cb8a_st if cb8a==0
tab cb8a if (cb8a_st=="early childhood education"|cb8a_st=="ece"|cb8a_st=="kindergarten"|cb8a_st=="pre-primary"|cb8a_st=="pre-school"|cb8a_st=="pre-scolaire"), nol
tab country cb8a_st if cb8a==1 // In Suriname, pre-primary==1

*Restriction: identifies those that attend preschool
gen in_preschool=1 if (cb8a_st=="early childhood education"|cb8a_st=="ece"|cb8a_st=="kindergarten"|cb8a_st=="pre-primary"|cb8a_st=="pre-school"|cb8a_st=="pre-scolaire") // level attended: goes to preschool
gen primary_age_range=0
replace primary_age_range=1 if schage>=prim_age0_eduout & schage<=prim_age1_eduout
replace primary_age_range=. if schage==.

bys country: tab schage primary_age_range

tab attend in_preschool, m //10,779 in preschool & attend==1

* The standard out of school:
recode attend (0=1) (1=0), gen(eduout)
replace eduout=1 if cb4==2 // cb4_string="no" or "non" ... "out of school" if "ever attended school"=no
replace eduout=. if cb8a_st=="dk"|cb8a_st=="no response" // 12 cases only
replace eduout=1 if in_preschool==1 // level attended: goes to preschool. 10.779 changes made

*- Also eduout=1 if level attended=not formal/not regular/not standard

*Auxiliary definition of eduout: Primary-school-age children in pre-primary as being in school (eduout=0)
gen eduout_aux=eduout
replace eduout_aux=0 if in_preschool==1 & primary_age_range==1


*Age limits for out of school
foreach X in prim lowsec upsec {
    gen eduout_`X'=eduout if schage>=`X'_age0_eduout & schage<=`X'_age1_eduout
    gen eduout_aux_`X'=eduout_aux if schage>=`X'_age0_eduout & schage<=`X'_age1_eduout
}


foreach X of varlist eduout_prim eduout_lowsec eduout_upsec eduout_aux_prim eduout_aux_lowsec eduout_aux_upsec {
	gen `X'_no=`X'
	gen `X'_COUNT0=`X' if `X'==0 
	gen `X'_COUNT1=`X' if `X'==1
}

gen sex=""
replace sex="Male" if hl4==1
replace sex="Female" if hl4==2

*Weight by fsweight (indicator EQ.1.2)
keep if fs17==1 // only those with completed interview (3754 obs dropped)

br eduout schage primary_age_range if eduout!=eduout_aux
tab primary_age_range if eduout!=eduout_aux // 3881 cases
compress
save "fs_5-17.dta", replace


*************************************************************************************************************************
*************************************************************************************************************************

*cd "$folder\WIDE\WIDE_MICS\data\mics6\fs"

cd "$folder\WIDE_MICS\data\mics6\fs" 

use "fs_5-17.dta", clear
collapse (mean) $list1 GEM_disability MICS_disability low_prevalence [iw=fsweight], by(country year)
save "t_mean_disab.dta", replace

use "fs_5-17.dta", clear
collapse (count) seeing_nr hearing_nr walking_nr selfcare_nr communication_nr learning_nr remembering_nr concentrating_nr acceptingchange_nr controlbehavior_nr makingfriends_nr anxiety_nr depression_nr GEM_disability_nr MICS_disability_nr low_prevalence_nr, by(country year)
save "t_nr_disab.dta", replace

use "fs_5-17.dta", clear
collapse (count) seeing_n1 hearing_n1 walking_n1 selfcare_n1 communication_n1 learning_n1 remembering_n1 concentrating_n1 acceptingchange_n1 controlbehavior_n1 makingfriends_n1 anxiety_n1 depression_n1 GEM_disability_n1 MICS_disability_n1 low_prevalence_n1, by(country year)
save "t_n1_disab.dta", replace

use "t_mean_disab.dta", clear
merge 1:1 country year using "t_nr_disab.dta", nogen
merge 1:1 country year using "t_n1_disab.dta", nogen

for X in any $list1 GEM_disability MICS_disability low_prevalence: replace X=. if X_nr<30

*export excel "C:\Users\r_vidarte-chicchon\Desktop\WIDE_MICS\tables\MICS6_Disability_Ages5-17_v4.xlsx", replace firstrow(variables)
export delimited using "C:\Users\r_vidarte-chicchon\Desktop\WIDE_MICS\tables\categories_disability_ages5-17_v4.csv", replace


*******************************************************************************************************************

*Out of school by disability
global list_eduout eduout_prim eduout_lowsec eduout_upsec eduout_aux_prim eduout_aux_lowsec eduout_aux_upsec
global list_eduout_count eduout_prim_no eduout_lowsec_no eduout_upsec_no eduout_prim_COUNT0 eduout_lowsec_COUNT0 eduout_upsec_COUNT0 eduout_prim_COUNT1 eduout_lowsec_COUNT1 eduout_upsec_COUNT1 eduout_aux_prim_no eduout_aux_lowsec_no eduout_aux_upsec_no eduout_aux_prim_COUNT0 eduout_aux_lowsec_COUNT0 eduout_aux_upsec_COUNT0 eduout_aux_prim_COUNT1 eduout_aux_lowsec_COUNT1 eduout_aux_upsec_COUNT1


****************************************************
cd "$folder\WIDE_MICS\data\mics6\fs" 

use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "collapse_total.dta", replace

use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "collapse_total_bilal.dta", replace

use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "collapse_total.dta", replace

use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year sex prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if sex==""
gen category="Sex"
save "collapse_sex.dta", replace


use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year disability prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if disability==""
gen category="Disability"
save "collapse_disability.dta", replace
 
use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year disability sex prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if disability==""|sex==""
gen category="Sex & Disability"
save "collapse_disability_sex.dta", replace

use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year low_prevalence prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if low_prevalence==.
gen category="Low Prevalence"
save "collapse_low_prevalence.dta", replace
 
use "fs_5-17.dta", clear
collapse (mean) $list_eduout (count) $list_eduout_count [weight=fsweight], by(country iso_code3 year low_prevalence sex prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if low_prevalence==.|sex==""
gen category="Low Prevalence & Disability"
save "collapse_low_prevalence_sex.dta", replace

use "collapse_total.dta", clear
append using "collapse_sex.dta"
append using "collapse_disability.dta"
append using "collapse_disability_sex.dta"
append using "collapse_low_prevalence.dta"
append using "collapse_low_prevalence_sex.dta"
gen survey="MICS6"
for X in any $list_eduout: replace X=. if X_no<30
order survey iso country year category sex disability eduout_prim* eduout_lowsec* eduout_upsec*
replace disability="Has functional difficulty" if disability=="has functional difficulty"
replace disability="Has no functional difficulty" if disability=="has no functional difficulty"
gen lp="Low-prevalence=1" if low_prevalence==1
replace lp="Low-prevalence=0" if low_prevalence==0
drop low_prevalence
ren lp low_prevalence
sort country category sex disability low_prevalence
sort category sex disability low_prevalence
sort country
sort category
order survey iso country year category sex disability low_prevalence $list_eduout $list_eduout_count
save "oos_mics6_fs.dta", replace
export delimited using "C:\Users\r_vidarte-chicchon\Desktop\WIDE_MICS\tables\oos_mics6_fs.csv", replace

****************************************************************************************************************
global data_fs "C:\Users\r_vidarte-chicchon\Desktop\WIDE_MICS\data\mics6\fs"
global disab_indicators disab low_prevalence
global disab_counts disab_no disab_COUNT0 disab_COUNT1 low_prevalence_no low_prevalence_COUNT0 low_prevalence_COUNT1

foreach var of varlist eduout eduout_aux {
foreach X in prim lowsec upsec {
use "$data_fs\fs_5-17.dta", clear
collapse (mean) $disab_indicators (count) $disab_counts [weight=fsweight], by(country iso_code3 year `var'_`X')
drop if `var'_`X'==.
gen level="`X'"
ren `var'_`X' `var'
save "$data_fs\collapse_`var'_`X'.dta", replace
}
}

foreach var of varlist eduout eduout_aux {
use "$data_fs\collapse_`var'_prim.dta", clear
append using "$data_fs\collapse_`var'_lowsec.dta"
append using "$data_fs\collapse_`var'_upsec.dta"
for X in any $disab_indicators: replace X=. if X_no<30
order iso country year level eduout 
save "$data_fs\disability_mics6_`var'.dta", replace
export delimited using "C:\Users\r_vidarte-chicchon\Desktop\WIDE_MICS\tables\disability_mics6_`var'.csv", replace
}


