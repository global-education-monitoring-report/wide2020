# wide_calculate.R: Following scripts read WIDE standardized microdata and calculate indicators
# ver. March 17, 2021 (under development)
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
# temporary variables (this will be included in standardize_data -> Marcela)
ageA <- data$age - 1
ageU <- data$age

edu_level <- c('prim', 'lowsec', 'upsec')
age_new <- c('ageU', 'ageA')

# CALCULATE 1: what is this indicator? its not available in summarize - primary (good code!)
# NOTE: need to refresh data
data <- subset(data, schage >= prim_age1+3 & schage <= prim_age1+5) # filter data by first condition
data$comp_prim_v2_age_new <- ifelse(data$comp_prim == 1, 1, 0) # second condition
View(data[c("schage", "prim_age1", "comp_prim", "comp_prim_v2_age_new")]) 


# CALCULATE 2: age limits for completion and out of school - primary 
# NOTE: comp_prim_v2 needs to be removed from standardize (Marcela)
# NOTE: need to refresh data
condition <- data$schage >= data$prim_age1+3 & data$schage <= data$prim_age1+5 # first condition
data$comp_prim_v2_new <- ifelse(condition == TRUE, 1, 0) # second condition
View(data[c("schage", "prim_age1", "comp_prim", "comp_prim_v2_new")])

# CALCULATE 3: comp_prim_1524 - primary
data <- subset(data, schage >= 15 & schage <= 24) # filter data by first condition
data$comp_prim_1524_new <- ifelse(data$comp_prim == 1, 1, 0) # second condition
View(data[c("schage", "comp_prim", "comp_prim_1524_new")])

# CALCULATE 4: comp_upsec_2029 - upper secondary
data <- subset(data, schage >= 20 & schage <= 29) # filter data by first condition
data$comp_upsec_2029_new <- ifelse(data$comp_upsec == 1, 1, 0) # second condition
View(data[c("schage", "comp_upsec", "comp_upsec_2029_new")])

# CALCULATE 5: comp_lowsec_1524 - lower secondary
data <- subset(data, schage >= 15 & schage <= 24) # filter data by first condition
data$comp_lowsec_1524_new <- ifelse(data$comp_lowsec == 1, 1, 0) # second condition
View(data[c("schage", "comp_lowsec", "comp_lowsec_1524_new")])

# CALCULATE 6: eduyears_2024 (note: remove from standardize - Marcela)
data <- subset(data, schage >= 20 & schage <= 24) # filter data by first condition
data$eduyears_2024_new <- ifelse(data$eduyears == 1, 1, 0) # second condition
View(data[c("schage", "eduyears", "eduyears_2024_new")])

# note: remove edu2_2024 / edu4_2024 from standardize (Marcela)
data$edu2_2024 <- ifelse(data$eduyears_2024 < 2, 1, 0)
data$edu4_2024 <- ifelse(data$eduyears_2024 < 4, 1, 0)

# CALCULATE 7: Never been to school
# note: include edu0 in standardize (Marcela)
data <- subset(data, schage >= prim_age0+3 & schage <= prim_age0+6)
data$edu0_prim_new <- ifelse(data$edu0 == 1, 1, 0)

# CALCULATE 8: completion of higher
# TODO

# CALCULATE 9: ages for compleiton higher
# note: remove comp_higher_2yrs_2529 from standardize
data <- subset(data, schage >= 25 & schage <= 29)
data$comp_higher_2yrs_2529_new <- ifelse(data$comp_higher_2yrs == 1, 1, 0) # second condition
data$comp_higher_4yrs_2529_new <- ifelse(data$comp_higher_4yrs == 1, 1, 0) # second condition

data <- subset(data, schage >= 30 & schage <= 34)
data$comp_higher_4yrs_3034_new <- ifelse(data$comp_higher_4yrs == 1, 1, 0) # second condition

# CALCULATE 10: Age limits for out of school - primary
data <- subset(data, schage >= prim_age0_eduout & schage <= prim_age1_eduout)
data$eduout_prim_new <- ifelse(data$eduout == 1, 1, 0) 

# CALCULATE 11: Age limit for attendance 
TODO






###########
# TESTING #
###########

if ((schage >= prim_age1+3) & (schage <= prim_age1+5)){
  if (data$comp_prim == 1) {
    comp_prim_test <- 1
  } else (data$comp_prim == 0) {
    comp_prim_test <- 0
  }
}

if (data$comp_prim == 1) {
  data$comp_prim_test = 1
} else if (data$comp_prim == 0) {
  data$comp_prim_test = 0
}

for (row in 1:nrow(data)){
  if (data$comp_prim == 1) {
    data$comp_prim_test = 1
  } else if (data$comp_prim == 0) {
    data$comp_prim_test = 0
  }
}

for (row in 1:nrow(data)) {
  if ((data$schage >= data$prim_age1+3) & (data$schage <= data$prim_age1+5)) {
    if (data$comp_prim == 1) {
      data$comp_prim_test = 1
    } else if (data$comp_prim == 0) {
      data$comp_prim_test = 0
    } else {
      data$comp_prim_test <- NA
    } else {
      data$comp_prim_test <- NA
    }
  }
}

# test working
n <- nrow(data)
for (i in 1:n) {
  if ((data$schage[i] >= data$prim_age1[i]+3) & (data$schage[i] <= data$prim_age1[i]+5)) {
    if (data$comp_prim[i] == 1) {
      data$comp_prim_test[i] <- 1
    } else if (data$comp_prim[i] == 0) {
      data$comp_prim_test[i] <- 0
    } else {
      data$comp_prim_test[i] <- NA
    }
  } else {
    data$comp_prim_test[i] <- NA
    print("what the fuck")
  }
}

# tets
n <- ncol(data)
for (i in 1:n) {
  if ((data$schage[i] >= data$prim_age1[i]+3) & (data$schage[i] <= data$prim_age1[i]+5)){
    print("true")
    data$comp_prim_test[i] <- 1
  } else {
    print("what?")
    data$comp_prim_test[i] <- 0
  }
}


View(data[c("schage", "prim_age1", "comp_prim", "comp_prim_test")])

sub_data <- subset(data, schage >= prim_age1+3 & schage < prim_age1+5)
View(sub_data)
View(sub_data[c("schage", "prim_age1", "comp_prim")])

for (i in 1:100) {
  if (sub_data$comp_prim[i] == 1) {
    #sub_data$comp_prim_test[i] <- 1
    print('true')
  } else if (sub_data$comp_prim[i] == 0) {
    #sub_data$comp_prim_test[i] <- 0
    print('false')
  } else {
    print('na')
  }
}


