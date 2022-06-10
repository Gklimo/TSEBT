. use "/Users/gabi2000/Desktop/therapy/therapy.dta", 


import excel "/Users/gabi2000/Desktop/therapy/therapy fin2.xlsx", sheet("Sheet1") firstrow case(lower) clear


rename timetorelapsemergeddatafro trel
rename timetoresponse trem
rename remissioncode remcode
rename percentagechangeinmswatafter percent_change
rename remissionhappenedornotatal rem
rename relapsehappeningduringfollow rel
rename ctclstagecode stage
rename maintenancetherapy maintenance
rename total_n_prior_therapies prior_therap
rename timetotreatmentfromdiagnosis timetotr


 destring bmi, generate(bmi_num)
 destring ethnicitycode, generate(ethnicity_num)
 destring timefromnoticingtodiagnosis, generate(timetodiag)

 
 codebook timetodiag
 codebook bmi_num
 codebook timetodeath
 
 
gen bmicat=bmi_num
recode bmicat min/18.5=0 18.51/24.9=1 24.91/29.9=2 29.91/max = 3
label define bmicat 0 "Underweight" 1 "Normal" 2 "Overweight" 3 "Obese"
label values bmicat bmicat
tab bmicat
 
 
 
label define ethnicity_num 0 "White British" 1 "White Irish" 2 "White Other"
label values ethnicity_num ethnicity_num
tab ethnicity_num
 
label define gender 0 "male" 1 "female"
label values gender gender
tab gender

label define others 0 "NO" 1 "YES"
label values others others
tab others

label define death 0 "NO" 1 "YES"
label values death death
tab others


label define alcohol 0 "non-drinker" 1 "drinker"
label values alcohol alcohol
tab alcohol

label define smoking_binary 0 "non-smoker" 1 "smoker"
label values smoking_binary smoking_binary
tab smoking_binary


label define stage 0 "IA" 1 "IB" 2 "IIB" 3 "IV"
label values stage stage
tab stage

rename largecelltransformation lct
rename folliculotrophic ftrophic
rename ageattimeoftsebt age
rename  history_of_psoriasis_echzema hist_p_e
rename previous_unrelated_malignancy prevmal
rename high_cholesterol hchol
rename localisedradiotherapy_done_befo locrad

label define lct 0 "NO" 1 "YES"
label values lct lct
tab lct


label define hchol 0 "NO" 1 "YES"
label values hchol hchol
tab hchol

label define diabetes 0 "NO" 1 "YES"
label values diabetes diabetes
tab hchol

label define hist_p_e 0 "NO" 1 "YES"
label values hist_p_e hist_p_e
tab hist_p_e

label define prevmal 0 "NO" 1 "YES"
label values prevmal prevmal
tab prevmal

label define ftrophic 0 "NO" 1 "YES"
label values ftrophic ftrophic
tab ftrophic

label define htn 0 "NO" 1 "YES"
label values htn htn
tab htn

label define smoking_code 0 "Never" 1 "Ex-smoker" 2 "Current"
label values smoking_code smoking_code
tab smoking_code


label define locrad 0 "NO" 1 "YES"
label values locrad locrad
tab locrad


label define maintenance 0 "NO" 1 "YES"
label values maintenance maintenance
tab locrad



label define remcode 0 "Partial Response" 1 "Complete Response" 2 "Stable Disease" 3 "Progressive Disease"
label values remcode remcode
tab remcode





 tab stage rem, cell
 tab stage remcode, cell
 tab stage rel, cell



stset trem, failure(rem)
stsum
stci 
sum trem



 
stcox i.stage
stcox age
stcox i.ethnicity_num
stcox i.gender 
stcox i.alcohol 
stcox i.smoking_code 
stcox bmi_num 
stcox i.bmicat 
stcox i.ftrophic 
stcox i.lct 
stcox i.prevmal 
stcox i.hist_p_e 
stcox i.htn 
stcox i.hchol 
stcox i.diabetes 
stcox i.locrad 
stcox timetodiag
stcox prior_therap
stcox gemcitabine
stcox chop
stcox uvb
stcox puva
stcox interferon
stcox methotrexate
stcox brentruximab
stcox proclipi
stcox gembextrial
stcox others
stcox maintenance
stcox timetotr

stcox i.stage others
est store a
** check for interaction term - effect modifications
stcox i.stage##others 
est store b
lrtest a b 

** check for confounders
stcox i.stage
** age as confounder
stcox i.stage others
** others as confounder - final model
stcox i.stage age





stcurve, survival
stcurve, survival at1(stage = 0) at2(stage = 1) at3(stage=2) at4(stage = 3)

 
stcox i.stage age , schoenfeld(sc2*) scaledsch(ssc2*)
estat phtest, log detail


*Fully adjusted model
stphplot, strata(stage) adjust(age)






stsum, by(stage)
stci, by(stage) /*to obtain CI for median time to discharge */
sts test stage

** kaplan-meier plot
sts graph, by(stage) risktable(0 (20) 160) tmax(160) xlabel(0 (20) 160) ytitle("Proportion with response") xtitle("Time since TSEBT started (days)") title("Time since the TSEBT start to response by stage")



stsum, by(maintenance)
stci, by(maintenance) /*to obtain CI for median time to discharge */
sts test maintenance

** kaplan-meier plot
sts graph, by(maintenance) risktable(0 (20) 160) tmax(160) xlabel(0 (20) 160) ytitle("Proportion with response") xtitle("Time since TSEBT started (days)") title("Time since the TSEBT start to response by stage")

