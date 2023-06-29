##Graph ideas: clean version

#setup of data frames

library(ggplot2)
library(tidyverse)
library(cowplot)

path2uisdata <- 'C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/UIS stat comparison/UIS sept 2022 bulk data/'
#march update:
path2uisdata2 <- 'C:/Users/Lenovo PC/Documents/GEM UNESCO MBR/UIS info/'
path2uisdata2 <- 'C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/UIS info/'


uis_clean <- function(uis_data) {
  print(table(uis_data$qualifier))
  mutate(uis_data, value = ifelse(magnitude == 'NA' & value == 0, NA, value)) %>% 
    mutate(indicator_id = toupper(indicator_id))
}

indicators2extract <- c(
  'ICTSKILLATTACH', 'ICTSKILLCONNEC', 'ICTSKILLCOPI',  'ICTSKILLPROGLANG',  'ICTSKILLTRANSFERFILE',
  'ICTSKILLCREAT', 'ICTSKILLDUPLIC', 'ICTSKILLFORMULA',  'ICTSKILLSOFTWARE'
)

regions <-   vroom::vroom(paste0(path2uisdata2, 'SDG_REGION.csv'), na = '')  %>%
  mutate(type = case_when(
    str_detect(REGION_ID, "WB:") &  str_detect(REGION_ID, "Income|income")  ~ 'WB', 
    str_detect(REGION_ID, "GPE:") &  str_detect(REGION_ID, "Income|income") ~ 'GPE', 
    str_detect(REGION_ID, "ESCAP:") &  str_detect(REGION_ID, "Income|income") ~ 'ESCAP', TRUE ~ 'other' )) %>% 
  filter(!str_detect(REGION_ID, '(excluding high income)')) %>%
  filter(!str_detect(REGION_ID, 'Low & middle income')) %>%
  filter(!str_detect(type, 'other')) %>% 
  #choose ESCAP, GPE, WB 
  filter(str_detect(type, 'WB')) %>%
  rename(country_id=COUNTRY_ID)

#updating this 
regions <-   vroom::vroom(paste0(path2uisdata2, 'countries_updated.csv'), na = '') %>%
  rename(country_id=iso3c)  %>% select(country_id, GEMR.region, income_group, income_subgroup) %>%
  unite(incgroup2, c("income_group", "income_subgroup")) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='_NA',replacement = '')) %>%
  mutate(incgroup2=str_replace(incgroup2, pattern='Middle_',replacement = '')) %>%
  filter(!incgroup2=='NA') %>%  filter(!incgroup2=='Not Classified')

geo_regions <- vroom::vroom(paste0(path2uisdata, 'SDG_REGION.csv'), na = '') %>%
  mutate(type = case_when(
    str_detect(REGION_ID, "WB:") &  !str_detect(REGION_ID, "Income|income") &  !str_detect(REGION_ID, "IDA|IBRD")  ~ 'WB', 
    TRUE ~ 'other' )) %>%  filter(!str_detect(type, 'other'))

countrynames <- vroom::vroom(paste0(path2uisdata2, 'countries_updated.csv'), na = '') %>%
  rename(country_id=iso3c) %>% select(country_id, annex_name)

varlabels <-  read.csv(paste0(path2uisdata2, 'SDG_LABEL.csv'), na = '') %>% rename(indicator_id=INDICATOR_ID)

disaggs_uis <- 
  vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract, collapse = '|'))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('.M')),  !str_detect(indicator_id, fixed('.F'))) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>%
  mutate(shortlab=str_replace(INDICATOR_LABEL_EN, pattern='\\s*\\([^\\)]+\\)',replacement = '')) %>%
  mutate(shortlab=str_replace(shortlab, pattern='Proportion of youth and adults who',replacement = '')) %>%
  mutate(shortlab=str_replace(shortlab, pattern=', both sexes', replacement = '')) %>% 
  mutate(shortlab=str_replace(shortlab, pattern='\\s*\\([^\\)]+\\)',replacement = '')) %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
    mutate(regionnumber = case_when(
    str_detect(incgroup2, 'High') ~ 1,
    str_detect(incgroup2, 'Upper middle') ~ 2 ,
    str_detect(incgroup2, 'Lower middle') ~ 3,
    str_detect(incgroup2, 'Low') ~ 4,
    TRUE ~ NA )) 


