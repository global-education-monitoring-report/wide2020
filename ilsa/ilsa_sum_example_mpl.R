### ilsa_summarize: Examples

library("tidyverse")
library("dplyr")
library("haven")
library("reshape2")
library("devtools")
install_github("eldafani/intsvy")
library("intsvy") # version from github

# Data with country iso_codes
dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/Analysis/ILSA"
cnt <- read.csv(file.path(dir, "iso_code.csv"))
# country data is complete

# PASEC 2014

## Read data
dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/PASEC"
pasec2 <- read_dta(file.path(dir, "PASEC2014_GRADE2.dta"))
pasec6 <- read_dta(file.path(dir, "PASEC2014_GRADE6.dta"))

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

# pasec6$Wealth <- with(pasec6, cut(SES, 
#                                   breaks=quantile(SES, probs=seq(0,1, by=0.2), na.rm=TRUE), 
#                                   labels = c(1:5),
#                                   include.lowest=TRUE))


pasec6 <- pasec6 %>%
  group_by(COUNTRY) %>%
  mutate(Wealth = cut(SES, breaks=quantile(SES, probs=seq(0,1, by=0.2), na.rm=TRUE), 
                  labels = c(1:5), include.lowest=TRUE))
  

pasec2_r<- ilsa_sum(pvnames = "LECT", 
         cutoff = c(540),
         config = pasec_conf,
         data = pasec2,
         year = 2014,
         level = "Primary",
         grade = 2,
         survey = "PASEC",
         prefix = "r") # 'r' for reading, 'm' for maths and 's' for science

pasec2_m<- ilsa_sum(pvnames = "MATHS", 
                    cutoff =  c(489), # 66.9
                    config = pasec_conf,
                    data = pasec2,
                    year = 2014,
                    level = "Primary",
                    grade = 2,
                    survey = "PASEC",
                    prefix = "m")


pasec6_r <- ilsa_sum(pvnames = "LECT", 
                       cutoff =  c(518.4),
                       config = pasec_conf,
                       data = pasec6,
                       year = 2014,
                       level = "Primary",
                       grade = 6,
                       survey = "PASEC",
                       prefix = "r")


