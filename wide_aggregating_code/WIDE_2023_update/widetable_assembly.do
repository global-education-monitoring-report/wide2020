*WIDETABLE so many parts
*output: widetable_2023.csv

**# IMPORT so many files 


import delimited "C:\Users\taiku\OneDrive - UNESCO\WIDE files\widetable_summarized_2022update.csv", clear 
*keep car 2019 mwi 2019 fji 2021 ind 2021 mrt 2021 eth 2019 lbr 2019 rwa 2019 sle 2019 

/*

country	2011	2019	2020	2021	Total
					
CentralAfricanRepub..	0	844	0	0	844 
Ethiopia	1,033	0	0	0	1,033 
Fiji	0	0	0	190	190 
India	0	0	3,778	0	3,778 
Liberia	0	630	0	0	630 
Malawi	0	0	156	0	156 
Mauritania	0	0	492	0	492 
Rwanda	0	0	871	0	871 
Sierra Leone	0	484	0	0	484 
					
Total	1,033	1,958	5,297	190	8,478 
*/

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part1.dta, replace


import delimited "C:\Users\taiku\OneDrive - UNESCO\WIDE files\widetable_summarized_27092021.csv", clear
*keep CRI 2018 KIR 2019 MNG 2018 MNE 2018 ZWE 2019 


/*
country	2017	2018	2019	Total
				
Algeria	0	0	292	292 
Bangladesh	0	0	326	326 
Belarus	0	0	277	277 
CentralAfricanRepub..	0	0	844	844 
Chad	0	0	1,866	1,866 
CostaRica	0	292	0	292 
Cuba	0	0	584	584 
DRCongo	0	869	0	869 
Gambia	0	291	0	291 
Georgia	0	368	0	368 
Ghana	394	0	0	394 
Guinea-Bissau	0	0	343	343 
Guyana	0	0	366	366 
Iraq	0	665	0	665 
Kiribati	0	586	0	586 
Kyrgyzstan	0	340	0	340 
LaoPDR	665	0	0	665 
Lesotho	0	182	0	182 
Madagascar	0	802	0	802 
Mongolia	0	600	0	600 
Montenegro	0	156	0	156 
Nepal	0	0	288	288 
Palestine	0	0	674	674 
SaoTomeandPrincipe	0	0	216	216 
Serbia	0	0	190	190 
SierraLeone	190	0	0	190 
Suriname	0	323	0	323 
TFYRMacedonia	0	325	0	325 
Thailand	0	0	216	216 
Togo	258	0	0	258 
Tonga	0	0	555	555 
Turkmenistan	0	0	234	234 
Zimbabwe	0	0	1,514	1,514 
				
Total	1,507	5,799	8,785	16,091 
*/

gen keep=.
replace keep=1 if country=="CostaRica"
replace keep=1 if country=="Kiribati"
replace keep=1 if country=="Montenegro"
replace keep=1 if country=="Mongolia"
replace keep=1 if country=="Zimbabwe"


keep if keep==1

local varlist_destring attend_higher_m attend_higher_1822_m comp_higher_2yrs_2529_m comp_higher_4yrs_2529_m comp_higher_4yrs_3034_m comp_lowsec_1524_m comp_lowsec_v2_m comp_prim_1524_m comp_prim_v2_m comp_upsec_2029_m comp_upsec_v2_m edu0_prim_m edu4_2024_m eduout_lowsec_m eduout_prim_m eduout_upsec_m eduyears_2024_m literacy_1524_m overage2plus_m preschool_1ybefore_m preschool_3_m attend_higher_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no comp_lowsec_1524_no comp_lowsec_v2_no comp_prim_1524_no comp_prim_v2_no comp_upsec_2029_no comp_upsec_v2_no edu0_prim_no edu4_2024_no eduout_lowsec_no eduout_prim_no eduout_upsec_no eduyears_2024_no literacy_1524_no overage2plus_no preschool_1ybefore_no preschool_3_no

