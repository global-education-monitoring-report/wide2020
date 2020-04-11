
program define replace_many

	args datafile varx vary keyvar1 keyvar2
	*syntax	[anything]	[,	datafile varx vary keyvar1 keyvar2]			
	
	preserve
	import delimited `datafile' ,  varnames(1) encoding(UTF-8) clear
	keep `varx' `vary' `keyvar1' `keyvar2'
	drop if `varx' == "" | `varx' == .
	tempfile usefile
    qui save `usefile'
    local datafile `usefile'
    restore

	
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
