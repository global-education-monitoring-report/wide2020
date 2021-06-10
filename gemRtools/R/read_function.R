#' A READ Function
#'
#' This function reads in a batch of microdata files with an input vectors of "survey types", "iso3 codes", and "years".
#' Please make sure to change the path where data files are located.
#' ver. May 31 2021
#' @name read_function
#' @param survey Survey types (e.g. MICS, DHS, etc.) of this dataset
#' @param iso_code3 Country ISO3 code of this dataset
#' @param year Year of this dataset
#' @keywords wide
#' @export
#' @examples
#' read_function(c("AFG", "BLZ"), c(2010, 2011), c("MICS"), "/Users/sunminlee/Desktop/gemr/gemRpackage/microdata/")


####################################
##### Example of input vectors #####
####################################
# iso3 <- c("AFG", "BLZ") # include more iso3 codes, if necessary
# year <- c(2010, 2011) # include more years, if necessary
# survey <- c("MICS", "DHS") # include more surveys, if necessary
# path <- "/Users/sunminlee/Desktop/gemr/gemRpackage/microdata/"

usethis::use_package("haven")
usethis::use_package("plyr")
library(haven)
library(plyr)


# update the filter_function as needed
filter_function <- function(data) {
  filter(data, age==6)
}


# read function
read_function <- function(iso3, year, survey, path) {
  # make file names using combination of input vectors
  files <- paste0(levels(interaction(iso3, year, survey, sep='_')), ".dta")
  # empty list to store data tables
  datalist = list()

  for (f in files){
    f_path <- paste0(path, f)
    # read .dta files if exists, otherwise skip
    skip_to_next <- FALSE
    mydata <- tryCatch(read_dta(f_path), error = function(e) {skip_to_next <<- TRUE})
    if (skip_to_next) {next}
    print(f_path)
    # append the data tables in an empty list
    datalist[[f]] <- filter_function(mydata)
  }

  # merge all data tables as a data frame
  ldply(datalist, data.frame)
}

read_survey <- function(file, filter_fun = identity) {
  if (file.exists(file)) filter_fun(haven::read_dta(print(file)))
}

read_surveys <- function(iso3, year, survey, path = "", ...) {
  # make file names using combination of input vectors
  files <- paste0(path, levels(interaction(iso3, year, survey, sep='_')), ".dta")

  map_dfr(files, read_survey, ...)
}
