program define disability_MICS_FS
	syntax, data_path(string) output_path(string) country_code(string) country_year(string) 

		cd "`data_path'\\`country_code'_`country_year'_MICS\"
		 
		capture confirm file fs.dta 
			if _rc == 0 {
				use "fs.dta", clear
			}
							
				
		capture rename *, lower
		gen iso_code3=upper("`country_code'")
		gen year="`3'"
		catenate country_year  = country year_folder, p("_")
		
	*Recode sex 
	recode hl4 (1=1) (2=0), gen(sex)
	label define sex 1 "Male" 0 "Female"
	label val sex sex

	*create auxiliary tempfiles from setcode table to fix values later
	local vars code_cb5a
	findfile mics_dictionary_setcode.xlsx, path("`c(sysdir_personal)'/")
	local dic `r(fn)'
	set more off	
	
	foreach X in `vars'{
		import excel "`dic'", sheet(`X') firstrow clear 
		tempfile fix`X'
		save `fix`X''
	}
  
	gen code_cb5a = cb5a
	label values code_cb5a .
	
	* EDUCATION LEVEL RECODE 
	* merge with auxiliary data of education levels for CB3A, now incorporated to the MICS dictionary  

	replace_many `fixcode_cb5a' code_cb5a code_cb5a_replace country_year

	
	**Import durations from UIS
	findfile UIS_duration_age_30082021.dta, path("`c(sysdir_personal)'/")
	merge m:1 iso_code3 year using "`r(fn)'", keep(master match) nogenerate
	

	* With info of duration of primary and secondary I can compare official duration with the years of education completed..
	generate years_prim   = prim_dur
	generate years_lowsec = prim_dur + lowsec_dur
	generate years_upsec  = prim_dur + lowsec_dur + upsec_dur
	
	*NEW STUFF
	replace eduyears=ed4b if inlist(code_cb5a, 1, 60, 70)  
	replace eduyears=ed4b+years_prim if inlist(code_cb5a, 2, 21, 23)
	replace eduyears=ed4b+years_lowsec if inlist(code_cb5a, 22, 24)
	replace eduyears=ed4b+years_upsec if inlist(code_cb5a, 3, 32, 33) 
	
	*AD HOC ADJUSTMENTS 
	replace eduyears=ed4b+years_prim-5 if code_cb5a==21 & country_year=="Montenegro_2018"
	replace eduyears=cb5b if (code_cb5a==1|code_cb5a==21|code_cb5a==22|code_cb5a==3) & country_year=="Bangladesh_2019"
	replace eduyears=ed4b+years_lowsec-3 if code_cb5a==22 & country_year=="Kiribati_2018"
	replace eduyears=cb5b if (code_cb5a==1|code_cb5a==21|code_cb5a==22) & country_year=="Qatar_2012"
	replace eduyears=ed4b+years_prim-5 if cb5a=="2" & country_year=="TFYRMacedonia_2018"
	
	replace eduyears=cb5b if cb5a=="2" & country_year=="Guyana_2019"
	replace eduyears=cb5b if cb5a=="3" & country_year=="Guyana_2019"

	replace eduyears=ed4b+years_lowsec-2 if cb5a=="3" & country_year=="Malawi_2019"
	replace eduyears=cb5b if cb5a=="2" & country_year=="Samoa_2019"
	replace eduyears=cb5b if cb5a=="2" & country_year=="Tuvalu_2019"
	replace eduyears=cb5b if cb5a=="2" & country_year=="Belarus_2019"
	replace eduyears=cb5b if cb5a=="3" & country_year=="Belarus_2019"
	replace eduyears=cb5b if cb5a=="3" & country_year=="Nepal_2019"
	replace eduyears=cb5b if cb5a=="4" & country_year=="Nepal_2019"
	replace eduyears=cb5b if cb5a=="5" & country_year=="Nepal_2019"
	
	replace eduyears=cb5b+years_lowsec-3 if code_cb5a==22 & country_year=="Thailand_2019" // *stairs* issue upsec
	replace eduyears=cb5b+years_upsec+6 if code_cb5a==41 & country_year=="Thailand_2019" // Master assuming 6 years of bachelor
	replace eduyears=cb5b+years_upsec+6+2 if code_cb5a==42 & country_year=="Thailand_2019" // Doctoral degree assuming 2 years of master
	
		
	*******COMPLETION_LVL base**********

 	*Completion each level without Age limits 
 	foreach Z in prim lowsec upsec  {
 		generate comp_`Z' = 0
 		replace comp_`Z' = 1 if eduyears >= years_`Z'
		replace comp_`Z' = . if inlist(eduyears, 97, 98, 99, .)
		replace comp_`Z' = 0 if cb7 == 2
 		replace comp_`Z' = 0 if code_cb5a == 0
 	}
	
	* COMPUTE EDUCATION COMPLETION (the level reached in primary, secondary, etc.)
	gen   prim_age0 = prim_age_uis
	generate lowsec_age0 = prim_age_uis + prim_dur_uis
	generate upsec_age0  = lowsec_age_uis+ lowsec_dur_uis
	for X in any prim lowsec upsec: generate X_age1 = X_age0 + X_dur_uis - 1
	
	*Age limits for completion and out of school
	foreach X in prim lowsec upsec {
		generate comp_`X'_v2 = comp_`X' if schage >= `X'_age1 + 3 & schage <= `X'_age1 + 5
	}
	
	*******EDUOUT *********

	
	* Recoding CB7: "Attended school during current school year?"
	capture generate attend = 1 if cb7 == 1
	capture replace attend  = 0 if cb7 == 2
	capture replace attend  = . if cb7 == 9

	* generate no_attend the attend complement
	capture recode attend (1=0) (0=1), gen(eduout)

	* generate eduout
	* missing when age, attendance or level of attendance (when goes to school) is missing / 1: goes to preschool. "out of school" if "ever attended school"=no 
	capture replace eduout  = . if (attend == 1 & code_cb5a == .) | age == . | (inlist(code_cb5a,. , 98, 99) & eduout == 0)
	capture replace eduout  = 1 if code_ed6a == 0 | cb4 == 2 
	
	gen   prim_age0_eduout = prim_age_uis
	capture generate lowsec_age0_eduout = prim_age_uis + prim_dur_uis
	capture generate upsec_age0_eduout  = lowsec_age_uis + lowsec_dur_uis
	for X in any prim lowsec upsec: capture generate X_age1_eduout = X_age_uis + X_dur_uis - 1
		
	*Age limits for out of school
	foreach X in prim lowsec upsec {
		capture generate eduout_`X' = eduout if schage >= `X'_age0_eduout & schage <= `X'_age1_eduout
	}
	
		
	******NEVER BEEN TO SCHOOL*****
		
	generate edu0 = 0 if cb4 == 2
	replace edu0  = 1 if cb4 == 1
	replace edu0  = . if cb4 == .
	replace edu0  = 1 if code_cb5a == 0
	replace edu0  = 1 if eduyears == 0
	
	gen edu0_prim = edu0  if schage >= prim_age_uis+3 & schage <= prim_age_uis+6
	
	
	***********OVER-AGE PRIMARY ATTENDANCE**************
	**MICS6 version
	*Over-age primary school attendance
	*Percentage of children in primary school who are two years or more older than the official age for grade.
	gen overage2plus= 0 if code_cb5a==1
	gen primarygrades=cb8b if code_cb5a==1 & cb8b<80
	levelsof primarygrades, local(primgrades) clean
	local i=0
    foreach grade of local primgrades {
				local i=`i'+1
				replace overage2plus = 1 if cb8b==`grade' & schage>prim_age_uis+1+`i'
                 }
	
				 
	************************************************************************************************************
	
	****Disability seciton*****
	
	*The raw data contains variable fsdisability 
	recode fsdisability (1=1) (2=0) (9=.) , gen(rawdisability)
	label define difficulty 0 "No functional difficulty" 1 "At least one functional difficulty" 9 "Missing" 
	label value rawdisability difficulty
		

