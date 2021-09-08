########### USING wide_summarize_ALT.R

library(dplyr)
library(stringr)
library(tidyr)
library(qs)

memory.limit(size = 2500)

#path2calculated <- "C:/Users/taiku/UNESCO/GEM Report - 3_calculated" # enter path
path2calculated <- "C:/Users/taiku/Desktop/temporary_std" # just 3 first files to test 

file_names <- list.files(path2calculated) #to set the directory
file_names


for (i in 1:length(file_names)) {
  setwd(path2calculated)
  wide_calculate <- qread(file_names[[i]]) 
  #Outcome vars
  if("literacy_1524" %in% colnames(wide_calculate))
  {
    wide_outcome_vars <- names(select(wide_calculate, literacy_1524, overage2plus, attend_higher, comp_prim_v2:edu4_2024))
  } else {
    wide_outcome_vars <- names(select(wide_calculate, overage2plus, attend_higher, comp_prim_v2:edu4_2024))
  }
  #variable "country"
  if(!"country" %in% colnames(wide_calculate))
  {
  wide_calculate <- wide_calculate %>% mutate(country =  str_split(country_year, "_")[[1]][1]) 
  }
  #Generate the categories checking the dataset
  emptycheck <- all.equal("",unique(wide_calculate$location))
  if(emptycheck==TRUE){
    categoriesinsvy <- c('sex', 'wealth')
  } else {
    emptycheck <- all.equal("",unique(wide_calculate$region))
    if(emptycheck==TRUE){
      categoriesinsvy <-c('sex', 'wealth', 'location')
    } else {
      emptycheck <- all.equal("",unique(wide_calculate$religion))
      if(emptycheck==TRUE){
        categoriesinsvy <-c('sex', 'wealth', 'location', 'region')
      } else {
        categoriesinsvy <- c('sex', 'wealth', 'location', 'region', 'religion')
      }
    }
  }
  #Generate a long version of wide_calculate qs file
  wide_long <-  pivot_longer(wide_calculate, names_to = 'indicator', cols = any_of(wide_outcome_vars))
  # Run aggregation 
  summarized_wide <- wide_aggregate(wide_long, categoriesinsvy, depth = 3)
  summarized_wider <-  pivot_wider(summarized_wide, names_from = 'indicator',  values_from = c(value,count))
  #Fixing indicator names
  summarized_wider <- summarized_wider %>% rename_all(~stringr::str_replace(.,"^value_",""))  %>%
    rename_with(~paste0(., "_m"), any_of(wide_outcome_vars)) %>% 
    rename_with(~paste0(., "_no"), any_of(paste0('count_',wide_outcome_vars)))  %>%  
    rename_all(~stringr::str_replace(.,"^count_",""))
  #Fixing category names
  summarized_wider <- summarized_wider %>% mutate(category= str_to_title(category))
  # Export data as .csv format by country
  survey <- substring( file_names[[i]], 1, 13)
  setwd("C:/Users/taiku/Desktop/temporary_sum")
  write.csv(summarized_wider, paste0(survey,"_summarized.csv"))
}

#Do I want to collect all csv files? Why not 

#OPTIONAL: merge all indicators into a single csv file
library(plyr)

#setwd("C:/Users/taiku/UNESCO/GEM Report - 3_calculated")
setwd("C:/Users/taiku/Desktop/temporary_sum")
all_indicators <- ldply(list.files(), read.csv, header=TRUE)
write.csv(all_indicators, paste0("widetable","_summarized_08092021.csv"))
