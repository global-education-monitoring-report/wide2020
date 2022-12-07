** ver. Feb 10, 2021
** Experimenting different combination of new variable "household education"
** Once variable is confirmed, these codes will be appended in the "mics_calculate.ado"


* Import mics_calculate.dta file (Note: Data is from MICS Benin 2014)
use "/Users/sunminlee/Desktop/gemr/wide_etl/output/MICS/data/mics_calculate_literacy.dta"

* Define a new variable "Household Education 1": At least one adult of the family has completed primary 
egen hh_edu1 = max(comp_prim), by(hh_id)

* Define a new variable "Household Education 2": At least one adult of the family has completed lower secondary
egen hh_edu2 = max(comp_lowsec), by(hh_id) 

* Define a new variable "Household Education 3": Most educated male in the family has at least primary
gen male_comp_prim = comp_prim if sex=="Male"
egen hh_edu3 = max(male_comp_prim), by(hh_id)
drop male_comp_prim

* Define a new variable "Household Education 4": Most educated female in the family has at least primary
gen female_comp_prim = comp_prim if sex=="Female"
egen hh_edu4 = max(female_comp_prim), by(hh_id)
drop female_comp_prim

* Define a new variable "Household Education 5": Most educated male in the family has at least lower secondary
gen male_comp_lowsec = comp_lowsec if sex=="Male"
egen hh_edu5 = max(male_comp_lowsec), by(hh_id)
drop male_comp_lowsec

* Define a new variable "Household Education 6": Most educated female in the family has at least lower secondary
gen female_comp_lowsec = comp_lowsec if sex=="Female"
egen hh_edu6 = max(female_comp_lowsec), by(hh_id)
drop female_comp_lowsec

* Save the output file
save "/Users/sunminlee/Desktop/gemr/disaggregation/mics_calculate_literacy_hh-edu.dta"


