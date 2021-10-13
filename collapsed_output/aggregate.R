#Don't forget to install wpp2019 package
install.packages("wpp2019")
data(popF, popM, package = 'wpp2019')

path2uisdata <- 'C:/Users/taiku/Documents/GEM UNESCO MBR/UIS stat comparison/'

sap_indicators <- c(
  'SAP.1.AgM1', 'SAP.02', 'SAP.5t8',
  'SAP.1', #'SAP.1.F', 'SAP.1.M', 
  'SAP.2', #'SAP.2.F', 'SAP.2.M',
  'SAP.3'#, #'SAP.3.F', 'SAP.3.M'
  )

saps <- 
  vroom::vroom(paste0(path2uisdata, 'NATMON_DATA_NATIONAL.csv'), na = '') %>% 
  filter(INDICATOR_ID %in% sap_indicators) %>% 
  filter(between(YEAR, 2015, 2019)) %>% 
  uis_clean %>% 
  select(weight = INDICATOR_ID, iso_code = COUNTRY_ID, year = YEAR, value = VALUE) %>% 
  # separate(indicator, c(NA, 'level', 'Sex'), remove = FALSE) %>% 
  # mutate(Sex = case_when(
  #   Sex == 'F' ~ 'Female',
  #   Sex == 'M' ~ 'Male'
  # )) %>% 
  filter(iso_code != 'VAT') %>% 
  group_by(iso_code, weight) %>% 
  summarize(wt_value = mean(value, na.rm = TRUE)) %>% 
  ungroup

pops <- 
  bind_rows(female = popF, male = popM, .id = 'Sex') %>%
  select(pop = `2015`, country_code, name, age, Sex) %>%
  filter(age %in% c('15-19', '20-24', '25-29', '30-34')) %>%
  # {print(all({dplyr::count(., country_code) %>% pull(n)} == 2))} %>%
  group_by(country_code, age, Sex) %>%
  dplyr::summarise(pop = sum(pop)) %>%
  dplyr::summarise(pop = mean(pop, na.rm = TRUE)) %>% 
  ungroup %>%
  pivot_wider(names_from = 'age', values_from = pop) %>% 
  transmute(country_code,
    pop_1524 = `15-19` + `20-24`,
    pop_2029 = `20-24` + `25-29`,
    pop_2024 = `20-24`,
    pop_2529 = `25-29`,
    pop_3034 = `30-34`,
    const = 1
    ) %>% 
  mutate(iso_code = countrycode::countrycode(country_code, 'iso3n', 'iso3c')) %>%
  filter(!is.na(iso_code)) %>% 
  select(-country_code) %>% 
  pivot_longer(names_to = 'weight', values_to = 'wt_value', cols = c(starts_with('pop_'), const)) %>% 
  mutate(wt_value = 1000 * wt_value)

weights <- 
  bind_rows(saps, pops) %>% 
  arrange(iso_code) %>% 
  inner_join(vroom::vroom('C:/Users/taiku/OneDrive - UNESCO/WIDE files/weight_vars.csv'), by = 'weight')

cats2agg <- c('Total', 'Location', 'Sex', 'Wealth')

aggfun <- function(x, w) weighted.mean(x, w, na.rm = TRUE)

myagg_inner <- function(df, cat) {
  cats <- if (cat == 'Total') {
    list()
  } else {list(as.name(cat))}
  
  filter(df, category == cat) %>% 
  group_by(category, indicator, !!! cats) %>% 
  {bind_rows(
    group_by(., .add = TRUE, income_group) %>%
    dplyr::summarize(
      weight_represented = sum(wt_value),
      count_represented = sum(!is.na(value)),
      value = aggfun(value, wt_value)
      ) %>%
    ungroup %>% 
    # mutate(region = income_group) %>% 
    identity
    ,
    group_by(., .add = TRUE, region_group) %>%
    dplyr::summarize(
      weight_represented = sum(wt_value),
      count_represented = sum(!is.na(value)),
      value = aggfun(value, wt_value)
      ) %>%
    ungroup %>% 
    # mutate(region = region_group) %>% 
    identity
    # , 
    # dplyr::summarize(., 
    #   weight_represented = sum(wt_value),
    #   count_represented = sum(!is.na(value)),
    #   value = aggfun(value, wt_value)
    #   ) %>%
    # ungroup %>%
    # # mutate(region = 'World') %>% 
    # identity
  )}
}

myagg_outer <- function(df) {
  map_dfr(cats2agg, ~ myagg_inner(df, .))
}

thresholds <- 
  weights %>%
  left_join(regions, by = c('iso_code' = 'iso3c')) %>% 
  mutate(category = 'Total', value = 1) %>% 
  rename(region_group = SDG.region) %>% 
  myagg_inner('Total') %>% 
  select(indicator, income_group, region_group, 
         total_weight = weight_represented, total_count = count_represented) %>% 
  filter(!(is.na(income_group) & is.na(region_group)))

apply_threshold <- function(df, of_count = 0., of_weight = 0.33) { #select(df, -weight_represented, -count_represented)
  df %>% 
  left_join(thresholds, by = c('indicator', 'income_group', 'region_group')) %>% 
  filter(
    weight_represented/total_weight >= of_weight,
    count_represented/total_count >= of_count,
  ) %>% 
  select(-weight_represented, -total_weight, -count_represented, -total_count) %>% 
  identity
}

keep_threshold <- function(df, of_count = 0., of_weight = 0.33) { #select(df, -weight_represented, -count_represented)
  df %>% 
    left_join(thresholds, by = c('indicator', 'income_group', 'region_group')) %>% 
    mutate(
      weight_share = weight_represented/total_weight
    ) %>%
    select(-weight_represented, -total_weight, -count_represented, -total_count) %>% 
    identity
}

