set more off

foreach var of varlist ethnicity religion {
	*-- All to lowercase
	replace `var'= lower(`var')
	replace `var'=stritrim(`var')
	replace `var'=strltrim(`var')
	replace `var'=strrtrim(`var')

	*-- Eliminates alpha-numeric characters
	replace `var' = subinstr(`var', "-", " ",.) 
	replace `var' = subinstr(`var', "ă", "a",.)
	replace `var' = subinstr(`var', "ĂŁ", "a",.)
	replace `var' = subinstr(`var', "ĂŠ", "e",.)
	replace `var' = subinstr(`var', "?", "e",.)
	replace `var' = subinstr(`var', "Ą", "i",.)
	replace `var' = subinstr(`var', "˘", "o",.)
	replace `var' = subinstr(`var', "¤", "n",.)
	replace `var' = subinstr(`var', "ń", "n",.)
	replace `var' = subinstr(`var', "ę", "e",.)
	replace `var' = subinstr(`var', "č", "e",.)
	replace `var' = subinstr(`var', "..", " ",.)
	replace `var' = subinstr(`var', "ö", "o",.)

	*-- Eliminates accents
	replace `var' = subinstr(`var', "á", "a",.)
	replace `var' = subinstr(`var', "é", "e",.)
	replace `var' = subinstr(`var', "í", "i",.)
	replace `var' = subinstr(`var', "ó", "o",.)
	replace `var' = subinstr(`var', "ú", "u",.)
	replace `var'=stritrim(`var')
	replace `var'=strltrim(`var')
	replace `var'=strrtrim(`var')
}

	foreach var of varlist ethnicity {
*-- Other common ocurrences
	replace `var' = subinstr(`var', " et ", " and ",.) 
	replace `var' = subinstr(`var', " & ", " and ",.)
	replace `var' = subinstr(`var', " ou ", "/",.)
}	


*************************
*	FIXING ETHNICITY
*************************
replace ethnicity="" if ethnicity=="."
replace ethnicity="kazakh" if ethnicity=="kazak"
replace ethnicity="roma" if ethnicity=="roma(gypsy)" 
replace ethnicity="indigenous" if ethnicity=="indigena" 
replace ethnicity="sonrai/djerma" if ethnicity=="sonraď/djerma" & country=="Mali"
replace ethnicity="mixed" if ethnicity=="mixed race"

replace ethnicity="don't know" if ethnicity=="dk"
replace ethnicity="doesn't answer" if ethnicity=="desn't want to declare"|ethnicity=="doesn't want to declare"|ethnicity=="non declare/pas de reponse"|ethnicity=="ns/nr"
replace ethnicity="missing" if ethnicity=="manquant"|ethnicity=="missing/dk"|ethnicity=="sin dato"|ethnicity=="sin informacion/ignorado"
replace ethnicity="other ethnic group" if ethnicity=="other ethnic groups" 
replace ethnicity="other" if (ethnicity=="autre"|ethnicity=="other ethnic group"|ethnicity=="other ethnicity"|ethnicity=="others"|ethnicity=="otra"|ethnicity=="otro"|ethnicity=="otro grupo"|ethnicity=="autre groupe ethnique")



***********************	
***  FIXING RELIGION
***********************
replace religion=ethnicity if country_year=="DominicanRepublic_2014"
replace ethnicity="" if religion==ethnicity & country_year=="DominicanRepublic_2014"

replace religion="" if religion=="."
replace religion="animist" if (religion=="anemista"|religion=="animisme"|religion=="animiste")
replace religion="adventist" if religion=="aventist"|religion=="adventista"
replace religion="buddhist" if (religion=="buddhism"|religion=="budhist"|religion=="budismo")
replace religion="catholic" if (religion=="catholique"|religion=="catolica"|religion=="catolico")
replace religion="catholic" if religion=="roman catholics"
replace religion="christian" if (religion=="chretienne"|religion=="christianity")
replace religion="confucianism" if religion=="confucianismo"
replace religion="evangelical" if (religion=="evangelica"|religion=="evangelicos")
replace religion="hindu" if (religion=="hinduism"|religion=="hinduismo")
replace religion="jewish" if (religion=="judaism"|religion=="judaismo")
replace religion="jehovah's witness" if religion=="temoins de jehovah"
replace religion="jehovah's witness" if (religion=="jehovah witness"|religion=="jehovah's witness (other recode)"|religion=="jehovah's witnesses"|religion=="jeova witness"|religion=="testigos de jehova")
replace religion="mormom" if religion=="mormonismo"
replace religion="muslim" if (religion=="musulman"|religion=="musulmane"|religion=="muçulmana")
*those that follow the islam are muslim. Islamist is political
replace religion="muslim" if (religion=="islam"|religion=="islamic"|religion=="islan"|religion=="islamismo")
replace religion="orthodox" if religion=="ortodoxa"
replace religion="pentecostal/charismatic" if religion=="penticostal/charismatic"
replace religion="seventh-day adventist" if (religion=="seventh day adventist"|religion=="sda")

replace religion="don't know" if religion=="dk"
replace religion="missing" if (religion=="manquant"|religion=="missing/dk"|religion=="ns/ em falta"|religion=="omitido/no sabe")
replace religion="none" if (religion=="ninguna"|religion=="ninguna religion"|religion=="no religion"|religion=="sem religiao")
replace religion="no religion/missing" if religion=="pas de religion/manquant"
replace religion="other" if (religion=="other religion"|religion=="others"|religion=="otra religion"|religion=="outra religiao"|religion=="autre religion")
replace religion="other" if (religion=="otra"|religion=="otro")
	
foreach var of varlist ethnicity {
*-- Other common ocurrences
	replace `var' = subinstr(`var', " et ", " & ",.) 
	replace `var' = subinstr(`var', " and ", " & ",.)
}	

for X in any ethnicity religion: replace X=proper(X)

foreach var of varlist ethnicity religion {
	replace `var'="Don't know/No response" if `var'=="Don'T Know/No Response"
	replace `var'="SDA" if `var'=="Sda"
	replace `var'="Jehovah's Witness" if `var'=="Jehovah'S Witness"
	replace `var'="Born Again/Jehovah's Wit/SDA" if `var'=="Born Again/Jehovah'S Wit/Sda"
	replace `var'="CCAP" if `var'=="Ccap"
}
