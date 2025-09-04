cd // this line sets the working directory to where this do-file is stored!

**# IMPUTATION

**# Preparing dataset for imputation
use ELDEQ+ADMIN, clear

**# Missing imputation with original variables (o_) did not converge, therefore, would have to use compositve, passive variables (p_)
keep noindiv sex p_internalizing o_childdepression p_externalizing o_deviant p_cognitiveskills p_academicperformance p_socialskills p_victimization any_mental_1_a_all any_physical_1_a_sev lifetobaccochild lifealcoholchild r_12m_thc_child agemom ethnicitymom ethnicitydad familytype ses o_a_neigh o_a_famfunc p_positiveparenting p_coerciveparenting p_consequentparenting o_parentalmonitoring p_maternaldepression tobaccopregnant alcoholpregnant drugpregnant o_a_tob_mom o_a_oh_mom o_a_dr_mom o_a_tob_dad o_a_oh_dad o_a_dr_dad common_1_c severe_1_c substance_1_c any_mental_1_c adhd_1_ao suicide_attempt_1_c respiratory_1_c asthma_1_c injuries_g_1_c other_physical_1_c any_physical2_1_c _traj_Group sampling p_monthtobaccochild p_yearalcoholchild

**# Editing values for conditional imputation
replace p_monthtobaccochild = . if lifetobaccochild == .
replace p_yearalcoholchild = . if lifealcoholchild == .

save PRE_IMPUTED, replace

* FIRST STEP: SET MI DATA TO LONG
mi set mlong

* SECOND STEP: DESCRIBE MI DATA, NOT USEFUL YET
mi describe

* THIRD STEP: IDENTIFYING MISSING VALUES
mi misstable summarize, all
mi misstable patterns
mi misstable nested

global missvar "`r(vars)'"
di "$missvar"
// list variables w/missing data in a macro

* FOURTH STEP: REGISTERING THE VARIABLES TO IMPUTE
mi register imputed $missvar

* FIFTH STEP: IMPUTATION PHASE

* pmm - knn, imputation
mi impute chained (pmm, knn(5)) ethnicitymom ethnicitydad familytype tobaccopregnant drugpregnant lifealcoholchild lifetobaccochild o_a_dr_mom o_a_dr_dad alcoholpregnant o_a_tob_mom o_a_oh_mom o_a_tob_dad o_a_oh_dad p_internalizing o_childdepression p_externalizing o_deviant p_cognitiveskills p_academicperformance p_socialskills p_victimization o_a_famfunc o_a_neigh o_parentalmonitoring (pmm, knn(5) conditional(if lifealcoholchild==1) include((_traj_Group*p_yearalcoholchild))) p_yearalcoholchild (pmm, knn(5) conditional(if lifetobaccochild==1) include((_traj_Group*p_monthtobaccochild))) p_monthtobaccochild = i.sex i.agemom ses p_positiveparenting p_coerciveparenting p_consequentparenting p_maternaldepression i.any_mental_1_a_all i.any_physical_1_a_sev i.common_1_c i.severe_1_c i.substance_1_c i.any_mental_1_c i.adhd_1_ao i.suicide_attempt_1_c i.respiratory_1_c i.asthma_1_c i.injuries_g_1_c i.other_physical_1_c i.any_physical2_1_c i._traj_Group sampling, add(20) burnin(30) rseed(1234) savetrace(trace, replace) noisily showcommand 

