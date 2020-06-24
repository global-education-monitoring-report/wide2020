* widetable4upload: program to create a  uploadable table
* Version 1.0
* June 2020

program define widetable4upload
    syntax, widetable_file(string) output_path(string)
	
    use "`output_path'/`widetable_file'", clear 
   	
    cd "`output_path'"
    tokenize `widetable_file', parse("_")
	local datetime "`3'"
	local datetime : subinstr local datetime ".dta" "" 
	
	drop if inlist(ethnicity, "Missing", "Doesn't answer", "Don't know", "Don't know/No response") | inlist(religion, "Missing", "Doesn't answer", "Don't know", "Don't know/No response")
    
    save "`output_path'/widetable4upload_`datetime'.dta", replace
	export delimited "`output_path'/widetable4upload_`datetime'.csv", replace
	
end
