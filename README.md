# WIDE

The goal of WIDE package is to generate the statistics WIDE tables.

## Description 


## Prerequisites 

You need to have the following commands installed: `catenate`, `fs`, `odbc`, `replacestrvar`, `rename`, `sdecode`, `sxpose` and `tosql`.

For example, to install the `fs` package you must run this line of code:
 
      ssc install fs

## Raw data 

The use of this package requires that the data from each source (DHS and MICS) be in a specific folder. In particular, MICS files should not have a generic name, the one that comes with the download, but should be called by the country name, the year and "hl" that identifies the corresponding base. If the name of the country consists of more than one word each must be capitalized, unless one of them is "and".


<img src="filenames.png" width="350" />

## Installation 

The ado files should be placed in the `c:\ado\personal\` folder and read by Stata from there. They should not be placed in the `c:\ado\plus\` folder (where packages downloaded from the Internet are located) because they may be deleted in an update.


## Example