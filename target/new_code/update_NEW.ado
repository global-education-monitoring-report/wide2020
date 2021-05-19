************************************************
***********MICS UPDATE**************************
************14-05-2021**************************

*******************************************************************
*This new module follows a new logic
*TO ONLY UPDATE NEW DATASETS, ON A SEQUENTIAL BASIS****************
*******************************************************************

global raw_path "C:\WIDE\1_raw_data"
global std_path "C:\WIDE\2_standardised_data"

**FIRST STEP: SCAN THE RAW DATA directory and get a list of survey IDs
local raw_list : dir global raw_path dirs "*"

**SECOND STEP: SCAN THE STANDARDIZED directory and get a list of survey IDS
local done_list : dir global std_path dirs "*"

**THIRD STEP: generate a new list of surveys to be processed
local process_list : list raw_list - done_list


**Now call standardize SEQUENTIALLY

foreach survey of local process_list {
         di "Now processing" " `survey'"
         
         local script_path : concat(`std_path' `survey' ".do"), punct(/)
         local in_path : concat(`raw_path' `survey'), punct(/)
         local out_path : : concat(`std_path' `survey'), punct(/)

         split filename, p(_)
         rename filename1 country
         rename filename2 year
         rename filename3 survey
		
		 cd in_path
         *** "<survey>.do" processes a single survey and can assume all necessary files are in the working directory
         do `script_path' country year survey

         cd out_path
         save "std_`survey'.dta"
		 clear
     }