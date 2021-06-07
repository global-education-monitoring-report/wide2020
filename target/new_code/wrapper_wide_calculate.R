path2standardised <- "C:/Users/taiku/UNESCO/GEM Report - 2_standardised/" # enter path
#path2standardised <- "C:/Users/taiku/Desktop/temporary_std" # testing


folder_names <- list.dirs(path2standardised) #to set the directory
folder_names

for (i in 2:length(folder_names)) {
  #survey <- substring( folder_names[[i]], 38, 45)
  survey <- substring( folder_names[[i]], 52, 59)
    setwd(folder_names[[i]])
  data <- read_dta(paste0("std_",survey,".dta")) # change this path
  source("C:/Users/taiku/Documents/GEM UNESCO MBR/GitHub/wide2020/target/new_code/wide_calculate.R")
  }


