* a program to extract the label names. a new variable that contains the labels of the variables  

preserve
if r(k) > r(N) set obs `r(k)'

local varlist `r(varlist)'

foreach new in newlist varname varlabel {
quietly generate str `new' = ""
}

local k 1
foreach var of varlist `varlist' {
local varlabel : variable label `var'
quietly replace varname = "`var'" in `k'
quietly replace varlabel = "`varlabel'" in `k'
local ++k
}


