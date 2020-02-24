*For my laptop
global data_Pdrive "C:\Users\Rosa_V\Dropbox\WIDE_DHS_MICS\data\mics"
global gral_dir "C:\Users\Rosa_V\Dropbox"

global data_raw_mics "$gral_dir\WIDE\Data\MICS"
global programs_mics "$gral_dir\WIDE_DHS_MICS\programs\mics"
global programs_mics_aux "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE_DHS_MICS\data\mics"


*New version in Desktop-Work
global data_Pdrive "P:\WIDE_DHS_MICS\data\mics"
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global data_raw_mics "$gral_dir\Data\MICS"
global programs_mics "$gral_dir\WIDE\WIDE_DHS_MICS\programs\mics"
global programs_mics_aux "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"

*****************************************************************************************************
*	APPENDING ALL THE DATABASES (in 2 mics)
*----------------------------------------------------------------------------------------------------
*****************
set more off
include "$programs_mics_aux\survey_list_CH_mics4"
foreach file in $survey_list_CH_mics4 {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_file = `3'
cap rename *, lower
gen mics="mics4"

cap drop individual_id
cap clonevar hh1=hi1
cap clonevar hh2=hi2
cap clonevar ln=hl1

*Line variable for Mexico
if country=="Mexico" & year_file==2015 {
   ren uf4 ln
}

*For age:
     cap rename ag2y age_child // South Sudan 2010
     cap rename ag2 age_child

*Mauritania doesn't have "ec5"
if country=="Mauritania" & year_file==2011 {
   ren ec5a ec5
}

foreach M in a b c d e f {
	 cap ren ec7_1`M' ec7`M'a
	 cap ren ec7_2`M' ec7`M'b
	 cap ren ec7_3`M' ec7`M'x
	 cap ren ec7_4`M' ec7`M'y
 }

 for M in any aa ab ax ay ba bb bx by ca cb cx cy da db dx dy ea eb ex ey fa fb fx fy: cap tostring ec7M, replace
 
 foreach M in a b c d e f {
 foreach N in a b c x y {
	 cap ren ec7_`M'`N' ec7`M'`N'
 }
}

cap gen ec5=.
gen code_ec5=ec5

gen space=" "
gen individual_id = country+space+string(year_file)+space+string(hh1)+space+string(hh2)+space+string(ln)    

for X in any ec5 hl4: cap decode X, gen(temp_X)
for X in any ec5 hl4: cap tostring X, gen(temp_X) 
drop ec5 hl4
for X in any ec5 hl4: cap ren temp_X X
for X in any d m y: cap ren ag1_X ag1X
for X in any cage ag1y: cap gen X=.

for X in any ec1 ec7 chweight hh6 windex: cap gen X=.
keep individual_id country year ec5 hl4 age_child cage* ag1* code_ec5 ec1* ec7* chweight hh6 windex*
label drop _all
cap label drop _all

save "$data_mics\ch\countries\\`1'`3'", replace
}


*****************
set more off
include "$programs_mics_aux\survey_list_CH_mics5"
foreach file in $survey_list_CH_mics5 {
use "$data_raw_mics/`file'", clear
	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_file = `3'
cap rename *, lower
gen mics="mics5"

cap drop individual_id
cap clonevar hh1=hi1
cap clonevar hh2=hi2
cap clonevar ln=hl1

*Line variable for Mexico
if country=="Mexico" & year_file==2015 {
   ren uf4 ln
}

*For age:
     cap rename ag2y age_child // South Sudan 2010
     cap rename ag2 age_child
	 
*Mauritania doesn't have "ec5"
if country=="Mauritania" & year_file==2011 {
   ren ec5a ec5
}

foreach M in a b c d e f {
	 cap ren ec7_1`M' ec7`M'a
	 cap ren ec7_2`M' ec7`M'b
	 cap ren ec7_3`M' ec7`M'x
	 cap ren ec7_4`M' ec7`M'y
 }

 for M in any aa ab ax ay ba bb bx by ca cb cx cy da db dx dy ea eb ex ey fa fb fx fy: cap tostring ec7M, replace
 
 foreach M in a b c d e f {
 foreach N in a b c x y {
	 cap ren ec7_`M'`N' ec7`M'`N'
 }
}

cap gen ec5=.
gen code_ec5=ec5

gen space=" "
gen individual_id = country+space+string(year_file)+space+string(hh1)+space+string(hh2)+space+string(ln)    

for X in any ec5 hl4: cap decode X, gen(temp_X)
for X in any ec5 hl4: cap tostring X, gen(temp_X) 
drop ec5 hl4
for X in any ec5 hl4: cap ren temp_X X
for X in any d m y: cap ren ag1_X ag1X
for X in any cage ag1y: cap gen X=.

for X in any ec1 ec7 chweight hh6 windex: cap gen X=.

keep individual_id country year ec5 hl4 age_child cage* ag1* code_ec5 ec1* ec7* chweight hh6 windex*
label drop _all
cap label drop _all
save "$data_mics\ch\countries\\`1'`3'", replace
}

*********************************************************************************************************
*********************************************************************************************************


* To append all the databases
cd "$data_mics\ch\countries"
local allfiles : dir . files "*.dta"
*di `allfiles'

use "Afghanistan2010.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c
drop cage_an cage_6_an cage_11_an caged_an
drop ag1c ag1f // just for Lao PDR
compress
save "$data_mics\ch\ch_append_mics_4&5.dta", replace

**************************************************************************
*			Translate
**************************************************************************
set more off
*Translate: I tried with encoding "ISO-8859-1" and it didn't work
clear
cd "$data_mics\ch"
unicode analyze "ch_append_mics_4&5.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "ch_append_mics_4&5.dta"


*****************************************************************************************
*****************************************************************************************


use "$data_mics\ch\ch_append_mics_4&5.dta", clear

bys individual_id: gen counts_n=_n
drop if counts_n>1 // eliminate duplicates. There are no duplicates!
drop counts_n

foreach var of varlist ec5 {
		replace `var' = subinstr(`var', "-", " ",.) 
		replace `var' = subinstr(`var', "ă", "a",.)
		replace `var' = subinstr(`var', "ĂĄ", "a",.)
		replace `var' = subinstr(`var', "ĂŁ", "a",.)
		replace `var' = subinstr(`var', "ĂŠ", "e",.)
		replace `var' = subinstr(`var', "č", "e",.)
 		replace `var' = subinstr(`var', "ń", "n",.) 
		replace `var' = subinstr(`var', "á", "a",.)
		replace `var' = subinstr(`var', "é", "e",.)
		replace `var' = subinstr(`var', "í", "i",.)
		replace `var' = subinstr(`var', "ó", "o",.)
		replace `var' = subinstr(`var', "ú", "u",.)
 }
 
