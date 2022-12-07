******************************************************************
**CHILDREN LEARNING AND EARLY CHILDHOOD DEVELOPMENT MICRODATA ***
************************************************20-04-2021********
******************************************************************

// ******!!!! INSTALL FIRST !!!!
// *this searches files given a pattern, install it first
// findit filelist 
// findit usespss 

*******************************************
*PART 1: for ALL MICS THAT HAVE THE DATASET
*******************************************

***JOIN DATASETS: CH***

*change location to where dataset raw files are
*	cd "`data_path'"
clear
cd "C:\WIDE\raw_data\MICS"

*Search for all those that have a ch.dta file and append them into a single dataset
filelist, dir("C:\WIDE\raw_data") pattern("ch*.sav") save("ch_datasets.dta") replace
       use "ch_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "ch_datasets.dta" in `i', clear
           local f = dirname + "/" + filename
		   local g = dirname
		   usespss "`f'", clear
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

***keep only EARLY CHILDHOOD DEVELOPMENT module (EC questions)***
keep country year hh1 hh2 hl1 partofcountry EC*
compress
cd "C:\WIDE\output\MICS\newmodules_temp"
save allCH.dta, replace

**********************
***JOIN DATASETS: FS***

*change location to where dataset raw files are
cd "C:\WIDE\raw_data\MICS"

*Search for all those that have a fs.sav file and append them into a single dataset
filelist, dir("C:\WIDE\raw_data") pattern("fs*.sav") save("fs_datasets.dta") replace
        
         use "fs_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "fs_datasets.dta" in `i', clear
           local f = dirname + "/" + filename
   		   local g = dirname
		   usespss "`f'", clear
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
           append using "`save`i''", force
         }
***Keep FOUNDATIONAL LEARNING SKILLS module 
keep country year HH1 HH2 LN FS1 FS2 FS3 FS4 FL* 
compress
cd "C:\WIDE\output\MICS\newmodules_temp"
save allFS.dta, replace

***JOIN LITERACY FILES***
cd "C:\WIDE\output\MICS\newmodules_temp"
// use allFS.dta
// append using allCH.dta

*Up to this it collects all these modules


***MERGE DATASET WITH MICRODATA FILE***
*the following should work well with both mics_calculate and mics_standardize, just double check the country list 
*Merge is done with id vars: HH1 HH2 LN for all**.dta and hh1 hh2 hl1 for mics_calculate.dta

**Some year fixes to make merge possible in some countries
replace year="2018" if country=="DRCongo"
replace year="2019" if country=="CentralAfricanRepublic"
replace year="2019" if country=="Guinea-Bissau"

// *renaming to coincide with widetable pre-output
rename HH1 hh1
rename HH2 hh2
rename LN hl1

merge 1:1 country year hh1 hh2 hl1 using "C:\WIDE\output\MICS\data\mics_standardize.dta"


// capture confirm string var year
// if _rc==0 {
// destring year, replace
// }
// else {
// }
//
// merge 1:1 country year hh1 hh2 hl1 using "C:\WIDE\output\MICS\data\mics_clean.dta"





