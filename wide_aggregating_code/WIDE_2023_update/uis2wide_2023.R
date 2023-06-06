## put UIS disaggregated completion and OOS data into WIDE-compatible format for overwrite

library(tidyverse)

#path2uisdata <- 'C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/UIS stat comparison/UIS sept 2022 bulk data/'
#march update:
path2uisdata2 <- 'C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/UIS info/'

#C:\Users\taiku\Documents\GEM UNESCO MBR\UIS stat comparison\UIS sept 2022 bulk data

uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
  mutate(indicator_id = toupper(indicator_id))
}

indicators2disagg <- c(
  'CR.1', 'CR.2', 'CR.3',
  'ROFST.H.1', 'ROFST.H.2', 'ROFST.H.3'
)


disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  filter(!str_detect(indicator_id, 'PIA'), !str_detect(indicator_id, fixed('1t'))) %>% 
  #addition: not taking disability data
  filter(!str_detect(indicator_id, 'DIS'), !str_detect(indicator_id, fixed('ABL'))) %>% 
  uis_clean 

#%>% filter(year > 2018)

uis_meta <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_METADATA.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>% 
  select(iso_code3 = country_id, year = year, meta = metadata) %>% 
  mutate(survey = case_when(
    str_detect(meta, "education-estimates.org") ~ 'Ameer',
    str_detect(meta, "SILC") ~ 'EU-SILC',
    str_detect(meta, "MICS") ~ 'MICS',
    str_detect(meta, "LIS") ~ 'LIS',
    str_detect(meta, "DHS") ~ 'DHS',
    str_detect(meta, "WIDE") ~ 'Already in WIDE',
    str_detect(meta, "HDS") ~ 'HDS',
    str_detect(meta, "PNAD") ~ 'PNAD',
    str_detect(meta, "CFPS") ~ 'CFPS',
    str_detect(meta, "CASEN") ~ 'CASEN',
    str_detect(meta, "CPS-ASEC") ~ 'CPS-ASEC',
    str_detect(meta, "Census|census|Recensement|Censo") ~ 'Census',
    str_detect(meta, "Honduras Encuesta Permanente de Hogares de Propositos Multiples") ~ 'EPHPM',
    str_detect(meta, "Uruguay Encuesta Nacional de Hogares - Fuerza de Trabajo") ~ 'ENH-FT',
    str_detect(meta, "Encuesta Nacional de Hogares  Condiciones de Vida y Pobreza") ~ 'ENAHO',
    str_detect(meta, "Encuesta Nacional de Hogares") ~ 'ENH',
    str_detect(meta, "Argentina Encuesta Permanente de Hogares") ~ 'EPH',
    str_detect(meta, "ENIGH") ~ 'ENIGH',
    str_detect(meta, "HES") ~ 'HES',
    str_detect(meta, "General Household Survey") ~ 'GHS',
    str_detect(meta, "American Community Survey") ~ 'ACS',
    str_detect(meta, "South Africa Community Survey") ~ 'CS',
    str_detect(meta, "Costa Rica Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Encuesta de Hogares por Muestreo") ~ 'EHM',
    str_detect(meta, "Uruguay Encuesta Continua de Hogares") ~ 'ECH',
    str_detect(meta, "RLMS-HSE") ~ 'RLMS-HSE',
    str_detect(meta, "Gran Encuesta Integrada de Hogares") ~ 'GEIH',
    str_detect(meta, "Peru Encuesta Nacional de Hogares|ENAHO") ~ 'ENAHO',
    str_detect(meta, "Costa Rica Encuesta Nacional de Hogares") ~ 'ENAHO',
    str_detect(meta, fixed("Colombia Encuesta Nacional de Hogares - Fuerza de Trabajo")) ~ 'ENH-FT',
    str_detect(meta, "Encuesta de Fuerza de Trabajo") ~ 'EFT',
    str_detect(meta, "Costa Rica Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Encuesta de Empleo, Subempleo y Desempleo en el Area Urbana y Rural") ~ 'EESD',
    str_detect(meta, "Ecuador Encuesta de Empleo, Subempleo y Desempleo|ENEMDU") ~ 'ENEMDU',
    str_detect(meta, "ENCOVI") ~ 'ENCOVI', 
    str_detect(meta, "Encuesta de Mercado Laboral") ~ 'EML', 
    str_detect(meta, "Dominican Republic Encuesta de Fuerza de Trabajo") ~ 'EFT', 
    str_detect(meta, "Encuesta Nacional Continua de Fuerza de Trabajo - ENCFT") ~ 'ENCFT', 
    str_detect(meta, "Encuesta Permanente de Hogares") ~ 'EPH',
    str_detect(meta, "Nicaragua Encuesta Nacional de Hogares sobre Medicion de Niveles de Vida ") ~ 'ENHMNV',
    str_detect(meta, "Encuesta Nacional de Hogares sobre Medicion de Niveles de Vida ") ~ 'ENHMNV',
    str_detect(meta, "Paraguay Encuesta Integrada de Hogares") ~ 'EIH',
    str_detect(meta, "Encuesta de Hogares de Propositos Multiples") ~ 'EHPM',
    str_detect(meta, "Panama Encuesta de Hogares") ~ 'EH',
    str_detect(meta, "Bolivia Encuesta Continua de Hogares") ~ 'ECH',
    str_detect(meta, "Bolivia Encuesta de Hogares") ~ 'EH',
    str_detect(meta, "Encuesta de Hogares") ~ 'EH',
    str_detect(meta, "Encuesta Integrada de Hogares") ~ 'EIH',
    str_detect(meta, "Encuesta Continua de Hogares") ~ 'ECH',
    str_detect(meta, "Encuesta de Propositos Multiples") ~ 'EPM',
    str_detect(meta, "Nicaragua Encuesta Nacional de Hogares sobre Medicion de Niveles de Vida") ~ 'EMNV',
    #new lines for new surveys
    str_detect(meta, "Ethiopian Socioeconomic Survey ") ~ 'ESS',
    str_detect(meta, "Djibouti EnquAte Djiboutienne") ~ 'EDAM',
    str_detect(meta, "India NFHS 2019-21") ~ 'NFHS',
    str_detect(meta, "Cambodia Living Standards Measurement Study Plus") ~ 'LSMS',
    str_detect(meta, "Morocco Household and Youth Survey") ~ 'HYS',
    str_detect(meta, "Tanzania Household Budget Survey 2017-18") ~ 'HBS',
    str_detect(meta, "Tanzania National Panel Survey") ~ 'NPS',
    str_detect(meta, "Brazil COVID-19 High Frequency") ~ 'HFPS',
    str_detect(meta, "EnquAte harmonisAe sur les conditions de vie des mAnages") ~ 'EHCVM',
    str_detect(meta, "EHCVM") ~ 'EHCVM',
    #march 23 upadte
    str_detect(meta, "Tanzania High Frequency Welfare Monitoring Phone Survey 2021") ~ 'HFWPS',
    str_detect(meta, "Burkina Faso COVID-19 High Frequency Phone Survey") ~ 'HFPS',
    str_detect(meta, "Afrobarometer 2017") ~ 'Afrobarometer',
    str_detect(meta, "Kenya Continuous Household Survey Programme") ~ 'KCHSP',
    str_detect(meta, "China Family Panel Studies") ~ 'CFPS',
    #detect and drop these
    str_detect(meta, "GEMR") ~ 'GEMR',
    str_detect(meta, "Value suppressed") ~ 'Value supressed',
    str_detect(meta, "Value based") ~ 'Value based on <50',
      TRUE ~ 'other' )) %>% 
  select(-meta) %>% 
  filter(!(survey=='Value supressed' | survey == 'Value based on <50' | survey == 'Already in WIDE' | survey == 'GEMR' | survey == 'EU-SILC'| survey=='Ameer' | survey=='LIS' ))