mi impute chained (pmm, knn(5)) ethnicitymom ethnicitydad familytype tobaccopregnant drugpregnant lifealcoholchild lifetobaccochild o_a_dr_mom o_a_dr_dad alcoholpregnant o_a_tob_mom o_a_oh_mom o_a_tob_dad o_a_oh_dad p_internalizing o_childdepression p_externalizing o_deviant p_cognitiveskills p_academicperformance p_socialskills p_victimization o_a_famfunc o_a_neigh o_parentalmonitoring (pmm, knn(5) conditional(if lifealcoholchild==1) include((_traj_Group*p_yearalcoholchild))) p_yearalcoholchild (pmm, knn(5) conditional(if lifetobaccochild==1) include((_traj_Group*p_monthtobaccochild))) p_monthtobaccochild = i.agemom ses p_positiveparenting p_coerciveparenting p_consequentparenting p_maternaldepression i.any_mental_1_a_all i.any_physical_1_a_sev i.common_1_c i.severe_1_c i.substance_1_c i.any_mental_1_c i.adhd_1_ao i.suicide_attempt_1_c i.respiratory_1_c i.asthma_1_c i.injuries_g_1_c i.other_physical_1_c i.any_physical2_1_c i._traj_Group sampling, add(20) burnin(30) rseed(1234) by(sex) noisily showcommand 

save IMPUTED, replace
     
/*
Note: as the save trace option was not available with the "by" imputation, it is not possible to run this
 Check convergence! w\my miconverge program (missvar = imputed variable; tracename = name of the saved trace)

quietly do "Programs\P. miconverge.do" 

miconverge, missvar(o_a_famfunc p_internalizing p_externalizing p_socialskills p_cognitiveskills o_a_tob_mom o_a_oh_mom o_a_dr_mom) tracename(trace)
miconverge, missvar(ethnicitymom ethnicitydad tobaccopregnant lifetobaccochild lifealcoholchild p_yearalcoholchild o_a_tob_dad o_a_oh_dad o_a_dr_dad) tracename(trace)
miconverge, missvar(o_a_neigh p_monthtobaccochild alcoholpregnant sampling) tracename(trace)
* In general, the burn-in period seems to be adequate...
*/

* Checking imputed values w/micheckimputed, a program I made to compared observed to imputed values

quietly do "Programs\P. micheckimputed.do" 

micheckimputed, noncat(o_a_famfunc p_internalizing p_externalizing p_socialskills p_cognitiveskills)
micheckimputed, noncat( p_yearalcoholchild p_monthtobaccochild)
micheckimputed, cat(ethnicitymom ethnicitydad tobaccopregnant lifetobaccochild lifealcoholchild alcoholpregnant o_a_tob_mom o_a_dr_mom o_a_tob_dad o_a_dr_dad)
micheckimputed, cat(o_a_oh_dad o_a_oh_mom)
* In general, observed to imputed comparisons look acceptable...

* SIXTH STEP: VERIFYING ALL MISSING VALUES HAVE BEEN FILLED
mi describe, detail 

* SEVENTH STEP: RUNNING THE ANALYSES
use IMPUTED, clear

**# Checking VIF in predictors of treatment assignment
* First, use Daniel Klein's mivif program to check VIF within the MI framework; need to convert data to flong to use this...
quietly do "Programs\P. mivif.do" 
mi convert flong, clear

* When checking VIF on categorical variables (more than 2 levels) use the most frequent level as the reference 
global impnameglobdich "i.sex c.p_internalizing c.o_childdepression c.p_externalizing c.o_deviant c.p_cognitiveskills c.p_academicperformance c.p_socialskills c.p_victimization i.any_mental_1_a_all i.any_physical_1_a_sev ib3.agemom i.ethnicitymom i.ethnicitydad i.familytype c.ses c.o_a_neigh c.o_a_famfunc c.p_positiveparenting c.p_coerciveparenting c.p_consequentparenting c.o_parentalmonitoring c.p_maternaldepression i.tobaccopregnant c.alcoholpregnant i.drugpregnant i.o_a_tob_mom c.o_a_oh_mom i.o_a_dr_mom i.o_a_tob_dad c.o_a_oh_dad i.o_a_dr_dad" // I have defined this GLOBAL macro to be able to repeat the command without having to run all the syntax at once; for this reason, I named it with an improbable name for a global...
qui: mi estimate: regress _traj_Group $impnameglobdich
mivif
* No multicollinearity

