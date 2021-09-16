# prelims -----------------------------------------------------------------

library(magrittr)
library(tidyverse)
library(countrycode)
library(dplyr)
library(vroom)
library(stringr)
library(purrr)
library(tidyr)

memory.limit(25000)
options(max.print=10000)

countries_unesco <- vroom::vroom('C:/Users/taiku/OneDrive - UNESCO/WIDE files/countries_unesco_2020.csv')

# last update uploaded ----------------------------------------------------

wide_jan19 <- vroom::vroom('C:/Users/taiku/OneDrive - UNESCO/WIDE files/WIDE_2021-01-28_v1.csv', guess_max = 900000) %>%
  mutate(Religion = replace(Religion, Religion == ".", NA))

wide_vars <- names(wide_jan19)
wide_outcome_vars <- names(select(wide_jan19, comp_prim_v2_m:slevel4_no))

wide_jan19_long <- 
  pivot_longer(wide_jan19, names_to = 'indicator', cols = any_of(wide_outcome_vars))

#library(foreign)
#write.dta(wide_jan19_long,'C:/Users/taiku/OneDrive - UNESCO/WIDE files/tests/previouswide.dta')

wide_jan19_long_clean <- 
  wide_jan19_long %>%
  mutate(value = case_when(
    survey == 'UWEZO' & str_detect(indicator, 'mlevel') ~ NA_real_,
    TRUE ~ value
  )) %>% 
  # drop learning assessments that haven't been re-mapped to MPL
  filter(!survey %in% c('UWEZO', 'SACMEQ', 'ASER')) %>% 
  filter(indicator != 'eduyears_2024_m') %>% 
  filter(!(iso_code == 'CHN' & str_detect(indicator, 'edu0'))) %>% 
  filter(!(survey == 'MICS' & year <= 2009 & 
          (str_detect(indicator, 'eduout') | str_detect(indicator, 'trans') | str_detect(indicator, 'comp')))) %>% 
  # drop regional aggregates, which will be recalculated
  filter(!is.na(iso_code)) %>% 
  rename(iso_code3 = iso_code) %>% 
  select(-country, -region_group, -income_group) 

#Today's test: fix with distinct
wide_jan19_long_clean <- wide_jan19_long_clean %>% distinct()
  

# GEMR Sept 2021 update from widetable new pipeline (MBR) -----------------------------------------------

widetable_sep21 <-
  vroom::vroom('C:/Users/taiku/OneDrive - UNESCO/WIDE files/widetable_summarized_10092021.csv', guess_max = 900000) %>%
    filter(year > 2017 & year < 2021 ) %>% 
  mutate(iso_code3 = countrycode::countrycode(country, 'country.name.en', 'iso3c')) %>% 
   rename_with(.fn = str_to_title, 
              .cols = any_of(c("sex", "location", "wealth", "region", "religion", "ethnicity")))  %>%
    select(iso_code3, any_of(wide_vars))  %>% distinct() %>%
    mutate(iso_code3 = ifelse(country =="CentralAfricanRepublic" , "CAR" , iso_code3)) %>%
    subset(country!="Kosovo" & country!="Kosovo_Comms") %>%
    mutate(Location = replace(Location, Location =="Camps" , NA )) %>%
    mutate(Location = replace(Location, Location =="Other" , "Rural") ) %>%
    mutate(Religion = replace(Religion, Religion =="" , NA )) 

widetable_woreligion <- widetable_sep21 %>%  filter(!category %in% c("Religion"))

widetable_religion <- widetable_sep21 %>%  filter(category %in% c("Religion")) %>% 
  filter( !is.na(Religion) )

widetable_sep21 <- bind_rows(widetable_woreligion,widetable_religion)     

widetable_sep21_long <- 
  pivot_longer(widetable_sep21, names_to = 'indicator', cols = any_of(wide_outcome_vars)) 

# clean
widetable_sep21_long_clean <- 
  widetable_sep21_long %>% 
  filter(!(iso_code3 == 'CHN' & str_detect(indicator, 'edu0') & year == 2016)) %>% 
  filter(survey != 'EU-SILC') %>% 
  select(-country)

