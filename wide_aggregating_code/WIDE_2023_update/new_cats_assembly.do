****FINAL ASSEMBLY OF NEW CATEGORIES AND NEW WIDE

import delimited "C:\Users\taiku\OneDrive - UNESCO\WIDE files\2023\WIDE_2023_06_03.csv", clear

append using "C:\Users\taiku\OneDrive - UNESCO\WIDE files\2023\new_categories_2023.dta"

drop disability_id

order v1 iso_code region_group income_group country survey year level grade category sex location wealth region ethnicity religion language disability hh_edu_head comp_prim_v2_m comp_lowsec_v2_m comp_upsec_v2_m comp_prim_1524_m comp_lowsec_1524_m comp_upsec_2029_m eduyears_2024_m edu2_2024_m edu4_2024_m eduout_prim_m eduout_lowsec_m eduout_upsec_m preschool_3_m preschool_1ybefore_m edu0_prim_m trans_prim_m trans_lowsec_m comp_higher_2yrs_2529_m comp_higher_4yrs_2529_m comp_higher_4yrs_3034_m attend_higher_1822_m overage2plus_m literacy_1524_m, first 

export delimited using "C:\Users\taiku\OneDrive - UNESCO\WIDE files\2023\WIDE_2023_08_03.csv", replace