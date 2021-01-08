*For Desktop-Work
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global data_raw_mics "$gral_dir\Data\MICS"
global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"

global dir_synchro "P:\WIDE"
global aux_data "$dir_synchro\auxiliary_data"
global programs_mics "$dir_synchro\programs\MICS"
global aux_programs "$programs_mics\auxiliary"

global output "$dir_synchro\output\edu_indicators"


*For laptop
*global gral_dir "C:\Users\Rosa_V\Dropbox"
*global data_raw_mics "$gral_dir\WIDE\Data\MICS"

*global programs_mics "$gral_dir\WIDE\WIDE_DHS_MICS\programs\mics"
*global aux_programs "$programs_mics\auxiliary"
*global aux_data "$gral_dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
*global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"

*Vars to keep
global vars_mics4 hh1 hh2 hh5* hl1 hl3 hl4 hl5* hl6 hl7 hh6* hh7* ed1 ed3* ed4* ed5* ed6* ed7* ed8* windex5 schage hhweight religion ethnicity region windex5
global list4 hh6 hh7 ed3 ed4a ed4b ed5 ed6b ed6a ed7 ed8a religion ethnicity hh7r ed3x ed4 ed4ax region 
global vars_keep_mics "hhid hvidx hv000 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124"
global categories sex urban region wealth
*global extra_keep ...// for the variables that I want to add later ex. cluster

global categories_collapse location sex wealth region ethnicity religion
global categories_subset location sex wealth
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no

** COMPARISON WITH UIS RESULTS

*To create the flags for total

use "$aux_data\UIS\completion\UIS_comp_eduout_02262020_with_sources.dta", clear
for X in any region ethnicity religion: gen X=""
save "$aux_data\UIS\completion\UIS_comp_eduout_02262020_TEMP.dta", replace


use "$aux_data\UIS\completion\UIS_comp_eduout_02262020_with_sources.dta", clear
keep if category=="Total"
save "$aux_data\UIS\completion\UIS_comp_eduout_02262020_TOTAL.dta", replace

***********-------------------------------------------------------------------------------------------
use "$output\collapse_Feb2020\dhs_collapse_by_categories_v10.dta", clear
gen round="all"
append using "$output\collapse_Feb2020\mics_collapse_by_categories_v10.dta"
replace round="2 to 5" if round==""
append using "$output\collapse_Feb2020\mics6_collapse_by_categories_v02.dta"
replace round="6" if round==""
compress
drop part *aux adjustment
*Changes to the year so WIDE years match with UIS years
*I add the year uis for those that have missing
replace year_uis=year if year_uis==.
replace year_uis=2018 if country=="Benin" & year==2017
replace year_uis=2017 if country=="Burundi" & year==2016
replace year_uis=2018 if country=="Philippines" & year==2017
replace year_uis=2014 if country=="Turkey" & year==2013
replace year_uis=2016 if country=="Thailand" & year==2015

replace year_uis=2007 if country=="Bangladesh" & year==2007 & survey=="DHS"
replace year_uis=2011 if country=="Ghana" & year==2011 & survey=="MICS"
replace year_uis=2014 if country=="Zimbabwe" & year==2014 & survey=="MICS"
save "$output\collapse_dhs_mics_02272020.dta", replace
export delimited using "$output\collapse_dhs_mics_02272020.csv", replace


***********************************************************************************************************
***********************************************************************************************************
use "$output\collapse_dhs_mics_02272020.dta", clear
keep if category=="Total"
codebook survey, tab(100)
merge 1:1 iso_code3 survey year_uis category using "$aux_data\UIS\completion\UIS_comp_eduout_02262020_TOTAL.dta"
keep if survey=="DHS"|survey=="MICS"
tab _merge
table country if _m==2, c(mean year_uis) 
*Completing the info for those that _merge==2
br iso country year* if _merge==2
*Sri Lanka DHS 2006  (Data not available)
*Timor-Leste DHS 2016 (needs to be added, data available)
*Uganda DHS 2016 (needs to be added, data available)

replace country_year=country+"_"+string(year_uis) if _merge==2
replace year=year_uis if _merge==2

for X in any prim lowsec upsec: gen diff_comp_X=abs(comp_X_v2-comp_X_uis)
for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)

