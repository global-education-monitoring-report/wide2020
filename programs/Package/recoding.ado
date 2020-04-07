
program define mics_recoding

*Creating categories

*Sex
rename hl4 sex
	recode sex (2=0) (9=.) (3/4=.)
	label define sex 0 "female" 1 "male"
	label values sex sex

*Age
rename hl6 age
generate ageA = age-1
generate ageU = age

*Urban
replace hh6 = lower(hh6)
generate urban=.
	replace urban = 0 if regexm(hh6, "rural") | regexm(hh6,"non-municipal")
	replace urban = 1 if regexm(hh6, "urba") | regexm(hh6, "municipal") | regexm(hh6, "kma") |regexm(hh6, "capital") | regexm(hh6, "center")
	replace urban = 2 if regexm(hh6, "camp")
	
label define urban 0 "rural" 1 "urban" 2 "camps"
label values urban urban

*Wealth
rename windex5 wealth

*Weight: already named hhweight

* fix ed3 and ed5 for Palestine 2010
* ed3: 0=Curr. kindergarten; 1=Curr. school; 2=attended school and dropped out 3=attended school and graduated;4=never attended school, 8=don't know 				
* ed5: 1=yes, 2=no, 9=missing
	if country_year == "Palestine_2010" {
		*ed3
		replace ed3 = "yes"        if (ed3 == "0" | ed3 == "1" | ed3 == "2" | ed3 == "3") 
		replace ed3 = "no"         if (ed3 == "4") 
		replace ed3 = "don't know" if (ed3 == "8") 
		*ed5
		replace ed5 = "yes"     if ed5 == "1"
		replace ed5 = "no"      if ed5 == "2"
		replace ed5 = "missing" if ed5 == "9"
	}


*import delimited "$aux_data_path/mics_codset_dictionary.csv", varnames(1) clear
*labeldatasyntax, saving("$data_path/programs/Package/mics_recode.do")
*do mics_recode.do

end
