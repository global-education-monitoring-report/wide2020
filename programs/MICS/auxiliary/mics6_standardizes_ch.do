 ren *, lower
 for X in any region psu strata caretakerdis: cap gen X=.
 keep hh1 hh2 uf1 uf7y uf17 ub6 ub7 ub8 ucf* hh6 region hl4 ed5a ed5b cage cage_6 cage_11 caged cdisability caretakerdis *weight windex5 psu strata ec6-ec15
 
 lookfor ucf
 codebook ucf*, tab(100)
 
 recode ucf7 (1/2=0) (3/4=1) (9=.), gen(seeing)
 recode ucf9 (1/2=0) (3/4=1) (9=.), gen(hearing)

codebook ucf11 ucf12 ucf13, tab(100)
  
 gen walking=0
 replace walking=1 if ucf11==3|ucf11==4|ucf12==3|ucf12==4|ucf13==3|ucf13==4
 replace walking=. if (ucf11==9|ucf11==.) & (ucf12==9|ucf12==.) & (ucf13==9|ucf13==.) 

 recode ucf14 (1/2=0) (3/4=1) (9=.), gen(finemotor)

 gen comm=0
 replace comm=1 if ucf15==3|ucf15==4|ucf16==3|ucf16==4
 replace comm=. if (ucf15==9|ucf15==.) & (ucf16==9|ucf16==.) 
 
 recode ucf17 (1/2=0) (3/4=1) (9=.), gen(learning)
 recode ucf18 (1/2=0) (3/4=1) (9=.), gen(playing)
 recode ucf19 (1/4=0) (5=1) (9=.), gen(behavior)
 codebook ucf19, tab(100)
 
 gen dis2=0
 for X in any $list1: replace dis2=1 if X==1
 replace dis2=. if seeing==. & hearing==. & walking==. & finemotor==. & comm==. & learning==. & playing==. & behavior==.
 
 tab dis2 cdisability, m // some differences

 
*ECD index
 for X in any ec6 ec7 ec8 ec9 ec11 ec12 ec13: recode X (2=0) (8/9=.)
 for X in any ec10 ec14 ec15: recode X (1=0) (2=1) (8/9=.)


 ** Literacy & numeracy
 gen sum_litnum=ec6+ec7+ec8
 gen litnum=0
 replace litnum=1 if sum_litnum>=2 & sum_litnum!=.
 replace litnum=. if ec6==. & ec7==. & ec8==.
 
 ** Physical
gen physical=0
replace physical=1 if ec9==1|ec10==1
replace physical=. if ec9==. & ec10==.

** Learning
gen learns=0
replace learns=1 if ec11==1|ec12==1
replace learns=. if ec11==. & ec12==.

** SocioEm
 gen sum_socioem=ec13+ec14+ec15
 gen socioem=0
 replace socioem=1 if sum_socioem>=2 & sum_socioem!=.
 replace socioem=. if ec13==. & ec14==. & ec15==.
 
** ECD index
gen sum_ecd=litnum+physical+learns+socioem
gen ecd=0
replace ecd=1 if sum_ecd>=3 & sum_ecd!=.
replace ecd=. if litnum==. & physical==. & learns==. & socioem==.
 
drop sum_*
