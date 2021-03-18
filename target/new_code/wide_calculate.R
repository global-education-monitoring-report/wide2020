# wide_calculate.R: Following scripts read WIDE standardized microdata and calculate indicators
# ver. March 18, 2021 (under development)
# Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load libraries (please install package beforehand)
library(haven)

# Read and view WIDE standardized microdata from STATA .dta format
# Sunmin NOTE: Delete one later and change into relative path
data <- read_dta("Desktop/gemr/new_etl/mics_standardize.dta") # change this path (MICS)
View(data)
data <- read_dta("Desktop/gemr/new_etl/dhs_standardize.dta") # change this path (DHS) 
View(data)
# sunmin testing with smaller dataset (to be deleted)
library(readr)
data <- read_csv("Desktop/gemr/new_etl/mics_standardize_bangladesh.csv")
View(data)


### Indicator: Completion each level with age limits

# CALCULATE 1: what is this indicator? its not available in summarize (super good code!)
# primary
condition <- with(data, schage >= prim_age1+3 & schage <= prim_age1+5)
data$comp_prim_v2_age = with(data, ifelse(condition == FALSE, NA,
                                              ifelse(comp_prim == 1, 1, 0)))
# lower secondary
condition <- with(data, schage >= lowsec_age1+3 & schage <= lowsec_age1+5)
data$comp_lowsec_v2_age = with(data, ifelse(condition == FALSE, NA,
                                              ifelse(comp_lowsec == 1, 1, 0)))
# upper secondary
condition <- with(data, schage >= upsec_age1+3 & schage <= upsec_age1+5)
data$comp_upsec_v2_age = with(data, ifelse(condition == FALSE, NA,
                                                ifelse(comp_upsec == 1, 1, 0)))
#View(data[c("schage", "prim_age1", "comp_prim", "comp_prim_v2_age")]) 


# CALCULATE 2: comp_prim_v2 / comp_lowsec_v2 / comp_upsec_v2 (age limits for completion and out of school)
# NOTE: remove these indicators from standardize (Marcela)
# primary
condition <- with(data, schage >= prim_age1+3 & schage <= prim_age1+5)
data$comp_prim_v2 <- ifelse(condition == TRUE, 1, 0)
# lower secondary
condition <- with(data, schage >= lowsec_age1+3 & schage <= lowsec_age1+5)
data$comp_lowsec_v2 <- ifelse(condition == TRUE, 1, 0)
# upper secondary
condition <- with(data, schage >= upsec_age1+3 & schage <= upsec_age1+5)
data$comp_upsec_v2 <- ifelse(condition == TRUE, 1, 0)
#View(data[c("schage", "prim_age1", "comp_prim", "comp_prim_v2")])


# CALCULATE 3: comp_prim_1524 / comp_lowsec_1524 / comp_upsec_2029
# NOTE: remove these indicators from standardize (Marcela)
# primary
condition <- with(data, schage >= 15 & schage <= 24)
data$comp_prim_1524 <- ifelse(data$comp_prim == 1, 1, 0)
# lower secondary
condition <- with(data, schage >= 15 & schage <= 24)
data$comp_lowsec_1524 <- ifelse(data$comp_lowsec == 1, 1, 0)
# upper secondary
condition <- with(data, schage >= 20 & schage <= 29)
data$comp_upsec_2029 <- ifelse(data$comp_upsec == 1, 1, 0)
#View(data[c("schage", "comp_prim", "comp_prim_1524")])


# CALCULATE 4: eduyears_2024 /edu2_2024 / edu4_2024
# note: remove these indicators from standardize - Marcela
# eduyears_2024
condition <- with(data, schage >= 20 & schage <= 24)
data$eduyears_2024 <- ifelse(data$eduyears == 1, 1, 0)
# edu2_2024
data$edu2_2024 <- ifelse(data$eduyears_2024 < 2, 1, 0)
# edu4_2024
data$edu4_2024 <- ifelse(data$eduyears_2024 < 4, 1, 0)
#View(data[c("schage", "eduyears", "eduyears_2024_new")])


# CALCULATE 5: Never been to school
# note: include edu0 in standardize (Marcela)
condition <- with(data, schage >= prim_age0+3 & schage <= prim_age0+6)
data$edu0_prim <- ifelse(data$edu0 == 1, 1, 0)


# CALCULATE 6: completion of higher
# note: check the this code and result
data$comp_higher_2yrs <- ifelse(data$eduyears >= data$years_upsec + 2, 1, 0)
data$comp_higher_4yrs <- ifelse(data$eduyears >= data$years_upsec + 4, 1, 0)
#View(data[c("years_upsec", "eduyears", "comp_higher_2yrs")])


# CALCULATE 7: ages for completion higher
# note: remove these indicators from standardize (Marcela)
condition <- with(data, schage >= 25 & schage <= 29)
data$comp_higher_2yrs_2529 <- ifelse(data$comp_higher_2yrs == 1, 1, 0) 
data$comp_higher_4yrs_2529 <- ifelse(data$comp_higher_4yrs == 1, 1, 0)

condition <- with(data, schage >= 30 & schage <= 34)
data$comp_higher_4yrs_3034 <- ifelse(data$comp_higher_4yrs == 1, 1, 0)


# CALCULATE 8: Age limits for out of school
# primary
condition <- with(data, schage >= prim_age0_eduout & schage <= prim_age1_eduout)
data$eduout_prim <- ifelse(data$eduout == 1, 1, 0) 
# lower secondary
condition <- with(data, schage >= lowsec_age0_eduout & schage <= lowsec_age1_eduout)
data$eduout_lowsec <- ifelse(data$eduout == 1, 1, 0) 
# upper secondary
condition <- with(data, schage >= upsec_age0_eduout & schage <= upsec_age1_eduout)
data$eduout_upsec <- ifelse(data$eduout == 1, 1, 0) 


# CALCULATE 9: Age limit for attendance 
# preschool 3
condition <- with(data, schage >= 3 & schage <= 4)
data$preschool_3 <- ifelse(data$attend_preschool == 1, 1, 0) 

condition <- with(data, schage == prim_age0_eduout - 1)
data$preschool_1ybefore <- ifelse(data$attend_preschool == 1, 1, 0) 

# higher education
condition <- with(data, schage >= 18 & schage <= 22)
data$attend_higher_1822 <- ifelse(data$attend_higher == 1, 1, 0) 


#### NOTE: Include "overage", "literacy", "household_edu" in CALCUALTE

