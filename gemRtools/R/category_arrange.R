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


# test category (please uncomment this when calling a function in different dataset)
category <- c("ethnicity", "location", "location and ethnicity", "location & religion",
              "location  &  sex", "location & sex & wealth", "location & wealth",
              "region", "religion", "sex", "sex & ethnicity", "sex and region",
              "sex & religion", "sex & wealth", "sex & wealth & region", "total",
              "wealth", "wealth & region")


# Split categories by pattern ("&" and "and"), remove extra spaces, arrange by alphabetical order, and convert first letter into uppercase
category_arrange <- function(category) {
  split1 <- str_split(category, " & ") %>% map(str_squish) %>% map(sort) %>% map_chr(paste, collapse = " & ")
  #print(split1)
  split2 <- str_split(split1, " and ") %>% map(str_squish) %>% map(sort) %>% map_chr(paste, collapse = " & ") %>% str_to_title()
  #print(split2)
}

