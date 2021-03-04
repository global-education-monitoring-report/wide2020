# World Bank income groups

get_income_groups <- function() {
  wbstats::wb_countries() %>%
  select(iso3c, income_level_iso3c) %>%
  filter(!is.na(income_level_iso3c)) %>%
  mutate(
    income_group = recode(income_level_iso3c,
      'HIC' = 'High',
      'UMC' = 'Middle',
      'LMC' = 'Middle',
      'LIC' = 'Low'),
    income_subgroup = recode(income_level_iso3c,
      'HIC' = NA_character_,
      'UMC' = 'Upper middle',
      'LMC' = 'Lower middle',
      'LIC' = NA_character_)
  )
}

update_income_groups <- function(df) {
  df %>%
  select(-any_of(c("income_level_iso3c", "income_group", "income_subgroup"))) %>%
  left_join(by = 'iso3c', get_income_groups())
}

