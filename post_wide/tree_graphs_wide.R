## digital trees
##using WIDE data
# 4/5/2023

#
library(ggrepel)
library(ggplot2)
library(tidyverse)
library(ggthemes)
library(cowplot)

#to save graphs
#setwd("C:/Users/Lenovo PC/OneDrive - UNESCO/inequality_forest/")

#newlaptop
setwd("C:/Users/mm_barrios-rivera/OneDrive - UNESCO/inequality_forest/")


#Load WIDE dataset

#WIDE_2023_08_02 <- read_csv("C:/Users/Lenovo PC/OneDrive - UNESCO/WIDE files/2023/WIDE_2023_08_02.csv") 
#WIDE_2023_08_02 <- read_csv("C:/Users/Lenovo PC/OneDrive - UNESCO/WIDE files/2023/WIDE_2023.csv") 

#newlaptop
WIDE_2023_08_02 <- read_csv("C:/Users/mm_barrios-rivera/OneDrive - UNESCO//WIDE files/2023/WIDE_2023_19_04_2.csv") 


#See what's on 3D possibilities 

#choose indicator here
indicator <- 'mlevel2_m'

locsexwealth <- WIDE_2023_08_02 %>% filter(category=='Location & Sex & Wealth') %>% 
  filter(wealth %in% c('Quintile 1', 'Quintile 5')) %>% 
  select(iso_code, year, survey, category, sex, location, wealth, indicator) %>%
  mutate(group = str_c(sex, location, wealth))  %>%
  distinct() %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = group, 
               values_from = c(indicator) , values_fn = list ) 

#Exploring inequalities 

ranking_wealth_differences <- WIDE_2023_08_02 %>% filter(category=='Wealth') %>% filter(!is.na(country), !is.na(survey), !is.na(year)) %>%
  filter(wealth %in% c('Quintile 1', 'Quintile 5')) %>%
  select(iso_code, year, survey, category, sex, location, level,  wealth, indicator)  %>%
  #keep obs where all these vars have a value
  filter_at(vars( mlevel2_m), all_vars(!is.na(.))) %>% distinct() %>%
  filter(level=="end of primary") %>% #disable/comment his line if indicator is not for learning
  group_by(iso_code) %>%
  filter(year == max(year)) %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = wealth, 
               values_from = c(indicator)  ) %>%
  rename(Q1='Quintile 1') %>%  rename(Q5='Quintile 5') %>%
  mutate(wealth_dif=Q5-Q1) %>% arrange(-wealth_dif)

ranking_sex_differences <- WIDE_2023_08_02 %>% filter(category=='Sex') %>% filter(!is.na(country), !is.na(survey), !is.na(year)) %>%
  select(iso_code, year, survey, category, sex, location, wealth, level,indicator)  %>%
  #keep obs where all these vars have a value
  filter_at(vars(indicator), all_vars(!is.na(.))) %>% distinct() %>% filter(level=="end of primary") %>%
  group_by(iso_code) %>%
  filter(year == max(year)) %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = sex, 
               values_from = c(indicator)  ) %>%
  mutate(sex_dif=Male-Female) %>% arrange(-sex_dif)

ranking_location_differences <- WIDE_2023_08_02 %>% filter(category=='Location') %>% filter(!is.na(country), !is.na(survey), !is.na(year)) %>%
  select(iso_code, year, survey, category, sex, location, wealth, level,  indicator)  %>%
  #keep obs where all these vars have a value
  filter_at(vars(indicator), all_vars(!is.na(.))) %>% distinct() %>% 
  filter(level=="end of primary") %>% #disable/comment his line if indicator is not for learning
  group_by(iso_code) %>%
  filter(year == max(year)) %>%
  pivot_wider( id_cols= c(iso_code, year, survey, category),
               names_from = location, 
               values_from = c(indicator)  ) %>%
  mutate(loc_dif=Urban-Rural) %>% arrange(-loc_dif)

all_rankings_together <- left_join(ranking_sex_differences, ranking_wealth_differences, by=c("iso_code", "year", "survey")) %>% 
  left_join(ranking_location_differences, by=c("iso_code", "year", "survey"))

### explore inequalities IN ONE SURVEY 

extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="MEX" & survey=='TERCE' & year==2013 )

