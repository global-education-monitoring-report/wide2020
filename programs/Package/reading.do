clear
global data_path "path"
global aux_data_path "path"

* get a list of files with the extension .dta in directory 

cd $data_path
local allfiles : dir . files "*.dta"

mkdir "$data_path/temporal"

* read all files 

foreach file of local allfiles {
  *read a file
  use "`file'", clear
  
  *lowercase all variables
  cap rename *, lower
  
  *generate variables with file name
  tokenize "`file'", parse("_")
	generate country = "`1'" 
	generate year_folder = `3'
  
  compress 
  save "$data_path/temporal/`1'_`3'_hl", replace
}

* some R code using Rcall module (I keep trying to do it in stata but there doesn't seem to be an easy way as in R)
* select variables using dictionary 

rsource, terminator(END_OF_R) rpath("/C:/Program Files/R/R-3.6.3/bin/i386/R.exe") roptions(`"--vanilla"')

library(haven);     # import and export Stata datasets
library(dplyr);     # manipulate dataframe
library(sjlabelled) # manage variable labelled

tempfile_path <- "/raw_data/temporal"

library(haven); 

# read mics variables and labels
dictionary <- readr::read_csv("auxiliary_data/cleaning/mics_variables_nameslabels.csv");

file.list <- list.files(path = tempfile_path, pattern = '*.dta');
file.list <- setNames(file.list, file.list);

# store all .dta files as individual data frames inside of one list

for(j in 1:length(file.list)){
  
  df <- haven::read_dta(paste0("raw_data/temporal/", file.list[j]));
  varlabel <- get_label(df) %>% as.data.frame();
  varlabel$label <- varlabel[,1];
  varlabel$variable <- rownames(varlabel);
  
  # common variable and label
  vars <- inner_join(varlabel, dictionary, by = c("variable" = "name", "label" = "varlab"));
  
  # select variables and save
  df <- df %>%
    select(vars$variable)
  haven::write_dta(data = df, path = paste0("raw_data/temporal/", names(file.list)[j]));
  
}

END_OF_R


cd $data_path\temporal
local allfiles : dir . files "*.dta"

*append all
set more off
foreach f of local allfiles {
	quitely append using `f'
}

*Remove temporal folder and files
rmdir "$data_path/temporal"

*save all dataset in a single one
compress
save "$data_path/all/hl_mics_reading.dta", replace


end

