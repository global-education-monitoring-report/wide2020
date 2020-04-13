
* I define the path in a relative way, only indicating the repository folders 

global data_path "../WIDE/raw_data"

global aux_data_path "../WIDE/auxiliary_data/cleaning"

global aux_data_uis "../WIDE/auxiliary_data/UIS"

* READING EACH COUNTRY FILE AND APPENDING IN ONE FILE

mics_reading $data_path/dta $data_path/temporal $data_path/all $aux_data_path/mics_dictionary.csv  $aux_data_path/mics_rename.csv


* CLEANING THE DATASET (RECODING SEVERAL VARIABLES)

mics_cleaning $data_path/all/mics_reading.dta $aux_data_path  $aux_data_uis/duration_age/UIS_duration_age_25072018.dta $data_path/all/mics_cleaning.dta



* CALCULATING EDUCATION VARIABLES

* input_path table_path output_path
mics_education_years $data_path/all/mics_cleaning.dta  $aux_data_path/mics_group_eduyears $data_path/all/mics_educvar.dta

* input_path table1_path table2_path output_path
mics_age_adjustment $data_path/all/mics_educvar.dta "$aux_data\temp\current_school_year_MICS.dta" $aux_data_uis/months_school_year/month_start.dta $data_path/all/mics_educvar.dta

mics_education_completion $data_path/all/mics_educvar.dta $data_path/all/mics_educvar.dta 

mics_education_out $data_path/all/mics_educvar.dta  $aux_data\UIS\duration_age\UIS_duration_age_25072018.dta
