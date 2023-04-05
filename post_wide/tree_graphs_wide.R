## digital trees
##using WIDE data
# 4/5/2023

#
library(ggrepel)
library(ggplot2)
library(tidyverse)

#Load WIDE dataset

WIDE_2023_08_02 <- read_csv("C:/Users/Lenovo PC/OneDrive - UNESCO/WIDE files/2023/WIDE_2023_08_02.csv") 

#See what's on 3D possibilities 

locsexwealth <- WIDE_2023_08_02 %>% filter(category=='Location & Sex & Wealth') %>% 
  filter(wealth %in% c('Quintile 1', 'Quintile 5')) %>% 
  select(iso_code, year, survey, category, sex, location, wealth,  comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
         eduout_upsec_m, eduout_lowsec_m, eduout_prim_m) %>%
  mutate(group = str_c(sex, location, wealth))  %>%
  distinct() %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = group, 
               values_from = c(comp_prim_v2_m) , values_fn = list ) 

#Exploring inequalities 

ranking_wealth_differences <- WIDE_2023_08_02 %>% filter(category=='Wealth') %>% filter(!is.na(country), !is.na(survey), !is.na(year)) %>%
  filter(wealth %in% c('Quintile 1', 'Quintile 5')) %>%
  select(iso_code, year, survey, category, sex, location, wealth,  comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
         eduout_upsec_m, eduout_lowsec_m, eduout_prim_m)  %>%
  #keep obs where all these vars have a value
  filter_at(vars( comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
                  eduout_upsec_m, eduout_lowsec_m, eduout_prim_m), all_vars(!is.na(.))) %>% distinct() %>%
  group_by(iso_code) %>%
  filter(year == max(year)) %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = wealth, 
               values_from = c(comp_prim_v2_m)  ) %>%
  rename(Q1='Quintile 1') %>%  rename(Q5='Quintile 5') %>%
  mutate(wealth_dif=Q5-Q1) %>% arrange(-wealth_dif)

ranking_sex_differences <- WIDE_2023_08_02 %>% filter(category=='Sex') %>% filter(!is.na(country), !is.na(survey), !is.na(year)) %>%
  select(iso_code, year, survey, category, sex, location, wealth,  comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
         eduout_upsec_m, eduout_lowsec_m, eduout_prim_m)  %>%
  #keep obs where all these vars have a value
  filter_at(vars( comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
                  eduout_upsec_m, eduout_lowsec_m, eduout_prim_m), all_vars(!is.na(.))) %>% distinct() %>%
  group_by(iso_code) %>%
  filter(year == max(year)) %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = sex, 
               values_from = c(comp_prim_v2_m)  ) %>%
  mutate(sex_dif=Male-Female) %>% arrange(-sex_dif)

ranking_location_differences <- WIDE_2023_08_02 %>% filter(category=='Location') %>% filter(!is.na(country), !is.na(survey), !is.na(year)) %>%
  select(iso_code, year, survey, category, sex, location, wealth,  comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
         eduout_upsec_m, eduout_lowsec_m, eduout_prim_m)  %>%
  #keep obs where all these vars have a value
  filter_at(vars( comp_lowsec_v2_m, comp_prim_v2_m, comp_upsec_v2_m, 
                  eduout_upsec_m, eduout_lowsec_m, eduout_prim_m), all_vars(!is.na(.))) %>% distinct() %>%
  group_by(iso_code) %>%
  filter(year == max(year)) %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = location, 
               values_from = c(comp_prim_v2_m)  ) %>%
  mutate(loc_dif=Urban-Rural) %>% arrange(-loc_dif)

### explore inequalities IN ONE SURVEY 

extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="TCD" & survey=='MICS' & year==2019)

q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(comp_prim_v2_m)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(comp_prim_v2_m)

m <- extracted_survey %>% filter(category=="Sex") %>% filter(sex %in% c('Male')) %>% pull(comp_prim_v2_m)
f <- extracted_survey %>% filter(category=="Sex") %>% filter(sex %in% c('Female')) %>% pull(comp_prim_v2_m)

urb <- extracted_survey %>% filter(category=="Location") %>% filter(location %in% c('Urban')) %>% pull(comp_prim_v2_m)
rur <- extracted_survey %>% filter(category=="Location") %>% filter(location %in% c('Rural')) %>% pull(comp_prim_v2_m)

