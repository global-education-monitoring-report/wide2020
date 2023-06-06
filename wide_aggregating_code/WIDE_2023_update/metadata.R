#THIS IS FOR METADATA 

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
beep()

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
