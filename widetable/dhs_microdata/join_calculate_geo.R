# This code joins dhs_calculate.dta and GeoSpatial covariates data from DHS
# @ Date: February 04, 2020 
# @ Contact: Sunmin Lee, Bilal Barakat

# Load packages 
library(dplyr)
library(readr)
library(haven)

# Import dataset (change the path)
dhs_calculate <- read_dta("/Users/sunminlee/UNESCO/GEM Report - Documents/Data Repository/WIDE Data/micro_data/DHS/Nigeria/2018/widetable/dhs_calculate.dta")
View(dhs_calculate)

# Import GeoSpatial covariates dataset (change the path)
dhs_geospatial <- read_csv("/Users/sunminlee/UNESCO/GEM Report - Documents/Data Repository/WIDE Data/raw_data/DHS_GeoSpatial/Nigeria/2018/NGGC7BFL.csv")
View(dhs_geospatial)

# Join two datasets by "cluster"
dhs_calculate_geo <- full_join(dhs_calculate, dhs_geospatial, by = c("cluster"="DHSCLUST"))
View(dhs_calculate_geo)

# Set working directory and save micro data in .csv (change the path)
setwd("/Users/sunminlee/UNESCO/GEM Report - Documents/Data Repository/WIDE Data/micro_data/DHS/Nigeria/2018/widetable")
write.csv(dhs_calculate_geo, "dhs_calculate_geo.csv", row.names = FALSE)


