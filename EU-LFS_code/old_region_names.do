**************************
* region_names.do 
**************************

g regionnew =""

* *In 2011, the NUTS1 code of Greece was changed from GR to EL. GR1 was changed to EL5, GR2 to EL6, GR3 to EL3 and GR4 to EL4.
replace region="EL5" if region=="GR1"|region=="EL1"
replace region="EL6" if region=="GR2"|region=="EL2"
replace region="EL3" if region=="GR3"
replace region="EL4" if region=="GR4"

replace regionnew="Voria Ellada" if region=="EL5"
replace regionnew="Kendriki Ellada" if region=="EL6"
replace regionnew="Attiki" if region=="EL3"
replace regionnew="Nisia Egeou, Kriti" if region=="EL4"

replace regionnew="Ostoesterreich" if region=="AT1"
replace regionnew="Suedoesterreich" if region=="AT2"
replace regionnew="Westoesterreich" if region=="AT3"

replace regionnew="Region de Brux.-Capitale/Brux Hoof" if region=="BE1"
replace regionnew="Vlaams Gewest" if region=="BE2"
replace regionnew="Region Wallonne" if region=="BE3"

replace regionnew="Severna I Iztochna Bulgaria" if region=="BG3"
replace regionnew="Yugozapadna I Yuzhna Tsentralna Bu" if region=="BG4"

replace regionnew="Switzerland" if region=="CH0"

replace regionnew="Kibris" if region=="CY0"

replace regionnew="Praha" if region=="CZ01"
replace regionnew="Stredni Cechy" if region=="CZ02"
replace regionnew="Jihozapad" if region=="CZ03"
replace regionnew="Severozapad" if region=="CZ04"
replace regionnew="Severovychod" if region=="CZ05"
replace regionnew="Jihovychod" if region=="CZ06"
replace regionnew="Stredni Morava" if region=="CZ07"
replace regionnew="Moravskoslezsko" if region=="CZ08"

replace regionnew="Danmark" if region=="DK0"

replace regionnew="Eesti" if region=="EE0"

replace regionnew="Galicia" if region=="ES11"
replace regionnew="Principado de Asturias" if region=="ES12"
replace regionnew="Cantabria" if region=="ES13"
replace regionnew="País Vasco" if region=="ES21"
replace regionnew="Comunidad Foral de Navarra" if region=="ES22"
replace regionnew="La Rioja" if region=="ES23"
replace regionnew="Aragon" if region=="ES24"
replace regionnew="Comunidad de Madrid" if region=="ES30"
replace regionnew="Castilla y Léon" if region=="ES41"
replace regionnew="Castilla-La Mancha" if region=="ES42"
replace regionnew="Extremadura" if region=="ES43"
replace regionnew="Cataluña" if region=="ES51"
replace regionnew="Comunidad Valenciana" if region=="ES52"
replace regionnew="Illes Balears" if region=="ES53"
replace regionnew="Andalucía" if region=="ES61"
replace regionnew="Region de Murcia" if region=="ES62"
replace regionnew="Ciudad Autonoma de Ceuta" if region=="ES63"
replace regionnew="Ciudad Autonoma de Melilla" if region=="ES64"
replace regionnew="Canarias" if region=="ES70"

replace regionnew="Laensi-Suomi" if region=="FI19"
replace regionnew="Helsinki-Uusimaa" if region=="FI1B"
replace regionnew="Etelä-Suomen" if region=="FI1C"
replace regionnew="Pohjois-Suomi ja Itä-Suomi" if region=="FI1D"

replace regionnew="Ile de France" if region=="FR10"
replace regionnew="Champagne-Ardenne" if region=="FR21"
replace regionnew="Picardie" if region=="FR22"
replace regionnew="Haute-Normandie" if region=="FR23"
replace regionnew="Centre" if region=="FR24"
replace regionnew="Basse-Normandie" if region=="FR25"
replace regionnew="Bourgogne" if region=="FR26"
replace regionnew="Nord-Pas-de-Calais" if region=="FR30"
replace regionnew="Lorraine" if region=="FR41"
replace regionnew="Alsace" if region=="FR42"
replace regionnew="Franche-Comte" if region=="FR43"
replace regionnew="Pays de la Loire" if region=="FR51"
replace regionnew="Bretagne" if region=="FR52"
replace regionnew="Poitou-Charentes" if region=="FR53"
replace regionnew="Aquitaine" if region=="FR61"
replace regionnew="Midi-Pyrenees" if region=="FR62"
replace regionnew="Limousin" if region=="FR63"
replace regionnew="Rhone-Alpes" if region=="FR71"
replace regionnew="Auvergne" if region=="FR72"
replace regionnew="Languedoc-Roussillon" if region=="FR81"
replace regionnew="Provence-Alpes-Cote dAzur" if region=="FR82"
replace regionnew="Corse" if region=="FR83"

replace regionnew="Hrvatska" if region=="HR0"

replace regionnew="Kozep-Magyarorszag" if region=="HU1"
replace regionnew="Dunantul" if region=="HU2"
replace regionnew="Alfold es Eszak" if region=="HU3"

replace regionnew="Iceland" if region=="IS"

