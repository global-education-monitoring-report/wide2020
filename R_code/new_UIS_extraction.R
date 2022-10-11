## 2022 UIS 2 WIDE revival 

#Task 1: whats there
#Task 2: whats new


library(tidyverse)
library(stringr)
library(purrr)

## put UIS disaggregated completion and OOS data into WIDE-compatible format for overwrite

path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/sept 2022 update/'

#path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/update/'
#NEW!!!



uis_clean <- function(uis_data) {
  print(table(uis_data$QUALIFIER))
  mutate(uis_data, VALUE = ifelse(MAGNITUDE == 'NA' & VALUE == 0, NA, VALUE)) %>% 
    mutate(INDICATOR_ID = toupper(INDICATOR_ID))
}

indicators2disagg <- c(
  'CR.1', 'CR.2', 'CR.3',
  'ROFST.H.1', 'ROFST.H.2', 'ROFST.H.3'
)


disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(INDICATOR_ID, paste(indicators2disagg, collapse = '|'))) %>% 
  filter(!str_detect(INDICATOR_ID, 'PIA'), !str_detect(INDICATOR_ID, fixed('1t'))) %>% 
  uis_clean

uis_meta <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_METADATA.csv'), na = '') %>% 
  filter(str_detect(INDICATOR_ID, paste(indicators2disagg, collapse = '|'))) %>% 
  select(iso_code3 = COUNTRY_ID, year = YEAR, meta = METADATA) %>% 
  mutate(survey = case_when(
    str_detect(meta, "WIDE") ~ 'Drop' ,
    str_detect(meta, "Value suppressed") ~ 'Drop',
    str_detect(meta, "Value based on 25-49 unweighted") ~ 'Drop',
    str_detect(meta, "MICS") ~ 'MICS',
    str_detect(meta, "DHS") ~ 'DHS',
    str_detect(meta, "HDS") ~ 'HDS',
    str_detect(meta, "PNAD") ~ 'PNAD',
    str_detect(meta, "CFPS") ~ 'CFPS',
    str_detect(meta, "CASEN") ~ 'CASEN',
    str_detect(meta, "CPS-ASEC") ~ 'CPS-ASEC',
    str_detect(meta, "Census|census|Recensement|Censo") ~ 'Census',
    str_detect(meta, "Uruguay Encuesta Nacional de Hogares - Fuerza de Trabajo") ~ 'ENH-FT',
    str_detect(meta, "Argentina Encuesta Permanente de Hogares") ~ 'EPH',
    str_detect(meta, "ENIGH") ~ 'ENIGH',
    str_detect(meta, "HES") ~ 'HES',
    str_detect(meta, "General Household Survey") ~ 'GHS',
    str_detect(meta, "American Community Survey") ~ 'ACS',
    str_detect(meta, "South Africa Community Survey") ~ 'CS',
    str_detect(meta, "Costa Rica Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Encuesta de Hogares por Muestreo") ~ 'EHM',
    str_detect(meta, "Encuesta Continua de Hogares") ~ 'ECH',
    str_detect(meta, "RLMS-HSE") ~ 'RLMS-HSE',
    str_detect(meta, "Colombia Gran Encuesta Integrada de Hogares") ~ 'GEIH',
    str_detect(meta, "Peru Encuesta Nacional de Hogares|ENAHO") ~ 'ENAHO',
    str_detect(meta, "ENCFT") ~ 'ENCFT',
    str_detect(meta, fixed("Colombia Encuesta Nacional de Hogares - Fuerza de Trabajo")) ~ 'ENH-FT',
    str_detect(meta, "EFT") ~ 'EFT',
    str_detect(meta, "Ecuador Encuesta de Empleo, Subempleo y Desempleo|ENEMDU") ~ 'ENEMDU',
    str_detect(meta, "ENCOVI") ~ 'ENCOVI',
    str_detect(meta, "Paraguay Encuesta Permanente de Hogares") ~ 'EPH',
    str_detect(meta, "Paraguay Encuesta Integrada de Hogares") ~ 'EIH',
    str_detect(meta, "El Salvador Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Panama Encuesta de Hogares|Bolivia Encuesta de Hogares") ~ 'EH',
    str_detect(meta, "Honduras Encuesta Permanente de Hogares de Propositos Multiples") ~ 'EPHPM',
    str_detect(meta, "Nicaragua Encuesta Nacional de Hogares sobre Medicion de Niveles de Vida") ~ 'EMNV',
    TRUE ~ 'other'  )) %>% 
  select(-meta) %>% filter(survey != "Drop")

