************************************************
***********MICS UPDATE**************************
************14-05-2021**************************

*******************************************************************
*This new module follows a new logic in the update of MICS surveys:
*TO ONLY UPDATE NEW DATASETS, ON A SEQUENTIAL BASIS****************
*******************************************************************

**FIRST STEP: SCAN THE RAW DATA directory and get a list of Country Year Survey

filelist, dir("C:\WIDE\raw_data") pattern("hl*.dta") save("raw_datasets.dta") replace
use "C:\Users\taiku\Documents\GEM UNESCO MBR\raw_datasets.dta"
split dirname, p(/)
rename dirname3 country
rename dirname4 year
gen survey="MICS"
keep country year survey
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\"
save "raw_datasets.dta"
*TO-DO: add MR for DHS surveys


**SECOND STEP: SCAN THE STANDARDIZED directory / dataset and get a list of Country Year Survey
*Go to standardized directory of country files
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\"
filelist, dir("C:\Users\taiku\UNESCO\GEM Report - wide_standardize") pattern("*.dta") save("processed_datasets.dta") replace
use "processed_datasets.dta"
split filename, p(_)
split filename3, p(.)
rename filename2 country
rename filename31 year
gen survey="MICS"
keep country year survey
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\"
save "processed_datasets.dta"


**THIRD STEP: MERGE to see if any new survey has been added, generate a new list of surveys to be processed
cd "C:\Users\taiku\Documents\GEM UNESCO MBR\"
use "raw_datasets.dta", clear
merge 1:1 country survey year using "processed_datasets.dta"
keep if _merge==1
di "The following surveys have not been yet processed"
list country year
egen country_year_mics=concat(country year) if survey=="MICS", punct(_)
egen country_year_dhs=concat(country year) if survey=="DHS", punct(_)
save updatelist.dta


**Now call MICS/DHS_standardize RECURSIVELY

levelsof country_year_mics, local(micssurveys)
foreach survey of local micssurveys {
         di "Now processing" " `survey'"
         *First generate the filenames.xlsx 
		 use updatelist.dta if country_year=="`survey'", clear
		 rename country folder_country
		 rename year folder_year
		 gen filename="hl.dta"
		 egen filepath=concat(folder_country folder_year filename), punct(/)
		 keep folder_country folder_year filename filepath
		 export excel using "C:\ado\personal\filenames.xls", firstrow(variables) replace
		 *Now run widetable with one survey
		local dpath "C:\WIDE\raw_data"
		local opath "C:\WIDE\output"
		widetable, source(mics) step(standardize) data_path(`dpath') output_path(`opath') nf(1)
		cd "C:\Users\taiku\UNESCO\GEM Report - wide_standardize"
		save "std_`survey'.dta"
		clear
     }
	 

levelsof country_year_mics, local(micssurveys)
foreach survey of local dhssurveys {
         di "Now processing" " `survey'"
         *First generate the filenames.xlsx 
		 use updatelist.dta if country_year=="`survey'", clear
		 rename country folder_country
		 rename year folder_year
		 foreach module in mr ir pr { // need to make this compatible to DHS with less than 3 modules...
				merge 1:1 country year using "dhs_filenames.dta", keep(match)
				gen lowerfilename=lower(filename)
				keep if strpos(lowerfilename, "`module'")
				drop lowerfilename
				egen filepath=concat(folder_country folder_year filename), punct(/)
				export excel using "C:\ado\personal\filenames.xls", sheet("dhs_`module'_files") firstrow(variables) replace
		 }
		 *Now run widetable with one survey
		local dpath "C:\WIDE\raw_data"
		local opath "C:\WIDE\output"
		widetable, source(dhs) step(standardize) data_path(`dpath') output_path(`opath') nf(1)
		cd "C:\Users\taiku\UNESCO\GEM Report - wide_standardize"
		save "std_`survey'.dta"
		clear
     }
	 





