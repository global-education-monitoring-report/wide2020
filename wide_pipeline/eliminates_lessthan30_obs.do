
local varlist_m attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 comp_lowsec_1524 comp_lowsec_v2 comp_prim_1524 comp_prim_v2 comp_upsec_2029 comp_upsec_v2 edu0_prim edu4_2024 eduout_lowsec eduout_prim eduout_upsec eduyears_2024 literacy_1524 overage2plus

set trace on
foreach var of local varlist_m {
			replace `var'_m = . if `var'_no < 30
	}
	set trace off