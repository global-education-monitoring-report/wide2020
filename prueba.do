set processors 2

*For my laptop
global gral_dir "C:\Users\Rosa_V\Dropbox\WIDE"
global data_raw_dhs "C:\Users\Rosa_V\Dropbox\WIDE\Data\DHS"
global programs_dhs "$gral_dir\WIDE\WIDE_DHS\programs"
global programs_dhs_aux "$programs_dhs\auxiliary"
global aux_data "$gral_dir\WIDE\data_created\auxiliary_data"
global data_dhs "$gral_dir\WIDE\WIDE_DHS\data"
global temp "$data_dhs\temp"


*-----------------------------------------------------------------------------------

global varlist_edu edu_out_prim edu_out_lowsec edu_out_upsec attend_higher_1822 attend_higher_2022 comp_prim_v2_A comp_prim_v2_B comp_prim_1524_A comp_prim_1524_B comp_lowsec_v2_B comp_lowsec_1524_B comp_upsec_v2_A comp_upsec_v2_B comp_upsec_2029_A comp_upsec_2029_B comp_higher_2529_A comp_higher_2529_B	comp_higher_3034_A comp_higher_3034_B edu2_20 edu4_20 eduyears_20
global varlist_m edu_out_prim_m edu_out_lowsec_m edu_out_upsec_m attend_higher_1822_m attend_higher_2022_m comp_prim_v2_A_m comp_prim_v2_B_m comp_prim_1524_A_m comp_prim_1524_B_m comp_lowsec_v2_B_m comp_lowsec_1524_B_m comp_upsec_v2_A_m comp_upsec_v2_B_m comp_upsec_2029_A_m comp_upsec_2029_B_m comp_higher_2529_A_m comp_higher_2529_B_m comp_higher_3034_A_m comp_higher_3034_B_m edu2_20_m edu4_20_m eduyears_20_m
global varlist_no edu_out_prim_no edu_out_lowsec_no edu_out_upsec_no attend_higher_1822_no attend_higher_2022_no comp_prim_v2_A_no comp_prim_v2_B_no comp_prim_1524_A_no comp_prim_1524_B_no comp_lowsec_v2_B_no comp_lowsec_1524_B_no comp_upsec_v2_A_no comp_upsec_v2_B_no comp_upsec_2029_A_no comp_upsec_2029_B_no comp_higher_2529_A_no comp_higher_2529_B_no comp_higher_3034_A_no comp_higher_3034_B_no edu2_20_no edu4_20_no eduyears_20_no
global categories_collapse location sex wealth region ethnicity religion

global vars_keep_dhs "hhid hvidx hv000 hv001 hv002 hv003 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124 hv125 hv126 hv127 hv128 hv129"
global vars_value_labels "hv024 hv129"
global extra_vars cluster

* To run a codebook of the variables needed and produce log files
*include "$programs_dhs_aux\codebook_variables.do"


**************************************************************************************************
*	APPENDING ALL THE DATABASES (in 2 parts)
*----------------------------------------------------------------------------------------------------
* To run a codebook of the variables needed and produce log files
*include "$programs_dhs_aux\codebook_variables.do"

