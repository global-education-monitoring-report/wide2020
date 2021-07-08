******************************************
****DANCE DANCE (DIRECTORY) REVOLUTION****
************20-05-2021********************
******************************************

*Code to simplify the folder structure of raw_data. 

// findfile country_iso_codes_names.dta, path("C:\ado\personal")
// use "`r(fn)'", clear
// drop if country_code_dhs == ""
// tempfile isocode
	
* Transforming the MICS subfolder

findfile filenames_ultimate.xlsx, path("C:\ado\personal")
import excel  "`r(fn)'", sheet(mics_hl_files) firstrow clear 
rename folder_country country_name_mics
merge m:1 country_name_mics using "C:\ado\personal\country_iso_codes_names2.dta", keep(match master) nogenerate

*trim "/hl.dta" part from filepath
replace filepath = substr(filepath, 1, length(filepath) - 6)
rename filepath old_filepath
egen filepath2=concat(old_filepath iso_code3)
drop old_filepath
*Now I have all the ingredients
levelsof filepath, local(filepath) clean 

local old_raw "C:\WIDE\raw_data"
local new_raw "C:\Users\taiku\Desktop\1_raw_data\"
*Hint: make the folder, then move it to OneDrive

foreach file of local filepath {
			tokenize `file', parse(/)
			*Create "country_year_survey" folder
			capture mkdir "`new_raw'/`5'_`3'_MICS"
			*Move to old directory, get list of all files
			local modules : dir "`old_raw'\MICS\\`1'\\`3'" files "*.dta"
			*Loop over all the dta files on that directory, open and save them in the new one
			foreach module in `modules' {
				use "`old_raw'\MICS\\`1'\\`3'\\`module'", clear
				cd "`new_raw'\`5'_`3'_MICS"
				save "`module'", replace
				}
			local modules : dir "`old_raw'\MICS\\`1'\\`3'" files "*.sav"
			*Loop over all the sav(SPSS) files on that directory, open and save them in the new one
			foreach module in `modules' {
				usespss "`old_raw'\MICS\\`1'\\`3'\\`module'", clear
				cd "`new_raw'/`5'_`3'_MICS"
				save "`module'", replace
							}
}

	
* Transforming the DHS subfolder

**New warning: Use Stata MP version for DHS part because it can't read large datasets
set maxvar 12000

findfile filenames_ultimate.xlsx, path("`c(sysdir_personal)'/")
*Choosing PR because it's the file that is always there for all surveys that were in old_raw 
import excel "`r(fn)'", sheet(dhs_pr_files) firstrow clear 
rename folder_country country_name_mics
merge m:1 country using "C:\ado\personal\country_iso_codes_names2.dta", keep(match master) nogenerate

*Get filepath ready
replace filepath = substr(filepath, 1, length(filepath) - 12)
rename filepath old_filepath
egen filepath2=concat(old_filepath iso_code3)
drop old_filepath
*Now I have all the ingredients
levelsof filepath, local(filepath) clean 

local old_raw "C:\WIDE\raw_data"
local new_raw "C:\Users\taiku\Desktop\1_raw_data\"

*set trace on
foreach file of local filepath {
			tokenize `file', parse(/)
			*Create "country_year_survey" folder
			capture mkdir "`new_raw'/`5'_`3'_DHS"
			*Move to old directory, get list of all files
			local modules : dir "`old_raw'\DHS\\`1'\\`3'"  files "*.dta"
			*Loop over all the dta files on that directory, open and save them in the new one
			foreach module in `modules' {
				use "`old_raw'\DHS\\`1'\\`3'\\`module'", clear
				cd "`new_raw'/`5'_`3'_DHS"
				save "`module'", replace
							}
}
*set trace off

