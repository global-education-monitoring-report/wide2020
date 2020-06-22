* widetable4upload: program to create a  uploadable table
* Version 1.0
* June 2020

program define widetable4upload
    syntax, widetable_file(string) output_path(string)
	
    use "`output_path'/`widetable_path'", clear 
   	
    cd "`output_path'"
    tokenize `widetable_file', parse("_")
	local datetime "`2'"
	local datetime : subinstr local datetime ".dta" "" 
	
	*drop 
    save "`output_path'/widetable4upload_`datetime'.dta", replace
	export delimited "`output_path'/widetable4upload_`datetime'.csv", replace
	
end