***************************************************************************
		*** CHILD FUNCTIONING FOR CHILDREN AGE 5-17 YEARS ***

		*Based on the recommended cut-off, the disability indicator includes "daily" for the questions on anxiety and depression; and "a lot of difficulty" and "cannot do at all" for all other questions *

		* PART ONE: Creating separate variables per domain of functioning *

		capture rename fcf# ucf#
		capture rename ucf*, upper

		* SEEING DOMAIN *
		gen SEE_IND = UCF6
		gen Seeing_5to17 = 9
		replace Seeing_5to17 = 0 if inrange(SEE_IND, 1, 2)
		replace Seeing_5to17 = 1 if inrange(SEE_IND, 3, 4)
		*label define see 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Seeing_5to17 see

		* HEARING DOMAIN *
		gen HEAR_IND = UCF8

		gen Hearing_5to17 = 9
		replace Hearing_5to17 = 0 if inrange(HEAR_IND, 1, 2)
		replace Hearing_5to17 = 1 if inrange(HEAR_IND, 3, 4)
		*label define hear 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Hearing_5to17 hear

		* WALKING DOMAIN *
		gen WALK_IND1 = UCF10 // withour equipment, diff walking 100 meters 
		replace WALK_IND1 = UCF11 if UCF10 == 2 // without equipment, walkng 500 meters
		tab WALK_IND1

		gen WALK_IND2 = UCF14 // compared w children of the same age, diff walking 100 mt
		replace WALK_IND2 = UCF15 if (UCF14 == 1 | UCF14 == 2) // compared w children same age, diff walking 500 mt
		tab WALK_IND2

		gen WALK_IND = WALK_IND1
		replace WALK_IND = WALK_IND2 if WALK_IND1 == .
		tab WALK_IND

		gen Walking_5to17 = 9
		replace Walking_5to17 = 0 if inrange(WALK_IND, 1, 2)
		replace Walking_5to17 = 1 if inrange(WALK_IND, 3, 4)
		*label define walk 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Walking_5to17 walk 

		* SELFCARE DOMAIN *
		gen Selfcare_5to17 = 9
		replace Selfcare_5to17 = 0 if inrange(UCF16, 1, 2)
		replace Selfcare_5to17 = 1 if inrange(UCF16, 3, 4)
		*label define selfcare 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Selfcare_5to17 selfcare

		* COMMUNICATING DOMAIN *
		gen COM_IND = 0
		replace COM_IND = 4 if (UCF17 == 4 | UCF18 == 4) // diff being understood IN house, diff being understood OUTSIDE of house
		replace COM_IND = 3 if (COM_IND != 4 & (UCF17 == 3 | UCF18 == 3))
		replace COM_IND = 2 if (COM_IND != 4 & COM_IND != 3 & (UCF17 == 2 | UCF18 == 2))
		replace COM_IND = 1 if (COM_IND != 4 & COM_IND != 3 & COM_IND != 1 & (UCF17 == 1 | UCF18 == 1))
		replace COM_IND = 9 if ((COM_IND == 2 | COM_IND == 1) & (UCF17 == 9 | UCF18 == 9))
		tab COM_IND

		gen Communication_5to17 = 9
		replace Communication_5to17 = 0 if inrange(COM_IND, 1, 2) 
		replace Communication_5to17 = 1 if inrange(COM_IND, 3, 4)
		*label define communicate 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Communication_5to17 communicate

		* LEARNING DOMAIN *
		gen Learning_5to17 = 9
		replace Learning_5to17 = 0 if inrange(UCF19, 1, 2)
		replace Learning_5to17 = 1 if inrange(UCF19, 3, 4)
		label define learning 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Learning_5to17 learning

		* REMEMBERING DOMAIN *
		gen Remembering_5to17 = 9
		replace Remembering_5to17 = 0 if inrange(UCF20, 1, 2)
		replace Remembering_5to17 = 1 if inrange(UCF20, 3, 4)
		label define remembering 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Remembering_5to17 remembering

		* CONCENTRATING DOMAIN *
		gen Concentrating_5to17 = 9
		replace Concentrating_5to17 = 0 if inrange(UCF21, 1, 2)
		replace Concentrating_5to17 = 1 if inrange(UCF21, 3, 4)
		label define concentrating 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Concentrating_5to17 concentrating 

		* ACCEPTING CHANGE DOMAIN *
		gen AcceptingChange_5to17 = 9
		replace AcceptingChange_5to17 = 0 if inrange(UCF22, 1, 2)
		replace AcceptingChange_5to17 = 1 if inrange(UCF22, 3, 4)
		label define accepting 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value AcceptingChange_5to17 accepting

		* BEHAVIOUR DOMAIN * e difficulty controlling his/her behaviour
		gen Behaviour_5to17 = 9
		replace Behaviour_5to17 = 0 if inrange(UCF23, 1, 2)
		replace Behaviour_5to17 = 1 if inrange(UCF23, 3, 4)
		label define behaviour 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Behaviour_5to17 behaviour

		* MAKING FRIENDS DOMAIN *
		gen MakingFriends_5to17 = 9
		replace MakingFriends_5to17 = 0 if inrange(UCF24, 1, 2)
		replace MakingFriends_5to17 = 1 if inrange(UCF24, 3, 4)
		label define friends 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value MakingFriends_5to17 friends

		* ANXIETY DOMAIN *
		gen Anxiety_5to17 = 9
		replace Anxiety_5to17 = 0 if inrange(UCF25, 2, 5)
		replace Anxiety_5to17 = 1 if (UCF25 == 1)
		label define anxiety 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Anxiety_5to17 anxiety

		* DEPRESSION DOMAIN *
		gen Depression_5to17 = 9
		replace Depression_5to17 = 0 if inrange(UCF26, 2, 5)
		replace Depression_5to17 = 1 if (UCF26 == 1)
		label define depression 0 "No functional difficulty" 1 "With functional difficulty" 9 "Missing" 
		label value Depression_5to17 depression

		* PART TWO: Creating disability indicators for children age 5-17 years *

		*This one should be equal to rawdisability	
		gen FunctionalDifficulty_5to17 = 0
		replace FunctionalDifficulty_5to17 = 1 if (Seeing_5to17 == 1 | Hearing_5to17 == 1 | Walking_5to17 == 1 | Selfcare_5to17 == 1 | Communication_5to17 == 1 | Learning_5to17 == 1 | Remembering_5to17 == 1 | Concentrating_5to17 == 1 | AcceptingChange_5to17 == 1 | Behaviour_5to17 == 1 | MakingFriends_5to17 == 1 | Anxiety_5to17 == 1 | Depression_5to17 == 1) 
		replace FunctionalDifficulty_5to17 = . if (FunctionalDifficulty_5to17 != 1 & (Seeing_5to17 == 9 | Hearing_5to17 == 9 | Walking_5to17 == 9 | Selfcare_5to17 == 9 | Communication_5to17 == 9 | Learning_5to17 == 9 | Remembering_5to17 == 9 | Concentrating_5to17 == 9 | AcceptingChange_5to17 == 9 | Behaviour_5to17 == 9 | MakingFriends_5to17 == 9 | Anxiety_5to17 == 9 | Depression_5to17 == 9)) 
		capture label define difficulty 0 "No functional difficulty" 1 "At least one functional difficulty"  
		label value FunctionalDifficulty_5to17 difficulty
		
		*This one only considers 7 dimensions: seeing hearing walking communicating self care remembering concentrating

		gen disability_essentialdomains = 0
		replace disability_essentialdomains = 1 if (Seeing_5to17 == 1 | Hearing_5to17 == 1 | Walking_5to17 == 1 | Selfcare_5to17 == 1 | Communication_5to17 == 1 | Remembering_5to17 == 1 | Concentrating_5to17 == 1) 
		replace disability_essentialdomains = . if (FunctionalDifficulty_5to17 != 1 & (Seeing_5to17 == 9 | Hearing_5to17 == 9 | Walking_5to17 == 9 | Selfcare_5to17 == 9 | Communication_5to17 == 9 | Remembering_5to17 == 9 | Concentrating_5to17 == 9 )) 
		capture label define essentialdifficulty 0 "No functional difficulty" 1 "At least one sensory, physical or intellectual difficulty"  
		label value disability_essentialdomains essentialdifficulty

		
		global indicators comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 overage2plus eduout_prim eduout_lowsec eduout_upsec edu0_prim
		keep $indicators FunctionalDifficulty_5to17 disability_essentialdomains rawdisability sex hh1 hh2 ln fs1 fs2 fs3 fsint fs4 

			foreach var in $indicators {
			gen `var'_no=`var'
					}
					
	local vars country_year iso_code3 year sex disability_essentialdomains rawdisability FunctionalDifficulty_5to17
	foreach var in `vars' {
		capture sdecode `var', replace
		capture tostring `var', replace
		capture replace `var' = "" if `var' == "."
	}
	
	compress
					
		cd "C:\Users\taiku\Desktop\temporary_disability"
		save "FS_disability_`isocode'_`3'_MICS.dta", replace
		
*************setup recursive collapse /  summarize  ******************************************************************

		global categories_collapse sex disability_essentialdomains rawdisability
		global varlist_m ccomp_prim_v2 comp_lowsec_v2 comp_upsec_v2 overage2plus eduout_prim eduout_lowsec eduout_upsec edu0_prim
		global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no overage2plus_no eduout_prim_no eduout_lowsec_no eduout_upsec_no edu0_prim_no
 
	tuples $categories_collapse, display

	
				 
	end
	