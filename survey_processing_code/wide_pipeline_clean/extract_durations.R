#Extracting durations for 2022 from UIS data

#To process the new 2022 surveys 

#variables names
#299932	Theoretical duration of primary education (years)
#999976	Theoretical duration of lower secondary education (years)
#999978	Theoretical duration of upper secondary education (years)

#299905	Official entrance age to primary education (years)
#999975	Official entrance age to lower secondary education (years)
#999977	Official entrance age to upper secondary education (years)


#using national/ORPI csv files

library(tidyverse)
library(foreign)


#march update:
path2uisdata <- 'C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/UIS info/'


uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
    mutate(indicator_id = toupper(indicator_id))
}

indicators2extract <- c( '299932', '999976', '999978', '299905', '999975', '999977')

uis_extract <- 
  vroom::vroom(paste0(path2uisdata, 'OPRI_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>%
  uis_clean %>% select(-magnitude, -qualifier)
  #rid of gender and GPIA 

countrynames <- vroom::vroom(paste0(path2uisdata, 'countries_updated.csv'), na = '') %>% 
  rename(country_id=iso3c) %>%  select(country_id, annex_name) %>% rename(country=annex_name)

uis_duration_age <- uis_extract %>% #filter(year==2022) %>% 
  mutate(indicator = case_when(
  str_detect(indicator_id, '299932') ~ 'prim_dur_uis',
  str_detect(indicator_id, '999976') ~ 'lowsec_dur_uis' ,
  str_detect(indicator_id, '999978') ~ 'upsec_dur_uis',
  str_detect(indicator_id, '299905') ~ 'prim_age_uis',
  str_detect(indicator_id, '999975') ~ 'lowsec_age_uis' ,
  str_detect(indicator_id, '999977') ~ 'upsec_age_uis',  TRUE ~ NA )) %>% 
  select(-indicator_id) %>%
  left_join(countrynames, by = 'country_id') %>%
  pivot_wider(names_from = 'indicator') %>% rename(iso_code3=country_id) %>% 
  relocate(iso_code3, country, year, prim_dur_uis, lowsec_dur_uis, upsec_dur_uis, prim_age_uis, lowsec_age_uis, upsec_age_uis) %>%
  arrange(iso_code3, year)


#put today's date 
write.dta(uis_duration_age, "C:/ado/personal/UIS_duration_age_04072023.dta")
