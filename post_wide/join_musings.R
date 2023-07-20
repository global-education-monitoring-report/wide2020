

bgd_extract_wideold <- wide_previous_long %>% select(survey, iso_code3, year, indicator, value, category, sex) %>% 
  filter(survey=='MICS' | survey == 'DHS') %>% 
  filter(iso_code3=='BGD') %>% filter(year== 2019) %>% distinct() 



bgd_extract_newcat <- newcategories_long %>% select(survey, iso_code, year, indicator, value, category, disability, hh_edu_head) %>% 
  filter(survey=='MICS' | survey == 'DHS') %>% 
  filter(iso_code=='BGD') %>% filter(year== 2019) %>% distinct() %>% rename(iso_code3=iso_code)

addifnew_wflag <- function(df_priority, df_ifnew, byvars, flag) {
  df_2add <- 
    anti_join(df_ifnew, df_priority, by = byvars) %>% 
    mutate(source = flag)
  bind_rows(df_priority, df_2add)
}

bgd_23_long <- bgd_extract_wideold %>%
  addifnew_wflag(bgd_extract_newcat, c('iso_code3', 'survey', 'year', 'indicator'), 'newcats')

#this is wrong 

bgd_23_long2 <- bgd_extract_wideold %>%
  addifnew_wflag(bgd_extract_newcat, c('iso_code3', 'survey', 'year', 'indicator', 'category'), 'newcats')

#this looks right 

bgd_23_long3 <-bind_rows(bgd_extract_wideold, bgd_extract_newcat)

#this is equivalent to 2

bgd_23_long4 <-full_join(bgd_extract_wideold, bgd_extract_newcat, by =  c('iso_code3', 'survey', 'year', 'indicator', 'category'))

#this creates "value.x" "value.y"

