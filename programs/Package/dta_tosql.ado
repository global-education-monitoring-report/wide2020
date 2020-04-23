* dta_tosql: program to create a sql file from a dta file
* Version 1.0
* April 2020

program define dta_tosql
	args input_path table_name columns
	

	use "`input_path'", clear 
	
	tosql `columns', table(`table_name')

end
