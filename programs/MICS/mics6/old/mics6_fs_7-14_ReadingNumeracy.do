use "C:\Users\Rosa_V\Dropbox\WIDE\Data\MICS\Madagascar\fs.dta", clear
*lookfor fl
keep if fl28==1
keep if cb3>=7 & cb3<=14 // age


**********************************************
**********************************************


codebook fl19*
*fl19w1-fl19w72 // 72 words
*fl20a: total # words attempted
*fl20b: total # words incorrect or missed
lookfor fl20a fl20b
codebook fl20a fl20b, tab(100)

* Attempted (fl20a) = correct + incorrect (fl20b) 
*--> Correct = fl20a-fl20b


*Compute=gen

*In other language
gen correct=0
replace correct=(fl20a-fl20b)

gen readcorrect=0
replace readcorrect=1 if correct>=0.9*84

gen aliteral=0
replace aliteral=1 if fl22a==1 & fl22b==1 & fl22c==1

gen ainferential=0
replace ainferential=1 if fl22d==1 & fl22e==1

gen readingskill=0
replace readingskill=1 if readcorrect==1 & aliteral==1 & ainferential==1

gen numchildren=1

sum readcorrect aliteral ainferential readingskill numchildren [iw=fsweight]

*In Francais
gen correctF=0
replace correctF=(fl220a-fl220b)

gen readcorrectF=0
replace readcorrectF=1 if correctF>=0.9*64

gen aliteralF=0
replace aliteralF=1 if fl222a==1 & fl222b==1 & fl222c==1

gen ainferentialF=0
replace ainferentialF=1 if fl222d==1 & fl222e==1

gen readingskillF=0
replace readingskillF=1 if readcorrectF==1 & aliteralF==1 & ainferentialF==1

sum readcorrectF aliteralF ainferentialF readingskillF [iw=fsweight]

tab correct correctF, m


tab fl100, m

br if correct==2 & correctF==1


***** MY METHOD

codebook fl19w1-fl19w84, tab(100)
foreach var of varlist fl19w1 - fl19w84 {
gen t_`var'=.
replace t_`var'=1 if `var'==0 // 0 = correct; 1=incorrect; 2=not attempted
replace t_`var'=0 if (`var'==1|`var'==2)
}

egen fl19_tot=rowtotal(t_fl19w1 - t_fl19w84)
egen fl19_miss=rowmiss(t_fl19w1 - t_fl19w84)

gen read90=0
replace read90=1 if fl19_tot>=0.9*84
replace read90=. if fl19_miss==84


tab read90

*3 literal questions: FL22 [A]=1 and FL22 [B]=1 and FL22 [C]=1
gen literal=0
replace literal=1 if fl22a==1 & fl22b==1 & fl22c==1
replace literal=. if fl22a==3 & fl22b==3 & fl22c==3

*2 inferential questions: FL22 [D]=1 and FL22 [E]=1
gen inferential=0
replace inferential=1 if fl22d==1 & fl22e==1
replace inferential=. if fl22d==3 & fl22e==3

gen reading=0
replace reading=1 if read90==1 & literal==1 & inferential==1
replace reading=. if read90==. & literal==. & inferential==.

for X in any read90 literal inferential reading: tab X, m
sum read90 literal inferential reading [iw=fsweight]


*What is ed9??
codebook cb7 fl9 fl7, tab(100)

**********************************************
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

*Ages for grades 2-3: schage==7|schage==8

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






*Grade 2-3: schage 7-8


****************

*My method
*Languages
codebook fs12 fs13 fs14
codebook fl7 fl9

lookfor fl19

codebook fl19w1-fl19w72, tab(100)
foreach var of varlist fl19w1 - fl19w72 {
gen t_`var'=.
replace t_`var'=1 if `var'==0 // 0 = correct; 1=incorrect; 2=not attempted
replace t_`var'=0 if (`var'==1|`var'==2)
}

egen fl19_tot=rowtotal(t_fl19w1 - t_fl19w72)
egen fl19_miss=rowmiss(t_fl19w1 - t_fl19w72)

gen read90=0
replace read90=1 if fl19_tot>=0.9*72
sum read90 [iw=fsweight] //50.49%
replace read90=. if fl19_miss==72 // this one is closer
sum read90 [iw=fsweight] // 77.12 % (1441 missings)

tab read90

*3 literal questions: FL22 [A]=1 and FL22 [B]=1 and FL22 [C]=1
gen literal=0
replace literal=1 if fl22a==1 & fl22b==1 & fl22c==1
replace literal=. if fl22a==3 & fl22b==3 & fl22c==3
replace literal=. if fl22a==. & fl22b==. & fl22c==.

*2 inferential questions: FL22 [D]=1 and FL22 [E]=1
gen inferential=0
replace inferential=1 if fl22e==1 & fl22f==1
replace inferential=. if fl22e==3 & fl22f==3
replace inferential=. if fl22e==. & fl22f==.

gen reading=0
replace reading=1 if read90==1 & literal==1 & inferential==1
replace reading=. if read90==. & literal==. & inferential==.

for X in any read90 literal inferential reading: tab X, m
sum read90 literal inferential reading [iw=fsweight]

*Grade 2-3: schage 7-8



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

*Total
sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight]

*Total by disability
bys fsdisability: sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight]

*by sex
bys hl4: sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight]

*by sex & disability
bys hl4 fsdisability: sum nrreading nrdiscrim addition pattern numeracy [iw=fsweight]




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
