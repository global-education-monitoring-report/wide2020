 ren *, lower
 *for X in any region psu strata caretakerdis ed5a ed5b hh52: cap gen X=.
 keep hh1 hh2 ln vt22* *age disability welevel windex5 *weight cm1 ceb
 
 gen id=string(hh1)+" "+string(hh2)+" "+string(ln)
 
 recode vt22a (2=0) (8/9=.), gen(d_origin)
 recode vt22b (2=0) (8/9=.), gen(d_gender)
 recode vt22d (2=0) (8/9=.), gen(d_disability)
 recode vt22x (2=0) (8/9=.), gen(d_other)
 
 recode fcf8 (1/2=0) (3/4=1) (9=.), gen(hearing)

 gen walking=0
 replace walking=1 if fcf10==3|fcf10==4|fcf11==3|fcf11==4|fcf14==3|fcf14==4|fcf15==3|fcf15==4
 replace walking=. if (fcf10==9|fcf10==.) & (fcf11==9|fcf11==.) & (fcf14==9|fcf14==.) & (fcf15==9|fcf15==.)  

 recode fcf16 (1/2=0) (3/4=1) (9=.), gen(selfcare)

 gen communication=0
 replace communication=1 if fcf17==3|fcf17==4|fcf18==3|fcf18==4
 replace communication=. if (fcf17==9|fcf17==.) & (fcf18==9|fcf18==.) 
 
 recode fcf19 (1/2=0) (3/4=1) (9=.), gen(learning)
 recode fcf20 (1/2=0) (3/4=1) (9=.), gen(remembering)
 recode fcf21 (1/2=0) (3/4=1) (9=.), gen(concentrating)
 recode fcf22 (1/2=0) (3/4=1) (9=.), gen(acceptingchange)
 recode fcf23 (1/2=0) (3/4=1) (9=.), gen(controlbehavior)
 recode fcf24 (1/2=0) (3/4=1) (9=.), gen(makingfriends)
 recode fcf25 (1=1) (2/5=0) (9=.), gen(anxiety)
 recode fcf26 (1=1) (2/5=0) (9=.), gen(depression)
 
 gen dis2=0
 for X in any $list1: replace dis2=1 if X==1
 replace dis2=. if seeing==. & hearing==. & walking==. & selfcare==. & communication==. & remembering==. ///
 & concentrating==. & acceptingchange==. & controlbehavior==. & makingfriends==. & anxiety==. & depression==.
 
