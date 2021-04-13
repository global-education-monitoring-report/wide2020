# wide_summarize.R: Following scripts read WIDE calculate microdata and summarize into indicators
# ver. April 12, 2021 (under development)
# Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat

# Load libraries (please install packages beforehand)
library(dplyr)
library(readr)
#library(haven) # for reading .dta (remove later)


# Read and view WIDE calculate microdata from R .rds format
# Sunmin NOTE: Delete .dta later and change into relative path
mics_calculate <- read_dta("Desktop/gemr/wide_etl/output/MICS/data/mics_calculate.dta") # testing with Benin 2014 (remove later)
View(mics_calculate)
wide_calculate <- readRDS("Desktop/gemr/new_etl/wide_calculate_MICS.rds")
View(wide_calculate)


#################################
##### Summarizing by groups #####
#################################

# Group by "ethnicity" and summarize by "mean"
# note: working (mean results are slightly different from stata code - check with Marcela and Bilal)
# note: change mics_calculate into wide_calculate
data_summarize1 <- mics_calculate %>% group_by(ethnicity) %>% summarise_at(c("comp_prim_v2", "comp_lowsec_v2", "comp_upsec_v2"), mean, na.rm = TRUE)
data_summarize1 <- data_summarize1 %>% mutate_at(vars(comp_prim_v2:comp_upsec_v2), .funs=funs(. * 100)) # multiply results by 100
data_summarize1 <- cbind(category = "Ethnicity", data_summarize1) # include category
View(data_summarize1)

# Group by "ethnicity, location" and summarize by "mean"
data_summarize2 <- mics_calculate %>% group_by(ethnicity, location) %>% summarise_at(c("comp_prim_v2", "comp_lowsec_v2", "comp_upsec_v2"), mean, na.rm = TRUE)
data_summarize2 <- data_summarize2 %>% mutate_at(vars(comp_prim_v2:comp_upsec_v2), .funs=funs(. * 100)) # multiply results by 100
data_summarize2 <- cbind(category = "Ethnicity & Location", data_summarize2) # include category
View(data_summarize2)

# Group by "ethnicity, sex" and summarize by "mean"
data_summarize3 <- mics_calculate %>% group_by(ethnicity, sex) %>% summarise_at(c("comp_prim_v2", "comp_lowsec_v2", "comp_upsec_v2"), mean, na.rm = TRUE)
data_summarize3 <- data_summarize3 %>% mutate_at(vars(comp_prim_v2:comp_upsec_v2), .funs=funs(. * 100)) # multiply results by 100
data_summarize3 <- cbind(category = "Ethnicity & Sex", data_summarize3) # include category
View(data_summarize3)


################################
##### Join all data frames #####
################################

# List all summarized data frames
list_summarized <- list(data_summarize1, data_summarize2, data_summarize3) # update this part when there is new category!

# Join all summarized data frames
data_summarize_join <- Reduce(full_join, list_summarized)
View(data_summarize_join)

# Include base data frame with default variables and slice the length matching the number of rows in data_summarize_join 
# Size (i.e. number of observations) needs to match for joining
df_base <- select(mics_calculate, iso_code3, country, year, country_year) %>% slice(1:nrow(data_summarize_join))
View(df_base)

# Join df_base with data_summarize_join
df_base_join <- merge(df_base, data_summarize_join, by = "row.names")
View(df_base_join)

# Reorder final data frame
data_order <- c("iso_code3", "country", "year", "country_year", "category", "ethnicity", "location", "comp_prim_v2", "comp_lowsec_v2", "comp_upsec_v2")
wide_summarize <- df_base_join[, data_order]
View(wide_summarize)


# Export final data frame as .rds format
# Sunmin NOTE: Change into relative path later. 
saveRDS(wide_summarize, file="Desktop/gemr/new_etl/wide_summarize.rds")





####################################################
### BELOW TESTING CODE #######
####################################################
#library(collapse) # Refer to https://github.com/SebKrantz/collapse

# # select few variables to summarize
# df_select <- select(mics_calculate, ethnicity, comp_prim_v2, comp_lowsec_v2, comp_upsec_v2)
# View(df_select)
# 
# 
# # summarize using dplyr
# df_summarize <- df_select %>% group_by(ethnicity) %>% summarise_all(funs(mean))
# View(df_summarize)
# 
# # this is working
# df_summarize <- df_select %>% group_by(ethnicity) %>% summarise_at(c("comp_prim_v2", "comp_lowsec_v2"), mean, na.rm = TRUE)
# View(df_summarize)
# 
# 
# # collapse using collapse package
# df_collapse <- collap(df_select, ethnicity ~ comp_prim_v2, FUN = list(fmean))
# View(df_collapse)
# 
# collapse <- collap(micro_data, literacy_1549 ~ comp_prim, FUN = list(fmean))
# collapse
# 
# # testing - multiple group
# library(tidyr)
# data_summarize_3 <- mics_calculate %>% group_by(c(ethnicity, location)) %>% summarise_at(c("comp_prim_v2", "comp_lowsec_v2", "comp_upsec_v2"), mean, na.rm = TRUE)
# View(data_summarize_3)
# 
# test <- mics_calculate %>% unite(measurevar, ethnicity, location, remove=FALSE) %>% gather(key, val, comp_prim_v2) %>% group_by((val) %>% summarise((mean(comp_prim_v2))))
# 
# test <- mics_calculate %>% group_by(ethnicity, location) %>% summarise_at(c("comp_prim_v2", "comp_lowsec_v2", "comp_upsec_v2"), mean, na.rm = TRUE)


# joining test
# for (i in 1:length(list_summarized)){
#   data_summarize_join <- data_summarize[i] %>% full_join(data_summarize[i+1])
#   View(data_summarize_join)
# }
# 
# # Join base and summarize data frames
# df_base_join <- df_base %>% inner_join(data_summarize_1, by = "for_join")
# View(df_base_join)
# 
# df_test2 <- right_join(df_base, data_summarize_1)
# View(df_test2)
# 
# df_test <- merge(x = df_base, y = data_summarize_1, by = NULL)
# View(df_test)
# 
# df_test <- merge(x = df_base, y = data_summarize_1, by = NULL, all.x = TRUE)
# View(df_test)
# 
# df_test3 <- merge(df_base, data_summarize_1, all.y=TRUE)
# View(df_test3)


# #df_base <- select(mics_calculate, iso_code3, country, year, country_year, survey, year_uis)
# df_base <- select(mics_calculate, iso_code3, country, year, country_year) # delete this later - survey, year_uis is not included in old stata dataset
# #slice(df_base, nrow(data_summarize_join))
# #df_base %>% slice_head(n = nrow(data_summarize_join))
# df_base <- df_base %>% slice(1:nrow(data_summarize_join))
# View(df_base)
