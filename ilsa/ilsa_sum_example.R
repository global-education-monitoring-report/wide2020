### ilsa_summarize: Examples

library("tidyverse")
library("dplyr")
library("haven")
library("reshape2")
library("devtools")
library("intsvy") # version from github

# Data with country iso_codes
dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/Analysis/ILSA"
cnt <- read.csv(file.path(dir, "iso_code.csv"))

# PASEC 2014

## Read data
dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/PASEC"
pasec2 <- read_dta(file.path(dir, "PASEC2014_GRADE2.dta"))
pasec6 <- read_dta(file.path(dir, "PASEC2014_GRADE6.dta"))

sapply(unique(pasec2$COUNTRY), function(x) grep(x, toupper(iso$country)))

## Create grouping variables

### Grade 2
pasec2$COUNTRY <- cnt[match(pasec2$PAYS, cnt$pasec), "iso_code3"]
pasec2$Sex <- factor(pasec2$qe22, c(1,2), c("Male", "Female"))
pasec2$Language <- factor(pasec2$qe25, c(1:3), c(rep("Yes",2), "No"))
pasec2$Location <- factor(pasec2$qd24, c(1:4), c(rep("Urban",2), rep("Rural",2)))

### Grade 6
pasec6$COUNTRY <- cnt[match(pasec6$PAYS, cnt$pasec), "iso_code3"]
pasec6$Sex <- factor(pasec6$qe62, c(1,2), c("Male", "Female"))
pasec6$Language <- factor(pasec6$qe615, c(1:3), c(rep("Yes",2), "No"))
pasec6$Location <- factor(pasec6$qd24, c(1:4), c(rep("Urban",2), rep("Rural",2)))
pasec6$Wealth <- with(pasec6, cut(SES, 
                                  breaks=quantile(SES, probs=seq(0,1, by=0.2), na.rm=TRUE), 
                                  labels = c(1:5),
                                  include.lowest=TRUE))


pasec2_r<- ilsa_sum(pvnames = "LECT", 
         cutoff = c(399.1, 469.5, 540, 610.4),
         config = pasec_conf,
         data = pasec2,
         year = 2014,
         level = "Primary",
         grade = 2,
         survey = "PASEC",
         prefix = "r") # 'r' for reading, 'm' for maths and 's' for science

pasec2_m<- ilsa_sum(pvnames = "MATHS", 
                    cutoff =  c(66.9, 400.3, 489, 577),
                    config = pasec_conf,
                    data = pasec2,
                    year = 2014,
                    level = "Primary",
                    grade = 2,
                    survey = "PASEC",
                    prefix = "m")


pasec6_r <- ilsa_sum(pvnames = "LECT", 
                       cutoff =  c(365, 441.7, 518.4, 595.1),
                       config = pasec_conf,
                       data = pasec6,
                       year = 2014,
                       level = "Primary",
                       grade = 6,
                       survey = "PASEC",
                       prefix = "r")


pasec6_m <- ilsa_sum(pvnames = "MATHS", 
                     cutoff =   c(68.1, 433.3, 521.5, 609.6),
                     config = pasec_conf,
                     data = pasec6,
                     year = 2014,
                     level = "Primary",
                     grade = 6,
                     survey = "PASEC",
                     prefix = "m")



## PISA

dir <- "/home/eldani/eldani/International LSA/PISA/2018/Data"

# uncomment for full sample
# pisa.var.label(folder=dir, school.file= "CY07_MSU_SCH_QQQ.sav",
#                student.file="CY07_MSU_STU_QQQ.sav")
# 
# pisa <- pisa.select.merge(folder = dir,
#                           student.file="CY07_MSU_STU_QQQ.sav",
#                           school.file="CY07_MSU_SCH_QQQ.sav",
#                           student= c("ESCS", "ST004D01T", "ST022Q01TA"),
#                           school = c("SC001Q01TA"),
#                           countries = c("ALB","ARE", "ARG", "AUS", "AUT")) 
# remove 'countries' argument for full sample

pisa <- readRDS(file.path(dir, "pisa.rds")) # or change for 'pisa.rds' for full sample

pisa$COUNTRY <- pisa$CNT
pisa$Sex <- factor(pisa$ST004D01T, labels = c("Female", "Male"))
pisa$Language <- factor(pisa$ST022Q01TA, labels = c("Yes", "No"))

pisa$Wealth <- with(pisa, cut(ESCS, 
               breaks=quantile(ESCS, probs=seq(0,1, by=0.2), na.rm=TRUE), 
               labels = c(1:5),
               include.lowest=TRUE))

pisa$Location <- factor(pisa$SC001Q01TA, labels = c("Rural", rep("Urban", 4)))

pisa_r <- ilsa_sum(pvnames = "READ", 
                     cutoff = c(334.75, 407.47, 480.18, 552.89),
                     config = pisa_conf,
                     data = pisa,
                     year = 2018,
                     level = "Upper secondary",
                     grade = NA,
                     survey = "PISA",
                     prefix = "r")

pisa_m <- ilsa_sum(pvnames = "MATH", 
                   cutoff = c(357.77,  420.07,  482.38, 544.68),
                   config = pisa_conf,
                   data = pisa,
                   year = 2018,
                   level = "Upper secondary",
                   grade = NA,
                   survey = "PISA",
                   prefix = "m")

