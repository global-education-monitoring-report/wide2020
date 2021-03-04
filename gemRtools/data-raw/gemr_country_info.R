# Standard UN Statistics Division (UNSD) country data (M49)
# can be downloaded at: https://unstats.un.org/unsd/methodology/m49/overview/

# This is combined and subsetted with GEM Report country names
# and updated income grouping from the World Bank

# World Bank income groups

write_csv(get_income_groups(), 'WB_income_groups.csv')

## The legacy term 'annex_name' used in old code for the GEMR statistical tables is in fact
## identical to 'country_tab' names:
# test <-
#   select(readr::read_csv('gemr_regions.csv'), iso3c, annex_name) %>%
#   left_join(readr::read_csv("gemr_country_names_2020.csv"), by = 'iso3c') %>%
#   mutate(
#     annex_is_text = annex_name == country_text,
#     annex_is_fig = annex_name == country_fig,
#     annex_is_tab = annex_name == country_tab
#   ) %>%
#   summary

gemr_country_names <- readr::read_csv("gemr_country_names_2020.csv")

gemr_country_regions <-
  select(gemr_country_names, iso3c) %>%
  left_join(
    readr::read_csv("~/Desktop/UNSD Methodology.csv") %>%
      select(
      iso3c      = `ISO-alpha3 Code`,
      region     = `Region Name`,
      sub_region = `Sub-region Name`
    ),
    by = "iso3c") %>%
  mutate(
    sdg_region = case_when(
      sub_region == "Sub-Saharan Africa"                      ~ "Sub-Saharan Africa",
      sub_region %in% c('Northern Africa', "Western Asia")    ~ "Western Asia and Northern Africa",
      sub_region %in% c('Central Asia', "Southern Asia")      ~ "Central and Southern Asia",
      sub_region %in% c('Eastern Asia', "South-eastern Asia") ~ "Eastern and South-eastern Asia",
      region == "Oceania" ~ "Oceania",
      sub_region == "Latin America and the Caribbean"         ~ "Latin America and the Caribbean",
      region == "Europe" | sub_region == "Northern America" ~ "Northern America and Europe"
    )
  ) %>%
  select(-region, -sub_region) %>%
  left_join(
    select(readr::read_csv('gemr_regions.csv'), iso3c, sdg_subregion = SDG.subregion),
    by = "iso3c"
  ) %>%
  left_join(
    readr::read_csv("WB_income_groups.csv"),
    by = "iso3c"
  ) %>%
  arrange(iso3c)

usethis::use_data(gemr_country_names, gemr_country_regions, overwrite = TRUE)
usethis::use_data(gemr_country_names, gemr_country_regions, overwrite = TRUE, internal = TRUE)
