***********recoding FS

**# Choosing what surveys to RUN

clear 
 use "C:\ado\personal\repository_inventory.dta"
 *drop if iso=="FJI"
 drop if iso=="LAO" //doesnt have disability in FS 
  drop if iso=="THA" //doesnt have disability in FS 
    *drop if iso=="NPL" //problem with ed level NEED RECODE 


  keep if roundmics==6
 *keep if iso=="BLR"
 levelsof fullname, local(mics6surveys)
 
 display `mics6surveys'
 *whatever name of the local put the local name in the next loop 
 
**# Run program on surveys
 

local dpath "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
local opath "C:\Users\taiku\Desktop\temporary_std"
*set trace on
foreach survey of local mics6surveys {
		tokenize "`survey'", parse(_)
		disability_MICS_FS,  data_path(`dpath') output_path(`opath') country_code("`1'") country_year("`3'") 
		cd "C:\Users\taiku\Desktop\temporary_disability\indicators"
		save "FS_disability_`1'_`3'_MICS.dta"	, replace 
}

**# Append FS results


local files : dir "C:\Users\taiku\Desktop\temporary_disability\indicators" files "*.dta"
    foreach file in `files' {
        append using `file'
    }
	
	
save "C:\Users\taiku\Desktop\temporary_disability\disability_MICS_FS_full.dta"


**# Part 1 tweaks

use "C:\Users\taiku\Desktop\temporary_disability\disability_MICS_FS_full.dta", clear


global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 overage2plus eduout_prim eduout_lowsec eduout_upsec edu0_prim


* Eliminate those with less than 30 obs
	foreach var of varlist $varlist_m  {
			replace `var' = . if `var'_no < 30
			rename `var' `var'_m, replace
	}
	
*just keeping the categories Manos wants

/*
drop if category=="rawdisability" & rawdisability==""
drop if category=="disability_essentialdomains" & disability_essentialdomains==""
drop if category=="sex rawdisability" & rawdisability==""
drop if category=="sex disability_essentialdomains" & disability_essentialdomains==""
*/

gen iso_code=""
replace iso_code="DZA" if country=="Algeria"
replace iso_code="ARG" if country=="Argentina"
replace iso_code="BGD" if country=="Bangladesh"
replace iso_code="BLR" if country=="Belarus"
replace iso_code="CAF" if country=="CentralAfricanRepublic"
replace iso_code="TCD" if country=="Chad"
replace iso_code="CRI" if country=="CostaRica"
replace iso_code="CUB" if country=="Cuba"
replace iso_code="COD" if country=="DRCongo"
replace iso_code="DOM" if country=="DominicanRepublic"
replace iso_code="FJI" if country=="Fiji"
replace iso_code="GMB" if country=="Gambia"
replace iso_code="GEO" if country=="Georgia"
replace iso_code="GHA" if country=="Ghana"
replace iso_code="GNB" if country=="Guinea-Bissau"
replace iso_code="GUY" if country=="Guyana"
replace iso_code="HND" if country=="Honduras"
replace iso_code="IRQ" if country=="Iraq"
replace iso_code="KIR" if country=="Kiribati"
replace iso_code="KGZ" if country=="Kyrgyzstan"
replace iso_code="LSO" if country=="Lesotho"
replace iso_code="MDG" if country=="Madagascar"
replace iso_code="MWI" if country=="Malawi"
replace iso_code="MNG" if country=="Mongolia"
replace iso_code="MNE" if country=="Montenegro"
replace iso_code="NPL" if country=="Nepal"
replace iso_code="NGA" if country=="Nigeria"
replace iso_code="PSE" if country=="Palestine"
replace iso_code="WSM" if country=="Samoa"
replace iso_code="STP" if country=="SaoTomeandPrincipe"
replace iso_code="SRB" if country=="Serbia"
replace iso_code="SLE" if country=="SierraLeone"
replace iso_code="SUR" if country=="Suriname"
replace iso_code="MKD" if country=="TFYRMacedonia"
replace iso_code="TGO" if country=="Togo"
replace iso_code="TON" if country=="Tonga"
replace iso_code="TUN" if country=="Tunisia"
replace iso_code="TKM" if country=="Turkmenistan"
replace iso_code="TCA" if country=="Turks and Caicos Islands"
replace iso_code="TUV" if country=="Tuvalu"
replace iso_code="UZB" if country=="Uzbekistan"
replace iso_code="VNM" if country=="VietNam"
replace iso_code="ZWE" if country=="Zimbabwe"
 
 
 order year country category fsdisability disability_trad_fs sex iso_code, first
 
 *just keeping the categories Manos wants
 sdecode disability_trad_fs, replace
