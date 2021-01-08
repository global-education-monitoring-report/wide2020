*******************************************
*WIDE-MICRODATA
*10-12-2020
*******************************************


*MICS for Bangladesh and Afghanistan worked fine
*Don't forget filenames.xlsx file

local dpath "C:\WIDE\raw_data"
local opath "C:\WIDE\output"

set trace on
widetable, source(mics) step(read) data_path(`dpath') output_path(`opath') nf(2)
set trace off

*ok

local dpath "C:\WIDE\raw_data"
local opath "C:\WIDE\output"

set trace on
widetable, source(mics) step(clean) data_path(`dpath') output_path(`opath') nf(2)
set trace off

*ok

local dpath "C:\WIDE\raw_data"
local opath "C:\WIDE\output"

set trace on
widetable, source(mics) step(calculate) data_path(`dpath') output_path(`opath') nf(2)
set trace off

*made several changes to this file 
