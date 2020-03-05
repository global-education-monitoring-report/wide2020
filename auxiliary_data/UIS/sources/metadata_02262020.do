global raw "O:\ED\ProgrammeExecution\GlobalEducationMonitoringReport_GEMR\1.ReportDevelopment\WIDE\WIDE\data_created\auxiliary_data\UIS\sources\02262020"

insheet using "$raw\EDUN_METADATA_02262020.csv", clear
ren country_id iso_code3
keep if indicator=="CR.1"|indicator=="CR.2"|indicator=="CR.3"|indicator=="ROFST.H.1"|indicator=="ROFST.H.2"|indicator==""|indicator=="ROFST.H.3"
drop type
*tab indicator
compress

gen source_uis=""
foreach X in MICS DHS PNAD CASEN ECLAC EU-SILC IPUMS-International SLID CFPS ENEMDU HES-SIH IHS ENCOVI HDS HES RLMS-HSE IPUMS-USA CPS-ASEC {
replace source_uis="`X'" if strpos(metadata, "`X'") > 0
}

codebook source_uis, tab(100)

gen note_source=""
replace note_source="Taken directly from WIDE" if strpos(metadata, "WIDE") > 0

for X in any 1 2 3: replace indicator_id="comp_X" if indicator_id=="CR.X"
for X in any 1 2 3: replace indicator_id="eduout_X" if indicator_id=="ROFST.H.X"

split indicator_id, parse(_) gen(indic)
drop indicator_id
ren indic1 indicator
ren indic2 level
replace level="prim" if level=="1"
replace level="lowsec" if level=="2"
replace level="upsec" if level=="3"

order indicator level

for X in any metadata source_uis note_source: ren X X_
reshape wide metadata source_uis note_source, i(level iso_code3 year) j(indicator) string
for X in any metadata_comp source_uis_comp note_source_comp metadata_eduout source_uis_eduout note_source_eduout: rename X X_
reshape wide metadata* source_uis* note_source*, i(iso_code3 year) j(level) string
ren year year_uis
compress
save "P:\WIDE\auxiliary_data\UIS\sources\UIS_metadata_02262020.dta", replace
