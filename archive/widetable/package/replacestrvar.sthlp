{smcl}
{* *! version 1.0  march2015}{...}
{vieweralsosee "matchit (if installed)" "help matchit"}{...}
{vieweralsosee "freqindex (if installed)" "help freqindex"}{...}
{vieweralsosee "cleanchars (if installed)" "help cleanchars"}{...}
{viewerjumpto "Syntax" "replacestrvar##syntax"}{...}
{viewerjumpto "Description" "replacestrvar##description"}{...}
{viewerjumpto "Options" "replacestrvar##options"}{...}
{viewerjumpto "Examples" "replacestrvar##examples"}{...}
{marker Top}{...}
{title:Title}

{p2colset 2 18 20 2}{...}
{p2col :replacestrvar {hline 1}} 
Replaces in one or more variables each instance of a list of texts 
by the desired text{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 5 15}
{cmd:replacestrvar} {it: {help varlist}} , {opt r:eplist(string)} [{it:options}]
{p_end}


{synoptset 22 tabbed}{...}
{syntab :}
{synopthdr}
{synoptline}
{synopt :{opt r:eplist(string)}}
String or list of strings to be sought within each observation of {help varlist}. 
In the case of a list of strings, the replacement is performed 
for each instance of each string in the list.
This option is required. 
{p_end}

{synopt :{opt w:ithstr(string)}}
String to replace with within each observation of {help varlist}
where the string sought was found. 
Default is "", which erases each instance of the string sought.
{p_end}

{synopt :{opt g:enerate(newvarname)}}
Generates a new variable for each variable in {help varlist} where the string replacement occurs,
leaving the selected {help varlist} unmodified.
If omitted, the default is to replace on the selected {help varlist}.
If {help varlist} contains more than one variable, 
{it:newvarname} is used as prefix for each new variable.
{p_end}

{synopt :{opt w:ord}}
Replaces words instead of strings. 
In other terms, if replacing "is" by "X" in "This is this" will return "This X this" when 
using {it:word} and "ThX X thX" by default.
{p_end}

{synopt :{opt qui:etly}}
Prevents Stata from providing detailed output on the results of each string replacements,
which is the default.
{p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:replacestrvar} replaces each instance of a string (or list of strings) 
within a variable (or list of variables) with a given string. 
{p_end}

{pstd}
It is meant to assist the cleaning of string variables, 
making it a complementary tool to {help matchit} and {help freqindex}
(if installed).
{p_end}

{pstd}
Please, note that {cmd:replacestrvar} is case-sensitive and takes into account 
all other symbols (as far as Stata does).
{p_end}

{marker examples}{...}
{title:Examples:}

{pstd}Removes puntuation marks from {it:mytxtvar}{p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r(". , ; : ! ?") 

{pstd}Removes numbers from {it:mytxtvar}{p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("0 1 2 3 4 5 6 7 8 9")

{pstd}Replaces accentuated or similar characters {p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("á ā ä â ã") w("a"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("é č ę ë") w("e"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("í ė î ï") w("i"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("ó ō õ ô ö ø") w("o"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("ú ų û ü") w("u"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("į"') w("c"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("ß"') w("s"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("ý"') w("y"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("æ"') w("ae"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r(""') w("oe"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("Ð"') w("D"){p_end}
{phang2}{cmd:. replacestrvar} {it:mytxtvar}, r("ņ"') w("n"){p_end}

{pstd}Removes a list characters {p_end}
{phang2}{cmd:. local} mylist / < > + = - _ [ ] { } | \ ' @ # $ % ^ & "*" ( ) /// {p_end}
{phang2} Ą ē ģ Ī Ž ž ― ū Ū þ Ŧ ŧ Ž ī ķ ð Đ ĩ ŋ  ą  â  {p_end}
{phang2} {cmd:. replacestrvar} {it:mytxtvar}, r(`"`mylist'"') {p_end}

