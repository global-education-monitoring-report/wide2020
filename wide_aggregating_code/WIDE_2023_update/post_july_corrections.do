*******************************************
***WIDE (AFTER JULY UPDATE) CORRECTIONS****


*load it
import delimited "C:\Users\mm_barrios-rivera\OneDrive - UNESCO\WIDE files\WIDE_2023_july.csv", clear

**overage out

// MICS Barbados 2012 (70% overage)
// Impossible to compare with anything but certainly wrong. You could just delete this indicator for Barbados (instead of trying to fix it). 

replace overage2plus_m=. if iso=="BRB" & survey=="MICS" & year==2012
replace overage2plus_no=. if iso=="BRB" & survey=="MICS" & year==2012

// MICS Belize 2011 (70% overage)
// Here you have a comparison (2006) which proves that it is wrong and should be deleted (or, in this case, fixed). 
// https://www.education-inequalities.org/indicators/overage2plus/belize#years=%5B%222011%22%2C%222006%22%5D&ageGroups=%5B%22overage2plus%22%5D 
// (one question is why you have not estimated this indicator for 2016?)

replace overage2plus_m=. if iso=="BLZ" & survey=="MICS" & year==2011
replace overage2plus_no=. if iso=="BLZ" & survey=="MICS" & year==2011


// DHS Indonesia 2017 (40% overage)
// Here you also have a comparison (2012) which proves that it is wrong and should be deleted (or, in this case, fixed).
// https://www.education-inequalities.org/indicators/overage2plus/indonesia#years=%5B%222017%22%2C%222012%22%5D&ageGroups=%5B%22overage2plus%22%5D 

replace overage2plus_m=. if iso=="IDN" & survey=="DHS" & year==2017
replace overage2plus_no=. if iso=="IDN" & survey=="DHS" & year==2017


// CFPS China 2016 (30% overage)
// China CFPS should not be used for overage. So that should be deleted.

replace overage2plus_m=. if iso=="CHN" & survey=="CFPS" 
replace overage2plus_no=. if iso=="CHN" & survey=="CFPS" 


*Now that I opened the overage indicaotr page, I spotted that for the few countries where you have ethnicities (all prior to 2015), their overage rates are 100%. *As it is a distracting error, just delete ethnicity for this indicator. 
*https://www.education-inequalities.org/indicators/overage2plus#maxYear=2021&minYear=2011&ageGroup=%22overage2plus%22 

replace overage2plus_m=. if category=="Ethnicity" & iso=="BEN" & survey=="DHS" & year==2006
replace overage2plus_no=. if category=="Ethnicity" & iso=="BEN" & survey=="DHS" & year==2006

replace overage2plus_m=. if category=="Ethnicity" & iso=="BFA" & survey=="DHS" & year==2010
replace overage2plus_no=. if category=="Ethnicity" & iso=="BFA" & survey=="DHS" & year==2010

replace overage2plus_m=. if category=="Ethnicity" & iso=="COD" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Ethnicity" & iso=="COD" & survey=="DHS" & year==2013

replace overage2plus_m=. if category=="Ethnicity" & iso=="COL" & survey=="DHS" & year==2015
replace overage2plus_no=. if category=="Ethnicity" & iso=="COL" & survey=="DHS" & year==2015

replace overage2plus_m=. if category=="Ethnicity" & iso=="GAB" & survey=="DHS" & year==2012
replace overage2plus_no=. if category=="Ethnicity" & iso=="GAB" & survey=="DHS" & year==2012

replace overage2plus_m=. if category=="Ethnicity" & iso=="GHA" & survey=="DHS" & year==2014
replace overage2plus_no=. if category=="Ethnicity" & iso=="GHA" & survey=="DHS" & year==2014

replace overage2plus_m=. if category=="Ethnicity" & iso=="GIN" & survey=="DHS" & year==2012
replace overage2plus_no=. if category=="Ethnicity" & iso=="GIN" & survey=="DHS" & year==2012

replace overage2plus_m=. if category=="Ethnicity" & iso=="GMB" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Ethnicity" & iso=="GMB" & survey=="DHS" & year==2013

replace overage2plus_m=. if category=="Ethnicity" & iso=="GTM" & survey=="DHS" & year==2015
replace overage2plus_no=. if category=="Ethnicity" & iso=="GTM" & survey=="DHS" & year==2015

replace overage2plus_m=. if category=="Ethnicity" & iso=="MLI" & survey=="DHS" & year==2006
replace overage2plus_no=. if category=="Ethnicity" & iso=="MLI" & survey=="DHS" & year==2006

replace overage2plus_m=. if category=="Ethnicity" & iso=="MOZ" & survey=="DHS" & year==2011
replace overage2plus_no=. if category=="Ethnicity" & iso=="MOZ" & survey=="DHS" & year==2011

replace overage2plus_m=. if category=="Ethnicity" & iso=="MWI" & survey=="DHS" & year==2010
replace overage2plus_no=. if category=="Ethnicity" & iso=="MWI" & survey=="DHS" & year==2010