keep if fsdisability=="At least one functional difficulty" | disability_trad_fs=="At least one sensory, physical or intellectual difficulty"

*get rid of two definitions into one variable

gen disability = fsdisability
replace disability=disability_trad_fs if disability==""

 order year country category fsdisability disability_trad_fs disability  sex iso_code, first
 
   
 *Fix categories
 
 
 replace category = "Disability" if category=="disability_trad_fs" | category=="fsdisability"
  replace category = "Disability & Sex" if category=="sex disability_trad_fs" | category=="sex fsdisability"

 
*drop 
drop fsdisability disability_trad_fs

gen survey="MICS"

save "C:\Users\taiku\Desktop\temporary_disability\disability_part1.dta", replace

**# Fix what came out from R from CH and ADULT 

*now need to add these

import delimited "C:\Users\taiku\Desktop\temporary_sum\widetable_summarized_2023_disability_CH_adult.csv", clear

gen iso_code=""
replace iso_code="DZA" if country=="Algeria"
replace iso_code="ARG" if country=="Argentina"
replace iso_code="BGD" if country=="Bangladesh"
replace iso_code="BLR" if country=="Belarus"
replace iso_code="CAF" if country=="CentralAfricanRepublic"
replace iso_code="TCD" if country=="Chad"
replace iso_code="CRI" if country=="CostaRica"
replace iso_code="CUB" if country=="Cuba"
replace iso_code="COD" if country=="DRCongo"
replace iso_code="DOM" if country=="DominicanRepublic"
replace iso_code="FJI" if country=="Fiji"
replace iso_code="GMB" if country=="Gambia"
replace iso_code="GEO" if country=="Georgia"
replace iso_code="GHA" if country=="Ghana"
replace iso_code="GNB" if country=="Guinea-Bissau"
replace iso_code="GUY" if country=="Guyana"
replace iso_code="HND" if country=="Honduras"
replace iso_code="IRQ" if country=="Iraq"
replace iso_code="KIR" if country=="Kiribati"
replace iso_code="KGZ" if country=="Kyrgyzstan"
replace iso_code="LSO" if country=="Lesotho"
replace iso_code="LAO" if country=="LaoPDR"

replace iso_code="MDG" if country=="Madagascar"
replace iso_code="MWI" if country=="Malawi"
replace iso_code="MNG" if country=="Mongolia"
replace iso_code="MNE" if country=="Montenegro"
replace iso_code="NPL" if country=="Nepal"
replace iso_code="NGA" if country=="Nigeria"
replace iso_code="PSE" if country=="Palestine"
replace iso_code="WSM" if country=="Samoa"
replace iso_code="STP" if country=="SaoTomeandPrincipe"
replace iso_code="SRB" if country=="Serbia"
replace iso_code="SLE" if country=="SierraLeone"
replace iso_code="SUR" if country=="Suriname"
replace iso_code="MKD" if country=="TFYRMacedonia"
replace iso_code="TGO" if country=="Togo"
replace iso_code="TON" if country=="Tonga"
replace iso_code="TUN" if country=="Tunisia"
replace iso_code="TKM" if country=="Turkmenistan"
replace iso_code="TCA" if country=="Turks and Caicos Islands"
replace iso_code="TUV" if country=="Tuvalu"
replace iso_code="UZB" if country=="Uzbekistan"
replace iso_code="VNM" if country=="VietNam"
replace iso_code="ZWE" if country=="Zimbabwe"
 

