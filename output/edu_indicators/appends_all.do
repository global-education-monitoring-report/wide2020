 global dir "P:\WIDE\output\edu_indicators"
 
 clear
 import excel using "$dir\LIS_indicators_v3.xlsx", firstrow
 rename *, lower
 drop a y an-az
  
 duplicates tag, gen(dup)
 tab dup // 150 duplicates. Australia 2014 is present 2 times...
  count //1017 obs
 drop dup
 duplicates drop
 drop if year==.
 count

 ren ctry iso_code2

 gen cy=country+"_"+string(year)
 tab cy
 
 *codebook location sex location wealth region ethnicity
 tab location if country=="Israel" // not rural, rural
 tab location if country=="Georgia" // not rural, rural
 
 *br if country=="Georgia"
 
 *Putting the survey name from https://www.lisdatacenter.org/frontend#/home
gen survey=""
replace survey="SIH" if cy=="Australia_2014" // Survey of Income and Housing (SIH) (Australia). For 2010 is "HES-SIH"
replace survey="SLID" if cy=="Canada_2010" // Survey of Labour and Income Dynamics (SLID) (Canada)
replace survey="CIS" if cy=="Canada_2013" // Canadian Income Survey (CIS) (Canada)
replace survey="IHS" if cy=="Georgia_2013" // Integrated Household Survey (IHS) (Georgia)
replace survey="IHS" if cy=="Georgia_2016" // Integrated Household Survey (IHS) (Georgia)
replace survey="HES" if cy=="Israel_2012" // Household Expenditure Survey (Israel)
replace survey="HES" if cy=="Israel_2014" // Household Expenditure Survey (Israel)
replace survey="HES" if cy=="Israel_2016" // Household Expenditure Survey (Israel)
replace survey="HIES-FHES" if cy=="South Korea_2012" // Household Income and Expenditure Survey (HIES) and Farm Household Income and Expenditure Survey (FHES) (South Korea)
replace survey="CPS-ASEC" if cy=="United States_2013" // Current Population Survey (CPS) - Annual Social and Economic Supplement (ASEC) (United States)
replace survey="CPS-ASEC" if cy=="United States_2016" // Current Population Survey (CPS) - Annual Social and Economic Supplement (ASEC) (United States)

foreach var of varlist edu0_prim - edu4_2024 {
destring `var', replace
}
 
tab edu0_prim 
drop edu0_prim*

foreach var of varlist eduout_prim eduout_lowsec eduout_upsec comp_prim_v2 comp_prim_1524 comp_lowsec_v2 comp_lowsec_1524 comp_upsec_v2 comp_upsec_2029 comp_higher_2529 edu2_2024 edu4_2024 {
replace `var'=`var'*100
}

foreach var of varlist eduout_prim eduout_lowsec eduout_upsec comp_prim_v2 comp_prim_1524 comp_lowsec_v2 comp_lowsec_1524 comp_upsec_v2 comp_upsec_2029 comp_higher_2529 edu2_2024 edu4_2024 eduyears_2024 {
replace `var'=. if `var'_no <30
}

  br if category=="Total" & comp_upsec_v2==.
  br if category=="Total" & comp_lowsec_v2==.
  br if category=="Total" & comp_prim_v2==.

 merge m:1 iso_code2 using "P:\WIDE\auxiliary_data\country_iso_codes_names.dta", keepusing(iso_code3)
 drop if _merge==2
 drop _merge
 drop iso_code2
 drop cy
 order iso_code3
 
 * I drop the information from Canada 2010 because there are problems. I'll take the info from the OLD WIDE
 drop if country=="Canada" & year==2010 & survey=="SLID"
 drop if country=="Israel" & year==2012 & survey=="HES" 
  compress
 
 save "$dir\collapse_LIS_03112020.dta", replace

******************************************************

 use "$dir\collapse_dhs_mics_02272020.dta", clear
  *Fixing things that should have been fixed before:
 *For DHS India_2005
  split region, parse(]) gen (reg)
 for X in any reg1 reg2: replace X=trim(X)
 replace region=reg2 if country_year=="India_2005"
 drop reg1 reg2
 
 append using "$dir\collapse_EU_SILC_03102020.dta"
 append using "$dir\collapse_LIS_03112020.dta"

 bys survey: sum comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 if category=="Total"

 * Bilal says: also impute 100% primary completion in the presence of 99+% lower secondary.
 replace comp_prim_v2=100 if comp_prim_v2==. & (comp_lowsec_v2>=99 & comp_lowsec_v2!=.)
 
 *Renaming to match the final WIDE
 
 rename location sex wealth region ethnicity religion, proper
 foreach var of varlist eduout_prim eduout_lowsec eduout_upsec comp_prim_v2 comp_prim_1524 comp_lowsec_v2 comp_lowsec_1524 comp_upsec_v2 comp_upsec_2029 comp_higher_2529 edu2_2024 edu4_2024 eduyears_2024 {
	rename `var' `var'_m
	}

 
 
compress
  save "$dir\collapse_dhs_mics_silc_lis_03112020.dta", replace


************************************************************
*I use the data from march last year