foreach var of local varlist_destring {
			replace `var'="" if `var'=="NA"
			destring `var', replace
	}


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part2.dta, replace



import delimited "C:\Users\taiku\Desktop\multiproposito\wide_allSenegal.csv", clear
*keep 2019 2012 2016

/*
2000	228	2.63	2.63
2002	27	0.31	2.94
2005	54	0.62	3.56
2011	1,066	12.28	15.84
2013	931	10.73	26.57
2014	1,036	11.94	38.50
2015	1,042	12.00	50.51
2016	1,011	11.65	62.15
2017	1,149	13.24	75.39
2018	1,060	12.21	87.60
2019	1,076	12.40	100.00
*/

gen keep=.
replace keep=1 if year==2019
replace keep=1 if year==2012
replace keep=1 if year==2019

keep if keep==1

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part3.dta, replace

		
import delimited "C:\Users\taiku\Documents\GEM UNESCO MBR\OUTPUT WIDE update\collapsed_output\output2001.csv", clear
*keep: QAT 2012 MDV 2017 ZAF 2016

drop if survey=="EU-SILC"

gen keep=.
replace keep=1 if iso_code3=="QAT"
replace keep=1 if iso_code3=="MDV"
replace keep=1 if iso_code3=="ZAF"

keep if keep==1
drop ethnicity 




	local varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec comp_higher_2529 comp_higher_3034 attend_higher_1822 edu0_prim overage2plus literacy_1549 comp_higher_2yrs_2529 comp_higher_4yrs_2529 comp_lowsec_2024 comp_upsec_2024 preschool_1ybefore preschool_3 comp_higher_4yrs_3034

foreach var of local varlist_m {
			rename `var' `var'_m
	}

cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part4.dta, replace


