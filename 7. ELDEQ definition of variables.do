cd // this line sets the working directory to where this do-file is stored!

**# Note
/*
time-varying variables will be averaged to produce a variable with the average of waves (i.e., "trend")
in presence of missing data, such procedure might bias estimations
time-varying variables will be marked with an "o_" as in original, as a reminder for multiple imputation
the derivates of time-varying variables will me marked with a "p_" as in passive
such variables will have to be deleted before the imputation, and generated as passive variables within the imputation framework
*/

**# Merge ELDEQ w/ADMIN & w/exposure trajectories

use ELDEQ, clear

rename *, lower

drop adpjt01 fqmmt06 fqpjt06 asffl01b csffl01b esffl01b gsffl01b isffl01b ksffl01b ehlfq2a3 ehlfq2a4 ghlfq2a3 ghlfq2a4 ihlfq2a3 ihlfq2a4 *hdnq10b *hdnq10c *hdnq10d *hdnq10e *hdnq10f *hdnq10g rhdn10ca rhdn10da rhdn10ea rhdn10fa rhdn10ga phdn10ca phdn10da phdn10ea phdn10fa phdn10ga mhdnq9 nhdnq9 phdnq9 rhdnq9

merge 1:1 noindiv using ADMIN_FINAL_DETAILED, keepusing(sex)
order sex, after(noindiv)

drop _merge

* actual age of children
rename maged02 cage13
rename naged02 cage14
rename paged02 cage16
rename raged02 cage18
label variable cage13 "Age of child at E13"
label variable cage14 "Age of child at E14"
label variable cage16 "Age of child at E16"
label variable cage18 "Age of child at E18"
sum cage13-cage18
graph box cage13 cage14 cage16 cage18, title("{bf:Actual age of children}") legend(label(1 "E13 (12y)") label(2 "E14 (13y)") label(3 "E15 (15y)") label(4 "E16 (17y)") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero)) yline(12 13 15 17)

**# Checking and recoding

* labeling sex
label variable sex "Sex"
label define sex1 1 "Female" 2 "Male"
label values sex sex1

* maternal age - recode tails to more populous categories
tab aagmd01
replace aagmd01 = aagmd01 - 1
replace aagmd01 = 1 if aagmd01 == 0
replace aagmd01 = 4 if aagmd01 == 5
label variable aagmd01 "Maternal age (years)"
label define agem 1 "<24" 2 "25-29" 3 "30-34" 4 "35+"
label values aagmd01 agem
tab aagmd01
rename aagmd01 agemom

* ethnicity
label define yes1no0 0 "No" 1 "Yes"
label values asdmd4aa yes1no0
label values asdjd4aa yes1no0
label variable asdmd4aa "Canadian-born mother"
label variable asdjd4aa "Canadian-born father"
tab1 asdmd4aa asdjd4aa
rename asdmd4aa ethnicitymom
rename asdjd4aa ethnicitydad

* family type - recode as dichotomous, intact, non-intact
tab afafd02
replace afafd02 = afafd02 - 1
replace afafd02 = 1 if afafd02 == 2
label variable afafd02 "Family type"
label define famtype 0 "Intact, two-parent family" 1 "Step- or single-parent family"
label values afafd02 famtype
tab afafd02
rename afafd02 familytype

