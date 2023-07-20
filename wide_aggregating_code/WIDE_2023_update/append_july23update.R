#MAKING THE WIDE DATASET O_O
#10/07/23 adding PIRLS and adapting new directories, fixing disability FS

# prelims -----------------------------------------------------------------

library(magrittr)
library(tidyverse)
library(countrycode)
library(dplyr)
library(vroom)
library(stringr)
library(purrr)
library(tidyr)
library(beepr)

#memory.limit(35000)
options(max.print=10000)

countries_unesco <- vroom::vroom('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/countries_unesco_2020.csv')

path2pieces <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/WIDE_2023_files/" 


# wide_old_clean: last update uploaded FIXED AND TRIMMED ----------------------------------------------------

wide_previous <- vroom::vroom(paste0(path2pieces,"wide_old_clean.csv"), guess_max = 900000) %>%
  # drop regional aggregates, which will be recalculated
  filter(!is.na(iso_code)) %>% 
  rename(iso_code3 = iso_code) %>% 
  select(-country, -region_group, -income_group, -v1) %>%
  #Senegal 2019 seems to be a problem 
  filter(!(iso_code3 == 'SEN' & year == 2019))


wide_vars <- names(wide_previous)
wide_vars
wide_outcome_vars <- names(select(wide_previous, comp_prim_v2_m:slevel4_no))
wide_outcome_vars


