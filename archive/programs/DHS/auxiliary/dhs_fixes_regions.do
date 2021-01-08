set more off

*All to lowercase
replace region= lower(region)
replace region=stritrim(region)
replace region=strltrim(region)
replace region=strrtrim(region)

*-- Eliminates alpha-numeric characters
replace region = subinstr(region, "-", " ",.) 
replace region = subinstr(region, "ă", "a",.)
replace region = subinstr(region, "?", "e",.)
replace region = subinstr(region, "Ą", "i",.)
replace region = subinstr(region, "˘", "o",.)
replace region = subinstr(region, "¤", "n",.)
replace region = subinstr(region, "ń", "n",.)
replace region = subinstr(region, "ę", "e",.)
replace region = subinstr(region, "č", "e",.)
replace region = subinstr(region, "..", " ",.)

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

*-- Especific changes (1)
replace region = subinstr(region, "reste quest", "reste ouest",.)
replace region = subinstr(region, "nord quest", "nord ouest",.)
replace region = subinstr(region, "sumatera", "sumatra",.)
replace region = subinstr(region, "atl ntico", "atlantico",.)
replace region = subinstr(region, "matebeleland", "matabeleland",.)
*replace region = subinstr(region, "", "",.)

*-- Especific changes (2)
replace region="zanzibar south" if region=="zanziba south"
replace region="butha buthe" if region=="butha bothe"|region=="botha bothe"
replace region="dar es salaam" if region=="dar es salam"
replace region="qacha's nek" if region=="qasha's nek"
replace region="siem reap" if region=="siem reab"
replace region="sanchez ramirez" if region=="s nchez ramirez"
replace region="svay rieng" if region=="svaay rieng"
replace region="maria trinidad sanchez" if region=="maria trinidad s nchez"
replace region="el seibo" if region=="el seybo"
replace region="san jose de ocoa" if region=="san jos de ocoa"
replace region="addis ababa" if region=="addis abeba"|region=="addis adaba"
replace region="afar" if region=="affar"
replace region="grand anse" if region=="grand'anse"|region=="grande anse"
replace region="hauts bassins" if region=="hauts basins"
replace region="kampong cham" if region=="kampong chaam"
replace region="kandal" if region=="kandaal"

