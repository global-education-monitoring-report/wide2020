program define widetests
    args data_path

odbc load, table("wide") dsn("widedb")

SELECT survey, country_year, category, comp_prim_v2 FROM widetable WHERE comp_prim_v2 <= 0 OR comp_prim_v2_m >= 100;

SELECT survey, country_year, category, round, comp_lowsec_v2 FROM widetable WHERE comp_lowsec_v2 <= 0 OR comp_lowsec_v2_m >= 100;

SELECT survey, country_year, category, round, comp_upsec_v2 FROM widetable WHERE comp_upsec_v2 <= 0 OR comp_upsec_v2_m >= 100;

SELECT survey, country_year, category, round, comp_prim_1524 FROM widetable WHERE comp_prim_1524 <= 0 OR comp_prim_1524 >= 100;

SELECT survey, country_year, category, round, comp_lowsec_1524 FROM widetable WHERE  comp_lowsec_1524 <= 0 OR comp_lowsec_1524 >= 100;

SELECT survey, country_year, category, round, comp_upsec_2029 FROM widetable WHERE comp_upsec_2029 <= 0 OR comp_upsec_2029 >= 100;

SELECT survey, country_year, category, round, eduyears_2024 FROM widetable WHERE eduyears_2024 <= 0 OR eduyears_2024 >= 100;

SELECT survey, country_year, category, round, edu2_2024 FROM widetable WHERE edu2_2024 <= 0 OR edu2_2024 >= 100;
SELECT survey, country_year, category, round, edu4_2024 FROM widetable WHERE edu4_2024 <= 0 OR edu4_2024 >= 100;

SELECT survey, country_year, category, round, eduout_prim FROM widetable WHERE eduout_prim <= 0 OR eduout_prim >= 100;

SELECT survey, country_year, category, round, eduout_lowsec FROM widetable WHERE eduout_lowsec <= 0 OR eduout_lowsec >= 100;

SELECT survey, country_year, category, round, eduout_upsec FROM widetable WHERE eduout_upsec <= 0 OR eduout_upsec >= 100;


SELECT survey, country_year, category,  comp_prim_v2, comp_lowsec_v2, comp_upsec_v2 FROME widetable WHERE comp_prim_v2 <= comp_lowsec_v2 OR comp_lowsec_v2 <= comp_upsec_v2

SELECT survey, country_year, category,  eduout_prim, eduout_lowsec, eduout_upsec FROME widetable WHERE eduout_prim >= eduout_lowsec OR eduout_lowsec >= eduout_upsec



end
