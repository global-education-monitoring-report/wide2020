{smcl}
{* *! version 1.0 17 May 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "widetable##syntax"}{...}
{viewerjumpto "Description" "widetable##description"}{...}
{viewerjumpto "Options" "widetable##options"}{...}
{viewerjumpto "Remarks" "widetable##remarks"}{...}
{viewerjumpto "Examples" "widetable##examples"}{...}
{title:widetable}
{phang}
{bf:widetable} {hline 2} generates the statistics WIDE table. The main function of the package, widetable, imports DHS and MICS files, standardizes them and calculates educational variables. Finally, education indicators (access and completion) are obtained for each country and year of the survey, disaggregated by different variables of interest.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:widetable}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required }
{synopt:{opt source(string)}} indicates which source must use ("dhs","mics" or "both"). The option "both" includes the other two.  It is mandatory.  {p_end}
{synopt:{opt step(string)}} indicates which process must run ("read", "clean", "calculate", "summarize" or "all"). The option "all" includes all the above.  It is mandatory. {p_end}
{synopt:{opt data_path(string)}} indicates the raw data folder path. It is mandatory. {p_end}
{synopt:{opt output_path(string)}} indicates the output table folder path. It is mandatory. {p_end}
{syntab:Optional}
{synopt:{opt nf(#)}}  Default value is 300.  All MICS and DHS files are read. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{bf:widetable} simplifies reading, cleaning and summarizing WIDE. The main function of the package, widetable, imports DHS and MICS files, standardizes them and calculates educational variables. Finally, education indicators (access and completion) are obtained for each country and year of the survey, disaggregated by different variables of interest. 

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt nf(#)}    {p_end}
{phang}
{opt source(string)}    {p_end}
{phang}
{opt step(string)}    {p_end}
{phang}
{opt data_path(string)}    {p_end}
{phang}
{opt output_path(string)}    {p_end}


{marker examples}{...}
{title:Examples}
{pstd}
This is a basic example which shows you how to use the widetable function. Defining the folder path, it is recommended to use slash (/) as separator instead of backslash (\), regardless of the operating system. You can write the paths directly in the function or previously create a local macro:

{p 4 4 2}{bf:defines the path folder in a absolute way (replace the dots)}

	.local dpath /../WIDE/raw_data/
	.local opath /../WIDE/raw_data/output

{p 4 4 2}{bf:generates the WIDE table from all countries, years and sources}

	.widetable, source(both) step(all) data_path(`dpath') output_path(`opath') 

{p 4 4 2}
The result is a table with the indicators that is saved in the 'output' folder in 'dta' and 'csv' format called 'WIDE_mmddyyy', where mm refers to the month, dd to the day and yyyy refers to the year.

{p 4 4 2}{bf:generates the WIDE table from all countries and years using MICS files}

	.widetable, source(mics) step(all) data_path(`dpath') output_path(`opath')
 
{p 4 4 2}{bf:generates the WIDE table from all countries and years using DHS files}
 
	.widetable, source(dhs) step(all) data_path(`dpath') output_path(`opath') 

{p 4 4 2}
For a development stage it is useful to test the sub-functions that make up widetable. This is also useful if you have a PC with few resources. For example: 

	.widetable, source(mics) step(read) data_path(`dpath') output_path(`opath') 

	.widetable, source(mics) step(clean) data_path(`dpath') output_path(`opath') 

	.widetable, source(mics) step(calculate) data_path(`dpath') output_path(`opath') 

	.widetable, source(mics) step(summarize) data_path(`dpath') output_path(`opath') 

{p 4 4 2}
To test the function it is recommended to use a value lower than 50.

	.widetable, source(mics) step(read) data_path(`dpath') output_path(`opath') nf(50)


{title:Author}
{p}