q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(mlevel2_m)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(mlevel2_m)

m <- extracted_survey %>% filter(category=="Sex") %>% filter(sex %in% c('Male')) %>% pull(mlevel2_m)
f <- extracted_survey %>% filter(category=="Sex") %>% filter(sex %in% c('Female')) %>% pull(mlevel2_m)

urb <- extracted_survey %>% filter(category=="Location") %>% filter(location %in% c('Urban')) %>% pull(mlevel2_m)
rur <- extracted_survey %>% filter(category=="Location") %>% filter(location %in% c('Rural')) %>% pull(mlevel2_m)

q5-q1
m-f
urb-rur


###############################################
###  TREE CHOICE 1 :WEALTH-LOCATION-SEX accessg -------
###############################################

#select survey
extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="BGD" & survey=='MICS' & year==2019 & is.na(level))
extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="COD" & survey=='MICS' & year==2018 & is.na(level))
extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="GHA" & survey=='MICS' & year==2018 & is.na(level))


rm(q1, q5, q5_urb, q5_rur, q1_urb, q1_rur, q5_urb_f, q5_urb_m,  q5_rur_f, q5_rur_m, q1_urb_f, q1_urb_m, q1_rur_f, q1_rur_m)

indicator <- 'comp_prim_v2_m'

q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(indicator)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(indicator)

q5_urb <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 5') & location %in% c('Urban')) %>% pull(indicator)
q5_rur <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 4') & location %in% c('Rural')) %>% pull(indicator)


q1_urb <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 1') & location %in% c('Urban')) %>% pull(indicator)
q1_rur <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 1') & location %in% c('Rural')) %>% pull(indicator)

q5_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q5_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q5_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q5_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)
#q5_rur_f <- -1
#q5_rur_m <- -1
#q5_urb <- 0.92



q1_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)

q1_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q1_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q1_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)
#q1_urb_f <- 0.7


plot_data  <- data.frame(level = c(1, 1, 2, 2, 2, 2, 3, 3, 3.5, 3.5, 3, 3, 3.5, 3.5),                      # Create example data frame
                         indicator = c(q1, q5, q5_urb, q5_rur, q1_urb, q1_rur, q5_urb_m, q5_urb_f, q5_rur_m, q5_rur_f, q1_urb_m, q1_urb_f, q1_rur_m, q1_rur_f), 
                         ind_example = c(60, 95, 90, 96, 61, 50, 98, 95, 80, 90, 51, 49, 65, 58), 
                         full_labels = c("Poorest","Richest", "Richest urban","Richest rural", "Poorest urban","Poorest rural",
                                         "Richest urban men", "Richest urban women", "Richest rural men", "Richest rural women",
                                         "Poorest urban men", "Poorest urban women" , "Poorest rural men", "Poorest rural women"), 
                         # short_labels= c("Poorest","Richest", "Urban","Rural", "Urban","Rural",
                         #                 "Men", "Women", "Men", "Women",
                         #                 "Men", "Women" , "Men", "Women"), 
                         short_labels= c("Poorest","Richest", "Urban","Rural", "Urban","Rural",
                                         "Men", "Women", "Men", "Women",
                                         "Men", "Women" , "Men", "Women"),
                         colors= c("black","black", "black","black", "black","black",
                                   "darkorange1", "darkorange1", "darkmagenta", "darkmagenta",
                                   "limegreen", "limegreen" , "dodgerblue3", "dodgerblue3"))
#WEALTH-LOCATION-SEX
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels), colour=short_labels) +                 # Create ggplot2 plot without lines & curves
  geom_point(colour=plot_data$colors)   
ggp

