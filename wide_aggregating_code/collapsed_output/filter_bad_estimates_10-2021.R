
wide_21_long %>% 
  mutate(value = ifelse(str_detect(indicator, 'literacy') &
                          (
                            (iso_code == 'JOR' & survey == 'HEIS') |
                              (iso_code == 'COL' & survey == 'GEIH' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'eduyears') &
                          (
                            (iso_code == 'NPL' & survey == 'MICS' & year == 2019) |
                              (iso_code == 'TON' & survey == 'MICS' & year == 2018) |
                              (iso_code == 'ZWE' & survey == 'MICS' & year == 2018)                                 FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'comp_higher') &
                          (
                            (iso_code == 'AFG' & survey == 'ECH') |
                              (iso_code == 'BRA' & survey == 'MICS' & year == 2011) |
                              (iso_code == 'SSD' & survey == 'MICS' & year == 2011) |
                              (iso_code == 'VNM' & survey == 'MICS' & year == 2011) |
                              (iso_code == 'NPL' & survey == 'MICS' & year == 2011) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'attend_higher') &
                          (
                            (iso_code == 'CAR' & year == 2016) |
                              (iso_code == 'LAO' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'comp_upsec_v2') &
                          (
                            (iso_code == 'GUY' & year == 2016) |
                              (iso_code == 'NPL' & year == 2016) |
                              (iso_code == 'JPN' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'comp_upsec_2029') &
                          (
                            (iso_code == 'NPL' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'comp_lowsec_v2') &
                          (
                            (iso_code == 'NPL' & year == 2016) |
                              (iso_code == 'JPN' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'eduout') &
                          (
                            (iso_code == 'LSO' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'comp_prim') &
                          (
                            (iso_code == 'NPL' & year == 2016) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'edu0') &
                          (
                            (iso_code == 'CAN' & year == 2016) |
                              (iso_code == 'TON' & year == 2019) |
                              FALSE), 
                        NA, value)) %>%
  mutate(value = ifelse(str_detect(indicator, 'edu0') &
                          (
                            (iso_code == 'CAN' & year == 2016) |
                              (iso_code == 'TON' & year == 2019) |
                              FALSE), 
                        NA, value))