*Country specific changes (After seeing regions country by country)
replace region="sar-e pul" if region=="sar e pul" & country=="Afghanistan"
replace region="rajshahi" if (region=="rajashahi"|region=="rajshani") & country=="Bangladesh"
replace region="kampong thom" if region=="kampong thum" & country=="Cambodia"
replace region="ouaddai" if region=="ouaddaď" & country=="Chad"
replace region="oueme" if region=="queme" & country=="Benin" 
replace region="prey veng" if region=="prey veaeng" & country=="Cambodia"
replace region="battambang & pailin" if region=="battambang & krong pailin" & country=="Cambodia"
replace region="kampot & kep" if region=="kampot & krong kep" & country=="Cambodia"
replace region="borkou/ennedi/tibesti" if region=="b. e. t." & country=="Chad"
replace region="kasai occidental" if region=="kasaď occident" & country=="DRCongo"
replace region="kasai oriental" if region=="kasaď oriental" & country=="DRCongo"
replace region="samana" if (region=="saman "|region=="saman") & country=="DominicanRepublic" // check again
for X in any 0 i ii iii iv v vi vii viii: replace region="region X" if region=="X" & country=="DominicanRepublic"
for X in any urban rural: replace region="lower egypt X" if (region=="le X"|region=="X le") & country=="Egypt"
for X in any urban rural: replace region="upper egypt X" if (region=="ue X"|region=="X ue") & country=="Egypt"
replace region="addis ababa" if region=="addis" & country_year=="Ethiopia_2000"
replace region="benishangul gumuz" if (region=="ben gumz"|region=="benishangul") & country=="Ethiopia"
replace region="oromia" if region=="oromiya" & country=="Ethiopia"
replace region="snnpr" if region=="snnp" & country=="Ethiopia"
replace region="andhra pradesh" if region=="[ap] andhra pradesh" & country=="India"
replace region="arunachal pradesh" if region=="[ar] arunachal pradesh" & country=="India"
replace region="assam" if region=="[as] assam" & country=="India"
replace region="bihar" if region=="[bh] bihar" & country=="India"
replace region="chhattisgarh" if region=="[ch] chhattisgarh" & country=="India"
replace region="delhi" if region=="[dl] delhi" & country=="India"
replace region="gujarat" if region=="[gj] gujarat" & country=="India"
replace region="goa" if region=="[go] goa" & country=="India"
replace region="himachal pradesh" if region=="[hp] himachal pradesh" & country=="India"
replace region="haryana" if region=="[hr] haryana" & country=="India"
replace region="jharkhand" if region=="[jh] jharkhand" & country=="India"
replace region="jammu and kashmir" if region=="[jm] jammu and kashmir" & country=="India"
replace region="karnataka" if region=="[ka] karnataka" & country=="India"
replace region="kerala" if region=="[ke] kerala" & country=="India"
replace region="meghalaya" if region=="[mg] meghalaya" & country=="India"
replace region="maharashtra" if region=="[mh] maharashtra" & country=="India"
replace region="manipur" if region=="[mn] manipur" & country=="India"
replace region="madhya pradesh" if region=="[mp] madhya pradesh" & country=="India"
replace region="mizoram" if region=="[mz] mizoram" & country=="India"
replace region="nagaland" if region=="[na] nagaland" & country=="India"
replace region="orissa" if region=="[or] orissa" & country=="India"
replace region="punjab" if region=="[pj] punjab" & country=="India"
replace region="rajasthan" if region=="[rj] rajasthan" & country=="India"
replace region="sikkim" if region=="[sk] sikkim" & country=="India"
replace region="tamil nadu" if region=="[tn] tamil nadu" & country=="India"
replace region="tripura" if region=="[tr] tripura" & country=="India"
replace region="uttaranchal" if region=="[uc] uttaranchal" & country=="India"
replace region="uttar pradesh" if region=="[up] uttar pradesh" & country=="India"
replace region="west bengal" if region=="[wb] west bengal" & country=="India"
replace region="central sulawesi" if region=="cenrtal sulawesi" & country=="Indonesia"
replace region="central" if region=="central region" & country=="Malawi"
replace region="northern" if (region=="north"|region=="northern region") & country=="Malawi"
replace region="southern" if (region=="south"|region=="southern region") & country=="Malawi"
replace region="i ilocos" if region=="i ilocos region" & country=="Philippines"
replace region="v bicol" if region=="v bicol region" & country=="Philippines"
replace region="xi davao" if region=="xi davao peninsula" & country=="Philippines"
replace region="kigali city (pvk)" if region=="kigali ville (pvk)" & country=="Rwanda"
replace region="kigali city" if region=="ville de kigali" & country=="Rwanda"
replace region="ziguinchor" if region=="zuguinchor" & country=="Senegal"
for X in any pemba unguja: replace region="X north" if region=="kaskazini X" & country=="URTanzania"
for X in any pemba unguja: replace region="X south" if region=="kusini X" & country=="URTanzania"
replace region="north western" if region=="northwestern" & country=="Zambia"
replace region="aceh" if region=="di aceh" & country=="Indonesia"
replace region="yogyakarta" if region=="di yogyakarta" & country=="Indonesia"
replace region="jakarta" if region=="dki jakarta" & country=="Indonesia"
*Indonesia: Utara=North, Selatan=South, Timur=East, Barat=west,  Tengha=Central
for X in any sulawesi papua: replace region="west X" if region=="X barat" & country=="Indonesia"
replace region="north maluku" if region=="maluku utara" & country=="Indonesia"
replace region="amoron'i mania" if region=="anamoroni'i mania" & country=="Madagascar"

replace region="Barima Waini" if region=="region 1" & country=="Guyana"
replace region="Pomeroon Supenaam" if region=="region 2" & country=="Guyana"
replace region="Essequibo Islands West Demerara" if region=="region 3" & country=="Guyana"
replace region="Demerara Mahaica" if region=="region 4" & country=="Guyana"
replace region="Mahaica Berbice" if region=="region 5" & country=="Guyana"
replace region="East Berbice Corentyne" if region=="region 6" & country=="Guyana"
replace region="Cuyuni Mazaruni" if region=="region 7" & country=="Guyana"
replace region="Potaro Siparuni" if region=="region 8" & country=="Guyana"
replace region="Upper Takutu Upper Essequibo" if region=="region 9" & country=="Guyana"
replace region="Upper Demerara Berbice" if region=="region 10" & country=="Guyana"