/*
*****************************************************************************************************
*	CREATING INDIVIDUAL DATABASES AND APPENDING THEM ALL 
*----------------------------------------------------------------------------------------------------

for X in any 1 2: cap mkdir "$data_dhs\PR\countries\\partX"

*foreach part in part1 part2 {
foreach part in part2 {
set more off
include "$programs_dhs_aux\survey_list_PR_`part'"

foreach file in $survey_list_PR {
use "$data_raw_dhs/`file'", clear

	tokenize "`file'", parse("\")
	gen country = "`1'" 
	gen year_folder= `3'

ren *, lower
for X in any $vars_keep_dhs : cap gen X=.
for X in any $vars_value_labels: cap decode X, gen(temp_X)
for X in any $vars_value_labels: cap tostring X, gen(temp_X)
drop $vars_value_labels
for X in any $vars_value_labels: cap ren temp_X X
cap label drop _all
keep $vars_keep_dhs country year*
cap label drop _all
compress
save "$data_dhs\PR\countries\\`part'\\`1'`3'", replace
}
}

*---------------------------------------------------------------------------------------------------------
* Appending all the databases
*---------------------------------------------------------------------------------------------------------


foreach part in part1 part2 {
cd "$data_dhs\PR\countries\\`part'"
local allfiles : dir . files "*.dta"

cap use "Albania2008.dta", clear
cap use "Jordan2012.dta", clear
gen id_c=1
foreach f of local allfiles {
   qui append using `f'
}
drop if id_c==1 // I eliminate the first country.
drop id_c

save "$data_dhs\PR\dhs_PR_append_`part'.dta" , replace
}


*---------------------------------------------------------------------------------------------------------

*Translate: I tried with encoding "ISO-8859-1" and it didn't work
set more off
foreach part in part1 part2 {
clear
cd "$data_dhs\PR"
unicode analyze "dhs_PR_append_`part'.dta"
unicode encoding set ibm-912_P100-1995
unicode translate "dhs_PR_append_`part'.dta"
}


**************************************************************************
*			Fixing categories and creating variables
**************************************************************************
set more off
foreach part in part1 part2 {
use "$data_dhs\PR\dhs_PR_append_`part'.dta" , clear

*use "$data_dhs\PR\dhs_PR_append_part2.dta" , clear

* ID for each country year: Variable country_year. Year of survey can be different from the year in the name of the folder
gen country_year=country+ "_"+string(year_folder)
* Country dhs code
gen country_code_dhs=substr(hv000, 1, 2)

*Round of DHS
gen round_dhs=substr(hv000, 3, 1)
drop hv000
replace round_dhs="4" if country_year=="VietNam_2002"

*Individual ids
for X in any hv001 hv002 hvidx: gen X_s=string(X, "%25.0f")
gen individual_id = country_year+" "+hv001_s+" "+hv002_s+" "+hvidx_s

*Special cases IDs for countries: Honduras_2005, Mali_2001, Peru_2012, Senegal_2005
replace individual_id=country_year+" "+hhid+" "+hvidx_s if (country_year=="Honduras_2005"|country_year=="Mali_2001"|country_year=="Peru_2012"|country_year=="Senegal_2005")
replace individual_id=country_year+" "+hhid+" "+"0"+hvidx_s if country_year=="Peru_2012"
replace individual_id=country_year+" "+hhid+" "+" "+hvidx_s if hvidx<=9 & (country_year=="Mali_2001"|country_year=="Honduras_2005"|country_year=="Senegal_2005") 

codebook individual_id // uniquely identifies all except Turkey 2008


gen n=1
bys country_year individual_id: egen d_count=sum(n)
tab d_count
br individual country_year hv001_s hv002_s hvidx_s if d_count>=2
tab country_year if d_count>=2 // problems with ID of Turkey 2008...
drop n d_count


*Household ids
gen hh_id = country_year+" "+hv001_s+" "+hv002_s // to merge with other modules by hh_id
ren hhid hhid_original
drop *_s

*Cluster variable
ren hv001 cluster

*drop hhid

* "Official" Year of the survey is hv007. 
* I median of year

*Fixing problems with year: variable hv007
*codebook hv007, tab(100)
	replace hv007=1990 if hv007==. & country_year=="Colombia_1990" 
	replace hv007=2000 if hv007==0 & (country_year=="Gabon_2000"|country_year=="Bangladesh_1999"|country_year=="India_1998")
	replace hv007=2001 if hv007==1 & country_year=="Gabon_2000" 	// label was 2001, but the value said 1
	replace hv007=2002 if hv007==2 & country_year=="VietNam_2002" 	// label was 2002, but the value said 2

	* COUNTRIES WITH DIFFERENT CALENDAR: the years/months don't coincide with the Gregorian Calendar
	*Nepal 2001
	recode hv006 (10=1) (11=2) (12=3) (1=4) (2=5) (3=6) if country_year=="Nepal_2001"
	replace hv007=2001 if country_year=="Nepal_2001"
	
	*Nepal 2006
	recode hv006 (10=2) (11=3) (12=4) (1=5) (2=6) (3=7) (4=8) if country_year=="Nepal_2006"
	replace hv007=2006 if country_year=="Nepal_2006"
	
	*Nepal 2011
	recode hv006 (10=2) (11=3) (12=4) (1=5) (2=6) if country_year=="Nepal_2011"
	replace hv007=2011 if country_year=="Nepal_2011"
	
	*Nepal 2016
	recode hv006 (3=6) (4=7) (5=8) (6=9) (7=10) (8=11) (9=12) (10=1) if country_year=="Nepal_2016"
	replace hv007=2016 if hv006>=3 & hv006<=12 & country_year=="Nepal_2016"
	replace hv007=2017 if hv006==1 & country_year=="Nepal_2016"

	*Afghanistan
	recode hv006 (1=4) (2=5) (3=6) (4=7) (5=8) (6=9) (7=10) (8=11) (9=12) (10=1) (11=2) if country_year=="Afghanistan_2015"
	replace hv007=2015 if hv006>=4 & hv006<=12 & country_year=="Afghanistan_2015"
	replace hv007=2016 if (hv006==1|hv006==2) & country_year=="Afghanistan_2015"

	*Ethiopia
	recode hv006 (5=1) (6=2) (7=3) (8=4) (9=5) (10=6) if country_year=="Ethiopia_2016"
	replace hv007=2016 if country_year=="Ethiopia_2016"

	recode hv006 (4=12) (5=1) (6=2) (7=3) (8=4) (9=5) if country_year=="Ethiopia_2011"
	replace hv007=2010 if hv006==12 & country_year=="Ethiopia_2011"
	replace hv007=2011 if hv006>=1 & hv006<=5 & country_year=="Ethiopia_2011"

	recode hv006 (8=4) (9=5) (10=6) (11=7) (12=9) if country_year=="Ethiopia_2005"
	replace hv007=2005 if country_year=="Ethiopia_2005"

	recode hv006 (6=2) (7=3) (8=4) (9=5) (10=6) if country_year=="Ethiopia_2000"
	replace hv007=2000 if country_year=="Ethiopia_2000"

	replace hv006=10 if hv006==1 & hv007==2013 & country_year=="Togo_2013" 
	
	drop if (hv007==2003|hv007==2004|hv007==2005|hv007==2006) & country_year=="Peru_2007" // For Peru, we have to drop the observations for years not included in that country_year

	foreach num of numlist 0/9 {    //Fix format of years
		replace hv007=199`num' if hv007==9`num'
	}
	
	*Missing in the day or month of interview
	replace hv016=1 if (country_year=="Colombia_1990"|country_year=="Indonesia_1991"|country_year=="Indonesia_1994") // Take the 1st of the month
	replace hv006=7 if hv006==. & country_year=="Colombia_1990"  // Take the month in the middle of the 2 fieldwork dates
		
	*Inconsistency in number of days for the month. 7567 cases
	*Countries: Afghanistan 2015; Ethiopia (2000, 20011, 2016); Nepal (2001,2006,2011,2016); Nigeria 2008 (1 case)
	replace hv016=30 if hv016==31 & (hv006==4|hv006==6|hv006==9|hv006==11) & (country=="Afghanistan"|country=="Ethiopia"|country=="Nepal"|country=="Nigeria") // Months that don't have 31 days...
	replace hv016=28 if hv016>=29 & hv006==2 & (country=="Afghanistan"|country=="Ethiopia"|country=="Nepal"|country=="Nigeria") // Most of the cases are for February
	replace hv016=31 if hv016==32 & (hv006==5|hv006==7) & (country=="Nepal")

*Create the variable YEAR
	bys country_year: egen year=median(hv007)
	drop if year<=1999 // drop the countries that have the median year of 1999


*-----------------------------------------------------------------------------------------------
* Merge with Duration in years, start age and names of countries (codes_dhs, mics_dhs, iso_code, WIDE names)
merge m:m country_code_dhs using "$aux_data\country_iso_codes_names.dta", keepusing(iso_code3)  // to obtain the iso_code3
replace iso_code3="PNG" if country=="PapuaNewGuinea"
drop if _merge==2
drop _merge
*Now we have year 2018, but the database of duration only has until 2017
ren year year_original
gen year=year_original
replace year=2017 if year_original>=2018
merge m:1 iso_code3 year using "$aux_data\UIS\duration_age\UIS_duration_age_25072018.dta"
drop year
ren year_original year
	drop if _m==2
	drop _merge
	drop lowsec_age_uis upsec_age_uis
	for X in any prim_dur lowsec_dur upsec_dur: ren X_uis X
	ren prim_age_uis prim_age0
	
compress 
*save "$data_dhs\PR\Step0_part2.dta", replace
save "$data_dhs\PR\Step0_`part'.dta", replace
}



*-----------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------

*************************************************************
*	AGE ADJUSTMENT
*************************************************************
set more off
foreach part in part1 part2 {
use "$data_dhs\PR\Step0_`part'.dta", clear
*use "$data_dhs\PR\Step0_part2.dta", clear

keep hv006 hv007 hv016 country year country_year iso_code3

*Merge with info about reference school year:
merge m:1 country_year using  "$aux_data\temp\current_school_year_DHS.dta"
drop if _merge==2 // this includes the data from 2016 that needs to be added
drop _merge
drop yearwebpage currentschoolyearDHSreport

gen year_c=hv007
replace year_c=2017 if year_c>=2018 // I only have data on school calendar until 2017
merge m:m iso_code3 year_c using "$aux_data\UIS\months_school_year\month_start.dta"
br if _m==1
drop if _merge==2
drop _merge max_month min_month diff
drop year_c

*All countries have month_start. Malawi_2015 has now the month 9 (OK)
	ren school_year current_school_year

*For those with missing in school year, I replace by the interview year
gen missing_current_school_year=1 if current_school_year==.
replace current_school_year=hv007 if current_school_year==.


tab hv007 if country_year=="PapuaNewGuinea_2016"

*-------------------------------------------------------------------------------------
* Adjustment VERSION 1: Difference in number of days 
*-			Start school	: Month from UIS database (we only had years 2009/2010 and 2014/2015. The values for the rest of the years were imputed by GEM
*- 			Interview		: Month as presented in the survey data
*-------------------------------------------------------------------------------------
	
	gen month_start_norm=month_start
	
*Taking into account the days	
	for X in any norm max min: gen s_school1_X=string(1)+"/"+string(month_start_X)+"/"+string(current_school_year)
	gen s_interview1=string(hv016)+"/"+string(hv006)+"/"+string(hv007) // date of the interview created with the original info

	for X in any norm max min: gen date_school1_X=date(s_school1_X, "DMY",2000) 
	gen date_interview1=date(s_interview1, "DMY",2000)
	
*Without taking into account the days
	for X in any norm max min: gen s_school2_X=string(month_start_X)+"/"+string(current_school_year)
	gen s_interview2=string(hv006)+"/"+string(hv007) // date of the interview created with the original info
	
	for X in any norm max min: gen date_school2_X=date(s_school2_X, "MY",2000) // official month of start... plus school year of reference
	gen date_interview2=date(s_interview2, "MY",2000)

*Adjustment=1 if 50% or more of hh (the median) have difference of (month_interv-month_school)>=6 months.
*Median difference is >=6.
*50% of hh have 6 months of difference or more
*gen diff1=(date_interview1-date_school1)/(365/12) // expressed in months

foreach M in norm max min {
foreach X in 1 2 {
	gen diff`X'_`M'=(date_interview`X'-date_school`X'_`M')
	gen temp`X'_`M'=mod(diff`X'_`M',365) 
	replace diff`X'_`M'=temp`X'_`M' if missing_current_school_year==1
	bys country_year: egen median_diff`X'_`M'=median(diff`X'_`M')
	gen adj`X'_`M'=0
	replace adj`X'_`M'=1 if median_diff`X'_`M'>=182
}
}

sort country_year
collapse diff* adj* flag_month, by(country_year)		
	
save "$data_dhs\PR\dhs_adjustment_`part'.dta", replace
}


use "$data_dhs\PR\dhs_adjustment_part1.dta", clear
append using "$data_dhs\PR\dhs_adjustment_part2.dta"
compress
save "$data_dhs\PR\dhs_adjustment.dta", replace
*for X in any 1 2: erase "$data_dhs\PR\dhs_adjustment_partX.dta"

*/

