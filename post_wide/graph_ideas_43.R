##Graph ideas: clean version for 4.3 chapter

#setup of data frames

library(ggplot2)
library(tidyverse)
library(cowplot)
library(ggrepel)

#march update:
path2uisdata2 <- 'C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/UIS info/'

#Participation rate of youth and adults in formal and non-formal education and training in the previous 12 months, 15-24 years old, both sexes (%)
PRYA.12MO.AG15T24
PRYA.12MO.AG15T24.F
PRYA.12MO.AG15T24.M

#ACTUALLY IT'S NOT 15-24 COHORT BUT 25-54
PRYA.12MO.AG25T54
PRYA.12MO.AG25T54.F
PRYA.12MO.AG25T54.GPIA
PRYA.12MO.AG25T54.M


#Gross enrolment ratio for tertiary education, both sexes (%)
GER.5T8
GER.5T8.F
GER.5T8.GPIA
GER.5T8.M

#by wealth
GAR.5T8.Q1
GAR.5T8.Q2
GAR.5T8.Q3
GAR.5T8.Q4
GAR.5T8.Q5

#by location 
GAR.5T8.RUR
GAR.5T8.URB

#Proportion of 15- to 24-year-olds enrolled in vocational education, both sexes (%)
EV1524P.2T5.V
EV1524P.2T5.V.F
EV1524P.2T5.V.M

uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
    mutate(indicator_id = toupper(indicator_id))
}

varlabels <-  read.csv(paste0(path2uisdata2, 'SDG_LABEL.csv'), na = '') %>% rename(indicator_id=INDICATOR_ID)

regions <-   vroom::vroom(paste0(path2uisdata2, 'countries_updated.csv'), na = '') %>%
  rename(country_id=iso3c)  %>% select(country_id, GEMR.region, income_group, income_subgroup)

indicators2extract <- c('PRYA.12MO.AG15T24' )
indicators2extract <- c('PRYA.12MO')

indicators2extract <- c('PRYA.12MO.AG25T54' )





uis_extraction <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('.M')),  !str_detect(indicator_id, fixed('.F'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #var labels
  left_join(varlabels, by="indicator_id") 


# F1 ----
# Figure 1: Across countries, participation rates are similar between males and females
#Participation rate of youth and adults in formal and non-formal education and training in 
#the previous 12 months, by sex

prya_data <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) 
rm(prya_data)

f1 <-   vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('.M')),  !str_detect(indicator_id, fixed('.F'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
  unite(incgroup2, c("income_group", "income_subgroup")) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='_NA',replacement = '')) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='Middle_',replacement = '')) %>%
  filter(!incgroup2=='NA') %>%  filter(!incgroup2=='Not Classified')  %>%
    #var labels
  left_join(varlabels, by="indicator_id") %>% filter(year > 2017 ) %>% 
  #keep last year per country 
  group_by(country_id) %>% filter(year == max(year)) %>%
  #crazy data cleanup: high unlikely outliers DJI and BRB 
  filter(!(country_id=='DJI' | country_id=='BRB')) 


  
#this is an alternative 

ggplot(f1, aes(x = value ,  fill = GEMR.region)) + 
  geom_dotplot(method='histodot', stackratio = 1,  binwidth = 1.5)+
  ggtitle("Participation rate of youth and adults in formal and non-formal education and training \nin the previous 12 months") +
    xlab("Participation (%) ") + ylab("")


ggplot(f1, aes(x = value , y = 0,  fill = incgroup2)) +
  geom_dotplot(method='histodot', stackratio = 1, binwidth = 1)+
  ggtitle("Participation rate of youth and adults in formal and non-formal education and training \nin the previous 12 months") +
  xlab("Participation (%) ") + ylab("") 

ggplot(data=f1, aes(x=value, group=incgroup2, fill=incgroup2)) +
  geom_density(adjust=1.5, alpha=.4)+
  ggtitle("Participation rate of youth and adults in formal and non-formal education and training \nin the previous 12 months") +
  xlab("Participation (%) ") + ylab("") 

#by gender? 

f1_m <- vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste('PRYA.12MO.AG25T54.M', collapse = '|'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
  unite(incgroup2, c("income_group", "income_subgroup")) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='_NA',replacement = '')) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='Middle_',replacement = '')) %>%
  filter(!incgroup2=='NA') %>%  filter(!incgroup2=='Not Classified')  %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>% filter(year > 2017 & year < 2022) %>%
  #keep last year per country 
  group_by(country_id) %>% filter(year == max(year)) %>% mutate(gender="Male")  %>%
  #crazy data cleanup: high unlikely outliers DJI and BRB 
  filter(!(country_id=='DJI' | country_id=='BRB')) 

ggplot(data= f1_m,  aes(x=value)) +
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)
  
ggplot(f1_m, aes(x = value ,  fill = GEMR.region)) +
  geom_dotplot(method='histodot', stackratio = 1)

