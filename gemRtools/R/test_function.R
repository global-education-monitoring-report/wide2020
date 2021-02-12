#' A TEST Function
#'
#' This function allows you to test
#' @param test Is this test? Defaults to TRUE.
#' @keywords test
#' @export
#' @examples
#' test_function()

test_function <- function(test=TRUE){
  if(test==TRUE){
    print("Test is successful!")
  }
  else {
    print("Re-test")
  }
}