accessg <-   ggp+
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
               yend =q5_urb_f,  color="darkorange1") +
  geom_segment(x = 3.5,  #v line 3rd level 2nd
               y = q5_rur_m,  
               xend = 3.5, 
               yend =q5_rur_f, color="darkmagenta") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_m,  
               xend = 3, 
               yend =q1_urb_f, color="limegreen") +
  geom_segment(x = 3.5,  #v line 3rd level 4th
               y = q1_rur_m,  
               xend = 3.5, 
               yend =q1_rur_f, color="dodgerblue3") +
  geom_segment(x = 1,  #horizontal 1-2 up
               y = q5,  
               xend = 2, 
               yend =q5) +
  geom_segment(x = 2,  #horizontal 2-3 1st
               y = q5_urb,  
               xend = 3, 
               yend =q5_urb, color="darkorange1") +
  geom_segment(x = 2, 
               y = q5_rur,  #horizontal 2-3 2nd
               xend = 3.5, 
               yend =q5_rur, color="darkmagenta")+
  geom_segment(x = 1, #horizontal 1-2 down
               y = q1,  
               xend = 2, 
               yend =q1)+
  geom_segment(x = 2, 
               y = q1_urb,  #horizontal 2-3 3rd
               xend = 3, 
               yend =q1_urb, color="limegreen")+
  geom_segment(x = 2, 
               y = q1_rur,  #horizontal 2-3 4th
               xend = 3.5, 
               yend =q1_rur, color="dodgerblue3")+
  theme(panel.background = element_rect(fill = "gray93",
                                        colour = "gray93",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())   +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent)+
  scale_x_continuous(n.breaks = 4, label = c("Wealth", "Location", "Sex", "Sex")) +
  labs(y= "Primary completion (%)", x="") +
  geom_label_repel(aes(label = short_labels),
                   box.padding   = 0.95, 
                   point.padding = 0.5,
                   segment.color = 'grey50')
accessg

#ggsave("rlevel2_THA_2018_PISA.png", width = 7, height = 6, units = "in")
ggsave("rlevel2_CRI_2015_PISA.png", width = 7, height = 6, units = "in")
ggsave("comp_prim_TCD_2019_MICS_wls.png", width = 7, height = 6, units = "in")
ggsave("comp_prim_MDG_2021_DHS_wls.png", width = 7, height = 6, units = "in")
ggsave("comp_prim_AFG_2015_DHS_wls.png", width = 7, height = 6, units = "in")


#STAPH!




##################################################################
###  ANOTHER TREE CHOICE 2 :WEALTH-SEX-LOCATION w 4 levels -------
##################################################################

extracted_survey <- WIDE_2023_08_02 %>% filter(iso_code=="TCD" & survey=='MICS' & year==2019 & is.na(level))

#rm(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_f, q5_urb_m,  q5_rur_f, q5_rur_m, q1_urb_f, q1_urb_m, q1_rur_f, q1_rur_m)

indicator <- 'comp_prim_v2_m'

q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(indicator)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(indicator)

q5_m <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 5') & sex %in% c('Male') ) %>% pull(indicator)
q5_f <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 5') & sex %in% c('Female') ) %>% pull(indicator)

q1_m <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 1') & sex %in% c('Male')) %>% pull(indicator)
q1_f <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 1') & sex %in% c('Female')) %>% pull(indicator)

q5_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q5_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q5_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q5_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)

q1_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q1_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q1_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q1_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)

plot_data  <- data.frame(level = c(1, 1, 2, 2, 2, 2, 3, 3, 3.5, 3.5, 3, 3, 3.5, 3.5),                      # Create example data frame
                         indicator = c(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_m, q5_rur_m, q5_urb_f, q5_rur_f, q1_urb_m, q1_rur_m, q1_urb_f, q1_rur_f), 
                         ind_example = c(60, 95, 90, 96, 61, 50, 98, 95, 80, 90, 51, 49, 65, 58), 
                         full_labels = c("Poorest, 22%","Richest, 47%", "Richest men","Richest women", "Poorest men","Poorest women",
                                         "Richest urban men", "Richest rural men", "Richest urban women", "Richest rural women",
                                         "Poorest urban men", "Poorest rural men" , "Poorest urban women", "Poorest rural women"), 
                         short_labels= c("Poorest, 22%","Richest, 42%", "Men","Women", "Men","Women",
                                         "Urban", "Rural", "Urban", "Rural",
                                         "Urban", "Rural" , "Urban", "Rural"), 
                         colors= c("black","black", "black","black", "black","black",
                                   "darkorange1", "darkorange1", "darkmagenta", "darkmagenta",
                                   "limegreen", "limegreen" , "dodgerblue3", "dodgerblue3"))
