# functional programming approach 
# to aggregate all categories and indicators 
# with a single call

# takes microdata in LONG format, with variables 'indicator' and 'value'
# the call would then be:
# wide_aggregate(wide_long, c('Location', 'Sex', 'Wealth'), depth = 3)

#' Aggregate for a given category set
#'
#' @param df Input data frame.
#' @param cs Categories.
#'
wide_aggregate_by_cats <- function(df, cs) {
  # build WIDE 'category' variable and
  # variable names to group by for that category
  if (identical(cs, c(""))) {
    cats     <- NULL
    category <- "Total"
  } else {
    cats     <- syms(cs)
    category <- paste(sort(cs), collapse = ' & ')
  }
  
  df %>%
    group_by(!!! cats, country, year, survey, indicator) %>%
    summarise(
      count = sum(!is.na(value)),
      value = weighted.mean(value, hhweight, na.rm = TRUE)
      #weight = sum(weight, na.rm = TRUE),
      ) %>%
    na.omit %>%
    mutate(category = category) %>%
    select(country, year, survey, indicator, value, count, category, everything()) %>%
    identity
}

#' Aggregate Over All Category Sets
#'
#' @param df Input data frame.
#' @param categories Aggregation categories.
#' @param depth Tree depth.
#'
wide_aggregate <- function(df, categories = "", depth = 1) {

  # build list of combinations of disaggregation dimensions
  # to specified depth
  disaggs <- unique(c('', purrr::lmap(1:depth, function(n) utils::combn(categoriesinsvy, n, simplify = FALSE))))
  
  # map aggregation function over combinations of dimensions
  # and append all results
  purrr::map_dfr(disaggs, function(c) wide_aggregate_by_cats(df, c))
}

