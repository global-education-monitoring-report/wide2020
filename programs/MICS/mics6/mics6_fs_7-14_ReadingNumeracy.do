use "C:\Users\Rosa_V\Dropbox\WIDE\Data\MICS\Madagascar\fs.dta", clear
*lookfor fl
keep if fl28==1
keep if cb3>=7 & cb3<=14 // age


**********************************************
**********************************************

codebook fl20a fl20b, tab(100) //            84 words                   ... fl22a-fl22e 
codebook fl120a fl120b, tab(100) // malagasy 84 words (fl119w1-fl119w84)... f1122a-fl122e
codebook fl220a fl220b, tab(100) // francais 64 words (fl219w1-fl219w64)... f1222a-fl222e


* Attempted (fl20a) = correct + incorrect (fl20b) 
*--> Correct = fl20a-fl20b


*Grade 2-3: schage 7-8

gen correct_20=0
replace correct_20=fl20a-fl20b if fl20a<=99 & fl20b<=99 // produces no missings
*tab correct_20, m

gen correct_21=0
replace correct_21=fl120a-fl20b if fl120a<=99 & fl120b<=99 // produces no missings
*tab correct_21, m

gen correct_22=0
replace correct_22=fl220a-fl220b if fl220a<=99 & fl220b<=99 // produces no missings
*tab correct_22, m

gen readcorrect_20=0
replace readcorrect_20=1 if correct_20>=0.9*84
sum readcorrect_20 [iw=fsweight] // 36.6 %

gen readcorrect_21=0
replace readcorrect_21=1 if correct_21>=0.9*84
sum readcorrect_21 [iw=fsweight] // 5.15 %

gen readcorrect_22=0
replace readcorrect_22=1 if correct_22>=0.9*64
sum readcorrect_22 [iw=fsweight] // 13.2 %


gen aliteral_20=0
replace aliteral_20=1 if fl22a==1 & fl22b==1 & fl22c==1

gen aliteral_21=0
replace aliteral_21=1 if fl122a==1 & fl122b==1 & fl122c==1

gen aliteral_22=0
replace aliteral_22=1 if fl222a==1 & fl222b==1 & fl222c==1


gen ainferential_20=0
replace ainferential_20=1 if fl22d==1 & fl22e==1

gen ainferential_21=0
replace ainferential_21=1 if fl122d==1 & fl122e==1

gen ainferential_22=0
replace ainferential_22=1 if fl222d==1 & fl222e==1


foreach var in readcorrect aliteral ainferential {
gen `var'=`var'_20
replace `var'=1 if (`var'_21==1|`var'_22==1)
}


gen readingskill=0
replace readingskill=1 if readcorrect==1 & aliteral==1 & ainferential==1

sum readcorrect aliteral ainferential readingskill [iw=fsweight] // ok

**********************************************

*Numeracy

foreach var of varlist fl23a - fl23f fl24a - fl24e fl25a - fl25e fl27a - fl27e {
	replace `var'=. if `var'==7 
	gen t_`var'=1 if `var'==1 
	replace t_`var'=0 if (`var'==2|`var'==3)
}


egen t_nrreading=rowtotal(t_fl23a-t_fl23f) // 6 items
egen t_nrdiscrim=rowtotal(t_fl24a-t_fl24e) // 5 items
egen t_addition=rowtotal(t_fl25a-t_fl25e) // 5 items
egen t_pattern=rowtotal(t_fl27a-t_fl27e) // 5 items

for X in any nrreading nrdiscrim addition pattern: gen X=0
for X in any nrreading: replace X=1 if t_X>=6
for X in any nrdiscrim addition pattern: replace X=1 if t_X>=5


gen numeracy=0
replace numeracy=1 if nrreading==1 & nrdiscrim==1 & addition==1 & pattern==1



gen nr_child_reading=readingskill
gen nr_child_numeracy=numeracy

save "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\ReadingNumeracy\Madagascar.dta", replace


********************* START THE COLLAPSING


cd "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\ReadingNumeracy\"
use "Madagascar.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight]
gen category="Total"
save "Madagascar_total.dta", replace

use "Madagascar.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight], by(fsdisability)
drop if fsdisability==.|fsdisability==9
gen category="Disability"
save "Madagascar_disability.dta", replace