pasec6_m <- ilsa_sum(pvnames = "MATHS", 
                     cutoff =   c(521.5), #68.1,
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
pisa <- pisa.select.merge(folder = dir,
                          student.file="CY07_MSU_STU_QQQ.sav",
                          school.file="CY07_MSU_SCH_QQQ.sav",
                          student= c("ESCS", "ST004D01T", "ST022Q01TA"),
                          school = c("SC001Q01TA"))

# remove 'countries' argument for full sample

# pisa2 <- readRDS(file.path(dir, "pisa.rds")) # or change for 'pisa.rds' for full sample

#pisa$COUNTRY <- cnt[match(pisa$CNT, cnt$iso_code3), "country"]
pisa$COUNTRY <- pisa$CNT

pisa$Sex <- factor(pisa$ST004D01T, labels = c("Female", "Male"))
pisa$Language <- factor(pisa$ST022Q01TA, labels = c("Yes", "No"))

pisa$Location <- factor(pisa$SC001Q01TA, labels = c("Rural", rep("Urban", 4)))

pisa <- pisa %>%
  group_by(COUNTRY) %>%
  mutate(Wealth = cut(ESCS, breaks=quantile(ESCS, probs=seq(0,1, by=0.2), na.rm=TRUE),
        labels = c(1:5),  include.lowest=TRUE))

# pisa$Wealth <- with(pisa, cut(ESCS,
#                breaks=quantile(ESCS, probs=seq(0,1, by=0.2), na.rm=TRUE),
#                labels = c(1:5),
#                include.lowest=TRUE))


# Remove NAs
pisa <- droplevels(pisa[!is.na(pisa$PV1READ), ])

#dir <- "/home/eldani/eldani/International LSA/PISA/2018/Data"
#load(file.path(dir, "pisa.rda"))

pisa_r <- ilsa_sum(pvnames = "READ", 
                     cutoff = c(407.47),
                     config = pisa_conf,
                     data = pisa,
                     year = 2018,
                     level = "Upper secondary",
                     grade = NA,
                     survey = "PISA",
                     prefix = "r")



pisa_m <- ilsa_sum(pvnames = "MATH", 
                   cutoff = c(420.07),
                   config = pisa_conf,
                   data = pisa,
                   year = 2018,
                   level = "Upper secondary",
                   grade = NA,
                   survey = "PISA",
                   prefix = "m")

pisa_s <- ilsa_sum(pvnames = "SCIE", 
                   cutoff = c(409.54),
                   config = pisa_conf,
                   data = pisa,
                   year = 2018,
                   level = "Upper secondary",
                   grade = NA,
                   survey = "PISA",
                   prefix = "s")

# Fix column names
# 
# # reading
# pisa_r$rlevel1_se <- NULL
# names(pisa_r)[11:14] <- c("rlevel1_se", "rlevel2_se", "rlevel3_se", "rlevel4_se")
# 
# pisa_r$rlevel2_no <- NULL
# names(pisa_r)[15:18] <- c("rlevel1_no", "rlevel2_no", "rlevel3_no", "rlevel4_no")
# pisa_r[, 19] <- NULL
# 
# # maths
# pisa_m$mlevel1_se <- NULL
# names(pisa_m)[11:14] <- c("mlevel1_se", "mlevel2_se", "mlevel3_se", "mlevel4_se")
# 
# pisa_m$mlevel2_no <- NULL
# names(pisa_m)[15:18] <- c("mlevel1_no", "mlevel2_no", "mlevel3_no", "mlevel4_no")
# pisa_m[, 19] <- NULL
# 
# # science
# pisa_s$slevel1_se <- NULL
# names(pisa_s)[11:14] <- c("slevel1_se", "slevel2_se", "slevel3_se", "slevel4_se")
# 
# pisa_s$slevel2_no <- NULL
# names(pisa_s)[15:18] <- c("slevel1_no", "slevel2_no", "slevel3_no", "slevel4_no")
# pisa_s[, 19] <- NULL


# PIRLS 2016
dir <- "/home/eldani/eldani/International LSA/PIRLS/PIRLS 2016/Data" 
pirls <- pirls.select.merge(folder= dir,
         student= c("ITSEX", "ASBG05A", "ASBG05B", "ASBG05C", "ASBG05D", "ASBG04", "ASBG03"), 
         home= c("ASBH04A", "ASBH17", "ASDHEDUP", "ASDHOCCP", "ASBH20A", "ASBH20B", "ASBH13"),
         school= c("ACBG05B"))

# Grouping variables

pirls$IDCNTRYL <- cnt[match(pirls$IDCNTRY, cnt$iso_num), "country"]
pirls$COUNTRY <- cnt[match(pirls$IDCNTRY, cnt$iso_num), "iso_code3"]
pirls$COUNTRY <- ifelse(is.na(pirls$COUNTRY), pirls$IDCNTRYL, pirls$COUNTRY)


pirls <- droplevels(pirls[!is.na(pirls$COUNTRY), ])

pirls$Sex <- factor(pirls$ITSEX, c(1,2), c("Female", "Male"))

# ACBG05B
# 1: Urban–Densely populated; 2: Suburban–On fringe or outskirts of urban area; 
# 3: Medium size city or large town; 4: Small town or village; 5: Remote rural

pirls$Location <- factor(pirls$ACBG05B, c(1:4, 5), c(rep("Urban", 4), "Rural"))

pirls$Language <- factor(pirls$ASBG03, c(1:3,4), c(rep("Yes",3), "No"))

## Create Wealth quantles (Caro and Cortes, 2012)

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

## Create Wealth quantiles

with(pirls, tapply(ses, COUNTRY, function(x) sum(is.na(x))/length(x)))

pirls <- pirls %>%
  group_by(COUNTRY) %>%
  filter(sum(is.na(ses)) != n() & 
           length(unique(quantile(ses, probs=seq(0,1, by=0.2), na.rm=TRUE)))==6) %>%
  mutate(ses_mis = sum(is.na(ses)) == n(), 
         Wealth = cut(ses, breaks=quantile(ses, probs=seq(0,1, by=0.2), na.rm=TRUE), 
                                labels = c(1:5),
                                include.lowest=TRUE))
# 
# pirls$Wealth <- with(pirls, cut(ses,
#                                 breaks=quantile(ses, probs=seq(0,1, by=0.2), na.rm=TRUE),
#                                 labels = c(1:5),
#                                 include.lowest=TRUE))

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
wide_data$COUNTRY <- cnt[match(wide_data$iso_code3, cnt$iso_code3), "country"]
wide_data$COUNTRY <- ifelse(is.na(wide_data$COUNTRY), wide_data$iso_code3, wide_data$COUNTRY)
wide_data$iso_num <- cnt[match(wide_data$COUNTRY, cnt$country), "iso_num"]

#wide_data$iso_code3 <- cnt[match(wide_data$COUNTRY, cnt$country), "iso_code3"]

#wide_data$country <- cnt[match(wide_data$iso_code3, cnt$iso_code3), "country"]

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
write.csv(wide_data, row.names = FALSE, na="", file = file.path(dir, "wide_data_mpl.csv"))
