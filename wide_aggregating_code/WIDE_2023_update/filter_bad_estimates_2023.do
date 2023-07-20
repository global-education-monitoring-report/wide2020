*****WIDE 2023: FILTER BAD ESTIMATES STATA VERSION (BLASPHEMY/unholy)

*import delimited "C:\Users\taiku\OneDrive - UNESCO\WIDE files\2023\WIDE_2023_07_02.csv", clear
import delimited "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\WIDE files\WIDE_2023_julytest.csv", clear


// eduout_lowsec
*Ben's content

*Uganda DHS 2016 
replace eduout_lowsec_m=. if iso=="UGA" & survey=="DHS" & year==2016 & cat=="Wealth"

*Argentina: the average is the same as the rural
replace eduout_lowsec_m=. if iso=="ARG" & survey=="MICS" & year==2020 & cat=="Location"
replace eduout_lowsec_m=. if iso=="ARG" & survey=="MICS" & year==2020 & cat=="Total"

*Bolivia has duplicated rural and urban groups 2019
replace eduout_lowsec_m=. if iso=="BOL" & survey=="ECLAC" & year==2019 & cat=="Location"
replace eduout_lowsec_m=. if iso=="BOL" & survey=="other" & year==2019 & cat=="Location"

*Same for Paraguay 2019
replace eduout_lowsec_m=. if iso=="PRY" & survey=="ECLAC" & year==2019 & cat=="Location"
replace eduout_lowsec_m=. if iso=="PRY" & survey=="other" & year==2019 & cat=="Location"
replace eduout_lowsec_m=. if iso=="PRY" & survey=="EPH" & year==2019 & cat=="Location"

*Costa Rica 2018 is missing an average diamond
*duplicate ECLAC MICS keep what exists
replace eduout_lowsec_m=0.32 if iso=="CRI" & survey=="MICS" & year==2018 & cat=="Total"

*can you put a screenshot? 
*arg 2020 cri 2018
*two observations filling the other
replace eduout_lowsec_m=0.3159 if iso=="ARG" & survey=="ECLAC" & year==2020 & cat=="Total"
replace eduout_lowsec_m=0.32 if iso=="CRI" & survey=="MICS" & year==2018 & cat=="Total"


// preschool_3
// preschool_1ybefore

*Cuba Camag<fc>Ey
replace region="Camagüey"  if region=="Camag<fc>Ey" & iso=="CUB"

*Cuba wealth
replace preschool_3_m=. if iso=="CUB" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="CUB" & survey=="MICS" & year==2019 & cat=="Wealth"

*CAF wealth
replace preschool_3_m=. if iso=="CAF" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="CAF" & survey=="MICS" & year==2019 & cat=="Wealth"

*GUY wealth
replace preschool_3_m=. if iso=="GUY" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="GUY" & survey=="MICS" & year==2019 & cat=="Wealth"

*PSE wealth
replace preschool_3_m=. if iso=="PSE" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="PSE" & survey=="MICS" & year==2019 & cat=="Wealth"

*WSM wealth
replace preschool_3_m=. if iso=="WSM" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="WSM" & survey=="MICS" & year==2019 & cat=="Wealth"

*KIR wealth
replace preschool_3_m=. if iso=="KIR" & survey=="MICS" & year==2018 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="KIR" & survey=="MICS" & year==2018 & cat=="Wealth"

*HND wealth
replace preschool_3_m=. if iso=="HND" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="HND" & survey=="MICS" & year==2019 & cat=="Wealth"

*GAB wealth
replace preschool_3_m=. if iso=="GAB" & survey=="EGEP" & year==2017 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="GAB" & survey=="EGEP" & year==2017 & cat=="Wealth"

*MNE wealth
replace preschool_3_m=. if iso=="MNE" & survey=="MICS" & year==2018 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="MNE" & survey=="MICS" & year==2018 & cat=="Wealth"

*ZWE wealth
replace preschool_3_m=. if iso=="ZWE" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="ZWE" & survey=="MICS" & year==2019 & cat=="Wealth"

