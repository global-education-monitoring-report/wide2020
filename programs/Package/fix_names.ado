
program define fix_names
	

*remove underscore from original variable name
cap rename *_* **

*choose a variable and drop the other and rename
cap var_exists ed4a ed4ap ed4a
cap var_exists ed4b ed4bp ed4b
cap var_exists ed6a ed6n  ed6a
cap var_exists ed6b ed6c  ed6b
cap var_exists ed6a ed6ap ed6a
cap var_exists ed6b ed6bp ed6b
cap var_exists ethnicity hc1c ethnicity
cap var_exists hh6 hh6a hh6
cap var_exists hh7 hh6b hh7
cap var_exists region hh7a hh7
*cap var_exists hh7 hh7a hh7
*cap if !missing(hh7) 	   & !missing(region)    drop hh7
*cap if !missing(hh8)       & !missing(region)    drop hh8
cap var_exists hhweight hlweight hhweight
cap var_exists religion hc1a religion
cap var_exists religion hl15 religion
cap var_exists windex5 windex5_5 windex5
cap var_exists windex5 windex5_1 windex5

end
