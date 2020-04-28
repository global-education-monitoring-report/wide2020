
* I define the path in a relative way, only indicating the repository folders 
global data_path "../WIDE/raw_data/MICS"
global aux_data_path "../WIDE/auxiliary_data/"

* READING EACH COUNTRY FILE AND APPENDING IN ONE FILE
mics_read $data_path $aux_data_path 

* CLEANING THE DATASET (RECODING SEVERAL VARIABLES)
mics_clean $data_path $aux_data_path 

* CALCULATING EDUCATION VARIABLES
mics_education_years $data_path  $aux_data_path 

mics_education_completion $data_path 

mics_age_adjustment $data_path $aux_data_path 

mics_education_out $data_path  $aux_data

* CALCULATING SUMMARY TABLES 
mics_summary $data_path $aux_data_path 