*DZA wealth
replace preschool_3_m=. if iso=="DZA" & survey=="MICS" & year==2019 & cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="DZA" & survey=="MICS" & year==2019 & cat=="Wealth"

*UZB wealth
replace preschool_3_m=. if iso=="UZB" & survey=="MICS" & year==2021& cat=="Wealth"
replace preschool_1ybefore_m=. if iso=="UZB" & survey=="MICS" & year==2021 & cat=="Wealth"


***GENERAL CHECKS

*THESE SHOULD BE IN THE 0-1 RANGE : 
**
global varlist_percentages comp_prim_v2_m comp_lowsec_v2_m comp_upsec_v2_m comp_prim_1524_m comp_lowsec_1524_m comp_upsec_2029_m  edu2_2024_m edu4_2024_m eduout_prim_m eduout_lowsec_m eduout_upsec_m preschool_3_m preschool_1ybefore_m edu0_prim_m   comp_higher_2yrs_2529_m comp_higher_4yrs_2529_m comp_higher_4yrs_3034_m attend_higher_1822_m overage2plus_m literacy_1524_m


* Eliminate those with less than 30 obs
	foreach var in $varlist_percentages  {
		 		if (`var' > 1) {
					display "`var' has values over 1"
						}
					if (`var' < 0) {
					display "`var' has negative values"
						}
	}

	
/*
comp_prim_1524_m has values over 1 ok
comp_lowsec_1524_m has values over 1 ok
comp_upsec_2029_m has values over 1 ok
edu2_2024_m has values over 1 --> not really
edu4_2024_m has values over 1 --> not really
eduout_prim_m has values over 1 --> not really
eduout_lowsec_m has values over 1 --> not really
eduout_upsec_m has values over 1 --> not really
preschool_3_m has values over 1 --> not really
preschool_1ybefore_m has values over 1 --> not really
edu0_prim_m has values over 1 --> not really
comp_higher_2yrs_2529_m has values over 1 ok
comp_higher_4yrs_2529_m has values over 1 ok 
comp_higher_4yrs_3034_m has values over 1 ok
attend_higher_1822_m has values over 1 --> not really
overage2plus_m has values over 1 --> not really
literacy_1524_m has values over 1 --> not really



comp_upsec_v2_m has values over 1 --> not really 
eduout_prim_m has values over 1 ---> not really
eduout_lowsec_m has values over 1 ---> not really
eduout_upsec_m has values over 1 ---> not really
preschool_3_m has values over 1 ---> not really
preschool_1ybefore_m has values over 1 ---> not really
edu0_prim_m has values over 1 ---> not really
overage2plus_m has values over 1 ---> not really


*/

*comp_prim_1524_m has values over 1
*EU LFS just censor
replace comp_prim_1524_m=. if comp_prim_1524_m >1 & comp_prim_1524_m!=. & survey=="EU-LFS"
*DHS divide value/100
replace comp_prim_1524_m=comp_prim_1524_m/100 if comp_prim_1524_m >1 & comp_prim_1524_m!=. & survey=="DHS"

*comp_lowsec_1524_m has values over 1
*DHS divide value/100
replace comp_lowsec_1524_m=comp_lowsec_1524_m/100 if comp_lowsec_1524_m >1 & comp_lowsec_1524_m!=. & survey=="DHS"

*comp_upsec_2029_m has values over 1
replace comp_upsec_2029_m=comp_upsec_2029_m/100 if comp_upsec_2029_m >1 & comp_upsec_2029_m!=. & survey=="DHS"

*comp_higher_2yrs_2529_m has values over 1
*EU LFS just censor
replace comp_higher_2yrs_2529_m=. if comp_higher_2yrs_2529_m >1 & comp_higher_2yrs_2529_m!=. & survey=="EU-LFS"

*comp_higher_4yrs_2529_m has values over 1
*EU LFS just censor
replace comp_higher_4yrs_2529_m=. if comp_higher_4yrs_2529_m >1 & comp_higher_4yrs_2529_m!=. & survey=="EU-LFS"