replace region="nord" if region=="north" & country=="Burundi"
replace region="sud" if region=="south" & country=="Burundi"
replace region="ouest" if region=="west" & country=="Burundi"
replace region="Sud (Sans Ville D'Abidjan)" if region=="sud sans abidjan" & country=="CotedIvoire"
replace region="Province Orientale" if region=="orientale" & country=="DRCongo"
replace region="Jalal-Abad" if region=="djalal abad" & country=="Kyrgyzstan"
replace region="osh" if region=="osh oblast" & country=="Kyrgyzstan"
replace region="kigali rural" if (region=="kigali ngali"|region=="kigali rurale") & country=="Rwanda"
replace region="Kigali City" if region=="kigali city (pvk)" & country=="Rwanda"
for X in any east north south west: replace region="X" if region=="Xern" & country=="SierraLeone"
replace region="DRD" if region=="drs" & country=="Tajikistan"
replace region="lome" if region=="grande agglomeration de lome" & country=="Togo"
replace region="maritime" if region=="maritime (sans agglomeration de lome)" & country=="Togo"
replace region="south east" if region=="southeast" & country=="VietNam"
replace region =subinstr(region, "regiao ", "",.) if country=="SaoTomeandPrincipe"
replace region="principe" if region=="do principe" & country=="SaoTomeandPrincipe"
replace region="north eastern" if region=="northeastern" & country=="Kenya"

replace region = subinstr(region, "north", "nord",.) if country=="Haiti"
replace region = subinstr(region, "south", "sud",.) if country=="Haiti"
replace region = subinstr(region, "east", "est",.) if country=="Haiti"
replace region = subinstr(region, "west", "ouest",.) if country=="Haiti"

*After the proper...
*replace region="" if region=="" & country==""

replace region=proper(region) 


replace region = subinstr(region, "Ii ", "II ",.) if country=="Philippines"
replace region = subinstr(region, "Iii ", "III ",.) if country=="Philippines"
replace region = subinstr(region, "Iv ", "IV ",.) if country=="Philippines"
replace region = subinstr(region, "Iva ", "IVa ",.) if country=="Philippines" 
replace region = subinstr(region, "Ivb ", "IVb ",.) if country=="Philippines"
replace region = subinstr(region, "Vi ", "VI ",.) if country=="Philippines"
replace region = subinstr(region, "Vii ", "VII ",.) if country=="Philippines"
replace region = subinstr(region, "Viii ", "VIII ",.) if country=="Philippines"
replace region = subinstr(region, "Ix ", "IX ",.) if country=="Philippines"
replace region = subinstr(region, "Xi ", "XI ",.) if country=="Philippines"
replace region = subinstr(region, "Xii ", "XII ",.) if country=="Philippines"
replace region = subinstr(region, "Xiii ", "XIII ",.) if country=="Philippines"

replace region = subinstr(region, " Iii", " III",.) if country=="DominicanRepublic"
replace region = subinstr(region, " Ii", " II",.) if country=="DominicanRepublic" 
replace region = subinstr(region, " Iv", " IV",.) if country=="DominicanRepublic"
replace region = subinstr(region, " Viii", " VIII",.) if country=="DominicanRepublic"
replace region = subinstr(region, " Vii", " VII",.) if country=="DominicanRepublic"
replace region = subinstr(region, " Vi", " VI",.) if country=="DominicanRepublic"

replace region="Amoron'i Mania" if region=="Amoron'I Mania"
replace region="NWFP" if region=="Nwfp"
replace region="Qacha's Nek" if region=="Qacha'S Nek"
replace region="Sar-e Pul" if region=="Sar-E Pul"
replace region="SNNPR" if region=="Snnpr"

replace region="Sa'dah" if region=="Sadah" & country=="Yemen"
replace region="Sana'a" if region=="Sanaa" & country=="Yemen"
replace region="Sana'a City" if region=="Sanaa City" & country=="Yemen"
replace region="Raymah" if region=="Reimah" & country=="Yemen"
replace region="Lahej" if region=="Lahj" & country=="Yemen"
replace region="Al Mahwit" if region=="Al Mhweit" & country=="Yemen"
replace region="Al Mahrah" if region=="Al Mhrah" & country=="Yemen"

replace region="Mohale's Hoek" if region=="Mohale'S Hoek" & country=="Lesotho"
replace region="DRD" if region=="Drd" & country=="Tajikistan"