/*
 iso_code3 |      2011       2012       2013       2015       2016       2017       2018       2019 |     Total
-----------+----------------------------------------------------------------------------------------+----------
       ALB |         0          0          0          0          0        270          0          0 |       270 
       ARG |         0          0          0          0          0          0          0        147 |       147 
       ARM |         0          0          0          0          0          0        252          0 |       252 
       BEN |         0          0          0          0          0        267          0          0 |       267 
       BGD |         0          0          0          0          0          0          0        208 |       208 
       BOL |         0          0          0          0          0          0          0        218 |       218 
       BRA |         0          0          0          0          0          0          0      8,273 |     8,273 
       CHL |         0          0          0          0          0        382          0          0 |       382 
       CHN |         0          0          0          0      2,166          0          0          0 |     2,166 
       CMR |         0          0          0          0          0          0      1,010          0 |     1,010 
       COD |         0          0          0          0          0          0        497          0 |       497 
       COG |         0          0          0        306          0          0          0          0 |       306 
       COL |         0          0          0          0          0          0        252          0 |       252 
       CRI |         0          0          0          0          0          0        225          0 |       225 
       ECU |         0          0          0          0          0          0      4,675          0 |     4,675 
       GEO |         0          0          0          0          0          0        248          0 |       248 
       GHA |         0          0          0          0          0        284          0          0 |       284 
       GIN |         0          0          0          0          0          0        192          0 |       192 
       GMB |         0          0          0          0          0          0        224          0 |       224 
       GNB |         0          0          0          0          0          0          0        255 |       255 
       HTI |         0          0          0          0          0        252          0          0 |       252 
       IDN |         0          0          0          0          0        666          0          0 |       666 
       IRQ |         0          0          0          0          0          0        378          0 |       378 
       JOR |         0          0          0          0          0        299          0          0 |       299 
       KGZ |         0          0          0          0          0          0        236          0 |       236 
       KIR |         0          0          0          0          0          0        185          0 |       185 
       LAO |         0          0          0          0          0        133          0          0 |       133 
       LSO |         0          0          0          0          0          0        234          0 |       234 
       MDG |         0          0          0          0          0          0        450          0 |       450 
       MDV |         0          0          0          0          0        150          0          0 |       150 
       MEX |         0          0          0          0          0          0        165          0 |       165 
       MKD |         0          0          0          0          0          0        213          0 |       213 
       MLI |         0          0          0          0          0          0        207          0 |       207 
       MNE |         0          0          0          0          0          0        108          0 |       108 
       MNG |         0          0          0          0          0          0        179          0 |       179 
       MOZ |         0          0          0        243          0          0          0          0 |       243 
       NAM |         0          0          0        306          0          0          0          0 |       306 
       NGA |         0          0          0          0          0          0        247          0 |       247 
       PAK |         0          0          0          0          0          0        198          0 |       198 
       PER |         0          0          0          0          0          0          0        504 |       504 
       PHL |         0          0          0          0          0        360          0          0 |       360 
       PNG |         0          0          0          0          0        126          0          0 |       126 
       PRY |         0          0          0          0          0          0          0        342 |       342 
       QAT |         0         27          0          0          0          0          0          0 |        27 
       RUS |         0          0          0          0          0          0        861          0 |       861 
       SEN |         0          0          0          0          0        302        375          0 |       677 
       SLE |         0          0          0          0          0        196          0          0 |       196 
       SLV |         0          0          0          0          0          0          0        144 |       144 
       SOM |       198          0          0          0          0          0          0          0 |       198 
       SRB |         0          0          0          0          0          0          0        151 |       151 
       SSD |         0          0          0          0          0         24          0          0 |        24 
       SUR |         0          0          0          0          0          0        265          0 |       265 
       TGO |         0          0          0          0          0        205          0          0 |       205 
       THA |         0          0          0          0          0          0          0        144 |       144 
       TJK |         0          0          0          0          0        138          0          0 |       138 
       TKM |         0          0          0          0          0          0          0        153 |       153 
       TLS |         0          0          0          0        307          0          0          0 |       307 
       TON |         0          0          0          0          0          0          0        175 |       175 
       TUN |         0          0          0          0          0          0        180          0 |       180 
       TUR |         0          0        144          0          0          0          0          0 |       144 
       TZA |         0          0          0          0          0         93          0          0 |        93 
       UGA |         0          0          0          0        642          0          0          0 |       642 
       URY |         0          0          0          0          0          0          0        198 |       198 
       VNM |         0          0          0        144          0          0          0          0 |       144 
       ZAF |         0          0          0          0        216          0          0          0 |       216 
       ZMB |         0          0          0          0          0          0        234          0 |       234 
       ZWE |         0          0          0          0          0          0          0        273 |       273 
-----------+----------------------------------------------------------------------------------------+----------
     Total |       198         27        144        999      3,331      4,147     12,290     11,185 |    32,321 
*/


import delimited "C:\Users\taiku\Desktop\multiproposito\widetable_summarized_2023update.csv", clear
*keep all countries


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part5.dta, replace

import delimited "C:\Users\taiku\Desktop\multiproposito\widetable_summarized_07012022.csv", clear
*keep TUN 2018 ALB 2917 IDN 2017 JOR 2018 PHL 2018 TJK 2017

gen keep=.
replace keep=1  if country=="Tunisia"
replace keep=1  if country=="Albania"
replace keep=1  if country=="Albania"
replace keep=1  if country=="Indonesia"
replace keep=1  if country=="Jordan"
replace keep=1  if country=="Philippines"
replace keep=1  if country=="Tajikistan"
replace keep=1  if country=="Gambia"
replace keep=1  if country=="Maldives"


keep if keep==1


