*****From text to database

*REMEMBER TO UPDATE:
*LINE 6 the filepath and filename
*LINE 29 the categories used in that particular country/survey file

import delimited "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\LIS\Canada\listing_job_810208.txt", varnames(nonames) clear
gen keep=substr(v1, 1, 1)
keep if keep=="@"
gen tosplit=substr(v1, 2, 1000000)
split tosplit, p("-")


*rename each split
rename tosplit1 country
rename tosplit2 survey
rename tosplit3 year
rename tosplit4 indicatorname
rename tosplit5 category
rename tosplit6 catname1
rename tosplit7 catname2
rename tosplit8 catname3
rename tosplit9 indicator
rename tosplit10 indicator_no

*Order category names
split category, p("")

global categories_collapse sex wealth region location


foreach var in $categories_collapse {
gen `var'= ""

gen `var'_present1 =  strpos(category1, "`var'") > 0
gen `var'_present2 =  strpos(category2, "`var'") > 0
gen `var'_present3 =  strpos(category3, "`var'") > 0


replace `var' = catname1 if `var'_present1==1 
replace `var' = catname2 if `var'_present2==1 
replace `var' = catname3 if `var'_present3==1  

}


drop catname*
drop *_present*
drop category1 category2 category3
drop v1  tosplit keep

*check 
duplicates report country survey year sex wealth region location category
*if duplicates, check before reshaping

reshape wide indicator indicator_no, i(country year survey category sex wealth region location) j(indicatorname) string
 
 *fix stubs
foreach var of varlist indicator_nocomp_higher_2529 indicator_nocomp_lowsec indicator_nocomp_lowsec_1524 indicator_nocomp_prim indicator_nocomp_prim_1524 indicator_nocomp_upsec indicator_nocomp_upsec_2029 indicator_noedu0_prim indicator_noedu_out_lowsec indicator_noedu_out_pry indicator_noedu_out_upsec indicator_noeduyears_2024 {
   	local newname = substr("`var'", 13, .)
   	rename `var' `newname'_no
}

foreach var of varlist indicatorcomp_higher_2529 indicatorcomp_lowsec indicatorcomp_lowsec_1524 indicatorcomp_prim indicatorcomp_prim_1524 indicatorcomp_upsec indicatorcomp_upsec_2029 indicatoredu0_prim indicatoredu_out_lowsec indicatoredu_out_pry indicatoredu_out_upsec indicatoreduyears_2024 {
   	local newname = substr("`var'", 10, .)
   	rename `var' `newname'
}

*replace here in the order it was on the country code
global categories_collapse sex wealth region location
	tuples $categories_collapse, display
	
* DROP Categories that are not used:
drop if category=="region location"|category==" sex region location"|category=="wealth region location"|category=="location sex wealth region"

*Proper for all categories
	foreach i of numlist 0/`ntuples' {
	replace category=proper(category) if category=="`tuple`i''"
	}

*strings to numbers
destring comp_higher_2529 comp_higher_2529_no comp_lowsec comp_lowsec_no comp_lowsec_1524 comp_lowsec_1524_no comp_prim comp_prim_no comp_prim_1524 comp_prim_1524_no comp_upsec comp_upsec_no comp_upsec_2029 comp_upsec_2029_no edu0_prim edu0_prim_no edu_out_lowsec edu_out_lowsec_no edu_out_pry edu_out_pry_no edu_out_upsec edu_out_upsec_no eduyears_2024 eduyears_2024_no, replace	
	
*order 
order comp_higher_2529_no comp_lowsec_no comp_lowsec_1524_no comp_prim_no comp_prim_1524_no comp_upsec_no comp_upsec_2029_no edu0_prim_no edu_out_lowsec_no edu_out_pry_no edu_out_upsec_no eduyears_2024_no, last 
	
*ta-da!
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\LIS\Canada"
save indicators_LIS_Canada.dta, replace
 

 