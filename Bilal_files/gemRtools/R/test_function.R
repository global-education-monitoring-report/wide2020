#' A TEST Function
#'
#' This function allows you to test
#' @name test_function
#' @param test Is this test? Defaults to TRUE.
#' @keywords test
#' @export
#' @examples
#' test_function()

# If you need to install other packages (as dependency) to execute the new function, please specify below.
# This will be integrated in the DESCRIPTION file as "imports" and mandates to pre-install when using gemRtools package.
usethis::use_package("dplyr")
library(dplyr)

# Write your function below
test_function <- function(test=TRUE){
  if(test==TRUE){
    print("Test is successful!")
  }
  else {
    print("Re-test")
  }
}

