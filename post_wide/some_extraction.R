library("readxl")
library(tidyverse)
library(ggplot2)
library(haven)
library(tidyr)
library(stringr)
library("writexl")
library(openxlsx)
library(xlsx)



# This to make WIDE and VIEW extract for someone (?)


path2pieces <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/WIDE_2023_files/" 

cleanwide <- haven::read_dta(paste0(path2pieces,"WIDE_2023_sept.dta")) 

#get LOW AND LOWER MIDDLE COUNTRIES GROUP
regions <-
  readr::read_csv("C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/regions.csv", col_types = readr::cols()) %>%
  dplyr::mutate(iso2c = ifelse(annex_name == "Namibia", "NA", iso2c)) %>%
  select(-income_group, -income_subgroup) %>%
  left_join(by = 'iso3c',
            {wbstats::wb_countries() %>%
                select(iso3c, income_level) %>%
                mutate(income_group = income_level) %>%
                filter(income_level != 'Aggregates') %>%
                select(-income_level)}
  )

relevantcountries <- regions %>% select(full_name, iso3c, income_group) %>%
  filter(income_group=='Lower middle income'|income_group=='Low income') %>% rename(iso_code=iso3c)


# •	WIDE: out-of-school by up to two dimensions
#assuming all levels


eduout <- cleanwide %>% select(iso_code, country, survey, year, category, sex, location, wealth, region, ethnicity, religion, disability, hh_edu_head,
                               eduout_prim_m, eduout_lowsec_m, eduout_upsec_m, eduout_prim_no, eduout_lowsec_no, eduout_upsec_no ) %>%
          filter(if_any(c( eduout_prim_m, eduout_lowsec_m, eduout_upsec_m, eduout_prim_no, eduout_lowsec_no, eduout_upsec_no ), complete.cases)) %>%
          group_by(iso_code, survey) %>% 
          filter(year == max(year) & max(year) >= 2010) %>%
          mutate(countcategories = str_count(category, pattern = '&')) %>%
          filter(!countcategories==2) %>% select(-countcategories, -eduout_prim_no, -eduout_lowsec_no, -eduout_upsec_no)

#check
#surveys <- eduout %>% select(survey, iso_code, year) %>% distinct

eduout_filtered <- inner_join(relevantcountries, eduout, c('iso_code')) %>% rename('Out of school - Primary'=eduout_prim_m, 'Out of school - Lower secondary'=eduout_lowsec_m, 
                                                                                   'Out of school - Upper secondary'=eduout_upsec_m, 'Household education'=hh_edu_head)
  
write_xlsx(eduout_filtered, "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/OOS_WIDE_extract.xlsx")



# •	WIDE: reading in grades 2/3 ------

reading <- cleanwide %>% select(iso_code, country, survey, year, category, level,  sex, location, wealth, region, ethnicity, religion, disability, hh_edu_head,
                                rlevel1_m, rlevel2_m, rlevel3_m, rlevel4_m) %>% 
  filter(if_any(c(rlevel1_m, rlevel2_m, rlevel3_m, rlevel4_m), complete.cases)) %>%
  #filter(level=='early grades' | level == 'end of primary') %>%
  filter(level == 'end of primary') %>%
  group_by(iso_code, survey) %>% 
  filter(year == max(year) & max(year) >= 2010) %>%
  mutate(countcategories = str_count(category, pattern = '&')) %>%
  filter(!countcategories==2) %>% select(-countcategories)

reading_filtered <-  inner_join(relevantcountries, reading, c('iso_code')) %>% rename('Household education'=hh_edu_head,"Low proficiency in reading"=rlevel1_m, 
                                                                                      "Minimum proficiency in reading"=rlevel2_m, "Medium proficiency in reading"=rlevel3_m,
                                                                                      "High proficiency in reading"=rlevel4_m) 
#%>%
  #select(-"Low proficiency in reading", -"High proficiency in reading", -"Medium proficiency in reading") %>%
  #drop_na("Minimum proficiency in reading")
  



write_xlsx(reading_filtered, "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/Reading_WIDE_extract_v2.xlsx")



# •	VIEW extraction  ------

completionVIEW <- read.xlsx("C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/Ameer/CR Results-20230828.xlsx", sheet = "Model Data") %>%
  filter(Type=="Country") %>% rename(iso_code=ISOalpha3, year=Time_Detail) %>%  filter( year %in% 2015:2022) %>%
  select(-Indicator, -Quantile, -Reporting.Type, -Units, -Nature, -SeriesID, -GeoAreaCode,-TimePeriod, -Source, -FootNote, -Location, -SeriesCode, -Type) %>%
  pivot_wider(names_from = Education.Level, values_from = Value) %>%
  rename('Completion rate primary'=PRIMAR, "Completion rate lower secondary"=LOWSEC, "Completion rate upper secondary" = UPPSEC, Category=Sex) %>%
  mutate(Category = case_when(
    Category == 'FEMALE' ~ 'Female',
    Category == 'MALE' ~ 'Male',
    Category == 'BOTHSEX' ~ 'Total'))
    
names(completionVIEW)

completionVIEW_f <- inner_join(relevantcountries, completionVIEW, c('iso_code'))

write_xlsx(missview_f, "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/ABCModel_CR_extract.xlsx")


MISS_VIEW <- read.xlsx("C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/Ameer/MISS Results (0223 + AFG Adjustment)-20230918.xlsx", sheet = "MISS Results") %>%
  select(-lower, -upper,-indicator) %>% rename(iso_code=country) %>%  filter( year %in% 2015:2022) %>%
  mutate(level = case_when(
    level == '1_prim' ~ 'Primary',
    level == '2_lsec' ~ 'Lower secondary',
    level == '3_usec' ~ 'Upper secondary',
    level == '4_all' ~ 'All levels')) %>%
  pivot_wider(names_from = level, values_from = value) %>% relocate(iso_code, year, sex)
  
names(MISS_VIEW)

missview_f <- inner_join(relevantcountries, MISS_VIEW, c('iso_code'))

write_xlsx(missview_f, "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/ABCModel_MISS_extract.xlsx")

oos_VIEW <- read.xlsx("C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/Ameer/OOS Results (0223 + AFG Adjustment)-20230918.xlsx", sheet = "OOS Results") %>%
  select(-lower, -upper,-indicator) %>% rename(iso_code=country) %>%  filter( year %in% 2015:2022) %>%
  mutate(level = case_when(
    level == '1_prim' ~ 'Primary',
    level == '2_lsec' ~ 'Lower secondary',
    level == '3_usec' ~ 'Upper secondary',
    level == '4_all' ~ 'All levels')) %>%
  pivot_wider(names_from = level, values_from = value) %>% relocate(iso_code, year, sex)

missview_f <- inner_join(relevantcountries, oos_VIEW, c('iso_code'))

write_xlsx(missview_f, "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/ABCModel_OOS_extract.xlsx")

