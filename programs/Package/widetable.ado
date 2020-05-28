* widetable: program to read and clean DHS and MICS files, calculate and summarize education indicators 
* Version 2.1
* May 2020

program define widetable
	syntax, source(string) step(string) data_path(string) output_path(string) [nf(integer 300) country_name(string) country_year(string) ]

	clear all
	* error message 
	if (`nf' < 2) {
		display as error "`nf' can not be less than 2"
		exit
	}
	if ("`source'" != "mics" & "`source'" != "dhs" & "`source'"  != "both") {
		display as error "‘source’ only can be 'mics', 'dhs' or 'both'"
		exit
	} 

	if ("`step'" != "read" & "`step'" != "clean" & "`step'" != "calculate" & "`step'" != "summarize" & "`step'" != "all") {
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
			
			mics_read `data_path' `nf' `country_name' `country_year'
			mics_clean `data_path' 
			mics_calculate `data_path' 
			mics_summarize `data_path' `output_path'
			
			dhs_read `data_path' `nf' `country_name' `country_year'
			dhs_clean `data_path' 
			dhs_calculate `data_path' 
			dhs_summarize `data_path' `output_path' 

			cd `output_path'/MICS
			local micsfilelist : dir . files "*.dta"
			local micssorted : list sort micsfilelist
			local micsrecent : word 1 of `micssorted'
			cd `output_path'/DHS
			local dhsfilelist : dir . files "*.dta"
			local dhssorted : list sort dhsfilelist
			local dhsrecent : word 1 of `dhssorted'
			tokenize `dhsrecent', parse("_")
			local date "`3'"
			local time "`5'"
			
			use "`output_path'/MICS/`micsrecent'", clear
			append using "`output_path'/DHS/`dhsrecent'", force
			save "`output_path'/widetable_`date'_`time'.dta", replace
			export delimited "`output_path'/widetable_`date'_`time'.csv", replace
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `nf' `country_name' `country_year'
			dhs_read `data_path' `nf' `country_name' `country_year'
		}
		else if "`step'" == "clean" {
			mics_clean `data_path' 
			dhs_clean `data_path' 
		}
		else if "`step'" == "calculate" {
			mics_calculate `data_path' 
			dhs_calculate `data_path' 
		}
		else if  "`step'" == "summarize" {
			mics_summarize `data_path' `output_path'
			dhs_summarize `data_path' `output_path'
						
			cd `output_path'/MICS
			local micsfilelist : dir . files "*.dta"
			local micssorted : list sort micsfilelist
			local micsrecent : word 1 of `micssorted'
			cd `output_path'/DHS
			local dhsfilelist : dir . files "*.dta"
			local dhssorted : list sort dhsfilelist
			local dhsrecent : word 1 of `dhssorted'
			tokenize `dhsrecent', parse("_")
			local date "`3'"
			local time "`5'"
			
			use "`output_path'/MICS/`micsrecent'", clear
			append using "`output_path'/DHS/`dhsrecent'", force
			save "`output_path'/widetable_`date'_`time'.dta", replace
			export delimited "`output_path'/widetable_`date'_`time'.csv", replace
	
		}
		else {
			
		}
	}  
	else if "`source'" == "mics" {
		if "`step'" == "all" {
			mics_read `data_path' `nf' `country_name' `country_year'
			mics_clean `data_path' 
			mics_calculate `data_path' 
			mics_summarize `data_path' `output_path'
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `nf' `country_name' `country_year'
		}
		else if "`step'" == "clean" {
			mics_clean `data_path' 
		}
		else if "`step'" == "calculate" {
			mics_calculate `data_path' 
		}
		else if "`step'" == "summarize" {
			mics_summarize `data_path' `output_path'
		}
		else {
			
		}
	}	
	else {
		if "`step'" == "all" {
			dhs_read `data_path' `nf' `country_name' `country_year'
			dhs_clean `data_path' 
			dhs_calculate `data_path' 
			dhs_summarize `data_path' `output_path'
		} 
		else if "`step'" == "read" {
			dhs_read `data_path'  `nf' `country_name' `country_year'
		}
		else if "`step'" == "clean" {
			dhs_clean `data_path' 
		}
		else if "`step'" == "calculate" {
			dhs_calculate `data_path' 
		}
		else if "`step'" == "summarize" {
			dhs_summarize `data_path' `output_path'
		}
		else {
			
		}

	}
		
end    