wide_previous_long <- 
  pivot_longer(wide_previous, names_to = 'indicator', cols = any_of(wide_outcome_vars)) %>% distinct() %>% filter(!is.na(value)) %>% select(-grade) %>%
  #harmonizing year with UIS
  mutate(year = ifelse((iso_code3 == 'CAF' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'COD' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'GUY' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'WSM' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'TCA' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'TUV' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'PSE' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'KIR' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'MKD' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'BEN' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'GHA' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'JOR' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'PNG' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  #drop lesotho mics 
  filter(!(iso_code3=='LSO' & year==2018 & survey=='MICS'))


#md_extract <- wide_previous_long %>% select(survey, iso_code3, year, indicator, value, category) %>% filter(survey=='MICS' | survey == 'DHS') %>% 
#  filter(iso_code3=='LSO') %>% filter(year== 2018) %>% distinct() 
 
##theres a problm with LSO 2018 MICS so getting rid of it  

# #this took a while but was worth it 
# what <- wide_previous_long  %>%  janitor::get_dupes()
# 
# #this is ISR 2012 and USA 2013 
# whatofinterest <- what %>% filter (!is.na(value))
# whatGHOSTST <- what %>% filter (is.na(value))
# #all is this 
# 
# wide_previous_long_zeros <- wide_previous_long %>% filter (is.na(value))


# UIS update (MAR 2023 release) -------------------------------------------
#no changes here so we dont incorporate

uis4wide <- vroom::vroom(paste0(path2pieces,"uis4wide.csv"), guess_max = 900000) %>%
  rename(sex= Sex) %>% rename(location = Location) %>% rename(wealth=Wealth)
  
names(uis4wide)

#burkina <- uis4wide %>% filter(survey=='EHCVM' ) 
#turkey <- uis4wide %>% filter(iso_code3=='TUR' ) 
#india <- uis4wide %>% filter(iso_code3=='IND' ) 

#this is already in long format 

  
# WIDETABLE GEMR Jan 2023 update from widetable pipeline and some past friends ----------------------------------------------

widetable_2023 <-
  vroom::vroom(paste0(path2pieces,"widetable_2023.csv"), guess_max = 900000) %>%
  filter(!iso_code3=='NGA') %>%  filter(!iso_code3=='ZAF') 

#here new stuff too

widetable_2023_long <- 
  pivot_longer(widetable_2023, names_to = 'indicator', cols = any_of(wide_outcome_vars)) 

# new categories: disability and parental edu-----------------------------

#fixed FS incorporated new 17/july version 
dis_hh_edu <- vroom::vroom(paste0(path2pieces,"newcategories_2023_2.csv")) %>%
  select(-country) %>%
  mutate(year = ifelse((iso_code == 'CAF' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code == 'COD' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code == 'GUY' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code == 'WSM' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code == 'TCA' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code == 'TUV' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code == 'PSE' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code == 'KIR' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code == 'MKD' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code == 'BEN' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code == 'GHA' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code == 'JOR' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code == 'PNG' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  rename(iso_code3=iso_code)


newcategories_long <- pivot_longer(dis_hh_edu, names_to = 'indicator', cols = any_of(wide_outcome_vars))


# GEMR national surveys -----------------------------------------------

nationalsurveys <-vroom::vroom(paste0(path2pieces,"nationalsurveys.csv")) %>% distinct() 

nationalsurveys_long <-
  pivot_longer(nationalsurveys, names_to = 'indicator', cols = any_of(wide_outcome_vars)) %>% filter (!is.na(value))

# learning update june 2023 ---------------------------------------------------

#now adding PIRLS21 
#file was here C:\Users\Lenovo PC\Documents\GEM UNESCO MBR\GitHub\wide2020\ilsa\data

pirls21 <- vroom::vroom(paste0(path2pieces,"pirls21_mpl.csv")) %>% select(-rlevel2_se, -rlevel3_se, -rlevel4_se) %>%
  rename(language=Language) %>% rename(location=Location) %>% rename(sex=Sex) %>% 
  mutate(level= case_when(
    grade == 3 ~ 'early grades',
    grade == 6 ~ 'end of primary')) %>% select(-grade) %>%
    #wealth fix
  mutate(quin = case_when(is.na(Wealth)~ '', TRUE ~ 'Quintile ')) %>% 
  unite("wealth", c('quin', 'Wealth'), sep = "" , remove = TRUE, na.rm = TRUE) 
  

pirls21_long <-
  pivot_longer(pirls21, names_to = 'indicator', cols = any_of(wide_outcome_vars)) %>% filter (!is.na(value))

mics_learning <- vroom::vroom(paste0(path2pieces,"mics6_mpl.csv")) %>%
  mutate(survey= 'MICS') %>%
  #year issue 
  mutate(year = ifelse((iso_code3 == 'CAF' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'COD' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'GUY' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'WSM' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'TCA' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'TUV' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'PSE' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'KIR' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'MKD' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'BEN' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'GHA' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'JOR' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'PNG' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  #level issue 
  mutate(level= case_when(
    grade == 3 ~ 'early grades',
    grade == 6 ~ 'end of primary')) %>% select(-grade) %>%
  #wealth 
  mutate(quin = case_when(is.na(Wealth)~ '', TRUE ~ 'Quintile ')) %>% 
  unite("wealth", c('quin', 'Wealth'), sep = "" , remove = TRUE, na.rm = TRUE) %>%
  rename(location = Location) %>% rename(sex = Sex)

micslearning_long <-
  pivot_longer(mics_learning, names_to = 'indicator', cols = any_of(wide_outcome_vars)) %>% filter (!is.na(value))

  
  
#checked
#check_year <- mics_learning %>% select(iso_code3,survey, year) %>% distinct() %>%
#  left_join(multi_mics, by=c('iso_code3'), multiple = "all") 


# EU-LFS forget about SILC  -----------------------------------------------------------------
#theres nothing new here, switching off


LFS_wide <- vroom::vroom(paste0(path2pieces,"LFS_indicators_WIDE_2023.csv"))
#LFS_old <- vroom::vroom(paste0(path2pieces,"old_LFS_indicators_for_WIDE.csv"))


LFS_long <-
  pivot_longer(LFS_wide, names_to = 'indicator', cols = any_of(wide_outcome_vars))

#fix with distinct
LFS_long <- LFS_long %>% distinct() %>% filter (!is.na(value))


# LIS (including latest update) ---------------------------------------------------------------------
#theres nothing new here, switching off


lis_new <- vroom::vroom(paste0(path2pieces,"lis_2023.csv")) %>% 
  mutate(survey = str_remove_all(survey, "LIS")) %>% 
  mutate(survey = str_remove_all(survey, "[()]")) %>%
  mutate(survey = str_trim(survey) )
 
lis_long <- 
  pivot_longer(lis_new, names_to = 'indicator', cols = any_of(wide_outcome_vars)) %>% 
  distinct() %>% filter(!is.na(value))

#Today's test: fix with distinct
lis_long <- lis_long %>% distinct()


# NOW COMBINE ALL THAT SHIT  ---------------------------------------------------------------

addifnew <- function(df_priority, df_ifnew, byvars) {
  df_2add <- anti_join(df_ifnew, df_priority, by = byvars)
  bind_rows(df_priority, df_2add)
}

addifnew_wflag <- function(df_priority, df_ifnew, byvars, flag) {
  df_2add <- 
    anti_join(df_ifnew, df_priority, by = byvars) %>% 
    mutate(source = flag)
  bind_rows(df_priority, df_2add)
}

wide_23_long <- wide_previous_long %>%
  addifnew_wflag(uis4wide, c('iso_code3', 'survey', 'year', 'indicator'), 'UIS4WIDE') %>% 
  addifnew_wflag(widetable_2023_long, c('iso_code3', 'survey', 'year',  'indicator'), 'WIDETABLE') %>% 
  addifnew_wflag(lis_long, c('iso_code3', 'survey', 'year', 'indicator'),'LIS') %>% 
  addifnew_wflag(LFS_long, c('iso_code3', 'survey', 'year', 'indicator'),'LFS') %>% 
  addifnew_wflag(nationalsurveys_long, c('iso_code3', 'survey', 'year', 'indicator'), 'NationalSurveys') %>%
  addifnew_wflag(newcategories_long, c('iso_code3', 'survey', 'year', 'indicator', 'category'), 'NewCategories') %>%
  addifnew_wflag(micslearning_long, c('iso_code3', 'survey', 'year', 'indicator'), 'MICSlearning') %>%
  addifnew_wflag(pirls21_long, c('iso_code3', 'survey', 'year', 'indicator'), 'newPIRLS') %>%
  select(-country) %>%
  select(-literacy_no,-comp_higher_2529_no,-comp_upsec_2024_m,-comp_lowsec_2024_m,-comp_higher_2529_m,-comp_higher_3034_m,-comp_higher_3034_no,
         -comp_lowsec_2024_no,-comp_upsec_2024_no,-isocode2, -literacy_1549_m,-literacy_1549_no, -literacy_1524) %>%
  #select(-source)   %>% 
  distinct() %>%
  distinct(survey, year, level, category, sex, location, wealth, region, ethnicity, disability, hh_edu_head, religion, language, iso_code3, indicator, .keep_all = TRUE)

names(wide_23_long)

rm(LFS_long,LFS_wide,lis_long,lis_new,nationalsurveys,nationalsurveys_long, uis4wide, pírls21, wide_previous, wide_previous_long, widetable_2023, widetable_2023_long)



###WARNING: RUN OTHER CODE BEFORE THIS
#Before running this, run update_income.R to get regions 
source("C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/update_income.R")

countries_unesco <- countries_unesco %>% rename(iso_code = iso3c) %>% rename(country= country_fig)

wide_23_long <- 
  wide_23_long %>% 
  rename(iso_code = iso_code3) %>% 
  select(any_of(wide_vars), indicator, value, iso_code, disability, hh_edu_head) %>% 
  inner_join(select(countries_unesco, iso_code , country), by = 'iso_code') %>% 
  left_join(select(regions, iso_code = iso3c, region_group = SDG.region, income_group), 
            by = 'iso_code') %>% 
    identity

###WARNING: RUN OTHER CODE BEFORE THIS
#Now run checks.R to get the functions
source("C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/checks.R")

wide_23_long %>% check_countries 

#rename categories proper 
wide_23_long <- 
  wide_23_long %>% rename(Sex=sex) %>%  rename(Location=location) %>% rename(Wealth=wealth) %>% rename(Ethnicity=ethnicity) %>% 
  rename(Region=region) %>% rename(Religion=religion)  %>% rename(Language=language) 


#Impute and check_* function comes from checks.R
wide4upload_long <- 
  wide_23_long %>% 
  check_completeness %>% 
  check_samplesize %>%
  check_categories %>% 
  mutate(value = round(value, 4)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') %>% 
  impute_prim_from_sec %>% 
  pivot_longer(names_to = 'indicator', values_to = 'value', cols = any_of(wide_outcome_vars)) %>% 
  group_by(iso_code, year, survey, indicator) %>% 
  filter("Total" %in% category) %>% 
  ungroup

  #Now run aggregate.R
source("C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/aggregate.R")


wide_23_2agg <- 
  wide4upload_long %>% 
  filter(category %in% cats2agg) %>% 
  filter(!str_detect(indicator, 'level')) %>% 
  select(-level,  -Region, -Ethnicity, -Religion, -Language) %>% 
  group_by(iso_code, indicator) %>% 
  filter(year == max(year) & max(year) >= 2010) %>% 
  filter(survey == first(survey)) %>% 
  ungroup %>% 
  left_join(weights, by = c('iso_code', 'indicator')) %>% 
  filter(!is.na(wt_value), !is.na(value)) 

wide_23_2agg %>% 
  group_by(category, region_group, income_group, indicator) %>% 
  summarize(lag = weighted.mean(2020 - year, wt_value)) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'lag')

# AGG AND WEIGHT TEST

test_long_aggs <- 
  myagg_outer(wide_23_2agg) %>% 
  keep_threshold %>% 
  mutate(value = ifelse(str_detect(indicator, '_no'), 1, value))

test_long_aggs %>% 
  unite('region', income_group, region_group) %>% 
  select(-value) %>% 
  pivot_wider(names_from = 'region', values_from = 'weight_share') %>% 
  filter(!str_detect(indicator, '_no')) %>% 
  write_csv('C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/reg_aggs.csv')

#

wide4upload_long_aggs <- 
  myagg_outer(wide_23_2agg) %>% 
  apply_threshold %>% 
  mutate(value = ifelse(str_detect(indicator, '_no'), 1, value))
#%>%
 # rename(sex=Sex) %>%  rename(location=Location) %>% rename(wealth=Wealth)

wide4upload <- 
  bind_rows(
    wide4upload_long,
    wide4upload_long_aggs
  ) %>% rename(iso_code3= iso_code) %>%
  pivot_wider(names_from = 'indicator', values_from = 'value') %>%
   rename(sex=Sex) %>%  rename(location=Location) %>% rename(wealth=Wealth) %>% rename(ethnicity=Ethnicity) %>% 
  rename(region=Region) %>% rename(religion=Religion)  %>% rename(language=Language) 

#%>%   select(any_of(wide_vars)) 

wide4upload_aggregates <- 
  bind_rows(
    wide4upload_long_aggs
  ) %>% 
  pivot_wider(names_from = 'indicator', values_from = 'value') 
#%>%   select(any_of(wide_vars))

#setwd("C:/Users/taiku/Desktop/temporary_raw/")
#write.csv(wide4upload_aggregates, 'WIDE_2021_06_10_aggregates.csv', na = '')


wide4upload %>% 
  check_completion_progression %>% 
  filter(category == 'Total') %>% 
  arrange(desc(pmax(comp_lowsec_v2_m - comp_prim_v2_m, comp_upsec_v2_m - comp_lowsec_v2_m)))

wide4upload %>% summary



wide4upload <- wide4upload %>% mutate(category=ifelse(category=="Sex Region",'Sex & Region',category)) %>%
  mutate(category=ifelse(category=="Region Ethnicity",'Ethnicity & Region',category)) %>%
  mutate(category=ifelse(category=="Sex Ethnicity",'Ethnicity & Sex',category)) %>%
  mutate(category=ifelse(category=="Sex Location",'Location & Sex',category)) %>%
  mutate(category=ifelse(category=="Sex Region",'Region & Sex',category)) %>%
  mutate(category=ifelse(category=="Sex Region Location",'Location & Region & Sex',category)) %>%
  mutate(category=ifelse(category=="Sex Wealth",'Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Sex Wealth Ethnicity",'Ethnicity & Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Sex Wealth Location",'Location & Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Sex Wealth Region",'Region & Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth Ethnicity",'Ethnicity & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth Ethnicity",'Ethnicity & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth Location",'Location & Wealth',category)) %>%
  mutate(category=ifelse(category=="Location Ethnicity",'Ethnicity & Location',category)) %>%
  mutate(category=ifelse(category=="Location Sex Wealth",'Location & Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Location Wealth",'Location & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth Location",'Location & Wealth',category)) %>%
  mutate(category=ifelse(category=="Region Ethnicity",'Ethnicity & Region',category)) %>%
  mutate(category=ifelse(category=="Sex Wealth",'Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Sex Wealth Region",'Region & Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Location Sex Wealth",'Location & Sex & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth Ethnicity",'Ethnicity & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth Region",'Region & Wealth',category)) %>%
  mutate(category=ifelse(category=="Wealth & Region",'Region & Wealth',category)) %>%
  mutate(category = str_to_title(gsub("_", " ", category))) %>%
  filter(!category == "Ethnicity & Location & Sex & Wealth")
  
#Here i can find weird shit 
fixcats <- wide4upload %>% select(category) %>% distinct()
fixcats
  
 
#   mutate(category=str_replace_all(category,c("Speakslanguageathome" = "Speaks Language At Home"))) %>%
#   filter(!category == 'Ethnicity & Location & Region & Sex & Wealth') 
#wide4upload <- wide4upload %>% filter(!category == "Ethnicity & Location & Sex & Wealth")


#Check if regions have been included checking the NA has 88 entries now 101 
table(wide4upload$iso_code3, useNA = "always")
#If not, add the wide version.
#wide4upload <- bind_rows(wide4upload,wide4upload_aggregates)


#setwd("C:/Users/taiku/OneDrive - UNESCO/WIDE files")

setwd("C:/Users/mm_barrios-rivera/OneDrive - UNESCO/WIDE files/2023/")

wide4upload <- wide4upload %>% rename(iso_code=iso_code3) 

wide4upload <- wide4upload %>% mutate(grade=1) 

#wide4upload <- wide4upload %>% mutate(v1=row_number()) 

wide4upload <- wide4upload %>% select(iso_code, region_group, income_group, country,	survey,
                                       year,level,grade, category,sex,location, wealth, region, ethnicity, religion,
                                       language, disability, hh_edu_head, comp_prim_v2_m,	comp_lowsec_v2_m,	comp_upsec_v2_m,	comp_prim_1524_m,
                                       comp_lowsec_1524_m,	comp_upsec_2029_m,	eduyears_2024_m,	edu2_2024_m,	edu4_2024_m,
                                       eduout_prim_m,	eduout_lowsec_m,	eduout_upsec_m,	comp_prim_v2_no,	comp_lowsec_v2_no,
                                       comp_upsec_v2_no,	comp_prim_1524_no,	comp_lowsec_1524_no,	comp_upsec_2029_no,	eduyears_2024_no,
                                       edu2_2024_no, edu4_2024_no,	eduout_prim_no,	eduout_lowsec_no,	eduout_upsec_no,	preschool_3_m,
                                       preschool_3_no,	preschool_1ybefore_m,	preschool_1ybefore_no,	edu0_prim_m,	edu0_prim_no,
                                       trans_prim_m,	trans_prim_no,	trans_lowsec_m,	trans_lowsec_no,	comp_higher_2yrs_2529_m,
                                       comp_higher_2yrs_2529_no,	comp_higher_4yrs_2529_m,	comp_higher_4yrs_2529_no,
                                       comp_higher_4yrs_3034_m,	comp_higher_4yrs_3034_no,	attend_higher_1822_m,	attend_higher_1822_no,
                                       overage2plus_m,	overage2plus_no,	literacy_1524_m,	literacy_1524_no,	mlevel1_m,	mlevel1_no,
                                       rlevel1_m,	rlevel1_no,	slevel1_m,	slevel1_no,	mlevel2_m,	mlevel2_no,	rlevel2_m,	rlevel2_no,
                                       slevel2_m,	slevel2_no,	mlevel3_m,	mlevel3_no,	rlevel3_m,	rlevel3_no,	slevel3_m,	slevel3_no,
                                       mlevel4_m,	mlevel4_no,	rlevel4_m,	rlevel4_no,	slevel4_m,	slevel4_no)

#wide4upload <- wide4upload %>% rename(iso_code=iso_code3) 


### SOME extra censoring ----

#arg <- wide4upload %>% select(iso_code,year, survey) %>% distinct() %>% filter(iso_code=="ARG")

wide4upload <- wide4upload %>% filter(!(iso_code=='ARG' & year==2020 & survey=='MICS'))

#wide4upload <- wide4upload %>% select(-v1)

write.csv(wide4upload, 'WIDE_2023_julytest.csv', na = '')

write_csv(wide4upload, 'WIDE_2023_julytest.csv', na = '')

write_excel_csv(wide4upload, 'WIDE_2023_julytest_excel.csv', na = '')

#take cleaned .dta 
library(haven)
cleanwide <- haven::read_dta(paste0(path2pieces,"WIDE_2023_julytest_cleaned.dta")) 
#it has to be this write.csv that creates a column they need for the web upload 
write.csv(cleanwide, 'WIDE_2023_july3.csv', na = '')

  
# write.csv(wide4upload, 'WIDE_2023_19_04_2.csv', na = '')
# write_csv(wide4upload, 'WIDE_2023.csv', na = '')
# write_excel_csv(wide4upload, 'WIDE_2023_19_04_excel.csv', na = '')


#write_csv(wide4upload, 'WIDE_2021_16_09_v1.csv', na = '')
#R is crashing when it tries to overwrite the file 
#so make sure it's gone before running this last line
#write.csv(wide4upload, 'WIDE_2021_06_10.csv', na = '')
#write.csv(wide4upload, 'WIDE_2023_06_03.csv', na = '')
#for some reason the github likes this way of saving that takes longer
#write_csv(wide4upload, 'WIDE_2023_06_03.csv', na = '')


#write_csv(gemr_countries, 'gemr_countries2.csv', na = '')

#names(wide4upload)

###################################################################################################
 
# #Quick fix on level variable
# wide4upload <- wide4upload %>% 
#   mutate(level=ifelse(level=="Lower secondary",NA,level)) %>%
#   mutate(level=ifelse(level=="lowsec",NA,level)) %>%
#   mutate(level=ifelse(level=="prim",NA,level)) %>%
#   mutate(level=ifelse(level=="Primary",NA,level)) %>%
#   mutate(level=ifelse(level=="Upper secondary",NA,level)) %>%
#   mutate(level=ifelse(level=="upsec",NA,level))
# 
# #Fix on category variable
# wide4upload <- wide4upload %>% mutate(category= str_to_title(category)) %>%
#   mutate(category=str_replace_all(category,c("Speaks Language At Home" = "Speakslanguageathome"))) %>%
#   mutate(category=str_replace_all(category,c("&" = "")))  %>%
#   mutate(category=str_squish(category))

#wide4upload$category<-sapply(lapply(strsplit(wide4upload$category," "), sort), paste, collapse=" & ")

# I was right w this correction
# posiblecorrection <- wide_previous_long %>%
#   addifnew_wflag(newcategories_long, c('iso_code3', 'survey', 'year', 'indicator', 'category'), 'NewCategories') %>%
#   filter((iso_code3=='SLE' & year==2017 & survey=='MICS'))   
# 
# posiblemistake <- wide_previous_long %>%
#   addifnew_wflag(newcategories_long, c('iso_code3', 'survey', 'year', 'indicator'), 'NewCategories') %>%
#   filter((iso_code3=='SLE' & year==2017 & survey=='MICS'))
