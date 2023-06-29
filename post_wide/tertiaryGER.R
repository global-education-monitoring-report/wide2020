
#setup of data frames

library(ggplot2)
library(tidyverse)
library(cowplot)
library(ggrepel)

#march update:
path2uisdata2 <- 'C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/UIS info/'

#GAR.5T8	Gross attendance ratio for tertiary education, both sexes (%)
#GAR.5T8.F	Gross attendance ratio for tertiary education, female (%)
#GAR.5T8.GPIA	Gross attendance ratio for tertiary education, adjusted gender parity index (GPIA)
#GAR.5T8.M	Gross attendance ratio for tertiary education, male (%)


indicators2extract <- c('GAR.5T8.F' , 'GAR.5T8.M')

varlabels <-  read.csv(paste0(path2uisdata2, 'SDG_LABEL.csv'), na = '') %>% rename(indicator_id=INDICATOR_ID)

ger_tertiary <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('WPIA')),  !str_detect(indicator_id, fixed('LPIA'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>%
  mutate(gender = case_when(indicator_id == 'GAR.5T8.F' ~ 'Female',
                            indicator_id == 'GAR.5T8.M' ~ 'Male',
                            TRUE ~ "")) 

genderdiff <- ger_tertiary %>%  select(-indicator_id, -INDICATOR_LABEL_EN) %>%
  pivot_wider(names_from = gender, values_from = value) %>%
  mutate(gendergap=Female - Male) %>%
  group_by(country_id) %>% filter(year == max(year))

##################################################
indicators2extract <- c('GAR.5T8.GPIA' )
ger_tertiary <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>%
  #rid of gender and GPIA 
  #filter(!str_detect(indicator_id, fixed('.M')),  !str_detect(indicator_id, fixed('LPIA')),
   #        !str_detect(indicator_id, fixed('.F'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #var labels
  left_join(varlabels, by="indicator_id")  %>%
  #keep last year per country 
  group_by(country_id) %>% filter(year == max(year)) %>% filter(year>2017)
 
#WPIA hy 121 países, 73 si solo se usa 2018 en adelante


####################################################
#f it, downloading from the web

library(readxl)
SDG_Feb2023_long <- read_excel("~/GEM UNESCO MBR/SDG_Feb2023_ long.xlsx") 
genderdiff2 <- SDG_Feb2023_long %>% 
  mutate(gender = case_when(`Indicator Name` == 'Gross enrolment ratio for tertiary education, female (%)' ~ 'Female',
                            `Indicator Name` == 'Gross enrolment ratio for tertiary education, male (%)' ~ 'Male',
                            TRUE ~ "")) %>%
    select(Country, Year, Value, gender) %>% 
  group_by(Country) %>% filter(Year == max(Year)) %>% distinct() %>%
  pivot_wider(names_from = gender, values_from = Value) %>% filter(Year > 2017) %>%
  mutate(gendergap=Female-Male) %>% mutate(isthereadiff = case_when(abs(gendergap) >= 3 ~ "signif", 
                                                                    abs(gendergap) < 3 ~  "non signif")) %>%
  mutate(direction = case_when(gendergap > 0 ~ "femalesmore", 
                                  gendergap < 0 ~  "malesmore")) %>% filter(!Country=="China, Hong Kong Special Administrative Region")

sheets <- list("gender diff in tertiary" = genderdiff2)
write.xlsx(sheets, file = "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/sdg432.xlsx")
