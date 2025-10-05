clear
set more off
pause off

cd "~/Desktop/school/4th/ecn286/dofiles"
use finalData.dta, replace

*** Merge Logistics
merge 1:1 state year using merged-house.dta
drop _merge

*** Scaling percentages by 100
replace conservative = conservative*100
replace unemployment = unemployment*100
replace whitenothispanic = whitenothispanic*100

*** Creating red/blue state dummy variable
egen mean_cons = mean(conservative), by(state)
gen red = 0
replace red = 1 if mean_cons > 53
replace red = 0 if mean_cons <= 53

*** Creating Percent of population that immigrated this year variable
gen immpercap = immigratethisyear/pop
replace immpercap = immpercap * 100

*** Labels
label var immigratethisyear "Immigrants 5% Sample"
label var immpercap "Percent of Immigrants * 100"
label var unemployment "Unemployment Rate"
label var whitenothispanic "White, not Hispanic"
label var college "College Degree"
label var age "Age"
label var state "State"
label var year "Year"
label var inctot "Income"
label var conservative "Conservative Rate"

*** Necessary numeric state variable
egen state_num = group(state)

*** Creating Region Variable
gen region = "Southeast"
replace region = "Southwest" if state_num == 3 | state_num == 31 | state_num == 36 | state_num == 43 | state_num == 5
replace region = "West" if state_num == 2 | state_num == 11 | state_num == 12 | state_num == 26 | state_num == 28 | state_num == 37 | state_num == 44 | state_num == 6 | state_num == 47 | state_num == 50
replace region = "Midwest" if state_num == 13 | state_num == 15 | state_num == 16 | state_num == 22 | state_num == 23 | state_num == 25 | state_num == 27 | state_num == 34 | state_num == 25 | state_num == 41 | state_num == 49
replace region = "Northeast" if state_num == 7 | state_num == 8 | state_num == 19 | state_num == 20 | state_num == 21 | state_num == 29 | state_num == 30 | state_num == 32 | state_num == 38 | state_num == 39 | state_num == 45

*** Summary stats table
est clear
estpost tabstat immpercap unemployment whitenothispanic college age inctot conservative, by(red) statistics(mean sd) columns(statistics)
eststo summary
esttab using "ECN286Table1.tex", label varwidth(30) cells(mean(label(Mean) fmt(2)) sd(label(SD) fmt(2) par)) replace title("Summary Statistics")


*** Standard regression
xtreg immigratethisyear conservative, cluster(state_num)
est store std

*** Regression With Lagged Conservative Rate
xtset state_num year
xtreg immigratethisyear L.conservative, cluster(state_num)
est store lag

*** Regression with Lagged Conservative Rate and Controls
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop, cluster(state_num)
est store ctrl

*** Regression with Lagged Conservative Rate, Controls, and Time FE
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.year, cluster(state_num)
est store time

*** Regression with Lagged Conservative Rate, Controls, and State FE
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num, cluster(state_num)
est store state

*** Regression with Lagged Conservative Rate, Controls, and both FE
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num i.year, cluster(state_num)
est store fe

*** Table with Regressions
esttab std lag ctrl time state fe using "ECN286Table2.tex", label nonumbers mtitles("Standard" "Lagged" "Controls" "Time FE" "State FE" "Fixed Effects") replace title("Linear Regression") ci


*** Heterogeneity analysis
*** Southwest Regression
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num i.year if region == "Southwest", cluster(state_num) 
est store southwest
*** possibly bootstrap cluster

*** Southeast Regression
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num i.year if region == "Southeast", cluster(state_num) 
est store southeast

*** West Regression
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num i.year if region == "West", cluster(state_num) 
est store west

*** Midwest Regression
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num i.year if region == "Midwest", cluster(state_num) 
est store midwest

*** Northeast Regression
xtreg immigratethisyear L.conservative unemployment whitenothispanic college age inctot pop i.state_num i.year if region == "Northeast", cluster(state_num) 
est store northeast

esttab southwest southeast west midwest northeast using "ECN286Table3.tex", label nonumbers mtitles("Southwest" "Southeast" "West" "Midwest" "Northeast") replace title("Heterogeneity") ci

*** Scatter Plot
gen lag = L.conservative
label var lag "Lagged Conservative Rate"
twoway (scatter immpercap lag) (lfit immpercap lag)