#Finding out new stuff 
#uis_meta_seeother <- uis_meta %>% distinct() %>% filter(survey == 'Already in WIDE')


uis2wide <- function(df) {
  df %>% 
    mutate(indicator = case_when(
      str_detect(INDICATOR_ID, 'CR') ~ 'comp',
      str_detect(INDICATOR_ID, 'ROFST') ~ 'eduout',
    )) %>% 
    mutate(level = case_when(
      str_detect(INDICATOR_ID, fixed('.1')) ~ 'prim',
      str_detect(INDICATOR_ID, fixed('.2')) ~ 'lowsec',
      str_detect(INDICATOR_ID, fixed('.3')) ~ 'upsec',
    )) %>% 
    mutate(indicator = case_when(
      str_detect(indicator, 'comp') ~ paste(indicator, level, 'v2_m', sep = '_'),
      TRUE ~ paste(indicator, level, 'm', sep = '_')
    )) %>% 
    mutate(Location = case_when(
      str_detect(INDICATOR_ID, 'URB') ~ 'Urban',
      str_detect(INDICATOR_ID, 'RUR') ~ 'Rural',
      TRUE ~ NA_character_
    )) %>% 
    mutate(Sex = case_when(
      str_detect(INDICATOR_ID, fixed('.F')) ~ 'Female',
      str_detect(INDICATOR_ID, fixed('.M')) ~ 'Male',
      TRUE ~ NA_character_
    )) %>% 
    mutate(Wealth = case_when(
      str_detect(INDICATOR_ID, 'Q1') ~ 'Quintile 1',
      str_detect(INDICATOR_ID, 'Q2') ~ 'Quintile 2',
      str_detect(INDICATOR_ID, 'Q3') ~ 'Quintile 3',
      str_detect(INDICATOR_ID, 'Q4') ~ 'Quintile 4',
      str_detect(INDICATOR_ID, 'Q5') ~ 'Quintile 5',
      TRUE ~ NA_character_
    )) %>% 
    rowwise %>%  
    mutate(category = paste(
      c('Location', 'Sex', 'Wealth')[which(map_lgl(c(Location, Sex, Wealth), ~ !is.na(.x)))], 
      collapse = ' & ')) %>% 
    mutate(category = if_else(category == '', 'Total', category)) %>% 
    ungroup %>% 
    mutate(value = VALUE/100) %>% 
    select(iso_code3 = COUNTRY_ID, year = YEAR, category, Sex, Location, Wealth, indicator, level, value) %>% 
    left_join(uis_meta, by = c('iso_code3', 'year'))
}

uis4wide <- uis2wide(disaggs_uis) %>% 
  filter(!is.na(survey))

#Seemingly there are a ton of duplicates, so getting rid of them 
uis4wide <- uis4wide %>% distinct()

#iso_code3,year,category,Sex,Location,Wealth,indicator,value
#setwd("C:/Users/taiku/OneDrive - UNESCO/WIDE files/")

#write_csv(uis4wide, 'uis4wide.csv', na = '')

#Now let's find out what that "other" surveys were
# uis_meta <- 
#   vroom::vroom(paste0(path2uisdata, 'SDG_METADATA.csv'), na = '') %>% 
#   filter(str_detect(INDICATOR_ID, paste(indicators2disagg, collapse = '|'))) %>% 
#   select(iso_code3 = COUNTRY_ID, year = YEAR, meta = METADATA, type = TYPE) %>% 
#   mutate(survey = case_when(
#     str_detect(meta, "Value suppressed") ~ 'Value supressed',
#     str_detect(meta, "Value based on 25-49 unweighted") ~ 'Few observations based',
#       TRUE ~ 'other'  )) %>% 
#    filter(survey != "other")
# 
# post_mortem <- uis2wide(disaggs_uis) 
# 
# 
#  selection <- uis4wide %>% filter(category == "Total")  %>% filter(survey == "DHS" | survey == "MICS")  %>%
#    filter(year >= 2016) %>% filter(!iso_code3 == "MLI")  %>% pivot_wider(id_cols = c(iso_code3, year, survey), names_from = 'indicator', values_from = 'value')
# # 
#  setwd("C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison")
#  write.csv(selection, "uis_selection2.csv")