#WEALTH-SEX-LOCATION
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels), colour=short_labels) +                 # Create ggplot2 plot without lines & curves
  geom_point(colour=plot_data$colors)  
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
               yend =q5_rur_m,  color="darkorange1") +
  geom_segment(x = 3.5,  #v line 3rd level 2nd
               y = q5_urb_f,  
               xend = 3.5, 
               yend =q5_rur_f, color="darkmagenta") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_m,  
               xend = 3, 
               yend =q1_rur_m, color="limegreen") +
  geom_segment(x = 3.5,  #v line 3rd level 4th
               y = q1_urb_f,  
               xend = 3.5, 
               yend =q1_rur_f, color="dodgerblue3") +
  geom_segment(x = 1,  #horizontal 1-2 up
               y = q5,  
               xend = 2, 
               yend =q5) +
  geom_segment(x = 2,  #horizontal 2-3 1st
               y = q5_m,  
               xend = 3, 
               yend =q5_m, color="darkorange1") +
  geom_segment(x = 2, 
               y = q5_f,  #horizontal 2-3 2nd
               xend = 3.5, 
               yend =q5_f, color="darkmagenta")+
  geom_segment(x = 1, #horizontal 1-2 down
               y = q1,  
               xend = 2, 
               yend =q1)+
  geom_segment(x = 2, 
               y = q1_m,  #horizontal 2-3 3rd
               xend = 3, 
               yend =q1_m, color="limegreen") +
  geom_segment(x = 2, 
               y = q1_f,  #horizontal 2-3 4th
               xend = 3.5, 
               yend =q1_f, color="dodgerblue3") +
  theme(panel.background = element_rect(fill = "gray93",
                                                           colour = "gray93",
                                                           size = 0.5, linetype = "solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())   +
  scale_y_continuous(limits = c(0, 0.8))+
  scale_x_continuous(n.breaks = 4, label = c("Wealth", "Sex", "Location", "Location")) +
  labs(y= "Primary completion", x="",  title = "The inequality tree: TCD MICS 2019") +
  geom_label_repel(aes(label = short_labels),
                   box.padding   = 0.95, 
                   point.padding = 0.5,
                   segment.color = 'grey50')

ggplot(plot_data, aes(x=level, y=indicator, label = full_labels)) +
  geom_point() + geom_label_repel(aes(label = full_labels),
                                  box.padding   = 0.95, 
                                  point.padding = 0.5,
                                  segment.color = 'grey50')

#ggsave("comp_prim_IRQ_2018_MICS.png", width = 7, height = 6, units = "in")
#ggsave("comp_prim_AFG_2015_DHS.png", width = 7, height = 6, units = "in")
#ggsave("comp_prim_MDG_2021_DHS_wsl.png", width = 7, height = 6, units = "in")
ggsave("comp_prim_TCD_2019_MICS_wsl.png", width = 7, height = 6, units = "in")


#COMP_PRIM 
#AFG DHS 2015 X
#MDG 2021 DHS  X X
#TCD 2019 mics X X
#IRQ 2018 MICS X

#m_level2
#CRI 2015 END OF LOWSEC PISA X
#THA 2019 PISA X

####MICS6 learning intake ----

path2pieces <- "C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/WIDE_2023_files/" 
path2learning <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/wide_aggregating_code/WIDE_2023_update/WIDE_2023_files/" 

mics_learning <- vroom::vroom(paste0(path2learning,"mics6_mpl.csv")) %>%
  mutate(survey= 'MICS') %>%
  #year issue 
  mutate(year = ifelse((iso_code3 == 'GUY' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'PSE' & survey == 'MICS' & year == 2019), 2020, year)) %>%
  mutate(year = ifelse((iso_code3 == 'KIR' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'MKD' & survey == 'MICS' & year == 2018), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'BEN' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'GHA' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'JOR' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'PNG' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'WSM' & survey == 'MICS' & year == 2020), 2019, year)) %>%
  mutate(year = ifelse((iso_code3 == 'COD' & survey == 'MICS' & year == 2017), 2018, year)) %>%
  mutate(year = ifelse((iso_code3 == 'CAF' & survey == 'MICS' & year == 2018), 2019, year))  %>%
  #level issue 
  mutate(level= case_when(
    grade == 3 ~ 'early grades',
    grade == 6 ~ 'end of primary')) %>% select(-grade) %>%
  #wealth 
  mutate(quin = case_when(is.na(Wealth)~ '', TRUE ~ 'Quintile ')) %>% 
  # #BIG FIX FOR WEALTH: 1 IS QUINTILE 5, 5 IS QUINTILE 1 
  # mutate(wealth_fix= case_when(
  #   Wealth == 1 ~ 5,
  #   Wealth == 2 ~ 4,
  #   Wealth == 3 ~ 3,
  #   Wealth == 4 ~ 2,
  #   Wealth == 5 ~ 1,)) 
  unite("wealth", c('quin', 'Wealth'), sep = "" , remove = TRUE, na.rm = TRUE) %>%
  rename(location = Location) %>% rename(sex = Sex)

#select MICS6 country 
extracted_survey <- mics_learning %>% filter(iso_code3=="TCD" & level=='end of primary')

#rm(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_f, q5_urb_m,  q5_rur_f, q5_rur_m, q1_urb_f, q1_urb_m, q1_rur_f, q1_rur_m)

indicator <- 'mlevel2_m'
#indicator <- 'rlevel2_m'


#WEALTH-SEX-LOCATION  ----

q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(indicator)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(indicator)

q5_m <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 5') & sex %in% c('Male') ) %>% pull(indicator)
q5_f <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 5') & sex %in% c('Female') ) %>% pull(indicator)

q1_m <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 1') & sex %in% c('Male')) %>% pull(indicator)
q1_f <- extracted_survey %>% filter(category=="Sex & Wealth") %>% filter(wealth %in% c('Quintile 1') & sex %in% c('Female')) %>% pull(indicator)

q5_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q5_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q5_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q5_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)