global varlist_m preschool_3 attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 comp_lowsec_1524 comp_prim_1524 comp_upsec_2029 comp_upsec_v2 edu4_2024 eduyears_2024 literacy_1524 comp_lowsec_v2

set trace on
* Eliminate those with less than 30 obs
	foreach var in $varlist_m  {
					replace `var'_m = . if `var'_no < 30
	}
	set trace off
	
*get rid of combinations we dont need

drop if cat=="Cdisability & Disability_trad_ch" | cat == "Disability & Disability_trad_adults" | cat=="Sex" | cat=="Total"

*fix category names
replace cat = "Disability" if cat=="Cdisability" | cat=="Disability" | cat=="Disability_trad_adults" | cat=="Disability_trad_ch"

replace category = "Disability & Sex" if cat=="Cdisability & Sex" | cat=="Disability & Sex" | cat=="Disability_trad_adults & Sex" | cat=="Disability_trad_ch & Sex"

*fix disability variable with all labels

replace disability=disability_trad_ch  if disability_trad_ch!="" & disability==""
replace disability=disabilityx  if disabilityx!="" & disability==""
replace disability=disability_trad_adults  if disability_trad_adults!="" & disability==""
replace disability=disabilityy  if disabilityy!="" & disability==""

*there's still missings for disability, so we get rid of those 
drop if disability=="" & disability_trad_ch=="" & disabilityx=="" & disability_trad_adults=="" & disabilityy==""

drop disability_trad_ch disabilityx disability_trad_adults disabilityy

  *just keeping the categories Manos wants
keep if disability=="At least one functional difficulty" | disability=="At least one sensory, physical or intellectual difficulty"

drop v1 x

*fix duplicates issue 
collapse (firstnm) preschool_3_m preschool_3_no attend_higher_1822_m comp_higher_2yrs_2529_m comp_higher_4yrs_2529_m comp_higher_4yrs_3034_m comp_lowsec_1524_m comp_prim_1524_m comp_upsec_2029_m comp_upsec_v2_m edu4_2024_m eduyears_2024_m literacy_1524_m attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no comp_lowsec_1524_no comp_prim_1524_no comp_upsec_2029_no comp_upsec_v2_no edu4_2024_no eduyears_2024_no literacy_1524_no comp_lowsec_v2_m comp_lowsec_v2_no ,by (iso_code survey year category disability sex)

save "C:\Users\taiku\Desktop\temporary_disability\disability_part2.dta", replace

**# Fix hh_education 

import delimited "C:\Users\taiku\Desktop\multiproposito\widetable_summarized_hh-edu-WIDE.csv", clear


drop hh_edu_adult hh_edu_mother

global varlist_m attend_higher attend_higher_1822 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_higher_4yrs_3034 comp_lowsec_1524 comp_lowsec_v2 comp_prim_1524 comp_prim_v2 comp_upsec_2029 comp_upsec_v2 edu0_prim edu4_2024 eduout_lowsec eduout_prim eduout_upsec eduyears_2024 overage2plus preschool_1ybefore preschool_3 literacy_1524

set trace on
* Eliminate those with less than 30 obs
	foreach var in $varlist_m  {
					replace `var'_m = . if `var'_no < 30
	}
	set trace off
	
	gen iso_code=""
