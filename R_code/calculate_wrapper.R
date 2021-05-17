# WIDE calculate wrapper
#
# this determines which surveys have a standardised file available but have not yet been calculated, and
# apply the existing wide_calculate function to these, either jointly or sequentially,
# depending on whether joint processing is deemed feasible based either on number or size of the files

path2standardised <- "" # enter path
path2calculated <- ""   # enter path

parallel_survey_limit_number <- 20  #
parallel_survey_limit_size   <- 2   # in GB

switch2sequential <- function(filenames, method = "number") {
  if (method == "number") {
    length(filenames) > parallel_survey_limit_number
  } else if (method == "size") {
    sum(map(filenames, file.size)/(1024^3)) > parallel_survey_limit_size
  }
}

calculate_wrapper <- function() {
  standardised       <- stringr::str_remove(list.files(path2standardised), "_standardised.dta")
  already_calculated <- stringr::str_remove(list.files(path2calculated), "_calculated.dta")

  to_calculate <- setdiff(standardised, already_calculated)

  if (switch2sequential(to_calculate)) { # sequential version
    walk(to_calculate, function(survey) {
    haven::read_dta(survey) %>%
    wide_calculate %>%
    qs::qsave(file = paste0(path2calculated, survey, "_calculated"))
    })
  } else { # parallel version
    map_dfr(to_calculate, haven::read_dta()) %>%
    wide_calculate %>%
    group_by(survey_label) %>%
    group_walk(~ qs::qsave(.x, file = paste0(path2calculated, .y, "_calculated")))
  }
}