q1_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q1_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q1_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q1_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)

plot_data  <- data.frame(level = c(1, 1, 2, 2, 2, 2, 3, 3, 3.5, 3.5, 3, 3, 3.5, 3.5),                      # Create example data frame
                         indicator = c(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_m, q5_rur_m, q5_urb_f, q5_rur_f, q1_urb_m, q1_rur_m, q1_urb_f, q1_rur_f), 
                         ind_example = c(60, 95, 90, 96, 61, 50, 98, 95, 80, 90, 51, 49, 65, 58), 
                         full_labels = c("Poorest","Richest", "Richest men","Richest women", "Poorest men","Poorest women",
                                         "Richest urban men", "Richest rural men", "Richest urban women", "Richest rural women",
                                         "Poorest urban men", "Poorest rural men" , "Poorest urban women", "Poorest rural women"), 
                         short_labels= c("Poorest","Richest", "Men","Women", "Men","Women",
                                         "Urban", "Rural", "Urban", "Rural",
                                         "Urban", "Rural" , "Urban", "Rural"), 
                         colors= c("black","black", "black","black", "black","black",
                                   "darkorange1", "darkorange1", "darkmagenta", "darkmagenta",
                                   "limegreen", "limegreen" , "dodgerblue3", "dodgerblue3"))
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels), colour=short_labels) +                 # Create ggplot2 plot without lines & curves
  geom_point(colour=plot_data$colors)  
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
               yend =q5_rur_m,  color="darkorange1") +
  geom_segment(x = 3.5,  #v line 3rd level 2nd
               y = q5_urb_f,  
               xend = 3.5, 
               yend =q5_rur_f, color="darkmagenta") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_m,  
               xend = 3, 
               yend =q1_rur_m, color="limegreen") +
  geom_segment(x = 3.5,  #v line 3rd level 4th
               y = q1_urb_f,  
               xend = 3.5, 
               yend =q1_rur_f, color="dodgerblue3") +
  geom_segment(x = 1,  #horizontal 1-2 up
               y = q5,  
               xend = 2, 
               yend =q5) +
  geom_segment(x = 2,  #horizontal 2-3 1st
               y = q5_m,  
               xend = 3, 
               yend =q5_m, color="darkorange1") +
  geom_segment(x = 2, 
               y = q5_f,  #horizontal 2-3 2nd
               xend = 3.5, 
               yend =q5_f, color="darkmagenta")+
  geom_segment(x = 1, #horizontal 1-2 down
               y = q1,  
               xend = 2, 
               yend =q1)+
  geom_segment(x = 2, 
               y = q1_m,  
               #horizontal 2-3 3rd
               xend = 3, 
               yend =q1_m, color="limegreen") +
  geom_segment(x = 2, 
               y = q1_f,  #horizontal 2-3 4th
               xend = 3.5, 
               yend =q1_f, color="dodgerblue3") +
  theme(panel.background = element_rect(fill = "gray93",
                                        colour = "gray93",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())   +
  scale_y_continuous(limits = c(0, 1))+
  scale_x_continuous(n.breaks = 4, label = c("Wealth", "Sex", "Location", "Location")) +
  labs(y= "MPL in math, end of primary", x="",  title = "The inequality tree: TCD MICS 2019") +
  geom_label_repel(aes(label = short_labels),
                   box.padding   = 0.95, 
                   point.padding = 0.5,
                   segment.color = 'grey50')

#
#WEALTH-LOCATION-SEX learningg  ----

extracted_survey <- mics_learning %>% filter(iso_code3=="BGD" & level=='end of primary')
extracted_survey <- mics_learning %>% filter(iso_code3=="COD" & level=='end of primary')

extracted_survey <- mics_learning %>% filter(iso_code3=="GHA" & level=='end of primary')


#rm(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_f, q5_urb_m,  q5_rur_f, q5_rur_m, q1_urb_f, q1_urb_m, q1_rur_f, q1_rur_m)

indicator <- 'mlevel2_m'
indicator <- 'rlevel2_m'


q1 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 1')) %>% pull(indicator)
q5 <- extracted_survey %>% filter(category=="Wealth") %>% filter(wealth %in% c('Quintile 5')) %>% pull(indicator)

q5_urb <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 5') & location %in% c('Urban')) %>% pull(indicator)
q5_rur <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 5') & location %in% c('Rural')) %>% pull(indicator)

q1_urb <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 1') & location %in% c('Urban')) %>% pull(indicator)
q1_rur <- extracted_survey %>% filter(category=="Location & Wealth") %>% filter(wealth %in% c('Quintile 1') & location %in% c('Rural')) %>% pull(indicator)

q5_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q5_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q5_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q5_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 5') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)

q1_urb_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Female')) %>% pull(indicator)
q1_urb_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Urban') & sex %in% c('Male')) %>% pull(indicator)

q1_rur_f <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Female')) %>% pull(indicator)
q1_rur_m <- extracted_survey %>% filter(category=="Location & Sex & Wealth") %>% 
  filter(wealth %in% c('Quintile 1') & location %in% c('Rural') & sex %in% c('Male')) %>% pull(indicator)


plot_data  <- data.frame(level = c(1, 1, 2, 2, 2, 2, 3, 3, 3.5, 3.5, 3, 3, 3.5, 3.5),                      # Create example data frame
                         indicator = c(q1, q5, q5_urb, q5_rur, q1_urb, q1_rur, q5_urb_m, q5_urb_f, q5_rur_m, q5_rur_f, q1_urb_m, q1_urb_f, q1_rur_m, q1_rur_f), 
                         ind_example = c(60, 95, 90, 96, 61, 50, 98, 95, 80, 90, 51, 49, 65, 58), 
                         full_labels = c("Poorest","Richest", "Richest urban","Richest rural", "Poorest urban","Poorest rural",
                                         "Richest urban men", "Richest urban women", "Richest rural men", "Richest rural women",
                                         "Poorest urban men", "Poorest urban women" , "Poorest rural men", "Poorest rural women"), 
                         # short_labels= c("Poorest","Richest", "Urban","Rural", "Urban","Rural",
                         #                 "Men", "Women", "Men", "Women",
                         #                 "Men", "Women" , "Men", "Women"), 
                         short_labels= c("Poorest","Richest", "Urban","Rural", "Urban","Rural",
                                         "Men", "Women", "Men", "Women",
                                         "Men", "Women" , "Men", "Women"),
                         colors= c("black","black", "black","black", "black","black",
                                   "darkorange1", "darkorange1", "darkmagenta", "darkmagenta",
                                   "limegreen", "limegreen" , "dodgerblue3", "dodgerblue3"))
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels), colour=short_labels) +                 # Create ggplot2 plot without lines & curves
  geom_point(colour=plot_data$colors)   
