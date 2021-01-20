**CHINA CFPS 2016 UPDATE

*This joins pieces of previous code and adapts to 2016 version. 

************************************************************************************************************
*************PART 1: merge surveys *************************************************************************
************************************************************************************************************

* tempfiles
tempfile familyroster family adult child

** [i]. Family roster
* open raw data
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)\[CFPS Public Data] CFPS2016 in STATA (English)\ecfps2016famconf_201804.dta", clear  
* keep vars
keep pid fid*   /// provcd doesnt exist countyid is fid16_countyid
tb1* tb4_a16_p alive_a16_p tb2_a_p tb4_a16_p tb6_a16_p /// changing most 14 into 16
pid_f alive_a16_f tb6_a16_f pid_m alive_a16_m tb6_a16_m pid_s alive_a16_s tb6_a16_s ///
pid_c* alive_a16_c* cfps2016_interv_p ///
familysize16 subpopulation 
* ids
tostring fid16, gen(household_id)  // use the identifiers for 2016. 
tostring pid, gen(individual_id)
* I keep only those that have completed an interview
keep if cfps2016_interv_p==1
* save tempfile
g subset = "Family roster"
save "`familyroster'"

** [ii]. Family 
* open raw data
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)\[CFPS Public Data] CFPS2016 in STATA (English)\ecfps2016famecon_201807.dta", clear  // 
* keep vars
keep fid* cid provcd countyid fswt_nat* fswt_res* ///
urban familysize ///
finc*
*faminc_net_old faminc_net faminc_old faminc indinc indinc_net foperate_net 
* ids
tostring fid16, gen(household_id)   // use the identifiers for 2016
* save tempfile
g subset = "Family"
save "`family'"


*** [iii]. Adult
* open raw data
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)\[CFPS Public Data] CFPS2016 in STATA (English)\ecfps2016adult_201906.dta", clear  //
* keep vars
keep pid fid* cid provcd countyid rswt_nat* rswt_res* cyear cmonth ///
cfps_age cfps_gender  pa701code cfps_latest_edu pw1r cfps2016edu pw1r cfps_latest_school cfps2016edu cfps2016sch cfps2016eduy cfps2016eduy_im cfps_latest_edu qc* /// 
qc201* pc1 pc2 pc3 pc4 ppc5 pc7 ps3 ps4 ps5 ps7 ps8 kw* cfps* pc4 pc3 urban* cfps_gender cfps2014_interv urban* ///

*kr1-kr4 kr5m kr6m kr701 kr801 kw* cfps* kra1 cfps_latest_school kr1 kw* cfps2014_interv urban* cfps_gender // 

*Notes on different variable names
// cfps2014_age became cfps_age, 
//cfps2012_latest_edu, adding cfps_latest_school attending school, }
//cfps2016edu cfps2016sch cfps2016eduy cfps2016eduy_im,
// qa701code is now pa701code your ethnicity, cfps_minzu doesnt exist anymore, 
//for te4 highest degree of education instead pw1r cfps2016edu
// wc01 attending school is now pc1 
//wc02 is now cfps_latest_school, 
//kr1 level of school currently attending pc3
// kr2 current primary school is now ps3
// kr3 current junior high school is now ps4
// kr4 current senior high school is now ps5
// kr5m 3 year college is now ps7 
// kr6m 4 year college ps8
// kr701 kr801 if field of major in master and doctoral degree what, not replacing 
// kw* educational history remains
// kra1 full time or part time student pc4
// kr1 level of school currently attending pc3

* ids
tostring fid16, gen(household_id)
tostring pid, gen(individual_id)
* save tempfile
g subset = "Adult"
save "`adult'"

