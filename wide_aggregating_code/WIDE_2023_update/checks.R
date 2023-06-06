# upload check

# must be country with info, or aggregate
check_completeness <- function(df) {
  df %>% 
  filter((!is.na(iso_code) & !is.na(country)) | !is.na(region_group) | !is.na(income_group))
}

# suppress cells based on < 20 (unweighted) observations
check_samplesize <- function(df_long) {
  df_long %>% 
  tidyr::extract(indicator, into = c('indicator', 'suffix'), regex = "(.*)_(no|m|sd)$") %>% 
  pivot_wider(names_from = 'suffix', values_from = 'value') %>% 
  # mutate(m = ifelse(no < 20, NA, m)) %>%
  filter(is.na(no) | no >= 30) %>%
  pivot_longer(cols = c(m, no), names_to = 'suffix', values_to = 'value') %>% 
  unite('indicator', indicator, suffix)
}

# check for non-recognized countries
check_countries <- function(df) print(sort(unique(df$country)))

# check for 'logical' primary completion > lower secondary completion > upper secondary completion 
check_completion_progression <- function(df) {
  df %>% 
  select(iso_code3, survey, year, category, comp_prim_v2_m, comp_lowsec_v2_m, comp_upsec_v2_m) %>% 
  filter(comp_prim_v2_m < comp_lowsec_v2_m | comp_lowsec_v2_m < comp_upsec_v2_m)
}

# check no NA category
check_categories <- function(df) {
  df %>% 
  filter(
    !(str_detect(category, 'Sex') & is.na(Sex)),
    !(str_detect(category, 'Location') & is.na(Location)),
    !(str_detect(category, 'Wealth') & is.na(Wealth)),
    !(str_detect(category, 'Ethnicity') & is.na(Ethnicity)),
    !(str_detect(category, 'Region') & is.na(Region)),
    !(str_detect(category, 'Religion') & is.na(Religion)),
    !(str_detect(category, 'Language') & is.na(Language))
  ) %>% 
  filter(
    is.na(Sex) | Sex %in% c('Female', 'Male'),
    is.na(Location) | Location %in% c('Urban', 'Rural'),
    is.na(Wealth) | Wealth %in% c('Quintile 1', 'Quintile 2', 'Quintile 3', 'Quintile 4', 'Quintile 5'),
    is.na(Ethnicity) | Ethnicity != 'Other',
    is.na(Region) | Region != 'Other',
    is.na(Religion) | Religion != 'Other',
    is.na(Language) | Language != 'Other',
  )
}


impute_prim_from_sec <- function(df) {
  df %>% 
  mutate(comp_prim_v2_m = ifelse(
                                comp_lowsec_v2_m >= 0.95 & is.na(comp_prim_v2_m), 
                                (1 + comp_lowsec_v2_m)/2, 
                                comp_prim_v2_m)) 
}
