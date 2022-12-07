# This code imports micro data from survey and aggregates by "learner" status
# @ Date: February 10, 2020 
# @ Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load packages 
library(dplyr)
library(haven)

# Import dataset (change the path!)
mics_calculate <- read_dta("~/Desktop/gemr/disaggregation/mics_calculate_literacy_hh-edu.dta")
View(mics_calculate)


######################## MICRO DATA ############################
# Select variables 
micro_data <- select(mics_calculate, iso_code3, country, year, country_year, location, sex, wealth, region, ethnicity, hh1, hh5y, religion, comp_lowsec_1524,
                     comp_upsec_2029, eduyears_2024, edu4_2024, eduout_prim, eduout_lowsec, eduout_upsec, comp_prim_1524_no, comp_lowsec_1524_no,
                     comp_upsec_2029_no, eduyears_2024_no, edu4_2024_no, eduout_prim_no, eduout_lowsec_no, eduout_upsec_no, adjustment, hhweight, schage,
                     individual_id, hh_id, age, eduyears, comp_prim, comp_lowsec, comp_upsec, comp_higher, attend, eduout, attend_preschool, attend_higher, literacy_1549,
                     hh_edu1, hh_edu2, hh_edu3, hh_edu4, hh_edu5, hh_edu6)
View(micro_data)

# Change some variable names 
colnames(micro_data)[colnames(micro_data) == 'hh5y'] <- 'year_interview' # 'hh5y' into 'year_interview'
colnames(micro_data)[colnames(micro_data) == 'hh1'] <- 'cluster' # 'hh1' into 'cluster' 
colnames(micro_data)[colnames(micro_data) == 'schage'] <- 'age_adjusted' # 'schage' into 'age_adjusted'
View(micro_data)

# Include following new variables as a column
micro_data <- cbind(year_uis = 2014, micro_data) # include 'year_uis' (change this part!)
micro_data <- cbind(survey = 'MICS', micro_data) # include 'survey'
View(micro_data)


###################### Summarize (mean) by new variable ###########################
# hh_edu1: At least one adult of the family has completed primary
agg_hh_edu1 <- aggregate(micro_data[, 15:45], list(micro_data$hh_edu1), mean, na.rm = TRUE)
View(agg_hh_edu1)

# hh_edu2: At least one adult of the family has completed lower secondary 
agg_hh_edu2 <- aggregate(micro_data[, 15:45], list(micro_data$hh_edu2), mean, na.rm = TRUE)
View(agg_hh_edu2)

# hh_edu3: Most educated male in the family has at least primary
agg_hh_edu3 <- aggregate(micro_data[, 15:45], list(micro_data$hh_edu3), mean, na.rm = TRUE)
View(agg_hh_edu3)

# hh_edu4: Most educated female in the family has at least primary
agg_hh_edu4 <- aggregate(micro_data[, 15:45], list(micro_data$hh_edu4), mean, na.rm = TRUE)
View(agg_hh_edu4)

# hh_edu5: Most educated male in the family has at least lower secondary
agg_hh_edu5 <- aggregate(micro_data[, 15:45], list(micro_data$hh_edu5), mean, na.rm = TRUE)
View(agg_hh_edu5)

# hh_edu6: Most educated female in the family has at least lower secondary
agg_hh_edu6 <- aggregate(micro_data[, 15:45], list(micro_data$hh_edu6), mean, na.rm = TRUE)
View(agg_hh_edu6)