*Flags for completion
gen flag_comp=0 // Both in UIS & GEM. No problem
replace flag_comp=1 if (diff_comp_prim>=3|diff_comp_lowsec>=3|diff_comp_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_comp=2 if comp_prim_uis==. // Only in GEM
replace flag_comp=3 if (comp_prim_v2==. & comp_prim_uis!=.) // Only in UIS

*Flags for out of school
gen flag_eduout=0 // Both in UIS & GEM. No problem
replace flag_eduout=1 if (diff_eduout_prim>=3|diff_eduout_lowsec>=3|diff_eduout_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_eduout=2 if eduout_prim_uis==. // Only in GEM
replace flag_eduout=3 if (eduout_prim==. & eduout_prim_uis!=.) // Only in UIS

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
for X in any comp eduout: label values flag_X flag

foreach X in comp eduout {
gen result_`X'="UIS estimates are reported" if flag_`X'==0
	replace result_`X'="Need to analyze" if flag_`X'==1
	replace result_`X'="GEM estimates are reported" if flag_`X'==2
	replace result_`X'="UIS estimates are reported" if flag_`X'==3
}

sort survey country_year
order survey country_year year comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 flag_comp result_comp diff_comp_prim diff_comp_lowsec diff_comp_upsec eduout_prim eduout_lowsec eduout_upsec flag_eduout result_eduout diff_eduout_prim diff_eduout_lowsec diff_eduout_upsec
br survey country_year year comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 flag_comp result_comp diff_comp_prim diff_comp_lowsec diff_comp_upsec eduout_prim eduout_lowsec eduout_upsec flag_eduout result_eduout diff_eduout_prim diff_eduout_lowsec diff_eduout_upsec
compress
save "$output\collapse_Feb2020\Comparison_GEM_UIS_02262020.dta", replace
export delimited using "$output\collapse_Feb2020\Comparison_GEM_UIS_02262020.csv", replace

************
use "$data_mics\hl\mics_AllRounds_collapse_categories_v5.dta", clear
append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS\data\PR\dhs_collapse_by_categories_v8.dta"

merge 1:1 iso_code3 survey year_uis category location sex wealth region ethnicity religion using "$aux_data\UIS\completion\UIS_completion_29Nov2018_TEMP.dta"
keep if survey=="DHS"|survey=="MICS"
tab iso_code3 if _m==2 //these 6 plus Yemen 2013

* MERGE=2 6 countries plus Yemen 2013
 	* BDI Burundi DHS 2017 
	* BLZ Belize MICS 2016 
	* LKA Sri Lanka DHS 2006 (fata not public)
	* TLS Timor-Leste DHS 2016
	* UGA Uganda DHS 2016 
* MERGE=2 additional that just appeared	
	 *  ARG Argentina MICS 2011 			// To be dropped because it only includes URBAN.
     *  LCA Saint Lucia MICS 2012  (19 obs) // it has another name for wealth. Called windex51 before
     *  URY Uruguay MICS 2013 (19 obs) 		// it has another name for wealth. Called windex5_5 before
     *  ZMB Zambia DHS 2001 (40 obs) 		// UIS has wealth, but wealth is not in the DHS database

drop if iso_code3=="ARG" & survey=="MICS" & year_uis==2011

*Eliminate those that are less than 30
*This is to add the end after comparing with UIS
*Append to DHS.
*merge to UIS
*Compare to UIS
*Create flags bys country_year survey: gen keep=1 if diff_prim & diff_lowsec & diff_upsec=0


foreach var of varlist $varlist_no {
	gen count_`var'=1
	replace count_`var'=0 if `var'<30
}
	* Drop rows with n<30 for all variables
	egen row_keep=rowtotal(count_comp_prim_v2_no-count_eduout_upsec_no)
	* Drop rows with n<30 for all variables
	tab row_keep 
	br if row_keep==12
	br if row_keep==0
	drop if row_keep==0 & eduout_prim_uis==.
	

for X in any prim lowsec upsec: gen diff_comp_X=abs(comp_X_v2-comp_X_uis)

gen flag_comp=0 // Both in UIS & GEM. No problem
replace flag_comp=1 if (diff_comp_prim>=3|diff_comp_lowsec>=3|diff_comp_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_comp=2 if comp_prim_uis==. // Only in GEM
replace flag_comp=3 if (comp_prim_v2==. & comp_prim_uis!=.) // Only in UIS
replace flag_comp=. if category!="Total"
bys country_year survey: egen t_flag=max(flag_comp) 
drop flag_comp

label define flag_comp 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
label values t_flag flag_comp

decode t_flag, gen(flag_comp)
drop t_flag

bys flag_comp: tab iso_code3
drop count*
drop iso_code2*
drop diff*
drop _merge
drop row_keep
merge m:1 iso_code3 using "$aux_data/country_iso_codes_names.dta", keepusing(country)
drop if _merge==2
drop _merge
sort iso_code3 country year survey category 
order iso_code3 country year survey category $categories_collapse $vars_m $vars_no

gen categories_uis=1 if (category=="Total"|category=="Location"|category=="Sex"|category=="Wealth"|category=="Sex & Wealth"|category=="Location & Wealth"|category=="Location & Sex"|category=="Location & Sex & Wealth")

foreach X in comp_prim comp_lowsec comp_upsec {
	replace `X'_v2=`X'_uis if categories_uis==1 & flag_comp=="Both in UIS & GEM. No problem"
}

** Have to check if with the UIS replacements some have n<30

gen source="GEM"
replace source="UIS" if categories_uis==1 & flag_comp=="Both in UIS & GEM. No problem"

save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\edu_indicators\GEM_UIS_AllCategories_v2.dta", replace
*-----------------------------------

use "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\edu_indicators\GEM_UIS_AllCategories_v2.dta", clear
export excel "C:\Users\Rosa_V\Desktop\WIDE\WIDE\data_created\edu_indicators\GEM_UIS_AllCategories_v2.csv", firstrow(variables) replace


*****************************************************************************
use "$gral_dir\WIDE\WIDE_DHS_MICS\data\GEM_UIS_AllCategories_v5.dta", clear
keep if survey=="DHS"
keep if category=="Total"
replace year=year_uis if year==.
keep country year eduout_prim eduout_lowsec eduout_upsec eduout_prim_uis eduout_lowsec_uis eduout_upsec_uis

for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)
*Flags for out of school
gen flag_eduout=0 // Both in UIS & GEM. No problem
replace flag_eduout=1 if (diff_eduout_prim>=3|diff_eduout_lowsec>=3|diff_eduout_lowsec>=3) // Both in UIS & GEM. Diff>3
replace flag_eduout=2 if eduout_prim_uis==. // Only in GEM
replace flag_eduout=3 if (eduout_prim==. & eduout_prim_uis!=.) // Only in UIS

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 
for X in any eduout: label values flag_X flag

foreach X in eduout {
gen result_`X'="UIS estimates are reported" if flag_`X'==0
	replace result_`X'="Need to analyze" if flag_`X'==1
	replace result_`X'="GEM estimates are reported" if flag_`X'==2
	replace result_`X'="UIS estimates are reported" if flag_`X'==3
}

*------------------------------------------------------------------------------------
