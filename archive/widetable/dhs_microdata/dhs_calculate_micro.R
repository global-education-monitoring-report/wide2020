# This code imports dhs_calculate.dta data produced from widetable.ado and selects specific variables to make micro data file.
# @ Date: January 06, 2020 
# @ Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load packages 
library(haven)
library(readr)
library(dplyr)

# Import dataset (change the path)
dhs_calculate <- read_csv("/Users/sunminlee/UNESCO/GEM Report - Documents/Data Repository/WIDE Data/micro_data/DHS/Nigeria/2018/widetable/dhs_calculate_geo.csv")
View(dhs_calculate)

# Select variables 
micro_data <- select(dhs_calculate, iso_code3, country, year, country_year, location, sex, wealth, region, ethnicity, cluster, year_interview, religion,
                     comp_lowsec, comp_upsec, eduyears, edu2_2024, edu4_2024, eduout_prim, eduout_lowsec, eduout_upsec, comp_prim, comp_prim_v2, comp_lowsec_v2, comp_upsec_v2, hhweight,
                     individual_id, hh_id, age, comp_higher_2yrs, comp_higher_4yrs, attend, eduout, attend_higher, literacy_1549, literacy, comp_prim_aux, comp_lowsec_aux,
                     Travel_Times_2015, UN_Population_Density_2015, SMOD_Population_2015, BUILT_Population_2014)
View(micro_data)

# Include following new variables as a column
micro_data <- cbind(year_uis = 2018, micro_data) # include 'year_uis' (change this part!)
micro_data <- cbind(survey = 'DHS', micro_data) # include 'survey'
View(micro_data)

# Set working directory and save micro data in .csv (change the path)
setwd("/Users/sunminlee/UNESCO/GEM Report - Documents/Data Repository/WIDE Data/micro_data/DHS/Nigeria/2018")
file_iso <- micro_data$iso_code3[1]
file_year <- micro_data$year[1]
write.csv(micro_data, paste0('DHS_', file_iso, '_', file_year, '.csv'), row.names = FALSE)





