###USING WIDE_CALCULATE.R###

#path2standardised <- "C:/Users/taiku/UNESCO/GEM Report - 2_standardised/" # enter path
path2standardised <- "C:/Users/taiku/Desktop/temporary_std" # testing


folder_names <- list.dirs(path2standardised) #to set the directory
folder_names

library(haven)


for (i in 2:length(folder_names)) {
  survey <- substring( folder_names[[i]], 38, 50)
  #survey <- substring( folder_names[[i]], 52, 65)
    setwd(folder_names[[i]])
  data <- read_dta(paste0("std_",survey,".dta")) # change this path
  source("C:/Users/taiku/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_pipeline/wide_calculate.R")
  }

