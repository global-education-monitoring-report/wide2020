#whats new
library(tidyverse)

path2wides <- "C:/Users/mm_barrios-rivera//OneDrive - UNESCO/WIDE files/" 

#old WIDE

old_wide <- vroom::vroom(paste0(path2wides,"WIDE_DataUpdate_08MAR2022.csv"), guess_max = 900000) 

survlist_old <- old_wide %>% select(iso_code, survey, year) %>% distinct()


#new WIDE
new_wide <- vroom::vroom(paste0(path2wides,"WIDE_2023_july.csv"), guess_max = 900000) 

survlist_new <- new_wide %>% select(iso_code, survey, year) %>% distinct()

whatsnew <- anti_join(survlist_new,survlist_old)

library("writexl") 
# saves the dataframe at the specified
# path
write_xlsx(whatsnew,paste0("newsurveys.xlsx"))
