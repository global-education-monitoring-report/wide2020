**Checks on priority countries

    foreach ctry in ca17 ca16 ca15 ca14 ca13 ca12 ca11 ca10 {
			*** merge
			use $`ctry'p, clear
			merge m:1 hid using $`ctry'h, keep(match) nogen
			
			 codebook educ educ_c enroll educlev edyrs illiterate
                         set trace on
			 tab region_c, m
			 tab region_c, m nol
			 tab ethnic_c, m
			 tab ethnic_c, m nol
			 tab educ
			 tab educ, nol
			 tab educ_c
			 tab educ_c, nol
 			 tab edyrs, m
			 tab sex
			 tab sex, nol
			 tab rural
			 tab rural, nol
                         set trace off
			
}
