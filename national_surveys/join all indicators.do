**Joining all national surveys

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\Datasets to update WIDE\Other surveys\INDICATORS"
	fs *.dta
	append using `r(files)', force
	compress
	save "nationalsurveys.dta", replace