** [iv]. Child
* open raw data
use "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)\[CFPS Public Data] CFPS2016 in STATA (English)\ecfps2016child_201906.dta", clear
* keep vars
keep pid fid* cid provcd countyid rswt_nat* rswt_res* ///
cfps_age cfps_gender pa701code pc601am_b_1 pc601ay_b_1 pc601bm_b_1 pc601by_b_1 pc6_b_1 ps201_b_1 ps202_b_1 ps203_b_1 ps204a_b_1 ps205_b_1 pc6_b_1 pc1_b_1 pc1_b_2 pc3_b_1 pc3_b_2 ppc5_b_1 ppc5_b_2 kw* cfps* ps201_b_1 pc3_b_1 pc3_b_2 pc1_b_1 school_b_2 cfps_latest_school cfps2014_interv urban* cfps_latest_edu cfps_latest_r1 cfps2016edu pc1_b_1 pc1_b_2 pc3_b_1 pc3_b_2 ppc5_b_1 ppc5_b_2 wf309a wf309b wf310a wf310b ps1102_b_1 ps1102_b_2 ps1003_b_1 ps1003_b_2 ps10_b_1 ps10_b_2 pd7r pr3_b_1 pr3_b_2 kw302_b_1 kw302_b_2 kw302_b_3 kw302_b_4 kw302_b_5 kw302_b_6 kw403_b_1 kw403_b_4 kw503_b_1 kw503_b_4 kw603_b_1 kw603_b_4 kw703_b_1 kw703_b_4 kw803_b_1 kw803_b_4 kw903_b_1 kw903_b_4 pc601ay_b_1 pc1_b_1 school_b_1 pc3_b_1 ppc5_b_1 ps201_b_1 ps202_b_1 ps4_b_1 ps7_b_1 ps8_b_1 ps10_b_1 pc1_b_2 school_b_2 pc3_b_2 ppc5_b_2 ps4_b_2 ps7_b_2 ps8_b_2 ps10_b_2 ps1002_b_1 ps1002_b_2 ps602_b_1 ps604_b_1 ps602_b_2 ps604_b_2 ps5_b_1 kw401_b_1 ps4_b_1 ps203_b_1 kw301_b_1 kw301_b_2 kw301_b_3 ps205_b_1 ps204a_b_1 kw501_b_1 ps603_b_1 ps5_b_2 ps4_b_2 ps603_b_2 kw401_b_4 kw301_b_4 kw301_b_5 kw301_b_6 kw501_b_4 pc3_b_1 pc3_b_2 ppc5_b_1 kw603_b_1 kw703_b_1 kw803_b_1 kw302_b_2 kw302_b_3 kw903_b_1 kw403_b_1 kw302_b_1 kw503_b_1 kw603_b_4 kw703_b_4 kw903_b_4 kw403_b_4 kw803_b_4 kw302_b_4 kw302_b_5 kw302_b_6 kw503_b_4 ps10_b_1 ps10_b_2 ps604_b_1 ps604_b_2 

//  wf101 wf3* wf301-wf306 cfps2012_latest_edu cfps2012_latest_r1 te4  kr1ckp3 kr1ckp4 ///
// wh* kr1-kr405  kw* cfps* wf111 wf301m wc01 wc02 cfps2012_interv cfps2010_interv urban* ok
* ids
tostring fid16, gen(household_id)
tostring pid, gen(individual_id)
* save tempfile
g subset = "Child"
save "`child'"

