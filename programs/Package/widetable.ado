* widetable: program to read and clean DHS and MICS files, calculate and summarize education indicators 
* Version 1.0
* May 2020
* Syntax
*	source: indicates which source must use ("dhs","mics" or "both"). The option "both" includes the other two.
*	step: indicates which process must run ("read", "clean", "calculate", "summarize" or "all"). The option "all" includes all the above.
* Example
*	
* 
* 
* 
*

program define widetable
		syntax, [source(string) step(string) data_path(string) output_path(string)]

	* error message 
	if ("`source'" != "mics" & "`source'" != "dhs" & "`source'"  != "both") {
		display as error "‘source’ only could be 'mics', 'dhs' or 'both'"
	} 

	if "`step'" != "read" & "`step'" != "clean" & "`step'" != "calculate" & "`step'" != "summarize" & "`step'" != "all" {
		display as error "‘step’ only could be 'read', 'clean', 'calculate', 'summarize' or 'all'"
	}
 

	* run 
	if "`source'" == "both" {
		if "`step'" == "all" {
			
			mics_read `data_path' `table_path'
			mics_clean `data_path' `table_path'
			mics_calculate `data_path' `table_path'
			mics_summarize `data_path' `table_path' `output_path'
			
			dhs_read `data_path' `table_path'
			dhs_clean `data_path' `table_path'
			dhs_calculate `data_path' `table_path'
			dhs_summarize `data_path' `table_path' `output_path' 
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `table_path'
			dhs_read `data_path' `table_path'
		}
		else if "`step'" == "clean" {
			mics_clean `data_path' `table_path'
			dhs_clean `data_path' `table_path'
		}
		else if "`step'" == "calculate" {
			mics_calculate `data_path' `table_path'
			dhs_calculate `data_path' `table_path'
		}
		else if  "`step'" == "summarize" {
			mics_summarize `data_path' `table_path' `output_path'
			dhs_summarize `data_path' `table_path' `output_path'
		}
		else {
			
		}
	}  
	else if "`source'" == "mics" {
		if "`step'" == "all" {
			mics_read `data_path' `table_path'
			mics_clean `data_path' `table_path'
			mics_calculate `data_path' `table_path'
			mics_summarize `data_path' `table_path' `output_path'
		} 
		else if "`step'" == "read" {
			mics_read `data_path' `table_path'
		}
		else if "`step'" == "clean" {
			mics_clean `data_path' `table_path'
		}
		else if "`step'" == "calculate" {
			mics_calculate `data_path' `table_path'
		}
		else if "`step'" == "summarize" {
			mics_summarize `data_path' `table_path' `output_path'
		}
		else {
			
		}
	}	
	else {
		if "`step'" == "all" {
			dhs_read `data_path' `table_path'
			dhs_clean `data_path' `table_path'
			dhs_calculate `data_path' `table_path'
			dhs_summarize `data_path' `table_path' `output_path'
		} 
		else if "`step'" == "read" {
			dhs_read `data_path' `table_path'
		}
		else if "`step'" == "clean" {
			dhs_clean `data_path' `table_path'
		}
		else if "`step'" == "calculate" {
			dhs_calculate `data_path' `table_path'
		}
		else if "`step'" == "summarize" {
			dhs_summarize `data_path' `table_path' `output_path'
		}
		else {
			
		}

	}
		
end    