path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/sept 2022 update/'
test <-   vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') 

uis_meta <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_METADATA.csv'), na = '')


glimpse(test)
summary(test)

disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|')))

indicatorsdisability <- vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>%
  filter(str_detect(indicator_id,c('DIS', 'ABL')))
  'CR.1', 'CR.2', 'CR.3',
  'ROFST.H.1', 'ROFST.H.2', 'ROFST.H.3'
)

disability2 <- indicatorsdisability %>%
left_join(uis_meta, by = c('indicator_id', 'country_id', 'year'))

setwd('C:/Users/taiku/Documents/GEM UNESCO MBR/disability unicef code')
write.csv(disability2, 'disabilityUIS.csv')

setwd(here())


###################################

path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/sept 2022 update/'


uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, VALUE = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
    mutate(indicator_id = toupper(indicator_id))
}

indicators2disagg <- c(
  'CR.1', 'CR.2', 'CR.3',
  'ROFST.H.1', 'ROFST.H.2', 'ROFST.H.3'
)


disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  filter(!str_detect(indicator_id, 'PIA'), !str_detect(indicator_id, fixed('1t')), !str_detect(indicator_id, fixed('DIS')), !str_detect(indicator_id, fixed('ABL'))) 

#%>% 

#  uis_clean

uis_meta <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_METADATA.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  select(iso_code3 = country_id, year = year, meta = metadata) %>% 
  mutate(survey = case_when(
    str_detect(meta, "WIDE") ~ 'Directly from WIDE' ,
    str_detect(meta, "EU-SILC") ~ 'EU-SILC from GEMR' ,
    str_detect(meta, "LIS") ~ 'LIS from GEMR' ,
    str_detect(meta, "ECLAC") ~ 'ECLAC' ,
    str_detect(meta, "Value suppressed") ~ 'Drop',
    str_detect(meta, "Value based on 25-49 unweighted") ~ 'Drop',
    str_detect(meta, "MICS") ~ 'MICS',
    str_detect(meta, "DHS") ~ 'DHS',
    str_detect(meta, "HDS") ~ 'HDS',
    str_detect(meta, "PNAD") ~ 'PNAD',
    str_detect(meta, "CFPS") ~ 'CFPS',
    str_detect(meta, "CASEN") ~ 'CASEN',
    str_detect(meta, "CPS-ASEC") ~ 'CPS-ASEC',
    str_detect(meta, "Census|census|Recensement|Censo") ~ 'Census',
    str_detect(meta, "Uruguay Encuesta Nacional de Hogares - Fuerza de Trabajo") ~ 'ENH-FT',
    str_detect(meta, "Argentina Encuesta Permanente de Hogares") ~ 'EPH',
    str_detect(meta, "ENIGH") ~ 'ENIGH',
    str_detect(meta, "HES") ~ 'HES',
    str_detect(meta, "General Household Survey") ~ 'GHS',
    str_detect(meta, "American Community Survey") ~ 'ACS',
    str_detect(meta, "South Africa Community Survey") ~ 'CS',
    str_detect(meta, "Costa Rica Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Encuesta de Hogares por Muestreo") ~ 'EHM',
    str_detect(meta, "Encuesta Continua de Hogares") ~ 'ECH',
    str_detect(meta, "RLMS-HSE") ~ 'RLMS-HSE',
    str_detect(meta, "Colombia Gran Encuesta Integrada de Hogares") ~ 'GEIH',
    str_detect(meta, "Peru Encuesta Nacional de Hogares|ENAHO") ~ 'ENAHO',
    str_detect(meta, "ENCFT") ~ 'ENCFT',
    str_detect(meta, fixed("Colombia Encuesta Nacional de Hogares - Fuerza de Trabajo")) ~ 'ENH-FT',
    str_detect(meta, "EFT") ~ 'EFT',
    str_detect(meta, "Ecuador Encuesta de Empleo, Subempleo y Desempleo|ENEMDU") ~ 'ENEMDU',
    str_detect(meta, "ENCOVI") ~ 'ENCOVI',
    str_detect(meta, "Paraguay Encuesta Permanente de Hogares") ~ 'EPH',
    str_detect(meta, "Paraguay Encuesta Integrada de Hogares") ~ 'EIH',
    str_detect(meta, "El Salvador Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Panama Encuesta de Hogares|Bolivia Encuesta de Hogares") ~ 'EH',
    str_detect(meta, "Honduras Encuesta Permanente de Hogares de Propositos Multiples") ~ 'EPHPM',
    str_detect(meta, "Nicaragua Encuesta Nacional de Hogares sobre Medicion de Niveles de Vida") ~ 'EMNV',
    str_detect(meta, "GEMR") ~ 'something else GEM' ,
    TRUE ~ meta  )) %>% 
   filter(survey != "Drop")


