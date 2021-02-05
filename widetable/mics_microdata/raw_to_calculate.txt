### WIDE - Converting into Micro Data from Raw Data using STATA and R ### 
@ Date: Dec 14, 2020
@ Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

1. Place all the codes and auxiliary files (.do and .ado) in your STATA personal directory. Note that this directory is different by user's computer. 
You can check the directory by typing "sysdir" in the command prompt. 
For instance, for Mac users, it will look like this "/Users/username/Documents/Stata/ado/personal/".

2. Adjust the Excel file "filenames.xlsx" in the above directory depending on the countries you want to process. 
If you don't want to process some countries, remove that from the list. 

3. Open a new "Do-file Editor" in STATA and run "RawToCalculate.do" file commands. 
If you encounter any error in the results prompt, debug or comment out (i.e. //) in the .ado file (e.g. mics_read.ado).
Make sure to run "wide table, source ..." code with directories code "local path ..." together! Otherwise it will show an error (e.g. data_path() required). You can also copy and paste code in the STATA Command terminal and run.   

4. Check whether output files are well generated. 

5. To change the micro data variables, edit directly in the .ado files (i.e. mics_read.ado / mics_clean.ado / mics_calculate.ado / mics_summarize.ado / wide_table.ado) from the STATA/ado/personal directory mentioned above. 
Note that mics_calculate.dta is the data result to be used for micro data. 

6. To change the survey (e.g. into DHS), change the "source" in the STATA code into "source(dhs)".

7. To extract/add variables from the mics_calculate.dta, run "mics_calculate_micro.R" file. You can select and/or add specific variables in this code. 

8. Change the name of the micro data file into "surveyname_iso_year.csv" (e.g. MICS_AFG_2010.csv).
