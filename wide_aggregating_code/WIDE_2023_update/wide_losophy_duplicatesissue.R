# some experiments with the past to understand the duplicates issue

#run uis4wide_raw


#path2uisdata <- '~/Documents/UIS2020/'
path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS2020_tocheck/'


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
  vroom::vroom(paste0(path2uisdata, 'SDG/SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(INDICATOR_ID, paste(indicators2disagg, collapse = '|'))) %>% 
  filter(!str_detect(INDICATOR_ID, 'PIA'), !str_detect(INDICATOR_ID, fixed('1t'))) %>% 
  uis_clean

uis_meta <- 
  vroom::vroom(paste0(path2uisdata, 'SDG/SDG_METADATA.csv'), na = '') %>% 
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
names(uis4wide)
#then use append.R to load gemr_jan21long

gemr_jan21 <- 
  vroom::vroom('C:/Users/taiku/Documents/GEM UNESCO MBR/OUTPUT WIDE update/collapsed_output/output2001.csv') %>%
  # some renaming is necessary
  rename(Wealth = wealth, Sex = sex, Location = location, 
         Region = region, Ethnicity = ethnicity, Religion = religion) %>% 
  rename_with(
    .fn = ~ paste0(.x, '_m'), 
    .cols = any_of(c(
      'comp_prim_v2', 'comp_lowsec_v2', 'comp_upsec_v2', 'comp_prim_1524', 'comp_lowsec_1524',
      'comp_upsec_2029', 'eduyears_2024', 'edu2_2024', 'edu4_2024', 'eduout_prim', 'eduout_lowsec',
      'eduout_upsec', 'comp_higher_2529', 'comp_higher_3034', 'attend_higher_1822', 'edu0_prim',
      'overage2plus', 'literacy_1549', 'comp_higher_2yrs_2529', 'comp_higher_4yrs_2529',
      'comp_lowsec_2024', 'comp_upsec_2024', 'preschool_1ybefore', 'preschool_3', 'comp_higher_4yrs_3034'))) %>% 
  select(iso_code3, any_of(wide_vars))

#also this 
wide_jan19 <- vroom::vroom('WIDE_2019-01-23.csv')

wide_vars <- names(wide_jan19)
wide_outcome_vars <- names(select(wide_jan19, comp_prim_v2_m:slevel4_no))

wide_jan19_long <- 
  pivot_longer(wide_jan19, names_to = 'indicator', cols = any_of(wide_outcome_vars))

###################################################################################

#now take a sample of the duplicates like female mongolia mics 2018 


mng_uis4wide <- uis4wide %>% filter(iso_code3 == 'MNG' & survey == 'MICS' & year == 2018 & Sex == 'Female' & category == 'Sex')
mng_myshit <- gemr_jan21_long %>% filter(iso_code3 == 'MNG' & survey == 'MICS' & year == 2018 & Sex == 'Female' & category == 'Sex') %>%
  #we going to introduce a difference in the number to see what happens
  mutate(value = case_when(
    category == 'Sex'  ~ 1, TRUE ~ 1  )) %>%
  mutate(level='lowsec') %>%
  filter(!str_detect(indicator, 'level')) 
  
#mongoliafemalescr1_e <- eurekaihopeso %>% filter(iso_code3 == 'MNG' & survey == 'MICS' & year == 2018 & Sex == 'Female')
mng_antijoining <-   mng_uis4wide %>%
  addifnew(mng_myshit, c('iso_code3', 'survey', 'year'))
##when using this, it only adds columns to the same 6 observations, this was done with my file
mng_antijoining_alt <-   mng_uis4wide %>%
  addifnew(mng_myshit, c('iso_code3', 'survey', 'year', 'indicator')) 
##when using this, they actually add the indicators in myshit

#recreate the pivoting 
what <- mng_antijoining %>%
  mutate(value = round(value, 4)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') %>% 
  pivot_longer(names_to = 'indicator', values_to = 'value', cols = any_of(wide_outcome_vars)) %>%
  pivot_wider(names_from = 'indicator', values_from = 'value')
#no duplicates, only has uis indicators
what_alt <- mng_antijoining_alt %>%
  mutate(value = round(value, 4)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') %>% 
  pivot_longer(names_to = 'indicator', values_to = 'value', cols = any_of(wide_outcome_vars)) %>%
  pivot_wider(names_from = 'indicator', values_from = 'value')
#no duplicates, but has an extra line with level=="" that has the new indicators from myshit