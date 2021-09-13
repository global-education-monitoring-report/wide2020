# prelims -----------------------------------------------------------------

library(magrittr)
library(tidyverse)
library(countrycode)
library(dplyr)
library(vroom)
library(stringr)
library(purrr)
library(tidyr)


countries_unesco <- vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/countries_unesco_2020.csv')

# last update uploaded ----------------------------------------------------

wide_jan19 <- vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/WIDE_2021-01-25_v2.csv')

wide_vars <- names(wide_jan19)
wide_outcome_vars <- names(select(wide_jan19, comp_prim_v2_m:slevel4_no))

wide_jan19_long <- 
  pivot_longer(wide_jan19, names_to = 'indicator', cols = any_of(wide_outcome_vars))

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
  
table(wide_jan19_long_clean$indicator)
# GEMR Sept 2021 update from widetable new pipeline (MBR) -----------------------------------------------

widetable_sep21 <- 
  vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/widetable_summarized_10092021.csv') %>%
   mutate(iso_code3 = countrycode::countrycode(country, 'country.name.en', 'iso3c')) %>% 
    filter(year > 2017 & year < 2021 ) %>% 
    select(iso_code3, any_of(wide_vars))

widetable_sep21_long <- 
  pivot_longer(widetable_sep21, names_to = 'indicator', cols = any_of(wide_outcome_vars))

# # some surveys are mis-scaled
# gemr_jan21_long %>% 
#   filter(indicator == 'comp_prim_v2_m') %>% 
#   group_by(survey) %>% 
#   summarize(maxval = max(value, na.rm = TRUE)) %>% 
#   data.frame
# 
# gemr_jan21_long %>% 
#   filter(indicator == 'comp_prim_v2_m', survey %in% c('DHS', 'MICS')) %>% 
#   group_by(iso_code3) %>% 
#   summarize(maxval = max(value, na.rm = TRUE)) %>% 
#   data.frame
# 
# check_completion_progression(gemr_jan21) %>% 
#   filter(category == 'Total')

# clean
gemr_sep21_long_clean <- 
  widetable_sep21_long %>% 
  filter(!(iso_code3 == 'CHN' & str_detect(indicator, 'edu0') & year == 2016)) %>% 
  filter(survey != 'EU-SILC') %>% 
  select(-country)

table(gemr_sep21_long_clean$indicator)

# GEMR Sept 2021 update from other surveys (national surveys such as CFPS) (MBR) -----------------------------------------------

nationalsurveys_sep21 <- 
  vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/nationalsurveys.csv') %>%
  rename_with(
    .fn = ~ paste0(.x, '_m'), 
    .cols = any_of(c(
      'comp_prim_v2', 'comp_lowsec_v2', 'comp_upsec_v2', 'comp_prim_1524', 'comp_lowsec_1524',
      'comp_upsec_2029', 'eduyears_2024', 'edu2_2024', 'edu4_2024', 'eduout_prim', 'eduout_lowsec',
      'eduout_upsec', 'comp_higher_2529', 'comp_higher_3034', 'attend_higher_1822', 'edu0_prim',
      'overage2plus', 'literacy_1549', 'comp_higher_2yrs_2529', 'comp_higher_4yrs_2529',
      'comp_lowsec_2024', 'comp_upsec_2024', 'preschool_1ybefore', 'preschool_3', 'comp_higher_4yrs_3034'))) %>% 
  filter(country=="China") %>%
  select(-ends_with(c("_dur","_age0","_age1")) ) %>%
  select(-starts_with(c("comp_lowsec_2024","comp_upsec_2024","literacy", "iso_code2", "no_attend")) )

  nationalsurveys_sep21_long <- 
  pivot_longer(nationalsurveys_sep21, names_to = 'indicator', cols = any_of(wide_outcome_vars))
  
  table(nationalsurveys_sep21_long$indicator)
  

# learning update september 2021 ----------------------------------------------------

