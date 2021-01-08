* widetests: program to test education indicators 
* Version 2.0
* May 2020

program define widetests
    syntax, table(string) nquery(integer 1)

    *odbc load, table("wide") dsn("WIDE")
	
	* check values completion
	local query1 "SELECT survey, country, year, category, comp_prim_v2 FROM `table' WHERE comp_prim_v2 <= 0 OR comp_prim_v2 >= 100;"
	local query2 "SELECT survey, country, year, category, comp_lowsec_v2 FROM `table' WHERE comp_lowsec_v2 <= 0 OR comp_lowsec_v2 >= 100;"
	local query3 "SELECT survey, country, year, category, comp_upsec_v2 FROM `table' WHERE comp_upsec_v2 <= 0 OR comp_upsec_v2 >= 100;"

	* check values: completion by age group
	local query4 "SELECT survey, country, year, category, round, comp_prim_1524 FROM `table' WHERE comp_prim_1524 <= 0 OR comp_prim_1524 >= 100;"
	local query5 "SELECT survey, country, year, category, round, comp_lowsec_1524 FROM `table' WHERE comp_lowsec_1524 <= 0 OR comp_lowsec_1524 >= 100;"
	local query6 "SELECT survey, country, year, category, round, comp_upsec_2029 FROM `table' WHERE comp_upsec_2029 <= 0 OR comp_upsec_2029 >= 100;"
	local query7 "SELECT survey, country, year, category, round, eduyears_2024 FROM `table' WHERE eduyears_2024 <= 0 OR eduyears_2024 >= 100;"
	
	* check extreme values: less than x years schooling by age group
	local query8 "SELECT survey, country, year, category, round, edu2_2024 FROM 	`table' WHERE edu2_2024 <= 0 OR edu2_2024 >= 100;"
	local query9 "SELECT survey, country, year, category, round, edu4_2024 FROM `table' WHERE edu4_2024 <= 0 OR edu4_2024 >= 100;"
	local query10 "SELECT survey, country, year, category, round, eduout_prim FROM `table' WHERE eduout_prim <= 0 OR eduout_prim >= 100;"

	* check extreme values: out of school by level
	local query11 "SELECT survey, country, year, category, round, eduout_lowsec FROM `table' WHERE eduout_lowsec <= 0 OR eduout_lowsec >= 100;"
	local query12 "SELECT survey, country, year, category, round, eduout_upsec FROM `table' WHERE eduout_upsec <= 0 OR eduout_upsec >= 100;"

	* compare among education levels within countries
	local query13 "SELECT survey, country, year, category, comp_prim_v2, comp_lowsec_v2, comp_upsec_v2 FROM `table' WHERE comp_prim_v2 <= comp_lowsec_v2 OR comp_lowsec_v2 <= comp_upsec_v2;"
	local query14 "SELECT survey, country, year, category, eduout_prim, eduout_lowsec, eduout_upsec FROM `table' WHERE eduout_prim >= eduout_lowsec OR eduout_lowsec >= eduout_upsec;"

	* check intertemporal indicator variation by country
	local query15 "SELECT survey, country, year, category, comp_prim_v2 - LEAD(comp_prim_v2) OVER(PARTITION BY country ORDER BY year desc) AS diff FROM (SELECT * FROM `table' WHERE category = "total" ORDER BY country, year DESC)t;"



	if nquery == 1 {
	odbc load, exec("`query1'")
	}
	else if nquery == 2 {
	odbc load, exec("`query2'")
	}
	else if nquery == 3 {
	odbc load, exec("`query3'")
	}
	else if nquery == 4 {	
	odbc load, exec("`query4'")
	}
	else if nquery == 5 {
	 odbc load, exec("`query5'")
	}
	else if nquery == 6 {	
	odbc load, exec("`query6'")
	}
	else if nquery == 7 {
	odbc load, exec("`query7'") 
	}
	else if nquery == 8 {
	odbc load, exec("`query8'")
	}
	else if nquery == 9 {
	odbc load, exec("`query9'")
	}
	else if nquery == 10 {
	odbc load, exec("`query10'")
	}
	else if nquery == 11 {
	odbc load, exec("`query11'")
	}
	else if nquery == 12 {
	odbc load, exec("`query12'")
	}
	else if nquery == 13 {
	odbc load, exec("`query13'")
	}
	else if nquery == 14 {
	odbc load, exec("`query14'")
	}
	else if nquery == 15 {
	odbc load, exec("`query15'")
	}
	else {
	display as error "`nquery’ only can be an integer between 1 and 15"
	}

end
