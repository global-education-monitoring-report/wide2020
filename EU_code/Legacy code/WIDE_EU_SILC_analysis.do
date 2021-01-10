****************************************
* WIDE_EU_SILC_analysis.do 
****************************************

* Tempfiles to store results
tempfile master
forvalues i=0(1)17 {
          tempfile result`i'
		  }

		  
* Global varlist for variables stats
#delimit ;
global varlist "
comp_lowsec comp_lowsec_v2 comp_lowsec_1524 
comp_upsec comp_upsec_v2 comp_upsec_2029 
att_higher_5 att_higher_1824 
enrol_higher_1822 enrol_higher_2022
comp_higher_2529 comp_higher_3034
age_start_primary preschool_0304 preschool_4 preschool_5 preschool_6 preschool_1ybefore
comp_lowersec_rev_1524 comp_higher_rev_2529 enrol_higher_rev 
comp_higher_2529_2yrs comp_higher_2529_4yrs comp_higher_3034_2yrs comp_higher_3034_4yrs
" ;
#delimit cr

qui foreach var in $varlist {
 g `var'_m = `var'
 g `var'_no = `var'
}

#delimit ;
global varlist_m "
comp_lowsec_m comp_lowsec_v2_m comp_lowsec_1524_m 
comp_upsec_m comp_upsec_v2_m comp_upsec_2029_m 
att_higher_5_m att_higher_1824_m 
enrol_higher_1822_m enrol_higher_2022_m
comp_higher_2529_m comp_higher_3034_m
age_start_primary_m preschool_0304_m preschool_4_m preschool_5_m preschool_6_m preschool_1ybefore_m
comp_lowersec_rev_1524_m comp_higher_rev_2529_m enrol_higher_rev_m
comp_higher_2529_2yrs_m comp_higher_2529_4yrs_m comp_higher_3034_2yrs_m comp_higher_3034_4yrs_m
" ;
#delimit cr

#delimit ;
global varlist_no "
comp_lowsec_no comp_lowsec_v2_no comp_lowsec_1524_no 
comp_upsec_no comp_upsec_v2_no comp_upsec_2029_no 
att_higher_5_no att_higher_1824_no 
enrol_higher_1822_no enrol_higher_2022_no
comp_higher_2529_no comp_higher_3034_no
age_start_primary_no preschool_0304_no preschool_4_no preschool_5_no preschool_6_no preschool_1ybefore_no
comp_lowersec_rev_1524_no comp_higher_rev_2529_no enrol_higher_rev_no
comp_higher_2529_2yrs_no comp_higher_2529_4yrs_no comp_higher_3034_2yrs_no comp_higher_3034_4yrs_no
" ;
#delimit cr


save "`master'"


*==================
* ONE category		  
		  
*** Total 
use "`master'", clear
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year)
gen subcategory1="Total"
gen category = "Country Total All"
sort category
save "`result0'"

*** Total Urban/Rural
use "`master'", clear
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year urban)
drop if urban=="."
gen subcategory1=urban 
drop urban
gen category = "Country Total Urban/Rural"
sort category
save "`result1'"

*** By Sex
use "`master'", clear
drop if sex==.
sort sex
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year sex)
decode sex, generate(subcategory1) 
drop sex
gen category = "Country Total Sex"
sort category
save "`result2'"

*** By wealth
use "`master'", clear
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year wealth)
drop if wealth==.
decode wealth, generate(subcategory1) 
drop wealth
gen category = "Country Wealth Index Quintiles"
sort category
save "`result3'"

*** By Inmigrant
use "`master'", clear
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year migrant)
drop if migrant==.
decode migrant, generate(subcategory1) 
drop migrant
gen category = "Country Total Migrant"
sort category
save "`result4'"

*** By Region
use "`master'", clear
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year region)
drop if region=="."
gen subcategory1=region 
drop region
gen category = "Country Total Region"
sort category
save "`result5'"


*==================
* TWO categories	

*** By Wealth and Urban
use "`master'", clear
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year urban wealth) 
drop if urban=="."
gen subcategory1=urban 
drop urban
drop if wealth==.
decode wealth, generate(subcategory2) 
drop wealth
gen category = "Urban/Rural and Country Wealth Index Quintiles"
sort category
save "`result6'"

*** By Sex and Wealth 
use "`master'", clear
drop if sex==.
sort sex
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year sex wealth) 
decode sex, generate(subcategory1) 
drop sex
drop if wealth==.
decode wealth, generate(subcategory2) 
drop wealth
gen category = "Sex and Country Wealth Index Quintiles"
sort category
save "`result7'"

*** By Migrant and Wealth 
use "`master'", clear
drop if migrant==.
sort migrant
collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country survey year migrant wealth) 
decode migrant, generate(subcategory1) 
drop migrant
drop if wealth==.
decode wealth, generate(subcategory2) 
drop wealth
gen category = "Migrant and Country Wealth Index Quintiles"
sort category
save "`result8'"



* Append results datasets
use "`result0'", clear
forvalues i=1(1)8 {
 	append using "`result`i''"
}

		 
* Order variables		  
#delimit;
order country survey year category subcategory1 subcategory2
comp_lowsec* 
comp_upsec*  
att_higher* 
enrol_higher*
comp_higher*
age_start_primary* preschool*
comp_lowersec* 
;
#delimit cr


* Replace missings 
#delimit ;
local varlist2 "
comp_lowsec comp_lowsec_v2 comp_lowsec_1524 
comp_upsec comp_upsec_v2 comp_upsec_2029 
att_higher_5 att_higher_1824 
enrol_higher_1822 enrol_higher_2022
comp_higher_2529 comp_higher_3034
age_start_primary preschool_0304 preschool_4 preschool_5 preschool_6 preschool_1ybefore
comp_lowersec_rev_1524 comp_higher_rev_2529 enrol_higher_rev
comp_higher_2529_2yrs comp_higher_2529_4yrs comp_higher_3034_2yrs comp_higher_3034_4yrs

" ;
#delimit cr
foreach x of local varlist2 {
 replace `x'_m = . if `x'_no<30
}
foreach x of local varlist2 {
 replace `x'_no =0 if `x'_no==.
}



sort country survey year category subcategory1 subcategory2