local varlist_destring attend_higher_m attend_higher_1822_m comp_higher_2yrs_2529_m comp_higher_4yrs_2529_m comp_higher_4yrs_3034_m comp_lowsec_1524_m comp_lowsec_v2_m comp_prim_1524_m comp_prim_v2_m comp_upsec_2029_m comp_upsec_v2_m edu0_prim_m edu4_2024_m eduout_lowsec_m eduout_prim_m eduout_upsec_m eduyears_2024_m literacy_1524_m overage2plus_m attend_higher_no attend_higher_1822_no comp_higher_2yrs_2529_no comp_higher_4yrs_2529_no comp_higher_4yrs_3034_no comp_lowsec_1524_no comp_lowsec_v2_no comp_prim_1524_no comp_prim_v2_no comp_upsec_2029_no comp_upsec_v2_no edu0_prim_no edu4_2024_no eduout_lowsec_no eduout_prim_no eduout_upsec_no eduyears_2024_no literacy_1524_no overage2plus_no preschool_1ybefore_m preschool_3_m preschool_1ybefore_no preschool_3_no

foreach var of local varlist_destring {
			replace `var'="" if `var'=="NA"
			destring `var', replace
	}


cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part6.dta, replace



/*
              country |      2016       2017       2018       2019       2020 |     Total
----------------------+-------------------------------------------------------+----------
              Albania |         0      1,371          0          0          0 |     1,371 
              Algeria |         0          0          0        292          0 |       292 
           Bangladesh |         0        731          0        326          0 |     1,057 
              Belarus |         0          0          0        277          0 |       277 
                Benin |         0      2,385          0          0          0 |     2,385 
              Burundi |     1,993          0          0          0          0 |     1,993 
             Cameroon |         0          0      1,446          0          0 |     1,446 
CentralAfricanRepub.. |         0          0          0        844          0 |       844 
                 Chad |         0          0          0      1,866          0 |     1,866 
            CostaRica |         0          0        292          0          0 |       292 
                 Cuba |         0          0          0        584          0 |       584 
              DRCongo |         0          0        869          0          0 |       869 
               Gambia |         0          0        291          0        629 |       920 
              Georgia |         0          0        368          0          0 |       368 
                Ghana |         0        394          0          0          0 |       394 
               Guinea |         0          0        670          0          0 |       670 
        Guinea-Bissau |         0          0          0        343          0 |       343 
               Guyana |         0          0          0        366          0 |       366 
                Haiti |         0      1,158          0          0          0 |     1,158 
            Indonesia |         0      1,202          0          0          0 |     1,202 
                 Iraq |         0          0        665          0          0 |       665 
               Jordan |         0        459          0          0          0 |       459 
             Kiribati |         0          0        586          0          0 |       586 
           Kyrgyzstan |         0          0        340          0          0 |       340 
               LaoPDR |         0        665          0          0          0 |       665 
              Lesotho |         0          0        182          0          0 |       182 
              Liberia |         0          0          0        630          0 |       630 
           Madagascar |         0          0        802          0          0 |       802 
             Maldives |         0        194          0          0          0 |       194 
                 Mali |         0          0        906          0          0 |       906 
             Mongolia |         0          0        600          0          0 |       600 
           Montenegro |         0          0        156          0          0 |       156 
                Nepal |         0          0          0        288          0 |       288 
              Nigeria |         0          0        773          0          0 |       773 
             Pakistan |         0          0        256          0          0 |       256 
            Palestine |         0          0          0        674          0 |       674 
     Papua New Guinea |         0      1,105          0          0          0 |     1,105 
          Philippines |         0      1,723          0          0          0 |     1,723 
   SaoTomeandPrincipe |         0          0          0        216          0 |       216 
              Senegal |         0          0      1,060      1,076          0 |     2,136 
               Serbia |         0          0          0        190          0 |       190 
         Sierra Leone |         0          0          0        484          0 |       484 
          SierraLeone |         0        190          0          0          0 |       190 
             Suriname |         0          0        323          0          0 |       323 
        TFYRMacedonia |         0          0        325          0          0 |       325 
           Tajikistan |         0        205          0          0          0 |       205 
             Thailand |         0          0          0        216          0 |       216 
                 Togo |         0        258          0          0          0 |       258 
                Tonga |         0          0          0        555          0 |       555 
              Tunisia |         0          0        292          0          0 |       292 
         Turkmenistan |         0          0          0        234          0 |       234 
               Zambia |         0          0        998          0          0 |       998 
             Zimbabwe |         0          0          0      1,514          0 |     1,514 
			 
			 
		*/

		
	import delimited "C:\Users\taiku\Desktop\multiproposito\Nepal\widetable_summarized_Nepalrecalculation.csv", clear
	
	drop v1 x
	
	replace year=2001 if year==2057
	replace year=2006 if year==2063
	replace year=2011 if year==2067
	replace year=2016 if year==2073

	
	cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
save part7.dta, replace
	
	
		
**# Append and homogenize 

clear
set trace on 
local files : dir "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts" files "*.dta"
foreach file in `files' {
	cd "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\widetable_parts"
append using `file'
}
set trace off 


drop v1
drop x
drop level grade language
drop country_year source adjustment year_uis prim_age0
drop lowsec_age0 upsec_age0 prim_age1 lowsec_age1 upsec_age1 prim_dur lowsec_dur upsec_dur higher_dur iso_code2
drop keep iso_code  ethnicity 


replace iso_code3="ALB" if country=="Albania"
replace iso_code3="ARG" if country=="Argentina"
replace iso_code3="CAF" if country=="CentralAfricanRepublic"
replace iso_code3="CRI" if country=="CostaRica"
replace iso_code3="DOM" if country=="DominicanRepublic"
replace iso_code3="ETH" if country=="Ethiopia"
replace iso_code3="FJI" if country=="Fiji"
replace iso_code3="GMB" if country=="Gambia"
replace iso_code3="HND" if country=="Honduras"
replace iso_code3="IND" if country=="India"
replace iso_code3="IDN" if country=="Indonesia"
replace iso_code3="JOR" if country=="Jordan"
replace iso_code3="KIR" if country=="Kiribati"
replace iso_code3="LBR" if country=="Liberia"
replace iso_code3="MDG" if country=="Madagascar"
replace iso_code3="MWI" if country=="Malawi"
replace iso_code3="MDV" if country=="Maldives"
replace iso_code3="MRT" if country=="Mauritania"
replace iso_code3="MNG" if country=="Mongolia"
replace iso_code3="MNE" if country=="Montenegro"
replace iso_code3="NPL" if country=="Nepal"
replace iso_code3="NGA" if country=="Nigeria"
replace iso_code3="PHL" if country=="Philippines"
replace iso_code3="QAT" if country=="Qatar"
replace iso_code3="RWA" if country=="Rwanda"
replace iso_code3="WSM" if country=="Samoa"
replace iso_code3="SEN" if country=="Senegal"
replace iso_code3="SLE" if country=="Sierra Leone"
replace iso_code3="ZAF" if country=="South Africa"
replace iso_code3="TJK" if country=="Tajikistan"
replace iso_code3="TUN" if country=="Tunisia"
replace iso_code3="TCA" if country=="Turks and Caicos Islands"
replace iso_code3="TUV" if country=="Tuvalu"
replace iso_code3="UZB" if country=="Uzbekistan"
replace iso_code3="VNM" if country=="VietNam"
replace iso_code3="ZWE" if country=="Zimbabwe"

*03/03/23 update: change years to match UIS's 
replace year = 2021 if iso=="VNM" | iso=="MRT"
replace year= 2020 if iso=="GMB" | iso=="MWI" | iso=="RWA" | iso=="TCA" | iso=="TUV"
replace year= 2019 if iso=="CAF" | iso=="KIR" | iso=="WSM"


order *_no, last

export delimited using "C:\Users\taiku\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\WIDE_2023_files\widetable_2023.csv", replace



