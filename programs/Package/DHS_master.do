* I define the path in a relative way, only indicating the repository folders 

global data_path "../WIDE/raw_data/DHS"

global aux_data_path "../WIDE/auxiliary_data/cleaning"

global aux_data_uis "../WIDE/auxiliary_data/UIS"



* READING EACH COUNTRY FILE AND APPENDING IN ONE FILE
* input_path temporal_path output_path table1_path 

dhs_reading $data_path  $data_path/temporal $data_path/all $aux_data_path/dhs_dictionary.csv $aux_data_path/dhs_renamevars.csv

* alternative: if data is stored in different foldes 

dhs_reading $data_path/Part1 $data_path/temporal/Part1 $data_path/all/Part1 $aux_data_path/dhs_dictionary.csv $aux_data_path/dhs_renamevars.csv

dhs_reading $data_path/Part2 $data_path/temporal/Part2 $data_path/all/Part2 $aux_data_path/dhs_dictionary.csv $aux_data_path/dhs_renamevars.csv



* CLEANING THE DATASET (RECODING SEVERAL VARIABLES)

dhs_cleaning $data_path/all/dhs_reading.dta $aux_data_path $aux_data_uis/duration_age/UIS_duration_age_25072018.dta $data_path/all/dhs_cleaning.dta

* alternative: if data is stored in different foldes 

dhs_cleaning $data_path/all/Part1/dhs_reading.dta $aux_data_path $aux_data_uis/duration_age/UIS_duration_age_25072018.dta $data_path/all/Part1/dhs_cleaning.dta

dhs_cleaning $data_path/all/Part2/dhs_reading.dta $aux_data_path $aux_data_uis/duration_age/UIS_duration_age_25072018.dta $data_path/all/Part2/dhs_cleaning.dta



* CALCULATING EDUCATION VARIABLES

dhs_education_years $data_path/all/dhs_cleaning.dta  $data_path/all/dhs_educvar.dta

* age adjustment

dhs_age_adjustment "$data_dhs/cleaning.dta" $aux_data\temp\current_school_year_DHS.dta "$aux_data_uis/months_school_year/month_start.dta"

* completion

dhs_education_completion $data_path/all/dhs_educvar.dta $data_path/all/dhs_educvar.dta 

dhs_education_out $data_path/all/dhs_educvar.dta  $aux_data/UIS/duration_age/UIS_duration_age_25072018.dta

* CREATING AN SQL FILE

dta_tosql $data_path/all/dhs_educvar.dta dhs *
* dta_tosql $data_path/all/dhs_educvar.dta dhs cluster age


dhs_summary
