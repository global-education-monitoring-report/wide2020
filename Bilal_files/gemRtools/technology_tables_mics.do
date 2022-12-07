************************************************
***********ICT tables from MICS*****************
************************************************

// HOUSEHOLD:
//
// HC11 HC12 HC13 
//
// by SEXHH LOCATION WEALTH
//
// INDIVIDUAL 
//
// MMT10 MT10 internet use
// MMT5 MT5 computer use 
// by SEX LOCATION WEALTH
//
// MMT6A MMT6B MMT6C MMT6D MMT6E MMT6F MMT6G MMT6H MMT6I (Y/N)


******
*Part 1: HH module extraction
******************************

global raw_path  "C:\Users\taiku\Desktop\temporary_raw"
global std_path "C:\Users\taiku\Desktop\temporary_std"

**FIRST STEP: SCAN THE RAW DATA directory and get a list of survey IDs
local raw_list_mics : dir "$raw_path" dirs "*mics*"


**SECOND STEP: SCAN THE STANDARDIZED directory and get a list of survey IDS
local done_list_mics : dir "$std_path" dirs "*mics*"

**THIRD STEP: generate a new list of surveys to be processed
local process_list_mics : list raw_list_mics-done_list_mics

di "The following MICS surveys will be processed" 
foreach filepath of local process_list_mics {
   di "`filepath'"
}


 set trace on
 set tracedepth 1
**Now call MICS_standardize RECURSIVELY
local dpath "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
local opath "C:\Users\taiku\Desktop\temporary_std"
foreach survey of local process_list_mics {
        di "Now processing" " `survey'"
		tokenize "`survey'", parse(_)

		*Open raw HH module, if it exists 
		cd "`dpath'\\`1'_`3'_MICS\"
		capture confirm file hh.dta 
		if _rc == 0 {
		use "hh.dta", clear
		capture rename * , lower
		
		*iso = 1 , survey = 2 , year = 3
		
		*Check if variables exist, if they do tabulate and save variables HC11 HC12 HC13 by SEXHH LOCATION WEALTH
		
			
			capture confirm variable hc11
					if !_rc {
			foreach var of varlist hc11 hc12 hc13 {
				cd "C:\Users\taiku\Desktop\multiproposito"
					*Urban
					tabout  hh6  `var' using test.xls [aw= hhweight] if hh6==1,  cells(cell) h3(`survey')  layout(col) append ptotal(none) f(2)
					*Rural
					tabout  hh6  `var' using test.xls [aw= hhweight] if hh6==2,  cells(cell) h3(`survey')  layout(col) append ptotal(none) f(2)
					*Poorest quintile
					tabout    windex5  `var' using test.xls [aw= hhweight] if windex5==1,  cells(cell) h3(`survey')  layout(col) append ptotal(none) f(2)
					*Richest quintile 
					tabout    windex5  `var' using test.xls [aw= hhweight] if windex5==5,  cells(cell) h3(`survey')  layout(col) append ptotal(none) f(2)
					*HH leader male
					tabout    hhsex  `var' using test.xls [aw= hhweight] if hhsex==1,  cells(cell) h3(`survey')  layout(col) append ptotal(none) f(2)
					*HH leader female
					tabout    hhsex  `var' using test.xls [aw= hhweight] if hhsex==2,  cells(cell) h3(`survey')  layout(col) append ptotal(none) f(2)
						}
			}
			
				
		clear
     }
	 else {
	 di "`survey'" "doesnt have hh module"
		}
			}
 set trace off	 
 
 
*********
*Part 2: Standardized module extraction 
******************************************


global raw_path "C:\Users\taiku\Desktop\temporary_raw"
global std_path "C:\Users\taiku\Desktop\temporary_std"

**FIRST STEP: SCAN THE RAW DATA directory and get a list of survey IDs
local raw_list_mics : dir "$raw_path" dirs "*mics*"


**SECOND STEP: SCAN THE STANDARDIZED directory and get a list of survey IDS
local done_list_mics : dir "$std_path" dirs "*mics*"

**THIRD STEP: generate a new list of surveys to be processed
local process_list_mics : list raw_list_mics-done_list_mics

di "The following MICS surveys will be processed" 
foreach filepath of local process_list_mics {
   di "`filepath'"
}


