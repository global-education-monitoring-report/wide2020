***ver. December 28, 2020
***Contact: Marcela Barrios Rivera, Sunmin Lee 

***LITERACY SIMPLIFIED

****************************MICS 4: THE LITERACY VARIABLE IS CALLED WB7 : RUN FROM LINE 8 TO 31 

*TO TEST WITH ONE SURVEY
clear
*Go to the directory of the WM dataset (in raw data)
cd "/Users/sunminlee/Desktop/gemr/wide_etl/raw_data/MICS/Benin/2014"
*Open the dataset that contains the literacy variable
use wm.dta
*Drop all the variables not needed
keep HH1 HH2 ln WB7
*Rename individual identifyer variables to make the merge possible
rename HH1 hh1
rename HH2 hh2
rename ln hl1

*Go to the directory of the mics_calculate
cd "/Users/sunminlee/Desktop/gemr/wide_etl/output/MICS/data"
*MERGE the mini dataset to the mics_calculate
merge 1:1 hh1 hh2 hl1 using "mics_calculate.dta", gen(litmerge)

*Generate the literacy variable 
recode WB7 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy_1549)
replace literacy_1549 = 1 if eduyears >= years_lowsec & litmerge==3

*Save mics_calculate.dta file with literacy variable
save mics_calculate_literacy.dta, replace

*******************************MICS 6: THE LITERACY VARIABLE IS CALLED WB14: RUN FROM LINE 35 TO 56

*TO TEST WITH ONE SURVEY
clear
*Go to the directory of the WM dataset (in raw data)
cd "/Users/sunminlee/UNESCO/Barakat, Bilal Fouad - WIDE 2.0/WIDE Data/raw_data/MICS/Belize/2015"
*Open the dataset that contains the literacy variable
use wm.dta
*Drop all the variables not needed
//keep HH1 HH2 ln WB14
keep hh1 hh2 ln WB14
*Rename individual identifyer variables to make the merge possible
// rename HH1 hh1
// rename HH2 hh2
rename ln hl1

*Go to the directory of the mics_calculate
cd "/Users/sunminlee/UNESCO/Barakat, Bilal Fouad - WIDE 2.0/WIDE Data/micro_data/MICS/Belize/2015/widetable"
*MERGE the mini dataset to the mics_calculate
merge 1:1 hh1 hh2 hl1 using "mics_calculate.dta", gen(litmerge)
**

*Generate the literacy variable 
recode WB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy_1549)
replace literacy_1549 = 1 if eduyears >= years_lowsec & litmerge==3

*Save mics_calculate.dta file with literacy variable
save mics_calculate_literacy.dta, replace

********************************************

*EXTRA WHEN THERE'S A MN dataset available 
clear
*Go to the directory of the MN dataset (in raw data)
cd "/Users/sunminlee/UNESCO/Barakat, Bilal Fouad - WIDE 2.0/WIDE Data/raw_data/MICS/Gambia/2018"
*Open the dataset that contains the literacy variable
use mn.dta
*Drop all the variables not needed
keep hh1 hh2 ln mwb14
*Rename individual identifyer variables to make the merge possible
//rename HH1 hh1
//rename HH2 hh2
rename ln hl1

*Go to the directory of the mics_calculate
cd "/Users/sunminlee/UNESCO/Barakat, Bilal Fouad - WIDE 2.0/WIDE Data/micro_data/MICS/Gambia/2018/widetable"
*MERGE the mini dataset to the mics_calculate
merge 1:1 hh1 hh2 hl1 using "mics_calculate.dta", gen(litmerge2)
**

*Complete the literacy variable for men
replace literacy_1549=0 if inlist(mwb14, 1)
replace literacy_1549=0 if inlist(mwb14, 2, 3)
replace literacy_1549=0 if inlist(mwb14, 4, 6, 9)
replace literacy_1549 = 1 if eduyears >= years_lowsec & litmerge2==3

*Save mics_calculate.dta file with literacy variable
save mics_calculate_literacy.dta, replace
