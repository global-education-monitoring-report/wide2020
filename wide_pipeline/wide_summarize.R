# wide_summarize.R: Following scripts read WIDE calculate microdata and summarize into indicators
# ver. April 29, 2021 (under development)
# Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load libraries (please install packages beforehand)
library(dplyr)
library(readr)


# Read and view WIDE calculate microdata from R .rds format
wide_calculate <- readRDS("Desktop/gemr/new_etl/wide_calculate.rds")
#View(wide_calculate)


################################################################################
############################ Summarizing by groups #############################
################################################################################

# Define the function summarizing by groups
function_summarize <- function(x, y, z) {
  data_summarize <- wide_calculate %>% group_by({{x}}, {{y}}, {{z}}) %>% summarise(comp_prim_v2_mean = weighted.mean(comp_prim_v2, hhweight, na.rm=TRUE),
                                                                          comp_lowsec_v2_mean = weighted.mean(comp_lowsec_v2, hhweight, na.rm=TRUE),
                                                                          comp_upsec_v2_mean = weighted.mean(comp_upsec_v2, hhweight, na.rm=TRUE),
                                                                          comp_prim_1524_mean = weighted.mean(comp_prim_1524, hhweight, na.rm=TRUE),
                                                                          comp_lowsec_1524_mean = weighted.mean(comp_lowsec_1524, hhweight, na.rm=TRUE),
                                                                          comp_upsec_2029_mean = weighted.mean(comp_upsec_2029, hhweight, na.rm=TRUE),
                                                                          comp_higher_2yrs_2529_mean = weighted.mean(comp_higher_2yrs_2529, hhweight, na.rm=TRUE),
                                                                          comp_higher_4yrs_2529_mean = weighted.mean(comp_higher_4yrs_2529, hhweight, na.rm=TRUE),
                                                                          eduyears_2024_mean = weighted.mean(eduyears_2024, hhweight, na.rm=TRUE),
                                                                          edu4_2024_mean = weighted.mean(edu4_2024, hhweight, na.rm=TRUE),
                                                                          edu0_prim_mean = weighted.mean(edu0_prim, hhweight, na.rm=TRUE),
                                                                          eduout_prim_mean = weighted.mean(eduout_prim, hhweight, na.rm=TRUE),
                                                                          eduout_lowsec_mean = weighted.mean(eduout_lowsec, hhweight, na.rm=TRUE),
                                                                          eduout_upsec_mean = weighted.mean(eduout_upsec, hhweight, na.rm=TRUE),
                                                                          attend_higher_1822_mean = weighted.mean(attend_higher_1822, hhweight, na.rm=TRUE),
                                                                          overage2plus_mean = weighted.mean(overage2plus, hhweight, na.rm=TRUE),
                                                                          literacy_1524_mean = weighted.mean(literacy_1524, hhweight, na.rm=TRUE),
                                                                          comp_prim_v2_no = sum(!is.na(comp_prim_v2)),
                                                                          comp_lowsec_v2_no = sum(!is.na(comp_lowsec_v2)),
                                                                          comp_upsec_v2_no = sum(!is.na(comp_upsec_v2)),
                                                                          comp_prim_1524_no = sum(!is.na(comp_prim_1524)),
                                                                          comp_lowsec_1524_no = sum(!is.na(comp_lowsec_1524)),
                                                                          comp_upsec_1524_no = sum(!is.na(comp_upsec_2029)),
                                                                          comp_higher_2yrs_2529_no = sum(!is.na(comp_higher_2yrs_2529)),
                                                                          comp_higher_4yrs_2529_no = sum(!is.na(comp_higher_4yrs_2529)),
                                                                          comp_higher_4yrs_3034_no = sum(!is.na(comp_higher_4yrs_3034)),
                                                                          eduyears_2024_no = sum(!is.na(eduyears_2024)),
                                                                          edu4_2024_no = sum(!is.na(edu4_2024)),
                                                                          edu0_prim_no = sum(!is.na(edu0_prim)),
                                                                          eduout_prim_no = sum(!is.na(eduout_prim)),
                                                                          eduout_lowsec_no = sum(!is.na(eduout_lowsec)),
                                                                          eduout_upsec_no = sum(!is.na(eduout_upsec)),
                                                                          attend_higher_1822_no = sum(!is.na(attend_higher_1822)),
                                                                          overage2plus_no = sum(!is.na(overage2plus)),
                                                                          literacy_1524_no = sum(!is.na(literacy_1524)),
                                                                     )
}


