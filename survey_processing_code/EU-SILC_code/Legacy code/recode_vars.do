
**********************
* recode_vars.do     *
**********************
*Modified Nov 2016. Then again on June 2017

 
 * Id
d *_id

*g age = 2005-pb140

* Age adjustment 
gen age=px020 // added
gen age_preschool=rx010 // added

local adjustage = 0
replace age = age - `adjustage'

* Weight
rename pb040 hhweight
lab var hhweight "HH weight"


** Recode educational variables
* enrolment
ta pe010
ta pe010, nol
recode pe010 (2=0)
* current level attended
ta pe020 
ta pe020, nol
* highest level attained 
ta pe040 
ta pe040, nol 
 
 

recode pe020 (10=1) (20=2) (30/35=3) (40/45=4) (50=5) (60/80=6) if pb010==2014
recode pe040 (100=1) (200=2) (300/354=3) (400/450=4) (500=5) (600/800=6) if pb010==2014
 
***============================
** Dimensions
*

* Sex
recode pb150 (1=1) (2=0), gen(sex)
label define sex 1 "Male" 0 "Female"
label val sex sex


* Degree of urbanization
g urban = "Intermediate or densely populated area" if (db100==1|db100==2)
replace urban = "Thinly populated area" if (db100==3)

* Region
rename db040 region

*if year==2005 {
*rename db040_num region_names
*}
*if year==2013 {
*g region_names =.
*}

* Wealth
xtile wealth = hx090, nquantiles(5)
label define wealth 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values wealth wealth

** New ones
* Migrant
*g migrant = pb210_num
*label define migrant 1 "No migrant"	2 "Migrant - from Europe" 3 "Migrant - not from Europe"
*label val migrant migrant

encode pb210, gen(migrant)
cap label drop migrant
label define migrant 1 "Not migrant" 2 "Migrant - from Europe" 3 "Migrant - not from Europe"
label val migrant migrant

***============================
** Education variables for WIDE indicators 
*

* Highest education level attained
rename pe040 highlevl

* Enrolment 
rename pe010 enrolment

* Current educational level attended
rename pe020 edlevel

*preschool // added
gen preschool=rl010
recode preschool (2/84=1) (85/100=.)
