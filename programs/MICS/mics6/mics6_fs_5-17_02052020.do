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


global folder "C:\Users\Rosa_V\Dropbox\WIDE"

global list1 seeing hearing walking selfcare communication remembering concentrating acceptingchange controlbehavior makingfriends anxiety depression

*Countries with no info on disabilities:  Lao PDR 
*Added 31 Jan: Lesotho, Madagascar, Madagascar Mongolia Zimbabwe Georgia

foreach country in Iraq KyrgyzRepublic SierraLeone Suriname TheGambia Tunisia Lesotho Madagascar Mongolia Zimbabwe Georgia PakistanPunjab {
 use "$folder\Data\MICS\\`country'\fs.dta", clear
 include "$folder\WIDE\WIDE_MICS\programs\auxiliary\mics6_standardizes_fs"
 gen country="`country'"
 save "$folder\WIDE\WIDE_MICS\data\mics6\fs\\`country'.dta", replace
}
 
 
cd "$folder\WIDE\WIDE_MICS\data\mics6\fs" 
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

  
 bys country: tab dis2 fsdisability, m
 egen year=median(fs7y)
 recode fsdisability (2=0)


 lookfor weight
 tab hh52
 
 gen w2=fshweight*hh52 // should be equal to fsweight
 br fshweight hh52 w2 fsweight if w2!=fsweight
 gen diff_weight=abs(w2-fsweight) // 
 
 
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


ren cb3 age
recode cb7 (2=0) (9=.), gen(attend)
gen attend_nr=attend

gen disability="Has functional difficulty" if fsdisability==1
replace disability="Has no functional difficulty" if fsdisability==0

foreach var of varlist seeing hearing {
gen d_`var'="Has `var' difficulty" if `var'==1
replace d_`var'="Has no `var' difficulty" if `var'==0
}


compress
codebook fsdisability
replace country="Sierra Leone" if country=="SierraLeone"
replace country="Gambia" if country=="TheGambia"
replace country="Kyrgyz Republic" if country=="KyrgyzRepublic"
ren dis2 GEM_disability
clonevar MICS_disability=fsdisability
for X in any seeing hearing walking selfcare communication remembering concentrating acceptingchange controlbehavior makingfriends anxiety depression GEM_disability MICS_disability: gen X_nr=X
for X in any seeing hearing walking selfcare communication remembering concentrating acceptingchange controlbehavior makingfriends anxiety depression GEM_disability MICS_disability: gen X_n1=X if X==1

*Request to do OOS from this module
codebook cb7 cb8a, tab(100)
bys country: tab cb7, m
bys country: tab cb8a, m
bys country: tab cb8a, m nol

codebook cb7_string cb8a_string cb8b_string, tab(100)
codebook cb7 cb8a cb8b, tab(100)

cap drop attend*

gen attend=0
replace attend=1 if cb7==1
replace attend=. if cb7==.|cb7==9

gen attend1=0
replace attend1=1 if cb7_string=="oui"|cb7_string=="yes"
replace attend1=. if cb7_st==""|cb7_st=="no response"

compare attend attend1 // they are the same, I drop attend1
drop attend1

codebook cb8a_st, tab(100)

bys country: tab cb8a_st if cb8a==0
tab cb8a if (cb8a_st=="early childhood education"|cb8a_st=="ece"|cb8a_st=="kindergarten"|cb8a_st=="pre-primary"|cb8a_st=="pre-school"|cb8a_st=="pre-scolaire"), nol
tab country cb8a_st if cb8a==1 // In Suriname, pre-primary==1

recode attend (0=1) (1=0), gen(eduout_aux)

gen eduout=eduout_aux
replace eduout=1 if (cb8a_st=="early childhood education"|cb8a_st=="ece"|cb8a_st=="kindergarten"|cb8a_st=="pre-primary"|cb8a_st=="pre-school"|cb8a_st=="pre-scolaire") // level attended: goes to preschool
replace eduout=1 if cb4==2 // cb4_string="no" or "non" ... "out of school" if "ever attended school"=no
*Also eduout=1 if level attended=not formal/not regular/not standard

*Durations for OUT-OF-SCHOOL & ATTENDANCE 
*merge with information of duration of levels, school calendar, official age for primary, etc:
	*The durations for 2018 are not available, so I create a "fake year"
	gen year_original=year
	replace year=2017 if year_original>=2018
	merge m:1 iso_code3 year using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\data_created\auxiliary_data\UIS\duration_age\UIS_duration_age_25072018.dta"
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
	
