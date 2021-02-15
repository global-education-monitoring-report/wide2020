### ilsa_summarize: Examples

library("tidyverse")
library("dplyr")
library("haven")
library("reshape2")
library("devtools")
#install_github("eldafani/intsvy")
library("intsvy") # version from github

# Data with country iso_codes
dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/Analysis/ILSA"
cnt <- read.csv(file.path(dir, "iso_code.csv"))
# country data is complete

# TERCE 2013

## Create pooled data

### Assessment data

dir <- "/home/eldani/eldani/International LSA/LLECE/TERCE/Logro-de-aprendizaje"
files <- grep(".dta$", list.files(dir), value = TRUE)

test <- lapply(files, function(x) {
  df = read_dta(file.path(dir, x));
  df$idgrade = as.numeric(substr(x, 3,3));
  df$area = substr(x, 2,2);
  df }
  )

vars <- Reduce(intersect, lapply(test, names))
test <- do.call(rbind, lapply(test, function(x) x[vars]))

### Student data
dir <- "/home/eldani/eldani/International LSA/LLECE/TERCE/Factores-asociados/Alumnos"
files <- grep("^QA", list.files(dir), value=TRUE)
student <- lapply(files, function(x) read_dta(file.path(dir, x)))
vars <- Reduce(intersect, lapply(student, names))
student <- do.call(rbind, lapply(student, function(x) x[vars]))

### Family data
dir <- "/home/eldani/eldani/International LSA/LLECE/TERCE/Factores-asociados/Familia"
files <- grep("^QF", list.files(dir), value=TRUE)
family <- lapply(files, function(x) read_dta(file.path(dir, x)))
vars <- Reduce(intersect, lapply(family, names))
family <- do.call(rbind, lapply(family, function(x) x[vars]))

### Merge files
terce <- left_join(test, student, by =c("idgrade", "country", "idschool", "idclass", "idstud"))
terce <- left_join(terce, family, by =c("idgrade", "country", "idschool", "idclass", "idstud"))


## Crete grouping variables

terce <- terce %>%
  mutate(COUNTRY =  recode(country,  `HON` =  "HND", `PAR` = "PRY", 
                                  `REP`= "DOM", `URU` = "URY"))


terce$Sex <- factor(terce$nina, c(0,1), c("Male", "Female"))
terce$Language <- factor(terce$DQFIT07, 1:6, c("Yes", rep("No", 5)))
terce$Location <- factor(terce$ruralidad, 1:2, c("Urban", "Rural"))

terce <- terce %>%
  group_by(COUNTRY) %>%
  filter(sum(is.na(ISECF)) != n() & 
           length(unique(quantile(ISECF, probs=seq(0,1, by=0.2), na.rm=TRUE)))==6) %>%
  mutate(Wealth = cut(ISECF, breaks=quantile(ISECF, probs=seq(0,1, by=0.2), na.rm=TRUE),
                      labels = c(1:5),  include.lowest=TRUE))


# Calculate MPL

## Reading


terce$wgt_sen <-terce$wgL_sen.x

terce3_r <- ilsa_sum(pvnames = "vp", 
                     cutoff = c(676, 729, 813),
                     config = llece_conf,
                     data = filter(terce, idgrade==3 & area =="L"),
                     year = 2013,
                     level = "Primary",
                     grade = 3,
                     survey = "TERCE",
                     prefix = "r")


terce6_r <- ilsa_sum(pvnames = "vp", 
                     cutoff = c(612, 754, 810),
                     config = llece_conf,
                     data = filter(terce, idgrade==6 & area =="L"),
                     year = 2013,
                     level = "Primary",
                     grade = 6,
                     survey = "TERCE",
                     prefix = "r")

## Maths

terce$wgt_sen <-terce$wgM_sen.x

terce3_m <- ilsa_sum(pvnames = "vp", 
                     cutoff = c(688, 750, 843),
                     config = llece_conf,
                     data = filter(terce, idgrade==3 & area =="M"),
                     year = 2013,
                     level = "Primary",
                     grade = 3,
                     survey = "TERCE",
                     prefix = "m")


terce6_m <- ilsa_sum(pvnames = "vp", 
                     cutoff = c(687, 789, 878),
                     config = llece_conf,
                     data = filter(terce, idgrade==6 & area =="M"),
                     year = 2013,
                     level = "Primary",
                     grade = 6,
                     survey = "TERCE",
                     prefix = "m")


## Science

terce$wgt_sen <-terce$wgC_sen

terce6_s <- ilsa_sum(pvnames = "vp", 
                     cutoff = c(669, 782, 862),
                     config = llece_conf,
                     data = filter(terce, idgrade==6 & area =="C"),
                     year = 2013,
                     level = "Primary",
                     grade = 6,
                     survey = "TERCE",
                     prefix = "s")



## Append datasets
datasets <- mget(grep("_r$|_m$|_s$", ls(), value = TRUE))
wide_data <- do.call(dplyr::bind_rows, datasets)

## Create country id
names(wide_data)[1] <- "iso_code3"
wide_data$iso_code3 <-as.character(wide_data$iso_code3)
wide_data$COUNTRY <- cnt[match(wide_data$iso_code3, cnt$iso_code3), "country"]
wide_data$COUNTRY <- ifelse(is.na(wide_data$COUNTRY), as.character(wide_data$iso_code3), wide_data$COUNTRY)
wide_data$iso_num <- cnt[match(wide_data$COUNTRY, cnt$country), "iso_num"]

# remove iso_code3 with more than 3 characters
wide_data$iso_code3 <- ifelse(nchar(as.character(wide_data$iso_code3)) >3, NA, wide_data$iso_code3)

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

# wide_data <- read.csv(file.path(dir, "llece_mpl.csv"))

names(wide_data)[13:39] <- c(paste0("mlevel", 2:4, "_m"),
                             paste0("mlevel", 2:4, "_se"),
                             paste0("mlevel", 2:4, "_no"),
                             paste0("rlevel", 2:4, "_m"), 
                            paste0("rlevel", 2:4, "_se"),
                            paste0("rlevel", 2:4, "_no"),
                            paste0("slevel", 2:4, "_m"), 
                            paste0("slevel", 2:4, "_se"),
                            paste0("slevel", 2:4, "_no"))

dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/Analysis/ILSA"
write.csv(wide_data, row.names = FALSE, na="", file = file.path(dir, "llece_mpl.csv"))


