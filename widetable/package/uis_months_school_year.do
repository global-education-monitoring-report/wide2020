global aux_data "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
global uis_data "$aux_data\UIS"

*---------------------------------------------------------------------------------------------------------------------------------------------

cd "$uis_data\months_school_year"
clear
	import excel using "UIS_School_Year_17042018.xlsx", firstrow sheet(Sheet1)
	ren *, lower
	replace country="Czech Republic" if country=="Czechia"
save "temp_uis_school_year2015_16.dta", replace
	
	
clear
	import excel using "UIS_School_Year_10032011.xlsx", firstrow sheet(Sheet1)
	drop H-EB
	ren *, lower
	drop if year==.
	drop region* countrycode
	duplicates drop
	reshape wide month_start month_end, i(country) j(year)
	replace country="Cabo Verde" if country=="Cape Verde"
	replace country="Libya" if country=="Libyan Arab Jamahiriya"
	replace country="Palestine" if country=="Occupied Palestinian Territory"

	merge 1:1 country using "temp_uis_school_year2015_16.dta"
	br if _merge!=3
	drop _merge
	for X in any 2009 2010: ren month_startX month_start_X
	for X in any 2009 2010: ren month_endX month_end_X	
	for X in any school_year201415: ren month_start_X  month_start_2015
	for X in any school_year201415: ren month_end_X  month_end_2015
	for X in any school_year201516: ren month_start_X  month_start_2016
	for X in any school_year201516: ren month_end_X  month_end_2016
	
	gen country_name_uis=country
	replace country="Bolivia, Plurinational States of" if country_name_uis=="Bolivia (Plurinational State of)"
	replace country="Cabo Verde" if country_name_uis=="Cape Verde"
	replace country="Democratic Rep. of the Congo" if country_name_uis=="Democratic Republic of the Congo"
	replace country="Iran, Islamic Republic of" if country_name_uis=="Iran (Islamic Republic of)"
	replace country="Libya" if country_name_uis=="Libyan Arab Jamahiriya"
	replace country="Macao, China" if country_name_uis=="China, Macao Special Administrative Region"
	replace country="Palestine" if country_name_uis=="Occupied Palestinian Territory"
	replace country="The former Yugoslav Rep. of Macedonia" if country_name_uis=="The former Yugoslav Republic of Macedonia"
	replace country="United Kingdom" if country_name_uis=="United Kingdom of Great Britain and Northern Ireland"
	replace country="United States" if country_name_uis=="United States of America"
	replace country="Venezuela, Bolivarian Republic of" if country_name_uis=="Venezuela (Bolivarian Republic of)"
	replace country="Czech Republic" if country_name_uis=="Czechia"

	replace country="Faroe Islands" if country_name_uis=="Faeroe Islands"
	replace country="Holy See (Vatican City State)" if country_name_uis=="Holy See"
	replace country="Sint Maarten" if country_name_uis=="Sint Maarten (Dutch part)"
	replace country="Saint Martin" if country_name_uis=="Saint-Martin (French part)"
	replace country="Virgin Islands, US" if country_name_uis=="United States Virgin Islands"
	replace country="Aland Islands" if country_name_uis=="Åland Islands"
	replace country="Hong Kong, China" if country_name_uis=="China, Hong Kong Special Administrative Region"

merge 1:1 country using "$aux_data\temp\country_iso_codes_names.dta"
drop if _merge!=3
drop country_name_uis-iso_code2 iso_numeric-_merge
sort country
save "$aux_data\UIS\UIS_months_school_year_2009_2016.dta", replace

erase "temp_uis_school_year2015_16.dta"