*comp_higher_4yrs_3034_m has values over 1
*EU LFS just censor
replace comp_higher_4yrs_3034_m=. if comp_higher_4yrs_3034_m >1 & comp_higher_4yrs_3034_m!=. & survey=="EU-LFS"

************
*new fixesss

*too many 1s
replace eduout_prim_m=. if iso=="NPL" & survey=="DHS" & year==2010
replace eduout_lowsec_m=. if iso=="NPL" & survey=="DHS" & year==2010 
replace eduout_upsec_m=. if iso=="NPL" & survey=="DHS" & year==2010 
 
*1s  
replace eduout_upsec_m=. if iso=="USA" & survey=="DHS" & year==2019 & category=="Ethnicity & Region" & eduout_upsec_m==1
*seems to be a mistake all 1s line 
drop if iso=="USA" & survey=="DHS" & year==2019 & category=="Ethnicity & Region" & region=="Tennessee" & ethnicity=="Black, Hispanic"

*1s
replace edu0_prim_m=. if iso=="GAB" & survey=="EGEP" & year==2017

*CANADA
replace edu0_prim_m=. if iso=="CAN" & survey=="CIS (LIS)" & inlist(year, 2015 , 2016, 2017)
replace edu0_prim_no=. if iso=="CAN" & survey=="CIS (LIS)" & inlist(year, 2015 , 2016, 2017)

*Lesotho HH EDU 
drop if iso=="LSO" & survey=="MICS" & year==2018 & category=="Household Education" 


*literacy 
*EGY	Northern Africa and Western Asia	Lower middle income	Egypt	HIECS (LIS)	2015 all wrong
*JOR	Northern Africa and Western Asia	Lower middle income	Jordan	HEIS (LIS)	2013
*COL	Latin America and the Caribbean	Upper middle income	Colombia	GEIH	2016
*PSE	Northern Africa and Western Asia	Upper middle income	Palestine	PECS (LIS)	2017
replace literacy_1524_m=. if iso=="EGY" & survey=="HIECS (LIS)" & inlist(year, 2015)
replace literacy_1524_no=. if iso=="EGY" & survey=="HIECS (LIS)" & inlist(year, 2015)
replace literacy_1524_m=. if iso=="JOR" & survey=="HEIS (LIS)" & inlist(year, 2013)
replace literacy_1524_no=. if iso=="JOR" & survey=="HEIS (LIS)" & inlist(year, 2013)
replace literacy_1524_m=. if iso=="COL" & survey=="GEIH" & inlist(year, 2016)
replace literacy_1524_no=. if iso=="COL" & survey=="GEIH" & inlist(year, 2016)
replace literacy_1524_m=. if iso=="PSE" & survey=="PECS (LIS)" & inlist(year, 2017)
replace literacy_1524_no=. if iso=="PSE" & survey=="PECS (LIS)" & inlist(year, 2017)

*eu lfs on primary COMPLETION and eduout 
replace comp_prim_v2_m=. if survey=="EU-LFS"
replace comp_prim_v2_no=. if survey=="EU-LFS"

replace comp_prim_v2_m=. if iso=="AUS" & survey=="SIH"

*JPN	Eastern and South-eastern Asia	High income	Japan	JHPS (LIS)
replace comp_lowsec_v2_m=. if iso=="JPN" & survey=="JHPS (LIS)"
replace comp_lowsec_v2_no=. if iso=="JPN" & survey=="JHPS (LIS)"
replace comp_upsec_v2_m=. if iso=="JPN" & survey=="JHPS (LIS)"
replace comp_upsec_v2_no=. if iso=="JPN" & survey=="JHPS (LIS)"
replace comp_lowsec_1524_m=. if iso=="JPN" & survey=="JHPS (LIS)"
replace comp_lowsec_1524_no=. if iso=="JPN" & survey=="JHPS (LIS)"