#others <- uis_meta %>% filter(survey=='other') %>% distinct()
#micsdhs <- uis_meta %>% filter(survey=='MICS' | survey == 'DHS') %>% distinct()
#eclac <- uis_meta %>% filter(survey=='ECLAC' ) %>% distinct()
#what <- uis_meta %>% select(iso_code3, survey) %>% distinct()
# turkey <- uis_meta %>% filter(iso_code3=='TUR' ) %>% distinct()
# india <- uis_meta %>% filter(iso_code3=='IND' ) %>% distinct()

multi_year_surveys <- uis_meta %>% distinct() %>% arrange(desc(year)) %>% 
  mutate( guion = ifelse(str_detect(meta, "(20)\\d{2}-"), "multi-year", "just one year")) %>%
  mutate(metaclean =str_replace(meta, pattern='The survey collected data on school attendance for age 5 to 18.|The survey collected data on school attendance for age 3-24 and educational attainment for age 3 and above.|The survey collected data on school attendance for age 3-24 and educational attainment for age 3 and above.|The survey collected data on school attendance for age 5-24 and educational attainment for age 5 and above.|The survey collected data on school attendance and educational attainment for age 3 and above.|The survey collected data on school attendance for age 4-24 and educational attainment for age 4 and above.', replacement='')) %>%
  select(-meta) %>%
  filter(guion == 'multi-year')