f1_f <- vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste('PRYA.12MO.AG25T54.F', collapse = '|'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
  unite(incgroup2, c("income_group", "income_subgroup")) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='_NA',replacement = '')) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='Middle_',replacement = '')) %>%
  filter(!incgroup2=='NA') %>%  filter(!incgroup2=='Not Classified')  %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>% filter(year > 2017 & year < 2022) %>%
  #keep last year per country 
  group_by(country_id) %>% filter(year == max(year)) %>% mutate(gender="Female")  %>%
  #crazy data cleanup: high unlikely outliers DJI and BRB 
  filter(!(country_id=='DJI' | country_id=='BRB')) 

ggplot(f1_f, aes(x = value ,  fill = GEMR.region)) +
  geom_dotplot(method='histodot', stackratio = 0.7)

ggplot(data= f1_f,  aes(x=value)) +
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)

f1_sex <- bind_rows(f1_m, f1_f) %>% pivot_wider(names_from = gender, values_from = value)

g <- ggplot(f1_sex, aes(x)) + geom_histogram( aes(x = Male, y = ..density..),
                                         binwidth = diff(range(f1_m$value))/30, fill="#404080") + 
  geom_histogram( aes(x = Female, y = -..density..), binwidth = diff(range(f1_f$value))/30, fill= "#69b3a2")+
  geom_label(x=13, y=0.05, label="Male", color="#404080")  +
geom_label(x=13, y=-0.05, label="Female", color="#69b3a2" )   + 
  ggtitle("Participation rate of youth and adults in formal and non-formal education and training, \n25-54 years old") +
  xlab("Participation (%) ") + ylab("") 

print(g)

print(g + coord_flip())

#density alternative

p <- ggplot(f1_sex, aes(x=x) ) +
  # Top
  geom_density( aes(x = Male, y = ..density..), fill="#69b3a2" ) +
  geom_label( aes(x=4.5, y=0.25, label="Male participation"), color="#69b3a2") +
  # Bottom
  geom_density( aes(x = Female, y = -..density..), fill= "#404080") +
  geom_label( aes(x=4.5, y=-0.25, label="Female participation"), color="#404080") +
  xlab("value of x")

p


#F2 ----
#Figure 2: Participation rates have barely changed in most countries since 2015

f2 <- vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('.M')),  !str_detect(indicator_id, fixed('.F'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
  unite(incgroup2, c("income_group", "income_subgroup")) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='_NA',replacement = '')) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='Middle_',replacement = '')) %>%
  filter(!incgroup2=='NA') %>%  filter(!incgroup2=='Not Classified')  %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>% filter(year > 2014 ) %>% 
  #crazy data cleanup: high unlikely outliers DJI and BRB 
  filter(!(country_id=='DJI' | country_id=='BRB')) %>% 
  #count obs per country 
  group_by(country_id) %>% mutate(yearcount = n()) %>% 
  filter(yearcount > 5) %>%
  arrange(desc(-year))
  
f2_subset <- f2 %>% filter(GEMR.region=='Europe and Northern America' | GEMR.region=='Latin America and the Caribbean')
  
timeseries <- ggplot(data=f2_subset, aes(x=year, y=value, color = country_id)) + geom_line()+
  ggtitle("Participation rates have barely changed") 

plot(timeseries + facet_wrap(~incgroup2) ) 

plot(timeseries + facet_wrap(~GEMR.region) ) 

#now lets play pivoting 
#to recreate Ben's idea 
f2_pivot <- pivot_wider(f2, names_from = year, values_from = value,  names_prefix = "year") %>%
  mutate(chg1520 = year2020- year2015, chg1521 = year2021- year2015, 
         c16= year2016- year2015, c17= year2017- year2016, c18= year2018- year2017, c19= year2019- year2018, 
         c20= year2020- year2019, c21= year2021- year2020) %>% 
  mutate(avg_annualc = mean(c(c16, c17, c18, c19, c20, c21), na.rm = TRUE) ) %>%
  arrange(desc(chg1520))

ggplot(f2_pivot, aes(x=chg1520, fill =incgroup2)) + 
  geom_histogram(binwidth=0.5) + 
  ggtitle("Participation rate change between 2015 and 2020") +
  xlab("Participation (%) ") + ylab("") 


f2_pivot2 <- f2_pivot %>% filter(!is.na(chg1520))

timevariation <- ggplot(f2_pivot2,  aes(x=reorder(country_id,chg1520) , y=chg1520, fill=incgroup2)) +
  geom_bar(stat="identity") 

timevariation 

f2_pivot3 <- f2_pivot %>% filter(!is.na(chg1521))

timevariation3 <- ggplot(f2_pivot3,  aes(x=reorder(country_id,chg1521) , y=chg1521, fill=incgroup2)) +
  geom_bar(stat="identity") 

timevariation3

timevariation4 <- ggplot(f2_pivot,  aes(x=reorder(country_id,avg_annualc) , y=avg_annualc, fill=incgroup2)) +
  geom_bar(stat="identity") + 
  ggtitle("Average annual change in participation") +
  xlab("Country ") + ylab("% change in a year") 

