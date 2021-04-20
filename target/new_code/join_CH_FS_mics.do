******************************************************************
**CHILDREN LEARNING AND EARLY CHILDHOOD DEVELOPMENT MICRODATA ***
************************************************20-04-2021********
******************************************************************

// ******!!!! INSTALL FIRST !!!!
// *this searches files given a pattern, install it first
// findit filelist 

*******************************************
*PART 1: for ALL MICS THAT HAVE THE DATASET
*******************************************

***JOIN DATASETS: CH***

*change location to where dataset raw files are
*	cd "`data_path'"
clear
cd "C:\WIDE\raw_data\MICS"

*Search for all those that have a wm.dta file and append them into a single dataset
filelist, dir("C:\WIDE\raw_data") pattern("ch*.sav") save("ch_datasets.dta") replace
       use "ch_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "women_datasets.dta" in `i', clear
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

***JOIN DATASETS: FS***

*change location to where dataset raw files are
*	cd "`data_path'"
cd "C:\WIDE\raw_data\MICS"

*Search for all those that have a wm.dta file and append them into a single dataset
filelist, dir("C:\WIDE\raw_data") pattern("fs*.sav") save("fs_datasets.dta") replace
        
         use "men_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "men_datasets.dta" in `i', clear
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
           append using "`save`i''"
         }
***Keep FOUNDATIONAL LEARNING SKILLS module 
keep country year hh1 hh2 hl1 FL*
compress
cd "C:\WIDE\output\MICS\literacy_temp"
save allFS.dta, replace

***JOIN LITERACY FILES***
cd "C:\WIDE\output\MICS\literacy_temp"
use allFS.dta
append using allCH.dta

**Merge approach is not 
***MERGE DATASET WITH MICRODATA FILE***
*Merge is done with id vars + date of the interview
*Togo has 2 duplicates, with empty identifiers for the line number. No observation has info on literacy, so we get rid of that. 
duplicates drop country year hh1 hh2 hl1 partofcountry, force

*This homogenizes the year variable for merge

capture confirm string var year
if _rc==0 {
destring year, replace
}
else {
}

*This is foolproof for some country group with no subregions

    capture confirm variable partofcountry
    if !_rc {
	merge 1:1 country year hh1 hh2 hl1 partofcountry using "C:\WIDE\output\MICS\data\mics_calculate.dta", nogenerate  keep(match using) 
    }
    else {
    merge 1:1 country year hh1 hh2 hl1 using "C:\WIDE\output\MICS\data\mics_calculate.dta", nogenerate  keep(match using) 
    }