latest_year <- disaggs_uis %>% group_by(country_id, indicator_id, ) %>%
  filter(year == max(year)) %>% arrange(value) %>% group_by(incgroup2, shortlab) %>%
  #slice(1:10) %>%  
  mutate(shortestlab = case_when(
    str_detect(shortlab, 'connected and installed') ~ 'connnected/installed new devices',
    str_detect(shortlab, 'copied or moved a file or folder') ~ 'copied/moved file' ,
    str_detect(shortlab, 'have created electronic presentations with presentation software') ~ 'electronic presentations',
    str_detect(shortlab, 'have found, downloaded, installed and configured software') ~ 'found/downloaded/installed software',
    str_detect(shortlab, 'have sent e-mails with attached files') ~ 'emailed with attachments',
    str_detect(shortlab, 'have transferred files between') ~ 'transfer files between devices',
    str_detect(shortlab, 'have used basic arithmetic formulae in a spreadsheet') ~ 'spreadsheets formulae',
    str_detect(shortlab, 'have used copy and paste tools to duplicate or move information within a document') ~ 'used copy/paste',
    str_detect(shortlab, 'have wrote a computer program using') ~ 'computer programming',
    TRUE ~ NA_character_ )) %>% mutate(shortestlab = str_to_sentence(shortestlab))

summary <- disaggs_uis %>% group_by(indicator_id, regionnumber, incgroup2,  shortlab) %>% 
  summarise(n = n(), mean_ind = mean(value), sd = sd(value), max = max(value), 
            min = min(value), min_year=min(year), max_year=max(year)) %>%  mutate(shortestlab = case_when(
              str_detect(shortlab, 'connected and installed') ~ 'connnected/installed new devices',
              str_detect(shortlab, 'copied or moved a file or folder') ~ 'copied/moved file' ,
              str_detect(shortlab, 'have created electronic presentations with presentation software') ~ 'electronic presentations',
              str_detect(shortlab, 'have found, downloaded, installed and configured software') ~ 'found/downloaded/installed software',
              str_detect(shortlab, 'have sent e-mails with attached files') ~ 'emailed with attachments',
              str_detect(shortlab, 'have transferred files between') ~ 'transfer files between devices',
              str_detect(shortlab, 'have used basic arithmetic formulae in a spreadsheet') ~ 'spreadsheets formulae',
              str_detect(shortlab, 'have used copy and paste tools to duplicate or move information within a document') ~ 'used copy/paste',
              str_detect(shortlab, 'have wrote a computer program using') ~ 'computer programming',
              TRUE ~ NA_character_ )) %>% arrange(mean_ind) %>% mutate(shortestlab = str_to_sentence(shortestlab))



summary_high <- summary %>% filter(shortestlab=='spreadsheets formulae' |
                                     shortestlab=='electronic presentations'|
                                     shortestlab=='computer programming'|
                                     shortestlab=='transfer files between devices')

ly_high <- latest_year %>%  filter(shortestlab=='Spreadsheets formulae' |
                                     shortestlab=='Electronic presentations'|
                                     shortestlab=='Computer programming'|
                                     shortestlab=='Transfer files between devices')

summary_time <- disaggs_uis %>% group_by(region,regionnumber,  year) %>% 
  summarise(n = n(), mean_ind = mean(value), sd = sd(value), max = max(value), 
            min = min(value), min_year=min(year), max_year=max(year))

bycountry_time1 <- disaggs_uis %>% 
  select(indicator_id, country_id, region,regionnumber, shortlab, year, value) %>%
  filter(year==2014 | year==2019) %>% 
  pivot_wider(names_from = year, names_prefix = 'year') %>% mutate(change=year2019-year2014) %>%
  filter(!is.na(change)) %>% 
  select(-year2019) %>% distinct %>% 
  filter(indicator_id=='ICTSKILLATTACH') %>% arrange(region)

