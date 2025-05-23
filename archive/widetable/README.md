# WIDE

The goal of WIDE package is to generate the statistics WIDE table. 

## Description 

The `wide` package simplifies reading, cleaning and summarizing WIDE. The main function of the package, widetable, imports DHS and MICS files, standardizes them and calculates educational variables. Finally, education indicators (access and completion) are obtained for  each country and year of the survey, disaggregated by different variables of interest.
    
## Prerequisites 

You need to have the following commands installed: `catenate`, `fs`, `gtools`, `replacestrvar`, `encodefrom`, `rmfiles`, `sdecode`, `tosql`, `tuples` and `usespss`.

For example, to install the `fs` package you must run this line of code:
 
      ssc install fs

## Installation 

The ado files should be placed in the `c:\ado\personal\` folder and read by Stata from there. They should not be placed in the `c:\ado\plus\` folder (where packages downloaded from the Internet are located) because they may be deleted in an update.

When the package is hosted in a public repository, it can be installed directly from Stata. To install the latest version directly from Github, type in Stata:

    github install XXXX/widetable

You must have the github package installed to type it into Stata: `net install github, from ("https://haghish.github.io/github/")`. This way of installation is better than using the net command as it automatically installs the package's dependencies.

To update all files associated with widetable type:

    adoupdate widetable, update

During the installation, in addition to the ado-files, **auxiliary tables** are downloaded that are used in different functions and will be located in the same folder. 

These tables are used to standardize both MICS and DHS data. 

| Table   | Description |
|---------|-------------|
|dhs_dictionary_setcode | selects the variables in each country dataset, standardizes the names and recodes several variables|
|mics_dictionary_setcode | selects the variables in each country dataset, standardizes the names and recodes several variables|
|filenames | lists the file paths to be read |
|country_iso_codes_names | adds the iso code3 variable |
|country_survey_year_uis| fixes survey year | 
|current_school_year_MICS | fixes current school year |
|current_school_year_DHS |  fixes current school year |
|dhs_adjustment | adjusts dates  |
|dhs_interview_dates | adjusts dates |
|UIS_duration_age_* | adds levels duration  |
|month_start |  adds month start school|


## Usage

The documentation of the command is available after installation using:
        
    help widetable


## Raw data 

Using this package requires to download the data from each source, [DHS](https://dhsprogram.com/) and [MICS](https://mics.unicef.org/), from their website. You must register and login to have access to the datasets. 

In both cases, we download a zip file containing the datasets. In the case of MICS for each country and year, we have a file that we place in a folder with the name of the country and inside it a folder with the name of the year. The dataset keeps the original name (e.g. hl). As we download more datasets we add year folders for that country. The dataset is in 'sav' format and we convert it to 'dta' with the command `usespss`.

As a rule to write the name of the countries we define: 

- the first letter of the name will be capitalized. 
- if the name of the country consists of more than one word each must be capitalized unless one of them is "and".

We keep the DHS data the same way. We select the module Household Member Recode and in this case, there is the option to download them in different formats, we choose the option FL (Flat ASCII data).
The DHS filenames are more specific than the MICS filenames, e.g. HNPR61FL, where 'HN' is the country code, 'PR' is the survey module, '61' is the round, and 'FL' is the file format. From DHS it is also necessary to download the (IR) module and the (MR).

For the proper functioning of the package the folder structure should be as follows:

<img src="raw_data.png" width="320" />

## Example

The main function, `widetable`, has four mandatory arguments:

- source: indicates which source must use ('dhs','mics' or 'both'). The option 'both' includes the other two.
- step: indicates which process must run ('read', 'clean', 'calculate', 'summarize' or 'all'). The option 'all' includes all the above.
- data_path: indicates the raw data folder path.  
- output_path: indicates the output table folder path.

Defining the folder path, it is recommended to use slash (/) as separator instead of backslash (\\), regardless of the operating system. You can write the paths directly in the function or previously create a local macro:

    * Defines the path folder in a absolute way (replace the dots)
    local dpath /../WIDE/raw_data/
    local opath /../WIDE/output/
   
This is a basic example which shows you how to use the widetable function:

    widetable, source(both) step(all) data_path(`dpath') output_path(`opath')
    
The result is a table with the indicators that is saved in the 'output' folder in 'dta' and 'csv' format called 'WIDE_mmddyyyThhmmss', where *mm* refers to the month, *dd* to the day and *yyyy* refers to the year and *hhmmss** refers to the hour, minutes and second.    

Also, you can run the function without seeing the intermediate results by typing: 

      quitely widetable, source(both) step(all) data_path(`dpath') output_path(`opath')

It is also possible to define some **optional** arguments that allow to work on a reduced number of files.

- nf: default value is 300. With this value all MICS and DHS files are read. To test the function it is recommended to use a value lower than 10.
- country_name: to evaluate the function for a given country.
- country_year: to evaluate the function for a given year. It requires defining the 'country_name'

The arguments "nf", "country_name" and "country_year" are only used when step is "read". 

## Testing 

The `widetests` function allow us to test the results. There are 15 pre-set tests.

| nquery | Query description |
|----------|-------------------------|
|   1    | checks extreme values (completion) |
|   2    | checks extreme values (completion) |
|   3    | checks extreme values (completion) |
|   4    | checks extreme values (completion by age group) |
|   5    | checks extreme values (completion by age group) |
|   6    | checks extreme values (completion by age group) |
|   7    | checks extreme values (completion by age group) |
|   8    | checks extreme values (school gap) |
|   9    | checks extreme values (school gap) |
|   10    | checks extreme values (school gap) |
|   11    | checks extreme values (out of school by level) |
|   12    | checks extreme values (out of school by level) |
|   13    | compares among education levels within countries |
|   14    | compares among education levels within countries |
|   15    | checks intertemporal indicator variation by country |


To execute the query number 5:

    widetests, table(widetable) nquery(5)
    
Alternatively, it is possible to make these queries outside Stata is useful the "widetests.sql" file. 

## Intermediate output

The `widedata` function allow us to store the cleaned DHS and MICS microdata in an SQL file.

    * Defines the path folder in a absolute way (replace the dots)
    local mics ".../WIDE/output/MICS/data/mics_calculate.dta"
    local dhs  ".../WIDE/output/DHS/data/dhs_calculate.dta"
    local wide ".../WIDE/WIDE/output"

    widedata, mics_data_path(`mics') dhs_data_path(`dhs') output_path(`wide') columns("all")