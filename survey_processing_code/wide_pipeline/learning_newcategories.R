
#NEW LEVELS FOR LEARNING INDICATORS CREATION 


library(magrittr)
library(tidyverse)
library(countrycode)


# learning update 2021 ----------------------------------------------------

setwd("C:/Users/taiku/Documents/GEM UNESCO MBR/GitHub/wide2020/ilsa/data")

ilsa_mpl_jan21_long <- 
  bind_rows(
    pirls_mpl = vroom::vroom('pirls_mpl.csv'),
    pisa_mpl = vroom::vroom('pisa_mpl.csv'),
    llece_mpl = vroom::vroom('llece_mpl.csv'),
    seaplm_mpl = vroom::vroom('sea-plm_mpl.csv'),
    timss19_mpl = vroom::vroom('timss19_mpl.csv'),
    timss_mpl = vroom::vroom('timss_mpl.csv') 
  ) %>% #filter(survey == 'PIRLS', category == 'Total') %>% pull(COUNTRY) %>% table
  mutate(category = str_replace(category, fixed('Language'), fixed('Speaks Language at Home'))) %>% 
  mutate(Wealth = ifelse(is.na(Wealth), NA_character_, paste('Quintile', Wealth))) %>% 
  pivot_longer(cols = mlevel1_m:slevel4_no, names_to = 'indicator', values_drop_na = TRUE) %>% 
  filter(!str_detect(indicator, '_se')) %>% 
  filter(!COUNTRY %in% c(
    'Abu Dhabi, UAE', 'Andalusia, Spain', 'Belgium (Flemish)', 'Belgium (French)',
    'Buenos Aires, Argentina', 'Canada, Ontario', 'Canada, Quebec', 'Canada, Alberta', 'Canada, British Columbia', 'Dubai,UAE',
    'Eng/Afr/Zulu – RSA (5)', 'Madrid, Spain', 'Moscow City, Russian Fed.', 'Scotland', 'Western Cape, RSA (9)', 'England', 
    'Northern Ireland', 'Taiwan, Province of China', 'Kosovo', 'Chinese Taipei', 'Gauteng, RSA (9)', 'Canada, Nova Scotia',
    'Iceland (5th grade)', 'Maltese-Malta', 'Norway (5th grade)', 'Norway (4 th grade)', 'Morocco 6', 'Connecticut (USA)',
    'Florida (USA)', 'Perm(Russian Federation)', 'Shanghai-China', 'Massachusetts (USA)'
  )) %>% 
  mutate(iso_code3 = countrycode::countrycode(COUNTRY, 'country.name.en', 'iso3c')) %>% 
  filter(!is.na(iso_code3)) %>% 
  select(-COUNTRY, -iso_num)

ilsa_mpl_jan21_long_clean <- 
  ilsa_mpl_jan21_long %>% 
  mutate(new_level= case_when(
    survey == 'PISA' ~ 'end of lower secondary', 
    survey == 'SEA-PLM'  ~ 'end of primary',
    survey == 'TERCE' & grade == 3 ~ 'early grades',
    survey == 'TERCE' & grade == 6 ~ 'end of primary',
    survey == 'PASEC' & grade == 2 ~ 'early grades',
    survey == 'PASEC' & grade == 6 ~ 'end of primary',
    survey == 'TIMSS|PIRLS' & grade == 4 & iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'early grades',
    survey == 'TIMSS|PIRLS' & grade == 4 & !iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'end of primary',
    survey == 'TIMSS' & grade == 8 ~ 'end of lower secondary'))

write.csv(ilsa_mpl_jan21_long_clean,"learning.csv")
