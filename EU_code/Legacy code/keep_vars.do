**************************
* keep_vars.do 
**************************


* Age for each level
gen primaryage0=`primaryage0'
gen primaryage1=`primaryage1'
gen lowersecondary0 = `lowersecondaryage0'
gen lowersecondary1 = `lowersecondaryage1'
gen uppersecondary0 = `uppersecondaryage0'
gen uppersecondary1 = `uppersecondaryage1'

* Age group of primary
gen agegroup_pry=0
replace agegroup_pry=1 if (age>=`primaryage0' & age<=`primaryage1')
replace agegroup_pry=. if age==.

* Age group of lower and upper secondary
gen agegroup_lower_sec=0
replace agegroup_lower_sec=1 if (age>=`lowersecondaryage0' & age<=`lowersecondaryage1')
replace agegroup_lower_sec=. if age==.
gen agegroup_upper_sec=0
replace agegroup_upper_sec=1 if (age>=`uppersecondaryage0' & age<=`uppersecondaryage1')
replace agegroup_upper_sec=. if age==.

gen age_start_primary=`primaryage0'
gen age_1ybefore=age_start_primary-1


*===========
** NEW - for Higher Education


* Age group for indicator of attendance (5yrs after upsec)
local attend0 = `uppersecondaryage1'+1
local attend1 = `attend0'+4
gen age_attend_5 = 1 if (age>= `attend0' & age<=`attend1')

* Age group for completion 
gen age0_comp_higher_3 = `attend1'
gen age1_comp_higher_3 = `attend1'+3
gen age_comp_higher_3 = 1 if (age>=age0_comp_higher_3 & age<=age1_comp_higher_3)

* Grades for higher [assumed length is `higherdur' 2 and 4]
local higherfirst = `uppersecondarylast'+1
local higherlast2 = `higherfirst'+1
local higherlast4 = `higherfirst'+3


* For attendance to higher ed // added
gen agegroup_1822=1 if age>=18 & age<=22
gen agegroup_2022=1 if age>=20 & age<=22 

* For higher comp
gen agegroup_2529=1 if age>=25 & age<=29
gen agegroup_3034=1 if age>=30 & age<=34 // added

* For by age analysis
gen agegroup_1824=1 if age>=18 & age<=24

*===========



** Age groups

** NEW

* For lower secondary completion
gen age0_comp_lowsec_5 = lowersecondary1+3
gen age1_comp_lowsec_5 = lowersecondary1+3+4
gen age_comp_lowsec_5 = 1 if (age>=age0_comp_lowsec_5 & age<=age1_comp_lowsec_5)

gen age0_comp_lowsec_3 = lowersecondary1+3
gen age1_comp_lowsec_3 = lowersecondary1+3+2
gen age_comp_lowsec_3 = 1 if (age>=age0_comp_lowsec_3 & age<=age1_comp_lowsec_3)

* For upper secondary completion
gen age0_comp_upsec_5 = uppersecondary1+3
gen age1_comp_upsec_5 = uppersecondary1+3+4
gen age_comp_upsec_5 = 1 if (age>=age0_comp_upsec_5 & age<=age1_comp_upsec_5)

gen age0_comp_upsec_3 = uppersecondary1+3
gen age1_comp_upsec_3 = uppersecondary1+3+2
gen age_comp_upsec_3 = 1 if (age>=age0_comp_upsec_3 & age<=age1_comp_upsec_3)


* 20-24 and 15-24 age groups
gen agegroup_2024 = 1 if (age>=20 & age<=24)
gen agegroup_1524 = 1 if (age>=15 & age<=24)

* 20-29 (for upsec)
gen agegroup_2029 = 1 if (age>=20 & age<=29)

* 3-4 (pre-school) // Changed
*gen age_preschool=rx010 // the age in rx010 is already calculated!!
* better for constructing indicators given that exact day of birth is not given
gen agegroup_preschool_0304 = 1 if (age_preschool>=3 & age_preschool<=4)
gen agegroup_preschool_4 = 1 if (age_preschool==4)
gen agegroup_preschool_5 = 1 if (age_preschool==5)
gen agegroup_preschool_6 = 1 if (age_preschool==6)


*===
* For completion rates

* With edulevel info
g comp_lowsec_temp = 1 if (inlist(highlevl,2,3,4,5)) 
replace comp_lowsec_temp = 0 if (inlist(highlevl,0,1)) 

g comp_upsec_temp = 1 if (inlist(highlevl,3,4,5)) 
replace comp_upsec_temp = 0 if (inlist(highlevl,0,1,2)) 

********
//-> NEW for higher edu

* For completion 
g comp_higher_temp = 1 if (inlist(highlevl,5)) 
replace comp_higher_temp = 0 if (inlist(highlevl,0,1,2,3,4))

g att_higher_temp = 1 if (inlist(edlevel,5))

replace att_higher_temp = 0 if (inlist(edlevel,0,1,2,3,4))


*Added (new)
gen comp_lowersec_rev=0
replace comp_lowersec_rev=1 if (highlevl>=2 & highlevl<=6)
replace comp_lowersec_rev=. if highlevl==.

gen comp_higher_rev=0
replace comp_higher_rev=1 if (highlevl==5|highlevl==6)
replace comp_higher_rev=. if highlevl==.

gen comp_higher_rev_2y=0
replace comp_higher_rev_2y=1 if (highlevl==5)
replace comp_higher_rev_2y=. if highlevl==.

gen comp_higher_rev_4y=0
replace comp_higher_rev_4y=1 if (highlevl==6)
replace comp_higher_rev_4y=. if highlevl==.

gen enrol_higher_rev=0
replace enrol_higher_rev=1 if (edlevel==5|edlevel==6)
replace enrol_higher_rev=. if edlevel==.



********



*==
* Wealth

* Gen windex
gen windex=hx090

* Gen std windex
egen windex_std = std(windex)

* QB/QT 
qui sum windex, d
g wealth_bt = 1 if windex<=r(p50)
replace wealth_bt = 2 if windex>r(p50) & windex<.
label define wealth_bt 1 "Bottom half" 2 "Top half"
label val wealth_bt wealth_bt 
 
* Q1Q2 vs Q3Q4
g wealth_q1245 = 1 if (wealth==1|wealth==2)
replace wealth_q1245 = 2 if (wealth==4|wealth==5)
label define wealth_q1245 1 "Quantiles 1 and 2" 2 "Quantiles 4 and 5"
label values wealth_q1245 wealth_q1245 
*==


*===========
* Keep vars

#delimit ;
keep 
hhweight individual_id household_id
country year survey
ag* comp* enrol*
sex urban wealt* winde*
regio* migrant 
highlevl
att_higher_temp
upp* presch*
;
#delimit cr

 

sort individual_id 
