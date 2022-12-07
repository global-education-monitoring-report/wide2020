* replace_many: program to replace several values in master data using an auxiliary table
* Version 2.0
* April 2020

program define replace_many

	args datafile varx vary keyvar1 keyvar2
		
	if "`keyvar1'" =="" {
    merge m:1 `varx' using `datafile' 
	drop if _merge == 2
	replace `varx' = `vary'[_n] if _merge == 3
	drop `vary' _merge
	}
	else if "`keyvar1'" !="" & "`keyvar2'" ==""{
	merge m:1 `keyvar1' `varx' using `datafile'
	drop if _merge == 2
	replace `varx' = `vary'[_n] if _merge == 3
	drop `vary' _merge
	}
	else if "`keyvar2'" !="" {
	merge m:1 `keyvar1' `keyvar2' `varx' using `datafile'
	drop if _merge == 2
	replace `varx' = `vary'[_n] if _merge == 3
	drop `vary' _merge
	}
	else {
		if "`datafile'" ==""{
		disp as error "must specify a datafile argument"
		}
		else if "`varx'" =="" {
		disp as error "must specify a varx argument"
		}
		else if "`vary'" =="" {
		disp as error "must specify a vary argument"
		}
		else {
		disp as error "must specify the arguments"
		}
	}

	
end
