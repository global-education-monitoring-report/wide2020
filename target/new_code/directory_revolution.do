******************************************
****DANCE DANCE (DIRECTORY) REVOLUTION****
************20-05-2021********************
******************************************

*Code to simplify the folder structure of raw_data. 

local old_raw "C:\WIDE\raw_data"
local new_raw "C:\Users\taiku\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\"

findfile country_iso_codes_names.dta, path("C:\ado\personal")
use "`r(fn)'", clear
drop if country_code_dhs == ""
tempfile isocode
	
* Transforming the MICS subfolder
findfile filenames_ultimate.xlsx, path("C:\ado\personal")
import excel  "`r(fn)'", sheet(mics_hl_files) firstrow clear 
merge m:1 country using "`isocode'", keep(match master) nogenerate

*trim "/hl.dta" part from filepath
replace filepath = substr(Subject, 1, length(Subject) - 6)
rename filepath old_filepath
egen filepath2=concat(old_filepath iso_code3)
drop old_filepath
*Now I have all the ingredients
levelsof filepath, local(filepath) clean 

foreach file of local filepath {
			tokenize `file', parse(/)
			*Create "country_year_survey" folder
			capture mkdir "`new_raw'/`5'_`3'_MICS"
			*Move to old directory, get list of all files
			local modules : dir "``old_raw'/MICS/`1'/`3'" files "*"
			*Loop over all the dta files on that directory, open and save them in the new one
			foreach module in `modules' {
				use `module', clear
				cd "`new_raw'/`5'_`3'_MICS"
				save `module', replace
							}
}

	
* Transforming the DHS subfolder

findfile filenames.xlsx, path("`c(sysdir_personal)'/")
*Choosing PR because it's the file that is always there for all surveys that were in old_raw 
import excel "`r(fn)'", sheet(dhs_pr_files) firstrow clear 
merge m:1 country using "`isocode'", keep(match master) nogenerate

*Get filepath ready
replace filepath = substr(Subject, 1, length(Subject) - 12)
rename filepath old_filepath
egen filepath2=concat(old_filepath iso_code3)
drop old_filepath
*Now I have all the ingredients
levelsof filepath, local(filepath) clean 

foreach file of local filepath {
			tokenize `file', parse(/)
			*Create "country_year_survey" folder
			capture mkdir "`new_raw'/`5'_`3'_MICS"
			*Move to old directory, get list of all files
			local modules : dir "``old_raw'/MICS/`1'/`3'" files "*"
			*Loop over all the dta files on that directory, open and save them in the new one
			foreach module in `modules' {
				use `module', clear
				cd "`new_raw'/`5'_`3'_MICS"
				save `module', replace
							}
}