* set trace on
* set tracedepth 1
**Now call MICS_standardize RECURSIVELY
local dpath "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
local opath "C:\Users\taiku\Desktop\temporary_std"
foreach survey of local process_list_mics {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		tokenize "`survey'", parse(_)
		local isocode=upper("`1'")
		
		*Open standardized module
		cd "C:\Users\taiku\UNESCO\GEM Report - 2_standardised\\`isocode'_`3'_MICS"
		use "std_`isocode'_`3'_MICS.dta", clear
		capture rename * , lower
		capture confirm variable mt10 
		 if !_rc {
		 
		

		*Check if variables for male exist, if they do make a variable that combines both sexes, and then tab
		capture confirm variable mmt10
					if !_rc {
		egen internet_use = rowtotal(mmt10 mt10)
		label values internet_use MT10
		label variable internet_use "Used internet in the last 3 months"
		
		*Tabulate and save variables MMT10 MT10 internet use by SEX LOCATION WEALTH
		cd "C:\Users\taiku\Desktop\multiproposito"
		*Location
		fre internet_use if location=="Urban" using standardized.txt [aw=hhweight], includelabeled append pre(Urban) post(`survey')
		fre internet_use if location=="Rural" using standardized.txt [aw=hhweight], includelabeled append pre(Rural) post(`survey')
		*Sex
		fre internet_use if sex=="Female" using standardized.txt [aw=hhweight] , includelabeled append pre(Female) post(`survey')
		fre internet_use if sex=="Male" using standardized.txt [aw=hhweight] , includelabeled append pre(Male) post(`survey')
		*Wealth
		fre internet_use if wealth=="Quintile 1" using standardized.txt [aw=hhweight] , includelabeled append pre(Poorest) post(`survey')
		fre internet_use if wealth=="Quintile 5" using standardized.txt [aw=hhweight] , includelabeled append pre(Richest) post(`survey')
							}
						else {
		*Location
		fre mt10 if location=="Urban" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Urban) post(`survey')
		fre mt10 if location=="Rural" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Rural) post(`survey')
		*Wealth
		fre mt10 if wealth=="Quintile 1" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Poorest) post(`survey')
		fre mt10 if wealth=="Quintile 5" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Richest) post(`survey')
						}
		
			
		*Tabulate and save variables MMT5 MT5 computer use by SEX LOCATION WEALTH
		
		capture confirm variable mmt5
					if !_rc {
		egen computer_use = rowtotal(mmt5 mt5)
		label values computer_use MT5
		label variable computer_use "Used computer in the last 3 months"
		*Tabulate and save variables MMT10 MT10 internet use by SEX LOCATION WEALTH
		cd "C:\Users\taiku\Desktop\multiproposito"
		*Location
		fre computer_use if location=="Urban" using standardized.txt [aw=hhweight], includelabeled append pre(Urban) post(`survey')
		fre computer_use if location=="Rural" using standardized.txt [aw=hhweight], includelabeled append pre(Rural) post(`survey')
		*Sex
		fre computer_use if sex=="Female" using standardized.txt [aw=hhweight] , includelabeled append pre(Female) post(`survey')
		fre computer_use if sex=="Male" using standardized.txt [aw=hhweight] , includelabeled append pre(Male) post(`survey')
		*Wealth
		fre computer_use if wealth=="Quintile 1" using standardized.txt [aw=hhweight] , includelabeled append pre(Poorest) post(`survey')
		fre computer_use if wealth=="Quintile 5" using standardized.txt [aw=hhweight] , includelabeled append pre(Richest) post(`survey')
			
							}
					else {
		*Location
		fre mt5 if location=="Urban" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Urban) post(`survey')
		fre mt10 if location=="Rural" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Rural) post(`survey')
		*Wealth
		fre mt5 if wealth=="Quintile 1" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Poorest) post(`survey')
		fre mt5 if wealth=="Quintile 5" using standardized.txt [aw=hhweight] , includelabeled append pre(Women - Richest) post(`survey')
						}

		
		*Tabulate and save variables MMT6A MMT6B MMT6C MMT6D MMT6E MMT6F MMT6G MMT6H MMT6I (Y/N) 
		
		capture confirm variable mmt6a 
		  if !_rc {
					foreach var of varlist mmt6* mt6* {
					cd "C:\Users\taiku\Desktop\multiproposito"
					tabout   `var' using standardized2.xls [aw= hhweight] ,  cells(cell) h3(`survey' - `var')  layout(col) append ptotal(none) f(2) 
						}
				}
				else {
					foreach var of varlist mt6* {
					cd "C:\Users\taiku\Desktop\multiproposito"
						tabout   `var' using standardized2.xls [aw= hhweight] ,  cells(cell) h3(`survey' - `var')  layout(col) append ptotal(none) f(2) 
							}
				
				}
		
		clear
		 }
		 else {
		 di "there's no mass media and ict module, moving on to the next survey"
		 clear
		 }
     }
* set trace off	 