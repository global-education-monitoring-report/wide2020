*****************************
* eu_silc_survey_list.do
*****************************

/*
** Note 
* Datasets n/a in 2005 wave for:

- BG 
- CH 
- **EL
- HR
- MT
- RO

** RV: Corrected this: there are datasets for EL 2005 (had other code), 

*/



*=====================
* Datasets

#delimit;
local survey_list_EU_SILC "

AT\2005\AT.dta
AT\2011\AT.dta
AT\2013\AT.dta
AT\2014\AT.dta

BE\2005\BE.dta
BE\2011\BE.dta
BE\2013\BE.dta
BE\2014\BE.dta

BG\2011\BG.dta
BG\2013\BG.dta
BG\2014\BG.dta

CH\2011\CH.dta
CH\2013\CH.dta
CH\2014\CH.dta

CY\2005\CY.dta
CY\2011\CY.dta
CY\2013\CY.dta
CY\2014\CY.dta

CZ\2005\CZ.dta
CZ\2011\CZ.dta
CZ\2013\CZ.dta
CZ\2014\CZ.dta

DE\2005\DE.dta
DE\2011\DE.dta
DE\2013\DE.dta
DE\2014\DE.dta

DK\2005\DK.dta
DK\2011\DK.dta
DK\2013\DK.dta
DK\2014\DK.dta

EE\2005\EE.dta
EE\2011\EE.dta
EE\2013\EE.dta
EE\2014\EE.dta

EL\2005\EL.dta
EL\2011\EL.dta
EL\2013\EL.dta
EL\2014\EL.dta

ES\2005\ES.dta
ES\2011\ES.dta
ES\2013\ES.dta
ES\2014\ES.dta

FI\2005\FI.dta
FI\2011\FI.dta
FI\2013\FI.dta
FI\2014\FI.dta

FR\2005\FR.dta
FR\2011\FR.dta
FR\2013\FR.dta
FR\2014\FR.dta

HR\2011\HR.dta
HR\2013\HR.dta
HR\2014\HR.dta

HU\2005\HU.dta
HU\2011\HU.dta
HU\2013\HU.dta
HU\2014\HU.dta

IE\2005\IE.dta
IE\2011\IE.dta
IE\2013\IE.dta
IE\2014\IE.dta

IS\2005\IS.dta
IS\2011\IS.dta
IS\2013\IS.dta
IS\2014\IS.dta

IT\2005\IT.dta
IT\2011\IT.dta
IT\2013\IT.dta
IT\2014\IT.dta

LT\2005\LT.dta
LT\2011\LT.dta
LT\2013\LT.dta
LT\2014\LT.dta

LU\2005\LU.dta
LU\2011\LU.dta
LU\2013\LU.dta
LU\2014\LU.dta

LV\2005\LV.dta
LV\2011\LV.dta
LV\2013\LV.dta
LV\2014\LV.dta

MT\2011\MT.dta
MT\2013\MT.dta
MT\2014\MT.dta

NL\2005\NL.dta
NL\2011\NL.dta
NL\2013\NL.dta
NL\2014\NL.dta

NO\2005\NO.dta
NO\2011\NO.dta
NO\2013\NO.dta
NO\2014\NO.dta

PL\2005\PL.dta
PL\2011\PL.dta
PL\2013\PL.dta
PL\2014\PL.dta

PT\2005\PT.dta
PT\2011\PT.dta
PT\2013\PT.dta
PT\2014\PT.dta

RO\2011\RO.dta
RO\2013\RO.dta
RO\2014\RO.dta

RS\2013\RS.dta
RS\2014\RS.dta

SE\2005\SE.dta
SE\2011\SE.dta
SE\2013\SE.dta
SE\2014\SE.dta

SI\2005\SI.dta
SI\2011\SI.dta
SI\2013\SI.dta
SI\2014\SI.dta

SK\2005\SK.dta
SK\2011\SK.dta
SK\2013\SK.dta
SK\2014\SK.dta

UK\2005\UK.dta
UK\2011\UK.dta
UK\2013\UK.dta
UK\2014\UK.dta

";			       
#delimit cr;	

