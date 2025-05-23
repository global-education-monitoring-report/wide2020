########### USING wide_summarize_ALT.R ###########
#Don't forget to run wide_summarize_ALT.R to get the programs !!!!!!
#FYI: for some reason, start a new Rstudio session before running this


library(dplyr)
library(stringr)
library(tidyr)
library(qs)

#Set this if dealing with BGD 2019 MICS
memory.limit(size = 45500) 

#put .qs files in the path

#path2calculated <- "C:/Users/taiku/UNESCO/GEM Report - 3_calculated" # enter path
path2calculated <- "C:/Users/mm_barrios-rivera/Desktop/temporary_std" # just 3 first files to test 

file_names <- list.files(path2calculated) #to set the directory
file_names


#Don't forget to run wide_summarize_ALT.R to get the programs 

for (i in 1:length(file_names)) {
  setwd(path2calculated)
  print(file_names[[i]]) 
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
  emptycheck <- isTRUE(all.equal("",unique(wide_calculate$location)))
  if(emptycheck==TRUE){
    categoriesinsvy <- c('sex', 'wealth')
  } else {
    emptycheck <- isTRUE(all.equal("",unique(wide_calculate$region)))
    if(emptycheck==TRUE){
      categoriesinsvy <-c('sex', 'wealth', 'location')
    } else {
      emptycheck <- isTRUE(all.equal("",unique(wide_calculate$religion)))
      if(emptycheck==TRUE){
        categoriesinsvy <-c('sex', 'wealth', 'location', 'region')
      } else {
        categoriesinsvy <- c('sex', 'wealth', 'location', 'region', 'religion')
      }
    }
  }
  #Generate a long version of wide_calculate qs file
  wide_long <-  pivot_longer(wide_calculate, names_to = 'indicator', cols = any_of(wide_outcome_vars))
  print("pivoted") 
  
  # Run aggregation 
  summarized_wide <- wide_aggregate(wide_long, categoriesinsvy, depth = 3)
  print("summarized")
  summarized_wider <-  pivot_wider(summarized_wide, names_from = 'indicator',  values_from = c(value,count))
  print("re-pivoted")
  #Fixing indicator names
  summarized_wider <- summarized_wider %>% rename_all(~stringr::str_replace(.,"^value_",""))  %>%
    rename_with(~paste0(., "_m"), any_of(wide_outcome_vars)) %>% 
    rename_with(~paste0(., "_no"), any_of(paste0('count_',wide_outcome_vars)))  %>%  
    rename_all(~stringr::str_replace(.,"^count_",""))
  #Fixing category names
  summarized_wider <- summarized_wider %>% mutate(category= str_to_title(category)) %>%
    mutate(iso_code3 = countrycode::countrycode(country, 'country.name.en', 'iso3c')) 
  # Export data as .csv format by country
  survey <- substring( file_names[[i]], 1, 13)
  setwd("C:/Users/mm_barrios-rivera/Desktop/temporary_sum")
  write.csv(summarized_wider, paste0(survey,"_summarized.csv"))
}

#Do I want to collect all csv files? Why not 

#OPTIONAL: merge all indicators into a single csv file
library(plyr)

#setwd("C:/Users/taiku/UNESCO/GEM Report - 3_calculated")
setwd("C:/Users/mm_barrios-rivera/Desktop/temporary_sum")
all_indicators <- ldply(list.files(), read.csv, header=TRUE)
#write.csv(all_indicators, paste0("widetable","_summarized_10092021.csv"))
#write.csv(all_indicators, paste0("widetable","_summarized_22092021.csv"))
#write.csv(all_indicators, paste0("widetable","_summarized_27092021.csv"))
#write.csv(all_indicators, paste0("widetable","_summarized_07012022.csv"))
#write.csv(all_indicators, paste0("widetable","_summarized_mics6_withcorr.csv"))
#write.csv(all_indicators, paste0("widetable","_summarized_Rwanda.csv"))
#write.csv(all_indicators, paste0("widetable","_summarized_newSenegal.csv"))

#write.csv(all_indicators, paste0("widetable","_summarized_latestAfrica.csv"))


#write.csv(all_indicators, paste0("widetable","_summarized_2022update.csv"), na = '')
#write.csv(all_indicators, paste0("widetable","_summarized_2023update.csv"), na = '')
#write.csv(all_indicators, paste0("widetable","_summarized_Nepalrecalculation.csv"), na = '')
write.csv(all_indicators, paste0("widetable","_summarized_dec23.csv"), na = '')

