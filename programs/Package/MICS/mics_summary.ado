* mics_summary: program to summarize the mics indicators 
* Version 1.0
* April 2020

program define mics_summary
	args
	
	/*
** HERE I TEST THE NEW VARIABLES

collapse edu0_prim preschool* attend_higher_1822 comp_higher* [iw=hhweight], by(country_year)
foreach var in edu0_prim preschool_3 preschool_1ybefore attend_higher_1822  comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 {
	replace `var'=`var'*100
}
gen cy=lower(country_year)
sort cy
br
table country year [iw=hhweight], c(mean edu0_prim mean (mean comp_higher_2yrs_2529 mean comp_higher_2yrs_3034
*/

use "$data_mics\hl\Step_4_temp.dta", clear

*Dropping variables
drop country_code*
drop hl* hh5* hh_id cluster hh6 district schage individual_id
drop ed3* ed4* ed5* ed6* ed7* ed8* code*
drop lowsec_age0* upsec_age0* prim_age1* lowsec_age1* upsec_age1*
drop years_prim years_lowsec years_upsec years_higher

save "$data_mics\hl\MICS5_Step_5.dta", replace

**********************************************

use "$data_mics\hl\MICS5_Step_5.dta", clear
drop *no
collapse (mean) comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec [weight=hhweight], by(country_year iso_code3 year adjustment prim_age0_comp prim_dur_comp lowsec_dur_comp upsec_dur_comp prim_age0_eduout prim_dur_eduout lowsec_dur_eduout upsec_dur_eduout )
foreach var of varlist comp* eduout*{
		replace `var'=`var'*100
}
gen category="Total"
gen survey="MICS"
*Merge with year_uis
merge 1:1 iso_code3 survey year using "$aux_data/gem/country_survey_year_uis.dta", keepusing(year_uis)
drop if _merge==2
drop _merge

gen location=""
gen sex=""
gen wealth=""
merge 1:1 iso_code3 survey year_uis category location sex wealth using "$aux_data\UIS/UIS_indicators_29Nov2018_with_metadata.dta"
drop if survey!="MICS"
drop if _merge==2
drop iso_code2 country survey_uis location sex wealth year_uis
gen cy=lower(country_year)
sort cy

drop category survey _merge
order iso_code3 country_year year adjustment *_uis 

for X in any prim lowsec upsec: gen diff_comp_X=abs(comp_X_v2-comp_X_uis)
for X in any prim lowsec upsec: gen diff_eduout_X=abs(eduout_X-eduout_X_uis)

foreach Y in comp eduout {
gen flag_`Y'=0
replace flag_`Y'=1 if (diff_`Y'_prim>=3|diff_`Y'_lowsec>=3|diff_`Y'_lowsec>=3)  // Both in UIS & GEM. Diff>3
replace flag_`Y'=2 if (diff_`Y'_prim==.|diff_`Y'_lowsec==.|diff_`Y'_lowsec==.) // Only in GEM
}
for X in any comp: replace flag_X=3 if (X_prim_v2==. & X_prim_uis!=.) // Only in UIS
for X in any eduout: replace flag_X=3 if (X_prim==. & X_prim_uis!=.) // Only in UIS

for X in any comp: replace flag_X=4 if (X_prim_v2==. & X_prim_uis==.) // Neither in UIS nor in GEM. Ex: Eduout for Cuba 2010 & 2014
for X in any eduout: replace flag_X=4 if (X_prim==. & X_prim_uis==.) // Neither in UIS nor in GEM. Ex: Eduout for Cuba 2010 & 2014

label define flag 0 "Both in UIS & GEM. No problem" 1 "Both in UIS & GEM. Diff>3" 2 "Only in GEM" 3 "Only in UIS" 4 "Neither in UIS nor in GEM"
for X in any comp eduout: label values flag_X flag

keep iso_code3 country_year survey year *_uis flag_comp





***************************************************************
* I put all the MICS together
use "$data_mics\hl\MICS5_Step_5.dta", clear
append using "$data_mics\mics3\hl\MICS3_Step_5.dta"
append using "$data_mics\mics2\hl\MICS2_Step_5.dta"
keep country_year iso_code3 year $categories_collapse $varlist_m $varlist_no adjustment hhweight comp_prim_aux comp_lowsec_aux
order country_year iso_code3 year $categories_collapse comp_prim_aux comp_lowsec_aux $varlist_m $varlist_no adjustment hhweight 
compress
save "$data_mics\hl\All_MICS_Step_5.dta", replace


cap mkdir "$data_mics\hl\collapse"

/*
cd "$data_mics\hl\collapse"
set more off
tuples $categories_collapse, display
foreach i of numlist 0/6 12/18 20/21 31 41 {
	use "$data_mics\hl\All_MICS_Step_5.dta", clear
	collapse (mean) $varlist_m comp_prim_aux comp_lowsec_aux (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year adjustment `tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'.dta", replace
}
*/

* Appending the results
cd "$data_mics\hl\collapse"
use "result0.dta", clear
gen t_0=1
foreach i of numlist 0/6 12/18 20/21 31 41 {
 	append using "result`i'"
}
gen survey="MICS"
include "$dir_synchro/programs/standardizes_collapse_dhs_mics.do"

save "$data_mics\hl\mics_collapse_by_categories_v10.dta", replace
export delimited "$data_mics\hl\mics_collapse_by_categories_v10.csv", replace



******************************************************************************
*****---- END OF MICS CALCULATIONS
******************************************************************************

	
end
