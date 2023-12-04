library(magrittr)
library(tidyverse)
library(countrycode)
library(dplyr)
library(vroom)
library(stringr)
library(purrr)
library(tidyr)
library(beepr)

############################
##PART 1: GET THE WEIGHTS##

#memory.limit(35000)
options(max.print=10000)

path2uisdata <- 'C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/UIS info/'

sap_indicators <- c(
  #'SAP.1.AgM1', 'SAP.02', 'SAP.5t8',
  'SAP.1', #'SAP.1.F', 'SAP.1.M', 
  'SAP.2', #'SAP.2.F', 'SAP.2.M',
  'SAP.3'#, #'SAP.3.F', 'SAP.3.M'
)

uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
    mutate(indicator_id = toupper(indicator_id))
}


#SAP= SCHOOL AGE POPULATION from UIS
saps <- 
  vroom::vroom(paste0(path2uisdata, 'OPRI_DATA_NATIONAL.csv'), na = '') %>% 
  filter(indicator_id %in% sap_indicators) %>% 
  #filter(between(year, 2015, 2019)) %>% 
  uis_clean %>% 
  select(weight = indicator_id, iso_code = country_id, year, value) %>% 
  # separate(indicator, c(NA, 'level', 'Sex'), remove = FALSE) %>% 
  # mutate(Sex = case_when(
  #   Sex == 'F' ~ 'Female',
  #   Sex == 'M' ~ 'Male'
  # )) %>% 
  #filter(iso_code != 'VAT') %>% 
  group_by(iso_code, weight, year) %>% 
  summarize(wt_value = mean(value, na.rm = TRUE)) %>% 
  ungroup


saps_total <- saps %>% group_by(weight, year) %>% 
  dplyr::summarize(
    total_weight_represented = sum(wt_value, na.rm = TRUE),
    total_count_represented = sum(!is.na(wt_value))
  ) 


############################
##PART 2: GET THE OOS DATA##


#C:\Users\taiku\Documents\GEM UNESCO MBR\UIS stat comparison\UIS sept 2022 bulk data
path2uisdata <- 'C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/UIS info/'


uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
    mutate(indicator_id = toupper(indicator_id))
}

indicators2disagg <- c(
 # 'CR.1', 'CR.2', 'CR.3',
  'ROFST.H.1', 'ROFST.H.2', 'ROFST.H.3'
)

disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste0("\\b(",paste(indicators2disagg, collapse = '|'),")\\b"))) %>% 
  filter(!str_detect(indicator_id, 'PIA'), !str_detect(indicator_id, fixed('1t'))) %>% 
  #addition: not taking disability data
  filter(!str_detect(indicator_id, 'DIS'), !str_detect(indicator_id, fixed('ABL'))) %>% 
  uis_clean %>%
  mutate(len=str_length(indicator_id)) %>% filter(len==9) %>% select(-len) %>%
  rename(iso_code = country_id)


weights <- 
  bind_rows(saps) %>% 
  arrange(iso_code) %>% 
  inner_join(vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/weight_vars.csv'), by = 'weight',relationship = "many-to-many") %>%
  filter(str_detect(indicator, 'eduout')) %>% 
  mutate(indicator_id=case_when(
    indicator == 'eduout_prim_m'  ~  'ROFST.H.1' ,
    indicator == 'eduout_lowsec_m'   ~ 'ROFST.H.2' ,
    indicator ==  'eduout_upsec_m' ~ 'ROFST.H.3' ))


######################################
##PART 3: AGGREGATE##


yearagg <- disaggs_uis %>%
  left_join(weights, by = c('iso_code', 'indicator_id', 'year')) %>%
  filter(!is.na(wt_value), !is.na(value)) 
  #pivot_wider(names_from = 'indicator_id', values_from = 'value') 

aggfun <- function(x, w) weighted.mean(x, w, na.rm = TRUE)


WORLD <- yearagg %>% 
  group_by(indicator_id, year) %>% 
  dplyr::summarize(
    weight_represented = sum(wt_value),
    count_represented = sum(!is.na(value)),
    value = aggfun(value, wt_value)
  ) %>% mutate(weight=case_when(
    indicator_id == 'ROFST.H.1'  ~  'SAP.1' ,
    indicator_id  == 'ROFST.H.2'   ~ 'SAP.2' ,
    indicator_id ==  'ROFST.H.3' ~ 'SAP.3' )) %>% 
  inner_join(saps_total, by = c('weight', 'year') ) %>%
 mutate(rep_pop=weight_represented/total_weight_represented, 
        rep_ncountries=count_represented/total_count_represented)


write.csv(WORLD, file="UIS_world_oos.csv")  
  
###### somthin else

viewextract <- 
  vroom::vroom(paste0(path2uisdata, 'OOS_Children_Aggregates.csv'), na = '') %>% select(-lower, -upper) %>%
  filter