*Changes of variable names
// cfps2014_age is now cfps_age
// wa6code is now pa701code
// wf1* are kindergarden related qs, adult reported qs are pc601am_b_1 pc601ay_b_1 pc601bm_b_1 pc601by_b_1 pc6_b_1 ps201_b_1 ps202_b_1 ps203_b_1 ps204a_b_1 ps205_b_1
// wf101 is child ever attended kinder is adult reported pc6_b_1
// wf3* is a bunch of attending currently related, is now pc1_b_1 pc1_b_2 pc3_b_1 pc3_b_2 ppc5_b_1 ppc5_b_2 wf309a wf309b wf310a wf310b ps1102_b_1 ps1102_b_2 ps1003_b_1 ps1003_b_2 ps10_b_1 ps10_b_2 pd7r pr3_b_1 pr3_b_2 kw302_b_1 kw302_b_2 kw302_b_3 kw302_b_4 kw302_b_5 kw302_b_6 kw403_b_1 kw403_b_4 kw503_b_1 kw503_b_4 kw603_b_1 kw603_b_4 kw703_b_1 kw703_b_4 kw803_b_1 kw803_b_4 kw903_b_1 kw903_b_4 pc601ay_b_1 pc1_b_1 school_b_1 pc3_b_1 ppc5_b_1 ps201_b_1 ps202_b_1 ps4_b_1 ps7_b_1 ps8_b_1 ps10_b_1 pc1_b_2 school_b_2 pc3_b_2 ppc5_b_2 ps4_b_2 ps7_b_2 ps8_b_2 ps10_b_2 ps1002_b_1 ps1002_b_2 ps602_b_1 ps604_b_1 ps602_b_2 ps604_b_2 ps5_b_1 kw401_b_1 ps4_b_1 ps203_b_1 kw301_b_1 kw301_b_2 kw301_b_3 ps205_b_1 ps204a_b_1 kw501_b_1 ps603_b_1 ps5_b_2 ps4_b_2 ps603_b_2 kw401_b_4 kw301_b_4 kw301_b_5 kw301_b_6 kw501_b_4
// wf111 is attending kindergarten is now ps201_b_1
// wf301m is level of school is child attending now has adult and child version pc3_b_1 pc3_b_2
// wc01 attending school is now pc1_b_1 school_b_2
//wc02 is now cfps_latest_school
// cfps2012_interv is now cfps2014_interv
// cfps2012_latest_r1 is now cfps_latest_r1
// te4 is now cfps2016edu
// wf301-wf306 is now pc3_b_1 pc3_b_2 ppc5_b_1 kw603_b_1 kw703_b_1 kw803_b_1 kw302_b_2 kw302_b_3 kw903_b_1 kw403_b_1 kw302_b_1 kw503_b_1 kw603_b_4 kw703_b_4 kw903_b_4 kw403_b_4 kw803_b_4 kw302_b_4 kw302_b_5 kw302_b_6 kw503_b_4 ps10_b_1 ps10_b_2 ps604_b_1 ps604_b_2
// idk what kr1ckp3 kr1ckp4, they do now appear in 2014 dataset

** [v] Merge datasets and save
use "`adult'", clear
append using "`child'"
tempfile adultchild
save "`adultchild'"
merge 1:1 individual_id using "`familyroster'", gen(_m1)
merge m:1 household_id using "`family'", gen(_m2)
drop if _m1!=3
drop if _m2!=3
drop _m1 _m2

/* Omit this labels for the moment 
*Labeling some variables that are in Chinese
label define no5 -8 "Not applicable" 1 "Yes" 5 "no" 
label define no0 -8 "Not applicable" 1 "Yes" 0 "no" 
label define lwf111 -8 "Not applicable" 1 "Kindergarten" 5 "Preschool class"
label define lwf106a -1 "Unknown" -8 "Not applicable" 1 "Full time" 2 "Half-time" 3 "On hourly basis" 


label var wf3m "Whether child is currently attending school(CHILD)"
label values wf3m no5

label var wf301m "Level of school that child is attending"

label drop wf301m
label define wf301m -1 "Unknown" -8 "Not applicable" 1 "Daycare" 2 "Kindergarten/Preschool class" 3 "Primary school" 4 "Junior high school" ///
5 "Senior high school/secondary/technical/vocational senior" 6 "2-or 3-year college"
label values wf301m wf301m

label var wf302 "Grade which child is attending"
label drop wf302
label define wf302 -8 "Not applicable" -1 "Unknown"
label values wf302 wf302


label var wf111 "Child attending kindergarten or preschool class(CHILD)"
label values wf111 lwf111

label var wf106a "How child attending kinder or preschool class"
label values wf106a lwf106a

label var wa6code "Child's ethnicity"
label var kr1ckp3 "CHILD Check highest educational level achieved by last interview"
label var kr1ckp4 "CHILD Confirm highest educational level recorded at last interview"
*/
 
g country = "China"
g survey = "CFPS"
g year = 2016
compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
save "China_CFPS_2016.dta", replace



************************************************************************************************************
*************PART 2: categories calculations, rename and define category variables *************************
************************************************************************************************************
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
use "China_CFPS_2016.dta", clear