replace regionnew="Nord-ovest" if region=="ITC"
replace regionnew="Sud" if region=="ITF"
replace regionnew="Isole" if region=="ITG"
replace regionnew="Nord-Est" if region=="ITH"
replace regionnew="Centro" if region=="ITI"

replace regionnew="Lietuva" if region=="LT0"

replace regionnew="Luxembourg (Grand-Duche)" if region=="LU0"

replace regionnew="Latvija" if region=="LV0"

replace regionnew="Malta" if region=="MT0"

replace regionnew="Norge" if region=="NO0"

replace regionnew="Region Centralny" if region=="PL1"
replace regionnew="Region Poludniowy" if region=="PL2"
replace regionnew="Region Wschodni" if region=="PL3"
replace regionnew="Region Polnocno-Zachodni" if region=="PL4"
replace regionnew="Region Poludniowo-Zachodni" if region=="PL5"
replace regionnew="Region Polnocny" if region=="PL6"

replace regionnew="Macroregiunea Unu" if region=="RO1"
replace regionnew="Macroregiunea Doi" if region=="RO2"
replace regionnew="Macroregiunea Trei" if region=="RO3"
replace regionnew="Macroregiunea Patru" if region=="RO4"

replace regionnew="Oestra Sverige" if region=="SE1"
replace regionnew="Soedra Sverige" if region=="SE2"
replace regionnew="Norra Sverige" if region=="SE3"

replace regionnew="Slovenská Republika" if region=="SK0"

replace regionnew="Tees Valley and Durham" if region=="UKC1"
replace regionnew="Northumberland and Tyne and Wear" if region=="UKC2"
replace regionnew="Cumbria" if region=="UKD1"
replace regionnew="Cheshire" if region=="UKD3"
replace regionnew="Greater Manchester" if region=="UKD4"
replace regionnew="Lancashire" if region=="UKD6"
replace regionnew="Merseyside" if region=="UKD7"
replace regionnew="East Yorkshire and North Lincolnshire" if region=="UKE1"
replace regionnew="North Yorkshire" if region=="UKE2"
replace regionnew="South Yorkshire" if region=="UKE3"
replace regionnew="West Yorkshire" if region=="UKE4"
replace regionnew="Derbyshire and Nottinghamshire" if region=="UKF1"
replace regionnew="Leicestershire, Rutland and Northamptonshire" if region=="UKF2"
replace regionnew="Lincolnshire" if region=="UKF3"
replace regionnew="Herefordshire, Worcestershire and Warwickshire" if region=="UKG1"
replace regionnew="Shropshire and Staffordshire" if region=="UKG2"
replace regionnew="West Midlands" if region=="UKG3"
replace regionnew="East Anglia" if region=="UKH1"
replace regionnew="Bedfordshire and Hertfordshire" if region=="UKH2"
replace regionnew="Essex" if region=="UKH3"
replace regionnew="Inner London" if region=="UKI1"
replace regionnew="Outer London" if region=="UKI2"
replace regionnew="Berkshire, Buckinghamshire and Oxfordshire" if region=="UKJ1"
replace regionnew="Surrey, East and West Sussex" if region=="UKJ2"
replace regionnew="Hampshire and Isle of Wight" if region=="UKJ3"
replace regionnew="Kent" if region=="UKJ4"
replace regionnew="Gloucestershire, Wiltshire and Bristol/Bath" if region=="UKK1"
replace regionnew="Dorset and Somerset" if region=="UKK2"
replace regionnew="Cornwall and Isles of Scilly" if region=="UKK3"
replace regionnew="Devon" if region=="UKK4"
replace regionnew="West Wales and The Valleys" if region=="UKL1"
replace regionnew="East Wales" if region=="UKL2"
replace regionnew="Eastern Scotland" if region=="UKM2"
replace regionnew="South Western Scotland" if region=="UKM3"
replace regionnew="North Eastern Scotland" if region=="UKM5"
replace regionnew="Highlands and Islands" if region=="UKM6"
replace regionnew="Northern Ireland" if region=="UKN0"

replace regionnew="North East, England" if region=="UKC"
replace regionnew="North West, England" if region=="UKD"
replace regionnew="Yorkshire and the Humber, England" if region=="UKE"
replace regionnew="East Midlands, England" if region=="UKF"
replace regionnew="West Midlands, England" if region=="UKG"
replace regionnew="East of England" if region=="UKH"
replace regionnew="London, England" if region=="UKI"
replace regionnew="South East, England" if region=="UKJ"
replace regionnew="South West, England" if region=="UKK"
replace regionnew="Wales" if region=="UKL"
replace regionnew="Scotland" if region=="UKM"
replace regionnew="Northern Ireland" if region=="UKN"

replace regionnew="Lake Geneva region" if region=="CH01"
replace regionnew="Espace Mittelland" if region=="CH02"
replace regionnew="Northwestern Switzerland" if region=="CH03"
replace regionnew="Zurich" if region=="CH04"
replace regionnew="Eastern Switzerland" if region=="CH05"
replace regionnew="Central Switzerland" if region=="CH06"
replace regionnew="Ticino" if region=="CH07"

replace regionnew="Slovenia" if region=="SI0"

replace regionnew="Bulgaria" if region=="BG0"

replace regionnew="Ireland" if region=="IE0"

drop region
g region = regionnew

