
program define mics_recoding

import delimited "$aux_data_path/mics_codset_dictionary.csv", varnames(1) clear
labeldatasyntax, saving("$data_path/programs/Package/mics_recode.do")
*do mics_recode.do

end