q5-q1
m-f
urb-rur


###############################################
###  TREE CHOICE 1 :WEALTH-LOCATION-SEX -------
###############################################

#select survey
extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="TCD" & survey=='MICS' & year==2019)

q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(comp_prim_v2_m)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(comp_prim_v2_m)

q5_urb <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 5') & location %in% c('Urban')) %>% pull(comp_prim_v2_m)
q5_rur <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 5') & location %in% c('Rural')) %>% pull(comp_prim_v2_m)

q1_urb <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 1') & location %in% c('Urban')) %>% pull(comp_prim_v2_m)
q1_rur <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 1') & location %in% c('Rural')) %>% pull(comp_prim_v2_m)

q5_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q5_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)

q5_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q5_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)

q1_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q1_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)

q1_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q1_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)


plot_data  <- data.frame(level = c(1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),                      # Create example data frame
                         indicator = c(q1, q5, q5_urb, q5_rur, q1_urb, q1_rur, q5_urb_m, q5_urb_f, q5_rur_m, q5_rur_f, q1_urb_m, q1_urb_f, q1_rur_m, q1_rur_f), 
                         ind_example = c(60, 95, 90, 96, 61, 50, 98, 95, 80, 90, 51, 49, 65, 58), 
                         full_labels = c("Poorest","Richest", "Richest urban","Richest rural", "Poorest urban","Poorest rural",
                                         "Richest urban men", "Richest urban women", "Richest rural men", "Richest rural women",
                                         "Poorest urban men", "Poorest urban women" , "Poorest rural men", "Poorest rural women"), 
                         short_labels= c("Poorest","Richest", "Urban","Rural", "Urban","Rural",
                                         "Men", "Women", "Men", "Women",
                                         "Men", "Women" , "Men", "Women"))
#WEALTH-LOCATION-SEX
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels)) +                 # Create ggplot2 plot without lines & curves
  geom_point()  
ggp

ggp+
  geom_segment(x = 1, #v line at level 1
               y = q1, 
               xend = 1, 
               yend =q5) +    
  geom_segment(x = 2, #v line upper 
               y = q5_urb,  
               xend = 2, 
               yend =q5_rur) +  
  geom_segment(x = 2,
               y = q1_urb,   #v line down
               xend = 2, 
               yend =q1_rur)  + 
  geom_segment(x = 3,    #v line 3rd level 1st
               y = q5_urb_m,
               xend = 3, 
               yend =q5_urb_f,  color="blue") +
  geom_segment(x = 3,  #v line 3rd level 2nd
               y = q5_rur_m,  
               xend = 3, 
               yend =q5_rur_f, color="red") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_m,  
               xend = 3, 
               yend =q1_urb_f, color="green") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_rur_m,  
               xend = 3, 
               yend =q1_rur_f, color="pink") +
  geom_segment(x = 1,  #horizontal 1-2 up
               y = q5,  
               xend = 2, 
               yend =q5) +
  geom_segment(x = 2,  #horizontal 2-3 1st
               y = q5_urb,  
               xend = 3, 
               yend =q5_urb, color="blue") +
  geom_segment(x = 2, 
               y = q5_rur,  #horizontal 2-3 2nd
               xend = 3, 
               yend =q5_rur, color="red")+
  geom_segment(x = 1, #horizontal 1-2 down
               y = q1,  
               xend = 2, 
               yend =q1)+
  geom_segment(x = 2, 
               y = q1_urb,  #horizontal 2-3 3rd
               xend = 3, 
               yend =q1_urb, color="green")+
  geom_segment(x = 2, 
               y = q1_rur,  #horizontal 2-3 4th
               xend = 3, 
               yend =q1_rur, color="pink")+
  theme(panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())   +
  scale_y_continuous(limits = c(0, 0.9))+
  scale_x_continuous(n.breaks = 3, label = c("Wealth", "Location", "Sex")) +
  labs(y= "Primary completion", x="",  title = "The inequality tree: TCD 2019 MICS") +
  geom_label_repel(aes(label = short_labels),
                   box.padding   = 0.95, 
                   point.padding = 0.5,
                   segment.color = 'grey50')

