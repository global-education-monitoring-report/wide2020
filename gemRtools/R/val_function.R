#' A VAL (validation) Function
#'
#' This function validates certain conditions of the variable values.
#' ver. May 11 2021
#' @param var Variable name to be validated from this dataset
#' @keywords wide
#' @export
#' @examples
#' val_function(age)

df <- read.csv(file = '/Users/sunminlee/Desktop/gemr/gemRpackage/microdata/DHS_COD_2013.csv')
View(df)


val_function <- function(df, var) {
  # condition 1: check negative values
  for (i in 1:nrow(df)){
    if (isTRUE(df$var[i] < 0)){
      print("Check negative values!")
      break
    } else {
      print("All values are greater than or equal to zero")
    }
  }
}


