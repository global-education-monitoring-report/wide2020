
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
cap var_exists ethnicity hc1c ethnicity if country == "Mali" & year_file == 2009
cap var_exists hh6 hh6a hh6
*cap var_exists hh7 hh6b hh7
cap var_exists region hh7 hh7
cap var_exists hhweight hlweight hhweight
cap var_exists religion hc1a religion if country == "Panama" & year_file == 2013
cap var_exists religion hl15 religion if country == "TrinidadandTobago" & year_file == 2011
cap var_exists windex5 windex5_5 windex5
cap var_exists windex5 windex5_1 windex5

end
