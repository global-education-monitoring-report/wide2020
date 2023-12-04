### MICS6 data

library("tidyverse")
library("haven")
library("reshape2")
library("janitor")
library("ggplot2")
library("stringr")
library("ggpubr")
library("purrr")
library("readxl")


#dir <- "/home/eldani/eldani/International LSA/MICS6_FLS/"
dir <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/RISE/Cleaned/"

malawi <- haven::read_dta(paste0(dir,"clean_fs_malawi.dta")) %>% mutate(iso_code="MWI", year=2021)
nigeria <- haven::read_dta(paste0(dir,"clean_fs_nigeria.dta")) %>% mutate(iso_code="NGA", year=2020)


df <- bind_rows(malawi, nigeria)

# windex5	1=from family in the poorest wealth quintile; 5=from family in the richest wealth quintile
# sex HL4 male 1, female 2
# HH6	1=urban, 2=rural
# fsweight	Sampling weights

df <- mutate(df, 
             read = readskill, math = numbskill, 
             iso_code3 = iso_code,
             Sex = factor(HL4, 1:2, c("Male", "Female")), 
             Location = factor(HH6, 1:2, c("Urban", "Rural")), 
             Wealth = factor(windex5, 1:5, 1:5), 
             weight = fsweight) %>%
  mutate(allskills= case_when(
    read == 1 & math == 1 ~ 1 ,
    read ==0 | math ==0  ~ 0))
### Aggregate
dvs <- c("math", "read", "allskills")
ids <- c("iso_code3", "year", "grade")
groups <- c("Location", "Sex", "Wealth")
vars <- c(dvs, ids, groups, "weight")

df <- filter(df, grade %in% c(3, 6))
wide_data <- wide_bind(df, dvs, ids, groups)

dir <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/ilsa/data"
write.csv(wide_data_ext, row.names = FALSE, na="", file = file.path(dir, "mics6_mpl_sep2023.csv"))

ggplot(filter(wide_data, category=="Total"), 
       aes(x= reorder(iso_code3, allskills), y= allskills, fill= as.factor(grade))) +
  geom_bar(stat="identity", position = "dodge")

wide_data_ext <- wide_data %>% 
             mutate(rlevel2_no=n, mlevel2_no=n, survey = "MICS6") %>%
             rename(rlevel2_m = read, mlevel2_m = math) %>%
             select(-n)

ggplot(filter(wide_data_ext, category=="Total"), 
       aes(x= reorder(iso_code3, mlevel2_m), y= mlevel2_m, fill= as.factor(grade))) +
  geom_bar(stat="identity", position = "dodge")

## Export

dir <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/ilsa/data"
write.csv(wide_data_ext, row.names = FALSE, na="", file = file.path(dir, "mics6_mpl_sep2023.csv"))