*comp_prim_1524_m	comp_lowsec_1524_m	comp_upsec_2029_m
*MDV	Central and Southern Asia	Upper middle income	Maldives	DHS	2017
*seems solved after loop 

*ABUNDANCE ISSUES
*USA	CPS-ASEC	2020
*USA	ACS	2020 uis

*BOL 	EH	2019
*BOL	ECH	2019 uis

*DOM	MICS	2019
*DOM	ENCFT	2019 uis

*HND	MICS	2019
*HND	EPH	2019 uis

*PRY	EPHC	2019
*PRY	EPH	2019 uis

*BEN	EHCVM	2018
*BEN	DHS	2018 uis

*BRA	HFPS	2021
*BRA	PNAD	2021

*CRI	MICS	2018
*CRI	ENH	2018

*ECU	ENEMDU	2018	
*ECU	ENAHO	2018	ahh

*HND	EPHPM	2018	
*HND	EPH	2018	ahh

*PAN	EPM	2018	
*PAN	EH	2018	ahh

*CRI	ENH	2017	
*CRI	ENAHO	2017	ahh

*ECU	ENEMDU	2017	
*ECU	ENAHO	2017	ahh

*PAN	EPM	2017	
*PAN	EH	2017	ahh

*USA	CPS-ASEC	2017	
*USA	ACS	2017	ahh

*CRI	ENH	2016	
*CRI	ENAHO	2016	ahh

*ECU	ENAHO	2016	
*ECU	ENEMDU	2016	ahh

*HND	EPHPM	2016	
*HND	EPH	2016	ahh

*MEX	ENIGH	2016	
*MEX	MICS	2016	ahh

*PAN	ECH	2016	
*PAN	EPM	2016	ahh

*PRY	MICS	2016	
*PRY	EPH	2016	ahh

*rest is in *abundance of surveys.xlsx
***************

****
*******
*new corrections from staging site

*Nigeria, MICS, 2021 hhedu not completed primary esta en 0
replace comp_prim_v2_m=. if iso=="NGA" & survey=="MICS" & inlist(year, 2021) & cat=="Household Education"

*eduout_prim_m:
*Nepal, MICS, 2019 HHEDU tb
replace eduout_prim_m=. if iso=="NPL" & survey=="MICS" & inlist(year, 2019) & cat=="Household Education"
*Lao PDR, MICS, 2017 hhedu
replace eduout_prim_m=. if iso=="LAO" & survey=="MICS" & inlist(year, 2017) & cat=="Household Education"
*wsm completed primary 
replace eduout_prim_m=. if iso=="WSM" & survey=="MICS" & cat=="Household Education" & hh_edu_head=="Completed primary"
*PSE Palestine, MICS, 2020 NOT COMPLETED PRIM
replace eduout_prim_m=. if iso=="PSE" & survey=="MICS" & cat=="Household Education" & hh_edu_head=="Not completed primary"


*eduout_upsec_m
*Fiji, MICS, 2021, hhedu not completed primary
replace eduout_upsec_m=. if iso=="FJI" & survey=="MICS" & cat=="Household Education" & hh_edu_head=="Not completed primary"


*eduyears_2024_m
*GABON EGEP 2017
drop if iso=="GAB" & survey=="EGEP" & inlist(year, 2017)
*LESOTHO

*Zimbabwe, MICS, 2019, Pentecostal religion outlier likely
replace eduyears_2024_m=. if iso=="ZWE" & survey=="MICS" & inlist(year, 2019) &  cat=="Religion" & religion=="Pentecostal"
*Lao PDR, MICS, 2017 hhedu and total 
replace eduyears_2024_m=. if iso=="LAO" & survey=="MICS" & inlist(year, 2017) & cat=="Household Education"
*Belarus, MICS, 2019 hhedu
replace eduyears_2024_m=. if iso=="BLR" & survey=="MICS" & inlist(year, 2019) & cat=="Household Education"
*Viet Nam, MICS, 2020 hhedu and total
replace eduyears_2024_m=. if iso=="VNM" & survey=="MICS" & inlist(year, 2020) & cat=="Household Education"
replace eduyears_2024_m=. if iso=="VNM" & survey=="MICS" & inlist(year, 2020) & cat=="Total"
*Guyana, MICS, 2020 all
replace eduyears_2024_m=. if iso=="GUY" & survey=="MICS" & inlist(year, 2020) 

