set more off
drop if t_0==1
drop t_0

replace category="total" if category==""
tab category

*-- Fixing for missing values in categories
foreach X in $categories_collapse {
drop if `X'=="" & category=="`X'"
}

for X in any sex wealth religion ethnicity region: cap drop if category=="location X" & (location==""|X=="")
for X in any wealth religion ethnicity region: cap drop if category=="sex X" & (sex==""|X=="")
for X in any region: cap drop if category=="wealth X" & (wealth==""|X=="")

drop if category=="location sex wealth" & (location==""|sex==""|wealth=="")
drop if category=="sex wealth region" & (sex==""|wealth==""|region=="")

* Categories that are not used:
drop if category=="location sex wealth region"|category=="location region"|category=="location sex region"|category=="location wealth region"

replace category=proper(category)
split category, gen(c)
gen category_original=category
replace category=c1+" & "+c2 if c1!="" & c2!="" & c3==""
replace category=c1+" & "+c2+" & "+c3 if c1!="" & c2!="" & c3!=""
drop c1 c2 c3

tab category category_orig
drop category_orig
compress

order country survey year category* $categories_collapse $varlist_m $varlist_no

foreach var of varlist $vars_comp $vars_eduout {
		replace `var'=`var'*100
}

*Eliminate those with less than 30 obs
foreach var of varlist $varlist_m  {
		replace `var'=. if `var'_no<30
}

*Merge with year_uis
merge m:1 iso_code3 survey year using "$aux_data/GEM/country_survey_year_uis.dta", keepusing(year_uis)
drop if _merge==2
drop _merge
compress
 *drop edu2* edu4*

merge m:1 iso_code3 using "$aux_data\country_iso_codes_names.dta", keepusing(country)
drop if _m==2
drop _merge
 
sort iso_code category $categories_collapse
order iso_code country year country_year survey category location sex wealth region ethnicity religion
