*LEARNING IN YOUR LANGUAGE LOOP

// Marcela it would be great if you could look into these questions FL7 and FL9 from the MICS foundational learning module and:
	// Confirm that you comes up with the same results (more or less) as in Figure 5.2 from last year's Spotlight (see attached)
	// Add new MICS surveys with foundational learning module, if any, since last year
	// Disaggregate the results (which currently are for `end of primary') by:
		// grade attended (expecting to find slightly more children learning in their home language in early grades)
		// wealth (expecting to find bigger disparity than by location

clear 
use "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\spotlight_surveys.dta"
*keep only mics

keep if survey=="MICS" & round==6

*drop TUN because FL9 has all missing records
drop if iso=="TUN"
keep if iso=="COD" | iso=="MWI" |iso=="NGA" | iso=="ZWE"

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
		use "fs.dta", clear		
		capture rename *, upper		
		gen iso_code3=upper("`isocode'")
		gen year="`year'"
		
		capture confirm variable FL7 
			if _rc == 0 {
						*fre FL7 
						*fre FL9
						*tab CB5A CB5B
						*tab CB5A CB5B, nol
						*primary is not CB5A==1 IN...
			*tcd 10
			*nga 11
			*cod 10
												
						*generate dummy variable of learning in the same language spoken at home 
						gen same_language=. 
						
						capture replace same_language = 0 if FL7 != FL9 & FL7!=. & FL9!=.
						capture replace same_language = 0 if FL7 != FL9A & FL7!=. & FL9A!=. & iso=="TCD"

						capture replace same_language = 1 if FL7 == FL9 & FL7!=. 
						capture replace same_language = 1 if FL7 == FL9A & FL7!=.  & iso=="TCD"

						*home language other dk na etc 
						replace same_language = . if inlist(FL7, 96, 98, 99)
					   replace same_language = . if inlist(FL7, 7,8,9) & iso=="ZWE"
					   replace same_language = . if inlist(FL7, 7,8,9) & iso=="LSO"
					   replace same_language = . if inlist(FL7, 7,8,9) & iso=="COD"
					
					*	school language other dk na etc
						capture replace same_language = . if inlist(FL9, 6, 8, 9)
						capture replace same_language = . if inlist(FL9, 96, 98, 99) & iso=="GHA"
						capture replace same_language = . if inlist(FL9, 96, 98, 99) & iso=="NGA"
						capture replace same_language = . if inlist(FL9, 7, 8, 9) & iso=="ZWE"
					*TCD has FL9A only ==1 
						capture replace same_language = . if inlist(FL9A, 6, 8, 9) & iso=="TCD"


				capture label define language 0 "Different language at home and school" 1 "Same language"  
				label value same_language language

						
/*
						*Confirm 
						*tab same_language [aw=fsweight] 
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						tabout same_language using same_language_total.xls [aw= FSWEIGHT] ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(freq col) append f(2)
												
						*By grade
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==1 ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==10 & iso=="TCD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						
						*By wealth windex5
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language WINDEX5  using same_language_bywealth.xls [aw= FSWEIGHT],  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language WINDEX5  using same_language_bywealth.xls [aw= FSWEIGHT] if CB5A==10 & iso=="TCD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language WINDEX5  using same_language_bywealth.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language WINDEX5  using same_language_bywealth.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)

						*By location HH6 area
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language HH6 using same_language_bylocation.xls [aw= FSWEIGHT] if CB5A==1 ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language HH6 using same_language_bylocation.xls [aw= FSWEIGHT] if CB5A==10 & iso=="TCD",  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language HH6 using same_language_bylocation.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD" ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language HH6 using same_language_bylocation.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA" ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)

						*By grade
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==1 ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==10 & iso=="TCD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_bygrade.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
*/
						
/*
						*By region
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language HH7  using same_language_byregion.xls [aw= FSWEIGHT] if CB5A==1 ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language HH7  using same_language_byregion.xls [aw= FSWEIGHT] if CB5A==10 & iso=="TCD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language HH7  using same_language_byregion.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language HH7  using same_language_byregion.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						
						*By age 5-17
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language CB3  using same_language_byage.xls [aw= FSWEIGHT] if CB5A==1 ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB3  using same_language_byage.xls [aw= FSWEIGHT] if CB5A==10 & iso=="TCD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB3  using same_language_byage.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
						capture tabout same_language CB3  using same_language_byage.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  ,  cells(freq col) h3(`isocode'-`year'-`survey') layout(col) append  f(2)
*/



						*The only thing missing was the grade by location (urban/rural) disaggregation. Can you try the four countries with large samples: DRC, Malawi, Nigeria an Zimbabwe?
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language CB5B  using same_language_gradexlocation.xls [aw= FSWEIGHT] if CB5A==1 & HH6==1,  cells(freq col) h3(`isocode'-`year'-`survey'-urban) layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_gradexlocation.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD" & HH6==1 ,  cells(freq col) h3(`isocode'-`year'-`survey'-urban) layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_gradexlocation.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  & HH6==1,  cells(freq col) h3(`isocode'-`year'-`survey'-urban) layout(col) append  f(2)
						
						cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\spot-lighting\samelanguage"
						capture tabout same_language CB5B  using same_language_gradexlocation.xls [aw= FSWEIGHT] if CB5A==1 & HH6==2,  cells(freq col) h3(`isocode'-`year'-`survey'-rural) layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_gradexlocation.xls [aw= FSWEIGHT] if CB5A==10 & iso=="COD" & HH6==2 ,  cells(freq col) h3(`isocode'-`year'-`survey'-rural) layout(col) append  f(2)
						capture tabout same_language CB5B  using same_language_gradexlocation.xls [aw= FSWEIGHT] if CB5A==11 & iso=="NGA"  & HH6==2,  cells(freq col) h3(`isocode'-`year'-`survey'-rural) layout(col) append  f(2)
						
						
						clear

			}
		else { 
		di "No FLL module"
			} 
		
}