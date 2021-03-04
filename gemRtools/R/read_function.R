#' A READ Function
#'
#' This function reads in a batch of microdata files with an input vector of "survey types", "iso3 codes", and "years".
#' Please make sure to run the function in a working directory where it includes microdata files.
#' ver. Mar 04 2021
#' @param survey Survey types (e.g. MICS, DHS, etc.) of this dataset
#' @param iso_code3 Country ISO3 code of this dataset
#' @param year Year of this dataset
#' @keywords wide
#' @export
#' @examples
#' read_function(DHS, COD, 2013)

read_function <- function(survey, iso_code3, year) {
  survey <- deparse(substitute(survey))
  iso_code3 <- deparse(substitute(iso_code3))
  year <- deparse(substitute(year))

  # File name from function
  f <- paste0(survey, "_", iso_code3, "_", year, ".csv")

  # Open the dataset that matches the file name
  for (f_path in list.files(path=".", all.files=FALSE)) {
    if (f == f_path) {
      print("Open dataset!")
      micro_data <- read.csv(f)
      View(micro_data)
      break
    } else {
      print("No dataset. Please check the working directory!")
      break
    }
  }

}
