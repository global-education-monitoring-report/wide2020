### pal_summarize: Examples

library("tidyverse")
library("haven")
library("reshape2")
library("janitor")
library("ggplot2")
library("stringr")
library("ggpubr")
library("purrr")

# Pakistan (almost identical math and reading)

dir  <- "/home/eldani/eldani/International LSA/ASER/Pakistan/2016/PK_2016_STATA"
pak_pal <- read_dta(file.path(dir, "ASER2016Child.dta"))

pak_pal <- mutate(pak_pal, math = recode(c012, `5`=1, .default =0), 
                 read = recode(c010, `5`=1, .default =0), 
                 grade = as.numeric(c005),
                 Sex = factor(c002, labels = c("Female", "Male")),
                 Location = "Rural",
                 iso_code3 = "PAK",
                 year = 2016,
                 weight = 1)

#prop.table(with(pak_pal, table(grade, c010)),1)

# Kenya (identical)
dir <- "/home/eldani/eldani/International LSA/ASER/Kenya/2015/KE_2015_STATA"
ken_pal <- read_dta(file.path(dir, "KE15_hhld.dta"))

ken_pal <- mutate(ken_pal, math = recode(as.numeric(math), `7`=1, .default =0), 
                 read = recode(as.numeric(swahili), `5`=1, .default =0), 
                 grade = as.numeric(grade),
                 Sex = factor(gender, labels = c("Male", "Female")),
                 Location = factor(ea_type, labels = c("Rural", "Urban")),
                 iso_code3 = "KEN",
                 year = 2015,
                 weight = weight)

# Uganda (math and read close)

dir <- "/home/eldani/eldani/International LSA/ASER/Uganda/2015/UG_2015_STATA"
uga_pal <- read_dta(file.path(dir, "UG15_hhld.dta"))

uga_pal <- mutate(uga_pal, math = recode(as.numeric(math), `7`=1, .default =0), 
                 read = recode(as.numeric(english), `5`=1, .default =0), 
                 grade = as.numeric(grade),
                 Sex = factor(gender, labels = c("Male", "Female")),
                 Location = factor(urban_code, labels = c("Rural", "Urban")),
                 iso_code3 = "UGA",
                 year = 2015,
                 weight = weight)

#prop.table(with(uga_pal, table(grade, english)),1)

# Tanzania (very close)

dir <- "/home/eldani/eldani/International LSA/ASER/Tanzania/2015/TZ_2015_STATA"
tza_pal <- read_dta(file.path(dir, "TZ15_hhld.dta"))


tza_pal <- mutate(tza_pal, math = recode(as.numeric(math), `9`=1, .default =0), 
                 read = recode(as.numeric(swahili), `5`=1, .default =0), 
                 grade = as.numeric(grade),
                 Sex = factor(gender, labels = c("Male", "Female")),
                 Location = factor(ea_type, labels = c("Rural", rep("Urban", 2))),
                 iso_code3 = "TZA",
                 year = 2015,
                 weight = weight)


# Mexico (close)
dir <- "/home/eldani/eldani/International LSA/ASER/Mexico/2016/MIA_2016"
mex_pal <- read.csv(file.path(dir, "med_2016.csv"))

mex_pal <- mutate(mex_pal, math = na_if(División, 999), 
                 read = na_if(Historia, 999), 
                 grade = Escolaridad -1,
                 Sex = factor(SexoNiño, labels = c("Female", "Male")),
                 Location = NA,
                 iso_code3 = "MEX",
                 year = 2016,
                 weight = 1)

# Mozambique (identical)
dir <- "/home/eldani/eldani/International LSA/ASER/Mozambique/2016/MZ_2016_STATA"
moz_pal <- read_dta(file.path(dir, "2016_TPC_Mozambique_RawDataSet_Pilot.dta"))

moz_pal <- mutate(moz_pal, math = recode(as.numeric(f5_1_matematicaniveisbasicos), `9`=1, .default=0), 
                 read = recode(as.numeric(f50_1_leituraniveisbasicos), `6`=1, .default=0), 
                 grade = as.numeric(f37_1_criancasfrequenciaclasse), # this is correct
                 Sex = factor(f36_1_sexodacrianca, 1:2, labels = c("Male", "Female")),
                 Location = factor(urbano_rural, labels = c("Urban", "Rural")),
                 iso_code3 = "MOZ",
                 year = 2016,
                 weight = 1)


# Append datasets
dvs <- c("math", "read")
ids <- c("iso_code3", "year", "grade")
groups <- c("Sex", "Location")

vars <- c(dvs, ids, groups, "weight")
df <- lapply(mget(grep("_pal$", ls(), value = TRUE)), function(x) x[vars])
df <- do.call(dplyr::bind_rows, df)
df <- filter(df, grade %in% c(3, 5))
df <- df[complete.cases(df[, c("math", "read")]), ]

# Calculate
pal <- wide_bind(df, dvs, ids, groups)
pal <- pal %>%
  rename(rlevel2_m = read, mlevel2_m = math) %>%
  mutate(survey =  "ASER")

# Remove unused categories
pal <- filter(pal, !(iso_code3=="PAK" & category=="Total"), iso_code3!="MEX")


## Export
dir <- "/home/eldani/MEGA/Work/Projects/Ongoing/UNESCO/Analysis/ILSA"
write.csv(pal, row.names = FALSE, na="", file = file.path(dir, "pal_mpl.csv"))
