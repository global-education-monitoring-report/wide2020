global gral_dir "C:\Users\Rosa_V\Dropbox\WIDE"
global data_mics6 "$gral_dir\WIDE\WIDE_MICS\data\mics6"

global list1 d_origin d_gender d_sexual d_age d_religion d_disability d_other

*LaoPDR SierraLeone  TheGambia
foreach country in Iraq KyrgyzRepublic Tunisia LaoPDR SierraLeone Suriname TheGambia Madagascar {
 set more off
 use "$gral_dir\Data\MICS\\`country'\wm.dta", clear
  ren *, lower
  for X in any a b c d e f x : cap gen vt22X=.
  cap gen disability=.
  keep hh1 hh2 ln vt22* *age *disability welevel windex5 *weight cm1 ceb wm6y wb4 wb14 wm6y 
  gen country="`country'"
 
 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)

 cap recode vt22g (2=0) (8/9=.), gen(d_immig) // for Suriname
 cap recode vt22h (2=0) (8/9=.), gen(d_ethn)  // for Suriname

 
 cap gen d_origin=0 if (d_immig==. | d_ethn==.)
 cap replace d_origin=1 if (d_immig==1|d_ethn==1) & d_origin==0
 
 cap drop d_immig d_ethn 
 
 cap recode vt22a (2=0) (8/9=.), gen(d_origin)
 cap recode vt22b (2=0) (8/9=.), gen(d_gender)
 cap recode vt22c (2=0) (8/9=.), gen(d_sexual)
 cap recode vt22d (2=0) (8/9=.), gen(d_age)
 cap recode vt22e (2=0) (8/9=.), gen(d_religion) 
 cap recode vt22f (2=0) (8/9=.), gen(d_disability)
 cap recode vt22x (2=0) (8/9=.), gen(d_other)
 
 cap ren mdisability disability
 cap clonevar women_disability=disability
 
 
 gen discrim=0
 for X in any $list1: replace discrim=1 if X==1
 replace discrim=. if d_origin==. & d_gender==. & d_sexual==. & d_age==. & d_religion==. & d_disability==. & d_other==.

 for X in any wb14 welevel: cap gen X=.
 for X in any wb14 welevel: cap gen code_X=X
 for X in any wb14 welevel: cap decode X, gen(temp_X)
 drop wb14 welevel
 for X in any wb14 welevel: cap ren temp_X X
 compress
 save "$data_mics6\wm\\`country'.dta", replace
}
***********************************************

cd "$data_mics6\wm\" 
local allfiles : dir . files "*.dta"
use "Iraq.dta", clear
gen id_c=1
foreach f of local allfiles {
	qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c
gen c=1 if country=="Iraq"
replace c=2 if country=="KyrgyzRepublic" 
replace c=3 if country=="LaoPDR" 
replace c=4 if country=="SierraLeone" 
replace c=5 if country=="Suriname" 
replace c=6 if country=="TheGambia" 
replace c=7 if country=="Tunisia"

ren disability wdisability
keep country code* welevel hh1 hh2 ln wb4 *weight wm6y
ren wb4 age
gen sex="Female"
gen survey="MICS"
gen round_mics="mics6"
gen year=wm6y
bys country: egen year_median=median(year)
save "$data_mics6/mics6_wm_literacy.dta", replace



***********************************************
***********************************************
 
cd "$data_mics6\wm\" 
 use Iraq.dta, clear
 append using KyrgyzRepublic.dta
 append using Suriname.dta
 append using Tunisia.dta
 
 
gen c=1 if country=="Iraq"
replace c=2 if country=="KyrgyzRepublic" 
replace c=3 if country=="LaoPDR" 
replace c=4 if country=="SierraLeone" 
replace c=5 if country=="Suriname" 
replace c=6 if country=="TheGambia" 
replace c=7 if country=="Tunisia"

gen id2=string(c)+" "+id
drop id
ren id2 id
lookfor weight

ren disability wdisability
merge 1:1 id using "$data_mics6\hl\Step_5.dta"
drop if _merge==2
*ren hl6 age
drop age
ren wb4 age

drop year
egen year=median(wm6y)

tab age disability, m
decode wdisability, gen(disability_st)
for X in any prim lowsec upsec: gen c_X="Completed X" if comp_X==1
for X in any prim lowsec upsec: replace c_X="Didn't complete X" if comp_X==0

save "$data_mics6\wm_data.dta", replace

use "$data_mics6\wm_data.dta", clear

collapse (mean) d_* discrim [iw=wmweight], by(country year)

collapse (mean) d_* discrim [iw=wmweight] if age>=18 & age<=49, by(country year)

collapse (mean) d_* discrim [iw=wmweight] if age>=18 & age<=49, by(country year c_prim)
drop if c_prim==""

collapse (mean) d_* discrim [iw=wmweight] if age>=18 & age<=49, by(country year c_lowsec)
drop if c_lowsec==""

collapse (mean) d_* discrim [iw=wmweight] if age>=18 & age<=49, by(country year c_upsec)
drop if c_upsec==""

collapse (mean) d_* discrim [iw=wmweight], by(country year disability_st)  
drop if disability_st=="" 
br
br
 *append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch_module.dta"