timevariation4

#the chosen graphsss ----

#1

f1 <- f1 %>% mutate(incgroup3 = case_when(incgroup2 == 'High' ~ 'High income',
                                    incgroup2 == 'Low' ~ 'Low income',
                                    incgroup2 == 'Lower middle' ~ 'Lower-middle income',
                                    incgroup2 == 'Upper middle' ~ 'Upper-middle income',
                               TRUE ~ ""))


f1_byincgroup <-  ggplot(f1, aes(x = value , y = 0,  fill = incgroup3)) +
  geom_dotplot(method='histodot', stackratio = 1, binwidth = 0.8, stat="identity", stackgroups=TRUE)  +
  theme(legend.position = "bottom",  axis.text.y=element_blank(), axis.title.y=element_blank(), 
        legend.title=element_blank(), axis.ticks.y=element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(), plot.background = element_blank()) +
  #scale_x_continuous(labels = scales::percent_format(scale = 1))+
  xlab("Participation rate (%)") +
    scale_fill_manual(values = c("#E60080", "#96c11f", "#1980D9", "#009a93"), 
                      limits = c("High income", "Upper-middle income", "Lower-middle income", "Low income"))
f1_byincgroup 


f1_byincgroup <-  ggplot(f1, aes(x = value ,  fill = incgroup3)) +
  geom_histogram(binwidth = 1)  +
  theme(legend.position = "bottom",  axis.text.y=element_blank(), axis.title.y=element_blank(), 
        legend.title=element_blank(), axis.ticks.y=element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(), plot.background = element_blank()) +
  #scale_x_continuous(labels = scales::percent_format(scale = 1))+
  xlab("Participation rate (%)") +
  scale_fill_manual(values = c("#E60080", "#96c11f", "#1980D9", "#009a93"), 
                    limits = c("High income", "Upper-middle income", "Lower-middle income", "Low income"))
f1_byincgroup 


#THIS
# TRY IN EXCEL
# NO VERTICAL LABELS IN Y AXIS ok
# Y AXIS UP TO 0.5 doesnt work
# NO TITTLE ok
# LEGEND ORDER AND COMPLETE NAME ok
# BACKGROUND AREA WHITE, NO GREY ok 
# FIG 3.8 FOR COLORS ok 

#2

#THIS
#NO TITTLE 
#Y AXIS INTO 20% = # COUNTRIES COUNT
#  BACKGROUND INTO WHITE 


gender1 <- ggplot(f1_sex, aes(x)) + geom_histogram( aes(x = Male, y = ..density..),
                                                    binwidth = 1, fill="#96c11f") + 
  geom_histogram( aes(x = Female, y = -..density..), binwidth = 1, fill= "#006ea6")+
  geom_label(x=23, y=0.05, label="Male", label.size = NA, size=5)  +
  #geom_label(x=10, y=0.2, label="27 countries between 1% and 2%", color="#96c11f", label.size = NA)  +
  geom_label(x=23, y=-0.05, label="Female",label.size = NA, size=5 )   + 
  #geom_label(x=10, y=-0.15, label="28 countries between 1% and 2%", color="#006ea6", label.size = NA )   + 
    xlab("Participation rate (%) ") + ylab("") + theme(panel.background = element_blank(),
                                                axis.text.y=element_blank(), axis.ticks.y=element_blank()) +
  scale_x_continuous(labels = scales::percent_format(scale = 1))
  

plot(gender1)


#3 

timeseries <- ggplot(data=f2_subset, aes(x=year, y=value, color = country_id)) + geom_line() +
   theme(panel.background = element_blank()) + ylab("Participation rate")


tlines2 <- timeseries + facet_wrap(~GEMR.region)+ scale_y_continuous(labels = scales::percent_format(scale = 1))

plot(tlines2)

#4

ggplot(f2_pivot, aes(x=chg1520, fill =incgroup2)) + 
  geom_histogram(binwidth=1, col=I("grey")) + 
  scale_fill_manual(values = c( "#96c11f", "#1980D9", "#E60080"), labels = c(
    "High" = "High income",
    "Upper middle" = "Upper-middle income",
    "Lower middle" = "Lower-middle income" ), limits = c("High", "Upper middle", "Lower middle" )) +
    xlab("Change in participation rate (percentage points) ") + ylab("") +
  theme(panel.background = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank(), 
        legend.title = element_blank(), legend.position = "bottom") 



#excel
library(writexl)
library(openxlsx)
sheets <- list("F1 by country group" = f1, "F1 by gender" = f1_sex, "F2 spaghetti" = f2_subset) #assume sheet1 and sheet2 are data frames
write.xlsx(sheets, file = "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/writeXLSX2.xlsx")

sheets <- list("F2" = f2_pivot)
write.xlsx(sheets, file = "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/erase.xlsx")