replace overage2plus_m=. if category=="Ethnicity" & iso=="NGA" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Ethnicity" & iso=="NGA" & survey=="DHS" & year==2013

replace overage2plus_m=. if category=="Ethnicity" & iso=="TCD" & survey=="DHS" & year==2004
replace overage2plus_no=. if category=="Ethnicity" & iso=="TCD" & survey=="DHS" & year==2004

replace overage2plus_m=. if category=="Ethnicity" & iso=="TGO" & survey=="DHS" & year==2014
replace overage2plus_no=. if category=="Ethnicity" & iso=="TGO" & survey=="DHS" & year==2014

replace overage2plus_m=. if category=="Ethnicity" & iso=="UGA" & survey=="DHS" & year==2011
replace overage2plus_no=. if category=="Ethnicity" & iso=="UGA" & survey=="DHS" & year==2011

replace overage2plus_m=. if category=="Ethnicity" & iso=="ZMB" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Ethnicity" & iso=="ZMB" & survey=="DHS" & year==2013

*extra


replace overage2plus_m=. if category=="Religion" & iso=="BEN" & survey=="DHS" & year==2006
replace overage2plus_no=. if category=="Religion" & iso=="BEN" & survey=="DHS" & year==2006

replace overage2plus_m=. if category=="Religion" & iso=="BFA" & survey=="DHS" & year==2010
replace overage2plus_no=. if category=="Religion" & iso=="BFA" & survey=="DHS" & year==2010

replace overage2plus_m=. if category=="Religion" & iso=="COD" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Religion" & iso=="COD" & survey=="DHS" & year==2013

replace overage2plus_m=. if category=="Religion" & iso=="COL" & survey=="DHS" & year==2015
replace overage2plus_no=. if category=="Religion" & iso=="COL" & survey=="DHS" & year==2015

replace overage2plus_m=. if category=="Religion" & iso=="GAB" & survey=="DHS" & year==2012
replace overage2plus_no=. if category=="Religion" & iso=="GAB" & survey=="DHS" & year==2012

replace overage2plus_m=. if category=="Religion" & iso=="GHA" & survey=="DHS" & year==2014
replace overage2plus_no=. if category=="Religion" & iso=="GHA" & survey=="DHS" & year==2014

replace overage2plus_m=. if category=="Religion" & iso=="GIN" & survey=="DHS" & year==2012
replace overage2plus_no=. if category=="Religion" & iso=="GIN" & survey=="DHS" & year==2012

replace overage2plus_m=. if category=="Religion" & iso=="GMB" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Religion" & iso=="GMB" & survey=="DHS" & year==2013

replace overage2plus_m=. if category=="Religion" & iso=="GTM" & survey=="DHS" & year==2015
replace overage2plus_no=. if category=="Religion" & iso=="GTM" & survey=="DHS" & year==2015

replace overage2plus_m=. if category=="Religion" & iso=="MLI" & survey=="DHS" & year==2006
replace overage2plus_no=. if category=="Religion" & iso=="MLI" & survey=="DHS" & year==2006

replace overage2plus_m=. if category=="Religion" & iso=="MOZ" & survey=="DHS" & year==2011
replace overage2plus_no=. if category=="Religion" & iso=="MOZ" & survey=="DHS" & year==2011

replace overage2plus_m=. if category=="Religion" & iso=="MWI" & survey=="DHS" & year==2010
replace overage2plus_no=. if category=="Religion" & iso=="MWI" & survey=="DHS" & year==2010

replace overage2plus_m=. if category=="Religion" & iso=="NGA" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Religion" & iso=="NGA" & survey=="DHS" & year==2013

replace overage2plus_m=. if category=="Religion" & iso=="TCD" & survey=="DHS" & year==2004
replace overage2plus_no=. if category=="Religion" & iso=="TCD" & survey=="DHS" & year==2004

replace overage2plus_m=. if category=="Religion" & iso=="TGO" & survey=="DHS" & year==2014
replace overage2plus_no=. if category=="Religion" & iso=="TGO" & survey=="DHS" & year==2014

replace overage2plus_m=. if category=="Religion" & iso=="UGA" & survey=="DHS" & year==2011
replace overage2plus_no=. if category=="Religion" & iso=="UGA" & survey=="DHS" & year==2011

replace overage2plus_m=. if category=="Religion" & iso=="ZMB" & survey=="DHS" & year==2013
replace overage2plus_no=. if category=="Religion" & iso=="ZMB" & survey=="DHS" & year==2013


***SAVE A NEW WIDE as .DTA then go to append.R code to save as csv from there to get the 1...N column

drop v1

save "C:\Users\mm_barrios-rivera\Documents\GEM UNESCO MBR\GitHub\wide2020\wide_aggregating_code\WIDE_2023_update\WIDE_2023_files\WIDE_2023_sept.dta", replace