* maternal depression
graph box adpmt01 bdpmt01 ddpmt01 fdpmt01 hdpmt01 kdpmt01, title("{bf:Maternal depression}") legend(label(1 "5mo") label(2 "17mo") label(3 "3.5y") label(4 "3.5y") label(5 "5y") label(6 "7y") label(7 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

foreach var of varlist adpmt01 bdpmt01 ddpmt01 fdpmt01 hdpmt01 kdpmt01	{
	label variable `var' "Maternal depression"
}

rename *dpmt01 o_*_maternaldepression

**# The mean of maternal depression - need to be re-defined as passive variables after imputation!
egen p_maternaldepression = rowmean(o_*_maternaldepression)
label variable p_maternaldepression "maternal depression, mean (SD)"
hist p_maternaldepression

* positive parenting practices
graph box apret01 bpret01 cpret01 dpret01 epret01 fpret01 gpret01 ipret01 kpret01, title("{bf:Positive parenting practices}") legend(label(1 "5mo") label(2 "17mo") label(3 "29mo") label(4 "3.5y") label(5 "4y") label(6 "5y") label(7 "6y") label(8 "8y") label(9 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

foreach var of varlist apret01 bpret01 cpret01 dpret01 epret01 fpret01 gpret01 ipret01 kpret01	{
	label variable `var' "Positive parenting practices"
}

* negative parenting practices
graph box cpret01b dpret01b epret01b fpret01b gpret01b ipret01b kpret01b, title("{bf:Negative parenting practices}") legend(label(1 "29mo") label(2 "3.5y") label(3 "4y") label(4 "5y") label(5 "6y") label(6 "8y") label(7 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

foreach var of varlist cpret01b dpret01b epret01b fpret01b gpret01b ipret01b kpret01b	{
	label variable `var' "Negative parenting practices"
}

* consequent parenting practices
graph box cpret01c dpret01c epret01c fpret01c gpret01c ipret01c kpret01c, title("{bf:Consequent parenting practices}") legend(label(1 "29mo") label(2 "3.5y") label(3 "4y") label(4 "5y") label(5 "6y") label(6 "8y") label(7 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

foreach var of varlist cpret01c dpret01c epret01c fpret01c gpret01c ipret01c kpret01c	{
	label variable `var' "Consequent parenting practices"
}

* to make proper comparisons of positive, negative, and consequent parenting practices, needed to drop two first waves of positive parenting practices (lack of information on negative & consequent parenting practices and are too rightly skeewed compared to other waves)
drop apret01 bpret01

rename *pret01 o_*_posparent
rename *pret01b o_*_negparent
rename *pret01c o_*_consparent

**# The mean of parenting variables - need to be re-defined as passive variables after imputation!
egen p_positiveparenting = rowmean(o_*_posparent)
egen p_coerciveparenting = rowmean(o_*_negparent)
egen p_consequentparenting = rowmean(o_*_consparent)
label variable p_positiveparenting "Positive parenting practices, mean (SD)"
label variable p_coerciveparenting "Coercive parenting practices, mean (SD)"
label variable p_consequentparenting "Consequent parenting practices, mean (SD)"

* parental monitoring (age 10): cleaning, reversing, standardizing scores to produce a single standardized summary measure (0-10 scale)
tab1 kpreq*
replace kpreq28b = . if kpreq28b < 0 | kpreq28b == 6
replace kpreq28b = -(kpreq28b - 6)
replace kpreq28b = (kpreq28b - 1)/4
replace kpreq33a = . if kpreq33a < 0
replace kpreq33a = (kpreq33a - 1)/3
replace kpreq33b = . if kpreq33b < 0
replace kpreq33b = -(kpreq33b - 5)
replace kpreq33b = (kpreq33b - 1)/3
replace kpreq33c = . if kpreq33c < 0
replace kpreq33c = -(kpreq33c - 5)
replace kpreq33c = (kpreq33c - 1)/3
replace kpreq33d = . if kpreq33d < 0
replace kpreq33d = -(kpreq33d - 5)
replace kpreq33d = (kpreq33d - 1)/3
tab1 kpreq*
egen o_parentalmonitoring = rowmean(kpreq*)
replace o_parentalmonitoring = o_parentalmonitoring * 10
label variable o_parentalmonitoring "Parental monitoring at age 10, mean (SD)"

* family functioning
graph box afnft01 bfnft01 gfnft01, title("{bf:Family dysfunction}") legend(label(1 "5mo") label(2 "17mo") label(3 "6y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))
foreach var of varlist afnft01 bfnft01 gfnft01	{
	label variable `var' "Family functioning"
}
rename *fnft01 o_*_famfunc

**# The mean of family functioning - need to be re-defined as passive variable after imptuation!
egen p_familyfunction = rowmean(o_*_famfunc)
label variable p_familyfunction "Family dysfunction, mean (SD)"

* neighborhood conflict
graph box asffl01a csffl01a esffl01a gsffl01a isffl01a ksffl01a, title("{bf:Neighborhood conflict}") legend(label(1 "5mo") label(2 "29mo") label(3 "4y") label(4 "6y") label(5 "8y") label(6 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))
foreach var of varlist asffl01a csffl01a esffl01a gsffl01a isffl01a ksffl01a	{
	label variable `var' "Neighborhood conflict"
}
rename *sffl01a o_*_neigh

**# The mean of neighborhood conflict - need to be re-defined as passive variable after imptuation!
egen p_neighborhoodconflict = rowmean(o_*_neigh)
label variable p_neighborhoodconflict "Neighborhood conflict, mean (SD)"

* SES
graph box ainfd09 binfd09 cinfd09 dinfd09 finfd09 ginfd09 hinfd09 iinfd09 kinfd09, title("{bf:Socioeconomic status}") legend(label(1 "5mo") label(2 "17mo") label(3 "29mo") label(4 "3.5y") label(5 "5y") label(6 "6y") label(7 "7y") label(8 "8y") label(9 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))
pwcorr ainfd09 binfd09 cinfd09 dinfd09 finfd09 ginfd09 hinfd09 iinfd09 kinfd09

preserve
local i 1
foreach var of varlist ainfd09 binfd09 cinfd09 dinfd09 finfd09 ginfd09 hinfd09 iinfd09 kinfd09	{
	rename `var' ses`i'
	local `++i'
}
reshape long ses, i(noindiv) j(t)
mixed ses || noindiv:, 
estat icc
restore

**# the variable SES has a high ICC - it almost doesn't vary over time - therefore it seems plausible to use the mean of the different waves to deal, in principle, with missing data
egen ses = rowmean(ainfd09 binfd09 cinfd09 dinfd09 finfd09 ginfd09 hinfd09 iinfd09 kinfd09)
hist ses
label variable ses "Family socioeconomic status, mean (SD)"
drop ainfd09 binfd09 cinfd09 dinfd09 finfd09 ginfd09 hinfd09 iinfd09 kinfd09

* MEAN IMPUTATION OF SES for 3 cases with missing data
sum ses, meanonly
replace ses = r(mean) if ses == .

**# logical and temporary consistency checks for variables on susbtance use are performed as per the following rationale:
/*
1. build a contigency table for "past" againt "current" wave
2. look for past/current inconsistencies in missing values and current "never" categories. e.g: 1st wave "always smoked", 2nd wave "never smoked (lifetime)"
3. correct inconsistencies and iterate the process with the rest of the waves
*/

* tobacco use children - lifetime
foreach var of varlist mhdnq1 nhdnq1 phdnq1 rhdnq1	{
	replace `var' = . if `var' < 1
	replace `var' = -(`var' - 2)
}
tab1 mhdnq1 nhdnq1 phdnq1 rhdnq1, m
* consistency check
foreach var of varlist nhdnq1 phdnq1 rhdnq1	{
	replace `var' = 1 if `var' == 0 & mhdnq1 == 1
	replace `var' = 1 if `var' == . & mhdnq1 == 1	
}
foreach var of varlist phdnq1 rhdnq1	{
	replace `var' = 1 if `var' == 0 & nhdnq1 == 1
	replace `var' = 1 if `var' == . & nhdnq1 == 1	
}
foreach var of varlist rhdnq1	{
	replace `var' = 1 if `var' == 0 & phdnq1 == 1
	replace `var' = 1 if `var' == . & phdnq1 == 1	
}
* labels
foreach var of varlist mhdnq1 nhdnq1 phdnq1 rhdnq1	{
	label variable `var' "Lifetime tobacco use"
	label values `var' yes1no0
}
tab1 mhdnq1 nhdnq1 phdnq1 rhdnq1, m

* tobacco use children - 30 days
label define tobaccochild 0 "Didn't use" 1 "Once or twice" 2 "Few days" 3 "Almost every day" 4 "Every day"
foreach var of varlist mhdnq4 nhdnq4 phdnq4 rhdnq4 {
	replace `var' = . if `var' < 1
	replace `var' = 6 if `var' == 1
	replace `var' = -(`var' - 2) + 4
	label variable `var' "Frequency of tobacco use (past 30 days)"
	label values `var' tobaccochild
}
* Multiple consistency checks
* By survey design ALL answered past 30 days tobacco use (Q4), therefore, I will apply a "backward" check: I use Q4 to clean Q1 (lifetime tobacco use)
foreach var in mhdnq nhdnq phdnq rhdnq	{
	replace `var'1 = 1 if `var'4 > 0 & `var'4 != .
}
* Re-applying lifetime tobacco consistency check
foreach var of varlist nhdnq1 phdnq1 rhdnq1	{
	replace `var' = 1 if `var' == 0 & mhdnq1 == 1
	replace `var' = 1 if `var' == . & mhdnq1 == 1	
}
foreach var of varlist phdnq1 rhdnq1	{
	replace `var' = 1 if `var' == 0 & nhdnq1 == 1
	replace `var' = 1 if `var' == . & nhdnq1 == 1	
}
foreach var of varlist rhdnq1	{
	replace `var' = 1 if `var' == 0 & phdnq1 == 1
	replace `var' = 1 if `var' == . & phdnq1 == 1	
}

**# Only consider the last data point for *hdnq1 = lifetime (adolescence) tobacco use
rename rhdnq1 lifetobaccochild
label variable lifetobaccochild "Lifetime (adolescence) tobacco use"

**# The mean of month tobacco use - need to be re-defined as passive variable after imptuation!
**# In MI: this variable should be conditional on lifetobaccochild!
egen p_monthtobaccochild = rowmean(mhdnq4 nhdnq4 phdnq4 rhdnq4)
label variable p_monthtobaccochild "Tobacco use in the past 30 days, mean (SD)"
* drop unused tobacco variables 
drop *hdnq1
* rename other tobacco variables
rename *hdnq4 o_*_30d_tob_child

* alcohol use children - lifetime
foreach var of varlist mhdnq6 nhdnq6 phdnq6 rhdnq6	{
	replace `var' = . if `var' < 1
	replace `var' = -(`var' - 2)
}
tab1 mhdnq6 nhdnq6 phdnq6 rhdnq6, m
* consistency check
foreach var of varlist nhdnq6 phdnq6 rhdnq6	{
	replace `var' = 1 if `var' == 0 & mhdnq6 == 1
	replace `var' = 1 if `var' == . & mhdnq6 == 1	
}
foreach var of varlist phdnq6 rhdnq6	{
	replace `var' = 1 if `var' == 0 & nhdnq6 == 1
	replace `var' = 1 if `var' == . & nhdnq6 == 1	
}
foreach var of varlist rhdnq6	{
	replace `var' = 1 if `var' == 0 & phdnq6 == 1
	replace `var' = 1 if `var' == . & phdnq6 == 1	
}
* labels
foreach var of varlist mhdnq6 nhdnq6 phdnq6 rhdnq6	{
	label variable `var' "Lifetime alcohol use"
	label values `var' yes1no0
}
tab1 mhdnq6 nhdnq6 phdnq6 rhdnq6, m

* alcohol use children - 12 months
label define alcoholchild 0 "Didn't use" 1 "Just once" 2 "<1/month or ocassionally" 3 "About once a month" 4 "Weekends or 1-2/week" 5 "3+ a week" 6 "Every day"
foreach var of varlist mhdnq7 nhdnq7 phdnq7 rhdnq7	{
	replace `var' = . if `var' < 0
	replace `var' = `var' - 1
	label variable `var' "Frequency of alcohol use (past 12 months)"
	label values `var' alcoholchild
}
tab1 mhdnq7 nhdnq7 phdnq7 rhdnq7, m
* multiple consistency checks
foreach var in mhdnq nhdnq phdnq rhdnq	{
	replace `var'6 = 1 if `var'7 > 0 & `var'7 != .
}
* Re-applying lifetime alcohol consistency check
foreach var of varlist nhdnq6 phdnq6 rhdnq6	{
	replace `var' = 1 if `var' == 0 & mhdnq6 == 1
	replace `var' = 1 if `var' == . & mhdnq6 == 1	
}
foreach var of varlist phdnq6 rhdnq6	{
	replace `var' = 1 if `var' == 0 & nhdnq6 == 1
	replace `var' = 1 if `var' == . & nhdnq6 == 1	
}
foreach var of varlist rhdnq6	{
	replace `var' = 1 if `var' == 0 & phdnq6 == 1
	replace `var' = 1 if `var' == . & phdnq6 == 1	
}
* Adding-up those who never used in their life to the "didn't use" in the past 30 days category
foreach var in mhdnq nhdnq phdnq rhdnq {
	replace `var'7 = 0 if `var'6 == 0
}

**# Only consider the last data point for *hdnq6 = lifetime (adolescence) alcohol use
rename rhdnq6 lifealcoholchild

**# The mean of month tobacco use - need to be re-defined as passive variable after imptuation!
**# For MI: this variable will be conditional on lifealcoholchild
egen p_yearalcoholchild = rowmean(mhdnq7 nhdnq7 phdnq7 rhdnq7)
label variable p_yearalcoholchild "Alcohol use in the past 12 months, mean (SD)"
* drop unused alcohol variables 
drop *hdnq6
* rename other alcohol variables
rename *hdnq7 o_*_12m_oh_child

**# cannabis use children - exposure
**# this variable will be imputed using full information maximum likelihood as per group-based trajectory model

* consistency check
foreach var of varlist nhdnq10a phdnq10a rhdnq10a	{
	replace `var' = 1 if `var' == -4 & mhdnq10a > 1 & mhdnq10a != .
}
foreach var of varlist phdnq10a rhdnq10a	{
	replace `var' = 1 if `var' == -4 & nhdnq10a > 1 & nhdnq10a != .
}
foreach var of varlist rhdnq10a	{
	replace `var' = 1 if `var' == -4 & phdnq10a > 1 & phdnq10a != .
}
label define cann 0 "Didn't use" 1 "Just once" 2 "<1/month or ocassionally" 3 "About once a month" 4 "Weekends or 1-2/week" 5 "3+ a week" 6 "Every day"
foreach var of varlist mhdnq10a nhdnq10a phdnq10a rhdnq10a	{
	replace `var' = 1 if `var' == -4
	replace `var' = . if `var' < 1
	replace `var' = `var' - 1
	label variable `var' "Cannabis use during the past 12 months"
	label values `var' cann
}
rename *hdnq10a *_12m_thc_child
tab1 *_12m_thc_child

* tobacco & drugs pregnant
foreach var of varlist amdeq03 amdeq11a	{
	replace `var' = . if `var' < 1
	replace `var' = 0 if `var' == 2
}
tab1 amdeq03 amdeq11a
label variable amdeq03 "Maternal prenatal tobacco use"
label variable amdeq11a "Maternal prenatal drug use"
label values amdeq03 amdeq11a yes1no0
rename amdeq03 tobaccopregnant
rename amdeq11a drugpregnant

* alcohol pregnant
replace amdeq06 = . if amdeq06 < 1
replace amdeq06 = amdeq06 - 1
tab1 amdeq06
label variable amdeq06 "Maternal prenatal alcohol use, mean (SD)"
label define alcoholpregnant 0 "never" 1 "<1 time/month" 2 "1-3 times/month" 3 "1 time/week" 4 "2-3 times/week" 5 "4-6 times/week" 6 "everyday"
label values amdeq06 alcoholpregnant
rename amdeq06 alcoholpregnant
tab alcoholpregnant

* tobacco use moms
foreach var of varlist ahlmq02 bhlmq02 chlmq02 dhlmq02	{
	replace `var' = . if `var' < 1
	replace `var' = -(`var' - 3)
	label variable `var' "Maternal tobacco use"
}
tab1 ahlmq02 bhlmq02 chlmq02 dhlmq02
label define tobacco_freq 0 "Not really" 1 "Used occasionally" 2 "Used everyday"
label values ahlmq02 bhlmq02 chlmq02 dhlmq02 tobacco_freq
**# The mean of tobacco use - need to be re-defined as passive variable after imptuation!
egen p_tobaccomom = rowmean(ahlmq02 bhlmq02 chlmq02 dhlmq02)
label variable p_tobaccomom "Maternal tobacco use, mean (SD)"
* Renaming variables for maternal tobacco use
rename *hlmq02 o_*_tob_mom

* alcohol use moms - 12 months
foreach var in ahlmq0 bhlmq0 chlmq0	{
	replace `var'5 = . if `var'5 < 1
	replace `var'5 = 8 if `var'4 == 2
	replace `var'5 = -(`var'5 - 8)
	label variable `var'5 "Maternal alcohol use"
}
replace dhlmq05 = . if dhlmq05 < 1
replace dhlmq05 = -(dhlmq05 - 8)
drop *hlmq04
tab1 ahlmq05 bhlmq05 chlmq05 dhlmq05
label define alcohol 0 "have not used" 1 "<1 time/month" 2 "once a month" 3 "2-3 time/week" 4 "once a week" 5 "2-3 times/week" 6 "4-6 times/week" 7 "everyday"
label values ahlmq05 bhlmq05 chlmq05 dhlmq05 alcohol
**# The mean of past year alcohol use - need to be re-defined as passive variable after imptuation!
egen p_alcoholmom = rowmean(ahlmq05 bhlmq05 chlmq05 dhlmq05)
label variable p_alcoholmom "Maternal alcohol use, mean (SD)"
* Rename variables for maternal alcohol use
rename *hlmq05 o_*_oh_mom

* drug use moms
foreach var of varlist ahlmq07a bhlmq07a chlmq07a dhlmq07a	{
	replace `var' = . if `var' < 1
	replace `var' = -(`var' - 2)
	label variable `var' "Maternal drug use"
}
tab1 ahlmq07a bhlmq07a chlmq07a dhlmq07a
label values ahlmq07a bhlmq07a chlmq07a dhlmq07a yes1no0
**# The mean of maternal drug use - need to be re-defined as passive variable after imputation!
egen p_drugmom = rowmean(ahlmq07a bhlmq07a chlmq07a dhlmq07a)
replace p_drugmom = 1 if p_drugmom > 0 & p_drugmom != .
label variable p_drugmom "Maternal drug use"
label values p_drugmom yes1no0
* Rename variables for maternal drug use
rename *hlmq07a o_*_dr_mom

* tobacco use dads
foreach var of varlist ahljq02 bhljq02 chljq02 dhljq02	{
	replace `var' = . if `var' < 1
	replace `var' = -(`var' - 3)
	label variable `var' "Paternal tobacco use"
}
tab1 ahljq02 bhljq02 chljq02 dhljq02
label values ahljq02 bhljq02 chljq02 dhljq02 tobacco_freq
**# The mean of tobacco use - need to be re-defined as passive variable after imptuation!
egen p_tobaccodad = rowmean(ahljq02 bhljq02 chljq02 dhljq02)
label variable p_tobaccodad "Paternal tobacco use, mean (SD)"
* Renaming variables for maternal tobacco use
rename *hljq02 o_*_tob_dad

* alcohol use dads
foreach var in ahljq0 bhljq0 chljq0	{
	replace `var'5 = . if `var'5 < 1
	replace `var'5 = 8 if `var'4 == 2
	replace `var'5 = -(`var'5 - 8)
	label variable `var'5 "Paternal alcohol use"
}
replace dhljq05 = . if dhljq05 < 1
replace dhljq05 = -(dhljq05 - 8)
drop *hljq04
tab1 ahljq05 bhljq05 chljq05 dhljq05
label values ahljq05 bhljq05 chljq05 dhljq05 alcohol
**# The mean of past year alcohol use - need to be re-defined as passive variable after imptuation!
egen p_alcoholdad = rowmean(ahljq05 bhljq05 chljq05 dhljq05)
label variable p_alcoholdad "Paternal alcohol use, mean (SD)"
* Rename variables for maternal alcohol use
rename *hljq05 o_*_oh_dad

* drug use dads
foreach var of varlist ahljq07a bhljq07a chljq07a dhljq07a	{
	replace `var' = . if `var' < 1
	replace `var' = -(`var' - 2)
	label variable `var' "Paternal drug use"
}
tab1 ahljq07a bhljq07a chljq07a dhljq07a
label values ahljq07a bhljq07a chljq07a dhljq07a yes1no0
**# The mean of paternal drug use - need to be re-defined as passive variable after imputation!
egen p_drugdad = rowmean(ahljq07a bhljq07a chljq07a dhljq07a)
replace p_drugdad = 1 if p_drugdad > 0 & p_drugdad != .
label variable p_drugdad "Paternal drug use"
label values p_drugdad yes1no0
* Rename variables for maternal drug use
rename *hljq07a o_*_dr_dad

* Internalizing and externalizing symptoms
graph box gbeet05c hbeet05c ibeet05c kbeet05c, title("{bf:Mood troubles}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

rename *beet05c o_*_int_dep

graph box gbeet05d hbeet05d ibeet05d kbeet05d, title("{bf:Anxiety}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

preserve
local i 1
foreach var of varlist gbeet05d hbeet05d ibeet05d kbeet05d	{
	rename `var' anx`i'
	local `++i'
}
reshape long anx, i(noindiv) j(t)
mixed anx || noindiv:, 
estat icc
restore

rename *beet05d o_*_int_anx

graph box gbeet05f hbeet05f ibeet05f kbeet05f, title("{bf:Physical aggression}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

rename *beet05f o_*_ext_agg

graph box gbeet05h hbeet05h ibeet05h kbeet05h, title("{bf:Opposition}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

preserve
local i 1
foreach var of varlist gbeet05h hbeet05h ibeet05h kbeet05h	{
	rename `var' opp`i'
	local `++i'
}
reshape long opp, i(noindiv) j(t)
mixed opp || noindiv:, 
estat icc
restore

rename *beet05h o_*_ext_opp

graph box gbeet05o hbeet05o ibeet05o kbeet05o, title("{bf:Inattention/hyperactivity}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

rename *beet05o o_*_ext_adh

graph box gbeet05q hbeet05q ibeet05q kbeet05q, title("{bf:Social withdrawal}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

preserve
local i 1
foreach var of varlist gbeet05q hbeet05q ibeet05q kbeet05q	{
	rename `var' sw`i'
	local `++i'
}
reshape long sw, i(noindiv) j(t)
mixed sw || noindiv:, 
estat icc
restore

rename *beet05q o_*_int_with

**# Internalizing and externalizing must be re-defined after MI as passive variables!
egen mood_mean = rowmean(o_*_int_dep)
egen anxiety_mean = rowmean(o_*_int_anx)
egen aggression_mean = rowmean(o_*_ext_agg)
egen opposition_mean = rowmean(o_*_ext_opp)
egen adh_mean = rowmean(o_*_ext_adh)
egen withdrawal_mean = rowmean(o_*_int_with)
egen p_internalizing = rowmean(mood_mean anxiety_mean withdrawal_mean)
egen p_externalizing = rowmean(aggression_mean opposition_mean adh_mean)
drop mood_mean anxiety_mean withdrawal_mean aggression_mean opposition_mean adh_mean
label variable p_internalizing "Internalizing behaviors, mean (SD)"
label variable p_externalizing "Externalizing behaviors, mean (SD)"

* victimization
graph box gqeet01 hqeet01 iqeet01 kqeet01, title("{bf:Victimization}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

rename *qeet01 o_*_victimization

**# Victimization must be re-defined after MI as passive variable!
egen p_victimization = rowmean(o_*_victimization)
label variable p_victimization "Victimization, mean (SD)"

graph box gaeet04 haeet04 iaeet04 kaeet04, title("{bf:Social skills}") legend(label(1 "6y") label(2 "7y") label(3 "8y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))
rename *aeet04 o_*_socsk
**# Social skills must be re-defined after MI as passive variable!
egen social_mean = rowmean(o_*_socsk)
rename social_mean p_socialskills
label variable p_socialskills "Social skills, mean (SD)"

* this line has been commented out as there is some weird error when running the graph:	graph box deves01 feves01 geves01 keves01, title("{bf:Cognitive skills}") legend(label(1 "3.5y") label(2 "5y") label(3 "6y") label(4 "10y") size(vsmall) position(6) rows(1) symysize(vsmall) symxsize(vsmall) title("Survey waves", size(small)) bmargin(zero))

rename *eves01 o_*_cogsk
**# Cognitive skills must be re-defined after MI as passive variable!
foreach var of varlist o_*_cogsk	{
	bysort sex: egen sd_`var' = std(`var'), mean(100) sd(15)
}
egen cognitive_mean = rowmean(sd_*_cogsk)
drop sd_*_cogsk
rename cognitive_mean p_cognitiveskills
label variable p_cognitiveskills "Cognitive skills, mean (SD)"

* academic performance
rename *aeiq04 o_*_performance
**# Academic performance must be re-defined after MI as passive variable!
egen p_academicperformance = rowmean(o_*_performance)
label variable p_academicperformance "Academic performance, mean (SD)"

* deviant behavior
rename kqeet14 o_deviant
sum o_deviant
hist o_deviant
**# deviant behavior must be re-defined after MI as passive variable!
label variable o_deviant "Deviant behavior, mean (SD)"

* depression (child - Kovac's)
rename kqeet10 o_childdepression
sum o_childdepression
hist o_childdepression
**# Children depression must be re-defined after MI as passive variable!
label variable o_childdepression "Children depression (CDI), mean (SD)"

gen aage = 5/12
gen bage = 17/12
gen cage = 29/12
gen dage = 3.5
gen eage = 4
gen fage = 5
gen gage = 6
gen hage = 7
gen iage = 8
gen kage = 10
gen mage = 12 // ages to be used for group-based trajectory analyses
gen nage = 13
gen page = 15
gen rage = 17

* ordering variables
order noindiv sex agemom ethn* familytype p_neighborhoodconflict ses p_familyfunction p_positiveparenting p_coerciveparenting p_consequentparenting o_parentalmonitoring tobaccopregnant alcoholpregnant drugpregnant p_tobaccomom p_alcoholmom p_drugmom p_maternaldepression p_tobaccodad p_alcoholdad p_drugdad p_internalizing p_externalizing o_childdepression p_victimization o_deviant p_socialskills p_cognitiveskills p_academicperformance p_monthtobaccochild p_yearalcoholchild lifetobaccochild lifealcoholchild

save ELDEQ_CLEANED, replace