#Today's test: fix with distinct
widetable_sep21_long_clean <- widetable_sep21_long_clean %>% distinct()


# GEMR Sept 2021 update from other surveys (national surveys such as CFPS) (MBR) -----------------------------------------------

nationalsurveys_sep21 <-
  read.csv('C:/Users/taiku/OneDrive - UNESCO/WIDE files/nationalsurveys.csv') %>%
  rename_with(
    .fn = ~ paste0(.x, '_m'),
    .cols = any_of(c(
      'comp_prim_v2', 'comp_lowsec_v2', 'comp_upsec_v2', 'comp_prim_1524', 'comp_lowsec_1524',
      'comp_upsec_2029', 'eduyears_2024', 'edu2_2024', 'edu4_2024', 'eduout_prim', 'eduout_lowsec',
      'eduout_upsec', 'comp_higher_2529', 'comp_higher_3034', 'attend_higher_1822', 'edu0_prim',
      'overage2plus', 'literacy_1549', 'comp_higher_2yrs_2529', 'comp_higher_4yrs_2529',
      'comp_lowsec_2024', 'comp_upsec_2024', 'preschool_1ybefore', 'preschool_3', 'comp_higher_4yrs_3034'))) %>%
  select(-ends_with(c("_dur","_age0","_age1")) ) %>%
  select(-starts_with(c("comp_lowsec_2024","comp_upsec_2024","literacy", "iso_code2", "no_attend")) ) %>% 
  rename_with(.fn = str_to_title, 
              .cols = any_of(c("sex", "location", "wealth", "region", "ethnicity"))) %>%
  filter(!iso_code3 %in% c("MEX")) %>% distinct()

nationalsurveys_sep21_long <-
  pivot_longer(nationalsurveys_sep21, names_to = 'indicator', cols = any_of(wide_outcome_vars))

#Today's test: fix with distinct
nationalsurveys_sep21_long <- nationalsurveys_sep21_long %>% distinct()

# learning update september 2021 ---------------------------------------------------
setwd("C:/Users/taiku/Documents/GEM UNESCO MBR/GitHub/wide2020/ilsa/data")
ilsa_mpl_set21_long <- 
  bind_rows(
    ilsa_mpl = vroom::vroom('update_mpl.csv'),
    pirls_mpl = vroom::vroom('pirls_mpl.csv'),
    pal_mpl = vroom::vroom('pal_mpl.csv'),
    pasec_mpl = vroom::vroom('pasec_mpl.csv'),
    pisa_mpl = vroom::vroom('pisa_mpl.csv'),
    pisad_mpl = vroom::vroom('pisad_mpl.csv'),
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
    'Eng/Afr/Zulu - RSA (5)', 'Madrid, Spain', 'Moscow City, Russian Fed.', 'Scotland', 'Western Cape, RSA (9)', 'England', 
    'Northern Ireland', 'Taiwan, Province of China', 'Kosovo', 'Chinese Taipei', 'Gauteng, RSA (9)', 'Canada, Nova Scotia',
    'Iceland (5th grade)', 'Maltese-Malta', 'Norway (5th grade)', 'Norway (4 th grade)', 'Morocco 6', 'Connecticut (USA)',
    'Florida (USA)', 'Perm(Russian Federation)', 'Shanghai-China', 'Massachusetts (USA)'
  )) %>% 
  mutate(iso_code3 = countrycode::countrycode(COUNTRY, 'country.name.en', 'iso3c')) %>% 
  filter(!is.na(iso_code3)) %>% 
  select(-COUNTRY, -iso_num)

ilsa_mpl_set21_long_clean <- 
  ilsa_mpl_set21_long %>% 
  mutate(new_level= case_when(
    survey == 'PISA' | survey== "PISA-D" ~ 'end of lower secondary', 
    survey == 'SEA-PLM'  ~ 'end of primary',
    survey == 'TERCE' & grade == 3 ~ 'early grades',
    survey == 'TERCE' & grade == 6 ~ 'end of primary',
    survey == 'PASEC' & grade == 2 ~ 'early grades',
    survey == 'PASEC' & grade == 6 ~ 'end of primary',
    survey == 'TIMSS' & grade == 4 & iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'early grades',
    survey == 'PIRLS' & grade == 4 & iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'early grades',
    survey == 'TIMSS' & grade == 4 & !iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'end of primary',
    survey == 'PIRLS' & grade == 4 & !iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'end of primary',
    survey == 'TIMSS' & grade == 8 ~ 'end of lower secondary')) %>% 
    select(-level, -grade ) %>% 
    rename(level=new_level)