bycountry_time2 <- disaggs_uis %>% 
  select(indicator_id, country_id, incgroup2,regionnumber, shortlab, year, value) %>%
  filter(year==2015 | year==2019) %>% 
  pivot_wider(names_from = year, names_prefix = 'year') %>% mutate(change=year2019-year2015) %>%
  filter(!is.na(change)) %>% 
  select(-year2019) %>% distinct %>% 
  filter(indicator_id=='ICTSKILLSOFTWARE') %>% arrange(incgroup2)


indicators2extract <- c( 'DL')

digital_learning <- vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('WPIA')) ) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
  mutate(regionnumber = case_when(
    str_detect(incgroup2, 'High') ~ 1,
    str_detect(incgroup2, 'Upper middle') ~ 2 ,
    str_detect(incgroup2, 'Lower middle') ~ 3,
    str_detect(incgroup2, 'Low') ~ 4,
    TRUE ~ NA ))   %>%
  separate(indicator_id,  into = c("orig", "category"))


sdg_region <- read_csv("C:/Users/Lenovo PC/UNESCO/Murakami, Yuki - 2021 Household spending model/Simplified/COUNTRY_CODES.csv") %>%
  select(iso3c, region.sdg, wb.income, country.crs.name) %>% rename(country_id=iso3c)

indicators2extract <- c( 'AG25T99')

edu_att <- vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('LPIA')) ) %>% 
  filter(!str_detect(indicator_id, '.RUR'), !str_detect(indicator_id, fixed('.URB')) ) %>% 
  filter(!str_detect(indicator_id, '.M'), !str_detect(indicator_id, fixed('.F')) ) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  #var labels
  left_join(varlabels, by="indicator_id") %>%
  #regions countries belong to
  left_join(regions ,by="country_id", multiple = "all") %>%
  mutate(region=str_replace(REGION_ID, pattern='WB:',replacement = '')) %>%
  mutate(region=str_replace(region, pattern='\\s*\\([^\\)]+\\)',replacement = '')) %>% 
  mutate(regionnumber = case_when(
    str_detect(region, 'High') ~ 1,
    str_detect(region, 'Upper middle') ~ 2 ,
    str_detect(region, 'Middle') ~ 3,
    str_detect(region, 'Lower middle') ~ 4,
    str_detect(region, 'Low') ~ 5,
    TRUE ~ NA )) %>% filter(!is.na(value)) %>% 
  separate(indicator_id,  into = c("orig", "level", "dropthis")) %>% select(-dropthis) %>%
  #drop some primary and doctoral degree
  filter(level=='2T8') %>% left_join(sdg_region,by="country_id", multiple = "all") %>% rename(income_group=region) %>%
  group_by(country_id) %>% mutate(count=n())

edu_att2 <- vroom::vroom(paste0(path2uisdata2, 'SDG_DATA_NATIONAL.csv'), na = '') %>% 
  filter(str_detect(indicator_id, paste(indicators2extract))) %>% 
  #rid of gender and GPIA 
  filter(!str_detect(indicator_id, 'GPIA'), !str_detect(indicator_id, fixed('LPIA')) ) %>% 
  filter(!str_detect(indicator_id, '.RUR'), !str_detect(indicator_id, fixed('.URB')) ) %>% 
  filter(!str_detect(indicator_id, '.M'), !str_detect(indicator_id, fixed('.F')) ) %>% 
  uis_clean %>%
  select(-qualifier, -magnitude) %>%
  left_join(varlabels, by="indicator_id") %>%
  filter(!is.na(value)) %>% 
  left_join(regions ,by="country_id", multiple = "all") %>%
  separate(indicator_id,  into = c("orig", "level", "dropthis")) %>% select(-dropthis) %>%
  filter((level=='1T8'| level=='2T8'|level=='3T8')) %>%
  group_by(country_id, year) %>% mutate(count=n()) %>% filter(count==3) %>% select(-count) %>% 
  mutate(value = value/100) %>% filter(year==2010 | year==2020) %>% group_by(country_id,  level) %>%
  mutate(count=n()) %>% filter(count==2) %>% select(-count) 

############################################3

#Final GRAPHS 1 -----

