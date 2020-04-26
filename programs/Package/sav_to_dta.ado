program define sav_to_dta

local savfiles : dir . files "*.sav"

mkdir "$data_path/dta"

foreach file of local savfiles {

	usespss using "`file'", clear

	save "$data_path/dta/`file'.dta", replace

}

end
