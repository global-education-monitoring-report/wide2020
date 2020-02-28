
global aux_data "P:\WIDE\auxiliary_data"

*---------------------------------------------------------------------------------------------------------------------------------------------
clear
import excel using "$aux_data\UIS\sources\UIS_sources_formatted_02262020.xlsx", firstrow sheet(list)
cap drop J-AA
drop if year_uis==999999 // drop the years that are not used for calculations

bys iso_code3 year_uis: gen N=_N 
tab N
drop N
label var year_uis "year used for calculation of UIS completion indicators"

save "$aux_data\UIS\sources\UIS_sources_02262020.dta", replace


*---------------------------------------------------------------------------------------------------------------------------------------------
clear
import excel using "$aux_data\UIS\sources\HH surveys metadata_UIS September release_ 2018.11.16.xlsx", firstrow sheet(Data)
ren *, lower
drop r s t
destring startofofficialschoolyearm endofofficialschoolyearmon, replace
gen country_uis=country
gen year=uisreferenceyear
*merge with iso code3
tab country
replace country="Bolivia, Plurinational States of" if country=="Bolivia"
replace country="Côte d'Ivoire" if country=="Cote d'Ivoire"
replace country="Democratic Rep. of the Congo" if country=="Democratic Republic of the Congo"
replace country="Lao People's Democratic Republic" if country=="Lao PDR"
replace country="The former Yugoslav Rep. of Macedonia" if country=="The former Yugoslav Republic of Macedonia"
replace country="Thailand" if country=="Thailand "
replace country="Turkmenistan" if country=="Turkmenistan "
merge m:1 country using "$aux_data\country_iso_codes_names.dta"
drop if _m==2
drop _m
drop country_name_dhs country_code_dhs country_name_mics country_name_WIDE
order country iso_code* survey year uisreferenceyear survey year 
save "$aux_data\UIS\sources\HH surveys metadata_UIS September release_2018.11.16.dta", replace
