*For Desktop-Work
global gral_dir "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE"
global data_raw_mics "$gral_dir\Data\MICS"

*For laptop
*global gral_dir "C:\Users\Rosa_V\Dropbox"
*global data_raw_mics "$gral_dir\WIDE\Data\MICS"

global programs_mics "$gral_dir\WIDE\WIDE_DHS_MICS\programs\mics"
global aux_programs "$programs_mics\auxiliary"
global aux_data "$gral_dir\WIDE\WIDE_DHS_MICS\data\auxiliary_data"
global data_mics "$gral_dir\WIDE\WIDE_DHS_MICS\data\mics"

*Vars to keep
global vars_mics4 hh1 hh2 hh5* hl1 hl3 hl4 hl5* hl6 hl7 hh6* hh7* ed1 ed3* ed4* ed5* ed6* ed7* ed8* windex5 schage hhweight religion ethnicity region windex5
global list4 hh6 hh7 ed3 ed4a ed4b ed5 ed6b ed6a ed7 ed8a religion ethnicity hh7r ed3x ed4 ed4ax region 
global vars_keep_mics "hhid hvidx hv000 hv005 hv006 hv007 hv008 hv016 hv009 hv024 hv025 hv270 hv102 hv104 hv105 hv106 hv107 hv108 hv109 hv121 hv122 hv123 hv124"
global categories sex urban region wealth
*global extra_keep ...// for the variables that I want to add later ex. cluster

*****************************************************************************************************
*	Preparing databases to append later (MICS 4 & 5)
*----------------------------------------------------------------------------------------------------

***** CODEBOOK FOR MICS THAT WILL SERVE AS GUIDE FOR FIXING THE LEVELS AND YEARS OF EDUCATION
set more off
cap log close
log using "$data_mics\hl\CHECKS\logs\RAW_data_codes_vars_mics.log", replace
display "**** CODEBOOKS FOR VARIABLES ED4A and ED4B ***"
log close
include "$aux_programs\survey_list_mics_hl"
foreach file in $survey_list_mics_hl {
use "$data_raw_mics/`file'", clear
log using "$data_mics\hl\CHECKS\logs\RAW_data_codes_vars_mics.log", append
display "*********************************************"
display "*-----  `file'"
display "*********************************************"
codebook ED4*, tab(200)
log close
}


set more off
cap log close
log using "$data_mics\hl\CHECKS\logs\RAW_data_ED4 & ED8.log", replace
display "**** CODEBOOKS FOR VARIABLES ED4 and ED8 ***"
log close
include "$aux_programs\survey_list_mics_hl"
foreach file in $survey_list_mics_hl {
use "$data_raw_mics/`file'", clear
log using "$data_mics\hl\CHECKS\logs\RAW_data_ED4 & ED8.log", append
display "*********************************************"
display "*-----  `file'"
display "*********************************************"
for X in any ED4A ED8A: cap gen X=.
codebook ED4* ED8*, tab(200)
log close
}

set more off
cap log close
log using "$data_mics\hl\CHECKS\logs\religion.log", replace
display "**** CODEBOOKS FOR VARIABLES ED4 and ED8 ***"
log close
include "$aux_programs\survey_list_mics_hl"
foreach file in $survey_list_mics_hl {
use "$data_raw_mics/`file'", clear
log using "$data_mics\hl\CHECKS\logs\religion.log", append
display "*********************************************"
display "*-----  `file'"
display "*********************************************"
lookfor rel eth etn
log close
}

