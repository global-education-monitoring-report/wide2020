# wide_calculate.R: Following scripts read WIDE standardized microdata and calculate indicators
# ver. April 29, 2021 (under development)
# Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load libraries (please install packages beforehand)
library(haven)

# Read and view WIDE standardized microdata from STATA .dta format
#data <- read_dta("C:/WIDE/output/MICS/data/mics_standardize.dta")
#data <- read_dta("C:/WIDE/output/MICS/data/mics_standardize.dta") # change this path
data <- read_dta("C:/WIDE/output/DHS/data/dhs_standardize.dta") # change this path
View(data)


# CALCULATE: Completion by education level
# primary
condition <- with(data, schage >= prim_age1+3 & schage <= prim_age1+5) # age limits condition
data$comp_prim_v2 = with(data, ifelse(condition == FALSE, NA, # if age condition is FALSE, return NA
                                          ifelse(comp_prim == 1, 1, 0))) # else if age condition is TRUE & comp_prim=1, return 1, otherwise (i.e. condition is TRUE & comp_prim=0), return 0
# lower secondary
condition <- with(data, schage >= lowsec_age1+3 & schage <= lowsec_age1+5)
data$comp_lowsec_v2 = with(data, ifelse(condition == FALSE, NA,
                                            ifelse(comp_lowsec == 1, 1, 0)))
# upper secondary
condition <- with(data, schage >= upsec_age1+3 & schage <= upsec_age1+5)
data$comp_upsec_v2 = with(data, ifelse(condition == FALSE, NA,
                                           ifelse(comp_upsec == 1, 1, 0)))


# CALCULATE: Completion by education level and age
# primary
condition <- with(data, schage >= 15 & schage <= 24)
data$comp_prim_1524 = with(data, ifelse(condition == FALSE, NA,
                                       ifelse(comp_prim == 1, 1, 0)))
# lower secondary
condition <- with(data, schage >= 15 & schage <= 24)
data$comp_lowsec_1524 = with(data, ifelse(condition == FALSE, NA,
                                        ifelse(comp_lowsec == 1, 1, 0)))
# upper secondary
condition <- with(data, schage >= 20 & schage <= 29)
data$comp_upsec_2029 = with(data, ifelse(condition == FALSE, NA,
                                          ifelse(comp_upsec == 1, 1, 0)))


# CALCULATE: Never been to school
# primary
condition <- with(data, schage >= prim_age0+3 & schage <= prim_age0+6)
data$edu0_prim = with(data, ifelse(condition == FALSE, NA,
                                         ifelse(edu0 == 1, 1, 0)))


# CALCULATE: Completion in higher education
condition <- with(data, schage >= 25 & schage <= 29)
data$comp_higher_2yrs_2529 = with(data, ifelse(condition == FALSE, NA,
                                   ifelse(comp_higher_2yrs == 1, 1, 0)))
data$comp_higher_4yrs_2529 = with(data, ifelse(condition == FALSE, NA,
                                   ifelse(comp_higher_4yrs == 1, 1, 0)))

condition <- with(data, schage >= 30 & schage <= 34)
data$comp_higher_4yrs_3034 = with(data, ifelse(condition == FALSE, NA,
                                   ifelse(comp_higher_4yrs == 1, 1, 0)))


# CALCULATE: Out of school by education level
# primary (Note: variable "prim_age0_eduout" is replaced by "prim_age0")
condition <- with(data, schage >= prim_age0 & schage <= prim_age1_eduout)
data$eduout_prim = with(data, ifelse(condition == FALSE, NA,
                                   ifelse(eduout == 1, 1, 0)))
# lower secondary
condition <- with(data, schage >= lowsec_age0_eduout & schage <= lowsec_age1_eduout)
data$eduout_lowsec = with(data, ifelse(condition == FALSE, NA,
                                   ifelse(eduout == 1, 1, 0)))
# upper secondary
condition <- with(data, schage >= upsec_age0_eduout & schage <= upsec_age1_eduout)
data$eduout_upsec = with(data, ifelse(condition == FALSE, NA,
                                   ifelse(eduout == 1, 1, 0)))


# CALCULATE: Attendance in preschool
# Note: These indicators are only available in MICS
if (data$survey[1] == "MICS") {
  condition <- with(data, schage >= 3 & schage <= 4)
  data$preschool_3 = with(data, ifelse(condition == FALSE, NA, ifelse(attend_preschool == 1, 1, 0)))
} else {
  print("This indicator is only available in MICS")
}

# Note: variable "prim_age0_eduout" is replaced by "prim_age0"
if (data$survey[1] == "MICS") {
  condition <- with(data, schage == prim_age0 - 1)
  data$preschool_1ybefore = with(data, ifelse(condition == FALSE, NA, ifelse(attend_preschool == 1, 1, 0)))
} else {
  print("This indicator is only available in MICS")
}


# CALCULATE: Attendance in higher education
condition <- with(data, schage >= 18 & schage <= 22)
data$attend_higher_1822 = with(data, ifelse(condition == FALSE, NA,
                                            ifelse(attend_higher == 1, 1, 0)))


# CALCULATE: Education years for age between 20 and 24
condition <- with(data, schage >= 20 & schage <= 24)
data$eduyears_2024 = with(data, ifelse(condition == FALSE, NA,
                                            ifelse(eduyears == 1, 1, 0)))

# CALCULATE: Less than 4 years of education
condition <- with(data, schage >= 20 & schage <= 24)
data$edu4_2024 = with(data, ifelse(condition == FALSE, NA,
                                       ifelse(edu4 == 1, 1, 0)))


#export data as .csv format
write.csv(data, "C:/Users/taiku/Documents/GEM UNESCO MBR/Rwide_calculate.csv", row.names = FALSE)

# export data frame to Stata format
write_dta(data, "C:/Users/taiku/Documents/GEM UNESCO MBR/Rwide_calculate.dta")

## TO.DO:
# include "overage2plus", "country", "edu4" in DHS standardize - Marcela working
# change into "literacy_1524" in MICS standardize - Marcela working
# calculate "household_edu" - Sunmin working


# Export data as .rds format
#saveRDS(data, file="C:/WIDE/output/MICS/R_output/wide_calculate.rds")


###### Extra code that is useful for checking ######
# frequency table
#library(epiDisplay)
#tab1(data$comp_lowsec_v2, sort.group = "decreasing", cum.percent = TRUE)

# view selected variables
#View(data[c("schage", "prim_age1", "comp_prim", "comp_prim_v2")]) 


# to read (import) .rds file as a dataframe
#df <- readRDS("Desktop/gemr/new_etl/wide_calculate.rds")

# group by variable
#library(dplyr)
#data %>% group_by(country) %>% summarize(n())