uis2wide <- function(df) {
  df %>% 
    mutate(indicator = case_when(
      str_detect(indicator_id, 'CR') ~ 'comp',
      str_detect(indicator_id, 'ROFST') ~ 'eduout',
    )) %>% 
    mutate(level = case_when(
      str_detect(indicator_id, fixed('.1')) ~ 'prim',
      str_detect(indicator_id, fixed('.2')) ~ 'lowsec',
      str_detect(indicator_id, fixed('.3')) ~ 'upsec',
    )) %>% 
    mutate(indicator = case_when(
      str_detect(indicator, 'comp') ~ paste(indicator, level, 'v2_m', sep = '_'),
      TRUE ~ paste(indicator, level, 'm', sep = '_')
    )) %>% 
    mutate(Location = case_when(
      str_detect(indicator_id, 'URB') ~ 'Urban',
      str_detect(indicator_id, 'RUR') ~ 'Rural',
      TRUE ~ NA_character_
    )) %>% 
    mutate(Sex = case_when(
      str_detect(indicator_id, fixed('.F')) ~ 'Female',
      str_detect(indicator_id, fixed('.M')) ~ 'Male',
      TRUE ~ NA_character_
    )) %>% 
    mutate(Wealth = case_when(
      str_detect(indicator_id, 'Q1') ~ 'Quintile 1',
      str_detect(indicator_id, 'Q2') ~ 'Quintile 2',
      str_detect(indicator_id, 'Q3') ~ 'Quintile 3',
      str_detect(indicator_id, 'Q4') ~ 'Quintile 4',
      str_detect(indicator_id, 'Q5') ~ 'Quintile 5',
      TRUE ~ NA_character_
    )) %>% 
    rowwise %>%  
    mutate(category = paste(
      c('Location', 'Sex', 'Wealth')[which(map_lgl(c(Location, Sex, Wealth), ~ !is.na(.x)))], 
      collapse = ' & ')) %>% 
    mutate(category = if_else(category == '', 'Total', category)) %>% 
    ungroup %>% 
    mutate(value = value/100) %>% 
    select(iso_code3 = country_id, year = year, category, Sex, Location, Wealth, indicator, level, value) 
  #%>% 
   # left_join(uis_meta, by = c('iso_code3', 'year'))
}

uis4wide <- uis2wide(disaggs_uis) 

wtf <- left_join(uis4wide, uis_meta, by = c('iso_code3', 'year'))

justCOL <- uis_meta %>% filter(iso_code3=='COL', year==2018)

#TAKES TOO LONG 
#test3 <- unique(uis4wide)

#better
test4 <- distinct(uis4wide)
rm(uis4wide)
table(test4$indicator)

test4 <- test4 %>% select(-level) %>% mutate(Sex = case_when(str_detect(meta, c('GEMR')) ~ 'GEMR',   TRUE ~ 'non GEMR'))

