*THE WEALTH ISSUE 

import delimited "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Datasets\AUT_2016_LFS\AT2016_y.csv"
tab hhlink
tab hhlink incdecil
tab hhlink incdecil, m

*incdecil with missing recode
gen incdecil2=incdecil if incdecil!=99
tab hhlink incdecil2, m


 bysort hhid: egen refpersondecil = total(incdecil2) if hhlink==1

 *wrong!
 bysort hhnum : egen refpersondecil = total(incdecil2) if hhlink==1
tab refpersondecil

*correct!
 bysort qhhnum : egen refpersondecil2 = total(incdecil2) if hhlink==1
 bysort qhhnum : egen whatiwant = total(refpersondecil2)
 
 
br qhhnum hhnum hhseqnum sex hhnbpers hhlink incdecil2 refpersondecil2 whatiwant
tab whatiwant
tab incdecil

 bysort qhhnum : egen sumallpeople = total(incdecil2) , missing
tab age
tab sumallpeople


tab whatiwant if age<35 , m
gen flag problem = 1 if whatiwant==0 & age<35
gen kidiwswnoinfo = 1 if whatiwant==0 & age<35
br qhhnum hhnum hhseqnum sex hhnbpers hhlink incdecil2 whatiwant kids if sumallpeople==.
br qhhnum hhnum hhseqnum sex hhnbpers hhlink incdecil2 whatiwant kidi if sumallpeople==.
tab kidi
tab hhnbwork if kidi==1
tab ilo if kidi==1
br qhhnum hhnum hhseqnum sex hhnbpers hhlink incdecil2 whatiwant kidi if sumallpeople==.
tab whatiwant

*only those employed have incdecil
tab incdecil2 ilostat
tab incdecil2 main
tab incdecil2 stapro

tab stapro
tab wstat
tab wstator
tab incdecil if age<35
tab kidiw
tab hat97lev if kidiw==.
tab hatlev1d
tab hat97lev
tab hat11lev
tab hat11lev if kidi==1
tab hat11lev if kidi==.
tab kidi

rename kidiwsnoinfo nowealthinfo
rename kidiwswnoinfo nowealthinfo
replace nowealthinfo=0 if whatiwant!=0 & age<35
by nowealthinfo: tab hat11lev
bysort nowealthinfo: tab hat11lev
bysort nowealthinfo: tab hat11lev if hat11lev!=999
bysort nowealthinfo: tab hat11lev if hat11lev!=999 [aw=coeff]
tab educstat
bysort nowealthinfo: tab educstat
bysort nowealthinfo: tab hhnum
bysort nowealthinfo: tab hhnbpers
bysort nowealthinfo: tab hhnbpers if hhnbpers<8
tab hhlink if age<35
bysort nowealthinfo: tab hhnbpers if hhnbpers<5
bysort nowealthinfo: tab hhnbpers if hhnbpers<6
tab whatiwant if age<35
gen refpersonwealth=whatiwant if whatiwant!=0
tab refpersonwealth if age < 35, m
tab incdecil if age < 35
tab incdecil if age < 35
bysort nowealthinfo: tab hhnbpers
tab hatlfath
tab hatlmoth
tab hatlmoth if age<35
tab hhnbpers
tab hhnbpers if age < 35
tab hhnbpers noweal if age < 35
bysort nowealth: tab hhnbpers  if age < 35