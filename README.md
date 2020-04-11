# WIDE

The main changes I made to the MICS code are to separate it into 4 parts: reading, cleaning, calculating variables and summarizing. At the same time, inside each of these parts I have tried to simplify the code as much as possible and to separate the logic from the data. To do this, I introduced several Stata module commands that need to be installed and generated specific commands that I named with an underscore. On the other hand, I created auxiliary tables that, through a merge with the dataset, allow a systematic replacement of values in different variables (region, ethnicity, etc.). There was also a change in the organization of the data and the homogenization of the country names. The files for each country should be in a single folder and named as follows: country_yyyy_hl.dta. This makes it easier to read and join them into a single file. For those countries whose name contains more than one word, the first letter of each is capitalized without leaving any space between the words.

The 'cleaning' folder contains the auxiliary tables: 

- country_iso_codes_names.csv: to add the iso code3 variable
- mics_dictionary.csv: to select the variables in each country dataset and to standardize the names
- mics_changes_duration_stage.csv
- mics_fix_date.csv 
- mics_fix_ethnicity.csv
- mics_fix_region.csv
- mics_fix_religion.csv
- mics_recode_edulevel.csv
- mics_group_eduyears.csv
- mics_rename.csv
- mics_setcode.csv
- dhs_fixes_ethnicity.csv
- dhs_fix_regions.csv
- dhs_fix_religion.csv
- dhs_fix_year.csv


The "Package" folder contains the master do-file (MICS_master.do) and the ado-files created. Thus, **mics_reading.ado** is the program that reads the data and standardizes to obtain a single dataset. While **mics_cleaning.ado** is the program that fixs values in different variables. These programs use other ado-files that do specific tasks.



## Reading

In this part the data of each country is read, variables are selected according to the mics dictionary where only those we are interested in keeping are included, the country and year_file variables are created, the names of variables and type are standardized.

Not always the same variable (according to its label) is called the same for different years or countries. The different names it takes are detailed in the dictionary and then in the standardization process they are renamed.

A part of the data cleaning is needed in the reading.do because it is necessary to obtain a single set of data with the same name of variables, thus reducing the amount of stored variables that occupy disk space but mainly occupy ram memory in reading and processing.

The new commands are:

**fs**: to simplify the append without the need to make a loop.

**sxpose**: to transpose the dictionary rows (variable names) to columns and stored them in a local macro. It is a trick to select variables from the master data without having to name the variables in the code.

**sdecode**: to decode variables in a systematic way and in one step. It is no longer necessary to generate a new variable and then apply the decode command to it to then delete the original variable and rename the new variable.

**cleanchars**: a compact way to replace special characters. It is included in the replace_characters.ado.

**catenate**: a simple way to concatenate strings variables

## Cleaning

In this part the values of the variables are standardized and for some variables the values are replaced according to the auxiliary tables. This includes: region, religion, date, ethnicity, urban, sex, year, original education variables. 

To simplify replacing one value with another, I created the *replace_many* function that replaces a "master" dataset value with a "using" dataset value as long as certain variables match. 

**replace_many**: to replace at once many values.


## Calculating

In this part the education variables are calculated by creating specific commands.

**compute_education_years**: to calculate the years of education