*preschool_1ybefore 
*Tonga, MICS, 2019 all is too low 
replace preschool_1ybefore_m=. if iso=="TON" & survey=="MICS" & inlist(year, 2019) 
*Serbia, MICS, 2019
replace preschool_1ybefore_m=. if iso=="SRB" & survey=="MICS" & inlist(year, 2019) 

*preschool_3
*LSO MICS 2018
drop if iso=="LSO" & survey=="MICS" & inlist(year, 2018)


*edu0_prim_m
*South Sudan, HFS, 2017
replace edu0_prim_m=. if iso=="SSD" & survey=="HFS" & inlist(year, 2017) 
*Nepal, MICS, 2019 disability 
replace eduout_prim_m=. if iso=="NPL" & survey=="MICS" & inlist(year, 2019) & cat=="Disability"
*Lesotho, MICS, 2018 disability  ALREADY 340

*overage2plus_m
*Costa Rica, MICS, 2018 all
replace overage2plus_m=. if iso=="CRI" & survey=="MICS" & inlist(year, 2018) 
*Nepal, MICS, 2019 disability	
replace overage2plus_m=. if iso=="NPL" & survey=="MICS" & inlist(year, 2019) & cat=="Disability"
*Uzbekistan, MICS, 2021 ALL 
replace overage2plus_m=. if iso=="UZB" & survey=="MICS" & inlist(year, 2021) 
*Zimbabwe, MICS, 2019
replace overage2plus_m=. if iso=="ZWE" & survey=="MICS" & inlist(year, 2019) 
*Mongolia, MICS, 2018
replace overage2plus_m=. if iso=="MNG" & survey=="MICS" & inlist(year, 2018) 
*Viet Nam, MICS, 2021
replace overage2plus_m=. if iso=="VNM" & survey=="MICS" & inlist(year, 2021) 
*Serbia, MICS, 2019 HH EDU TOO HIGH 
replace overage2plus_m=. if iso=="SRB" & survey=="MICS" & inlist(year, 2019)  & cat=="Household Education"
*Guinea-Bissau, MICS, 2019 HH EDU TOO HIGH
replace overage2plus_m=. if iso=="GNB" & survey=="MICS" & inlist(year, 2019) & cat=="Household Education"
*North Macedonia, MICS, 2019 ALL
replace overage2plus_m=. if iso=="MKD" & survey=="MICS" & inlist(year, 2019) 


*attend_higher_1822_m
*Lesotho, MICS, 2018 all already
*Madagascar, MICS, 2018 all
replace attend_higher_1822_m=. if iso=="MDG" & survey=="MICS" & inlist(year, 2018) 
*TCA, MICS, 2020 all
replace attend_higher_1822_m=. if iso=="TCA" & survey=="MICS" & inlist(year, 2020) 


*comp_higher_4yrs_2529
*Kiribati, MICS, 2019 all 
replace comp_higher_2yrs_2529_m=. if iso=="KIR" & survey=="MICS" & inlist(year, 2019) 
*Madagascar, MICS, 2018
replace comp_higher_2yrs_2529_m=. if iso=="MDG" & survey=="MICS" & inlist(year, 2018) 
*Nigeria, MICS, 2021
replace comp_higher_2yrs_2529_m=. if iso=="NGA" & survey=="MICS" & inlist(year, 2021) 
*TCA, MICS, 2020
replace comp_higher_2yrs_2529_m=. if iso=="TCA" & survey=="MICS" & inlist(year, 2020) 
*Lebanon, LFHLCS, 2018
replace comp_higher_2yrs_2529_m=. if iso=="LBN" & survey=="LFHLCS" & inlist(year, 2018) 
*Guyana, MICS, 2020 hh edu 
replace comp_higher_2yrs_2529_m=. if iso=="GUY" & survey=="MICS" & inlist(year, 2020)  & cat=="Household Education"
*Belarus, MICS, 2019 hh edu
replace comp_higher_2yrs_2529_m=. if iso=="BLR" & survey=="MICS" & inlist(year, 2019)  & cat=="Household Education"