**************************************************************************************************************************
**************************************************************************************************************************
*-------------------------------------------------------------------------------
*	CREATING EDUC VARIABLES AND CATEGORIES
*-------------------------------------------------------------------------------

foreach part in part1 part2 {
set more off
use "$data_dhs\PR\Step0_`part'.dta", clear
*use "$data_dhs\PR\Step0_part2.dta", clear

*Creating the variables for EDUOUT indicators
	for X in any prim_dur lowsec_dur upsec_dur: gen X_eduout=X 
	gen prim_age0_eduout=prim_age0
	

*FOR COMPLETION: Changes to match UIS calculations

*Changes to duration
replace prim_dur=6 if country_year=="Gabon_2012" // UIS matches 2012 ADJUSTED
replace upsec_dur=3 if country_year=="SierraLeone_2013" // upsec dur changed from 3 to 4 in 2013, but school year starts in September.

*Changes to durations/age made in August 2019

replace prim_dur=4 if country_year=="Albania_2008"
replace upsec_dur=4 if country_year=="Albania_2008"

replace prim_age0=7 if country_year=="Armenia_2015"
replace prim_dur=3 if country_year=="Armenia_2015"
replace upsec_dur=2 if country_year=="Armenia_2015"

*Changes to duration (Feb 2020), to match what is presented in the data
replace prim_age0=7 if country_year=="PapuaNewGuinea_2016"
replace prim_dur=6 if country_year=="PapuaNewGuinea_2016"
replace lowsec_dur=4 if country_year=="PapuaNewGuinea_2016"
replace upsec_dur=2 if country_year=="PapuaNewGuinea_2016"

*Questions to UIS
*- Burkina Faso 2010 (DHS) should use age 6 or 7 as start age? The start age changes from 7 to 6 in 2010, the school year starts in October.
*- Egypt 2005 DHS: prim dur changes from 5 to 6 in 2005. Should we use 5 or 6 for year 2005 considering that school years starts in September.
*- Armenia 2010 DHS: All the interviews were in 2010, but UIS says it is year 2011 and has put duration and ages of that year. We put duration and age for 2010 and our results match UNICEF'S
*Education: hv107, hv108, hv109, hv121
compress 
save "$data_dhs\PR\Step1_`part'.dta", replace
*save "$data_dhs\PR\Step1_part2.dta", replace
}


