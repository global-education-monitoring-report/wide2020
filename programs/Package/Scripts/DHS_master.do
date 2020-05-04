* I define the path in a relative way, only indicating the repository folders 

global data_path "../WIDE/raw_data/DHS"

global aux_data_path "../WIDE/auxiliary_data"


* READING EACH COUNTRY FILE AND APPENDING IN ONE FILE

dhs_read $data_path  $aux_data_path

* alternative: if data is stored in different foldes 

*dhs_read $data_path/Part1 $aux_data_path
*dhs_read $data_path/Part2 $aux_data_path


* CLEANING THE DATASET (RECODING SEVERAL VARIABLES)

dhs_clean $data_path $aux_data_path 

* alternative: if data is stored in different folders 

*dhs_clean $data_path/Part1 $aux_data_path 

*dhs_clean $data_path/Part2 $aux_data_path 


* CALCULATING EDUCATION VARIABLES

dhs_education_years $data_path

* age adjustment

dhs_age_adjustment $data_path $aux_data_path 

* completion

dhs_education_completion $data_path

dhs_education_out $data_path  $aux_data_path

* CREATING AN SQL FILE (we can load a few variables from a stata file, this could be enough without making a sql query)

*dta_tosql $data_path/all/dhs_educvar.dta dhs *
* dta_tosql $data_path/all/dhs_educvar.dta dhs cluster age


dhs_summary $data_path $aux_data_path
