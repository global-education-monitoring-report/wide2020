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
  
#  Part 1 : hh_edu tables for WIDE  -----------------------------------------------------------------
  
  #Generate the categories checking the dataset
  
  if("hh_edu_mother" %in% colnames(wide_calculate))
  {
    categoriesinsvy <- c('hh_edu_adult', 'hh_edu_head', 'hh_edu_mother')
    
  } else {
    categoriesinsvy <- c('hh_edu_adult', 'hh_edu_head')
    
  }
  
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
  summarized_wider <- summarized_wider %>% mutate(category= str_to_title(category)) %>%
    mutate(iso_code3 = countrycode::countrycode(country, 'country.name.en', 'iso3c')) 
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

#Some cleanup

all_indicators_p1 <-all_indicators %>%  filter(!(hh_edu_adult == ''  )) 
all_indicators_p2 <-all_indicators %>%  filter(!(hh_edu_head == '' ))
all_indicators_p3 <-all_indicators %>%  filter(!(hh_edu_mother == '' ))
all_indicators_p4 <-all_indicators %>%  filter(category == 'Total' )

all_indicators_clean <-bind_rows(all_indicators_p1,all_indicators_p2,all_indicators_p3,all_indicators_p4)

write.csv(all_indicators_clean, paste0("widetable","_summarized_hh-edu-Bilal.csv"), na = '')
write.csv(all_indicators_p2, paste0("widetable","_summarized_hh-edu-WIDE.csv"), na = '')


##CONCLUSION PARTE 1: HH_EDU CON HEAD FUNCIONA MEJOR QUE CON ADULT 


#  Part 2 : disability by parts   -----------------------------------------------------------------

path2calculated <- "C:/Users/taiku/Desktop/temporary_std" # just 3 first files to test 

file_names <- list.files(path2calculated) #to set the directory
file_names

setwd(path2calculated)


#Disability by parts: 
# PARTS: (1) CH module, (2) WM and MN modules (adults)
# Disability variables: (1) cdisability, disability_trad_ch ; (2) disability, disability_trad_adults 

#Generate the categories checking the dataset, this goes for all parts


