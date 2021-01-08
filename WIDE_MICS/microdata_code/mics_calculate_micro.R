# This code imports mics_calculate.dta data produced from widetable.ado and selects specific variables to make micro data file.
# @ Date: December 11, 2020 
# @ Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load packages 
library(haven)
library(dplyr)

# Import dataset
mics_calculate <- read_dta("Desktop/gemr/wide_etl/output/MICS/data/mics_calculate.dta")
View(mics_calculate)

# Select variables 
micro_data <- select(mics_calculate, iso_code3, country, year, country_year, location, sex, wealth, region, ethnicity, hh1, hh5y, religion, comp_lowsec_1524,
                     comp_upsec_2029, eduyears_2024, edu4_2024, eduout_prim, eduout_lowsec, eduout_upsec, comp_prim_1524_no, comp_lowsec_1524_no,
                     comp_upsec_2029_no, eduyears_2024_no, edu4_2024_no, eduout_prim_no, eduout_lowsec_no, eduout_upsec_no, adjustment, hhweight, schage,
                     individual_id, hh_id, age, eduyears, comp_prim, comp_lowsec, comp_upsec, comp_higher, attend, eduout, attend_preschool, attend_higher)
View(micro_data)

# Change some variable names 
colnames(micro_data)[colnames(micro_data) == 'hh5y'] <- 'year_interview' # 'hh5y' into 'year_interview'
colnames(micro_data)[colnames(micro_data) == 'hh1'] <- 'cluster' # 'hh1' into 'cluster' 
colnames(micro_data)[colnames(micro_data) == 'schage'] <- 'age_adjusted' # 'schage' into 'age_adjusted'
View(micro_data)

# Include following new variables as a column
micro_data <- cbind(year_uis = 2011, micro_data) # include 'year_uis' (change this part!)
micro_data <- cbind(survey = 'MICS', micro_data) # include 'survey'
View(micro_data)
# literacy (Marcela updating mics_calculate.ado)

# Set working directory and save micro data in .csv
setwd("Desktop/gemr/wide_etl/output/MICS")
write.csv(micro_data, 'mics_iso_year.csv', row.names = FALSE)