high_g <- ggplot(summary_high, aes(x=as.character(regionnumber), y = mean_ind, fill = shortestlab)) +
  geom_col(position = "dodge2")  +
  theme(legend.position="bottom",  axis.title.x=element_blank(), legend.title=element_blank()) +
  scale_x_discrete(labels=c('High income', 'Upper middle income', 
                            'Middle income', 'Lower middle income', 'Low income')) + ggtitle("Percentage of youth and adults with advanced ICT skills")
plot(high_g)

allskills <- ggplot(summary, aes(x=as.character(regionnumber), y = mean_ind, fill = shortestlab)) +
  geom_col(position = "dodge2")  +
  theme(legend.position="bottom",  axis.title.x=element_blank(), legend.title=element_blank()) +
  scale_x_discrete(labels=c('High income', 'Upper middle income', 
                            'Middle income', 'Lower middle income', 'Low income')) +
  ggtitle("Percentage of youth and adults with ICT skills") + guides(fill=guide_legend(nrow=3, byrow=TRUE))

plot(allskills)

#FIX
allskills <- ggplot(summary, aes(x=as.character(shortestlab), y = mean_ind, fill = factor(incgroup2, levels= c("High", "Upper middle", "Lower middle", "Low")))) +
  geom_col(position = "dodge2")  +
  theme(legend.position="bottom",  axis.title.x=element_blank(), legend.title=element_blank(), 
         panel.background = element_blank(), plot.background = element_blank()) +
  scale_fill_manual(values = c("#E60080", "#96c11f", "#1980D9", "#009a93"), 
                    limits = c("High", "Upper middle", "Lower middle", "Low")) +
  ylab("%") 
  #scale_y_continuous(labels = scales::percent_format(scale = 1))

plot(allskills)


#ly_high$region <- factor(ly_high$region, levels = 
#               c('High income', 'Upper middle income', 'Middle income', 'Lower middle income', 'Low income'))
test <- c("1" = "High", "2" = "Upper middle" , "3" = "Lower middle", 
           "4" = "Low" ) 

ly_high <- latest_year %>%  filter(shortestlab=='Spreadsheets formulae' |
                                     shortestlab=='Electronic presentations'|
                                     shortestlab=='Computer programming'|
                                     shortestlab=='Transfer files between devices')

preciselyskill <- latest_year %>%  filter(shortestlab=='Spreadsheets formulae' )
preciselyskill <- latest_year %>%  filter(shortestlab=='Transfer files between devices' )
preciselyskill <- latest_year %>%  filter(shortestlab=='Electronic presentations' )


#FIX
dots_high <- ggplot(data = preciselyskill) + 
  geom_point(mapping = aes(x = value, y = as.character(incgroup2), color=incgroup2), 
             alpha = 0.15,  size = 15) +
  geom_point(mapping = aes(x = value, y = as.character(incgroup2), color=incgroup2), 
              size = 15, shape=21, stroke = 1) +
  theme(axis.title.y=element_blank(), legend.position = "none", 
        panel.background = element_blank(), plot.background = element_blank(), 
         axis.text.y = element_text(size = 15)) +
  scale_y_discrete(labels = c(
    "High" = "High income",
    "Upper middle" = "Upper-middle income",
    "Lower middle" = "Lower-middle income",
    "Low" = "Low income" ), limits = c("High", "Upper middle", "Lower middle" ,  "Low"))     +
  scale_color_manual(values = c("#E60080", "#96c11f", "#1980D9", "#009a93"), 
                    limits = c("High", "Upper middle", "Lower middle", "Low")) +
xlab("Proportion of respondents (%)")
plot(dots_high) 
#+ facet_wrap( ~ shortestlab)


# Final GRAPHS 2 ----

attachment_time <-ggplot(data=bycountry_time1, aes(x=reorder(country_id,change,sum), y=change, fill=region))+geom_col(position = "dodge")+
  ggtitle("ICT skill (sent an email with an attachment) change of prevalence \nbetween 2014 and 2019, pp") + 
  theme(legend.position="bottom",  axis.title.x=element_blank(), legend.title=element_blank()) 
plot(attachment_time)