#STAPH!

#################################################
###  TREE CHOICE 2 :WEALTH-SEX-LOCATION -------
#################################################

extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="BGD" & survey=='MICS' & year==2019)


q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(comp_prim_v2_m)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(comp_prim_v2_m)

q5_m <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 5') & sex %in% c('Male') ) %>% pull(comp_prim_v2_m)
q5_f <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 5') & sex %in% c('Female') ) %>% pull(comp_prim_v2_m)

q1_m <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 1') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)
q1_f <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 1') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)

q5_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q5_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)

q5_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q5_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)

q1_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q1_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)

q1_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(comp_prim_v2_m)
q1_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(comp_prim_v2_m)


plot_data  <- data.frame(level = c(1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),                      # Create example data frame
                         indicator = c(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_m, q5_rur_m, q5_urb_f, q5_rur_f, q1_urb_m, q1_rur_m, q1_urb_f, q1_rur_f), 
                         ind_example = c(60, 95, 90, 96, 61, 50, 98, 95, 80, 90, 51, 49, 65, 58), 
                         full_labels = c("Poorest","Richest", "Richest men","Richest women", "Poorest men","Poorest women",
                                         "Richest urban men", "Richest rural men", "Richest urban women", "Richest rural women",
                                         "Poorest urban men", "Poorest rural men" , "Poorest urban women", "Poorest rural women"), 
                         short_labels= c("Poorest","Richest", "Men","Women", "Men","Women",
                                         "Urban", "Rural", "Urban", "Rural",
                                         "Urban", "Rural" , "Urban", "Rural"))
#WEALTH-SEX-LOCATION
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels)) +                 # Create ggplot2 plot without lines & curves
  geom_point()  
ggp

ggp+
  geom_segment(x = 1, #v line at level 1
               y = q1, 
               xend = 1, 
               yend =q5) +    
  geom_segment(x = 2, #v line upper 
               y = q5_m,  
               xend = 2, 
               yend =q5_f) +  
  geom_segment(x = 2,
               y = q1_m,   #v line down
               xend = 2, 
               yend =q1_f)  + 
  geom_segment(x = 3,    #v line 3rd level 1st
               y = q5_urb_m,
               xend = 3, 
               yend =q5_rur_m,  color="blue") +
  geom_segment(x = 3,  #v line 3rd level 2nd
               y = q5_urb_f,  
               xend = 3, 
               yend =q5_rur_f, color="red") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_m,  
               xend = 3, 
               yend =q1_rur_m, color="green") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_f,  
               xend = 3, 
               yend =q1_rur_f, color="pink") +
  geom_segment(x = 1,  #horizontal 1-2 up
               y = q5,  
               xend = 2, 
               yend =q5) +
  geom_segment(x = 2,  #horizontal 2-3 1st
               y = q5_m,  
               xend = 3, 
               yend =q5_m, color="blue") +
  geom_segment(x = 2, 
               y = q5_f,  #horizontal 2-3 2nd
               xend = 3, 
               yend =q5_f, color="red")+
  geom_segment(x = 1, #horizontal 1-2 down
               y = q1,  
               xend = 2, 
               yend =q1)+
  geom_segment(x = 2, 
               y = q1_m,  #horizontal 2-3 3rd
               xend = 3, 
               yend =q1_m, color="green")+
  geom_segment(x = 2, 
               y = q1_f,  #horizontal 2-3 4th
               xend = 3, 
               yend =q1_f, color="pink")+
  theme(panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())   +
  scale_y_continuous(limits = c(0.4, 1))+
  scale_x_continuous(n.breaks = 3, label = c("Wealth", "Sex", "Location")) +
  labs(y= "Primary completion", x="",  title = "The inequality tree: BGD 2019 MICS") +
  geom_label_repel(aes(label = short_labels),
                   box.padding   = 0.95, 
                   point.padding = 0.5,
                   segment.color = 'grey50')

ggplot(plot_data, aes(x=level, y=indicator, label = full_labels)) +
  geom_point() + geom_label_repel(aes(label = full_labels),
                                  box.padding   = 0.95, 
                                  point.padding = 0.5,
                                  segment.color = 'grey50')