*Age limits for out of school

foreach X in prim lowsec upsec {
	gen eduout_`X'=eduout if schage>=`X'_age0_eduout & schage<=`X'_age1_eduout
}


foreach X of varlist eduout_prim eduout_lowsec eduout_upsec {
	gen `X'_no=`X'
	gen `X'_COUNT0=`X' if `X'==0 
	gen `X'_COUNT1=`X' if `X'==1
	
}

gen sex=""
replace sex="Male" if hl4==1
replace sex="Female" if hl4==2

codebook disability
gen disab=0 if disability=="Has no functional difficulty"
replace disab=1 if disability=="Has functional difficulty"

gen disab_no=disab
gen disab_COUNT0=disab if disab==0
gen disab_COUNT1=disab if disab==1

replace country="Pakistan (Punjab)" if country=="PakistanPunjab"

*Weight by fsweight (indicator EQ.1.2)


save "$folder\WIDE\WIDE_MICS\data\mics6\fs\fs_5-17.dta", replace

************************************************************************************
************************************************************************************

*Out of school by disability
global data_fs "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs"


****************************************************
use "$data_fs\fs_5-17.dta", clear
keep if fs17==1 // only those with completed interview
collapse (mean) eduout_prim eduout_lowsec eduout_upsec (count) eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=fsweight], by(country iso_code3 year prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "$data_fs\collapse_total.dta", replace

use "$data_fs\fs_5-17.dta", clear
collapse (mean) eduout_prim eduout_lowsec eduout_upsec (count) eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=fsweight], by(country iso_code3 year prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "$data_fs\collapse_total_bilal.dta", replace


use "$data_fs\fs_5-17.dta", clear
keep if fs17==1 // only those with completed interview
collapse (mean) eduout_prim eduout_lowsec eduout_upsec (count) eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=fsweight], by(country iso_code3 year prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
gen category="Total"
save "$data_fs\collapse_total.dta", replace


use "$data_fs\fs_5-17.dta", clear
keep if fs17==1 // only those with completed interview
collapse (mean) eduout_prim eduout_lowsec eduout_upsec (count) eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=fsweight], by(country iso_code3 year sex prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if sex==""
gen category="Sex"
save "$data_fs\collapse_sex.dta", replace


use "$data_fs\fs_5-17.dta", clear
keep if fs17==1 // only those with completed interview
collapse (mean) eduout_prim eduout_lowsec eduout_upsec (count) eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=fsweight], by(country iso_code3 year disability prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if disability==""
gen category="Disability"
save "$data_fs\collapse_disability.dta", replace
 
use "$data_fs\fs_5-17.dta", clear
keep if fs17==1 // only those with completed interview
collapse (mean) eduout_prim eduout_lowsec eduout_upsec (count) eduout_prim_no eduout_lowsec_no eduout_upsec_no *COUNT0 *COUNT1 [weight=fsweight], by(country iso_code3 year disability sex prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout)
drop if disability==""|sex==""
gen category="Sex & Disability"
save "$data_fs\collapse_disability_sex.dta", replace

*************
use "$data_fs\collapse_total.dta", clear
append using "$data_fs\collapse_sex.dta"
append using "$data_fs\collapse_disability.dta"
append using "$data_fs\collapse_disability_sex.dta"
gen survey="MICS6"
for X in any eduout_prim eduout_lowsec eduout_upsec: replace X=. if X_no<30
order survey iso country year category sex disability eduout_prim* eduout_lowsec* eduout_upsec*
replace disability="Has functional difficulty" if disability=="has functional difficulty"
replace disability="Has no functional difficulty" if disability=="has no functional difficulty"
order survey iso country year
sort country category sex disability
sort category sex disability
sort country
sort category
save "$data_fs\oos_mics6_fs.dta", replace
export delimited using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\tables\mics6\oos_mics6_fs.csv", replace


************************
global data_fs "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs"
use "$data_fs\fs_5-17.dta", clear

foreach X in prim lowsec upsec {
use "$data_fs\fs_5-17.dta", clear
collapse (mean) disab (count) disab_no disab_COUNT0 disab_COUNT1 [weight=fsweight], by(country iso_code3 year eduout_`X')
drop if eduout_`X'==.
gen level="`X'"
ren eduout_`X' eduout
save "$data_fs\collapse_eduout_`X'.dta", replace
}

use "$data_fs\collapse_eduout_prim.dta", clear
append using "$data_fs\collapse_eduout_lowsec.dta"
append using "$data_fs\collapse_eduout_upsec.dta"
replace disab=. if disab_no<30
order iso country year level eduout 
save "$data_fs\disability_mics6_fs.dta", replace
export delimited using "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\tables\mics6\disability_mics6_fs.csv", replace






******************************************
cd "$folder\WIDE\WIDE_MICS\data\mics6\fs"
use "$folder\WIDE\WIDE_MICS\data\mics6\fs\fs_5-17.dta", clear
collapse (mean) seeing hearing walking selfcare communication remembering concentrating acceptingchange controlbehavior makingfriends anxiety depression GEM_disability MICS_disability [iw=fsweight], by(country year)
save "t_mean_disab.dta", replace

use "$folder\WIDE\WIDE_MICS\data\mics6\fs\fs_5-17.dta", clear
collapse (count) seeing_nr hearing_nr walking_nr selfcare_nr communication_nr remembering_nr concentrating_nr acceptingchange_nr controlbehavior_nr makingfriends_nr anxiety_nr depression_nr GEM_disability_nr MICS_disability_nr, by(country year)
save "t_nr_disab.dta", replace

use "$folder\WIDE\WIDE_MICS\data\mics6\fs\fs_5-17.dta", clear
collapse (count) seeing_n1 hearing_n1 walking_n1 selfcare_n1 communication_n1 remembering_n1 concentrating_n1 acceptingchange_n1 controlbehavior_n1 makingfriends_n1 anxiety_n1 depression_n1 GEM_disability_n1 MICS_disability_n1, by(country year)
save "t_n1_disab.dta", replace

use "t_mean_disab.dta", clear
merge 1:1 country year using "t_nr_disab.dta", nogen
merge 1:1 country year using "t_n1_disab.dta", nogen
br





cd "$folder\WIDE\WIDE_MICS\data\mics6\fs"

use fs_5-17.dta, clear
collapse (mean) fsdisability [iw=fsweight], by(country year age)

use fs_5-17.dta, clear
collapse (mean) attend [iw=fsweight] if schage>=7 & schage<=17, by(country year d_hearing)
save temp_mean_hearing.dta, replace

use fs_5-17.dta, clear
collapse (count) attend if schage>=7 & schage<=17, by(country year d_hearing)
ren attend nr_obs
save temp_count_hearing.dta, replace

use temp_mean_hearing, clear
merge 1:1 country year d_hearing using temp_count_hearing.dta, nogen
drop if d_hearing==""
gen category="hearing"
save d_hearing.dta, replace


use fs_5-17.dta, clear
collapse (mean) attend [iw=fsweight] if schage>=7 & schage<=17, by(country year d_seeing)
save temp_mean_seeing.dta, replace

use fs_5-17.dta, clear
collapse (count) attend if schage>=7 & schage<=17, by(country year d_seeing)
ren attend nr_obs
save temp_count_seeing.dta, replace

use temp_mean_seeing, clear
merge 1:1 country year d_seeing using temp_count_seeing.dta, nogen
drop if d_seeing==""
gen category="seeing"
save d_seeing.dta, replace

use d_hearing.dta, clear
append using d_seeing.dta
ren d_hearing difficulty
replace difficulty=d_seeing if difficulty==""
drop d_seeing
gen flag=1 if nr_obs<=30
gen survey="MICS6"
order survey country year category difficulty



use "$folder\WIDE\WIDE_MICS\data\mics6\fs\fs_5-17.dta", clear
collapse (mean) attend [iw=fsweight] if schage>=7 & schage<=17, by(country year d_seeing)

use "$folder\WIDE\WIDE_MICS\data\mics6\fs\fs_5-17.dta", clear
collapse (count) attend if schage>=7 & schage<=17, by(country year d_seeing)


	 
 
 *append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch_module.dta"

 
gen id2=string(c)+" "+id
drop id
ren id2 id
merge 1:1 id using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\hl\hl_append_mics_6.dta", keepusing(hl6)
drop if _merge==2
ren hl6 age