#Today's test: fix with distinct
ilsa_mpl_set21_long_clean <- ilsa_mpl_set21_long_clean %>% distinct()

#setwd("C:/Users/taiku/OneDrive - UNESCO/WIDE files/")

#write_csv(ilsa_mpl_set21_long_clean, 'ilsa.csv', na = '')

# UIS update (Sep 2020 release) -------------------------------------------

# actually run uis2wide.R
#added a duplicates drop there

# EU-SILC -----------------------------------------------------------------

#silc_old <-
#  vroom::vroom('EU_SILC_May31.csv')

silc_new <- 
  vroom::vroom('C:/Users/taiku/OneDrive - UNESCO/WIDE files/EU_SILC_Jan26_censored.csv') %>% 
  rename(preschool_1ybefore_m = preschool_1ybefore) %>% 
  mutate(iso_code = countrycode::countrycode(country, 'country.name.en', 'iso3c')) %>% 
  mutate(Location = replace(Location, Location =="Intermediate or densely populated area" , "Urban") ) %>%
  mutate(Location = replace(Location, Location =="Thinly populated area" , "Rural") ) %>%
  select(any_of(wide_vars))  %>% 
  rename(iso_code3 = iso_code)

silc_long <-
  pivot_longer(silc_new, names_to = 'indicator', cols = any_of(wide_outcome_vars))

silc_long_clean <- 
  silc_long %>% 
  select(-country)


#Today's test: fix with distinct
silc_long_clean <- silc_long_clean %>% distinct()


# LIS (including latest update) ---------------------------------------------------------------------

lis_old <- 
  readxl::read_xlsx('C:/Users/taiku/OneDrive - UNESCO/WIDE files/LIS_indicators_v3.xlsx', na = '.') %>% 
  select(-Ctry, -a...10, -a...25) %>% 
  rename_with(
    .fn = ~ paste0(.x, '_m'), 
    .cols = any_of(c(
      'comp_prim_v2', 'comp_lowsec_v2', 'comp_upsec_v2', 'comp_prim_1524', 'comp_lowsec_1524',
      'comp_upsec_2029', 'eduyears_2024', 'edu2_2024', 'edu4_2024', 'eduout_prim', 'eduout_lowsec',
      'eduout_upsec', 'comp_higher_2529', 'comp_higher_3034', 'attend_higher_1822', 'edu0_prim',
      'overage2plus', 'literacy_1549', 'comp_higher_2yrs_2529', 'comp_higher_4yrs_2529',
      'comp_lowsec_2024', 'comp_upsec_2024', 'preschool_1ybefore', 'preschool_3', 'comp_higher_4yrs_3034'))) %>% 
  mutate(iso_code3 = countrycode::countrycode(Country, 'country.name.en', 'iso3c'), 
         survey = 'LIS') %>% 
  rename(comp_higher_4yrs_2529_m = comp_higher_2529_m, comp_higher_4yrs_2529_no = comp_higher_2529_no) %>% 
  select(-Country) %>% 
  # AUS appears twice in the file
  distinct

