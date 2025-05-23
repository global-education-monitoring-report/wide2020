{smcl}
{* *! version 1.0 19 May 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "widetests##syntax"}{...}
{viewerjumpto "Description" "widetests##description"}{...}
{viewerjumpto "Options" "widetests##options"}{...}
{viewerjumpto "Remarks" "widetests##remarks"}{...}
{viewerjumpto "Examples" "widetests##examples"}{...}
{title:widetests}
{phang}
{bf:widetests} {hline 2} tests the results of widetable function using a series of SQL queries.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:widetests}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required }
{synopt:{opt table(string)}} Table name {p_end}
{synopt:{opt nquery(#)}}  Test number to be run. Default value is 1.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt table(string)}    {p_end}
{phang}
{opt nquery(#)}    {p_end}


{marker examples}{...}
{title:Examples}
{pstd}

   . widetests table(tablename) nquery(1)
{title:Author}
{p}


