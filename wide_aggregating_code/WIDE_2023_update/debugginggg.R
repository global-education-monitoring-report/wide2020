
####  - Anarchy space for checks 


notclass <- wide4upload_long %>% filter(income_group == 'Not Classified') %>% select(iso_code, survey) %>% distinct()
# just venezuela things 

elchombo <- wide4upload_long %>% filter(iso_code == 'IND') %>% select(iso_code, survey, year) %>% distinct()

elchombo2 <- widetable_2023_long  %>% filter(country == 'India') %>% distinct()

education <- wide_previous %>% filter(survey=='PASEC') %>%  select(iso_code3, survey, year, mlevel1_m, grade)  %>% distinct()
table(education$mlevel1_m)

what <- wide_23_long %>% select(survey, source, attend_higher_m, attend_higher_no, year) %>% distinct()

test <- wide_23_long %>% distinct()

library(foreign)

setwd("C:/Users/taiku/Desktop/temporary_raw/")

write.dta(wide4upload_long, 'whatswrong.dta')
  
wide_23_long %>%
  dplyr::group_by(survey, year, level, category, Sex, Location, Wealth, Region, Ethnicity, Religion, Language, indicator, iso_code, country, region_group, income_group, suffix) %>%
  dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
  dplyr::filter(n > 1L) 

kaputt <- wide_23_long %>% 
  tidyr::extract(indicator, into = c('indicator', 'suffix'), regex = "(.*)_(no|m|sd)$")  %>%
pivot_wider(names_from = 'suffix', values_from = 'value')

#senegal 2019 
sen1 <- widetable_2023 %>%  filter(iso_code3 == 'SEN' & year == 2019)
sen2 <- wide_previous %>%  filter(iso_code3 == 'SEN' & year == 2019)

fix <- wide4upload_long %>% distinct()


omfg <- wide4upload %>% filter (comp_prim_v2_m > 1 )
  #BELGICA LFS 2011 2009 

omfg <- wide4upload %>% filter (comp_prim_1524_m  > 1 )

omfg <- wide4upload %>% filter (eduyears_2024_m     > 30 )


comp_higher_2yrs_2529_m 