replace iso_code="DZA" if country=="Algeria"
replace iso_code="ARG" if country=="Argentina"
replace iso_code="BGD" if country=="Bangladesh"
replace iso_code="BLR" if country=="Belarus"
replace iso_code="CAF" if country=="CentralAfricanRepublic"
replace iso_code="TCD" if country=="Chad"
replace iso_code="CRI" if country=="CostaRica"
replace iso_code="CUB" if country=="Cuba"
replace iso_code="COD" if country=="DRCongo"
replace iso_code="DOM" if country=="DominicanRepublic"
replace iso_code="FJI" if country=="Fiji"
replace iso_code="GMB" if country=="Gambia"
replace iso_code="GEO" if country=="Georgia"
replace iso_code="GHA" if country=="Ghana"
replace iso_code="GNB" if country=="Guinea-Bissau"
replace iso_code="GUY" if country=="Guyana"
replace iso_code="HND" if country=="Honduras"
replace iso_code="IRQ" if country=="Iraq"
replace iso_code="KIR" if country=="Kiribati"
replace iso_code="KGZ" if country=="Kyrgyzstan"
replace iso_code="LAO" if country=="LaoPDR"
replace iso_code="LSO" if country=="Lesotho"
replace iso_code="MDG" if country=="Madagascar"
replace iso_code="MWI" if country=="Malawi"
replace iso_code="MNG" if country=="Mongolia"
replace iso_code="MNE" if country=="Montenegro"
replace iso_code="NPL" if country=="Nepal"
replace iso_code="NGA" if country=="Nigeria"
replace iso_code="PSE" if country=="Palestine"
replace iso_code="WSM" if country=="Samoa"
replace iso_code="STP" if country=="SaoTomeandPrincipe"
replace iso_code="SRB" if country=="Serbia"
replace iso_code="SLE" if country=="SierraLeone"
replace iso_code="SUR" if country=="Suriname"
replace iso_code="MKD" if country=="TFYRMacedonia"
replace iso_code="TGO" if country=="Togo"
replace iso_code="TON" if country=="Tonga"
replace iso_code="TUN" if country=="Tunisia"
replace iso_code="TKM" if country=="Turkmenistan"
replace iso_code="TCA" if country=="Turks and Caicos Islands"
replace iso_code="TUV" if country=="Tuvalu"
replace iso_code="UZB" if country=="Uzbekistan"
replace iso_code="VNM" if country=="VietNam"
replace iso_code="ZWE" if country=="Zimbabwe"
 
replace cat="Household education"

drop v1 x

save "C:\Users\taiku\Desktop\temporary_disability\hh_edu_part3.dta", replace

***merge the new categories 

use "C:\Users\taiku\Desktop\temporary_disability\disability_part1.dta", clear

/*
duplicates report  iso survey year category disability sex
duplicates tag   iso survey year category disability sex, gen(dups)
sort  iso survey year category disability sex
br if dups==1
*/

duplicates drop iso survey year category disability sex, force

destring year, replace
 
 merge 1:1 iso survey year category disability sex using "C:\Users\taiku\Desktop\temporary_disability\disability_part2.dta", gen(disas)
 
 *need to fix the country names 
 
append  using  "C:\Users\taiku\Desktop\temporary_disability\hh_edu_part3.dta", gen(headdd)

 
 replace attend_higher_1822_m = attend_higher_m if attend_higher_1822_m==. & attend_higher_m!=.
 replace attend_higher_1822_no = attend_higher_no if attend_higher_1822_no==. & attend_higher_no!=.

 
  drop disas headdd
  drop attend_higher_no attend_higher_m
  
  drop country
  
  merge m:1 iso_code using "C:\Users\taiku\OneDrive - UNESCO\WIDE files\2023\country_names_key.dta"
  
  drop if _merge==2
  
  replace country="Turks and Caicos Islands" if iso=="TCA"
  replace country="Tuvalu" if iso=="TUV"
 replace country="Samoa" if iso=="WSM"
 
 drop _merge 
  
  save "C:\Users\taiku\OneDrive - UNESCO\WIDE files\2023\new_categories_2023.dta", replace
  export delimited using "C:\Users\Lenovo PC\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\WIDE_2023_files\newcategories_2023.csv", replace
  
