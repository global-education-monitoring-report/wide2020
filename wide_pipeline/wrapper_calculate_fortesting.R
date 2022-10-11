########### USING wide_summarize_ALT.R ############

####TEST.SPACE

#Don't forget to run wide_summarize_ALT.R to get the programs !!!!!!
#FYI: for some reason, start a new Rstudio session before running this


library(dplyr)
library(stringr)
library(tidyr)
library(qs)
library(tidyverse)

#Set this if dealing with BGD 2019 MICS
#memory.limit(size = 45500) 

#path2calculated <- "C:/Users/taiku/UNESCO/GEM Report - 3_calculated" # enter path
path2calculated <- "C:/Users/taiku/Desktop/temporary_std" # just 3 first files to test 

file_names <- list.files(path2calculated) #to set the directory
file_names

setwd(path2calculated)



#Don't forget to run wide_summarize_ALT.R to get the programs 

for (i in 1:length(file_names)) {
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
  
#  Part 1 : hh_edu options  -----------------------------------------------------------------
  
  #Generate the categories checking the dataset
    categoriesinsvy <- c('hh_edu_adult', 'hh_edu_head')
  
  #Generate a long version of wide_calculate qs file
  wide_long <-  pivot_longer(wide_calculate, names_to = 'indicator', cols = any_of(wide_outcome_vars))
  print("pivoted") 
  
  # Run aggregation 
  summarized_wide <- wide_aggregate(wide_long, categoriesinsvy, depth = 1)
  print("summarized")
  summarized_wider <-  pivot_wider(summarized_wide, names_from = 'indicator',  values_from = c(value,count))
  print("re-pivoted")
  
  
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

write.csv(all_indicators, paste0("widetable","_summarized_hh-edu-options.csv"))

##CONCLUSION PARTE 1: HH_EDU CON HEAD FUNCIONA MEJOR QUE CON ADULT 


#  Part 2 : disability by parts   -----------------------------------------------------------------

#Disability by parts: 
# PARTS: (1) FSDISABILITY, (2) DISABILITY, (3) CDISABILITY 

#Generate the categories checking the dataset, this goes for all parts
categoriesinsvy <- c('disability','sex')


for (i in 1:length(file_names)) {
  setwd(path2calculated)
  print(file_names[[i]]) 
  wide_calculate <- qread(file_names[[i]]) 
  #LITERACY_1524 would ideally be calculated with adult disability, so it's not included here 
  
# (1) FSDISABILITY 5-17 y-o relevant indicators
  
  #Outcome vars: issue of where comp_lowsec_v2 goes 
  if(mean(wide_calculate$lowsec_age1)<= 13){
      print("comp lowsec calculated with FS QUESTIONNAIRE,here")
      wide_outcome_vars <- names(select(wide_calculate, comp_prim_v2, comp_lowsec_v2, eduout_prim, eduout_lowsec, eduout_upsec, edu0_prim, overage2plus))
    } else {
      print("comp lowsec calculated with ADULT QUESTIONNAIRE,in part 2" )}
      wide_outcome_vars <- names(select(wide_calculate, comp_prim_v2, eduout_prim, eduout_lowsec, eduout_upsec, edu0_prim, overage2plus))
  
      summarized_fs <- summ_bypieces(wide_calculate, wide_outcome_vars, depth = 2)
 
  # (2) DISABILITY ADULTS 17+ y-o relevant indicators
  
  #Outcome vars: issue of where comp_lowsec_v2 goes 
  if(mean(wide_calculate$lowsec_age1)<= 13){
    print("comp lowsec calculated with FS QUESTIONNAIRE, in part 1")
    wide_outcome_vars <- names(select(wide_calculate, comp_upsec_v2, comp_prim_1524, comp_lowsec_1524, comp_upsec_2029, 
                                      eduyears_2024, edu4_2024, comp_higher_2yrs_2529, comp_higher_4yrs_2529, 
                                      comp_higher_4yrs_3034, attend_higher_1822, literacy_1524))
  } else {
    print("comp lowsec calculated with ADULT QUESTIONNAIRE, here" )}
  wide_outcome_vars <- names(select(wide_calculate, comp_lowsec_v2, comp_upsec_v2, comp_prim_1524, comp_lowsec_1524, comp_upsec_2029, 
                                    eduyears_2024, edu4_2024, comp_higher_2yrs_2529, comp_higher_4yrs_2529, 
                                    comp_higher_4yrs_3034, attend_higher_1822, literacy_1524)) 
  
      summarized_adults <- summ_bypieces(wide_calculate, wide_outcome_vars, depth = 2)
  
# (3) CDISABILITY <5 y-o relevant indicators
      
      wide_outcome_vars <- names(select(wide_calculate, preschool_3))
      
      summarized_ch <- summ_bypieces(wide_calculate, wide_outcome_vars, depth = 2)
      
      summarized_disability <- full_join(summarized_fs,summarized_adults,summarized_ch,  by = c('country', 'survey', 'year','category','disability', 'sex'))
      
}

#variable "country"
if(!"country" %in% colnames("RESULT"))
{
  wide_calculate <- wide_calculate %>% mutate(country =  str_split(country_year, "_")[[1]][1]) 
}
}


# Export data as .csv format by country
survey <- substring( file_names[[i]], 1, 13)
setwd("C:/Users/taiku/Desktop/temporary_sum")
write.csv(summarized_wider, paste0(survey,"_summarized.csv"))



#OPTIONAL: merge all indicators into a single csv file
library(plyr)

#setwd("C:/Users/taiku/UNESCO/GEM Report - 3_calculated")
setwd("C:/Users/taiku/Desktop/temporary_sum")
all_indicators <- ldply(list.files(), read.csv, header=TRUE)

write.csv(all_indicators, paste0("widetable","_summarized_disability_fromraw.csv"))