#fix
bycountry_time22 <- bycountry_time2 %>% filter(!country_id=='BEL') %>% filter(!country_id=='EGY') %>%
  left_join(countrynames, by="country_id")

software_use <- ggplot(data=bycountry_time22, aes(x=reorder(annex_name,change,sum), y=change, fill=incgroup2))+geom_col(position = "dodge2")+
  theme(legend.position="bottom",   legend.title=element_blank(),
          panel.background = element_blank(), plot.background = element_blank(), 
        axis.title.y=element_blank()) +
  scale_fill_manual(values = c("#E60080", "#96c11f", "#1980D9", "#009a93")) + ylab("Percentage-point change") +coord_flip()
  #scale_y_continuous(labels = scales::percent_format(scale = 1))

plot(software_use)

timeseries <- ggplot(data=summary_time, aes(x=year, y=mean_ind, color = region)) + geom_line()+
  ggtitle("Average ICT skill prevalence, 2014-2019") +
  theme(legend.position = "right")

plot(timeseries)

# Final GRAPHS 3 ----

dl_sex <-digital_learning %>% filter(category=='F' | category=='M') %>% 
  pivot_wider(names_from=category, id_cols = c('country_id', 'year', 'region') ) %>% filter(!country_id=='KAZ') %>% filter(!country_id=='RUS')

pgender<- ggplot(dl_sex) +
  geom_segment( aes(x=F, xend=M, y=reorder(country_id,-F,sum), yend=country_id), color="grey") +
  geom_point( aes(x=F, y=country_id, color="Female"), size=2 ) +
  geom_point( aes(x=M, y=country_id, color="Male"), size=2 ) +
  theme(legend.position = "bottom",  axis.title.y = element_blank()) + scale_color_manual(values = c("blue", "red"),
                                                                                          guide  = guide_legend(), 
                                                                                          name   = "Gender") + 
  xlab("% of subpopulation") 
plot(pgender)

dl_ses <- digital_learning %>% filter(category=='HIGHSES' | category=='LOWSES') %>%
  pivot_wider(names_from=category, id_cols = c('country_id', 'year', 'region') ) %>% filter(!country_id=='KAZ') %>% filter(!country_id=='RUS')

pses <- ggplot(dl_ses) +
  geom_segment( aes(x=LOWSES, xend=HIGHSES, y=reorder(country_id,-LOWSES,sum), yend=country_id), color="grey") +
  geom_point( aes(x=HIGHSES, y=country_id, color="High SES"),  size=2 ) +
  geom_point( aes(x=LOWSES, y=country_id, color="Low SES"),  size=2 ) +
  theme(legend.position = "bottom",  axis.title.y = element_blank()) + scale_color_manual(values = c("green", "purple"),
                                                                                          guide  = guide_legend(), 
                                                                                          name   = "") + 
  xlab("% of subpopulation") 
plot(pses)


dl_age <- digital_learning %>% filter(category=='OLDERADULTS' | category=='YOUNGERADULTS') %>%
  pivot_wider(names_from=category, id_cols = c('country_id', 'year', 'region') ) %>% filter(!country_id=='KAZ') %>% filter(!country_id=='RUS')

padultsage <- ggplot(dl_age) +
  geom_segment( aes(x=OLDERADULTS, xend=YOUNGERADULTS , y=reorder(country_id,-OLDERADULTS,sum), yend=country_id), color="grey") +
  geom_point( aes(x=YOUNGERADULTS , y=country_id, color="Younger_adults"), size=2 ) +
  geom_point( aes(x=OLDERADULTS, y=country_id, color="Older_adults"), size=2 ) +
  theme(legend.position = "bottom", axis.title.y = element_blank()) + scale_color_manual(values = c("turquoise", "brown"),
                                                                                         guide  = guide_legend(), 
                                                                                         name   = "") + 
  xlab("% of subpopulation") 
plot(padultsage)


dl_edu <- digital_learning %>% filter(category=='WITHOUTTERTIARY' | category=='WITHTERTIARY') %>%
  pivot_wider(names_from=category, id_cols = c('country_id', 'year', 'incgroup2') ) %>%
  filter(!country_id=='KAZ') %>% filter(!country_id=='RUS') %>% filter(!country_id=='EGY') %>% filter(!country_id=='BEL') %>%
  left_join(countrynames, by="country_id")