* Weights ? (in 2010 "rswt_nat"="Individual-level national sampling weights)
*Coordinated w Ameer
gen hhweight = rswt_natcs16  

* Age // ? there is no one under "4 years of age"
codebook cfps_age, tab(200)
recode cfps_age (-8=.) (-1=.) , gen(age)
gen age_original=age
*Adjustment issue 
*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more
*In China, school starts in SEPTEMBER.
*Quote of CFPS User Guide 
// The 2016 follow-up survey was conducted in two stages: During the first stage,
// which started on June 28, 2016 and ended on April 30, 2017, we revisited the original
// addresses and conducted local interviews. During the second stage,which started on
// May 13, 2016 and ended on April 30, 2017, we conducted telephone interviews.
*replace age = age -1 

* Gender
*codebook tb2_a_p cfps_gender
*tab tb2_a_p cfps_gender
replace cfps_gender=. if cfps_gender==-8
clonevar sex=cfps_gender

* Region: two variables, provcd16 fid_provcd16, here we're following 2014
codebook provcd16, tab(200)
*decode provcd16, gen(region)
rename provcd16 region
label val region provcd16
replace region=. if region==-9

* Location
codebook urban16
*decode urban16, gen(location)
rename urban16 location
label val location urban16
replace location=. if location==-9



* Ethnicity
codebook pa701code,tab(200)
g eth = "Han" if pa701code==1
replace eth = "Other" if (pa701code>1 & pa701code<.) 
encode eth, gen(ethnicity)  // ? few observations!! (only 10% of the sample)

*====
* Wealth 

*d faminc_net_old faminc_net faminc_old faminc indinc indinc_net foperate_net 
// in 2010 use faminc_net "Adjusted net family income"
// in 2014 use fincome2 "Net family income (comparable with year 2010)"

*xtile wealth = hh, nquantiles(5)
*Using Net family income per capita(yuan) fincome1_per 
*Adding weights
xtile wealth = fincome1_per [pw=hhweight], nquantiles(5)
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth 
*drop hh
*====

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
save "China_CFPS_2016.dta", replace


************************************************************************************************************
*************PART 3: all indicators (clean and calculate) **************************************************
************************************************************************************************************
***I have 2 sources of code for this, keep_vars.do, and WIDE_large_countries_China_2010-2012-2014 I will reorder that code

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
use "China_CFPS_2016.dta", clear

** Education system information

* Primary
local primaryage0 = 6
local primaryage1 = 11
local primaryfirst = 1
local primarylast = 6
local primarydur = 6
* Lower secondary
local lowersecondaryage0 = 12
local lowersecondaryage1 = 14
local lowersecondaryfirst = 7 
local lowersecondarylast = 9
local lowersecondarydur = 3
* Upper secondary
local uppersecondaryage0 = 15
local uppersecondaryage1 = 17
local uppersecondaryfirst = 10 
local uppersecondarylast = 12
local uppersecondarydur = 3

** Age groups:

* Age for each level
gen prim_age0=`primaryage0'
gen prim_age1=`primaryage1'
gen lowsec_age0 = `lowersecondaryage0'
gen lowsec_age1 = `lowersecondaryage1'
gen upsec_age0 = `uppersecondaryage0'
gen upsec_age1 = `uppersecondaryage1'

*this from keep_vars
gen prim_age0_eduout = 6
gen prim_dur = 6
gen lowsec_dur = 3 
gen upsec_dur = 3

gen years_prim   = 6
gen years_lowsec = 6+3
gen years_upsec  = 6+3+3


*Following this 
*Levels: 0=preschool, 1=primary, 2=lowsec, 3=upsec/general educ/vocational educ, //
*        4=post sec non tertiary/general educ/vocat educ; 5=short cycle tertiary, 6=bachelor; 7=master, 8=phd 
local highestlevelattended cfps2016edu
*pe020 es levelattendingcurrentyear
*pe040 es  highestlevelattended
*See ICSED mapping file for correspondence

*I have 4 candidates for highest level attended: cfps_latest_edu pw1r cfps2016edu tb4_a16_p. Despite tb... having no missings, I'd trust cfps2016edu more. 

// 0<-1	Illiterate/Semi-literate
// 1<-2	Primary school
// 2<-3	Junior high school
// 3<-4	Senior high school/secondary school/tec
// 5<-5	3-year college 
// 6<-6	4-year college //assume as bachelor
// 7<-7	Master's degree
// 8<-8	Doctoral degree

recode `highestlevelattended' (1=0) (2=1) (3=2) (4=3) (5=5) (6=6) (7=7) (8=8) , gen(highestlevelattended)
*Fixing with cfps2016eduy_im years of education imputed
*6-3-3
replace highestlevelattended=0 if inlist(cfps2016eduy_im, 0, 1, 2, 3, 4, 5)
replace highestlevelattended=1 if inlist(cfps2016eduy_im, 6, 7, 8)
replace highestlevelattended=2 if inlist(cfps2016eduy_im, 9, 10, 11)
replace highestlevelattended=3 if inlist(cfps2016eduy_im, 12, 13, 14) 


gen schage = age-1 

***Completion variables:  comp_prim_v2 comp_lowsec_v2 comp_upsec_v2  comp_prim_1524 comp_lowsec_1524 comp_upsec_2029

for X in any prim lowsec upsec: gen comp_X=0 if highestlevelattended!=.
replace comp_prim=1 if highestlevelattended >= 1 & comp_prim == 0
replace comp_lowsec=1 if highestlevelattended >= 2 & comp_lowsec == 0
replace comp_upsec=1 if highestlevelattended >= 3 & comp_upsec == 0

*Age limits
foreach X in prim lowsec upsec {
foreach AGE in schage {
	gen comp_`X'_v2=comp_`X' if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5
	gen comp_`X'_1524=comp_`X' if `AGE'>=15 & `AGE'<=24
	gen comp_`X'_2024=comp_`X' if `AGE'>=20 & `AGE'<=24
}
}

