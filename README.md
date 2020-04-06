# WIDE

The main changes I made to the MICS code are to separate it into 4 parts: reading, cleaning, calculating variables and summarizing. At the same time, inside each of these parts I have tried to simplify the code as much as possible and to separate the logic from the data.  To do this, I introduced several Stata module commands that need to be installed and generated specific commands. On the other hand, I created auxiliary tables that, through a merge with the dataset, allow a systematic replacement of values in different variables (region, ethnicity, etc.). There was also a change in the organization of the data and the homogenization of the country names. The files for each country should be in a single folder and named as follows: country_yyyy_hl.dta. This makes it easier to read and join them into a single file.


## Reading

In this part the data of each country is read, variables are selected according to the mics dictionary where only those we are interested in keeping are included, the country and year_file variables are created, the names of variables and type are standardized.

Not always the same variable (according to its label) is called the same for different years or countries. The different names it takes are detailed in the dictionary and then in the standardization process they are renamed.

A part of the data cleaning is needed in the reading.do because it is necessary to obtain a single set of data with the same name of variables, thus reducing the amount of stored variables that occupy disk space but mainly occupy ram memory in reading and processing.

The new commands are:

**fs**: to simplify the append without the need to make a loop.

**sxpose**: to transpose the dictionary rows (variable names) to columns and stored them in a local macro. It is a trick to select variables from the master data without having to name the variables in the code.

**sdecode**: to decode variables in a systematic way and in one step. It is no longer necessary to generate a new variable and then apply the decode command to it to then delete the original variable and rename the new variable.

**cleanchars**: a compact way to replace special characters. It is included in the replace_characters.ado.


## Cleaning

In this part the values of the variables are standardized and for some variables the values are replaced according to the auxiliary tables. This includes: names of regions, names of religions, dates, ethnicities, years of education and durations.

- **catenate**: a simple way to concatenate strings variables


## Calculating

In this part the education variables are calculated by creating specific commands.


