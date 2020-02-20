
global list1 d_origin d_gender d_sexual d_age d_religion d_disability d_other

*Madagascar LaoPDR SierraLeone  TheGambia


 set more off
 use "C:\Users\Rosa_V\Dropbox\WIDE\Data\MICS\Madagascar\mn.dta", clear
  ren *, lower
  keep hh1 hh2 ln mvt22* *age *disability mwelevel windex5 *weight mwm6y mwb4
  for X in any mvt22c mvt22d mvt22e mvt22f: cap gen X=.

 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)

 recode mvt22a (2=0) (8/9=.), gen(d_origin)
 recode mvt22b (2=0) (8/9=.), gen(d_gender)
 recode mvt22c (2=0) (8/9=.), gen(d_sexual)
 recode mvt22d (2=0) (8/9=.), gen(d_age)
 recode mvt22e (2=0) (8/9=.), gen(d_religion) 
 recode mvt22f (2=0) (8/9=.), gen(d_disability)
 recode mvt22x (2=0) (8/9=.), gen(d_other)
 
 cap ren mdisability disability
 cap clonevar men_disability=disability
 
 
 gen discrim=0
 for X in any $list1: replace discrim=1 if X==1
 replace discrim=. if d_origin==. & d_gender==. & d_sexual==. & d_age==. & d_religion==. & d_disability==. & d_other==.
 gen country="Madagascar"
 save "C:\Users\Rosa_V\Dropbox\WIDE\WIDE\WIDE_MICS\data\mics6\mn\Madagascar.dta", replace
 
 


 set more off
 use "C:\Users\Rosa_V\Desktop\WIDE\Data\MICS\Tunisia\mn.dta", clear
  ren *, lower
  keep hh1 hh2 ln mvt22* *age *disability mwelevel windex5 *weight mwm6y mwb4
  for X in any mvt22c mvt22d mvt22e mvt22f: cap gen X=.

 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)

 recode mvt22a (2=0) (8/9=.), gen(d_origin)
 recode mvt22b (2=0) (8/9=.), gen(d_gender)
 recode mvt22c (2=0) (8/9=.), gen(d_sexual)
 recode mvt22d (2=0) (8/9=.), gen(d_age)
 recode mvt22e (2=0) (8/9=.), gen(d_religion) 
 recode mvt22f (2=0) (8/9=.), gen(d_disability)
 recode mvt22x (2=0) (8/9=.), gen(d_other)
 
 cap ren mdisability disability
 
 gen discrim=0
 for X in any $list1: replace discrim=1 if X==1
 replace discrim=. if d_origin==. & d_gender==. & d_sexual==. & d_age==. & d_religion==. & d_disability==. & d_other==.
 gen country="Tunisia"
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\mn\Tunisia.dta", replace

 *************
 use "C:\Users\Rosa_V\Desktop\WIDE\Data\MICS\Suriname\mn.dta", clear
 ren *, lower
  keep hh1 hh2 ln mvt22* *age *disability mwelevel windex5 *weight mwm6y mwb4
  for X in any mvt22c mvt22d mvt22e mvt22f: cap gen X=.

 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)

 recode mvt22g (2=0) (8/9=.), gen(d_immig)
 recode mvt22h (2=0) (8/9=.), gen(d_ethn) 

 gen d_origin=0
 replace d_origin=1 if d_immig==1|d_ethn==1
 replace d_origin=. if d_immig==. & d_ethn==.
 drop d_immig d_ethn 
 
 recode mvt22b (2=0) (8/9=.), gen(d_gender)
 recode mvt22c (2=0) (8/9=.), gen(d_sexual)
 recode mvt22d (2=0) (8/9=.), gen(d_age)
 recode mvt22e (2=0) (8/9=.), gen(d_religion) 
 recode mvt22f (2=0) (8/9=.), gen(d_disability)
 recode mvt22x (2=0) (8/9=.), gen(d_other)
 
 cap ren mdisability disability
 
 gen discrim=0
 for X in any $list1: replace discrim=1 if X==1
 replace discrim=. if d_origin==. & d_gender==. & d_sexual==. & d_age==. & d_religion==. & d_disability==. & d_other==.
 gen country="Suriname"
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\mn\Suriname.dta", replace

********************** 
cd "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\mn\" 
 use Suriname.dta, clear
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

ren disability mdisability
merge 1:1 id using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\hl\Step_5.dta"
drop if _merge==2
* hl6=age
drop age
ren mwb4 age
drop year
egen year=median(mwm6y)
tab age disability, m
decode mdisability, gen(disability_st)
for X in any prim lowsec upsec: gen c_X="Completed X" if comp_X==1
for X in any prim lowsec upsec: replace c_X="Didn't complete X" if comp_X==0

save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\mn_data.dta", replace

use "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\mn_data.dta", clear

collapse (mean) d_* discrim [iw=mnweight], by(country year)
collapse (mean) d_* discrim [iw=mnweight] if age>=18 & age<=49, by(country year)

collapse (mean) d_* discrim [iw=mnweight] if age>=18 & age<=49, by(country year c_prim)
drop if c_prim==""

collapse (mean) d_* discrim [iw=mnweight] if age>=18 & age<=49, by(country year c_lowsec)
drop if c_lowsec==""

collapse (mean) d_* discrim [iw=mnweight] if age>=18 & age<=49, by(country year c_upsec)
drop if c_upsec==""



collapse (mean) d_* discrim [iw=mnweight], by(country year disability_st)  
drop if disability_st=="" 
br
br
 *append using "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch_module.dta"