use "Madagascar.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight], by(hl4)
drop if hl4==.
gen category="Sex"
save "Madagascar_sex.dta", replace

use "Madagascar.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight], by(fsdisability hl4)
drop if fsdisability==.|hl4==.
drop if fsdisability==9
gen category="Disability & Sex"
save "Madagascar_disability&sex.dta", replace

use "Madagascar_total.dta"
append using "Madagascar_disability.dta"
append using "Madagascar_sex.dta"
append using "Madagascar_disability&sex.dta"
for X in any readcorrect aliteral ainferential readingskill nrreading nrdiscrim addition pattern numeracy: replace X=X*100
order category fs hl


sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight]
*by sex
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if hl4==1
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if hl4==2

*By disability
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if fsdisability==1 // has disabilities
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if fsdisability==2 // doesn't have disabilities

*By sex & disability
*Male
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if hl4==1 & fsdisability==1 // has disabilities
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if hl4==1 & fsdisability==2 // doesn't have disabilities
*Female
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if hl4==2 & fsdisability==1 // has disabilities
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight] if hl4==2 & fsdisability==2 // doesn't have disabilities


codebook fsdisability 


fsweight 


gen nr_discrimination


*codebook fl23a fl23b fl23c fl23d fl23e fl23f
*codebook fl24a fl24b fl24c fl24d fl24e
*codebook fl25a fl25b fl25c fl25d fl25e
codebook fl27a fl27b fl27c fl27d fl27e


tab read90
br

fl22a

for X in any : gen t_X=1 if X==1



codebook fl28

save "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\ReadingNumeracy\Madagascar.dta", replace


*----------------------------------------------------------
********************* ZIMBABWE
*----------------------------------------------------------


use "C:\Users\Rosa_V\Dropbox\WIDE\Data\MICS\Zimbabwe\fs.dta", clear
keep if fl28==1 //responded
keep if cb3>=7 & cb3<=14 // age

*---------------
***** READING
*---------------

*codebook fl19*
*fl19w1-fl19w72 // 72 words
*fl20a: total # words attempted
*fl20b: total # words incorrect or missed
*codebook fl20a fl20b, tab(100)
*Compute=gen


*Grade 2-3: schage 7-8

gen correct_19=0
replace correct_19=fl20a-fl20b if fl20a<=99 & fl20b<=99 // produces no missings
tab correct_19, m

gen correct_21=0
replace correct_21=fl21pa-fl21pb if fl21pa<=99 & fl21pb<=99 // produces no missings
tab correct_21, m

/*
gen correct2=0
replace correct2=fl20a-fl20b // produces 1441 missings
tab correct2, m

gen missing_correct=0
replace missing_correct=1 if fl20a==. & fl20b==. // 1441 cases

*what about the missings?
*/

gen readcorrect_19=0
replace readcorrect_19=1 if correct_19>=0.9*72
sum readcorrect_19 [iw=fsweight] // 50.49 %

gen readcorrect_21=0
replace readcorrect_21=1 if correct_21>=0.9*62
sum readcorrect_21 [iw=fsweight] // 21.52 %

gen aliteral_19=0
replace aliteral_19=1 if fl21ba==1 & fl21bb==1 & fl21bc==1
sum aliteral_19 [iw=fsweight] // 35.4%

gen aliteral_21=0
replace aliteral_21=1 if fl22a==1 & fl22b==1 & fl22c==1
sum aliteral_21 [iw=fsweight] // 18.48%

gen ainferential_19=0
replace ainferential_19=1 if fl21be==1 & fl21bf==1
sum ainferential_19 [iw=fsweight] // 31.81%

gen ainferential_21=0
replace ainferential_21=1 if fl22e==1 & fl22f==1
sum ainferential_21 [iw=fsweight] //12.58%

foreach var in readcorrect aliteral ainferential {
gen `var'=`var'_19
replace `var'=1 if `var'_21==1
}

gen readingskill=0
replace readingskill=1 if readcorrect==1 & aliteral==1 & ainferential==1
sum readingskill [iw=fsweight]

sum readcorrect aliteral ainferential readingskill [iw=fsweight] // ok

****************

*Numeracy

foreach var of varlist fl23a - fl23f fl24a - fl24e fl25a - fl25e fl27a - fl27e {
	replace `var'=. if `var'==7 
	gen t_`var'=1 if `var'==1 
	replace t_`var'=0 if (`var'==2|`var'==3)
}