%>%  
  pivot_wider(names_from = 'indicator', values_from = 'value')


what <- test4 %>%
  dplyr::group_by(iso_code3, year, category, Sex, Location, Wealth, meta, survey, indicator) %>%
  dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
  dplyr::filter(n > 1L) 

#%>% select(-meta) %>% filter(survey != "Drop")
setwd('C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/sept 2022 update/')
write.csv(uis_meta, 'uis4wide.csv')

justMLI <- uis_meta %>%  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  filter(!str_detect(indicator_id, 'PIA'), !str_detect(indicator_id, fixed('1t')), !str_detect(indicator_id, fixed('DIS')), !str_detect(indicator_id, fixed('ABL'))) %>%
  filter(country_id=='MLI') %>% filter(year==2018) %>%
      mutate(indicator = case_when(
        str_detect(indicator_id, 'CR') ~ 'comp',
        str_detect(indicator_id, 'ROFST') ~ 'eduout',
      )) %>% 
      mutate(Location = case_when(
    str_detect(indicator_id, 'URB') ~ 'Urban',
    str_detect(indicator_id, 'RUR') ~ 'Rural',
    TRUE ~ NA_character_
  )) %>% 
  mutate(Sex = case_when(
    str_detect(indicator_id, fixed('.F')) ~ 'Female',
    str_detect(indicator_id, fixed('.M')) ~ 'Male',
    TRUE ~ NA_character_
  )) %>% 
  mutate(Wealth = case_when(
    str_detect(indicator_id, 'Q1') ~ 'Quintile 1',
    str_detect(indicator_id, 'Q2') ~ 'Quintile 2',
    str_detect(indicator_id, 'Q3') ~ 'Quintile 3',
    str_detect(indicator_id, 'Q4') ~ 'Quintile 4',
    str_detect(indicator_id, 'Q5') ~ 'Quintile 5',
    TRUE ~ NA_character_))  %>% 
  rowwise %>%  
  mutate(category = paste(
    c('Location', 'Sex', 'Wealth')[which(map_lgl(c(Location, Sex, Wealth), ~ !is.na(.x)))], 
    collapse = ' & ')) %>% 
  mutate(category = if_else(category == '', 'Total', category))

names(justMLI)
table(justMLI$metadata)
table(justMLI$indicator,justMLI$metadata)
table(justMLI$category,justMLI$metadata)

dataMLI<- disaggs_uis %>%  filter(country_id=='MLI') %>% filter(year==2018) 
names(dataMLI)
names(justMLI)
porfincsm <- dataMLI %>%  left_join(justMLI, by = c('country_id', 'year','indicator_id'))



subset <-justCOL %>% filter(metadata=='Colombia Gran Encuesta Integrada de Hogares 2018. ECLAC calculations based on household survey data bank.') 
table(subset$category)


############################################
### CLEAN NEW MERGE get here -------
##########################################
library(tidyverse)
library(stringr)
library(purrr)


path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/sept 2022 update/'

indicators2disagg <- c(
  'CR.1', 'CR.2', 'CR.3',
  'ROFST.H.1', 'ROFST.H.2', 'ROFST.H.3'
)

#PIA gets rid of the gender/disability/location/weakth Parity Index
# 1t gets rid of preprimary(?)
# DIS and ABL gets rid of the disability indicators 
#disaggs has the actual indicator values!

disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  mutate(value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>%
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  filter(!str_detect(indicator_id, 'PIA'), !str_detect(indicator_id, fixed('1t')), !str_detect(indicator_id, fixed('DIS')), !str_detect(indicator_id, fixed('ABL'))) %>%
  select(-magnitude, -qualifier)

#This gets the survey name but needs to be recoded
#type just says "Source:Data sources"


uis_meta <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_METADATA.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  mutate(survey = case_when(
     str_detect(metadata, "Value suppressed") ~ 'Drop',
    str_detect(metadata, "Value based on 25-49 unweighted") ~ 'Drop',
    TRUE ~ metadata  )) %>% 
  filter(survey != "Drop") %>% select(-type)


uis4wide <- disaggs_uis %>%  left_join(uis_meta, by = c('country_id', 'year','indicator_id'))

#Get categories and rename indicator
uis4wide <- uis4wide %>%
  mutate(indicator = case_when(
  str_detect(indicator_id, 'CR') ~ 'comp',
  str_detect(indicator_id, 'ROFST') ~ 'eduout',
)) %>% 
  mutate(level = case_when(
    str_detect(indicator_id, fixed('.1')) ~ 'prim',
    str_detect(indicator_id, fixed('.2')) ~ 'lowsec',
    str_detect(indicator_id, fixed('.3')) ~ 'upsec',
  )) %>% 
  mutate(indicator = case_when(
    str_detect(indicator, 'comp') ~ paste(indicator, level, 'v2_m', sep = '_'),
    TRUE ~ paste(indicator, level, 'm', sep = '_')
  )) %>% 
  mutate(Location = case_when(
    str_detect(indicator_id, 'URB') ~ 'Urban',
    str_detect(indicator_id, 'RUR') ~ 'Rural',
    TRUE ~ NA_character_
  )) %>% 
  mutate(Sex = case_when(
    str_detect(indicator_id, fixed('.F')) ~ 'Female',
    str_detect(indicator_id, fixed('.M')) ~ 'Male',
    TRUE ~ NA_character_
  )) %>% 
  mutate(Wealth = case_when(
    str_detect(indicator_id, 'Q1') ~ 'Quintile 1',
    str_detect(indicator_id, 'Q2') ~ 'Quintile 2',
    str_detect(indicator_id, 'Q3') ~ 'Quintile 3',
    str_detect(indicator_id, 'Q4') ~ 'Quintile 4',
    str_detect(indicator_id, 'Q5') ~ 'Quintile 5',
    TRUE ~ NA_character_
  )) %>% 
  rowwise %>%  
  mutate(category = paste(
    c('Location', 'Sex', 'Wealth')[which(map_lgl(c(Location, Sex, Wealth), ~ !is.na(.x)))], 
    collapse = ' & ')) %>% 
  mutate(category = if_else(category == '', 'Total', category)) %>%
  rename (indicator_uis_name = indicator_id )

table(uis4wide$category)
table(uis4wide$indicator)

table(uis4wide$Wealth)
table(uis4wide$Location)

#Fix survey names from the metadata string 

exploremeta <- distinct(uis4wide,metadata)

uis4wide <- uis4wide %>%  select(-survey) %>% 
  mutate(survey2 = case_when(
  str_detect(metadata, "GEMR") ~ 'GEM' ,
  str_detect(metadata, "WIDE") ~ 'GEM' ,
  str_detect(metadata, "EU-SILC") ~ 'EU-SILC' ,
  str_detect(metadata, "LIS") ~ 'LIS' ,
  str_detect(metadata, "ECLAC") ~ 'ECLAC' ,
  str_detect(metadata, "IPUMS") ~ 'IPUMS' ,
  str_detect(metadata, "MICS") ~ 'MICS',
  str_detect(metadata, "DHS") ~ 'DHS',
  str_detect(metadata, "Census|census|Recensement|Censo") ~ 'Census',  TRUE ~ 'Likely national survey'  )) %>%
  mutate(source_calculation = case_when(
    str_detect(metadata, "GEMR") ~ 'taken from GEM' ,
    str_detect(metadata, "WIDE") ~ 'taken from GEM' ,
        str_detect(metadata, "ECLAC") ~ 'taken from ECLAC' ,
    TRUE ~ 'likely UIS'  ))  

table(uis4wide$survey2)
table(uis4wide$source_calculation)

check <- uis4wide %>% filter(survey2=='Likely national survey') %>% select(survey2,source_calculation,metadata,country_id,year) %>% distinct()
#select(iso_code3 = country_id, year = year, meta = metadata) %>% 


############

#Some extracts 
uis4somalia <- uis4wide %>% filter(str_detect(country_id, 'SOM')) %>% filter(str_detect(year, 'SOM'))

                                   