pisa_s <- ilsa_sum(pvnames = "SCIE", 
                   cutoff = c(334.94, 409.54, 484.14, 558.73),
                   config = pisa_conf,
                   data = pisa,
                   year = 2018,
                   level = "Upper secondary",
                   grade = NA,
                   survey = "PISA",
                   prefix = "s")


# PIRLS 2016
dir <- "/home/eldani/eldani/International LSA/PIRLS/PIRLS 2016/Data" 
pirls <- pirls.select.merge(folder= dir,
         student= c("ITSEX", "ASBG05A", "ASBG05B", "ASBG05C", "ASBG05D", "ASBG04", "ASBG03"), 
         home= c("ASBH04A", "ASBH17", "ASDHEDUP", "ASDHOCCP", "ASBH20A", "ASBH20B", "ASBH13"),
         school= c("ACBG05B"))

# Grouping variables

pirls$COUNTRY <- cnt[match(pirls$IDCNTRY, cnt$iso_num), "iso_code3"]
pirls <- droplevels(pirls[!is.na(pirls$COUNTRY), ])

pirls$Sex <- factor(pirls$ITSEX, c(1,2), c("Female", "Male"))

# ACBG05B
# 1: Urban–Densely populated; 2: Suburban–On fringe or outskirts of urban area; 
# 3: Medium size city or large town; 4: Small town or village; 5: Remote rural

pirls$Location <- factor(pirls$ACBG05B, c(1:4, 5), c(rep("Urban", 4), "Rural"))

pirls$Language <- factor(pirls$ASBG03, c(1:3,4), c(rep("Yes",3), "No"))

## Create Wealth quantles

### Parental education
pirls$pared <- pirls$ASDHEDUP
pirls$pared[pirls$pared==6] <-NA
pirls$pared <- 6-pirls$pared

### Parental occupation
# Father's ISEI
pirls$dadsei <- pirls$ASBH20A

pirls$dadsei[pirls$dadsei==1] <-22
pirls$dadsei[pirls$dadsei==2] <-57
pirls$dadsei[pirls$dadsei==3] <-49
pirls$dadsei[pirls$dadsei==4] <-45
pirls$dadsei[pirls$dadsei==5] <-31
pirls$dadsei[pirls$dadsei==6] <-37
pirls$dadsei[pirls$dadsei==7] <-33
pirls$dadsei[pirls$dadsei==8] <-24
pirls$dadsei[pirls$dadsei==9] <-67
pirls$dadsei[pirls$dadsei==10] <-73
pirls$dadsei[pirls$dadsei==11] <-52
pirls$dadsei[pirls$dadsei==12] <-NA

# Mother
pirls$momsei <- pirls$ASBH20B

pirls$momsei[pirls$momsei==1] <-22
pirls$momsei[pirls$momsei==2] <-57
pirls$momsei[pirls$momsei==3] <-49
pirls$momsei[pirls$momsei==4] <-45
pirls$momsei[pirls$momsei==5] <-31
pirls$momsei[pirls$momsei==6] <-37
pirls$momsei[pirls$momsei==7] <-33
pirls$momsei[pirls$momsei==8] <-24
pirls$momsei[pirls$momsei==9] <-67
pirls$momsei[pirls$momsei==10] <-73
pirls$momsei[pirls$momsei==11] <-52
pirls$momsei[pirls$momsei==12] <-NA

pirls$parsei <- with(pirls, pmax(dadsei, momsei, na.rm=T))

### Home possessions
pirls$pc <- pirls$ASBG05A
pirls$desk <- pirls$ASBG05B
pirls$room <- pirls$ASBG05C
pirls$internet <- pirls$ASBG05D

pos <- c("pc", "desk", "room", "internet")

pirls[pos][pirls[pos]==2] = 0

pirls$home <- apply(pirls[pos], 1, mean, na.rm=TRUE)


pirls$books <- pirls$ASBH13


### Create SES variable
ses.var <- c("pared", "parsei", "home", "books")

# SES with max values
ses.m <- princomp(na.omit(pirls[ses.var]), cor=T)
plot(ses.m,type="lines") # scree plot 
ses <- ses.m$scores[,1, drop=F]

# Match SES score with original data
pirls$ses <- ses[match(rownames(pirls), rownames(ses))] 

## Missing SES data
miss <- pirls %>%
  group_by(IDCNTRYL) %>%
  summarise(sum(is.na(ses))/n())

### Plot SES distribution
ggplot(pirls, aes(x=ses)) +
  geom_density() +
  facet_wrap(~IDCNTRYL)


## Create Wealth quantiles
pirls$Wealth <- with(pirls, cut(ses, 
                                breaks=quantile(ses, probs=seq(0,1, by=0.2), na.rm=TRUE), 
                                labels = c(1:5),
                                include.lowest=TRUE))

# Reading performance
pirls_r <- ilsa_sum(pvnames = "ASRREA", 
                     cutoff =   c(400, 475, 550, 625),
                     config = pirls_conf,
                     data = pirls,
                     year = 2016,
                     level = "Primary",
                     grade = 4,
                     survey = "PIRLS",
                     prefix = "r")


## Append datasets

datasets <- mget(grep("_r$|_m$|_s$", ls(), value = TRUE))
wide_data <- do.call(dplyr::bind_rows, datasets)

## Create country id
names(wide_data)[1] <- "iso_code3"
wide_data$country <- cnt[match(wide_data$iso_code3, cnt$iso_code3), "country"]

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

dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/Analysis/ILSA"
write.csv(wide_data, row.names = FALSE, na="", file = file.path(dir, "wide_data.csv"))




