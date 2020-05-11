# WIDE

The goal of WIDE package is to generate the statistics WIDE tables.

## Description 


## Prerequisites 

You need to have the following commands installed: `catenate`, `fs`, `ftools`, `moremata`, `odbc`, `replacestrvar`, `renamefrom`, `sdecode`, `sxpose`, `tosql` and `usespss`.

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
The DHS filenames are more specific than the MICS filenames, e.g. HNPR61FL, where 'HN' is the country code, 'PR' is the survey module, '61' is the round, and 'FL' is the file format.

<img src="raw_data.png" width="320" />

## Auxiliary data

In addition to the raw data, different auxiliary tables are used to standardize both MICS and DHS data. 

| Table   | Description |
|---------|-------------|
|country_iso_codes_names | adds the iso code3 variable |
|dictionary_setcode | selects the variables in each country dataset, standardizes the names and recodes several variables|
|filenams | lists the file paths to be read |

The files corresponding to these auxiliary tables should be organized according to the following diagram:


## Example

This is a basic example which shows you how to use this package:


    * Defines the path folder in a relative way
    global data_path_mics "../WIDE/raw_data/MICS"
    global data_path_dhs "../WIDE/raw_data/DHS"
    global aux_data_path "../WIDE/auxiliary_data/"

    * Calls the functions
    mics $data_path_mics $aux_data_path 
    dhs $data_path_dhs $aux_data_path 

