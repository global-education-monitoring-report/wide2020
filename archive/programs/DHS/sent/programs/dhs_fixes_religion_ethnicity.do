set more off

foreach var of varlist ethnicity religion {
	*All to lowercase
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

	*-- Eliminate accents
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
	replace ethnicity="amhara" if ethnicity=="amharra"
	replace ethnicity="arab" if ethnicity=="arabic"|ethnicity=="arabe"
	replace ethnicity="argobba" if ethnicity=="argoba"|ethnicity=="argobe"
	replace ethnicity="autres pays africans" if ethnicity=="autres pays africains sans spcifier"
	replace ethnicity="bakongo north and south" if ethnicity=="bakongo nord and sud"
	replace ethnicity="bambara" if ethnicity=="bambara." 
	replace ethnicity="bas-kasai and kwilu-kwngo" if ethnicity=="bas-kasai et kwilu-kwngo"
	replace ethnicity="basele-k , man. and kivu" if ethnicity=="basele-k , man. et kivu"
	replace ethnicity="black/mulato/afro-colombian/afro-descendant" if ethnicity=="black/mulato/afro-colombian/afro-descendent"
	replace ethnicity="brahmin" if ethnicity=="brahman"
									
	replace ethnicity="chikunda" if ethnicity=="chicunda"
	replace ethnicity="don't know" if ethnicity=="dk"|ethnicity=="dk, unsure"|ethnicity=="dk/none"|ethnicity=="nsp"	
	replace ethnicity="foreigner" if ethnicity=="foreign/non-congolese"|ethnicity=="foreign"|ethnicity=="stranger"|ethnicity=="stranger  / other"|ethnicity=="abroad idioma"|ethnicity=="etranger" ///
					|ethnicity=="foreign language"|ethnicity=="foreigner"
	replace ethnicity="gourmantche" if ethnicity=="gourmatche"
	replace ethnicity="grusi" if ethnicity=="grussi"
	replace ethnicity="ijaw/ izon" if ethnicity=="ijaw/izon"
	replace ethnicity="ijede" if ethnicity=="ijeme"
	replace ethnicity="kanuri/ beriberi" if ethnicity=="kanuri/beriberi"
	replace ethnicity="kikuyu" if ethnicity=="kikuya"	
	replace ethnicity="mijikenda/ swahili" if ethnicity=="mijikenda/swahili"
	replace ethnicity="muslim" if ethnicity=="musalman"
	replace ethnicity="not senegalese" if ethnicity=="not a senegalese"
	replace ethnicity="ogba" if ethnicity=="ogbo"	
	replace ethnicity="other african country" if ethnicity=="other african"|ethnicity=="other african countries"	
	replace ethnicity="other beninois" if ethnicity=="other beninoise"
	replace ethnicity="peul" if ethnicity=="peulh"
	replace ethnicity="peul and related" if ethnicity=="peulh and related"
	replace ethnicity="pygmy" if ethnicity=="pygmee"
	replace ethnicity="doesn't answer" if ethnicity=="refused to say"
	replace ethnicity="roma" if ethnicity=="gypsy (rom)"|ethnicity=="roma (gypsy)"
	replace ethnicity="sarakole/soninke/marka" if ethnicity=="sarkole/soninke/marka"
	replace ethnicity="somali" if ethnicity=="somalie"
	replace ethnicity="soussou" if ethnicity=="sousou"
	replace ethnicity="taita/ taveta" if ethnicity=="taita/tavate"
	replace ethnicity="ubangi and itimbiri" if ethnicity=="ubangi et itimbiri"
	replace ethnicity="uele lake albert" if ethnicity=="uele lac albert"
	replace ethnicity="ukrainian" if ethnicity=="ukraine"
	replace ethnicity="other" if ethnicity=="others"
	replace ethnicity="maasai" if ethnicity=="masai" & country=="Kenya"
	replace ethnicity="sonrai" if ethnicity=="sonraď" & country=="Mali"
	replace ethnicity="other countries" if (ethnicity=="other african country"|ethnicity=="other nationalities") & country=="Mali"
	replace ethnicity="nkhonde" if ethnicity=="nkonde" & country=="Malawi"
	replace ethnicity="lambya" if ethnicity=="other: lambya" & country=="Malawi"
	replace ethnicity="mang'anja" if ethnicity=="other: mang'anja" & country=="Malawi"
	replace ethnicity="ndali" if ethnicity=="other: ndali" & country=="Malawi"
	replace ethnicity="nyanja" if ethnicity=="other: nyanja" & country=="Malawi"
	replace ethnicity="nyanja" if ethnicity=="nyanga" & country=="Malawi"
	replace ethnicity="other foreign" if ethnicity=="other non sierra leone" & country=="SierraLeone"
	replace ethnicity="creole" if ethnicity=="kriole" & country=="SierraLeone"

	replace ethnicity = subinstr(ethnicity, " (other recode)", "",.) if country=="Philippines"
	replace ethnicity = subinstr(ethnicity, " and related", "",.) if country_year=="Benin_2006"

	replace ethnicity="chabacano" if (ethnicity=="chavakano"|ethnicity=="chavacano"|ethnicity=="chabakano") & country=="Philippines"
	replace ethnicity="boholano" if ethnicity=="boholanon" & country=="Philippines"
	replace ethnicity="kankanaey" if ethnicity=="kankaney" & country=="Philippines"
	replace ethnicity="maguindanaon" if ethnicity=="maguindanawon" & country=="Philippines"
	replace ethnicity="maranao" if ethnicity=="maranso" & country=="Philippines"
	
	replace ethnicity="ukranian" if ethnicity=="ukrainian"
	replace ethnicity="wolof" if ethnicity=="wollof"
	replace ethnicity="taita/taveta" if ethnicity=="taita/ taveta"
	replace ethnicity="sarakole/soninke/marka" if ethnicity=="sarakol/sonink/marka"

	replace ethnicity="don't know/no response" if ethnicity=="dk"|ethnicity=="no sabe"|ethnicity=="not responded"|ethnicity=="refused/dk"|ethnicity=="refused/not stated"

	replace ethnicity="portuguese" if ethnicity=="portugues"
	replace ethnicity="other foreign" if ethnicity=="other foreigners"
	replace ethnicity="lunda (north western)" if ethnicity=="lunda (northwestern)"
	replace ethnicity="gourmantche" if ethnicity=="gourmantch"
	replace ethnicity="mang'anja" if ethnicity=="mang'ana" & country=="Malawi"
	replace ethnicity="tamachek" if ethnicity=="tamacheck"|ethnicity=="tanachek"
	replace ethnicity="tigraway / tigre" if ethnicity=="tigray (tigraway)"
	replace ethnicity="kwangwa" if ethnicity=="kwanga" & country=="Zambia"
	
	replace ethnicity="senoufo" if ethnicity=="snoufo" & country=="BurkinaFaso"
	replace ethnicity="senoufo/minianka" if ethnicity=="snoufo/minianka" & country=="Mali"
	replace ethnicity="gruma" if ethnicity=="gurma" & country=="Ghana"
	replace ethnicity="swaka" if ethnicity=="swawka" & country=="Zambia"

	
	*For countries that have more than 70 categories of ethnicity
	*- Nigeria has 304 categories
	*- Nepal has 76 
	bys country year_folder ethnicity: gen N=_N // for Nigeria, I keep only the ones with more than 1% observations
	bys country year_folder: gen tot=_N // for Nigeria, I keep only the ones with more than 1% observations
	gen percent=(N/tot)*100

	replace ethnicity="other" if percent<1 & ethnicity!="" & country_year=="Nigeria_2013"
	replace ethnicity="other" if percent<1 & ethnicity!="" & country_year=="Nepal_2001"	
	replace ethnicity="other" if percent<1 & ethnicity!="" & country_year=="Nepal_2006"
			 
*Check: Malawi, Nepal, Nigeria, Philippines, SierraLeone

	drop percent N

***********************	
***  FIXING RELIGION
***********************

*tab religion
	encode religion, gen(code_religion)
	replace religion="celestes (celestial church of christ)" if code_religion==1

	replace religion="adventist/jehova" if (religion=="adventist/jehova"|religion=="adventiste/jehova")
	replace religion="adventist" if religion=="aventist"|religion=="adventista"
	replace religion="anglican" if religion=="anglican church"
	replace religion="animist" if religion=="animiste"
	replace religion="armee de salut" if religion=="arme du salut"
	replace religion="buddhist" if (religion=="buddhism"|religion=="budhist")
	replace religion="buddhist/neo-buddhist" if religion=="buddhist/neo buddhist"
	replace religion="catholic" if (religion=="catholique"|religion=="catolica")
	replace religion="catholic/greek catholict" if religion=="catholic/greek cath."|religion=="catholic/greek cath"
	replace religion="christian" if (religion=="christan"|religion=="christianity"|religion=="christrian"|religion=="chretienne")
	replace religion="christian protestant" if (religion=="christian/protesstan")
	replace religion="evangelical" if (religion=="evangelic"|religion=="evangelist"|religion=="lesotho evangelical church"|religion=="evangelica")
	replace religion="evangelical/pentecostal" if religion=="envagelic/petencostal"
	replace religion="hindu" if religion=="hinduism"|religion=="hinduismo"
	replace religion="jewish" if religion=="judaism"
	replace religion="jehovah's witness" if (religion=="jehovah witness"|religion=="jehovah's witness (other recode)"|religion=="jehovah's witnesses"|religion=="jeova witness")
	replace religion="kimbanguist" if (religion=="kibanguist"|religion=="kimbanguiste")
	replace religion="muslim" if (religion=="moslem"|religion=="mulsim"|religion=="muslem"|religion=="muslim/islam"|religion=="muslin"|religion=="muslum"|religion=="musulman"|religion=="musualmane"|religion=="musulmane/islam")
	*those that follow the islam are muslim. Islamist is political
	replace religion="muslim" if (religion=="islam"|religion=="islamic"|religion=="islan"|religion=="islamismo")
	replace religion="seventh-day adventist" if religion=="seventh day adventist"|religion=="sda"
	replace religion="traditional/animist" if (religion=="traditional / animist"|religion==""|religion==""|religion=="traditionnal/animist")
	replace religion="vaudouisant" if religion=="vaudousant"
	replace religion="zionist" if religion=="zion"
	replace religion="zephirin/matsouaniste/ngunza" if religion=="zephirrin/matsouanist/ngunza"
	
	gen temp1=substr(religion, 1, 7)
	replace religion="pentecostal" if (temp1=="penteco"|temp1=="penteco")
	replace religion="protestant" if (temp1=="protest"|temp1=="prostes")
	replace religion="catholic" if temp1=="roman c"
	replace religion="seventh-day adventist" if temp1=="seventh"
	replace religion="traditional" if (temp1=="taditio"|temp1=="traditi")|religion=="tradicionalist"

	replace religion="don't know/no response" if religion=="dk"|religion=="no sabe"|religion=="not responded"|religion=="refused/dk"
	replace religion="no religion/none" if (religion=="no religion"|religion=="no religion/none"|religion=="not religion"|religion=="not religious"|religion=="none"|religion=="no tiene"|religion=="pas de religion"|religion=="sans religion")
	replace religion="other" if (religion=="other religion"|religion=="other religions"|religion=="others"|religion=="otra"|religion=="autre")
	replace religion="other christian" if (religion=="other christians"|religion=="other chritians")
	replace religion="other protestant" if religion=="other protestants"
	replace religion="other traditional" if religion=="other traditional religions"

	*UR Tanzania as special case
	replace religion="muslim" if religion=="1" & country_year=="URTanzania_2004"
	replace religion="catholic" if religion=="2" & country_year=="URTanzania_2004"
	replace religion="protestant" if religion=="3" & country_year=="URTanzania_2004"
	replace religion="none" if religion=="4" & country_year=="URTanzania_2004"
	replace religion="other" if religion=="6" & country_year=="URTanzania_2004"
	replace religion="." if religion=="9" & country_year=="URTanzania_2004"

cap drop tot code_religion temp1
for X in any ethnicity religion: replace X=proper(X)

foreach var of varlist ethnicity religion {
	replace `var'="Don't know/No response" if `var'=="Don'T Know/No Response"
	replace `var'="Don't know" if `var'=="Don'T Know"
	replace `var'="Doesn't answer" if `var'=="Doesn'T Answer"
	replace `var'="SDA" if `var'=="Sda"
	replace `var'="Jehovah's Witness" if `var'=="Jehovah'S Witness"
	replace `var'="Born Again/Jehovah's Wit/SDA" if `var'=="Born Again/Jehovah'S Wit/Sda"
}

