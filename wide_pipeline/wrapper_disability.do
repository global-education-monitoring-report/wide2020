***********recoding FS


clear 
 use "C:\ado\personal\repository_inventory.dta"
 drop if iso=="FJI"
 drop if iso=="LAO" //doesnt have disability in FS 
  drop if iso=="THA" //doesnt have disability in FS 
    drop if iso=="NPL" //problem with ed level NEED RECODE 


  keep if roundmics==6
 *keep if iso=="BLR"
 levelsof fullname, local(mics6surveys)
 
 display `mics6surveys'
 *whatever name of the local put the local name in the next loop 

local dpath "C:\Users\taiku\UNESCO\GEM Report - 1_raw_data"
local opath "C:\Users\taiku\Desktop\temporary_std"
*set trace on
foreach survey of local mics6surveys {
		tokenize "`survey'", parse(_)
		disability_MICS_FS,  data_path(`dpath') output_path(`opath') country_code("`1'") country_year("`3'") 
		cd "C:\Users\taiku\Desktop\temporary_disability\indicators"
		save "FS_disability_`1'_`3'_MICS.dta"	, replace 
}

local files : dir "C:\Users\taiku\Desktop\temporary_disability\indicators" files "*.dta"
    foreach file in `files' {
        append using `file'
    }
	
	
save "C:\Users\taiku\Desktop\temporary_disability\disability_MICS_FS_full.dta"