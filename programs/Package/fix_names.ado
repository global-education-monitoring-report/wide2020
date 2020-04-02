
program define fix_names
*renamefrom using $aux_data_path/mics_dictionary.csv, filetype(delimited) delimiters(",") raw(name) clean(name_new) label(varlabel_en)

cap if !missing(ed4a)      & !missing(ed4ap)     drop ed4a
cap if !missing(ed4b)      & !missing(ed4bp)     drop ed4b
cap if !missing(ed6a)      & !missing(ed6n)      drop ed6a
cap if !missing(ed6b)      & !missing(ed6c)      drop ed6b
cap if !missing(ed6a)      & !missing(ed6ap)     drop ed6a
cap if !missing(ed6b)      & !missing(ed6bp)     drop ed6b
cap if !missing(ethnicity) & !missing(hc1c)      drop ethnicity
cap if !missing(hh6)       & !missing(hh6a)      drop hh6
cap if !missing(hh7)       & !missing(hh6b)      drop hh7
cap if !missing(region)    & !missing(hh7a)      drop region
*cap if !missing(hh7) 	   & !missing(region)    drop hh7
*cap if !missing(hh8)       & !missing(region)    drop hh8
cap if !missing(hhweight)  & !missing(hlweight)  drop hhweight
cap if !missing(religion)  & !missing(hc1a)      drop religion
cap if !missing(religion)  & !missing(hl15)      drop religion
cap if !missing(windex5)   & !missing(windex5_5) drop windex5
cap if !missing(windex5)   & !missing(windex5_1) drop windex5

cap rename ed4ap     ed4a
cap rename ed4bp     ed4b
cap rename ed6n      ed6a
cap rename ed6c      ed6b
cap rename ed6ap     ed6a
cap rename ed6bp     ed6b
cap rename hc1c      ethnicity
cap rename hh6a      hh6
cap rename hh6b      hh7
cap rename hh7a      region
cap rename hlweight  hhwieght
cap rename hc1a      religion
cap rename hl15      religion
cap rename windex5_5 windex5
cap rename windex5_1 windex5

end
