**Checks on priority countries

    foreach ctry in us14 us15 us16 us17 us18 {
			*** merge
			use $`ctry'p, clear
			merge m:1 hid using $`ctry'h, keep(match) nogen
			
			 codebook educ educ_c enroll educlev edyrs illiterate
              set trace on
			 tab region_c, m
			 tab region_c, m nol
			 tab ethnic_c, m
			 tab ethnic_c, m nol
			 tab age enroll 
			 tab educ
			 tab educ, nol
			 tab age educ 
			 tab educ_c
			 tab educ_c, nol
 			 tab age educ_c 
 			 tab edyrs, m
			 tab age educlev
			 tab sex
			 tab sex, nol
			 tab rural
			 tab rural, nol
             set trace off
			
}
