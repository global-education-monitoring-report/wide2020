* widetable: program to read and clean DHS and MICS files, calculate and summarize education indicators 
* Version 2.0
* May 2020


program define widetable
	syntax, source(string) step(string) data_path(string) output_path(string) [nf(integer 300)]

	
	* error message 
	if (`nf' < 2) {
		display as error "`nf' no puede ser menor a 2"
	}
	if ("`source'" != "mics" & "`source'" != "dhs" & "`source'"  != "both") {
		display as error "‘source’ only could be 'mics', 'dhs' or 'both'"
	} 

	if "`step'" != "read" & "`step'" != "clean" & "`step'" != "calculate" & "`step'" != "summarize" & "`step'" != "all" {
		display as error "‘step’ only could be 'read', 'clean', 'calculate', 'summarize' or 'all'"
	}
 

	* run 
	if "`source'" == "both" {
		if "`step'" == "all" {
			
			mics_read `data_path' `nf'
			mics_clean `data_path' 
			mics_calculate `data_path' 
			mics_summarize `data_path' `output_path'
			
			dhs_read `data_path' `nf'
			dhs_clean `data_path' 
			dhs_calculate `data_path' 
			dhs_summarize `data_path' `output_path' 
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `nf'
			dhs_read `data_path' `nf'
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
		}
		else {
			
		}
	}  
	else if "`source'" == "mics" {
		if "`step'" == "all" {
			mics_read `data_path' `nf'
			mics_clean `data_path' 
			mics_calculate `data_path' 
			mics_summarize `data_path' `output_path'
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `nf'
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
			dhs_read `data_path' `nf'
			dhs_clean `data_path' 
			dhs_calculate `data_path' 
			dhs_summarize `data_path' `output_path'
		} 
		else if "`step'" == "read" {
			dhs_read `data_path'  `nf'
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
