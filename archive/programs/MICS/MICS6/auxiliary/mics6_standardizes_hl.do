cap rename *, lower

egen year_folder = median(hh5y)

gen id=string(hh1)+" "+string(hh2)+" "+string(hl1)

for X in any hh7a hh7r: cap ren X region // for alternatives names of region
for X in any region: cap ren X hh7

for X in any y m d: cap ren hh5_X hh5X
for X in any y m d: cap ren hl5_X hl5X

*Particular to MICS6
drop ed3 ed7 // only indicates ages

ren ed4 ed3
for X in any a b: ren ed5X ed4X

ren ed9 ed5
cap drop ed6a
for X in any a b: ren ed10X ed6X

ren ed15 ed7
for X in any a b: ren ed16X ed8X

ren ed8 ed3_check
ren ed6 ed_completed // highest grade ATTENDED at that level

*For ethnicity & religion

cap ren ethnie ethnicity
cap ren ethnicidad ethnicity

cap drop hh71
cap drop hh72r

for X in any $list6 ed_completed windex5 schage ed1 hl5y hh5y: cap gen X=.

cap gen hl7=.
keep $vars_mics6 ed_completed country year* id

for X in any ed8a ed8b: cap gen X=.
for X in any ed4a ed4b ed6a ed6b ed8a ed8b: gen X_nr=X // create the numbers (without labels) for ed4a, ed6b etc
for X in any $list6 ed_completed: cap decode X, gen(temp_X)
for X in any $list6 ed_completed: cap tostring X, gen(temp_X)
for X in any ed3 ed5 ed7: cap tostring X, gen(temp_X) // for Palestine
drop $list6 ed_completed
for X in any $list6 ed_completed: cap ren temp_X X
cap label drop _all

for X in any ethnicity region religion: replace X=proper(X)
compress
