*===========================================================================================
* WIDE_EU_SILC.do
*
* This file produces the WIDE dataset for EU-SILC (waves 2005 and 2013) by dimensions.
*
*
*
*
* File created: 09 March 2016
* File last modified: 27 May 2016.
* File 1st modified by Rosa: 28 June 2017
* File last modified by Rosa: 10 October 2017

*============================================================================================


clear all
macro drop all
version 14.1
set more off
set maxvar 9000


* Today
local today = subinstr("`c(current_date)'", " ", "", .)



* Globals

global datadir_eu_silc "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_EU_SILC\data\raw"

global projdir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_EU_SILC"

global progdir "$projdir\programs"
global datafinal "$projdir\data\output"
global datadir_r "$projdir\data\raw"
global progdir_eu_silc "$projdir\programs\eu_silc_co"




***========================================================
** S1. Recode each country data (EU-SILC)
*

* Locals for datasets 
include "$progdir`c(dirsep)'eu_silc_survey_list"

* Temp files 
local k : list sizeof survey_list_EU_SILC
forvalues i=1(1)`k' {
     tempfile f`i'
}	 

* Recode each dataset
local i = 1
foreach x of local survey_list_EU_SILC {
	use "$datadir_eu_silc`c(dirsep)'`x'", clear
	tokenize "`x'", parse("\")
	g country = "`1'"
	g year1 = `3'
	g survey = "EU-SILC"
	do  "$progdir_eu_silc`c(dirsep)'`1'`3'"  
	save "`f`i''"
	local ++i
}	


* Append tempfiles
tempfile pooled_EU_SILC
local i=1
use "`f`i''", clear
save "`pooled_EU_SILC'"
qui forvalues i=2(1)`k' {	
    di in red "---- `i' out of `k' EU-SILC ----"
	append using "`f`i''"
	compress
	save "`pooled_EU_SILC'", replace
}	
save "$datadir_r\pooled_EU_SILC_1.dta", replace



*=====

**** Indicators ****
use "$datadir_r\pooled_EU_SILC_1.dta", clear
local today = subinstr("`c(current_date)'", " ", "", .)
*[note: dropped non-define indicators due to age censoring]
bys country year household_id: egen temp_max_weight=max(hhweight)
bys country year household_id: egen temp_min_weight=min(hhweight)
*br country year survey household* temp* hhweight if age_preschool<10
*br country year survey age age_preschool household* temp* hhweight if country=="AT" & year==2005 & household_id=="101002"

replace hhweight=temp_max_weight if hhweight==. & age_preschool<10 // to complete the weights for the R module
drop temp_max_weight temp_min_weight

*** (i). From wide file

* Lower secondary completion rate (%)
gen comp_lowsec = 0 if (age_comp_lowsec_5==1) & comp_lowsec_temp!=.
recode comp_lowsec (0=1) if comp_lowsec_temp==1
gen comp_lowsec_v2 = 0 if (age_comp_lowsec_3==1) & comp_lowsec_temp!=.
recode comp_lowsec_v2 (0=1) if comp_lowsec_temp==1
gen comp_lowsec_1524 = 0 if (agegroup_1524==1) & comp_lowsec_temp!=.
recode comp_lowsec_1524 (0=1) if comp_lowsec_temp==1

*Added:
gen comp_lowersec_rev_1524=comp_lowersec_rev if agegroup_1524==1


* Upper secondary completion rate (%)
gen comp_upsec = 0 if (age_comp_upsec_5==1) & comp_upsec_temp!=.
recode comp_upsec (0=1) if comp_upsec_temp==1
gen comp_upsec_2029 = 0 if (agegroup_2029==1) & comp_upsec_temp!=.
recode comp_upsec_2029 (0=1) if comp_upsec_temp==1
gen comp_upsec_v2 = 0 if (age_comp_upsec_3==1) & comp_upsec_temp!=.
recode comp_upsec_v2 (0=1) if comp_upsec_temp==1

// NEW
* Out of school adolescents (upper sec) (%)
gen edu_out_upsec= 0 if (agegroup_upper_sec==1)
recode edu_out_upsec (0=1) if (enrolment==0)
replace edu_out_upsec=. if enrolment==.


*** (ii). From tertiary file

** Completion Rates 
* Completion rate higher (age higher1, higher1+3)
gen comp_higher_3 = 0 if (age_comp_higher_3==1) & comp_higher_temp!=.
recode comp_higher_3 (0=1) if comp_higher_temp==1
* Completion rate higher (age 25-29)
gen comp_higher_2529 = 0 if (agegroup_2529==1) & comp_higher_temp!=.
recode comp_higher_2529 (0=1) if comp_higher_temp==1
* Added
gen comp_higher_3034 = 0 if (agegroup_3034==1) & comp_higher_temp!=.
recode comp_higher_3034 (0=1) if comp_higher_temp==1

*Added
gen comp_higher_rev_2529=comp_higher_rev if agegroup_2529==1
gen comp_higher_rev_3034=comp_higher_rev if agegroup_3034==1

gen comp_higher_2529_2yrs=comp_higher_rev_2y if agegroup_2529==1
gen comp_higher_3034_2yrs=comp_higher_rev_2y if agegroup_3034==1

gen comp_higher_2529_4yrs=comp_higher_rev_4y if agegroup_2529==1
gen comp_higher_3034_4yrs=comp_higher_rev_4y if agegroup_3034==1

** Attendance (current)
* Age: 5 year group after upsec
gen att_higher_5 = 0 if age_attend_5==1 & att_higher_temp!=.
replace att_higher_5 = 1 if att_higher_temp==1 
* Age 18-24 (for by age analysis)
gen att_higher_1824 = 0 if agegroup_1824==1 & att_higher_temp!=.
replace att_higher_1824 = 1 if att_higher_temp==1 

*Added
gen enrol_higher_1822= enrol_higher_rev if agegroup_1822==1
gen enrol_higher_2022= enrol_higher_rev if agegroup_2022==1


* Added Preschool
gen preschool_0304=preschool if agegroup_preschool_0304==1

gen preschool_4=preschool if agegroup_preschool_4==1
gen preschool_5=preschool if agegroup_preschool_5==1
gen preschool_6=preschool if agegroup_preschool_6==1
gen preschool_1ybefore=preschool if age_preschool==age_1ybefore

*=====

* Country and region names
include "$progdir\country_names" 
include "$progdir\region_names" 


* Keep vars
keep country year survey hhweight ///
sex urban wealt* winde* region migrant ///
comp_lowsec comp_lowsec_v2 comp_lowsec_1524 ///
comp_upsec comp_upsec_v2 comp_upsec_2029 ///
edu_out_upsec ///
att_higher_5 att_higher_1824 ///
comp_higher_3 comp_higher_2529 comp_higher_3034 presch* ag* comp* enrol*


*> new - drop some vars
drop edu_out_upsec comp_higher_3 


* Save pooled data 
save "$datadir_r\pooled_EU_SILC_2.dta", replace



***========================================================
** S2. Means by dimensions (EU-SILC)
*

* Today
use "$datadir_r\pooled_EU_SILC_2.dta", clear
*Fixing the fact that we lost the hhweights for kids

* Today
local today = subinstr("`c(current_date)'", " ", "", .)
include "$progdir\WIDE_EU_SILC_analysis"

* Recode and drop migrant + wealth
replace category="Country Total Ethnicity" if category=="Country Total Migrant"
drop if category=="Migrant and Country Wealth Index Quintiles"

* Save results 
save "$datafinal`c(dirsep)'WIDE_EU_SILC_`today'.dta", replace
* Transfer to excel
export excel using "$datafinal`c(dirsep)'WIDE_EU_SILC_`today'.xls", firstrow(variables) replace


/* END of do file */




/*
**** Final checks
** 
use "$datafinal\WIDE_EU_SILC_24Jul2017.dta", clear
keep if category=="Country Total All"
sort country year
br country year subcategory1 comp_higher_3034_m enrol_higher_1822_m enrol_higher_2022_m 
br country year subcategory1 comp_lowsec_v2_m comp_lowsec_1524_m
*/



