* I define the path in a relative way, only indicating the repository folders 

global data_path "../WIDE/raw_data/DHS"

global aux_data_path "../WIDE/auxiliary_data/cleaning"

global aux_data_uis "../WIDE/auxiliary_data/UIS"

* READING EACH COUNTRY FILE AND APPENDING IN ONE FILE

dhs_reading

* CLEANING THE DATASET (RECODING SEVERAL VARIABLES)

dhs_cleaning "$data_dhs/reading.dta"  "$aux_data_uis/duration_age/UIS_duration_age_25072018.dta" "$data_dhs/cleaning.dta"


* CALCULATING EDUCATION VARIABLES
