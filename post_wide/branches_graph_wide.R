## digital comparative branches
##using WIDE data
# 4/20/2023

#
library(ggrepel)
library(ggplot2)
library(tidyverse)
library(ggthemes)

#to save graphs
setwd("C:/Users/Lenovo PC/OneDrive - UNESCO/inequality_forest/")


#Load WIDE dataset

WIDE_2023_19_04 <- read_csv("C:/Users/Lenovo PC/OneDrive - UNESCO/WIDE files/2023/WIDE_2023_19_04_excel.csv") 

library(readr)
WIDE_2023_19_04 <- read_csv("WIDE_2023_19_04_2.csv", 
                            col_types = cols(hh_edu_head = col_character()))
View(WIDE_2023_19_04)


indicator <- 'literacy_1524_m'

your_graph <- WIDE_2023_19_04 %>% select(iso_code, survey, year, indicator, category, location, sex) %>%
  #filter rows with any observation of the indicator 
  filter(!is.na(literacy_1524_m)) %>%
     filter((category=='Total' | category=='Sex' |  category=='Location')) %>% rowwise() %>%
  mutate(id=paste0(location, sex, collapse = "")) %>%   mutate(id = str_remove_all(id, "NA")) %>% mutate(id = if_else(id=="", "Total" ,id)) %>% 
  select(-category, -sex, -location) %>%
  pivot_wider(names_from = id, values_from=indicator) %>%
  #get rid of weird entries
  filter(across(c(Rural, Urban, Female, Male, Total), ~ !is.na(.))) %>% filter(across(c(Rural, Urban, Female, Male, Total), ~ ! . == 1)) %>%
  rowwise() %>%
  mutate(valmin = min(Rural, Urban, Female, Male, Total), valmax = max(Rural, Urban, Female, Male, Total)) %>%
  arrange(Total) %>% 
  mutate(iso_code=factor(iso_code, iso_code)) %>%
  group_by(iso_code, year) %>% fil

    
ggplot(your_graph) +
  geom_segment( aes(x=iso_code, xend=iso_code, y=valmin, yend=valmax), color="grey") +
  geom_point( aes(x=iso_code, y=Rural), color="blue", size=2 ) +
  geom_point( aes(x=iso_code, y=Urban), color="red", size=2 ) +
  geom_point( aes(x=iso_code, y=Female), color="chartreuse", size=2 ) +
  geom_point( aes(x=iso_code, y=Male), color="purple", size=2 ) 
  


#filter((iso_code=='TCD' & year==2019 & survey=='MICS')) %>%