#fix
ptertiary <- ggplot(dl_edu) +
  geom_segment( aes(x=WITHOUTTERTIARY, xend=WITHTERTIARY , y=reorder(annex_name,WITHTERTIARY,sum), yend=annex_name), color="grey") +
  geom_point( aes(x=WITHTERTIARY , y=annex_name, color="With tertiary education"), size=2 ) +
  geom_point( aes(x=WITHOUTTERTIARY, y=annex_name, color="Without tertiary education"), size=2 ) +
  theme(legend.position = "bottom", axis.title.y = element_blank(),  panel.background = element_blank(), plot.background = element_blank()) + 
  scale_color_manual(values = c("#96c11f", "#1980D9"),guide  = guide_legend(), name   = "") + 
  xlab("Percentage-point change") 
  #scale_x_continuous(labels = scales::percent_format(scale = 1))


plot(ptertiary)

# Final GRAPHS 4 ----

two_year_grid <-ggplot(edu_att2, aes(x = reorder(country_id,value,sum), y = value, fill = level)) + 
  geom_bar(stat = "identity") +
  scale_fill_discrete(labels = c("Primary", "Lower secondary", "Upper secondary")) +
  facet_grid( ~ year) +coord_flip() + theme(axis.title.y=element_blank() ) + 
  ggtitle("Educational attainment")
plot(two_year_grid)

#fix dataset

edu_att22 <- edu_att2 %>% filter(level=='3T8') %>% 
  pivot_wider(names_from = year, values_from = value,  names_prefix = "yr") %>%
  mutate(chg_2020_2010= yr2020-yr2010) %>% arrange(desc(chg_2020_2010))



sdgregion_subset <- edu_att %>% filter(count>28)

longrun <- ggplot(sdgregion_subset, aes(x = year, y = value)) + 
  geom_line(aes(color = country_id), size = 0.5) +
  theme(legend.position="bottom")+
  ggtitle("Educational attainment of lower secondary in the long run: 1970-2020")

plot(longrun)

bored <- edu_att %>% mutate(decade = floor(as.numeric(year) / 10) * 10) %>%
  group_by(decade, country_id, wb.income, region.sdg) %>%
  summarise(value=mean(value, na.rm = TRUE)) %>% group_by(country_id) %>% mutate(count=n()) %>% 
  filter(!is.na(region.sdg)) %>% filter(decade>=1990) %>% 
  pivot_wider(names_from = decade, names_prefix = 'decade') %>% 
  mutate(change90s=decade2000-decade1990, change00s=decade2010-decade2000, change10s=decade2020-decade2010) %>%   filter(across(c(change90s, change00s, change10s), ~ !is.na(.))) %>%
  pivot_longer(cols = starts_with("change"), names_to=c("change")) %>%
  filter(!country_id=='DNK') %>% filter(!country_id=='COL') %>%  filter(!country_id=='BOL')

bored$change <- factor(bored$change, levels = c("change90s", "change00s", "change10s"))

decadeinbars <- ggplot(bored, aes(fill=change, y=reorder(country_id,-value,sum), x=value)) + 
  geom_bar(position="dodge2", stat="identity") + coord_flip() + ggtitle("Change in educational attainment of lower secondary level by decades") 
plot(decadeinbars)

#Final EXCEL -----
#excel
library("writexl") 
sheets <- list("F1.2" = summary, "F1.3" = latest_year, "F2.2" = bycountry_time2, "F3.4" = dl_edu, "F4.1" = edu_att22, "F1_THAT" = argh) #assume sheet1 and sheet2 are data frames
write.xlsx(sheets, file = "C:/Users/mm_barrios-rivera/Documents/GEM UNESCO MBR/graphs_44_v2.xlsx")

argh <- summary %>% ungroup %>% select(incgroup2, mean_ind, shortestlab) %>% pivot_wider(names_from = 'shortestlab', values_from = 'mean_ind')
