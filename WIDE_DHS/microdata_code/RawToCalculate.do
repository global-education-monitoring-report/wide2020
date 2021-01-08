* WIDE - Converting into Micro Data from Raw Data
* Date: December 2020
* Contact: Sunmin Lee, Marcela Barrios Rivera, Bilal Barakat


* Set the directories (change this path depending on your data located)
* Make sure to run "step" code and below "path" code together! 
local dpath "/Users/sunminlee/Desktop/gemr/wide_etl/raw_data"
local opath "/Users/sunminlee/Desktop/gemr/wide_etl/output"

** MICS - ALL Step **
* Run ALL four steps from "mics" survey (this will produce same result with above)
set trace on
widetable, source(mics) step(all) data_path(`dpath') output_path(`opath') nf(1)
set trace off 


** MICS - EACH Step **
* Run the first step "read" from "mics" survey (using mics_read.ado)
set trace on
widetable, source(mics) step(read) data_path(`dpath') output_path(`opath') nf(1)
set trace off

* Run the second step "clean" from "mics" survey (using mics_clean.ado)
set trace on
widetable, source(mics) step(clean) data_path(`dpath') output_path(`opath') nf(1)
set trace off 

* Run the third step "calculate" from "mics" survey (using mics_calculate.ado)
set trace on
widetable, source(mics) step(calculate) data_path(`dpath') output_path(`opath') nf(1)
set trace off 

* Run the fourth step "summarize" from "mics" survey (using mics_summarize.ado)
set trace on
widetable, source(mics) step(summarize) data_path(`dpath') output_path(`opath') nf(1)
set trace off 


** DHS - ALL Step **
* Run ALL four steps from "dhs" survey (this will produce same result with above)
set trace on
widetable, source(dhs) step(all) data_path(`dpath') output_path(`opath') nf(1)
set trace off 


* Set the directories (change this path depending on your data located)
* Make sure to run "step" code and below "path" code together! 
local dpath "/Users/sunminlee/Desktop/gemr/wide_etl/raw_data"
local opath "/Users/sunminlee/Desktop/gemr/wide_etl/output"

** DHS - EACH Step **
* Run the first step "read" from "mics" survey (using mics_read.ado)
set trace on
widetable, source(dhs) step(read) data_path(`dpath') output_path(`opath') nf(1)
set trace off

* Run the second step "clean" from "mics" survey (using mics_clean.ado)
set trace on
widetable, source(dhs) step(clean) data_path(`dpath') output_path(`opath') nf(1)
set trace off 

* Run the third step "calculate" from "mics" survey (using mics_calculate.ado)
set trace on
widetable, source(dhs) step(calculate) data_path(`dpath') output_path(`opath') nf(1)
set trace off 

* Run the fourth step "summarize" from "mics" survey (using mics_summarize.ado)
set trace on
widetable, source(dhs) step(summarize) data_path(`dpath') output_path(`opath') nf(1)
set trace off 
