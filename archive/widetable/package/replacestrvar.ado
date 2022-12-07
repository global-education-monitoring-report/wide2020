*! version 1.1 J.D. Raffo May 2016
program replacestrvar
 version 12
 syntax varlist(string) [if] ///
   , Replist(string) [Generate(string) Withstr(string) Tag(string) Word] 

 // setup //////////////////////////////////////
 if ("`word'"=="") local subfunc subinstr
 else local subfunc subinword
 
 if ("`tag'"!="" & "`generate'"!="") {
  di "Invalid syntax. Generate and Tag cannot be selected at the same time."
  exit
  }
 // programs starts
 preserve
 tokenize `varlist'
 foreach curvar of var `varlist' {
  if ("`tag'"!="") {
   cap confirm variable `tag'
   if !_rc local generate `tag'
  } 
  if ("`generate'"!=""){
   if ("`2'"=="") local repvarname `generate'
   else local repvarname `generate'`curvar'
   qui gen `repvarname'=`curvar' `if'
  }
  else local repvarname `curvar'
  local mylist `replist'
  foreach symbol of local mylist {
   di `"`curvar': replacing `symbol' with `withstr' "' _continue 
   replace `repvarname'=`subfunc'(`repvarname',"`symbol'","`withstr'",.) `if'
  }
 }
 restore, not
end