gen comp_upsec_2029=comp_upsec if schage>=20 & schage<=29
gen comp_upsec_2029_no=comp_upsec_2029

// foreach AGE in schage  {
// 		generate comp_prim_1524   = comp_prim if `AGE' >= 15 & `AGE' <= 24
// 		generate comp_upsec_2029  = comp_upsec if `AGE' >= 20 & `AGE' <= 29
// 		generate comp_lowsec_1524 = comp_lowsec if `AGE' >= 15 & `AGE' <= 24
// 	}


*EDUYEARS will combine level and highest level-grade attended
*The USER GUIDE on page 96 has a conversion table (last number=years of schooling)
// 1 Illiterate/ semi-illiterate 0
// 2 Primary school 6
// 3 Middle school 9
// 4 High school 12
// 5 2 or 3 year college 15
// 6 Bachelor‘s degree 16
// 7 Master‘s degree 19
// 8 Doctoral degree 22

// 0<-1	Illiterate/Semi-literate
// 6<-2	Primary school
// 9<-3	Junior high school
// 12<-4	Senior high school/secondary school/tec
// 15<-5	3-year college 
// 16<-6	4-year college //assume as bachelor
// 19<-7	Master's degree
// 22<-8	Doctoral degree

gen eduyears=.
replace eduyears=0 if cfps2016edu==1
replace eduyears=6 if cfps2016edu==2
replace eduyears=9 if cfps2016edu==3
replace eduyears=12 if cfps2016edu==4
replace eduyears=15 if cfps2016edu==5
replace eduyears=16 if cfps2016edu==6
replace eduyears=19 if cfps2016edu==7
replace eduyears=22 if cfps2016edu==8

*DATA COLLECTION DAYS OF THE SURVEY
*Start	End	Cycle
*2019-09-02	2019-11-15	Anual

*According to Colombia Education Ministry : empieza en el mes de febrero y culmina en el mes de noviembre
*https://www.mineducacion.gov.co/1759/w3-article-364691.html?_noredirect=1

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*100% of hh have 6 months of difference or more



***
***Mean years of education: eduyears_2024
***
generate eduyears_2024 = eduyears if schage >= 20 & schage <= 24

***

*ATTENDING: "Attended school during current school year?"
*pc1_b_1 for adult report on children
* pc1 if for adult proxy report on adult UP TO 45 years old 
generate attend = 1 if pc1_b_1 == 1
replace attend  = 0 if pc1_b_1 == 0
replace attend = . if pc1_b_1 == -8
replace attend = 1 if pc1 == 1
replace attend = 0 if pc1 == 0
replace attend = . if pc1_b_1 == -8
replace attend = 1 if inlist(pc3, 3, 4, 5, 6, 7, 8, 9)
recode attend (1=0) (0=1), gen(no_attend)


