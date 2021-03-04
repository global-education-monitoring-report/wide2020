* widetable: program to read and clean DHS and MICS files, calculate and summarize education indicators 
* Version 2.1
* May 2020

program define widetable
	syntax, source(string) step(string) data_path(string) output_path(string) [nf(integer 300) country_name(string) country_year(string) ]

	clear all
	* error message 
	if (`nf' < 1) {
		display as error "`nf' can not be less than 1"
		exit
	}
	if ("`source'" != "mics" & "`source'" != "dhs" & "`source'"  != "both") {
		display as error "‘source’ only can be 'mics', 'dhs' or 'both'"
		exit
	} 

	if ("`step'" != "read" & "`step'" != "clean" & "`step'" != "calculate" & "`step'" != "standardize" & "`step'" != "summarize" & "`step'" != "all") {
		display as error "‘step’ only can be 'read', 'clean', 'calculate', 'summarize' or 'all'"
		exit
	}
	if (`nf' != 300 & ("`country_name'" != "" | "`country_year'" != "")) {
		display as error "It is not possible to define ‘nf' and ‘country_name'/‘country_year' at the same time"
		exit
	}
	if ("`country_name'" == "" & "`country_year'" != "") {
		display as error "Define 'country_name' is required"
		exit
	}
	
	* run 
	if "`source'" == "both" {
		if "`step'" == "all" {
			
			mics_read `data_path' `output_path' `nf' `country_name' `country_year'
			mics_clean `output_path' 
			mics_calculate `output_path' 
			mics_summarize `output_path'
			
			dhs_read `data_path' `output_path' `nf' `country_name' `country_year'
			dhs_clean `output_path' 
			dhs_calculate `output_path' 
			dhs_summarize `output_path' 

			cd `output_path'/MICS
			local micsfilelist : dir . files "*.dta"
			local micsrecent : word `:list sizeof micsfilelist' of `micsfilelist'
			cd `output_path'/DHS
			local dhsfilelist : dir . files "*.dta"
			local dhsrecent : word `:list sizeof dhsfilelist' of `dhsfilelist'
			tokenize `dhsrecent', parse("_")
			local datetime "`5'"
			local datetime : subinstr local datetime ".dta" "" 
			
			use "`output_path'/MICS/`micsrecent'", clear
			append using "`output_path'/DHS/`dhsrecent'", force
			save "`output_path'/widetable_`datetime'.dta", replace
			export delimited "`output_path'/widetable_`datetime'.csv", replace
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `output_path' `nf' `country_name' `country_year'
			dhs_read `data_path' `output_path' `nf' `country_name' `country_year'
		}
		else if "`step'" == "clean" {
			mics_clean `output_path' 
			dhs_clean `output_path' 
		}
		else if "`step'" == "calculate" {
			mics_calculate `output_path' 
			dhs_calculate `output_path' 
		}
		else if "`step'" == "standardize" {
			mics_read `data_path' `output_path' `nf' `country_name' `country_year'
			mics_clean `output_path' 
			mics_standardize `output_path'
			
			dhs_read `data_path' `output_path' `nf' `country_name' `country_year'
			dhs_clean `output_path' 
			dhs_standardize `output_path' 
		}
		else if  "`step'" == "summarize" {
			mics_summarize `output_path'
			dhs_summarize `output_path'
						
			cd `output_path'/MICS
			local micsfilelist : dir . files "*.dta"
			local micsrecent : word `:list sizeof micsfilelist' of `micsfilelist'
			cd `output_path'/DHS
			local dhsfilelist : dir . files "*.dta"
			local dhsrecent : word `:list sizeof dhsfilelist' of `dhsfilelist'
			tokenize `dhsrecent', parse("_")
			local datetime "`5'"
			local datetime : subinstr local datetime ".dta" "" 
						
			use "`output_path'/MICS/`micsrecent'", clear
			append using "`output_path'/DHS/`dhsrecent'", force
			save "`output_path'/widetable_`datetime'.dta", replace
			export delimited "`output_path'/widetable_`datetime'.csv", replace
	
		}
		else {
			
		}
	}  
	else if "`source'" == "mics" {
		if "`step'" == "all" {
			mics_read `data_path' `output_path' `nf' `country_name' `country_year'
			mics_clean `output_path' 
			mics_calculate `output_path' 
			mics_summarize `output_path'
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `output_path' `nf' `country_name' `country_year'
		}
		else if "`step'" == "clean" {
			mics_clean `output_path' 
		}
		else if "`step'" == "calculate" {
			mics_calculate `output_path' 
		}
		else if "`step'" == "standardize" {
			mics_read `data_path' `output_path' `nf' `country_name' `country_year'
			mics_clean `output_path' 
			mics_standardize `output_path'
		}
		else if "`step'" == "summarize" {
			mics_summarize `output_path'
		}
		else {
			
		}
	}	
	else {
		if "`step'" == "all" {
			dhs_read `data_path' `output_path' `nf' `country_name' `country_year'
			dhs_clean `output_path' 
			dhs_calculate `output_path' 
			dhs_summarize `output_path'
		} 
		else if "`step'" == "read" {
			dhs_read `data_path'  `output_path' `nf' `country_name' `country_year'
		}
		else if "`step'" == "clean" {
			dhs_clean `output_path' 
		}
		else if "`step'" == "calculate" {
			dhs_calculate `output_path' 
		}
		else if "`step'" == "standardize" {
			dhs_read `data_path' `output_path' `nf' `country_name' `country_year'
			dhs_clean `output_path' 
			dhs_standardize `output_path' 
		}
		else if "`step'" == "summarize" {
			dhs_summarize `output_path'
		}
		else {
			
		}

	}
		
end    
