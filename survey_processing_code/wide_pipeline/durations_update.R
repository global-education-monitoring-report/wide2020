#### UPDATING THE DURATIONS FILE FOR WIDETABLE ####

# 16/01/2023: updating file UIS_duration_age_30082021.dta with UIS_duration_age_16012023.dta 
# 2021 info added UwU

#this update has durations only up to 2021 
#also keep durations only since 1990

# Set up libraries
library(tidyverse)
library(haven)


# Import bulk UIS file 

#the numbers
 OPRI_DATA_NATIONAL <- read_csv("C:/Users/taiku/OneDrive - UNESCO/UIS sept 2022 bulk data/OPRI_DATA_NATIONAL.csv")
head(OPRI_DATA_NATIONAL)

#the country names
OPRI_COUNTRY <- read_csv("C:/Users/taiku/OneDrive - UNESCO/UIS sept 2022 bulk data/OPRI_COUNTRY.csv") %>%
  rename(iso_code3 = COUNTRY_ID) %>% rename(country=COUNTRY_NAME_EN)


# List of indicators we need: 

# 299932	Theoretical duration of primary education (years)
# 999976	Theoretical duration of lower secondary education (years)
# 999978	Theoretical duration of upper secondary education (years)

# 299905	Official entrance age to primary education (years)
# 999975	Official entrance age to lower secondary education (years)
# 999977	Official entrance age to upper secondary education (years)

duration_indicators <- c("299932","999976","999978", "299905", "999975", "999977")
duration_dtanames <- c("prim_dur_uis","lowsec_dur_uis","upsec_dur_uis", "prim_age_uis", "lowsec_age_uis", "upsec_age_uis")

#Transform it into what we want :P 

 duration_UIS <- OPRI_DATA_NATIONAL %>% 
  filter(indicator_id %in% duration_indicators) %>% 
  filter(year >= 1990) %>%
  mutate(indicator_id = case_when(
    indicator_id == "299932" ~ "prim_dur_uis",
    indicator_id == "999976" ~ "lowsec_dur_uis",
    indicator_id == "999978" ~ "upsec_dur_uis",
    indicator_id == "299905" ~ "prim_age_uis",
    indicator_id == "999975" ~ "lowsec_age_uis",
    indicator_id == "999977" ~ "upsec_age_uis",
    TRUE ~ as.character(indicator_id))) %>%
  select(-magnitude,-qualifier) %>%
  pivot_wider(names_from = 'indicator_id', values_from = 'value') %>%
  rename(iso_code3=country_id) %>%
  left_join(OPRI_COUNTRY,by="iso_code3") %>%
  select(iso_code3,country,year,prim_dur_uis,lowsec_dur_uis,upsec_dur_uis,prim_age_uis,lowsec_age_uis,upsec_age_uis) %>%
   arrange(country)
 
 ####HEYYYYYYY###
 ### DONT U FORGEEEET ####
 ### TO MOVE THE FILE INTO THE PERSONAL FOLDER ###
 #setwd("C:/ado/personal")
 write_dta(duration_UIS, "UIS_duration_age_16012023.dta")





# Other cool stuff to extract  

# 299932	Theoretical duration of primary education (years)
# 999974	Theoretical duration of early childhood education (years)
# 999976	Theoretical duration of lower secondary education (years)
# 999978	Theoretical duration of upper secondary education (years)
# 999988	Theoretical duration of post-secondary non-tertiary education (years)
# 299902	Official entrance age to pre-primary education (years)
# 299905	Official entrance age to primary education (years)
# 401	Official entrance age to compulsory education (years)
# 999973	Official entrance age to early childhood education (years)
# 999975	Official entrance age to lower secondary education (years)
# 999977	Official entrance age to upper secondary education (years)
# 999987	Official entrance age to post-secondary non-tertiary education (years)
