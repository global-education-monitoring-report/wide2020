#' A Category Arrange Helper Function
#'
#' This function takes a vector of categories and rearranges them in alphabetical order
#' ver. May 20 2021
#' @param category Vector of categories to be arranged.
#' @keywords wide
#' @export
#' @examples
#' category_arrange(category)

library(stringr)
library(purrr)


category <- c("ethnicity", "location", "location & ethnicity", "location & religion",
              "location & sex", "location & sex & wealth", "location & wealth",
              "region", "religion", "sex", "sex & ethnicity", "sex & region",
              "sex & religion", "sex & wealth", "sex & wealth & region", "total",
              "wealth", "wealth & region")


# arrange categories by alphabetical order and convert first letter into uppercase
category_arrange <- function(category) {
  str_split(category, " & ") %>%
  map(sort) %>%
  map_chr(paste, collapse = " & ") %>%
  str_to_title()
}