lis_new <- vroom::vroom('C:/Users/taiku/OneDrive - UNESCO/WIDE files/indicators_LIS_1009.csv')  %>% 
  mutate(iso_code3 = countrycode::countrycode(country, 'country.name.en', 'iso3c'), 
         survey = 'LIS') %>%
      rename_with(
      .fn = ~ paste0(.x, '_m'), 
       .cols = any_of(c(
      'comp_higher_2529', 'comp_lowsec', 'comp_prim', 'comp_upsec', 'comp_prim_1524', 'comp_lowsec_1524',
      'comp_upsec_2029', 'eduyears_2024', 'edu0_prim', 'eduout_prim', 'eduout_lowsec',
      'eduout_upsec', 'literacy_1524'))) %>%
      select(-eracy_1524_no,-'_noliteracy_1524')  %>% 
     rename(eduout_prim_no=edu_out_pry_no,
            eduout_lowsec_no = edu_out_lowsec_no,
            eduout_upsec_no = edu_out_upsec_no,
            comp_prim_v2_m = comp_prim_m,
            comp_lowsec_v2_m = comp_lowsec_m,
            comp_upsec_v2_m = comp_upsec_m,
            comp_prim_v2_no = comp_prim_no,
            comp_lowsec_v2_no = comp_lowsec_no,
            comp_upsec_v2_no = comp_upsec_no, 
            comp_higher_2yrs_2529_m = comp_higher_2529_m,
            comp_higher_2yrs_2529_no = comp_higher_2529_no,
            Sex=sex, Wealth=wealth, Region=region, Ethnicity=ethnicity, Location=location)

lis_all <- bind_rows(lis_old,lis_new) %>% 
  mutate(Wealth = replace(Wealth, Wealth =="1" , "Quintile 1") ) %>%
  mutate(Wealth = replace(Wealth, Wealth =="2" , "Quintile 2") ) %>%
  mutate(Wealth = replace(Wealth, Wealth =="3" , "Quintile 3") ) %>%
  mutate(Wealth = replace(Wealth, Wealth =="4" , "Quintile 4") ) %>%
  mutate(Wealth = replace(Wealth, Wealth =="5" , "Quintile 5") )  %>%
  mutate(Location = replace(Location, Location =="Not rural" , "Urban") ) %>%
  mutate(Sex = replace(Sex, Sex =="female" , "Female") )  %>%
  mutate(Sex = replace(Sex, Sex =="male" , "Male") )  %>%
  mutate(survey = "LIS")
  
#setwd("C:/Users/taiku/OneDrive - UNESCO/WIDE files/")

#write_csv(lis_all, 'LIS_full.csv', na = '')

lis_long <- 
  pivot_longer(lis_all, names_to = 'indicator', cols = any_of(wide_outcome_vars))


#Today's test: fix with distinct
lis_long <- lis_long %>% distinct()

# combine-time with tags -------------------------------------------------------

addifnew_wflag <- function(df_priority, df_ifnew, byvars, flag) {
  df_2add <- 
    anti_join(df_ifnew, df_priority, by = byvars) %>% 
    mutate(source = flag)
  bind_rows(df_priority, df_2add)
}

#Prepare computer for potential memory issue
#rm(widetable_sep21)
#rm(disaggs_uis)
#rm(ilsa_mpl_set21_long,lis_new,lis_old,lis_all)
#rm(silc_new,silc_long,nationalsurveys_sep21)
#rm(wide_jan19,wide_jan19_long)

wide_21_long_wflag <- 
  wide_jan19_long_clean %>%
  mutate(source = 'WIDE online 2021') %>% 
  addifnew_wflag(uis4wide, c('iso_code3', 'survey', 'year', 'indicator'), 'UIS 2021') 

#write_csv(wide_21_long_wflag, 'widetest', na = '')


wide_21_long_wflag <- 
  wide_21_long_wflag %>%
  addifnew_wflag(nationalsurveys_sep21_long, c('iso_code3', 'survey', 'year', 'indicator'), 'MB National surveys') 

wide_21_long_wflag <- 
  wide_21_long_wflag %>%
  addifnew_wflag(widetable_sep21_long, c('iso_code3', 'survey', 'year', 'indicator' ), 'MB widetable') 

wide_21_long_wflag <- 
  wide_21_long_wflag %>% 
  filter(survey != "EU-SILC") %>% 
  bind_rows(mutate(silc_long_clean, source = 'SILC censored'))

wide_21_long_wflag <- 
  wide_21_long_wflag %>% 
  bind_rows(mutate(lis_long, source = 'LIS'))

wide_21_long_wflag <- 
  wide_21_long_wflag %>%
  filter(!str_detect(indicator, 'level')) %>% 
  bind_rows(mutate(ilsa_mpl_set21_long_clean, source = 'Learning DC Jan 2021')) %>% 
  identity

