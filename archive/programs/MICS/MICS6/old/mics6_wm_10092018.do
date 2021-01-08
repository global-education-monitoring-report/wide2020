
global list1 d_origin d_gender d_sexual d_age d_religion d_disability d_other

*LaoPDR SierraLeone  TheGambia
foreach country in Iraq KyrgyzRepublic Tunisia {
 set more off
 use "C:\Users\Rosa_V\Desktop\WIDE\Data\MICS\\`country'\wm.dta", clear
  ren *, lower
  keep hh1 hh2 ln vt22* *age *disability welevel windex5 *weight cm1 ceb wm6y wb4 wb14
  for X in any vt22c vt22d vt22e vt22f: cap gen X=.

 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)

 recode vt22a (2=0) (8/9=.), gen(d_origin)
 recode vt22b (2=0) (8/9=.), gen(d_gender)
 recode vt22c (2=0) (8/9=.), gen(d_sexual)
 recode vt22d (2=0) (8/9=.), gen(d_age)
 recode vt22e (2=0) (8/9=.), gen(d_religion) 
 recode vt22f (2=0) (8/9=.), gen(d_disability)
 recode vt22x (2=0) (8/9=.), gen(d_other)
 
 cap ren mdisability disability
 
 gen discrim=0
 for X in any $list1: replace discrim=1 if X==1
 replace discrim=. if d_origin==. & d_gender==. & d_sexual==. & d_age==. & d_religion==. & d_disability==. & d_other==.
 gen country="`country'"
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\wm\\`country'.dta", replace
}
*************
 use "C:\Users\Rosa_V\Desktop\WIDE\Data\MICS\Suriname\wm.dta", clear
  ren *, lower
  keep hh1 hh2 ln vt22* *age *disability welevel windex5 *weight cm1 ceb wm6y wb4  wb14


 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)

 recode vt22g (2=0) (8/9=.), gen(d_immig)
 recode vt22h (2=0) (8/9=.), gen(d_ethn) 

 gen d_origin=0
 replace d_origin=1 if d_immig==1|d_ethn==1
 replace d_origin=. if d_immig==. & d_ethn==.
 drop d_immig d_ethn 
 
 recode vt22b (2=0) (8/9=.), gen(d_gender)
 recode vt22c (2=0) (8/9=.), gen(d_sexual)
 recode vt22d (2=0) (8/9=.), gen(d_age)
 recode vt22e (2=0) (8/9=.), gen(d_religion) 
 recode vt22f (2=0) (8/9=.), gen(d_disability)
 recode vt22x (2=0) (8/9=.), gen(d_other)
 
 cap ren mdisability disability
 
 gen discrim=0
 for X in any $list1: replace discrim=1 if X==1
 replace discrim=. if d_origin==. & d_gender==. & d_sexual==. & d_age==. & d_religion==. & d_disability==. & d_other==.
 gen country="Suriname"
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\wm\Suriname.dta", replace

********************** 
cd "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\wm\" 
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
merge 1:1 id using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\hl\Step_5.dta"
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

save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\wm_data.dta", replace

use "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\wm_data.dta", clear

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
