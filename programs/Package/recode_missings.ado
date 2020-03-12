* recode_missings: program to recode the missing values, not applicable, dont know and non-response
* Version 1.0

program define replace_character
	syntax varlist(min=1), 
	
	foreach var of varlist `varlist' {
		
	* Question not applicable
	replace 97 = .a
	
	* Dont know
	replace "don't know" = .b
	replace 98 = .b
	
	* Missing
	replace 99 = .
	replace "missing" = .
  }
  
end
	
