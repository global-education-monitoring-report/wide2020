## put UIS disaggregated completion and OOS data into WIDE-compatible format for overwrite

library(dplyr)
library(vroom)
library(stringr)
library(purrr)

path2uisdata <- "C:/Users/mm_barrios-rivera/Documents/UIS_DATA/"

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
  filter(INDICATOR_ID == 'CR.1') %>% 
  select(iso_code3 = COUNTRY_ID, year = YEAR, meta = METADATA) %>% 
  mutate(survey = case_when(
    str_detect(meta, "MICS") ~ 'MICS',
    str_detect(meta, "DHS") ~ 'DHS',
    str_detect(meta, "HDS") ~ 'HDS',
    str_detect(meta, "PNAD") ~ 'PNAD',
    str_detect(meta, "CFPS") ~ 'CFPS',
    str_detect(meta, "CASEN") ~ 'CASEN',
    str_detect(meta, "CPS-ASEC") ~ 'CPS-ASEC',
    str_detect(meta, "Census|Recensement|Censo") ~ 'Census',
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
    TRUE ~ 'other'
  )) %>% 
  select(-meta)

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

uis4wide <- uis2wide(disaggs_uis) 
