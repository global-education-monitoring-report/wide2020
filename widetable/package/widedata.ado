* widedata: program to create a sql file from a the intermediate MICS and DHS dta files
* Version 1.0
* June 2020

program define widedata
    syntax, mics_data_path(string) dhs_data_path(string) output_path(string) [columns(string)]
	
    
    local today : di  %tdCY-N-D  daily("$S_DATE", "DMY")
    local time : di subinstr(c(current_time),":", "", .)
	local table_name widedata_`today'T`time'
	
	if ("`columns'" == ""){
        local columns location sex wealth region ethnicity religion hhweight comp_prim_aux comp_lowsec_aux comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no country_year iso_code3 year adjustment
    }
   
	if ("`columns'" == "all"){
        local columns *
    }
	
    use `columns' using "`mics_data_path'", clear 
    tempfile mics
    save `mics'
	
    use `columns' using "`dhs_data_path'", clear 
    append using `mics', force
	
    cd "`output_path'"
    tosql `columns', table("`table_name'")
	
end