# Call the function and include category name
wide_calculate$total <- "Total" # include "Total" variable to group by total
data_summarize0 <- cbind(category = "Total", function_summarize(total))
data_summarize1 <- cbind(category = "Ethnicity", function_summarize(ethnicity))
data_summarize2 <- cbind(category = "Location", function_summarize(location))
data_summarize3 <- cbind(category = "Location & Ethnicity", function_summarize(location, ethnicity))
data_summarize4 <- cbind(category = "Location & Sex", function_summarize(location, sex))
data_summarize5 <- cbind(category = "Location & Sex & Wealth", function_summarize(location, sex, wealth))
data_summarize6 <- cbind(category = "Location & Wealth", function_summarize(location, wealth))
data_summarize7 <- cbind(category = "Region", function_summarize(region))
data_summarize8 <- cbind(category = "Sex", function_summarize(sex))
data_summarize9 <- cbind(category = "Sex & Ethnicity", function_summarize(sex, ethnicity))
data_summarize10 <- cbind(category = "Sex & Region", function_summarize(sex, region))
data_summarize11 <- cbind(category = "Sex & Wealth", function_summarize(sex, wealth))
data_summarize12 <- cbind(category = "Sex & Wealth & Region", function_summarize(sex, wealth, region))
data_summarize13 <- cbind(category = "Sex & Wealth & Region", function_summarize(sex, wealth, region))
data_summarize14 <- cbind(category = "Wealth", function_summarize(wealth))
data_summarize15 <- cbind(category = "Wealth & Region", function_summarize(wealth, region))

#View(data_summarize1)


################################################################################
######################## Join all summarized data frames #######################
################################################################################

# List all summarized data frames
list_summarize <- list(data_summarize1, data_summarize2, data_summarize3, data_summarize4,
                       data_summarize5, data_summarize6, data_summarize7, data_summarize8,
                       data_summarize9, data_summarize10, data_summarize11, data_summarize12,
                       data_summarize13, data_summarize14, data_summarize15, data_summarize0) # update this part when there is a new category!

# Join all summarized data frames
data_summarize_join <- Reduce(full_join, list_summarize)
View(data_summarize_join)

# Include base data frame with default variables and slice the length matching the number of rows in data_summarize_join 
# Size (i.e. number of observations) needs to match for joining
#df_base <- dplyr::select(wide_calculate, iso_code3, country, survey, year, country_year) %>% slice(1:nrow(data_summarize_join))
df_base <- dplyr::select(wide_calculate, iso_code3, survey, year, country_year) %>% slice(1:nrow(data_summarize_join)) # TODO: Marcela including country in DHS
View(df_base)

# Join df_base with data_summarize_join
df_base_join <- merge(df_base, data_summarize_join, by = "row.names")
View(df_base_join)

# Reorder final data frame
# TODO: Check final list of variables
data_order <- c("iso_code3", "country", "survey", "year", "country_year", "category", "location", "sex", "wealth", "region", "ethnicity",  
                "comp_prim_v2_mean", "comp_lowsec_v2_mean", "comp_upsec_v2_mean", "comp_prim_1524_mean", "comp_lowsec_1524_mean", "comp_upsec_2029_mean",
                "comp_higher_2yrs_2529_mean", "comp_higher_4yrs_2529_mean", 
                "edu0_prim_mean", "eduout_prim_mean", "eduout_lowsec_mean", "eduout_upsec_mean", "attend_higher_1822_mean",
                "literacy_1549_mean", "comp_prim_v2_no", "comp_lowsec_v2_no", "comp_upsec_v2_no", "comp_prim_1524_no", 
                "comp_lowsec_1524_no", "comp_upsec_1524_no", "comp_higher_2yrs_2529_no", "comp_higher_4yrs_2529_no", "comp_higher_4yrs_3034_no",
                "edu0_prim_no", "eduout_prim_no", "eduout_lowsec_no", "eduout_upsec_no",
                "attend_higher_1822_no", "literacy_1549_no")
wide_summarize <- df_base_join[, data_order]
View(wide_summarize)


# Export final data frame as .rds format
saveRDS(wide_summarize, file="Desktop/gemr/new_etl/wide_summarize.rds")



###### Extra code that is useful for checking ######
# frequency table
#library(epiDisplay)
#tab1(wide_calculate$comp_prim_v2, sort.group = "decreasing", cum.percent = TRUE)
#tabpct(wide_calculate$ethnicity, wide_calculate$comp_prim_v2, decimal = 1, percent = "both")
