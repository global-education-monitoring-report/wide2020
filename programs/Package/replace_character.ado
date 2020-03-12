* replace_character: program to replace several characters and accents 
* Version 1.0

program define replace_character
	syntax varlist(min=1), 
	
	foreach var of varlist `varlist' {
	replace `var' = subinstr(`var', "-", " ",.) 
	replace `var' = subinstr(`var', "ă", "a",.)
	replace `var' = subinstr(`var', "ŕ", "a",.)
	replace `var' = subinstr(`var', "ĂĄ", "a",.)
	replace `var' = subinstr(`var', "ĂŁ", "a",.)
	replace `var' = subinstr(`var', "ĂŠ", "e",.)
	replace `var' = subinstr(`var', "Ă¨", "e",.)
	replace `var' = subinstr(`var', "č", "e",.)
	replace `var' = subinstr(`var', "ń", "n",.) 
	replace `var' = subinstr(`var', "á", "a",.)
	replace `var' = subinstr(`var', "à", "a",.)
	replace `var' = subinstr(`var', "è", "e",.)
	replace `var' = subinstr(`var', "é", "e",.)
	replace `var' = subinstr(`var', "í", "i",.)
	replace `var' = subinstr(`var', "ó", "o",.)
	replace `var' = subinstr(`var', "ú", "u",.)
  }
end
	
