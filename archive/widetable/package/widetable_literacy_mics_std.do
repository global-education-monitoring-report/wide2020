**********************************************************
**LITERACY AND MASS MEDIA / ICT USE MICRODATA ***
************************************************18-12-2020
************************************************06-05-2021
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
		   generate year = usubstr(filepath,splitat + 1,4)
		   *Adding this rename so that LN and ln don't cause trouble
		   capture rename ln LN 
		   capture confirm variable LN 
				if !_rc {	
				}
					else {
					*Special case for Mexico 2015
					   capture rename WM4 LN 
						}
		   drop filepath
		   *First check if literacy variable exists, if not, delete that file 
		   capture confirm variable WB14
			if _rc == 0 {
			*di "Something exists, keeping " "`f'"
		   	*Adding this to check for the MASS MEDIA AND ICT module and capture it if variables exist
			 capture confirm variable MT2 
				if !_rc {
							di "Both literacy and mass media exist, keeping " "`f'"
							keep country year HH1 HH2 LN WB14 WM6D WM6M WM6Y MT*
						}
					else {
							di "Only literacy exists, keeping " "`f'"
							keep country year HH1 HH2 LN WB14 WM6D WM6M WM6Y 
						}
			
 		   tempfile save`i'
           save "`save`i''"
		   }
		else {
		 	  *Adding this in case only mass media ict exists
			 capture confirm variable MT2 
				if !_rc {
							keep country year HH1 HH2 LN MT* 
							tempfile save`i'
							save "`save`i''"
						}
					else {
							di "Clearing because neither literacy nor mass media/ict variables exists in " "`f'"
							keep country year
							keep if _n==1
							tempfile save`i'
							save "`save`i''"
						}
			
			}
         }

 use "`save1'", clear
         forvalues i=2/`obs' {
           append using "`save`i''", force
         }

***RECODE ABLE TO READ TEST VAR***
recode WB14 (1 = 0) (2 3 = 1) (4 6 9 = .), gen(literacy_1549)
*keep identifyer vars and literacy
  capture confirm variable LN
			if !_rc {
			rename LN hl1, replace
			}
			else {
			rename ln hl1, replace
			}

rename HH1 hh1, replace
rename HH2 hh2, replace
rename WM6D hh5d, replace
rename WM6M hh5m, replace
rename WM6Y hh5y, replace
*rename WAGE age, replace
gen sex="Female"

capture confirm variable partofcountry
    if !_rc {
	keep country year sex hh1 hh2 hl1 partofcountry WB14 literacy_1549 MT*
    }
    else {
	keep country year sex hh1 hh2 hl1 WB14 literacy_1549 MT*
    }
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
		   generate year = usubstr(filepath,splitat + 1,4)
		   drop filepath  
   		   *Adding this distinction so that LN and ln don't cause trouble
   		   capture rename ln LN 
		   capture confirm variable MWB14
			if _rc == 0 {
			di "Something exists, keeping " "`f'"
		    *Adding this to check for the MASS MEDIA AND ICT module and capture it if variables exist
			 capture confirm variable MMT2 
				if !_rc {
							keep country year HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4 MMT*
						}
					else {
							keep country year HH1 HH2 LN MWB14 MWM6D MWM6M MWM6Y MWB4
						}
			
 		   tempfile save`i'
           save "`save`i''"
		   }
		else {
		 	  *Adding this in case only mass media ict exists
			 capture confirm variable MMT2 
				if !_rc {
							keep country year HH1 HH2 LN MMT*
							tempfile save`i'
							save "`save`i''"
						}
					else {
							di "Clearing because neither literacy nor mass media/ict variables exists in " "`f'"
							keep country year
							keep if _n==1
							tempfile save`i'
							save "`save`i''"
						}
			
			}
		   
      }

 use "`save1'", clear
         forvalues i=2/`obs' {
           append using "`save`i''"
         }
		 
		 
***RECODE ABLE TO READ VAR***
recode MWB14 (1 = 0) (2 3 = 1) (4 9 = .), gen(literacy_1549)
*keep identifyer vars and literacy
  capture confirm variable LN
			if !_rc {
			rename LN hl1, replace
			}
			else {
			rename ln hl1, replace
			}
rename HH1 hh1, replace
rename HH2 hh2, replace
rename MWM6D hh5d, replace
rename MWM6M hh5m, replace
rename MWM6Y hh5y, replace
rename MWB4 age
gen sex="Male"
keep country year hh1 hh2 hl1 sex MWB14 literacy_1549 MMT*
compress
cd "C:\WIDE\output\MICS\literacy_temp"
save allMN.dta, replace

***JOIN WM+MN FILES***
cd "C:\WIDE\output\MICS\literacy_temp"
use allMN.dta
append using allWM.dta

***MERGE DATASET WITH STANDARDIZED MICRODATA FILE***
*Merge is done with id vars 
*Togo has 2 duplicates, with empty identifiers for the line number. No observation has info on literacy, so we get rid of that.
*Thailand has a couple too, with no info whatsoever, so we get rid of that too. 
    capture confirm variable partofcountry
    if !_rc {
	duplicates drop country year hh1 hh2 hl1 partofcountry, force
    }
    else {
	duplicates drop country year hh1 hh2 hl1 , force
    }
	
*This homogenizes the year variable for merge, that should be numeric in both mics_standardize and here

capture confirm string var year
if _rc==0 {
destring year, replace
}
else {
}

*This is foolproof for some country group with no subregions

    capture confirm variable partofcountry
    if !_rc {
	merge 1:1 country year hh1 hh2 hl1 partofcountry using "C:\WIDE\output\MICS\data\mics_standardize.dta", nogenerate  keep(match using) 
    }
    else {
    merge 1:1 country year hh1 hh2 hl1 using "C:\WIDE\output\MICS\data\mics_standardize.dta", nogenerate  keep(match using) 
    }





