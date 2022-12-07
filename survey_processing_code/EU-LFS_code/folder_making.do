
levelsof isocode3, local(isocodes) clean 


foreach survey of local isocodes {
		 local ycode 2014
		 		 forvalues num=1/5 {
				 		  local ycode = `ycode' + 1
		  di "Now creating" " `survey'" " `ycode'"
		capture mkdir  "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`survey'_`ycode'_LFS"	
		}
		     }
	 

*****20/01 version for creating folders and copying files into it (WORKS ON UNESCO COMPUTER)

* Do 1998-2014 folders for those countries most (see countrycodes xlsx file)
*Import Countrycodes as a dataset

capture drop bothisos 
egen bothisos = concat(eucode isocode3), punct(_)

capture drop bothisos_9804
gen bothisos_9804=bothisos  if firstyearavailablein1998file==1998
levelsof bothisos_9804, local(bothisos_9804)  clean
display "`r(levels)'"

foreach pairofisos of local bothisos_9804 {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1997
		 		 forvalues num=1/16 {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1998_onwards\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }
			
* Do particular year for these countries up to 2014
// Bulgaria	BGR	x		2000
// Cyprus	CYP	x		1999
// Croatia	HRV	x		2002
// Malta	MLT	x		2009+

local bothisos BG_BGR
display "`bothisos'"

foreach pairofisos of local bothisos {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1999
		 		 forvalues num=1/16 {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  cd "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  *Now copy the file
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1998_onwards\\`1'`yearcode'_y.csv" "`1'`yearcode'_y.csv", replace
		}
		     }
			 
local bothisos CY_CYP
display "`bothisos'"

foreach pairofisos of local bothisos {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1998
		 		 forvalues num=1/16 {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  cd "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  *Now copy the file
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1998_onwards\\`1'`yearcode'_y.csv" "`1'`yearcode'_y.csv", replace
		}
		     }
			 
			 
local bothisos HR_HRV
display "`bothisos'"

foreach pairofisos of local bothisos {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 2001
		 *Change the year in the middle with the year of the oldest dataset
		 local n = 2014 - 2002 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  cd "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  *Now copy the file
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1998_onwards\\`1'`yearcode'_y.csv" "`1'`yearcode'_y.csv", replace
		}
		     }
			 
local bothisos MT_MLT
display "`bothisos'"

foreach pairofisos of local bothisos {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 2008
		 *Change the year in the middle with the year of the oldest dataset
		 local n = 2014 - 2009 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  cd "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  *Now copy the file
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1998_onwards\\`1'`yearcode'_y.csv" "`1'`yearcode'_y.csv", replace
		}
		     }
			 
// eucode	country	isocode3	First year available in 1983 file
// BE	Belgium	BEL	1983
// DE	Germany	DEU	1983
// DK	Denmark	DNK	1983
// EL	Greece	GRC	1983
// FR	France	FRA	1983
// IE	Ireland	IRL	1983
// IT	Italy	ITA	1983
// LU	Luxembourg	LUX	1983
// NL	Netherlands	NLD	1983
// UK	United Kingdom	GBR	1983

capture drop bothisos_80s
gen bothisos_80s=bothisos  if firstyearavailablein1983file==1983
replace bothisos_80s="" if eucode=="NL"
levelsof bothisos_80s, local(bothisos_80s)  clean
display "`r(levels)'"

foreach pairofisos of local bothisos_80s {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1982
		  *Change the year in the middle with the year of the oldest dataset
		 local n = 1997 - 1983 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1983_1997\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }
			 
* Do particular year for these up to 1997 for these
// eucode	country	isocode3	First year available in 1983 file
// AT	Austria	AUT	1995
// IS	Iceland	ISL	1995
// FI	Finland	FIN	1995
// SE	Sweden	SWE	1995
// NO	Norway	NOR	1995

capture drop bothisos_80s
gen bothisos_80s=bothisos  if firstyearavailablein1983file==1995
levelsof bothisos_80s, local(bothisos_80s)  clean
display "`r(levels)'"

foreach pairofisos of local bothisos_80s {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1994
		  *Change the year in the middle with the year of the oldest dataset
		 local n = 1997 - 1995 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1983_1997\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }

// CZ	Czechia	CZE	1997
// EE	Estonia	EST	1997
// RO	Romania	ROU	1997
// PL	Poland	POL	1997

capture drop bothisos_80s
gen bothisos_80s=bothisos  if firstyearavailablein1983file==1997
levelsof bothisos_80s, local(bothisos_80s)  clean
display "`r(levels)'"

foreach pairofisos of local bothisos_80s {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1996
		  *Change the year in the middle with the year of the oldest dataset
		 local n = 1997 - 1997 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1983_1997\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }


// ES	Spain	ESP	1986
// PT	Portugal	PRT	1986

capture drop bothisos_80s
gen bothisos_80s=bothisos  if firstyearavailablein1983file==1986
levelsof bothisos_80s, local(bothisos_80s)  clean
display "`r(levels)'"

foreach pairofisos of local bothisos_80s {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1985
		  *Change the year in the middle with the year of the oldest dataset
		 local n = 1997 - 1986 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1983_1997\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }


// HU	Hungary	HUN	1996
// CH	Switzerland	CHE	1996
// SI	Slovenia	SVN	1996


capture drop bothisos_80s
gen bothisos_80s=bothisos  if firstyearavailablein1983file==1996
levelsof bothisos_80s, local(bothisos_80s)  clean
display "`r(levels)'"

foreach pairofisos of local bothisos_80s {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1995
		  *Change the year in the middle with the year of the oldest dataset
		 local n = 1997 - 1996 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1983_1997\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }

			 
// NL Netherlands NLD 1985 1987

local bothisos NL_NLD
display "`bothisos'"

foreach pairofisos of local bothisos {
		di "Now processing "  "`pairofisos'"
		tokenize "`pairofisos'", parse(_)
		di "`1'" " is the iso code2"
		di "`3'" " is the iso code3"
		 local yearcode 1986
		  *Change the year in the middle with the year of the oldest dataset
		 local n = 1997 - 1987 + 1
		 		 forvalues num=1/`n' {
				 		  local yearcode = `yearcode' + 1
						  di "Now creating" " `3'" " `yearcode'" " folder"
						  capture mkdir  "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS"
						  copy "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\2021 from OurDrive\Unzipped\\`1'_YEAR_1983_1997\\`1'`yearcode'_y.csv" "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets\\`3'_`yearcode'_LFS\\`1'`yearcode'_y.csv", replace
		}
		     }

			 cd "C:\Users\mm_barrios-rivera\Documents\test test"
	