# WIDE

The goal of WIDE package is to generate the statistics WIDE tables.

## Description 

The main function of the package, widetable, imports DHS and MICS files, standardizes them and calculates educational variables. Finally, education indicators are obtained for each country and year of the survey, disaggregated by different variables of interest.

## Prerequisites 

You need to have the following commands installed: `catenate`, `fs`, `ftools`, `gtools` `moremata`, `odbc`, `replacestrvar`, `renamefrom`, `sdecode`, `tosql`, `tuples` and `usespss`.

For example, to install the `fs` package you must run this line of code:
 
      ssc install fs


To fix the `ftools` error "fcollapse fails with string by variables" try running

         ftools, compile 
     
and then 

        clear all

The `fcollapse` function (from `ftools`) requires the `moremata` package for some the median and percentile stats.


## Installation 

The ado files should be placed in the `c:\ado\personal\` folder and read by Stata from there. They should not be placed in the `c:\ado\plus\` folder (where packages downloaded from the Internet are located) because they may be deleted in an update.

## Raw data 

Using this package requires to download the data from each source, [DHS](https://dhsprogram.com/) and [MICS](https://mics.unicef.org/), from their website. You must register and login to have access to the datasets. 

In both cases, we download a zip file containing the datasets. In the case of MICS for each country and year, we have a file that we place in a folder with the name of the country and inside it a folder with the name of the year. The dataset keeps the original name (e.g. hl). As we download more datasets we add year folders for that country. The dataset is in 'sav' format and we convert it to 'dta' with the command `usespss`.

As a rule to write the name of the countries we define: 

- the first letter of the name will be capitalized. 
- if the name of the country consists of more than one word each must be capitalized unless one of them is "and".

We keep the DHS data the same way. We select the module Household Member Recode and in this case, there is the option to download them in different formats, we choose the option FL (Flat ASCII data).
The DHS filenames are more specific than the MICS filenames, e.g. HNPR61FL, where 'HN' is the country code, 'PR' is the survey module, '61' is the round, and 'FL' is the file format. From DHS it is also necessary to download the (IR) module and the (MR).

<img src="raw_data.png" width="320" />

## Auxiliary data

In addition to the raw data, different auxiliary tables are used to standardize both MICS and DHS data. 

| Table   | Description |
|---------|-------------|
|country_iso_codes_names | adds the iso code3 variable |
|dictionary_setcode | selects the variables in each country dataset, standardizes the names and recodes several variables|
|filenames | lists the file paths to be read |

The files corresponding to these auxiliary tables should be organized according to the following diagram:

<img src="auxiliary_data.png" width="350" />

## Example

The main function is widetable and have five arguments:

- source: indicates which source must use ('dhs','mics' or 'both'). The option 'both' includes the other two.
- step: indicates which process must run ('read', 'clean', 'calculate', 'summarize' or 'all'). The option 'all' includes all the above.

You can write the paths directly in the function or previously create a local or global macro. For example, if you use a local macro: 

    * Defines the path folder in a absolute way (replace the dots)
    local data_path ../WIDE/raw_data/
    local table_path ../WIDE/auxiliary_data/
    local data_output ../WIDE/raw_data/output
    
This is a basic example which shows you how to use the widetable function:

    widetable "both" "all" `data_path' `table_path' `output_path'
    
    
    
    

