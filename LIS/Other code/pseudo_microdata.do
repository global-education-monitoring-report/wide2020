************************************
*NO FUNCIONA
************************************

*====
***** Pool data
program define domerge
    foreach ctry in $datasets {
	
		*** merge
		    use $varsp using $`ctry'p, clear
			merge m:1 hid using $`ctry'h, keepusing($varsh) keep(match) nogen
			
		 *** recode dim
			 decode region_c, gen(region2)
			 gen region = substr(region2, 4, 200) 
			 drop region2
			 decode sex, gen(sex2)
			 drop sex
			 gen sex = substr(sex2, 4,7)
			 drop sex2
			 gen location = "Rural" if rural == 1
			 replace location = "Urban" if rural == 0
			 g dhi_tb = dhi
			 qui sum dhi [w=hpopwgt], d
			 replace dhi_tb = 0 if dhi<0
			 replace dhi_tb = 10*r(p50) if dhi>10*r(p50)
			 gen edhi_tb = dhi_tb/(nhhmem^0.5)
			 xtile quintile = edhi_tb[w=hpopwgt], nq(5)
			 label define quintile 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
			 label val quintile quintile
			 decode quintile, gen(wealth)
			 
		 *** keep vars
			 keep hid pid dname cname hwgt pwgt ppopwgt region location sex wealth educ educlev edyrs educ_c enroll age
			 save $mydata/${username}_$ctry, replace
    }
end

program define doeduccounts

*** Open data
        use $mydata/${username}_$ctry, clear

local country Japan
local survey LWS
gen edad="age"
egen agerange=concat(edad age) if age>=24 & age<=30, punct(:)
        egen combinating=concat(sex wealth region location agerange) if age>=24 & age<=30, punct(*)
			qui levelsof combinating,  local(combclean)
			foreach i in `combclean' {
			replace combinating = "" if combinating=="`i'" & educlev==.
			}
			set trace on
			levelsof combinating,  local(categorynames)
		   local categorylevels : word count `categorynames' 
		   		   		   		  foreach y in `categorynames' {
						  gen educlevnum=educlev if combinating=="`y'" 
						  levelsof educlevnum, local(educlevnum) 
						  local maxstat : word count `educlevnum' 
						  drop educlevnum
						  foreach z of numlist 1/`maxstat' {
						  		qui tabstat educlev if combinating=="`y'" , stat(N) by(educlev) missing save
						  		local indicator=el(r(Stat`z'),1,1)
								display  "@"  "`country'" "-" "`survey'" "-" "$year" "-" "`y'" "-"  r(name`z') "-" "`indicator'"  

						  }
				 }
				 set trace off
end



***** Run progs
local surveycodes "jp14"

local survey_year "2014"

local n : word count `surveycodes'

forvalues i = 1/`n' {
global username "mbarri"
local surcode : word `i' of `surveycodes'
global datasets "`surcode'"
global varsh "hid did dname cname hwgt hpopwgt region_c rural nhhmem dhi"
global varsp "hid pid dname cname pwgt ppopwgt age sex educ edyrs educ_c educlev enroll"
domerge
global year : word `i' of `survey_year'
doeduccounts	
}