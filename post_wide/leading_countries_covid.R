# TASK: list of the ten countries with the lowest drop out rates at each school level?

# we would like to specify that what we need mostly is the list of leading countries with the lowest school drop out rate.
# Such list would be very helpful to us, and of course, we would also welcome any additional resources or publications on this topic.
# We have looked into the UIS website for some relevant data, and found some statistics on completion rates 
# ( primary, lower secondary and upper secondary). 
#Leading countries in this regard include the UK, Sweden and Slovenia, among others, 
#which could lead us to assume that these countries have a very low school drop out rate. 
#However we are not sure that we are well interpreting this data and if our analysis is correct. Your input would be greatly appreciated.

library(tidyverse)

WIDE_2023_08_02 <- read_csv("C:/Users/Lenovo PC/OneDrive - UNESCO/WIDE files/2023/WIDE_2023_08_02.csv") 

comp_indicators <- names(select(WIDE_2023_08_02, comp_prim_v2_m:comp_upsec_v2_m))
eduout_indicators <- names(select(WIDE_2023_08_02, eduout_prim_m:eduout_upsec_m))
relevant_indicators <- c(comp_indicators , eduout_indicators)


#FIRST get uis data form uis2wide_2023.R: latam mainly 
uis4wide <- uis4wide %>% filter(category=='Total') %>% filter(year==2019 | year==2020 | year==2021) %>% rename(iso_code = iso_code3)

uis_test <- uis4wide %>%   pivot_wider(names_from = year, values_from = c(value))

#then gather stuff from LATEST WIDE 

WIDE <-  WIDE_2023_08_02 %>% 
  filter(category=='Total') %>% filter(year==2018 | year==2019 | year==2020 | year==2021) %>% 
  pivot_longer(names_to = 'indicator', cols = all_of(relevant_indicators), values_to = "value") %>% 
  select(-c(comp_prim_1524_m:slevel4_no)) %>% 
  select(-c(sex:hh_edu_head)) %>% 
  filter(!is.na(value)) %>% filter(!survey=='ECLAC') %>% filter(!(iso_code == 'PSE' & year == 2019)) %>%
  filter(!(iso_code == 'TCA' & year == 2019)) %>% filter(!(iso_code == 'TUV' & year == 2019)) %>% filter(!(iso_code == 'GUY' & year == 2019))

#####################
#something w really didnt need

best_of <- function(ind) {
    uis_part <-  uis4wide %>%   filter(indicator==ind) %>%  pivot_wider(names_from = year, values_from = c(value), names_prefix = "year") %>%  
    filter(across(c('year2019', 'year2020'), ~ !is.na(.))) %>% select(-meta)
  
  wide_part <- WIDE %>% filter(indicator==ind) %>% select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
    pivot_wider(names_from = year, values_from = c(value), names_prefix = "year") %>% 
    filter(across(c('year2019', 'year2020'), ~ !is.na(.)))
  
  ranking <- bind_rows(uis_part, wide_part) %>% mutate(covid_diff= year2020-year2019) %>%  mutate(covid_diff = round(covid_diff, 3))
}

#
#choose: "comp_prim_v2_m"   "comp_lowsec_v2_m" "comp_upsec_v2_m"  "eduout_prim_m"    "eduout_lowsec_m"  "eduout_upsec_m" 

#arrange : -covid_diff para comp , covid_diff para eduout 
 top10 <- best_of('comp_upsec_v2_m') %>% arrange(covid_diff) %>% top_n(10) 
top10

ranking_all <- best_of('comp_upsec_v2_m')
ranking_all

##################################################


eduout_p <- WIDE %>%  select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
  filter(indicator=='eduout_prim_m') %>%  distinct() %>%    group_by(iso_code) %>%
  filter(year == max(year)) %>%  arrange(value) 


eduout_ls <- WIDE %>%  select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
  filter(indicator=='eduout_lowsec_m') %>%  distinct()  %>%  group_by(iso_code) %>%
  filter(year == max(year)) %>%    arrange(value) 


eduout_us <- WIDE %>%  select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
  filter(indicator=='eduout_upsec_m') %>%  group_by(iso_code) %>%
  filter(year == max(year)) %>% arrange(value) 


comp_p <- WIDE %>%  select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
  filter(indicator=='comp_prim_v2_m') %>%  distinct()  %>%  group_by(iso_code) %>%
  filter(year == max(year)) %>% arrange(-value) 


comp_ls <- WIDE %>%  select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
  filter(indicator=='comp_lowsec_v2_m') %>%  distinct()  %>%  group_by(iso_code) %>%
  filter(year == max(year)) %>%   arrange(-value) 


comp_us <- WIDE %>%  select (-level, -grade, -country_year, -v1, -country, -region_group, -income_group) %>%
  filter(indicator=='comp_upsec_v2_m') %>%  group_by(iso_code) %>%
  filter(year == max(year)) %>% arrange(-value) 


library(openxlsx)
names <- list('Out of school - Primary' = eduout_p, 'Out of school - Lower secondary' = eduout_ls, 'Out of school - Upper secondary' = eduout_us, 
              'Completion - Primary' = comp_p, 'Completion - Lower secondary' = comp_ls, 'Completion - Upper secondary' = comp_us )
write.xlsx(names, file = 'top10rankings.xlsx')