***Pre-primary education attendance: preschool_1ybefore 
***
*Percentage of children attending any type of pre–primary education programme, 
*(i) as 3–4 year olds and NOT THIS
*(ii) 1 year before the official entrance age to primary. THIS

*ps201_b_1 Adult proxy report:How does child attending kindergarten or preschool class

	 generate attend_preschool   = 1 if ps201_b_1 == 1 
	 replace attend_preschool    = 0 if ps201_b_1 == 0
	 generate preschool_3        = attend_preschool if schage >= 3 & schage <= 4
	 generate preschool_1ybefore = attend_preschool if schage == prim_age0_eduout - 1


***
****Higher education attendance: attend_higher_1822
***
*pc3 Level of school currently attending FOR ADULTS only, for children none register higher level ofc pc3_b_1 pc3_b_2

generate high_ed = 1 if inlist(pc3, 6, 7, 8, 9)
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
capture replace eduout  = . if (attend == 1 & pc3 == .) | age == . 
capture replace eduout  = 1 if ps201_b_1 == 1 
capture replace eduout  = 1 if ps201_b_1 == 0 

generate lowsec_age0_eduout = prim_age0_eduout + prim_dur
generate upsec_age0_eduout  = lowsec_age0_eduout + lowsec_dur
for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age0_eduout + X_dur - 1

*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}

***
***NEVER BEEN TO SCHOOL: edu0_prim
***
generate edu0 = 0 if inlist(cfps2016edu, 2, 3, 4, 5, 6, 7, 8) 
replace edu0  = 1 if inlist(cfps2016edu, 1)
replace edu0  = 1 if inlist(tb4_a16_p, 1) & edu0==.
replace edu0  = 1 if eduyears == 0

generate edu0_prim = edu0 if schage >= prim_age0 + 3 & schage <= prim_age0 + 6

*Completion of higher
	foreach X in 2 4 {
		generate comp_higher_`X'yrs = 0
		replace comp_higher_`X'yrs = . if inlist(cfps2016edu, ., 1 )
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
gen overage2plus= 0 if attend==1 & pc3_b_1==3
	gen primarygrades=ppc5_b_1 if ppc5_b_1>0 & pc3_b_1==3
	levelsof primarygrades, local(primgrades) clean
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus=1 if ppc5_b_1==`grade' & schage>prim_age0+1+`i'
                 }

foreach var in comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_3 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus{
gen `var'_no=`var'
}

compress
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
save China_microdata.dta, replace


************************************************************************************************************
*************PART 4: collapse / summarize ******************************************************************
************************************************************************************************************

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
use China_microdata.dta, clear

global categories_collapse location sex wealth region ethnicity
global varlist_m comp_lowsec_2024 comp_upsec_2024 comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 eduyears_2024 preschool_3 preschool_1ybefore attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 eduout_prim eduout_lowsec eduout_upsec edu0_prim edu2_2024 edu4_2024 overage2plus *age0 *age1 *dur 
global varlist_no comp_lowsec_2024_no comp_upsec_2024_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no preschool_3_no preschool_1ybefore_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no edu2_2024_no edu4_2024_no overage2plus_ no

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

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"

set more off
set trace on
foreach i of numlist 0/5 6/12 14/19 21 23 25/26 29 30 {
	use China_microdata, clear
	qui tuples $categories_collapse, display
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(`tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
set trace off

*****************************************************************************************
*****************************************************************************************

* Appending the results
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/5 6/12 14/19 21 23 25/26 29 30 {
 	append using "result`i'"
}
drop if t_0==1
drop t_0

gen year="2016"
gen country_year="China"+"_"+year
destring year, replace
gen iso_code2="CN"
gen iso_code3="CHN"
gen country = "China"
gen survey="CFPS"
replace category="Total" if category==""

	
	global categories_collapse location sex wealth region ethnicity
	
	*-- Fixing for missing values in categories
	for X in any $categories_collapse: decode X, gen(X_s)
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

				 

save "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\China CFPS\[CFPS Public Data] CFPS 2016 in STATA (English)\indicators_China_2016.dta", replace