for (i in 1:length(file_names)) {
  setwd(path2calculated)
  print(file_names[[i]]) 
  wide_calculate <- qread(file_names[[i]]) 

  #variable "country"
  if(!"country" %in% colnames(wide_calculate))
  {
    print("country name missing")
    wide_calculate <- wide_calculate %>% mutate(country =  str_split(country_year, "_")[[1]][1]) 
  }
  
  #adult disability based on wdisability and mdisability 
  if(!"disability" %in% colnames(wide_calculate))
  {
    if(!"mdisability" %in% colnames(wide_calculate))
    {
      if(!"wdisability" %in% colnames(wide_calculate))
      {
        print("no adult disability available in this survey")
      } else {
        print("no men disability, using adult women only ")
        wide_calculate <- wide_calculate %>% mutate(disability=paste(wdisability))
            }
        }
  } else {
    print("disability variable exists")
          }
  
  # what <- wide_calculate %>% select(contains("disa"))
  # names(what)
  
# # THIS SECTION HAS BEEN STATA-TIZED BECAUSE WEIGHTS 
#  (1) FSDISABILITY 5-17 y-o relevant indicators
#   
#   #Outcome vars: issue of where comp_lowsec_v2 goes 
#   if(mean(wide_calculate$lowsec_age1)<= 13){
#       print("comp lowsec calculated with FS QUESTIONNAIRE,here")
#       wide_outcome_vars <- names(select(wide_calculate, comp_prim_v2, comp_lowsec_v2, eduout_prim, eduout_lowsec, eduout_upsec, edu0_prim, overage2plus))
#     } else {
#       print("comp lowsec calculated with ADULT QUESTIONNAIRE,in part 2" )}
#       wide_outcome_vars <- names(select(wide_calculate, comp_prim_v2, eduout_prim, eduout_lowsec, eduout_upsec, edu0_prim, overage2plus))
#   
#       categoriesinsvy <- c('FSDISABILITY','sex')
#       
#       summarized_fs <- summ_bypieces(wide_calculate, wide_outcome_vars, depth = 2, categoriesinsvy)
 
  # (2) DISABILITY ADULTS 17+ y-o relevant indicators
  # Disability variables: (1) cdisability, disability_trad_ch ; (2) disability, disability_trad_adults 
  
  
  #Outcome vars: issue of where comp_lowsec_v2 goes 
  #Run conditional on variable availability 
if( exists("disability", wide_calculate) ) {
  if(mean(wide_calculate$lowsec_age1)<= 13){
    print("comp lowsec calculated with FS QUESTIONNAIRE, in part 1")
    wide_outcome_vars <- names(select(wide_calculate, comp_upsec_v2, comp_prim_1524, comp_lowsec_1524, comp_upsec_2029, 
                                      eduyears_2024, edu4_2024, comp_higher_2yrs_2529, comp_higher_4yrs_2529, 
                                      comp_higher_4yrs_3034, attend_higher_1822, literacy_1524))
  } else {
    print("comp lowsec calculated with ADULT QUESTIONNAIRE, here" )
  wide_outcome_vars <- names(select(wide_calculate, comp_lowsec_v2, comp_upsec_v2, comp_prim_1524, comp_lowsec_1524, comp_upsec_2029, 
                                    eduyears_2024, edu4_2024, comp_higher_2yrs_2529, comp_higher_4yrs_2529, 
                                    comp_higher_4yrs_3034, attend_higher_1822, literacy_1524)) }
 
      categoriesinsvy <- c('disability','disability_trad_adults','sex')
      
     
        summarized_adults <- summ_bypieces(wide_calculate, wide_outcome_vars, depth = 2, categoriesinsvy)
              }
  
# (3) CDISABILITY <5 y-o relevant indicators
    if( exists("CDISABILITY", wide_calculate) ) {
      wide_outcome_vars <- names(select(wide_calculate, preschool_3))
      
      categoriesinsvy <- c('CDISABILITY','disability_trad_ch','sex')
      
      
      summarized_ch <- summ_bypieces(wide_calculate, wide_outcome_vars, depth = 2, categoriesinsvy)
    }
  
      
#Consolidate parts and clean rows that we don't need
  
  if( exists("disability", wide_calculate) ) {
    summarized_disability <- full_join(summarized_adults,summarized_ch,  by = c('country', 'survey', 'year','category', 'sex'))
  } else {
    summarized_disability <-summarized_ch 
  }
  
            
      #Get rid of category=='Sex'
      
      # Export data as .csv format by country
      survey <- substring( file_names[[i]], 1, 13)
      setwd("C:/Users/taiku/Desktop/temporary_sum")
      write.csv(summarized_disability, paste0(survey,"_summarized.csv"))
      
      
}




#OPTIONAL: merge all indicators into a single csv file
library(plyr)

#setwd("C:/Users/taiku/UNESCO/GEM Report - 3_calculated")
#setwd("C:/Users/taiku/Desktop/temporary_sum")
setwd("C:/Users/mm_barrios-rivera/Desktop/temporary_sum")

all_indicators <- ldply(list.files(), read.csv, header=TRUE)

write.csv(all_indicators, paste0("widetable","_summarized_2023_disability_CH_adult.csv"), na = '')

#search variables through this 
wide_calculate %>% dplyr:: select(contains("dif")) %>% names()

#  Part 3 : hh_edu tables for BILAL  -----------------------------------------------------------------


for (i in 1:length(file_names)) {
  print(file_names[[i]]) 
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
  
  if("hh_edu_mother" %in% colnames(wide_calculate))
  {
    categoriesinsvy <- c('hh_edu_head_exact', 'hh_edu_head_prim', 'hh_edu_head_lowsec', 'hh_edu_head_upsec',  'hh_edu_head_higher',
                         'hh_edu_adult_exact', 'hh_edu_adult_prim', 'hh_edu_adult_lowsec', 'hh_edu_adult_upsec', 'hh_edu_adult_higher',
                         'hh_edu_mother_exact','hh_edu_mother_prim','hh_edu_mother_lowsec','hh_edu_mother_upsec','hh_edu_mother_higher')
    
  } else {
    categoriesinsvy <-  c('hh_edu_head_exact', 'hh_edu_head_prim', 'hh_edu_head_lowsec', 'hh_edu_head_upsec',  'hh_edu_head_higher',
                          'hh_edu_adult_exact', 'hh_edu_adult_prim', 'hh_edu_adult_lowsec', 'hh_edu_adult_upsec', 'hh_edu_adult_higher')
    
  }
  
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
  summarized_wider <- summarized_wider %>% mutate(category= str_to_title(category)) %>%
    mutate(iso_code3 = countrycode::countrycode(country, 'country.name.en', 'iso3c')) 
  # Export data as .csv format by country
  survey <- substring( file_names[[i]], 1, 13)
  setwd("C:/Users/taiku/Desktop/temporary_sum")
  write.csv(summarized_wider, paste0(survey,"_summarized.csv"))
}


  #Do I want to collect all csv files? YES