sts graph, risktable(0 (20) 160) tmax(160) xlabel(0 (20) 160)  ytitle("Proportion with response") xtitle("Time since TSEBT started (days)") title("Time since the TSEBT start to response") gwood

** relapse time

stset trel, failure(rel)
stsum
stci
sum trel

** kaplan-meier plot
** remove patients not in remission
drop if remcode > = 2

rename remcode type

label define type 0 "Partial" 1 "Complete" 
label values type type

sts graph, by(type) risktable(0 (50) 450) tmax(450) xlabel(0 (50) 450) ytitle("Proportion relapsed") xtitle("Time since TSEBT start to relapse (days)") title("Time since TSEBT treatment start to date of relapse")

rename ftrophic follicotrophic
sts graph, by(follicotrophic) risktable(0 (50) 450) tmax(450) xlabel(0 (50) 450) ytitle("Proportion relapsed") xtitle("Time since TSEBT start to relapse (days)") title("Time since TSEBT treatment start to date of relapse")


sts graph, by(lct) risktable(0 (50) 450) tmax(450) xlabel(0 (50) 450) ytitle("Proportion relapsed") xtitle("Time since TSEBT start to relapse (days)") title("Time since TSEBT treatment start to date of relapse")


stsum, by(remcode)
stci, by(remcode) /*to obtain CI for median time to discharge (optional)*/
sts test remcode

stsum, by(lct)
stci, by(lct) /*to obtain CI for median time to discharge (optional)*/
sts test lct

stsum, by(ftrophic)
stci, by(ftrophic) /*to obtain CI for median time to discharge (optional)*/
sts test ftrophic


stcox i.stage
stcox age
stcox i.ethnicity_num
stcox i.gender 
stcox i.alcohol 
stcox i.smoking_code 
stcox bmi_num 
stcox i.bmicat 
stcox i.ftrophic 
stcox i.lct 
stcox i.prevmal 
stcox i.hist_p_e 
stcox i.htn 
stcox i.hchol 
stcox i.diabetes 
stcox i.locrad 
stcox timetodiag
stcox prior_therap
stcox gemcitabine
stcox chop
stcox uvb
stcox puva
stcox interferon
stcox methotrexate
stcox brentruximab
stcox proclipi
stcox gembextrial
stcox others
stcox maintenance
stcox rem
stcox trem
stcox timetotr


stcox i.stage i.others i.lct timetodiag 
est store a

stcox i.stage##i.others i.lct timetodiag 
est store b
lrtest a b

stcox i.stage##i.lct i.others timetodiag 
est store c
lrtest a c


stcox i.stage i.others 
est store a

stcox i.stage##i.others 
est store b
lrtest a b
stcox i.stage i.lct 
est store c
stcox i.stage##i.lct 
est store d
lrtest c d

**confounder check
stcox i.stage
stcox i.stage i.others
stcox i.stage
stcox i.stage i.lct
stcox i.stage
stcox i.stage timetodiag

stcox i.stage i.others

stcurve, survival
stcurve, survival at1(stage = 0) at2(stage = 1) at3(stage=2) at4(stage = 3)

 
stcox i.stage i.others , schoenfeld(scb*) scaledsch(sscb*)
estat phtest, log detail


stsum, by(stage)
stci, by(stage) /*to obtain CI for median time to discharge (optional)*/
sts test stage

** kaplan-meier plot
sts graph, by(stage) risktable(0 (50) 450) tmax(450) xlabel(0 (50) 450) ytitle("Proportion relapsed") xtitle("Time since TSEBT start to relapse (days)") title("Time since TSEBT treatment start to date of relapse")


stsum, by(maintenance)
stci, by(maintenance) /*to obtain CI for median time to discharge (optional)*/
sts test maintenance

sts graph, by(maintenance) risktable(0 (50) 450) tmax(450) xlabel(0 (50) 450) ytitle("Proportion relapsed") xtitle("Time since TSEBT start to relapse (days)") title("Time since TSEBT treatment start to date of relapse")



sts graph, risktable(0 (50) 450) tmax(450) xlabel(0 (50) 450)  ytitle("Proportion relapsed") xtitle("Time since TSEBT start to relapse (days)") title("Time since TSEBT treatment start to date of relapse") gwood


stset timetodeath, failure(death)
stsum
stci /*to obtain CI for median time to discharge (optional)*/
sum timetodeath

stsum, by(stage)
stci, by(stage) /*to obtain CI for median time to discharge (optional)*/
sts test stage

** kaplan-meier plot
sts graph, by(stage) risktable(0 (12) 72) tmax(72) xlabel(0 (12) 72) ytitle("Proportion dead") xtitle("Time since TSEBT start to death (months)") title("Time since TSEBT treatment start to death date")

stsum, by(maintenance)
stci, by(maintenance) /*to obtain CI for median time to discharge (optional)*/
sts test maintenance

sts graph, by(maintenance) risktable(0 (12) 72) tmax(72) xlabel(0 (12) 72) ytitle("Proportion dead") xtitle("Time since TSEBT start to death (months)") title("Time since TSEBT treatment start to death date")



sts graph, risktable(0 (12) 72) tmax(72) xlabel(0 (12) 72) ytitle("Proportion dead") xtitle("Time since TSEBT start to death (months)") title("Time since TSEBT treatment start to death date") gwood


** demographics
codebook age gender alcohol smoking_code bmi_num bmicat ftrophic lct stage prevmal hist_p_e htn hchol diabetes locrad total_n_prior_therapies death timetodeath

stcox rem
stcox rel





