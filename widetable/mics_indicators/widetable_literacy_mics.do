**********************************************************
**LITERACY MICRODATA ***
************************************************18-12-2020
**********************************************************

// ******!!!! INSTALL FIRST !!!!
// *this searches files given a pattern, install it first
// findit filelist 

*******************************************
*PART 1: for ALL MICS THAT HAVE THE DATASET
*******************************************

***JOIN DATASETS: WM***

*change location to where dataset raw files are
*	cd "`data_path'"
clear
cd "C:\WIDE\raw_data\MICS"

*Search for all those that have a wm.dta file and append them into a single dataset
filelist, dir("C:\WIDE\raw_data") pattern("wm*.dta") save("women_datasets.dta") replace
        di "terminó filelist"
         use "women_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "women_datasets.dta" in `i', clear
           local f = dirname + "/" + filename
		   local g = dirname
           use "`f'", clear
           gen filepath = "`g'"
		   replace filepath= substr(filepath,23,100) 
		   generate splitat = ustrpos(filepath,"/")
		   generate country = usubstr(filepath,1,splitat - 1) 
		   generate year = usubstr(filepath,splitat + 1,.)
		   drop filepath
 		   tempfile save`i'
           save "`save`i''"
         }

 use "`save1'", clear
         forvalues i=2/`obs' {
           append using "`save`i''", force
         }

***RECODE ABLE TO READ VAR***
recode WB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy_1549)
*keep identifyer vars and literacy
rename LN hl1, replace
rename HH1 hh1, replace
rename HH2 hh2, replace
rename WM6D hh5d, replace
rename WM6M hh5m, replace
rename WM6Y hh5y, replace
rename WAGE age, replace
gen sex="Female"
keep country year hh1 hh2 hl1 partofcountry WB14 literacy_1549
compress
cd "C:\WIDE\output\MICS\literacy_temp"
save allWM.dta, replace

***JOIN DATASETS: MN***

*change location to where dataset raw files are
*	cd "`data_path'"
cd "C:\WIDE\raw_data\MICS"

*Search for all those that have a wm.dta file and append them into a single dataset
filelist, dir("C:\WIDE\raw_data") pattern("mn*.dta") save("men_datasets.dta") replace
        
         use "men_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "men_datasets.dta" in `i', clear
           local f = dirname + "/" + filename
   		   local g = dirname
           use "`f'", clear
           gen filepath = "`g'"
		   replace filepath= substr(filepath,23,100) 
		   generate splitat = ustrpos(filepath,"/")
		   generate country = usubstr(filepath,1,splitat - 1) 
		   generate year = usubstr(filepath,splitat + 1,.)
		   drop filepath
           gen source = "`f'"
		   tempfile save`i'
           save "`save`i''"
         }

 use "`save1'", clear
         forvalues i=2/`obs' {
           append using "`save`i''"
         }
***RECODE ABLE TO READ VAR***
recode MWB14 (1 = 0) (2 3 = 1) (4 9 = .), gen(literacy_1549)
*keep identifyer vars and literacy
rename LN hl1, replace
rename HH1 hh1, replace
rename HH2 hh2, replace
rename MWM6D hh5d, replace
rename MWM6M hh5m, replace
rename MWM6Y hh5y, replace
rename MWB4 age
gen sex="Male"
keep country year hh1 hh2 hl1 MWB14 literacy_1549
compress
cd "C:\WIDE\output\MICS\literacy_temp"
save allMN.dta, replace

***JOIN LITERACY FILES***
cd "C:\WIDE\output\MICS\literacy_temp"
use allMN.dta
append using allWM.dta

**Merge approach is not 
***MERGE DATASET WITH MICRODATA FILE***
*Merge is done with id vars + date of the interview
*Togo has 2 duplicates, with empty identifiers for the line number. No observation has info on literacy, so we get rid of that. 
duplicates drop country year hh1 hh2 hl1 partofcountry, force
destring year, replace
di "merge output of literacy variable is"
merge 1:1 country year hh1 hh2 hl1 partofcountry using "C:\WIDE\output\MICS\data\mics_calculate.dta", gen(litmerge)



