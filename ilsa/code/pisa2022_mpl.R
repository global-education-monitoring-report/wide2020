#PISA 2022 into WIDE indicators

library("tidyverse")
library("dplyr")
library("haven")
library("reshape2")
library("devtools")
#install_github("eldafani/intsvy")
library("intsvy") # version from github


# Data with country iso_codes
dir <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/pisa2022/zip of data"
cnt <- read.csv(file.path(dir, "iso_code.csv"))
# country data is complete

##Select PISA 2022 files to merge

pisa <- pisa.select.merge(folder = dir,
                          student.file="CY08MSP_STU_QQQ.sav",
                          school.file="CY08MSP_SCH_QQQ.sav",
                          student= c("ESCS", "ST004D01T", "ST022Q01TA"),
                          school = c("SC001Q01TA"))

##Get categories and country names

#pisa$COUNTRY <- cnt[match(pisa$CNT, cnt$iso_code3), "country"]
pisa$COUNTRY <- pisa$CNT

pisa$Sex <- factor(pisa$ST004D01T, labels = c("Female", "Male"))
pisa$Language <- factor(pisa$ST022Q01TA, labels = c("Yes", "No"))
#added 'megacity'
pisa$Location <- factor(pisa$SC001Q01TA, labels = c("Rural", rep("Urban", 5)))

#wealth
pisa <- pisa %>%
  group_by(COUNTRY) %>%
  filter(sum(is.na(ESCS)) != n() & 
           length(unique(quantile(ESCS, probs=seq(0,1, by=0.2), na.rm=TRUE)))==6) %>%
  mutate(Wealth = cut(ESCS, breaks=quantile(ESCS, probs=seq(0,1, by=0.2), na.rm=TRUE),
                      labels = c(1:5),  include.lowest=TRUE))

##Cutoffs and calculation by subject
#RUN ilsa_sum.R (!!!)

#cutoffs didn't change in reading
pisa22_r <- ilsa_sum(pvnames = "READ", 
                     cutoff = c(334.75, 407.47, 480.18, 552.89),
                     config = pisa_conf,
                     data = pisa,
                     year = 2022,
                     level = "Upper secondary",
                     grade = NA,
                     survey = "PISA",
                     prefix = "r")


#cutoffs didn't change in math
pisa22_m <- ilsa_sum(pvnames = "MATH", 
                     cutoff = c(357.77, 420.07, 482.38, 544.68),
                     config = pisa_conf,
                     data = pisa,
                     year = 2022,
                     level = "Upper secondary",
                     grade = NA,
                     survey = "PISA",
                     prefix = "m")

#cutoffs didn't change in science 
pisa22_s <- ilsa_sum(pvnames = "SCIE",
                     cutoff = c(334.94, 409.54, 484.14, 558.73),
                     config = pisa_conf,
                     data = pisa,
                     year = 2022,
                     level = "Upper secondary",
                     grade = NA,
                     survey = "PISA",
                     prefix = "s")

## Append datasets
datasets <- mget(grep("_r$|_m$|_s$", ls(), value = TRUE))
wide_data <- do.call(dplyr::bind_rows, datasets)

## Descriptives
summary(wide_data)
cat.vars <- grep("_m|_se|_no", names(wide_data), invert = TRUE, value = TRUE)
sapply(wide_data[cat.vars], table)

## Export

# reorder columns for wide
vars <- c("category", "Sex",  "Location", "Wealth", "Language")
vars <- intersect(names(wide_data), vars)
num.vars <- setdiff(names(wide_data), cat.vars)
id.vars <- setdiff(cat.vars, vars)

wide_data <- wide_data[c(id.vars, vars, num.vars)]

#made a mistake sorrry
wide_data <- wide_data %>% select(-year) %>% mutate(year=2022)

savedir <- "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/GitHub/wide2020/ilsa/data"
write.csv(wide_data, row.names = FALSE, na="", file = file.path(savedir, "pisa2022_mpl.csv"))
