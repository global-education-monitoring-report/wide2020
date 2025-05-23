**********************
* canada new calculations
**********************
***DEFINE 3 PROGRAMS: 
	*domerge joins person and household data
	*doeduc generates education indicators
	*doedumean "makes the tables"
	
**CANADA SPECIFICATIONS: 
// lowest level is 'less than upsec', 7 years
// no ethnicity
// rural
// sex
// region

*====
***** Pool data
program define domerge
    foreach ctry in $datasets {
	
		*** merge
		    use $varsp using $`ctry'p, clear
			merge m:1 hid using $`ctry'h, keepusing($varsh) keep(match) nogen
			
		 *** recode dim
			 decode region_c, gen(region2)
			 gen region = substr(region2, 5, 200) 
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
			 keep hid pid dname cname hwgt pwgt ppopwgt region location sex wealth educ edyrs educ_c enroll age
			 save $mydata/${username}_$ctry, replace
    }
end


*====
***** Recode data edu
program define doeduc
     
	*** Open data
        use $mydata/${username}_$ctry, clear	
		
	*** Edu info 
		* Primary
		local primaryage0 = 6
		local primaryage1 = 11
		local primaryfirst = 1
		local primarylast = 6
		local primarydur = 6
		* Lower secondary
		local lowersecondaryage0 = 12
		local lowersecondaryage1 = 13
		local lowersecondaryfirst = 7 
		local lowersecondarylast = 8
		local lowersecondarydur = 2
		* Upper secondary
		local uppersecondaryage0 = 14
		local uppersecondaryage1 = 17
		local uppersecondaryfirst = 9 
		local uppersecondarylast = 12
		local uppersecondarydur = 4

	*** Age for each level
		g primaryage0=`primaryage0'
		g primaryage1=`primaryage1'
		g lowersecondary0 = `lowersecondaryage0'
		g lowersecondary1 = `lowersecondaryage1'
		g uppersecondary0 = `uppersecondaryage0'
		g uppersecondary1 = `uppersecondaryage1'

	*** Age groups ind	  
		* Never
		g age0_never = primaryage0+2 
		g age1_never = age0_never+4
		g age_never = 1 if (age>=age0_never & age<=age1_never)
		g age0_never2 = age0_never+4
		g age1_never2 = age0_never2+4
		g age_never2 = 1 if (age>=age0_never2 & age<=age1_never2)	     	
		* Out
		g agegroup_pry=0
		replace agegroup_pry=1 if (age>=`primaryage0' & age<=`primaryage1')
		replace agegroup_pry=. if age==.
		g agegroup_lower_sec=0
		replace agegroup_lower_sec=1 if (age>=`lowersecondaryage0' & age<=`lowersecondaryage1')
		replace agegroup_lower_sec=. if age==.
		g agegroup_upper_sec=0
		replace agegroup_upper_sec=1 if (age>=`uppersecondaryage0' & age<=`uppersecondaryage1')
		replace agegroup_upper_sec=. if age==. 	  
		* Prim comp
		g age0_comp_prim_3 = primaryage1+3
		g age1_comp_prim_3 = primaryage1+3+2
		g age_comp_prim_3 = 1 if (age>=age0_comp_prim_3 & age<=age1_comp_prim_3)	  
		* Lowsec comp
		g age0_comp_lowsec_3 = lowersecondary1+3
		g age1_comp_lowsec_3 = lowersecondary1+3+2
		g age_comp_lowsec_3 = 1 if (age>=age0_comp_lowsec_3 & age<=age1_comp_lowsec_3)	  
		* Upsec comp
		g age0_comp_upsec_3 = uppersecondary1+3
		g age1_comp_upsec_3 = uppersecondary1+3+2
		g age_comp_upsec_3 = 1 if (age>=age0_comp_upsec_3 & age<=age1_comp_upsec_3) 
		* Higher comp
		g agegroup_2529=1 if age>=25 & age<=29	 
		* 20-24 and 15-24
		g agegroup_2024 = 1 if (age>=20 & age<=24)
		g agegroup_1524 = 1 if (age>=15 & age<=24)  
		g agegroup_2029 = 1 if (age>=20 & age<=29)

	*** Temp vars ind 
	*updating this according to database
		* Never 
		recode educ_c (1=1) (2/12=0), gen(never_prim_temp)	
		* Enrol
		*updating this
		recode enroll (1=1) (0=0), gen(enrolment) 	
		* Comp
		g comp_prim_temp=.
		g comp_lowsec_temp=.
		*recode educ_c (1=0) (2/4=1), gen(comp_lowsec_temp)
		recode educ_c (1=0) (2/4=1), gen(comp_upsec_temp) 
		recode educ_c (1/2=0) (3/4=1), gen(comp_higher_temp) 

	*** Ind 	
		* Never
		g edu0_prim = 0 if (age_never2==1) & never_prim_temp!=.
		recode edu0_prim (0=1) if (never_prim_temp==1) 			
		* Out prim
		g edu_out_pry= 0 if (agegroup_pry==1)
		recode edu_out_pry (0=1) if (enrolment==0)
		replace edu_out_pry=. if enrolment==.  
		* Out lowsec
		g edu_out_lowsec= 0 if (agegroup_lower_sec==1)
		recode edu_out_lowsec (0=1) if (enrolment==0)
		replace edu_out_lowsec=. if enrolment==.
		* Out upsec
		g edu_out_upsec= 0 if (agegroup_upper_sec==1)
		recode edu_out_upsec (0=1) if (enrolment==0)
		replace edu_out_upsec=. if enrolment==.	 
		* Prim comp 
		g comp_prim = 0 if (age_comp_prim_3==1) & comp_prim_temp!=.
		recode comp_prim (0=1) if comp_prim_temp==1
		g comp_prim_1524 = 0 if (agegroup_1524==1) & comp_prim_temp!=.
		recode comp_prim_1524 (0=1) if comp_prim_temp==1	 	 
		* Lowsec comp
		g comp_lowsec = 0 if (age_comp_lowsec_3==1) & comp_lowsec_temp!=.
		recode comp_lowsec (0=1) if comp_lowsec_temp==1
		g comp_lowsec_1524 = 0 if (agegroup_1524==1) & comp_lowsec_temp!=.
		recode comp_lowsec_1524 (0=1) if comp_lowsec_temp==1	 		 
		* Upsec comp
		g comp_upsec = 0 if (age_comp_upsec_3==1) & comp_upsec_temp!=.
		recode comp_upsec (0=1) if comp_upsec_temp==1	 
		g comp_upsec_2029 = 0 if (agegroup_2029==1) & comp_upsec_temp!=.
		recode comp_upsec_2029 (0=1) if comp_upsec_temp==1		
		* Higher comp
		g comp_higher_2529 = 0 if (agegroup_2529==1) & comp_higher_temp!=.
		recode comp_higher_2529 (0=1) if comp_higher_temp==1
		*Eduyears
		g eduyears_2024 = edyrs if agegroup_2024 == 1
		

	*** Keep vars
		keep cname hwgt pwgt ppopwgt region location sex wealth ///
		eduyears_2024 edu0_prim edu_out_pry edu_out_lowsec edu_out_upsec ///
		comp_prim comp_prim_1524 comp_lowsec comp_lowsec_1524 comp_upsec comp_upsec_2029 comp_higher_2529 	
	
	*** Save	
		save $mydata/${username}_$ctry, replace		
end

program define doedumean

	*** Open data
		use $mydata/${username}_$ctry, clear	

   ***  Global
		#delimit ;
		global eduvars "
		eduyears_2024 edu0_prim edu_out_pry edu_out_lowsec edu_out_upsec 
		comp_prim comp_prim_1524 comp_lowsec comp_lowsec_1524 comp_upsec comp_upsec_2029 comp_higher_2529 
		" ;
		#delimit cr
		
		local country Canada
		local survey LIS
	
	*** Total
	    di " ---- Total ----"
		  foreach x in $eduvars {
		   qui tabstat `x' [aw=ppopwgt], stat(mean N) save
		   local indicator=el(r(StatTotal),1,1)
		   local nobs=el(r(StatTotal),2,1)
		   display "@"  "`country'" "-" "`survey'" "-" "$year" "-" "`x'" "-" "Total" "----" "`indicator'" "-" "`nobs'"
		   }
		
		
	*** 1d
   di "---- 1d ----"	
        foreach x in  sex wealth region location  {
		   di "----`x'----"	
		   levelsof `x',  local(categorynames)
		   local categorylevels : word count `categorynames' 
		   *di `categorylevels'
		   		  foreach y in $eduvars {
				  		  qui tabstat `y' [aw=ppopwgt], stat(mean N) by(`x') nototal save
						  foreach z of numlist 1/`categorylevels' {
						  		local indicator=el(r(Stat`z'),1,1)
								local nobs=el(r(Stat`z'),2,1)
								display  "@"  "`country'" "-" "`survey'" "-" "$year" "-" "`y'" "-" "`x'" "-" r(name`z') "---" "`indicator'" "-" "`nobs'" 

						  }
				 }
		}
	*** 2d 
global categories_collapse sex wealth region location
tuples $categories_collapse, display
display "`tuple`i''"
foreach i of numlist 5/10 {
			egen combination`i'=concat(`tuple`i''), punct("-")
			levelsof combination`i',  local(categorynames)
		   local categorylevels : word count `categorynames' 
		   foreach y in $eduvars {
				  		  qui tabstat `y' [aw=ppopwgt], stat(mean N) by(combination`i') nototal save
						  foreach z of numlist 1/`categorylevels' {
						  		local indicator=el(r(Stat`z'),1,1)
								local nobs=el(r(Stat`z'),2,1)
								display "@"  "`country'" "-" "`survey'" "-" "$year" "-" "`y'" "-" "`tuple`i''" "-" r(name`z') "--" "`indicator'" "-" "`nobs'" 
								}
						  }
}	

*** 3d 
global categories_collapse sex wealth region location
tuples $categories_collapse, display
display "`tuple`i''"
foreach i of numlist 11/14 {
			egen combination`i'=concat(`tuple`i''), punct("-")
			levelsof combination`i',  local(categorynames)
		   local categorylevels : word count `categorynames' 
		   foreach y in $eduvars {
				  		  qui tabstat `y' [aw=ppopwgt], stat(mean N) by(combination`i') nototal save
						  foreach z of numlist 1/`categorylevels' {
						  		local indicator=el(r(Stat`z'),1,1)
								local nobs=el(r(Stat`z'),2,1)
								display "@"  "`country'" "-" "`survey'" "-" "$year" "-" "`y'" "-" "`tuple`i''" "-" r(name`z') "-" "`indicator'" "-" "`nobs'" 
								}
						  }
}	
		
end



*====
***** Run progs
local surveycodes "ca17 ca16 ca15 ca14"

local survey_year "2017 2016 2015 2014"

local n : word count `surveycodes'

forvalues i = 1/`n' {
global username "mbarri"
local surcode : word `i' of `surveycodes'
global datasets "`surcode'"
global varsh "hid did dname cname hwgt hpopwgt region_c rural nhhmem dhi"
global varsp "hid pid dname cname pwgt ppopwgt age sex educ edyrs educ_c enroll"
domerge
doeduc	
global year : word `i' of `survey_year'
doedumean
}







