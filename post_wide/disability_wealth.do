*******

*MICS DISABILITY EXPLOARATION 

*DISABILITY TYPE  BY HOUSEHOLD WEALTH 


local files : dir "C:\Users\mm_barrios-rivera\Desktop\temporary_disability\datasets" files "*.dta"

cd "C:\Users\mm_barrios-rivera\Desktop\temporary_disability\datasets"
	local position 1

foreach file in `files' {
    use `file', clear
	
	gen new_disability_fs= 1 if  disability_trad_fs==1
	replace new_disability_fs= 2 if  disability_trad_fs==0 &  fsdisability=="At least one functional difficulty"
	replace new_disability_fs= 3 if  fsdisability=="No functional difficulty"
	replace new_disability_fs= 9 if  fsdisability==""
	capture label define newdisability 1 "At least one sensory, physical or intellectual difficulty"  2 "At least one other difficulty" 3 "No functional difficulty" 9 "Missing from FS"
	label value new_disability_fs   newdisability
	tab new_di
	tab new_di [aw=fsweight]

	capture rename ln HL1
	capture rename hh1 HH1
	capture rename hh2 HH2
		
    local FILE = upper("`file'")
	tokenize upper(`FILE'),  parse("_")
	di "5=|`5'|, 7=|`7'|, 9=|`9'|"
	
	merge 1:m HH1 HH2 HL1 using  "C:\Users\mm_barrios-rivera\UNESCO\GEM Report - WIDE Data NEW\1_raw_data\\`5'_`7'_MICS\\hl.dta"
	*fre new_di if inrange(HL6, 5, 17)
	*tab  windex5 new_di if inrange(HL6, 5, 17),  row nofreq

	tabout windex5 new_di [aw=fsweight] using test.xlsx, ///
	append c(row) f(2p) style(xlsx) ///
	 title(MICS `5' `7') ///
	location(`position' 1) lwidth(25) cwidth(15) ///
	sheet(Disability by wealth - MICS)

	local position = `position' + 15

	clear
}


