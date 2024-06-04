*Chandni loop

/*
*Percentage of children age 24-59 months engaged in four or more activities to provide early stimulation and responsive care in the last 3 days with
(a)     Any adult household member
(b)     Father
(c)     Mother
Percentage of children age 2-4 years with whom the father, mother or adult household members engaged in activities that promote learning and school readiness during the last three days Note: Activities include: reading books to the child; telling stories to the child; singing songs to the child; taking the child outside the home; playing with the child; and naming, counting or drawing things with the child
*/


clear 
use "C:\ado\personal\repository_inventory.dta"
*keep only mics6

keep if survey=="MICS" & round==6


 levelsof fullname, local(process_list)



foreach survey of local process_list {
         di "Now processing" " `survey'"
         *Directly run mics_standardize_standalone with one survey
		tokenize "`survey'", parse(_)
		local isocode=upper("`1'")
		*di "`isocode'"
		local survey=upper("`5'")
		*di `survey'
		local year=upper("`3'")
		*di `year'

cd "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`isocode'_`year'_MICS\"
		use "ch.dta", clear		
		capture rename *, upper		
		gen iso_code3=upper("`isocode'")
		gen year="`year'"
		egen surveyname=concat(iso year),  punct(-)
		
		*check if the question exists
		capture confirm variable EC5FA 
			if _rc == 0 {
						
						fre EC5FA
															
						*generate dummy variable to count for each activity checkin for mom dad other, there are 6 activities 
						*EC5A read books
						gen act1=. 
						capture replace act1 = 1 if EC5AA=="A" | EC5AB=="B" | EC5AX=="X"
						capture replace act1 = 0 if EC5AY=="Y" | EC5ANR=="?" 
						
						*EC5B told stories
						gen act2=. 
						capture replace act2 = 1 if EC5BA=="A" | EC5BB=="B" | EC5BX=="X"
						capture replace act2 = 0 if EC5BY=="Y" | EC5BNR=="?" 
						
						*EC5C sang songs
						gen act3=. 
						capture replace act3 = 1 if EC5CA=="A" | EC5CB=="B" | EC5CX=="X"
						capture replace act3 = 0 if EC5CY=="Y" | EC5CNR=="?" 
						
						*EC5D took outside
						gen act4=. 
						capture replace act4 = 1 if EC5DA=="A" | EC5DB=="B" | EC5DX=="X"
						capture replace act4 = 0 if EC5DY=="Y" | EC5DNR=="?"
						
						*EC5E played with
						gen act5=. 
						capture replace act5 = 1 if EC5EA=="A" | EC5EB=="B" | EC5EX=="X"
						capture replace act5 = 0 if EC5EY=="Y" | EC5ENR=="?"
						
						*EC5F named or counted
						gen act6=. 
						capture replace act6 = 1 if EC5FA=="A" | EC5FB=="B" | EC5FX=="X"
						capture replace act6 = 0 if EC5FY=="Y" | EC5FNR=="?"
						
						*NOW generate variable that adds then one dummy for those that did at least 4 
						
						egen sumofact= rowtotal(act1 act2 act3 act4 act5 act6)
						
						gen early_stimulated = 1 if sumofact >= 4 & inrange(CAGE, 24, 59)
						replace early_stimulated = 0 if  sumofact < 4 & inrange(CAGE, 24, 59)

				capture label define early_stimulated 0 "Not enough activities" 1 "Stimulated enough"  
				label value early_stimulated early_stimulated
				
				mean early_stimulated [aw= CHWEIGHT]
				
				
						*Make line for country avg
						
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\loopings"
						tabout surveyname early_stimulated using early_stimulated.xls [aw= CHWEIGHT] ,  c(row) append nototal  f(2)

												
						clear

			}
		else { 
		di "No FLL module"
			} 
		
}