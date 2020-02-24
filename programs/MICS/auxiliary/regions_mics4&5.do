*- Need to check what is the real variable identifying the region
*-hh7: Saint Lucia doesn't have regions
replace hh7=region if country_year=="LaoPDR_2011" // 3 categories
replace hh7=region if country_year=="Malawi_2013"
replace hh7=region if country_year=="Uruguay_2012"

ren region district 
ren hh7 region // the variable hh7 is THE ONE that indicates region

*All to lowercase
replace region= lower(region)
replace region=stritrim(region)
replace region=strltrim(region)
replace region=strrtrim(region)

*-- Eliminates alpha-numeric characters
replace region = subinstr(region, "-", " ",.) 
replace region = subinstr(region, "ă", "a",.)
replace region = subinstr(region, "ĂŁ", "a",.)
replace region = subinstr(region, "?", "e",.)
replace region = subinstr(region, "Ą", "i",.)
replace region = subinstr(region, "˘", "o",.)
replace region = subinstr(region, "¤", "n",.)
replace region = subinstr(region, "ń", "n",.)
replace region = subinstr(region, "ę", "e",.)
replace region = subinstr(region, "č", "e",.)
replace region = subinstr(region, "..", " ",.)
replace region = subinstr(region, "ö", "o",.)

*-- Eliminate accents
replace region = subinstr(region, "á", "a",.)
replace region = subinstr(region, "é", "e",.)
replace region = subinstr(region, "í", "i",.)
replace region = subinstr(region, "ó", "o",.)
replace region = subinstr(region, "ú", "u",.)
replace region=stritrim(region)
replace region=strltrim(region)
replace region=strrtrim(region)

*- Common occurrences
replace region = subinstr(region, " ou ", "/",.)

*Changes
replace region="federation of bosnia and herzegovina" if region=="fbih" & country=="BosniaandHerzegovina"
replace region="republic of srpska" if region=="rs" & country=="BosniaandHerzegovina"
replace region="district of brcko" if region=="bd" & country=="BosniaandHerzegovina"
replace region="la habana" if region=="ciudad habana" & country=="Cuba"
replace region="kingston metropolitan area" if region=="kma" & country=="Jamaica"
replace region="kostanay" if region=="kostanai" & country=="Kazakhstan"
replace region="karaganda" if region=="karagandy" & country=="Kazakhstan"
replace region="zhambyl" if region=="zhambul" & country=="Kazakhstan"
replace region="south kazakhstan" if region=="south kasakhstan" & country=="Kazakhstan"
replace region="almaty" if region=="almaty oblast" & country=="Kazakhstan" // "oblast" means region. Different from city
replace region="karagandy" if region=="karaganda" & country=="Kazakhstan"
replace region="west kazakhstan" if region=="western kazakhstan" & country=="Kazakhstan"
replace region="aktobe" if region=="aktubinsk" & country=="Kazakhstan"
replace region="mangystau" if region=="mangistau" & country=="Kazakhstan"
replace region="osh" if region=="osh oblast" & country=="Kyrgyzstan"
replace region="fct (abuja)" if region=="fct abuja" & country=="Nigeria"
replace region="deir el-balah" if (region=="dier el balah"|region=="deir el balah") & country=="Palestine"
replace region="jericho" if region=="jericho and al aghwar" & country=="Palestine"
replace region = subinstr(region, "regiao ", "",.) if country=="SaoTomeandPrincipe"
replace region="vojvodina" if region=="ap vojvodina" & country=="Serbia"
replace region="belgrade" if region=="city of belgrade" & country=="Serbia"
replace region="white nile" if region=="wite nile" & country=="Sudan"
replace region = subinstr(region, "darfor", "darfur",.) if country=="Sudan"
replace region="northern" if region=="north" & country=="Thailand"
replace region="southern" if region=="south" & country=="Thailand"
replace region="northeastern" if region=="northeast" & country=="Thailand"
replace region="northern midlands and mountain area" if region=="northen midlands and mountain area" & country=="VietNam"

replace region = subinstr(region, " region", "",.) if country=="Belarus"
replace region="jalal-abad" if region=="djalal abad" & country=="Kyrgyzstan"
replace region="hodh ech charghi" if region=="hodh charghy" & country=="Mauritania"
replace region="hodh el gharbi" if region=="hodh gharby" & country=="Mauritania"
replace region="tiris zemmour" if region=="tirs ezemour" & country=="Mauritania"
replace region="southeast" if region=="south and east serbia" & country=="Serbia"
replace region = subinstr(region, " velayat", "",.) if country=="Turkmenistan"
replace region="centre" if region=="centre (sans yaounde)" & country=="Cameroon"
replace region="littoral" if region=="littoral (sans douala)" & country=="Cameroon"
replace region="sud (sans ville d'abidjan)" if region=="sud sans ville d'abidjan" & country=="CotedIvoire"
replace region="ashanti" if region=="asante" & country=="Ghana"

*replace region="" if region=="" & country==""

replace region="Borkou/Ennedi/Tibesti" if region=="bet" & country=="Chad"
replace region="N'Djamena" if region=="ndjamena" & country=="Chad"
replace region="principe" if region=="autonoma de principe" & country=="SaoTomeandPrincipe"

replace region="batha" if region=="bhata" & country=="Chad"
replace region="wadi fira" if region=="wad fira" & country=="Chad"
replace region="Ombella M'Poko" if region=="ombella mpoko" & country=="CentralAfricanRepublic"

replace region=proper(region) 

replace region="Region CH" if region=="Region Ch"
replace region="Region NE" if region=="Region Ne"
replace region="Region SE" if region=="Region Se"
replace region="DF Edo. de Mexico" if region=="Df Edo Mexico"
replace region="FCT (Abuja)" if region=="Fct (Abuja)"
replace region = subinstr(region, "terai", "Terai",.) if country=="Nepal"