setwd("C:/Users/mm_barrios-rivera/Documents/GitHub/wide2020/ilsa/data")
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
    'Eng/Afr/Zulu – RSA (5)', 'Madrid, Spain', 'Moscow City, Russian Fed.', 'Scotland', 'Western Cape, RSA (9)', 'England', 
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
    survey == 'PISA' ~ 'end of lower secondary', 
    survey == 'SEA-PLM'  ~ 'end of primary',
    survey == 'TERCE' & grade == 3 ~ 'early grades',
    survey == 'TERCE' & grade == 6 ~ 'end of primary',
    survey == 'PASEC' & grade == 2 ~ 'early grades',
    survey == 'PASEC' & grade == 6 ~ 'end of primary',
    survey == 'TIMSS|PIRLS' & grade == 4 & iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'early grades',
    survey == 'TIMSS|PIRLS' & grade == 4 & !iso_code3 %in% c("AUS", "BWA", "DNK", "ISL", "NOR", "ZAF","IRL") ~ 'end of primary',
    survey == 'TIMSS' & grade == 8 ~ 'end of lower secondary'))


# UIS update (Sep 2020 release) -------------------------------------------

# actually run uis2wide.R

# uis2add <- 
#   uis4wide %>% 
#   anti_join(filter(wide_old_long, category == 'Total'), 
#             by = c('iso_code3', 'year')) %>% 
#   left_join(rename(regions, region_group = SDG.region), by = c('iso_code3' = 'COUNTRY_ID')) %>% 
#   rename(country = name)


# EU-SILC -----------------------------------------------------------------

#silc_old <-
#  vroom::vroom('EU_SILC_May31.csv')

silc_new <- 
  vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/EU_SILC_Jan26_censored.csv') %>% 
  rename(preschool_1ybefore_m = preschool_1ybefore) %>% 
  select(any_of(wide_vars))

silc_long <-
  pivot_longer(silc_new, names_to = 'indicator', cols = any_of(wide_outcome_vars))

silc_long_clean <- 
  silc_long %>% 
  select(-country)


# LIS (including latest update) ---------------------------------------------------------------------

lis_old <- 
  readxl::read_xlsx('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/LIS_indicators_v3.xlsx', na = '.') %>% 
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

lis_new <- vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/indicators_LIS_1009.csv')  %>% 
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
            comcomp_prim_m)

lis_all <- bind_rows(lis_old,lis_new)

lis_long <- 
  pivot_longer(lis_all, names_to = 'indicator', cols = any_of(wide_outcome_vars))



# combine-time with tags -------------------------------------------------------

addifnew_wflag <- function(df_priority, df_ifnew, byvars, flag) {
  df_2add <- 
    anti_join(df_ifnew, df_priority, by = byvars) %>% 
    mutate(source = flag)
  bind_rows(df_priority, df_2add)
}

#Prepare computer for potential memory issue
rm(widetable_sep21)
rm(disaggs_uis)
rm(ilsa_mpl_set21_long,lis_new,lis_old,lis_all)
rm(silc_new,silc_long,nationalsurveys_sep21)
rm(wide_jan19,wide_jan19_long)

wide_21_long_wflag <- 
  wide_jan19_long_clean %>%
  mutate(source = 'WIDE online 2021') %>% 
  addifnew_wflag(uis4wide, c('iso_code3', 'survey', 'year', 'indicator'), 'UIS 2021') %>% 
  addifnew_wflag(nationalsurveys_sep21_long, c('iso_code3', 'survey', 'year', 'indicator'), 'MB National surveys') %>% 
  addifnew_wflag(widetable_sep21_long, c('iso_code3', 'survey', 'year'), 'MB widetable') %>% 
  bind_rows(mutate(lis_long, source = 'LIS')) %>%
  filter(survey != "EU-SILC") %>% 
  bind_rows(mutate(silc_long_clean, source = 'SILC censoring')) %>% 
  filter(!str_detect(indicator, 'level')) %>% 
  bind_rows(mutate(ilsa_mpl_set21_long_clean, source = 'Learning DC Jan 2021')) %>% 
  identity

