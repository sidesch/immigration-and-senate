clear
set more off
pause off

cd "~/Desktop/school/4th/ecn286/dofiles"
use usa_00004.dta, replace

drop if year <= 1999 | year > 2016

drop if age < 18

decode statefip, gen(state)
replace state = strupper(state)

gen immigratethisyear = 0
replace immigratethisyear = 1 if yrimmig == year

gen whitenothispanic = 0
replace whitenothispanic = 1 if race == 1 & hispan == 0

gen unemployed = 0
replace unemployed = 1 if empstat == 2

gen laborforce = 0
replace laborforce = 1 if labforce == 2

gen college = 0
replace college = 1 if educ == 10 | educ == 11

gen pop = 1
collapse (sum) immigratethisyear unemployed laborforce pop (mean) whitenothispanic college age inctot [pw = perwt],  by (state year)

gen unemployment = unemployed / laborforce

save finalData.dta, replace

merge 1:1 state year using merged-house.dta

drop _merge
