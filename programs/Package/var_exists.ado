program define var_exists
	args var1 var2 new_name
	

       capture confirm var `var1' `var2' 
       
       if _rc == 0 { 
                drop `var1'
                rename `var2' `new_name'
       }
       else {
			capture confirm var `var1' 
			if _rc == 0 { 
				rename `var1' `new_name'
			} 
			else {
				rename `var2' `new_name'
			}
       }
end