foreach var of varlist ec5 hl4 {
		replace `var'=lower(`var')
		replace `var'=stritrim(`var')
		replace `var'=strltrim(`var')
		replace `var'=strrtrim(`var')
}

replace hl4="male" if hl4=="garçon"|hl4=="hombre"|hl4=="masculin"|hl4=="masculino"|hl4=="varón"
replace hl4="female" if hl4=="femenino"|hl4=="feminin"|hl4=="feminino"|hl4=="fille"|hl4=="féminin"|hl4=="hembra"|hl4=="mujer"

tab country if age_child==. // 15,517 missing values

codebook cage* , tab(100)
tab country if cage==.


count if cage==.
count if age_child==.

tab cage age_child if cage==., m
tab cage age_child if age_child==., m


tab country year_file if cage==. & age_child!=. // fix this?

tab country if ag1y==. // 24,796 missing

gen space=" "
egen country_year=concat(country space year_file)
drop space

*table country_year, c(count code_ec5)
tab country if ec5==""
tab country if ec5=="." // Cuba doesn't have info on EC5

label define code_ec5 1 "yes" 2 "no" 8 "don't know" 9 "missing"
label values code_ec5 code_ec5
label var code_ec5 "Attends early childhood education programme (CODE)"

ren hl4 hl4_child