todrop <- 
  wide_21_long_wflag %>% 
  filter(!is.na(value)) %>%
  distinct(iso_code3, survey, source, year, indicator) %>% 
  mutate(year_p1 = year + 1, year_m1 = year - 1) %>% 
  bind_rows(
  {left_join(., filter(., source == 'UIS 2020'), by = c('iso_code3', 'survey', 'year' = 'year_p1'),
             suffix = c('', '_uis'))},
  {left_join(., filter(., source == 'UIS 2020'), by = c('iso_code3', 'survey', 'year' = 'year_m1'),
             suffix = c('', '_uis'))},
  ) %>% 
  filter(!is.na(year_uis)) %>% 
  filter(source != source_uis) %>% 
  select(-year_m1, -year_p1, -year_m1_uis, -year_p1_uis) %>% 
  arrange(iso_code3, survey) %>% 
  mutate(year_todrop = ifelse(source %in% c('WIDE online 2019', 'RV Mar 2019'), year_uis, year)) %>%
  distinct(iso_code3, survey, year = year_todrop, indicator) %>%
  data.frame

source_count <- 
  wide_21_long_wflag %>% 
  filter(!is.na(value)) %>% 
  mutate(source_institution = ifelse(source == 'UIS 2020', source, 'GEMR')) %>%
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
  filter(!'WIDE online 2019' %in% source) %>%
  select(-source) %>% 
  filter(!survey %in% c('EU-SILC', 'PIRLS', 'PISA', 'TIMSS', 'PASEC')) %>% 
  arrange(iso_code3, survey, year) %>% 
  group_by(iso_code3, survey, source_institution) %>% 
  summarize(year = 
    str_remove(paste(min(year), if (length(year) > 1) {max(year)} else {NULL}, sep = '-'), '-$')
  ) %>% 
  ungroup %>% 
  identity

write.csv(single_source, 'single_sources_for_metadata.csv')

multi_source <- 
  source_count %>% 
  filter(distinct_instsources > 1) %>% 
  distinct(iso_code3, survey, year, indicator, source, source_institution) %>% 
  filter(source != 'WIDE online 2019') %>%
  arrange(iso_code3, survey, year, indicator) %>% 
  ungroup %>% 
  select(-source_institution) %>%
  pivot_wider(names_from = 'indicator', values_from = 'source') %>%
  identity

write.csv(multi_source, 'additional_sources_for_metadata.csv')

# combining ---------------------------------------------------------------

addifnew <- function(df_priority, df_ifnew, byvars) {
  df_2add <- anti_join(df_ifnew, df_priority, by = byvars)
  bind_rows(df_priority, df_2add)
}