#rm(gemr_sep21_long_clean,ilsa_mpl_set21_long_clean,nationalsurveys_sep21_long,silc_long_clean,widetable_sep21_long)
#rm(lis_long,wide_jan19_long_clean)

todrop <- 
  wide_21_long_wflag %>% 
  filter(!is.na(value)) %>%
  distinct(iso_code3, survey, source, year, indicator) %>% 
  mutate(year_p1 = year + 1, year_m1 = year - 1) %>% 
  bind_rows(
  {left_join(., filter(., source == 'UIS 2021'), by = c('iso_code3', 'survey', 'year' = 'year_p1'),
             suffix = c('', '_uis'))},
  {left_join(., filter(., source == 'UIS 2021'), by = c('iso_code3', 'survey', 'year' = 'year_m1'),
             suffix = c('', '_uis'))},
  ) %>% 
  filter(!is.na(year_uis)) %>% 
  filter(source != source_uis) %>% 
  select(-year_m1, -year_p1, -year_m1_uis, -year_p1_uis) %>% 
  arrange(iso_code3, survey) %>% 
  mutate(year_todrop = ifelse(source %in% c('MB widetable','LIS') , year_uis, year)) %>%
  distinct(iso_code3, survey, year = year_todrop, indicator) %>%
  data.frame

