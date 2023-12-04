library("readxl")
library(tidyverse)
library(ggplot2)


dir <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/spot-lighting/"
data <- read_excel(paste0(dir,"mics6_mpl.xlsx"), sheet = "mics6_mpl")

spotlight_data <- data %>% filter(!is.na(`FILTER AFRICA`))


ggplot(filter(spotlight_data, category=="Total"), 
       aes(x= reorder(iso_code3, mlevel2_m), y= mlevel2_m, fill= as.factor(grade))) +
  geom_bar(stat="identity", position = "dodge")

ggplot(filter(spotlight_data, category=="Total"), 
       aes(x= reorder(iso_code3, rlevel2_m), y= rlevel2_m, fill= as.factor(grade))) +
  geom_bar(stat="identity", position = "dodge")

#gender

ggplot(filter(spotlight_data, category=="Sex" & grade==3 ), 
       aes(x= reorder(iso_code3, mlevel2_m), y= mlevel2_m, fill= as.factor(Sex))) +
  geom_bar(stat="identity", position = "dodge")

ggplot(filter(spotlight_data, category=="Sex" & grade==6 ), 
       aes(x= reorder(iso_code3, mlevel2_m), y= mlevel2_m, fill= as.factor(Sex))) +
  geom_bar(stat="identity", position = "dodge")

ggplot(filter(spotlight_data, category=="Sex"), 
       aes(x= reorder(iso_code3, rlevel2_m), y= rlevel2_m, fill= as.factor(Sex))) +
  geom_bar(stat="identity", position = "dodge")


#wealth
ggplot(filter(spotlight_data, category=="Wealth" & grade==3 ), 
       aes(x= reorder(iso_code3, mlevel2_m), y= mlevel2_m, fill= as.factor(Wealth))) +
  geom_bar(stat="identity", position = "dodge")

ggplot(filter(spotlight_data, category=="Wealth"), 
       aes(x= reorder(iso_code3, rlevel2_m), y= rlevel2_m, fill= as.factor(Wealth))) +
  geom_bar(stat="identity", position = "dodge")


#location 

ggplot(filter(spotlight_data, category=="Location" & grade==3), 
       aes(x= reorder(iso_code3, rlevel2_m), y= rlevel2_m, fill= as.factor(Location))) +
  geom_bar(stat="identity", position = "dodge")

ggplot(filter(spotlight_data, category=="Location"), 
       aes(x= reorder(iso_code3, mlevel2_m), y= mlevel2_m, fill= as.factor(Location))) +
  geom_bar(stat="identity", position = "dodge")
