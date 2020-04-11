
* I define the path in a relative way, only indicating the repository folders 

global data_path "../WIDE/raw_data"

global aux_data_path "../WIDE/auxiliary_data/cleaning"

global aux_data_uis "../WIDE/auxiliary_data/UIS"

* READING EACH COUNTRY FILE AND APPENDING IN ONE FILE

mics_reading $data_path/dta $data_path/temporal $data_path/all $aux_data_path/mics_dictionary.csv  $aux_data_path/mics_rename.csv


* CLEANING THE DATASET (RECODING SEVERAL VARIABLES)

mics_cleaning $data_path/all/mics_reading.dta $aux_data_path  $aux_data_uis/duration_age/UIS_duration_age_25072018.dta $data_path/all/mics_cleaning.dta



* CALCULATING EDUCATION VARIABLES

compute_education_years

age_adjustment

compute_education_completion

compute_education_out
