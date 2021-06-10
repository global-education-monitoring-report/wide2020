#' A Category Arrange Helper Function
#'
#' This function takes a vector of categories and rearranges them in alphabetical order
#' ver. May 26 2021
#' @name category_arrange
#' @param category Vector of categories to be arranged.
#' @keywords wide
#' @export
#' @examples
#' category_arrange(category)

usethis::use_package("stringr")
usethis::use_package("purrr")
library(stringr)
library(purrr)


# test category (please uncomment this when calling a function in different dataset)
category <- c("ethnicity", "location", "location and ethnicity", "location & religion",
              "location  &  sex", "location & sex & wealth", "location & wealth",
              "region", "religion", "sex", "sex & ethnicity", "sex and region",
              "sex & religion", "sex & wealth", "sex & wealth & region", "total",
              "wealth", "wealth & region")


# Replace category pattern into "&", remove extra spaces, arrange by alphabetical order, and convert first letter into uppercase
category_arrange <- function(category) {
  category1 <- category %>% map(str_squish) %>% str_replace_all(c("and" = "&")) %>% str_to_title()
  category2 <- str_split(category1, " & ") %>% map(sort) %>% map_chr(paste, collapse = " & ")
  category2
}

