{smcl}
{* *! version 1.0 15 May 2020}{...}
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
{bf:widetable} generates the statistics WIDE table

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:widetable}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt source(string)}} indicates which source must use ("dhs","mics" or "both"). The option "both" includes the other two.  It is mandatory. {p_end}
{synopt:{opt step(string)}} indicates which process must run ("read", "clean", "calculate", "summarize" or "all"). The option "all" includes all the above.  It is mandatory. {p_end}
{synopt:{opt data_path(string)}} indicates the raw data folder path. It is mandatory. {p_end}
{synopt:{opt output_path(string)}} indicates the output table folder path. It is mandatory. {p_end}
{synopt:{opt nf(#)}}  Default value is 300.{p_end}
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
{opt source(string)}    {p_end}
{phang}
{opt step(string)}    {p_end}
{phang}
{opt data_path(string)}    {p_end}
{phang}
{opt output_path(string)}    {p_end}
{phang}
{opt nf(#)}    {p_end}


{marker examples}{...}
{title:Examples}
{pstd}


{title:Author}
{p}