*literacy_1524_m
*Nigeria, MICS, 2021
replace literacy_1524_m=. if iso=="NGA" & survey=="MICS" & inlist(year, 2021) 
*Cuba, MICS, 2019 
replace literacy_1524_m=. if iso=="CUB" & survey=="MICS" & inlist(year, 2019) 


*******
****


*THESE should be reasonably below 25: eduyears_2024_m

tab iso year if eduyears_2024_m >25 & eduyears_2024_m!=.

replace eduyears_2024_m=.   if eduyears_2024_m >25 & eduyears_2024_m!=.


*fix survey names
egen country_year=concat(iso year), punct("_")
replace survey="ILCS" if country_year=="ARM_2018"
replace survey="SIH" if country_year=="AUS_2010"
replace survey="CIS" if country_year=="CAN_2010"

replace survey="CIS" if survey=="CIS (LIS)"
replace survey="CPS-ASEC" if survey=="CPS-ASEC (LIS)"
replace survey="FHES" if survey=="FHES (LIS)"
replace survey="GEIH" if survey=="GEIH (LIS)"
replace survey="HES" if survey=="HES (LIS)"
replace survey="HIECS" if survey=="HIECS (LIS)"
replace survey="JHPS" if survey=="JHPS (LIS)"
replace survey="HEIS" if survey=="HEIS (LIS)"
replace survey="PECS" if survey=="PECS (LIS)"
replace survey="SIH" if survey=="SIH (LIS)"

  

replace survey="CFPS" if country_year=="CHN_2010"
replace survey="CFPS" if country_year=="CHN_2012"
replace survey="CFPS" if country_year=="CHN_2014"
replace survey="CFPS" if country_year=="CHN_2016"
replace survey="ENEMDU" if country_year=="ECU_2000"
replace survey="HIES" if country_year=="GEO_2013"
replace survey="HIES" if country_year=="GEO_2016"
replace survey="ENCOVI" if country_year=="GTM_2011"
replace survey="HDS" if country_year=="IND_2005"
replace survey="HDS" if country_year=="IND_2011"
replace survey="HES" if country_year=="ISR_2012"
replace survey="HES" if country_year=="ISR_2014"
replace survey="HES" if country_year=="ISR_2016"
replace survey="FHES" if country_year=="KOR_2012"
replace survey="AIS" if country_year=="MOZ_2015"
replace survey="NHIES" if country_year=="NAM_2015"
replace survey="RLMS-HSE" if country_year=="RUS_2013"
replace survey="RLMS-HSE" if country_year=="RUS_2018"
replace survey="HFS" if country_year=="SSD_2017"
replace survey="HBS" if country_year=="TZA_2017"
replace survey="CPS-ASEC" if country_year=="USA_2013"
replace survey="EPH" if country_year=="ARG_2004"
*replace survey="ECLAC" if country_year=="ARG_2012"
*replace survey="ECLAC" if country_year=="ARG_2019"
*replace survey="ECLAC" if country_year=="BOL_2019"
replace survey="GEIH" if country_year=="COL_2018"
replace survey="HIES" if country_year=="GEO_2013"
replace survey="EMNV" if country_year=="NIC_2001"
replace survey="EMNV" if country_year=="NIC_2009"
*replace survey="ECLAC" if country_year=="PRY_2019"

replace survey="RLMS-HSE" if survey=="HSE"

drop country_year


*export in .DTA, then treat in R 

cd "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\WIDE_2023_files"

save "WIDE_2023_julytest_cleaned.dta", replace

*export delimited using "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\WIDE files\2023\WIDE_2023_july_cleaned.csv", replace