wide_21_long <- 
  wide_jan19_long_clean %>%
  addifnew(uis4wide, c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  addifnew(nationalsurveys_sep21_long, c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  addifnew(widetable_sep21_long, c('iso_code3', 'survey', 'year')) %>% 
  bind_rows(lis_long) %>%
  filter(survey != "EU-SILC") %>% 
  bind_rows(silc_long_clean) %>% 
  filter(!str_detect(indicator, 'level')) %>% 
  bind_rows(ilsa_mpl_set21_long_clean) %>% 
  # drop redundancies due to different year labels
  anti_join(todrop, by = c('iso_code3', 'survey', 'year', 'indicator')) %>% 
  identity

# write_rds(wide_21_long, 'wide_21_long.rds')
qs::qsave(wide_21_long, 'wide_21_long.qs')

#skip this for the moment
filter_bad_estimates <- function(df) {
    df %>% 
    mutate(value = ifelse(str_detect(indicator, 'preschool') &
                            (
                            (iso_code == 'SLV' & survey == 'EHPM') |
                            (iso_code == 'BOL' & survey == 'EH') |
                            (iso_code == 'BDI' & survey == 'MICS') |
                            (iso_code == 'TZA' & survey == 'HBS') |
                            (iso_code == 'MOZ' & survey == 'MICS') |
                            (iso_code == 'PAN' & survey == 'MICS') |
                            (iso_code == 'SSD' & survey == 'MICS') |
                            (iso_code == 'NOR' & survey == 'EU-SILC') |
                            (iso_code == 'VNM' & survey == 'HRS') |
                            FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'edu0') &
                            (
                              (iso_code == 'MOZ' & survey == 'AIS') |
                                (iso_code == 'SLV' & survey == 'EHPM') |
                                (iso_code == 'URY' & survey == 'ECH') |
                                (iso_code == 'COD' & survey == 'MICS' & year == 2018) |
                                (iso_code == 'CRI' & survey == 'MICS' & year == 2018) |
                                (iso_code == 'MKD' & survey == 'MICS' & year == 2018) |
                                (iso_code == 'VNM' & survey == 'HRS') |
                                FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'overage') &
                            (
                              (iso_code == 'URY' & survey == 'ECH') |
                                (iso_code == 'ARG' & survey == 'EPH') |
                                (iso_code == 'SOM' & survey == 'MICS' & year == 2011) |
                                FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'comp_prim') &
                            (
                              FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'eduout_prim') &
                            (
                              (iso_code == 'CHN' & year == 2016) |
                                FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'comp_lowsec') &
                            (
                              FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'eduout_lowsec') &
                            (
                              (iso_code == 'CHN' & year == 2016) |
                                FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'comp_upsec') &
                            (
                              (iso_code == 'TKM' & year == 2019)), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'eduout_upsec') &
                            (
                              FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'attend_higher') &
                            (
                              (iso_code == 'RUS' & survey == 'HSE') |
                              (iso_code == 'TUR' & survey == 'DHS' & year == 2004) |
                                FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'comp_higher') &
                            (
                              (iso_code == 'RUS' & survey == 'HSE') |
                                (iso_code == 'CAN' & survey == 'LIS' & year == 2013) |
                                (iso_code == 'BTN' & survey == 'MICS' & year == 2010) |
                                (iso_code == 'AFG' & survey == 'MICS' & year == 2015) |
                                (iso_code == 'GAB' & survey == 'DHS' & year == 2012) |
                                (iso_code == 'MMR' & survey == 'DHS' & year == 2016) |
                                (iso_code == 'NIC' & survey == 'DHS' & year == 2001) |
                                #
                                (iso_code == 'SOM' & survey == 'MICS' & year == 2011) |
                                (iso_code == 'ARG' & survey == 'EPH' & year == 2019) |
                                (iso_code == 'TON' & survey == 'MICS' & year == 2019) |
                                (iso_code == 'PER' & survey == 'ENAHO' & year == 2019) |
                                (iso_code == 'MEX' & survey == 'MICS' & year == 2015) |
                                (iso_code == 'NAM' & survey == 'NHIES' & year == 2015) |
                                (iso_code == 'TUR' & survey == 'DHS' & year == 2004) |
                                (iso_code == 'SSD' & survey == 'HFS') |
                                (iso_code == 'TZA' & survey == 'HBS') |
                                FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'edu2') &
                            (
                              (iso_code == 'SSD' & survey == 'HFS') |
                              FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'edu4') &
                            (
                              FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(str_detect(indicator, 'eduyears') &
                            (
                              (iso_code == 'ARG' & survey == 'EPH' & year == 2019) |
                                (iso_code == 'TON' & survey == 'MICS' & year == 2019) |
                                (iso_code == 'MKD' & survey == 'MICS' & year == 2019) |
                              FALSE), 
                          NA, value)) %>%
    mutate(value = ifelse(indicator %in% c('comp_lowsec_v2_m', 'comp_lowsec_1524_m') &
                            ((iso_code == 'CHE' & survey == 'EU-SILC' & year == 2009) |
                               (iso_code == 'BEL' & survey == 'EU-SILC' & year %in% c(2005, 2007)) |
                               (iso_code == 'TLS' & survey == 'DHS'     & year == 2009) |
                               (iso_code == 'FRA' & survey == 'EU-SILC' & year == 2013) |
                               (iso_code == 'LVA' & survey == 'EU-SILC' & year == 2005) |
                               (iso_code == 'SVN' & survey == 'EU-SILC' & year == 2005)), 
                          NA, value)) %>% 
    # TODO China 2016 OOS
    # mutate(value = ifelse(iso_code == 'CHN' & year == 2016 & indicator %in% c('eduout_prim_m', 'eduout_lowsec_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'MOZ' & survey == 'AIS' & indicator %in% c('edu0_prim_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'SLV' & survey == 'EHPM' & indicator %in% c('edu0_prim_m', 'preschool_1ybefore_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'URY' & survey == 'ECH' & indicator %in% c('edu0_prim_m', 'overage2plus_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'BOL' & survey == 'EH' & indicator %in% c('preschool_1ybefore_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'BDI' & survey == 'MICS' & indicator %in% c('preschool_1ybefore_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'TZA' & survey == 'HBS' & indicator %in% c('preschool_1ybefore_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code %in% c('MOZ', 'PAN', 'SSD') & survey == 'MICS' & indicator %in% c('preschool_1ybefore_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'NOR' & survey == 'EU-SILC' & indicator %in% c('preschool_1ybefore_m'), NA, value)) %>% 
    # mutate(value = ifelse(iso_code == 'RUS' & survey == 'HSE' & str_detect(indicator, 'higher'), NA, value)) %>% 
  # mutate(value = ifelse(iso_code == 'ARG' & survey == 'EPH' & str_detect(indicator, 'overage'), NA, value)) %>% 
  # mutate(value = ifelse(iso_code == 'COD' & survey == 'MICS' & year == 2018 & str_detect(indicator, 'edu0'), NA, value)) %>% 
  mutate(value = ifelse(iso_code == 'VNM' & survey == 'HRS', NA, value)) %>% 
  identity
}

wide_jan21_long_clean <- 
  wide_21_long %>% 
  rename(iso_code = iso_code3) %>% 
  select(any_of(wide_vars), indicator, value) %>% 
  inner_join(select(countries_unesco, iso_code = iso3c, country = country_fig), by = 'iso_code') %>% 
  left_join(select(regions, iso_code = iso3c, region_group = SDG.region, income_group), 
            by = 'iso_code') %>% 
  filter_bad_estimates %>% 
  identity
  
wide_jan21_long_clean %>% check_countries

wide4upload_long <- 
  wide_jan21_long_clean %>% 
  check_completeness %>% 
  check_samplesize %>% 
  check_categories %>% 
  mutate(value = round(value, 4)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') %>% 
  impute_prim_from_sec %>% 
  pivot_longer(names_to = 'indicator', values_to = 'value', cols = any_of(wide_outcome_vars)) %>% 
  # mutate(level = ifelse(!is.na(grade) & grade == 8, 'lower secondary', level)) %>% 
  filter(!(survey == 'EU-SILC' & year >= 2016 & str_detect(category, 'Wealth'))) %>% 
  filter(!(survey == 'CASEN' & year == 2000)) %>% 
  filter(!(iso_code == 'IND' & year == 2006 & survey == 'DHS')) %>% 
  filter(!(iso_code == 'SOM' & year == 2011 & survey == 'MICS')) %>% 
  filter(!(iso_code == 'URY' & year == 2019 & survey == 'ECH')) %>% 
  group_by(iso_code, year, survey, indicator) %>% 
  filter("Total" %in% category) %>% 
  ungroup
  

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

write_excel_csv(wide4upload, 'WIDE_2021-01-28_v1.csv', na = '')