cap drop space
order country* year_file individual_id hl4 code_ec5 ec5 age_child ag1* cage*


*table country_year, c(mean chweight) // check the countries that do not have chweight
*mauritania does not have weight and palestine 2010 presents a normalized weight

******* FOR NUMBER OF BOOKS
gen books=0
replace books=1 if ec1>=3 
replace books=. if (ec1==.|ec1==98|ec1==99)

*tab cage age_child, m
replace books=. if age_child>4

replace hh6=2 if hh6==3 & country_year=="LaoPDR 2011"
replace hh6=2 if hh6==3 & country_year=="Suriname 2010"
recode hh6 (2/3=1) (4=2) if country_year=="Mongolia 2010"

label define hh6 1 "Urban" 2 "Rural" 3 "Camps"
label values hh6 hh6

decode hh6, gen(location)

bys country_year: tab windex5
label define windex5 1 "1. Poorest" 2 "2. Second" 3 "3. Middle" 4 "4. Fourth" 5 "5. Richest"
label values windex5 windex5 
decode windex5, gen(wealth)
compress
*Palestine: 1 Father, 2 Mother, 3 Other, 4 No One
*Other countries: A Mother, B Father, X other, Y No one

codebook ec7aa, tab(100)
*
drop if country_year=="Palestine 2010"

for M in any aa ab ax ay ba bb bx by ca cb cx cy da db dx dy ea eb ex ey fa fb fx fy: codebook ec7M, tab(100)

 
tab country_year if ec7aa=="?"

*1(a)=read books, 2(b)=tell stories, 3(c)=sang songs, 4(d)=took outside, 5(e)=play, 6(f)=spend

foreach M in a b c d e f {
gen var_`M'=0
	replace var_`M'=1 if (ec7`M'a=="A"|ec7`M'b=="B"|ec7`M'x=="X")
	replace var_`M'=0 if (ec7`M'y=="Y")
	replace var_`M'=. if (ec7`M'a=="" & ec7`M'b=="" & ec7`M'x=="" & ec7`M'y=="" )
	replace var_`M'=. if (ec7`M'a=="?" & ec7`M'b=="?" & ec7`M'x=="?" & ec7`M'y=="?") // find out why they have a question mark...
}

egen total=rowtotal(var_a-var_f)
replace total=. if var_a==. & var_b==. & var_c==. & var_d==. & var_e==. & var_f==.

	gen adult_support=0
	replace adult_support=1 if total>=4
	replace adult_support=. if total==.
	
	gen adult_support_3659=adult_support if cage>=36 & cage<=59
	
	
table country_year [iw=chweight], c(mean adult_support mean adult_support_3659)
	
 

compress
save "$data_mics\ch\ch_mics_4&5.dta", replace

*Cuba doesn't have info on EC5




 

*----------------------------------------------------------------------------------------------------
use "$data_mics\ch\ch_mics_4&5.dta", clear


collapse (mean) books (median) year [iw=chweight], by(country_year country)
foreach var of varlist books {
	replace `var'=`var'*100
}
order country year books
br
*----------------------------------------------------------------------------------------------------
use "$data_mics\ch\ch_mics_4&5.dta", clear
collapse (mean) books (median) year [iw=chweight], by(country_year country hh6)
foreach var of varlist books {
	replace `var'=`var'*100
}
order country year books
br
*----------------------------------------------------------------------------------------------------
use "$data_mics\ch\ch_mics_4&5.dta", clear
collapse (mean) books (median) year [iw=chweight], by(country_year country windex5)
foreach var of varlist books {
	replace `var'=`var'*100
}
order country year books
br