multi_mics <- multi_year_surveys %>% filter(survey=='MICS') %>% filter(year>2016)

write_excel_csv(multi_year_surveys, "C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/multi_year_surveys.csv")
 
#table(uis_meta$survey)

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
  select(iso_code3 = country_id, year = year, category, Sex, Location, Wealth, indicator, level, value) %>% 
  left_join(uis_meta, by = c('iso_code3', 'year'))
}
####WARNING: it TAKES not that much to run this
uis4wide <- uis2wide(disaggs_uis)

rm(uis_meta)
rm(disaggs_uis)

#FIXIIIING
#this takes a lot 
#Seemingly there are a ton of duplicates, so getting rid of them 
#WARNING: TAKES A LOT
uis4wide <- uis4wide %>% 
  filter(!is.na(survey)) %>%
  filter(!is.na(value)) %>%
  #trim meta and level columns 
select(-level) %>% distinct() %>%  arrange(iso_code3,year, survey, category, Sex, Location, Wealth, indicator, value)


##############################

setwd("C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/WIDE_2023_files")

write_csv(uis4wide, 'uis4wide.csv', na = '')

##THE END##
################################




test <- 
  vroom::vroom(paste0(path2uisdata, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2disagg, collapse = '|'))) %>%
  filter(!str_detect(indicator_id, 'PIA'), !str_detect(indicator_id, fixed('1t'))) %>% filter(str_detect(indicator_id, 'ABL|DIS')) %>%
                                                                                                select(indicator_id) %>% distinct()

checking_dis_surveys <- disaggs_uis %>% left_join(uis_meta, by = c('country_id' = 'iso_code3', 'year')) %>%  filter(str_detect(indicator_id, 'ABL|DIS')) %>%
  select(indicator_id, country_id,survey, meta, year) %>% distinct()

is_this_mine <- checking_dis_surveys %>% filter(!str_detect(meta, 'Value suppressed')) %>% 
  filter(!str_detect(meta, 'Value based on')) %>%
  select(indicator_id, country_id, year, meta) %>% distinct() %>% filter(str_detect(meta, 'GEMR'))

dis_extract <- checking_dis_surveys %>% filter(!str_detect(meta, 'Value suppressed')) %>% 
  filter(!str_detect(meta, 'Value based on')) %>%
  select(indicator_id, country_id, year, meta) %>% distinct() 


checking_sources <- uis_meta %>%  filter(str_detect(survey, 'other')) %>% select(iso_code3, year, meta)  %>% distinct()

checking_late_dhs <- uis_meta %>%  filter(str_detect(survey, 'DHS')) %>% filter(year >= 2017) %>% distinct()

checking_late_mics <- uis_meta %>%  filter(str_detect(survey, 'MICS')) %>% filter(year >= 2017) %>% distinct()

checking_late_per <- uis_meta %>%  filter(str_detect(iso_code3, 'PER')) %>% filter(year >= 2000) %>% distinct()

checking_late_dhs <- uis_meta %>%  filter(str_detect(survey, 'DHS'))   %>% distinct()
#oldest DHS is from 2000
checking_late_mics <- uis_meta %>%  filter(str_detect(survey, 'MICS'))   %>% distinct()
#oldest MICS BDI 1999 

wideleft <- uis_meta %>%  filter(str_detect(survey, 'Already in WIDE'))   %>% distinct()
#oldest MICS BDI 1999 

viewextract <- uis_meta %>%  filter(str_detect(survey, 'Ameer'))   %>% distinct()
#a TON

what

#Finding out new stuff 
uis_meta_seeother <- uis_meta %>% distinct() %>% filter(survey == 'other') %>% distinct()

whay <- uis4wide %>% filter((iso_code3 == 'TGO' & str_detect(indicator, 'comp_prim') & year == 2017 & survey == 'MICS' & category == 'Total' ))
#OMG 519 copies