use "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\data_created\edu_indicators\WIDE_All_2019-03-22.dta", clear
 *Drop MICS & DHS
 drop if survey=="MICS"|survey=="DHS"
 *Drop EU-SILC
 drop if survey=="EU-SILC"
 *Drop LIS, except Australia 2010 (survey=="HES-SIH"), Canada 2010 (SLID), Israel 2012 (HES)
  drop if survey=="CIS"|survey=="IHS"|survey=="HIES-FHES"|survey=="CPS-ASEC"

  duplicates drop
  * tab survey year if country=="Australia"
  
foreach X in eduout_prim eduout_lowsec eduout_upsec comp_prim_v2 comp_prim_1524 comp_lowsec_v2 comp_lowsec_1524 comp_upsec_v2 comp_upsec_2029 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 edu2_2024 edu4_2024 {
	replace `X'_m=`X'_m*100
	replace `X'_m=. if `X'_no <30
}

append using "$dir\collapse_dhs_mics_silc_lis_03112020.dta"
 * Bilal says: also impute 100% primary completion in the presence of 99+% lower secondary.
 replace comp_prim_v2_m=100 if comp_prim_v2_m==. & (comp_lowsec_v2_m>=99 & comp_lowsec_v2_m!=.)

  *To keep only completion
 drop if level!=""
 
codebook category Sex Location Wealth Region Ethnicity Religion Language, tab(100)
 bys survey: sum comp_prim_v2_m comp_lowsec_v2_m comp_upsec_v2_m if category=="Total"

 br if country=="Australia" & category=="Total"
 compress
 save "$dir\appended_completion_dhs_mics_silc_lis_03112020.dta", replace
 
 
 **** PUTTING IN THE FORMAT OF THE STAT TABLES
 use "$dir\appended_completion_dhs_mics_silc_lis_03112020.dta", clear
keep survey iso_code country year category Location Sex Wealth comp_prim_v2_m comp_lowsec_v2_m comp_upsec_v2_m
keep if category=="Total"|category=="Location"|category=="Sex"|category=="Wealth"|category=="Sex & Wealth"
drop if category=="Sex & Wealth" & Wealth!="Quintile 1"

br if country=="Canada"

gen group=category
replace group="poorest by sex" if group=="Sex & Wealth"
drop category

gen category=""
for X in any Sex Wealth Location: replace category=X if group=="X"
replace category="Total" if group=="Total"
replace category="poorest female" if Sex=="Female" & Wealth=="Quintile 1" & group=="poorest by sex"
replace category="poorest male" if Sex=="Male" & Wealth=="Quintile 1" & group=="poorest by sex"
drop Sex Location Wealth

for X in any group category: replace X=lower(X)

codebook group category, tab(100)
br if category==""
br if country=="Canada" & year==2013

*Drop those that have no info for any indicator
drop if comp_prim_v2_m==. & comp_lowsec_v2_m==. & comp_upsec_v2_m==.
codebook group category, tab(100)

order survey iso country year group category comp_prim_v2 comp_lowsec_v2 comp_upsec_v2

br if category=="not rural"
sort iso country year group category
compress
export delimited "$dir\WIDE_Completion_03112020.csv", replace



use "P:\WIDE\auxiliary_data\UIS\completion\UIS_comp_eduout_02262020_with_metadata.dta", clear 
rename location sex wealth, proper
keep source* note* metadata* iso_code3 country year category Location Sex Wealth comp_prim comp_lowsec comp_upsec
keep if category=="Total"|category=="Location"|category=="Sex"|category=="Wealth"|category=="Sex & Wealth"
drop if category=="Sex & Wealth" & Wealth!="Quintile 1"

gen group=category
replace group="poorest by sex" if group=="Sex & Wealth"
drop category

gen category=""
for X in any Sex Wealth Location: replace category=X if group=="X"
replace category="Total" if group=="Total"
replace category="poorest female" if Sex=="Female" & Wealth=="Quintile 1" & group=="poorest by sex"
replace category="poorest male" if Sex=="Male" & Wealth=="Quintile 1" & group=="poorest by sex"
codebook category group
drop Sex Location Wealth

for X in any group category: replace X=lower(X)

codebook group category, tab(100)
br if category==""
br if country=="Canada" & year==2013

*Drop those that have no info for any indicator
drop if comp_prim==. & comp_lowsec==. & comp_upsec==.
codebook group category, tab(100)
drop *eduout*
for X in any prim lowsec upsec: rename source_uis_comp_X survey_uis_comp_X
order iso country year group category comp_prim comp_lowsec comp_upsec *_comp_prim *_comp_lowsec *_comp_upsec
order iso country year group category comp_prim comp_lowsec comp_upsec survey*

gen survey=survey_uis_comp_prim
replace survey=survey_uis_comp_lowsec if survey==""
replace survey=survey_uis_comp_upsec if survey==""

gen metadata=metadata_comp_prim
replace metadata=metadata_comp_lowsec if metadata==""
replace metadata=metadata_comp_upsec if metadata==""

gen note_source=note_source_comp_prim
replace note_source=note_source_comp_lowsec if note_source==""
replace note_source=note_source_comp_upsec if note_source==""

drop survey_uis_comp_prim-note_source_comp_upsec
ren survey survey_uis
order survey_uis

compress
export delimited "$dir\UIS_Completion_02202020.csv", replace


