#survey_path <- '/Users/bifouba/UNESCO/GEM Report - Documents/Data Repository/WIDE Data/raw_data/DHS/'
survey_path <- 'C:/Users/taiku/Desktop/Test'

library(countrycode)
library(tidyr)
library(purrr)

dirs <- 
  tibble(country = list.files(survey_path)) %>% 
  mutate(iso3c = countrycode::countrycode(country, 'country.name.en', 'iso3c')) %>% 
  # need to fix countries with missing spaces
  na.omit %>% 
  mutate(years = map(country, ~ list.files(paste0(survey_path, .x)))) %>% 
  group_by(country) %>% 
  mutate(
    source = map(years, ~ paste0(survey_path, '/', country, '/', .x)),
    target = map(years, ~ paste('DHS', iso3c, .x, sep = '_'))
  ) %>% 
  ungroup %>% 
  select(source, target) %>% 
  unnest(cols = c(source, target))

View(dirs)