**# Adjusted estimation
**# 1ST, BALANCE CHECK
* Run my covbalance program, which has some functionalities of the tebalance summarize command within the teffects framework but with extended functions for managing missing data and other balancing weights (trimmed and overlap)
quietly do "Programs\P. covbalance.do" 

mi convert flong, clear

covbalance2, treatment(_traj_Group) covariates($impnameglobdich) weights(overlap) balance(asd) savewgt(overlap)
plotbalance, treatments(all) labels("Male sex" "Male sex" "Internalizing behaviors" "Children depression" "Externalizing behaviors" "Deviant behaviors" "Verbal skills" "Academic performance" "Social skills" "Victimization" "Any mental disorder" "Any mental disorder" "Any physical disease" "Any physical disease" "Maternal age 30-34y" "Maternal age <24" "Maternal age 25-29y" "Maternal age 35+" "Canadian-born mother" "Canadian-born mother" "Canadian-born father" "Canadian-born father" "Intact, two parent family" "Step- or single-parent family" "Family SES" "Neighborhood conflict" "Family dysfunction" "Positive parenting" "Coercive parenting" "Consequent parenting" "Parental monitoring" "Maternal depression" "Prenatal tobacco use" "Prenatal tobacco use" "Prenatal alcohol use" "Prenatal drug use" "Prenatal drug use" "Maternal tobacco use: not really" "Maternal tobacco use: occasionally" "Maternal tobacco use: everyday" "Maternal alcohol use" "Maternal drug use" "Maternal drug use" "Paternal tobacco use: not really" "Paternal tobacco use: occasionally" "Paternal tobacco use: everyday" "Paternal alcohol use" "Paternal drug use" "Paternal drug use")
* Overlap weights were saved and will be used later...
* Perfect balance...

save IMPUTED+OVERLAP, replace


**# Unadjusted estimations

use IMPUTED+OVERLAP, clear 

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic common_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic substance_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic suicide_attempt_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic respiratory_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic injuries_g_1_c i._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic other_physical_1_c i._traj_Group [pw=sampling], vce(robust)


**# Adjusted estimations: overlap weights

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic common_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic substance_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic suicide_attempt_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic respiratory_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic injuries_g_1_c i._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic other_physical_1_c i._traj_Group [pw=sampling * overlap], vce(robust)


**# Sex interaction

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group##i.sex [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group##i.sex [pw=sampling * overlap], vce(robust) 

**# Sex stratified

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group [pw=sampling * overlap] if sex==1, vce(robust)

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group [pw=sampling * overlap] if sex==2, vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group if sex==1 [pw=sampling * overlap], vce(robust) 

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group if sex==2 [pw=sampling * overlap], vce(robust) 


**# Trajectory by tobacco\alcohol use interactions (test effect modification hypothesis)

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group##c.p_monthtobaccochild [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group##c.p_monthtobaccochild [pw=sampling * overlap], vce(robust) 

mi estimate, or cformat(%9.2f): logistic any_mental_1_c i._traj_Group##c.p_yearalcoholchild [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c i._traj_Group##c.p_yearalcoholchild [pw=sampling * overlap], vce(robust)


**# Late users as the base category for a direct comparison between early vs late users

* Unadjusted
mi estimate, or cformat(%9.2f): logistic any_mental_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic common_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic substance_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic suicide_attempt_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic respiratory_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic injuries_g_1_c ib2._traj_Group [pw=sampling], vce(robust)

mi estimate, or cformat(%9.2f): logistic other_physical_1_c ib2._traj_Group [pw=sampling], vce(robust)

* Adjusted
mi estimate, or cformat(%9.2f): logistic any_mental_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic common_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic substance_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic suicide_attempt_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic any_physical2_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic respiratory_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic injuries_g_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)

mi estimate, or cformat(%9.2f): logistic other_physical_1_c ib2._traj_Group [pw=sampling * overlap], vce(robust)