egen t_nrreading=rowtotal(t_fl23a-t_fl23f) // 6 items
egen t_nrdiscrim=rowtotal(t_fl24a-t_fl24e) // 5 items
egen t_addition=rowtotal(t_fl25a-t_fl25e) // 5 items
egen t_pattern=rowtotal(t_fl27a-t_fl27e) // 5 items

for X in any nrreading nrdiscrim addition pattern: gen X=0
for X in any nrreading: replace X=1 if t_X>=6
for X in any nrdiscrim addition pattern: replace X=1 if t_X>=5

gen numeracy=0
replace numeracy=1 if nrreading==1 & nrdiscrim==1 & addition==1 & pattern==1

gen nr_child_reading=readingskill
gen nr_child_numeracy=numeracy

save "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\ReadingNumeracy\Zimbabwe.dta", replace

cd "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\ReadingNumeracy\"
use "Zimbabwe.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight]
gen category="Total"
save "Zimbabwe_total.dta", replace

use "Zimbabwe.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight], by(fsdisability)
drop if fsdisability==.|fsdisability==9
gen category="Disability"
save "Zimbabwe_disability.dta", replace

use "Zimbabwe.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight], by(hl4)
drop if hl4==.
gen category="Sex"
save "Zimbabwe_sex.dta", replace

use "Zimbabwe.dta", clear
collapse (mean) readcorrect aliteral ainferential readingskill (count) nr_child_reading (mean) nrreading nrdiscrim addition pattern numeracy (count) nr_child_numeracy [iw=fsweight], by(fsdisability hl4)
drop if fsdisability==.|hl4==.
drop if fsdisability==9
gen category="Disability & Sex"
save "Zimbabwe_disability&sex.dta", replace

use "Zimbabwe_total.dta"
append using "Zimbabwe_disability.dta"
append using "Zimbabwe_sex.dta"
append using "Zimbabwe_disability&sex.dta"
for X in any readcorrect aliteral ainferential readingskill nrreading nrdiscrim addition pattern numeracy: replace X=X*100
order category fs hl
br


use "Zimbabwe.dta", clear
*Total
sum readingskill numeracy [iw=fsweight]

*Total by disability
bys fsdisability: sum readingskill numeracy [iw=fsweight]

*by sex
bys hl4: sum readingskill numeracy [iw=fsweight]

*by sex & disability
bys hl4 fsdisability: sum readingskill numeracy [iw=fsweight]




save "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs\ReadingNumeracy\Zimbabwe.dta", replace

global list1 seeing hearing walking selfcare communication remembering concentrating acceptingchange controlbehavior makingfriends anxiety depression



 
foreach country in Iraq KyrgyzRepublic SierraLeone Suriname TheGambia Tunisia {
 use "C:\Users\Rosa_V\Desktop\WIDE\Data\MICS\\`country'\fs.dta", clear
 include "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\standardizes_fs"
 gen country="`country'"
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\fs\\`country'.dta", replace
}

 
*LaoPDR
 
cd "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\fs" 
 use Iraq.dta, clear
 append using KyrgyzRepublic.dta
 *append using LaoPDR.dta
 append using SierraLeone.dta
 append using Suriname.dta
 append using TheGambia.dta
 append using Tunisia.dta
 
 bys country: tab dis2 fsdisability, m
 egen year=median(fs7y)
 recode fsdisability (2=0)


 lookfor weight
 tab hh52
 
 gen w2=fshweight*hh52
 br fshweight hh52 w2 fsweight if w2!=fsweight
 
gen c=1 if country=="Iraq"
replace c=2 if country=="KyrgyzRepublic" 
replace c=3 if country=="LaoPDR" 
replace c=4 if country=="SierraLeone" 
replace c=5 if country=="Suriname" 
replace c=6 if country=="TheGambia" 
replace c=7 if country=="Tunisia"

gen id2=string(c)+" "+id
drop id
ren id2 id
merge 1:1 id using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\hl\hl_append_mics_6.dta", keepusing(hl6)
drop if _merge==2
ren hl6 age
collapse (mean) fsdisability [iw=fsweight], by(country year age)
collapse (mean) fsdisability [iw=fshweight], by(country year age)  
 
 *append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch_module.dta"
