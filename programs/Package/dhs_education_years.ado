* dhs_education_years:
* Version 1.0
* April 2020

program define dhs_education_years
	args input_path output_path 

	* CHANGES IN HV108

	*Republic of Moldova doesn't have info on eduyears
	if country_year == "RepublicofMoldova_2005"{
		replace hv108 = hv107               if (hv106 == 0 | hv106 == 1)
		replace hv108 = hv107 + years_prim  if hv106 == 2 
		replace hv108 = hv107 + years_upsec if hv106 == 3
		replace hv108 = 98                  if hv106 == 8 
		replace hv108 = 99                  if hv106 == 9 
	} else if  country_year == "Armenia_2005" {
		*Changes to hv108 made in August 2019
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0  // "primary"
		replace hv108 = hv107      if hv106 == 1 // "primary"
		replace hv108 = hv107 + 5  if hv106 == 2 // "secondary"
		replace hv108 = hv107 + 10 if hv106 == 3 //"higher"
	} else if country_year == "Armenia_2010" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 // "primary" & secondary
		replace hv108 = hv107      if hv106 == 1 | hv106 == 2 // "primary" & secondary
		replace hv108 = hv107 + 10 if hv106 == 3  //"higher"
	} else if country_year == "Egypt_2008" {
		replace hv108 = . if 
		replace hv108 = 0 if hv106 == 0 
		replace hv108 = hv107 if hv106 == 1 
		replace hv108 = hv107 + 6 if hv106 == 2 
		replace hv108 = hv107 + 12 if hv106 == 3 
	} else if country_year == "Egypt_2014" {
		replace hv108 = .
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 6  if hv106 == 2
		replace hv108 = hv107 + 12 if hv106 == 3 
	} else if country_year == "Madagascar_2003" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 5  if hv106 == 2 
		replace hv108 = hv107 + 12 if hv106 == 3
	} else if country_year == "Madagascar_2008" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0 
		replace hv108 = hv107      if hv106 == 1 
		replace hv108 = hv107 + 6  if hv106 == 2 // I add 6, not 5 to correct
		replace hv108 = hv107 + 13 if hv106 == 3  // I add 13, not 6 to correct
	} else if country_year == "Zimbabwe_2005" {
		replace hv108 = . 
		replace hv108 = 0          if hv106 == 0  // "no education"
		replace hv108 = hv107      if hv106 == 1 // "primary"
		replace hv108 = hv107 + 7  if hv106 == 2  // "secondary"
		replace hv108 = hv107 + 13 if hv106 == 3  //"higher"	
	} else {
		replace hv108 = hv108
	}
		
	*Hv108: 
	*Albania 2017: doesn't have hv108==10, 11
	*Mali 2018: doesn't have hv108==11
	*Haiti 2017, Pakistan 2018, South Africa 2016: only goes until 16 years
	*Indonesia 2017, Maldives 2017, Mali 2018: only goes until 17 years

end
