 
 *UNESCO laptop version
 cd "C:\Users\mm_barrios-rivera\Documents\test test"
 
 *tip! using pattern to select what im interested interested
 
 filelist, dir("C:\Users\mm_barrios-rivera\OneDrive - UNESCO\EU labour force survey\LFS Datasets") pat("AT*.csv") save("lfs_datasets.dta") replace
 
 *my laptop version 
 cd "C:\Users\taiku\OneDrive - UNESCO\EU labour force survey"
  filelist, dir("C:\Users\taiku\OneDrive - UNESCO\EU labour force survey\LFS Datasets") pat("AT*.csv") save("lfs_datasets.dta") replace

 
         use "lfs_datasets.dta", clear
         local obs = _N
         forvalues i=1/`obs' {
           use "lfs_datasets.dta" in `i', clear
           local f = dirname + "/" + filename
		   local country_year = filename

		   di "now watching "   "`country_year'"
           import delimited  using "`f'", clear
		      
			fre hat11lev  
				 clear
         }

        