source_count <- 
  wide_21_long_wflag %>% 
  filter(!is.na(value)) %>% 
  mutate(source_institution = ifelse(source == 'UIS 2021', source, 'GEMR')) %>%
  distinct(iso_code3, survey, year, indicator, source, source_institution) %>%
  anti_join(todrop, by = c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  group_by(iso_code3, survey, year) %>% 
  mutate(distinct_instsources = n_distinct(source_institution)) %>% 
  ungroup

single_source <- 
  source_count %>% 
  filter(distinct_instsources == 1) %>% 
  distinct(iso_code3, survey, year, source, source_institution) %>% 
  group_by(iso_code3, survey, year, source_institution) %>% 
  filter(!'MB widetable' %in% source) %>%
  select(-source) %>% 
  filter(!survey %in% c('EU-SILC', 'PIRLS', 'PISA', 'TIMSS', 'PASEC')) %>% 
  arrange(iso_code3, survey, year) %>% 
  group_by(iso_code3, survey, source_institution) %>% 
  summarize(year = 
    str_remove(paste(min(year), if (length(year) > 1) {max(year)} else {NULL}, sep = '-'), '-$')
  ) %>% 
  ungroup %>% 
  identity

write.csv(single_source, 'C:/Users/taiku/OneDrive - UNESCO/WIDE files/single_sources_for_metadata.csv')

multi_source <- 
  source_count %>% 
  filter(distinct_instsources > 1) %>% 
  distinct(iso_code3, survey, year, indicator, source, source_institution) %>% 
  filter(source != 'MB widetable') %>%
  arrange(iso_code3, survey, year, indicator) %>% 
  ungroup %>% 
  select(-source_institution) %>%
  pivot_wider(names_from = 'indicator', values_from = 'source') %>%
  identity

write.csv(multi_source, 'additional_sources_for_metadata.csv')

rm(multi_source,single_source)

# combining ---------------------------------------------------------------

addifnew <- function(df_priority, df_ifnew, byvars) {
  df_2add <- anti_join(df_ifnew, df_priority, by = byvars)
  bind_rows(df_priority, df_2add)
}

wide_21_long <- 
  wide_jan19_long_clean %>%
  addifnew(uis4wide, c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  addifnew(nationalsurveys_sep21_long, c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  #addifnew(widetable_sep21_long_clean, c('iso_code3', 'survey', 'year')) %>% 
  addifnew(lis_long, c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  filter(survey != "EU-SILC") %>% 
  bind_rows(silc_long_clean) %>% 
  filter(!str_detect(indicator, 'level')) %>% 
  bind_rows(ilsa_mpl_set21_long_clean) %>% 
  # drop redundancies due to different year labels
  anti_join(todrop, by = c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  identity

#saveRDS(wide_21_long_wflag, file = "prepivot.RDS") 

# write_rds(wide_21_long, 'wide_21_long.rds')
#setwd("C:/Users/taiku/OneDrive - UNESCO/WIDE files/")
#qs::qsave(wide_21_long_wflag, 'wide_21_long.qs')
#write_csv(wide_21_long_wflag,"wide_21_long.csv")

#Before running this, run update_income.R to get regions 
wide_21_long <- 
  wide_21_long %>% 
  rename(iso_code = iso_code3) %>% 
  select(any_of(wide_vars), indicator, value) %>% 
  inner_join(select(countries_unesco, iso_code = iso3c, country = country_fig), by = 'iso_code') %>% 
  left_join(select(regions, iso_code = iso3c, region_group = SDG.region, income_group), 
            by = 'iso_code') %>% 
  #Bad estimates will be filtered once I see the final output
  #filter_bad_estimates %>% 
  identity
  
wide_21_long <- 
  wide_21_long %>% select(-country.x) %>% rename(country=country.y)

#Now run checks.R to get the functions
wide_21_long %>% check_countries

#Impute and check_* function comes from checks.R
wide4upload_long <- 
  wide_21_long %>% 
  check_completeness %>% 
  check_samplesize %>% 
  check_categories %>% 
  mutate(value = round(value, 4)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') %>% 
  impute_prim_from_sec %>% 
  pivot_longer(names_to = 'indicator', values_to = 'value', cols = any_of(wide_outcome_vars)) %>% 
  # mutate(level = ifelse(!is.na(grade) & grade == 8, 'lower secondary', level)) %>% 
  #filter(!(survey == 'EU-SILC' & year >= 2016 & str_detect(category, 'Wealth'))) %>% 
  #filter(!(survey == 'CASEN' & year == 2000)) %>% 
  #filter(!(iso_code == 'IND' & year == 2006 & survey == 'DHS')) %>% 
  #filter(!(iso_code == 'SOM' & year == 2011 & survey == 'MICS')) %>% 
  #filter(!(iso_code == 'URY' & year == 2019 & survey == 'ECH')) %>% 
  group_by(iso_code, year, survey, indicator) %>% 
  filter("Total" %in% category) %>% 
  ungroup

  #Now run aggregate.R
wide_21_2agg <- 
  wide4upload_long %>% 
  filter(category %in% cats2agg) %>% 
  filter(!str_detect(indicator, 'level')) %>% 
  select(-level, -grade, -Region, -Ethnicity, -Religion, -Language) %>% 
  group_by(iso_code, indicator) %>% 
  filter(year == max(year) & max(year) >= 2010) %>% 
  filter(survey == first(survey)) %>% 
  ungroup %>% 
  left_join(weights, by = c('iso_code', 'indicator')) %>% 
  filter(!is.na(wt_value), !is.na(value)) 

wide_21_2agg %>% 
  group_by(category, region_group, income_group, indicator) %>% 
  summarize(lag = weighted.mean(2020 - year, wt_value)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'lag')

# AGG AND WEIGHT TEST

test_long_aggs <- 
  myagg_outer(wide_21_2agg) %>% 
  keep_threshold %>% 
  mutate(value = ifelse(str_detect(indicator, '_no'), 1, value))

test_long_aggs %>% 
  unite('region', income_group, region_group) %>% 
  select(-value) %>% 
  pivot_wider(names_from = 'region', values_from = 'weight_share') %>% 
  filter(!str_detect(indicator, '_no')) %>% 
  write_csv('reg_aggs.csv')

#

wide4upload_long_aggs <- 
  myagg_outer(wide_21_2agg) %>% 
  apply_threshold %>% 
  mutate(value = ifelse(str_detect(indicator, '_no'), 1, value))

wide4upload <- 
  bind_rows(
    wide4upload_long,
    wide4upload_long_aggs
  ) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') %>% 
  select(any_of(wide_vars))

wide4upload %>% 
  check_completion_progression %>% 
  filter(category == 'Total') %>% 
  arrange(desc(pmax(comp_lowsec_v2_m - comp_prim_v2_m, comp_upsec_v2_m - comp_lowsec_v2_m)))

wide4upload %>% summary
setwd("C:/Users/taiku/OneDrive - UNESCO/WIDE files/")

write_csv(wide4upload, 'wide4upload.csv', na = '')
