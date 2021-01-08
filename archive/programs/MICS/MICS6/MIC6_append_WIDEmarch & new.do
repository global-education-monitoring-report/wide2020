use "C:\Users\Rosa_V\Downloads\WIDE_All_2019-03-22.dta", clear
keep if category=="Total"
keep if iso_code=="IRQ"|iso_code=="KGZ"|iso_code=="LAO"|iso_code=="SLE"|iso_code=="SUR"|iso_code=="GMB"|iso_code=="TUN"
drop if survey=="PISA"|survey=="TIMSS"
keep iso_code3 country survey year comp_prim_v2_m comp_lowsec_v2_m comp_upsec_v2_m eduout_prim_m eduout_lowsec_m eduout_upsec_m

foreach var in comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 eduout_prim eduout_lowsec eduout_upsec {
	ren `var'_m `var'
}


append using "C:\Users\Rosa_V\Desktop\MICS6\data\indicators_mics6.dta" 
sort iso year
