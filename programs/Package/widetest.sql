/* check values completion */
SELECT survey, country, year, category, comp_prim_v2 FROM wide_05142020 WHERE comp_prim_v2 <= 0 OR comp_prim_v2 >= 100;
SELECT survey, country, year, category, comp_lowsec_v2 FROM wide_05142020 WHERE comp_lowsec_v2 <= 0 OR comp_lowsec_v2 >= 100;
SELECT survey, country, year, category, comp_upsec_v2 FROM wide_05142020 WHERE comp_upsec_v2 <= 0 OR comp_upsec_v2 >= 100;

/* check values: completion by age group */
SELECT survey, country, year, category, round, comp_prim_1524 FROM wide_05142020 WHERE comp_prim_1524 <= 0 OR comp_prim_1524 >= 100;
SELECT survey, country, year, category, round, comp_lowsec_1524 FROM wide_05142020 WHERE comp_lowsec_1524 <= 0 OR comp_lowsec_1524 >= 100;
SELECT survey, country, year, category, round, comp_upsec_2029 FROM wide_05142020 WHERE comp_upsec_2029 <= 0 OR comp_upsec_2029 >= 100;
SELECT survey, country, year, category, round, eduyears_2024 FROM wide_05142020 WHERE eduyears_2024 <= 0 OR eduyears_2024 >= 100;

/* check values: less than x years schooling by age group */
SELECT survey, country, year, category, round, edu2_2024 FROM wide_05142020 WHERE edu2_2024 <= 0 OR edu2_2024 >= 100;
SELECT survey, country, year, category, round, edu4_2024 FROM wide_05142020 WHERE edu4_2024 <= 0 OR edu4_2024 >= 100;
SELECT survey, country, year, category, round, eduout_prim FROM wide_05142020 WHERE eduout_prim <= 0 OR eduout_prim >= 100;

/* check values: out of school by level */
SELECT survey, country, year, category, round, eduout_lowsec FROM wide_05142020 WHERE eduout_lowsec <= 0 OR eduout_lowsec >= 100;
SELECT survey, country, year, category, round, eduout_upsec FROM wide_05142020 WHERE eduout_upsec <= 0 OR eduout_upsec >= 100;

/* comparison among education levels within countries */
SELECT survey, country, year, category, comp_prim_v2, comp_lowsec_v2, comp_upsec_v2 FROM wide_05142020 WHERE comp_prim_v2 <= comp_lowsec_v2 OR comp_lowsec_v2 <= comp_upsec_v2;
SELECT survey, country, year, category, eduout_prim, eduout_lowsec, eduout_upsec FROM wide_05142020 WHERE eduout_prim >= eduout_lowsec OR eduout_lowsec >= eduout_upsec;

/* intertemporal indicator variation by country */
-- Comment on Oct/6/2020: Need to check below code. Previous version had a code error. 
SELECT survey, country, year, category, comp_prim_v2 - LEAD(comp_prim_v2) - OVER(PARTITION BY country ORDER BY year desc) AS diff FROM (SELECT * FROM wide_05142020 WHERE category = "total" ORDER BY country, year DESC);
