# Update income groups
setwd("C:/Users/Lenovo PC/OneDrive - UNESCO/WIDE files/")
library(wbstats)

#this generates only HIGH LOW AND MIDDLE income 
# regions <-
#   readr::read_csv("regions.csv", col_types = readr::cols()) %>%
#   dplyr::mutate(iso2c = ifelse(annex_name == "Namibia", "NA", iso2c)) %>%
#   select(-income_group, -income_subgroup) %>%
#   left_join(by = 'iso3c',
#             {wbstats::wb_countries() %>%
#              select(iso3c, income_level) %>%
#              mutate(income_group = stringr::str_to_title(stringr::str_remove_all(income_level, " income|Lower |Upper ")),
#                     income_subgroup = ifelse(stringr::str_detect(income_level, 'middle'), stringr::str_remove(income_level, " income"), NA)) %>%
#              filter(income_level != 'Aggregates') %>%
#              select(-income_level)}
#             )
###RUN THIS
### run this to get both lower middle and upper middle income instead 

regions <-
  readr::read_csv("regions.csv", col_types = readr::cols()) %>%
  dplyr::mutate(iso2c = ifelse(annex_name == "Namibia", "NA", iso2c)) %>%
  select(-income_group, -income_subgroup) %>%
  left_join(by = 'iso3c',
            {wbstats::wb_countries() %>%
                select(iso3c, income_level) %>%
                mutate(income_group = income_level) %>%
                filter(income_level != 'Aggregates') %>%
                select(-income_level)}
  )