ggp

learningg <-   ggp+
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
               yend =q5_urb_f,  color="darkorange1") +
  geom_segment(x = 3.5,  #v line 3rd level 2nd
               y = q5_rur_m,  
               xend = 3.5, 
               yend =q5_rur_f, color="darkmagenta") +
  geom_segment(x = 3,  #v line 3rd level 4th
               y = q1_urb_m,  
               xend = 3, 
               yend =q1_urb_f, color="limegreen") +
  geom_segment(x = 3.5,  #v line 3rd level 4th
               y = q1_rur_m,  
               xend = 3.5, 
               yend =q1_rur_f, color="dodgerblue3") +
  geom_segment(x = 1,  #horizontal 1-2 up
               y = q5,  
               xend = 2, 
               yend =q5) +
  geom_segment(x = 2,  #horizontal 2-3 1st
               y = q5_urb,  
               xend = 3, 
               yend =q5_urb, color="darkorange1") +
  geom_segment(x = 2, 
               y = q5_rur,  #horizontal 2-3 2nd
               xend = 3.5, 
               yend =q5_rur, color="darkmagenta")+
  geom_segment(x = 1, #horizontal 1-2 down
               y = q1,  
               xend = 2, 
               yend =q1)+
  geom_segment(x = 2, 
               y = q1_urb,  #horizontal 2-3 3rd
               xend = 3, 
               yend =q1_urb, color="limegreen")+
  geom_segment(x = 2, 
               y = q1_rur,  #horizontal 2-3 4th
               xend = 3.5, 
               yend =q1_rur, color="dodgerblue3")+
  theme(panel.background = element_rect(fill = "gray93",
                                        colour = "gray93",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())   +
  scale_y_continuous(limits = c(0, 1),  labels = scales::percent)+
  scale_x_continuous(n.breaks = 4, label = c("Wealth", "Location", "Sex", "Sex")) +
  labs(y= "Students reaching minimum proficiency in mathematics (%)", x="") +
  geom_label_repel(aes(label = short_labels),
                   box.padding   = 0.95, 
                   point.padding = 0.5,
                   segment.color = 'grey50')
learningg

#combined access learning plot  ----

plot_row <- plot_grid(accessg,learningg)
plot_row

# now add the title
title <- ggdraw() + 
  draw_label(
    "Ghana",
    fontface = 'bold',
    x = 0,
    hjust = 0
  ) +
  theme(
    # add margin on the left of the drawing canvas,
    # so title is aligned with left edge of first plot
    plot.margin = margin(0, 0, 0, 8)
  )

plot_grid(
  title, plot_row,
  ncol = 1,
  # rel_heights values control vertical title margins
  rel_heights = c(0.1, 1)
)

#doesnt work :(
  ggsave("paralel_BGD2019MICS_v2.png", width = 12, height = 8, units = "in" ,  bg = 'white')
  ggsave("paralel_COD2018MICS_v2.png", width = 12, height = 8, units = "in" ,  bg = 'white')
  ggsave("paralel_GHA2017MICS_v2.png", width = 12, height = 8, units = "in",  bg = 'white')
  

####

extracted_survey <- mics_learning %>% filter(iso_code3=="TCD" & level=='end of primary')

#rm(q1, q5, q5_m, q5_f, q1_m, q1_f, q5_urb_f, q5_urb_m,  q5_rur_f, q5_rur_m, q1_urb_f, q1_urb_m, q1_rur_f, q1_rur_m)

indicator <- 'mlevel2_m'
#indicator <- 'rlevel2_m'



####oldies ----

###  TREE CHOICE 2 :WEALTH-SEX-LOCATION




#WEALTH-LOCATION-SEX
ggp <- ggplot(plot_data, aes(level, indicator, label=short_labels), colour=short_labels) +                 # Create ggplot2 plot without lines & curves
  geom_point(colour=plot_data$colors)   
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
               yend =q1_urb, color="limegreen")+
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

#STAPH

#ghana
q1_urb_f <- 0.8444255
q1_urb_m <- 0.7046445
q1_urb <-0.74674809
q1 <-0.72190374


#Final EXCEL -----
#excel
library("writexl") 
sheets <- list("F1.2" = summary, "F1.3" = latest_year, "F2.2" = bycountry_time2, "F3.4" = dl_edu, "F4.1" = edu_att22, "F1_THAT" = argh) #assume sheet1 and sheet2 are data frames
write.xlsx(sheets, file = "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/graphs_44_v2.xlsx")