***************************************************************

foreach part in part1 part2 {
set more off
use "$data_dhs\PR\Step1_`part'.dta", clear

*use "$data_dhs\PR\Step1_part2.dta", clear

*------------------------------------------------------------------------------------------
* Creates education variables
*------------------------------------------------------------------------------------------
*****************************
*	VERSION A
*****************************

* For Completion: Version A is directly with hv109; Version B uses years of education and duration

*Creating generic variables for WIDE
* Attainment, years of education, attendance
*hv109: 0=no education, 1=incomplete primary, 2=complete primary, 3=incomplete secondary, 4=complete secondary, 5=higher
						 
*Primary
gen comp_prim_A=0
replace comp_prim_A=1 if hv109>=2
replace comp_prim_A=. if (hv109==.|hv109==8|hv109==9)

*Upper secondary
gen comp_upsec_A=0
replace comp_upsec_A=1 if hv109>=4  //hv109=4: Complete secondary
replace comp_upsec_A=. if (hv109==.|hv109==8|hv109==9)

*Higher
gen comp_higher_A=0
replace comp_higher_A=1 if hv109>=5 //hv109=5: Higher
replace comp_higher_A=. if (hv109==.|hv109==8|hv109==9)


*****************************
*	VERSION B
*****************************
* Version B: Mix of years of education completed (hv108) and duration of levels --> useful for lower secondary
*----------------------
*	DURATION OF LEVELS
*----------------------
*With the info of years that last primary and secondary I can also compare official duration with the years of education completed..
	gen years_prim		=prim_dur
	gen years_lowsec	=prim_dur+lowsec_dur
	gen years_upsec		=prim_dur+lowsec_dur+upsec_dur
	*gen years_higher	=prim_dur+lowsec_dur+upsec_dur+higher_dur

*Ages for completion
	gen lowsec_age0=prim_age0+prim_dur
	gen upsec_age0=lowsec_age0+lowsec_dur
	for X in any prim lowsec upsec: gen X_age1=X_age0+X_dur-1
	
	
bys country_year: egen count_hv108=count(hv108)
tab country_year if count_hv108==0
drop count_hv108 // need to check info sh17_a sh17_b for Yemen 2013


*CHANGES IN HV108

*Republic of Moldova doesn't have info on eduyears
replace hv108=hv107 if (hv106==0|hv106==1) & country_year=="RepublicofMoldova_2005"
replace hv108=hv107+years_prim if hv106==2 & country_year=="RepublicofMoldova_2005"
replace hv108=hv107+years_upsec if hv106==3 & country_year=="RepublicofMoldova_2005"
replace hv108=98 if hv106==8 & country_year=="RepublicofMoldova_2005"
replace hv108=99 if hv106==9 & country_year=="RepublicofMoldova_2005"

*Changes to hv108 made in August 2019
replace hv108=. if country_year=="Armenia_2005"
replace hv108=0 if hv106==0 & country_year=="Armenia_2005" // "primary"
replace hv108=hv107 if hv106==1 & country_year=="Armenia_2005" // "primary"
replace hv108=hv107+5 if hv106==2 & country_year=="Armenia_2005" // "secondary"
replace hv108=hv107+10 if hv106==3 & country_year=="Armenia_2005" //"higher"

replace hv108=. if country_year=="Armenia_2010"
replace hv108=0 if hv106==0 & country_year=="Armenia_2010" // "primary" & secondary
replace hv108=hv107 if hv106==1|hv106==2 & country_year=="Armenia_2010" // "primary" & secondary
replace hv108=hv107+10 if hv106==3  & country_year=="Armenia_2010" //"higher"

replace hv108=. if country_year=="Egypt_2008"
replace hv108=0 if hv106==0 & country_year=="Egypt_2008"
replace hv108=hv107 if hv106==1 & country_year=="Egypt_2008"
replace hv108=hv107+6 if hv106==2 & country_year=="Egypt_2008"
replace hv108=hv107+12 if hv106==3 & country_year=="Egypt_2008"

replace hv108=. if country_year=="Egypt_2014"
replace hv108=0 if hv106==0 & country_year=="Egypt_2014"
replace hv108=hv107 if hv106==1 & country_year=="Egypt_2014"
replace hv108=hv107+6 if hv106==2 & country_year=="Egypt_2014"
replace hv108=hv107+12 if hv106==3 & country_year=="Egypt_2014"

replace hv108=. if country_year=="Madagascar_2003"
replace hv108=0 if hv106==0 & country_year=="Madagascar_2003"
replace hv108=hv107 if hv106==1 & country_year=="Madagascar_2003"
replace hv108=hv107+5 if hv106==2 & country_year=="Madagascar_2003"
replace hv108=hv107+12 if hv106==3 & country_year=="Madagascar_2003"

replace hv108=. if country_year=="Madagascar_2008"
replace hv108=0 if hv106==0 & country_year=="Madagascar_2008"
replace hv108=hv107 if hv106==1 & country_year=="Madagascar_2008"
replace hv108=hv107+6 if hv106==2 & country_year=="Madagascar_2008" // I add 6, not 5 to correct
replace hv108=hv107+13 if hv106==3 & country_year=="Madagascar_2008" // I add 13, not 6 to correct

replace hv108=. if country_year=="Zimbabwe_2005"
replace hv108=0 if hv106==0 & country_year=="Zimbabwe_2005" // "no education"
replace hv108=hv107 if hv106==1 & country_year=="Zimbabwe_2005" // "primary"
replace hv108=hv107+7 if hv106==2 & country_year=="Zimbabwe_2005" // "secondary"
replace hv108=hv107+13 if hv106==3 & country_year=="Zimbabwe_2005" //"higher"	
	
*tab hv108 if country_year=="PapuaNewGuinea_2016"
*tab hv109 if country_year=="PapuaNewGuinea_2016"
*tab hv108 hv109 if country_year=="PapuaNewGuinea_2016"
	
*Creating "B" variables
foreach X in prim lowsec upsec {
	cap gen comp_`X'_B=0
	replace comp_`X'_B=1 if hv108>=years_`X'
	replace comp_`X'_B=. if (hv108==.|hv108>=90) // here includes those ==98, ==99 
	replace comp_`X'_B=0 if (hv108==0|hv109==0) // Added in Aug 2019!!	
}

*For 2 countries, I use hv109 (I don't find other solution)
replace comp_upsec_B=comp_upsec_A if country_year=="Egypt_2005" // I don't know why if goes to 28.93 if I don't do this... Check difference between A & B later
compress

*save "$data_dhs\PR\Step2_part2.dta", replace
save "$data_dhs\PR\Step2_`part'.dta", replace
}
****************************************************

/*
***********************
*For Bilal's request
***********************

*https://dhsprogram.com/Data/Guide-to-DHS-Statistics/School_Attendance_Ratios.htm
*https://dhsprogram.com/pubs/pdf/DHSG4/Recode7_Map_31Aug2018_DHSG4.pdf

* HV121 Household member attended school during current school year.
* HV122 Educational level attended during current school year, with the same standardized levels as explained for HV106. (0=no education/preschool, 1=primary, 2=secondary, 3=higher)

use "$data_dhs\PR\Step2_part1.dta", clear
append using "$data_dhs\PR\Step2_part2.dta"
keep iso hv005 hv104 country* year hv105 hv12* year* prim_age0
drop country_code_dhs years_prim years_lowsec years_upsec
keep if year>=2015

ren hv105 age
ren hv005 hhweight

label define hv121 0 "no" 1 "currently attending" 2 "attended some time"
label define hv122 0 "no educ/preschool" 1 "primary" 2 "secondary" 3 "higher"
for X in any 1 2: label values hv12X hv12X

gen country_age=country_year+" "+"(AgeStart"+"="+string(prim_age0)+")"
order iso_code3 country_year country year year_folder prim_age0
compress
save "$data_dhs\PR\dhs_temp_attendance.dta", replace

*---------------------------------------------------------
use "$data_dhs\PR\dhs_temp_attendance.dta", clear

replace hv122=. if hv122==8|hv122==9
replace hv126=. if hv126==8|hv126==9

*Attendance current year
recode hv121 (1/2=1) (8/9=.), gen(attend_current)
label define yn 0 "no" 1 "yes"
label values attend_current yn


*Attendance previous year--> The variables is still 0=no, 1=yes (I checked each database)
clonevar attend_previous=hv125 

*To find out starting from what age there is info on attendance
bys country_year age: egen max_attend_current=max(attend_current)
bys country_year age: egen max_attend_previous=max(attend_previous)

bys country_year: tab age max_attend_current, m
bys country_year: tab age max_attend_previous, m

*Replacing by missing those that don't have info on edu but appear with no attending
for X in any current previous: replace attend_X=. if max_attend_X==0
drop max*

*bys country_age: tab age attend_curr if age>=3 & age<=8, m
*bys country_age: tab hv122 attend_curr if age>=3 & age<=8, m
*bys country_age: tab attend_curr if age>=3 & age<=8, m
*codebook hv122, tab(100)

gen status_current=1 if attend_current==0
replace status_current=2 if attend_current==1 & hv122==0 // pre-primary level
replace status_current=3 if attend_current==1 & hv122==1 // primary level
replace status_current=4 if attend_current==1 & hv122==2 // secondary level
replace status_current=5 if attend_current==1 & hv122==3 // higher level

tab age status_current if country=="Afghanistan"
tab age attend_current if country=="Afghanistan"

gen status_previous=1 if attend_previous==0
replace status_previous=2 if attend_previous==1 & hv126==0 // pre-primary level
replace status_previous=3 if attend_previous==1 & hv126==1 // primary level
replace status_previous=4 if attend_previous==1 & hv126==2 // secondary level
replace status_previous=5 if attend_previous==1 & hv126==3 // higher level

label define level_ed 1 "oos" 2 "preschool" 3 "primary" 4 "secondary" 5 "higher"
foreach X in current previous {
	label values status_`X' level_ed
	tab status_`X', gen(`X'_)
	ren `X'_1 `X'_oos
	ren `X'_2 `X'_preschool
	ren `X'_3 `X'_primary
	ren `X'_4 `X'_secondary
	ren `X'_5 `X'_higher	
}

*bys country_age: tab current_preschool if age>=3 & age<=8, m
*bys country_age: sum current_o current_pre current_pri if age>=3 & age<=8

* OOS last year (previous_oos==1)
*-- and oos this year (value=2)
*-- and primary this year  (value=3)
*-- and pre-primary this year  (value=4)

gen current=0 if previous_oos==1
replace current=1 if previous_oos==1 & current_oos==1
replace current=2 if previous_oos==1 & current_preschool==1
replace current=3 if previous_oos==1 & current_primary==1
replace current=4 if previous_oos==1 & current_secondary==1
replace current=5 if previous_oos==1 & current_higher==1
replace current=. if current==0 & hv122==.
label define current 1 "CurrOos" 2 "CurrPresc" 3 "CurrPrim" 4 "CurrSec" 5 "CurrHigh"
label values current current

tab current, gen(PrevOos_)
ren PrevOos_1 PrevOos_CurrOos
ren PrevOos_2 PrevOos_CurrPresc
ren PrevOos_3 PrevOos_CurrPrim
ren PrevOos_4 PrevOos_CurrSec
ren PrevOos_5 PrevOos_CurrHigh

merge m:1 country_year using "$data_dhs\PR\dhs_adjustment.dta", keepusing(adj1_norm)
drop if _merge==2
drop _merge
ren adj1_norm adjustment

*Creating the appropiate age according to adjustment
gen ageU=age
gen ageA=age-1 

gen agestandard=ageU if adjustment==0
replace agestandard=ageA if adjustment==1


collapse prim_age0 current_* previous_* PrevOos_* if age>=5 & age<=10 [iw=hhweight], by(iso_code country year)
collapse prim_age0 current_* previous_* PrevOos_* if agestandard>=5 & agestandard<=10 [iw=hhweight], by(iso_code country year)


collapse prim_age0 current_* previous_* PrevOos_* if age>=5 & age<=10 [iw=hhweight], by(iso_code country year age)

collapse prim_age0 current_* previous_* PrevOos_* [iw=hhweight], by(iso_code country year age)
collapse prim_age0 current_* previous_* PrevOos_* [iw=hhweight], by(iso_code country year agestandard)


tab comparison, m

replace comparison=. if previous_oos==1 & hv122==.

tab comparison if age>=3 & age<=8, m

ren 

br if comparison==1 & (age>=3 & age<=10)

tab country_age if attend_current==1 & comparison==1

bys country_age: tab attend_current if hv122==., m




*codebook hv121 hv129 hv122 hv123 hv124 , tab(100) // current year 
*codebook hv125 hv126 hv127 hv128, tab(100) // previous year



*hv125: 0=no, 1=yes
clonevar attend_prev=hv125
tab hv126 hv125, m
*replace attend_prev=1 if hv125==0 & hv126==0 // those in preschool (diff for oos)
*replace attend_prev=. if hv126==. & (hv125==1|hv125==2|hv125==8|hv125==.)

foreach X in hv122 hv126 {
	gen `X'c="preschool" if `X'==0
	replace `X'c="primary" if `X'==1
	replace `X'c="secondary" if `X'==2
	replace `X'c="higher" if `X'==3
}



*No attend
recode attend_curr (1=0) (0=1), gen(noattend_curr)
recode attend_prev (1=0) (0=1), gen(noattend_prev)


*tab hv122 attend, m
*tab hv122 attend if age==10, m

codebook hv122, tab(100)
tab hv122 hv121, m


for X in any preschool primary secondary higher: gen attend_curr_X=0
replace attend_curr_preschool =1 if hv122==0 
replace attend_curr_primary   =1 if hv122==1 
replace attend_curr_secondary =1 if hv122==2
replace attend_curr_higher    =1 if hv122==3
*for X in any preschool primary secondary higher: replace attend_curr_X=. if hv121==.


for X in any preschool primary secondary higher: gen attend_prev_X=0 if attend_prev==1
replace attend_prev_preschool =1 if hv126==0 & attend_prev_preschool ==0 
replace attend_prev_primary   =1 if hv126==1 & attend_prev_primary   ==0 
replace attend_prev_secondary =1 if hv126==2 & attend_prev_secondary ==0
replace attend_prev_higher    =1 if hv126==3 & attend_prev_higher    ==0
for X in any preschool primary secondary higher: replace attend_prev_X=. if (attend_prev==.|hv126==.)

tab attend_curr, 
for X in any preschool primary secondary higher: tab attend_curr_X attend_curr, m

*sum noattend attend* at_* if age==10, separator(11)

collapse noattend_curr attend_curr*  [iw=hhweight], by (iso_code3 country_year country year age)

order iso_code3 country_year country year age no_attend attend*

save "$data_dhs/DHS_age_attendance.dta", replace
export delimited using "$data_dhs/DHS_age_attendance.csv", replace

*/


foreach part in part1 part2 {
use "$data_dhs\PR\Step2_`part'.dta", clear
*use "$data_dhs\PR\Step2_part2.dta", clear
set more off

*Age
ren hv105 age
replace age=. if age>=98

	gen ageA=age-1 // before it had the restriction "if adj==1" . I'll show both adjusted and unadjusted and a flag that says if it should be adjusted!
	ren age ageU

*Attendance to higher educ
recode hv121 (1/2=1) (8/9=.), gen(attend)

*------------------
*	Out of school
*------------------
*codebook hv121 hv122, tab(100)

gen eduout_1=.
replace eduout_1=0 if (hv121==1|hv121==2) // goes to school
replace eduout_1=1 if (hv121==0) // does not go to school
replace eduout_1=. if ageU==.
replace eduout_1=. if (hv121==8|hv121==9|hv121==.)
replace eduout_1=. if (hv122==8|hv122==9) & eduout_1==0 // missing when age, attendance or level of attendance (when goes to school) is missing

gen eduout=eduout_1
replace eduout=1 if hv122==0 // level attended: goes to preschool
*** replace eduout=1 if hv106==0 // those whose highest ed level is preschool.. DO NOT ADD THIS LINE, makes it really different to UIS estimates!! See the version 4 for the results!
drop eduout_1

*--------------------------------------------
* Completion indicators (version A & B) with age limits 
*--------------------------------------------
*Age limits for Version A and B
foreach Y in A B {
foreach X in prim upsec {
foreach AGE in ageU ageA {
	gen comp_`X'_v2_`Y'_`AGE'=comp_`X'_`Y' if `AGE'>=`X'_age1+3 & `AGE'<=`X'_age1+5 
}
}
}

merge m:1 country_year using "$data_dhs\PR\dhs_adjustment.dta", keepusing(adj1_norm)
*merge m:1 country_year using "C:\Users\Rosa_V\Desktop\casa\dhs_adjustment.dta", keepusing(adj1_norm)
drop if _merge==2
drop _merge
ren adj1_norm adjustment

*Creating the appropiate age according to adjustment
gen agestandard=ageU if adjustment==0
replace agestandard=ageA if adjustment==1

*Age limits 
foreach AGE in agestandard  {
	for X in any prim upsec: cap gen comp_X_v2_A=comp_X_A if `AGE'>=X_age1+3 & `AGE'<=X_age1+5
}

*-- Collapse for comparison with UIS (adjusted vs not adjusted)
*collapse (mean) comp_prim_v2* comp_lowsec_v2* comp_upsec_v2* prim_age* lowsec_age* upsec_age*  [iw=hv005], by(country_year country iso_code3 year adjustment)

*Dropping adjusted ages and the _ageU indicators (but keep ageU)
cap drop *ageA *_ageU

*I keep the version B
for X in any prim lowsec upsec: ren comp_X_B comp_X

*Age limits 
foreach AGE in agestandard  {
	for X in any prim lowsec upsec: gen comp_X_v2=comp_X if `AGE'>=X_age1+3 & `AGE'<=X_age1+5
	gen comp_prim_1524=comp_prim if `AGE'>=15 & `AGE'<=24
	gen comp_upsec_2029=comp_upsec if `AGE'>=20 & `AGE'<=29
	*gen comp_higher_2529=comp_higher if `AGE'>=25 & `AGE'<=29
	gen comp_lowsec_1524=comp_lowsec if `AGE'>=15 & `AGE'<=24
}

*-- Collapse comparing hv108 & hv109
*collapse (mean) comp_prim_v2 comp_prim_v2_A comp_lowsec_v2 comp_upsec_v2 comp_upsec_v2_A prim_age* lowsec_age* upsec_age*  [iw=hv005], by(country_year country iso_code3 year adjustment)

*Dropping the A version (not going to be used)
cap drop *_A

* FOR UIS request
gen comp_prim_aux=comp_prim if agestandard>=lowsec_age1+3 & agestandard<=lowsec_age1+5
gen comp_lowsec_aux=comp_lowsec if agestandard>=upsec_age1+3 & agestandard<=upsec_age1+5

*--------------------
* Years of education
*--------------------
*codebook hv108, tab(200)
*If this eduyears would be a version, it would be version "A" because it comes directly from DHS variables.
gen eduyears=hv108
replace eduyears=30 if hv108>=30 // I put the max of years as 30
replace eduyears=. if hv108>=90

*With age limits
gen eduyears_2024=eduyears if agestandard>=20 & agestandard<=24
foreach X in 2 4 {
	gen edu`X'_2024=0
	replace edu`X'_2024=1 if eduyears_2024<`X'
	replace edu`X'_2024=. if eduyears_2024==.
}

*----------------------
* Never been to school
*----------------------
recode hv106 (0=1) (1/3=0) (4/9=.), gen(edu0)
gen never_prim_temp=1 if (hv106==0|hv109==0) & (hv107==. & hv123==.)
replace edu0=1 if (eduyears==0|never_prim_temp==1)
replace edu0=. if eduyears==.

foreach AGE in agestandard  {
	gen edu0_prim1=edu0 if `AGE'>=prim_age0+3 & `AGE'<=prim_age0+6
	*gen edu0_prim2=edu0 if `AGE'>=prim_age0+2 & `AGE'<=prim_age0+4
	*gen edu0_prim3=edu0 if `AGE'>=prim_age0+4 & `AGE'<=prim_age0+8
}

drop never_prim_temp edu0

*codebook hv121 hv122, tab(200)
gen attend_higher=0
replace attend_higher=1 if [(hv121==1|hv121==2) & hv122==3]
replace attend_higher=. if [(hv121==8|hv121==9)|(hv122==8|hv122==9)]


*Durations for out-of-school
	gen lowsec_age0_eduout=prim_age0_eduout+prim_dur_eduout
	gen upsec_age0_eduout=lowsec_age0_eduout+lowsec_dur_eduout
	for X in any prim lowsec upsec: gen X_age1_eduout=X_age0_eduout+X_dur_eduout-1
	
*Creating variables for Bilal: attendance to each level by age
*https://dhsprogram.com/Data/Guide-to-DHS-Statistics/School_Attendance_Ratios.htm

keep country_year year hv005 age* iso_code3 hv007 hv104 hv025 hv270 hv005 hv024 comp_* eduout* attend* $extra_vars prim_dur lowsec_dur upsec_dur prim_age* lowsec_age* upsec_age* hh* hvidx individual_id attend round adjustment edu* hh* hv122 hv124 years_*

foreach AGE in agestandard {
	for X in any prim lowsec upsec: gen eduout_X=eduout if `AGE'>=X_age0_eduout & `AGE'<=X_age1_eduout
	gen attend_higher_1822=attend_higher if `AGE'>=18 & `AGE'<=22
}
drop attend_higher

* CREATING THE DISSAGREGATION VARIABLES & weight

*weight
ren hv005 hhweight // sample weight

*table country_year [iw=hhweight], c(mean comp_prim_v2 mean comp_lowsec_v2 mean comp_upsec_v2)

*Location (Urban=1)
ren hv025 location
recode location (2=0) (9=.)
label define location 0 "rural" 1 "urban"

*Sex
ren hv104 sex
recode sex (2=0) (9=.) (3/4=.)
label define sex 0 "female" 1 "male"

*Wealth
ren hv270 wealth
label define wealth 1 "quintile 1" 2 "quintile 2" 3 "quintile 3" 4 "quintile 4" 5 "quintile 5"

for Z in any location sex wealth: label values Z Z

*Converting the categories to strings
foreach var in location sex wealth {
	cap decode `var', gen(t_`var')
	cap drop `var'
	cap ren t_`var' `var'
	cap replace `var'=proper(`var')
}

*Region
ren hv024 region

	** Solving name of regions
		*Region: Had to be transformed to string before appending every country to avoid putting the same label to all regions
		*https://www.stata.com/manuals13/m-4string.pdf#m-4string
		qui include "$programs_dhs_aux/dhs_fixes_regions.do"

*Religion
* should see how to uniquely identify HOUSEHOLDS later
merge m:m hh_id using "$data_dhs\dhs_ethnicity_religion_v2.dta", keepusing (ethnicity religion)
drop if _merge==2 // added Aug 2019
cap drop _merge

ren ageU age

order country_year iso_code3 year hhweight age* hv007 $categories_collapse comp_* eduout* edu* attend* $extra_vars round adjustment
compress
*save "$data_dhs\PR\Step3_part2.dta", replace
save "$data_dhs\PR\Step3_`part'.dta", replace
}


set more off
use "$data_dhs\PR\Step3_part1.dta", clear
append using  "$data_dhs\PR\Step3_part2.dta"
drop year
bys country_year: egen year=median(hv007)
keep hhweight *age* hv007 year ///
iso_code3 country* cluster hh_id individual_id round ///
adjustment comp* edu* *attend* location sex wealth ethnicity religion region 
drop *aux*
*drop region ethnicity religion
ren hv007 year_interview
label var year "Median year of interview"
ren agestandard age_adjusted
cap drop *_ageU
drop edu0_prim1
drop *age0* *age1*
order iso country* year* *weight *id cluster age* adjustment location sex wealth ethnicity religion eduyear* comp* attend* eduout*
compress
*save "\\hqfs\tech\STATA\WIDE\microdata_Bilal\DHS_Microdata.dta", replace // this is the database I sent to Bilal
save "C:\Users\Rosa_V\Dropbox\microdata_Bilal\microdata_DHS.dta", replace // this is the database I sent to Bilal

*********************************************************************************************************************************
global vars_comp comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029
global vars_eduout edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_m comp_prim_v2 comp_lowsec_v2 comp_upsec_v2 comp_prim_1524 comp_lowsec_1524 comp_upsec_2029 eduyears_2024 edu2_2024 edu4_2024 eduout_prim eduout_lowsec eduout_upsec
global varlist_no comp_prim_v2_no comp_lowsec_v2_no comp_upsec_v2_no comp_prim_1524_no comp_lowsec_1524_no comp_upsec_2029_no eduyears_2024_no edu2_2024_no edu4_2024_no eduout_prim_no eduout_lowsec_no eduout_upsec_no


foreach part in part1 part2 {
use "$data_dhs\PR\Step3_`part'.dta", clear
*use "$data_dhs\PR\Step3_part2.dta", clear
set more off

*Dropping variables
drop hhid hvidx individual_id lowsec_age0 upsec_age0 prim_age1 lowsec_age1 upsec_age1 eduyears adjustment

*--The year is the median of the year of interview
drop year
bys country_year: egen year=median(hv007)

*Create variables for count of observations
foreach var of varlist $varlist_m  {
		gen `var'_no=`var'
}

keep country_year iso_code3 year $categories_collapse hhweight $varlist_m $varlist_no comp_prim_aux comp_lowsec_aux
compress
*save "$data_dhs\PR\Step4_part2.dta", replace
save "$data_dhs\PR\Step4_`part'.dta", replace
}

***************
*https://www.stata.com/meeting/baltimore17/slides/Baltimore17_Correia.pdf

cap mkdir "$data_dhs\PR\collapse"
cd "$data_dhs\PR\collapse"
*foreach part in part1 part2 {
foreach part in part2 {
use "$data_dhs\PR\Step4_`part'.dta", clear
set more off
tuples $categories_collapse, display
foreach i of numlist 0/6 12/18 20/21 31 41 {
	preserve
	collapse (mean) $varlist_m (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year `tuple`i'')
	*collapse (mean) $varlist_m comp_prim_aux comp_lowsec_aux (count) $varlist_no [weight=hhweight], by(country_year iso_code3 year `tuple`i'')
	gen category="`tuple`i''"	
	save "result`i'_`part'.dta", replace
	restore
}
}

*****************************************************************************************
*****************************************************************************************


* Appending the results
cd "$data_dhs\PR\collapse"
use "result0_part1.dta", clear
gen t_0=1
foreach i of numlist 0/6 12/18 20/21 31 41 {
 	append using "result`i'_part1"
	append using "result`i'_part2"
}
drop if t_0==1
drop t_0

gen survey="DHS"
replace category="total" if category==""
tab category

*-- Fixing for missing values in categories
foreach X in $categories_collapse {
drop if `X'=="" & category=="`X'"
}

for X in any sex wealth religion ethnicity region: drop if category=="location X" & (location==""|X=="")
for X in any wealth religion ethnicity region: drop if category=="sex X" & (sex==""|X=="")
for X in any region: drop if category=="wealth X" & (wealth==""|X=="")

drop if category=="location sex wealth" & (location==""|sex==""|wealth=="")
drop if category=="sex wealth region" & (sex==""|wealth==""|region=="")

replace category=proper(category)
split category, gen(c)
gen category_original=category
replace category=c1+" & "+c2 if c1!="" & c2!="" & c3==""
replace category=c1+" & "+c2+" & "+c3 if c1!="" & c2!="" & c3!=""
drop c1 c2 c3

tab category category_orig
drop category_orig
compress

order country survey year category* $categories_collapse $varlist_m $varlist_no

foreach var of varlist $vars_comp $vars_eduout {
		replace `var'=`var'*100
}

*Merge with year_uis
merge m:1 iso_code3 survey year using "$aux_data/GEM/country_survey_year_uis.dta", keepusing(year_uis)
drop if _merge==2
drop _merge
compress
 *drop edu2* edu4*
sort iso_code category $categories_collapse
save "$data_dhs\PR\dhs_collapse_by_categories_v9.dta", replace

export delimited "$data_dhs\PR\dhs_collapse_by_categories_v9.csv", replace

************* END *********************************************

use "$data_dhs\PR\dhs_collapse_by_categories_v8.dta", clear
drop *no
for X in any prim lowsec upsec: ren comp_X_v2 comp_X_new
merge 1:1 country year $categories_collapse using  "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\WIDE_DHS_MICS\data\dhs\PR\old\dhs_collapse_by_categories_v6.dta"
keep if category=="Total"
tab _merge
br if _merge==1 // Burundi 2017, India
for X in any prim lowsec upsec: gen diff_X=abs(comp_X_v2-comp_X_new)
br if diff_prim==.
br if diff_upsec>=5 & diff_upsec!=.
gen changed=1 if iso=="ALB"|iso=="ARM"|iso=="EGY"|iso=="MDG"|iso=="ZWE"
br country year comp_*_v2 comp_*_new diff* if changed==1




