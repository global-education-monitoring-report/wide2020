* Functional difficulty in the individual domains are calculated as follows:

*  - Seeing (UCF7A/B=3 or 4) 
*  - Hearing (UCF9A/B=3 or 4) 
*  - Walking (UCF11=3 or 4 OR UCF12=3 or 4 OR UCF13=3 or 4)
*  - Fine motor (UCF14=3 or 4)
*  - Communication a) Understanding (UCF15=3 or 4) or b) Being understood (UCF16=3 or 4)
*  - Learning (UCF17=3 or 4)
*  - Playing (UCF18=3 or 4)
*  - Controlling behaviour (UCF19=5)

* The percentage of children age 2-4 years with functional difficulty in at least one domain is presented in the last column.

global list1 seeing hearing walking finemotor comm learning playing behavior

******************************************************************************************************
******************************************************************************************************
foreach country in Iraq KyrgyzRepublic LaoPDR SierraLeone Suriname TheGambia {
 use "C:\Users\Rosa_V\Desktop\WIDE\Data\MICS\\`country'\ch.dta", clear
 include "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\standardizes_ch"
 gen country="`country'"
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch\\`country'.dta", replace
}

 ****************************************************************************************
 ****************************************************************************************
 
cd "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch\" 
 use Iraq.dta, clear
 append using KyrgyzRepublic.dta
 append using LaoPDR.dta
 append using SierraLeone.dta
 append using Suriname.dta
 append using TheGambia.dta
 append using Tunisia.dta
 
 bys country: tab dis2 cdisability if cage>=24 & cage<=59 , m
 egen year=median(uf7y)
 recode cdisability (2=0)
 gen age=0 if cage>=0 & cage<12
 replace age=1 if cage>=12 & cage<24
 replace age=2 if cage>=24 & cage<36
 replace age=3 if cage>=36 & cage<48
 replace age=4 if cage>=48 & cage<60
 
 gen hhweight=chweight
 save "C:\Users\Rosa_V\Desktop\WIDE\WIDE\WIDE_DHS_MICS\MICS6\data_created\ch_module.dta", replace
tab cage age, m

collapse (mean) cdisability [iw=chweight], by(country year age) 
collapse (mean) cdisability [iw=chweight], by(country year cage) 
 


 collapse (mean) $list1 dis2 cdisability if cage>=24 & cage<=59 [iw=chweight], by(country year) 
 