*LFS first showoff

use "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\EU-LFS_indicators_25012022.dta", clear

*cleaaaaning

duplicates drop

drop if year <= 2013 

drop comp_higher_4yrs_2529 comp_higher_4yrs_3034 comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no

export delimited using "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS_indicators_for_WIDE.csv", replace