#OPTIONAL: merge all indicators into a single csv file
library(plyr)

#setwd("C:/Users/taiku/UNESCO/GEM Report - 3_calculated")
setwd("C:/Users/taiku/Desktop/temporary_sum")
all_indicators <- ldply(list.files(), read.csv, header=TRUE)

#Some cleanup

c('hh_edu_head_exact', 'hh_edu_head_prim', 'hh_edu_head_lowsec', 'hh_edu_head_upsec',  'hh_edu_head_higher',
  'hh_edu_adult_exact', 'hh_edu_adult_prim', 'hh_edu_adult_lowsec', 'hh_edu_adult_upsec', 'hh_edu_adult_higher',
  'hh_edu_mother_exact','hh_edu_mother_prim','hh_edu_mother_lowsec','hh_edu_mother_upsec','hh_edu_mother_higher')

all_indicators_p1 <-all_indicators %>%  filter(!(hh_edu_head_exact == ''  )) 
all_indicators_p2 <-all_indicators %>%  filter(!(hh_edu_head_prim == ''  )) 
all_indicators_p3 <-all_indicators %>%  filter(!(hh_edu_head_lowsec == ''  )) 
all_indicators_p4 <-all_indicators %>%  filter(!(hh_edu_head_upsec == ''  )) 
all_indicators_p5 <-all_indicators %>%  filter(!(hh_edu_head_higher == ''  )) 

all_indicators_p6 <-all_indicators %>%  filter(!(hh_edu_adult_exact == '' ))
all_indicators_p7 <-all_indicators %>%  filter(!(hh_edu_adult_prim == '' ))
all_indicators_p8 <-all_indicators %>%  filter(!(hh_edu_adult_lowsec == '' ))
all_indicators_p9 <-all_indicators %>%  filter(!(hh_edu_adult_upsec == '' ))
all_indicators_p10 <-all_indicators %>%  filter(!(hh_edu_adult_higher == '' ))

all_indicators_p11 <-all_indicators %>%  filter(!(hh_edu_mother_exact == '' ))
all_indicators_p12 <-all_indicators %>%  filter(!(hh_edu_mother_prim == '' ))
all_indicators_p13 <-all_indicators %>%  filter(!(hh_edu_mother_lowsec == '' ))
all_indicators_p14 <-all_indicators %>%  filter(!(hh_edu_mother_upsec == '' ))
all_indicators_p15 <-all_indicators %>%  filter(!(hh_edu_mother_higher == '' ))

all_indicators_p16 <-all_indicators %>%  filter(category == 'Total' )

all_indicators_clean <-bind_rows(all_indicators_p1,all_indicators_p2,all_indicators_p3,all_indicators_p4, all_indicators_p5,
                                 all_indicators_p6,all_indicators_p7,all_indicators_p8,all_indicators_p9,all_indicators_p10,
                                 all_indicators_p11,all_indicators_p12,all_indicators_p13,all_indicators_p14,all_indicators_p15,
                                 all_indicators_p16)

all_indicators_clean2 <- all_indicators_clean %>%
  unite(hh_edu_mother, hh_edu_mother_prim, hh_edu_mother_lowsec, hh_edu_mother_upsec, hh_edu_mother_higher, sep = "", remove = TRUE, na.rm=TRUE) %>%
  unite(hh_edu_adult, hh_edu_adult_prim, hh_edu_adult_lowsec, hh_edu_adult_upsec, hh_edu_adult_higher, sep = "", remove = TRUE, na.rm=TRUE) %>%
  unite(hh_edu_head, hh_edu_head_prim, hh_edu_head_lowsec, hh_edu_head_upsec, hh_edu_head_higher, sep = "", remove = TRUE, na.rm=TRUE) 
  

write.csv(all_indicators_clean2, paste0("widetable","_summarized_hh-edu-Bilal.csv"), na = '')
