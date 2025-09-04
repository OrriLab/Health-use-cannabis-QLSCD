cd // this line sets the working directory to where this do-file is stored!

**# Selection of outcomes & confounders in medical care use data
use ADMIN_FINAL_DETAILED, clear

* medical care for physical diseases during childhood is nearly universal, thus: hospitalization + ER will be considered
gen any_physical_1_a_sev = cond(any_physical2_hosp_a > 0 | any_physical2_er_a > 0, 1, 0)
label variable any_physical_1_a_sev "Any physical disease (w/Injuries & poisoning) - 1+ HOSP/ER - childhood"

* any mental disorder in childhood (any mental + neurodevelopmental + conduct disorders)
gen any_mental_1_a_all = cond(any_mental_1_a == 1 | neurodevelopmental_1_a == 1 | conduct_emotion_1_a == 1, 1, 0)

* keep selected variables
keep noindiv common_1_c severe_1_c substance_1_c any_mental_1_c adhd_1_ao suicide_attempt_1_c respiratory_1_c asthma_1_c injuries_g_1_c other_physical_1_c any_physical2_1_c any_mental_1_a_all any_physical_1_a_sev

**# merge to ELDEQ
merge 1:1 noindiv using TRAJECTORIES_all

* drop non-matched individuals as they don't have cannabis data
drop if _merge == 1
drop _merge

* save
save ELDEQ+ADMIN, replace

**# Descriptives

* actual ages were subjects were assessed
sum cage13 cage14 cage16 cage18

* cannabis use in the whole sample
tab1 m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child

* weighted descriptives
dtable i.sex p_internalizing c.o_childdepression p_externalizing c.o_deviant p_cognitiveskills c.p_academicperformance p_socialskills c.p_victimization i.any_mental_1_a_all i.any_physical_1_a_sev i.lifetobaccochild i.lifealcoholchild r_12m_thc_child, by(_traj_Group, tests) nformat(%9.1fc mean sd) title(Table 1a. Children characteristics) titlestyle(font(, bold)) export(table1a.docx, replace) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (%): p-value from Pearson test.)

dtable i.agemom i.ethnicitymom i.ethnicitydad i.familytype c.ses c.o_a_neigh c.o_a_famfunc c.p_positiveparenting c.p_coerciveparenting c.p_consequentparenting c.o_parentalmonitoring c.p_maternaldepression i.tobaccopregnant c.alcoholpregnant i.drugpregnant i.o_a_tob_mom c.o_a_oh_mom i.o_a_dr_mom i.o_a_tob_dad c.o_a_oh_dad i.o_a_dr_dad, by(_traj_Group, tests) nformat(%9.1fc mean sd) title(Table 1b. Family characteristics) titlestyle(font(, bold)) export(table1b.docx, replace) note(Mean (Standard deviation): p-value from a pooled t-test.) note(Frequency (%): p-value from Pearson test.)

**# Outcomes selection
dtable i.common_1_c i.severe_1_c i.substance_1_c i.any_mental_1_c i.adhd_1_ao i.suicide_attempt_1_c i.respiratory_1_c i.asthma_1_c i.injuries_g_1_c i.other_physical_1_c i.any_physical2_1_c, by(_traj_Group, tests)
* less than 10 per cell: severe mental disorders, adult-onset ADHD, suicide-related behaviors, asthma

**# Preliminary analyses
**# Checking VIF in predictors of treatment assignment
* When checking VIF on categorical variables (more than 2 levels) use the most frequent level as the reference 
tab agemom, nolabel
global impnameglobdich "i.sex c.p_internalizing c.o_childdepression c.p_externalizing c.o_deviant c.p_cognitiveskills c.p_academicperformance c.p_socialskills c.p_victimization i.any_mental_1_a_all i.any_physical_1_a_sev ib3.agemom i.ethnicitymom i.ethnicitydad i.familytype c.ses c.o_a_neigh c.o_a_famfunc c.p_positiveparenting c.p_coerciveparenting c.p_consequentparenting c.o_parentalmonitoring c.p_maternaldepression i.tobaccopregnant c.alcoholpregnant i.drugpregnant i.o_a_tob_mom c.o_a_oh_mom i.o_a_dr_mom i.o_a_tob_dad c.o_a_oh_dad i.o_a_dr_dad" // I have defined this GLOBAL macro to be able to repeat the command without having to run all the syntax at once; for this reason, I named it with an improbable name for a global...
qui: regress _traj_Group $impnameglobdich
estat vif
* No multicollinearity

**# Unadjusted estimations ## IN THE FULL-SAMPLE (no missing data)
logistic any_mental_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic common_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic substance_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic suicide_attempt_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic any_physical2_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic respiratory_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic injuries_g_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)

logistic other_physical_1_c i._traj_Group [pw=sampling], vce(robust) cformat(%9.2f)
 
**# BALANCE CHECK
* Run my covbalance program, which has some functionalities of the tebalance summarize command within the teffects framework but with extended functions for managing missing data and other balancing weights (trimmed and overlap)
quietly do "Programs\P. covbalance.do" 

covbalance2, treatment(_traj_Group) covariates($impnameglobdich) weights(overlap) balance(asd) savewgt(overlap)
plotbalance, treatments(all) labels("Male sex" "Male sex" "Internalizing behaviors" "Children depression" "Externalizing behaviors" "Deviant behaviors" "Verbal skills" "Academic performance" "Social skills" "Victimization" "Any mental disorder" "Any mental disorder" "Any physical disease" "Any physical disease" "Maternal age 30-34y" "Maternal age <24" "Maternal age 25-29y" "Maternal age 35+" "Canadian-born mother" "Canadian-born mother" "Canadian-born father" "Canadian-born father" "Intact, two parent family" "Step- or single-parent family" "Family SES" "Neighborhood conflict" "Family dysfunction" "Positive parenting" "Coercive parenting" "Consequent parenting" "Parental monitoring" "Maternal depression" "Prenatal tobacco use" "Prenatal tobacco use" "Prenatal alcohol use" "Prenatal drug use" "Prenatal drug use" "Maternal tobacco use: not really" "Maternal tobacco use: occasionally" "Maternal tobacco use: everyday" "Maternal alcohol use" "Maternal drug use" "Maternal drug use" "Paternal tobacco use: not really" "Paternal tobacco use: occasionally" "Paternal tobacco use: everyday" "Paternal alcohol use" "Paternal drug use" "Paternal drug use")
* Perfect balance!
* The weights can be saved for later user

**# Accounting for sample selection
gen newwgt = overlap*sampling

**# Adjusted estimations ## 

logistic any_mental_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic common_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic substance_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic suicide_attempt_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic any_physical2_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic respiratory_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic injuries_g_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)

logistic other_physical_1_c i._traj_Group [pw=newwgt], vce(robust) cformat(%9.2f)