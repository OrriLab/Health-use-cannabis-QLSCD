cd // this line sets the working directory to where this do-file is stored!

set more off  // to avoid using the "more" and "break" button

use ELDEQ_CLEANED_SAMPLED, clear

* Check out data points
preserve
rename m_12m_thc_child cann12
rename n_12m_thc_child cann13
rename p_12m_thc_child cann15
rename r_12m_thc_child cann17
reshape long cann, i(noindiv) j(t)
graph twoway scatter cann t, c(L) msize(tiny) mcolor(gray) lwidth(vthin) lcolor(gray)
restore

* loss to follow-up was classified as mar (as per GBTM procedure) according to the following rules : 1) completers; & 2) intermitent attrition; thus, obsmar option can be specified in traj
gen can_mar = cond((can_tag == 3 & r_12m_thc_child == .) | (can_tag < 3),0,1,.)

* identifying baseline variables associated to missigness
misstable summarize sex agemom ethnicitymom ethnicitydad familytype tobaccopregnant alcoholpregnant drugpregnant o_a_tob_mom o_a_oh_mom o_a_dr_mom o_a_tob_dad o_a_oh_dad o_a_dr_dad ses o_a_famfunc o_a_neigh, all

* looking for independent predictors of missigness in fully-observed covariates
sw, pr(.05): logistic can_mar sex i.agemom ses [pw = sampling]
* male sex & lower socioeconomic status were associated to missigness (i.e., non-MAR)

* Using auto_traj programs to select the number of groups (1st) and the order of polynomials (2nd)

quietly do "Programs\P. auto_traj_initial.do" 

auto_traj_initial, trajopts("var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) drop(0) obsmar(can_mar) weight(sampling)") groups(5) initpoly(2)

/*
 
            BIC-based group selection

    ------------------------------------------
     N Groups  BIC subj.   P(corr.)  Group ~5% 
    ------------------------------------------
            3  -4523.489   .9999996          1 
            4  -4538.232   3.95e-07          1 
            5   -4552.89   1.70e-13          1 
            2  -4655.116   6.84e-58          1 
            1   -5829.76          0          1 
    ------------------------------------------
    Notes.
    BIC subj. = Sample size-based BIC.
    P (corr.) = Probability correct model.
    Group n > 5% = 0 if at least 1 group with less than 5% of subjects assigned; otherwise, 1.
    Warning messages may appear if iterations had convergence issues.

*/

quietly do "Programs\P. auto_traj_final.do" 

auto_traj_final, trajopts("var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) drop(0) obsmar(can_mar) weight(sampling)") random(groups(3) polynom(3) maxmod(all))

/*
        BIC-based polynomial selection

    ---------------------------------------------------------------------------
     N Groups  BIC subj.   P(corr.)  Group ~5%        p_1        p_2        p_3 
    ---------------------------------------------------------------------------
            3  -4511.717   .7861195          1          0          3          2 
            3  -4514.188   .0664211          1          2          0          2 
            3  -4514.188    .066421          1          0          2          2 
            3  -4514.568   .0454285          1          2          0          3 
            3  -4515.403   .0197085          1          3          0          3 
            3  -4516.995   .0040086          1          0          1          3 
            3  -4516.996   .0040082          1          1          0          3 
            3  -4517.752    .001881          1          1          2          2 
            3  -4518.254   .0011384          1          2          1          3 
            3  -4518.254   .0011383          1          1          2          3 
    ---------------------------------------------------------------------------
    Notes.
    BIC subj. = Sample size-based BIC.
    P (corr.) = Probability correct model.
    Group n > 5% = 0 if at least 1 group with less than 5% of subjects assigned; otherwise, 1.
    p_n = polynomial order for group n.
    64 models have been tested.
    Warning messages may appear if iterations had convergence issues.

*/

* Checking models fited by auto_traj_final for fit statistics and feasibility
quietly do "Programs\P. summary_table_procTraj.do" 

traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(0 3 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) detail // model did not converge, other model is needed
trajplot, xtitle("Age") ytitle("Frequency of cannabis use") ci nolegend
summary_table_procTraj

traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(2 0 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) detail // model converged, but variance matrix nonsymmmetric or highly singular other model is needed
trajplot, xtitle("Age") ytitle("Frequency of cannabis use") ci nolegend // unfeasible trajectories
summary_table_procTraj

traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(0 2 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) detail // model converged, but variance matrix nonsymmmetric or highly singular other model is needed
trajplot, xtitle("Age") ytitle("Frequency of cannabis use") ci nolegend // unfeasible trajectories
summary_table_procTraj

traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(0 1 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) detail // converged, not any issue
trajplot, xtitle("Age") ytitle("Frequency of cannabis use") ci nolegend
summary_table_procTraj
* this might be the best model. Let's check the next one.

* A loop to test convergence of different random starting values with the best model order(0 1 2)
set seed 123
mat R = J(100,7,.)
traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(0 1 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) detail
mat sv = e(b)
forvalues i = 1/100 {
	quietly {
		trajstart, start(sv) sigma(.005) risk
		mat A = r(trajstart)
		mat list A, format(%8.3f)
		traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(0 1 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) start(A) detail
		matrix R[`i',1] = round(e(ll),.2)
		mat F = e(b)
		matrix R[`i',2] = round(F[1,1],.2)
		matrix R[`i',3] = round(F[1,2],.2)
		matrix R[`i',4] = round(F[1,3],.2)
		matrix R[`i',5] = round(F[1,4],.2)
		matrix R[`i',6] = round(F[1,5],.2)
		matrix R[`i',7] = round(F[1,6],.2)
	}
	local `++i'
}
preserve
drop noindiv-_traj_ProbG3
svmat R
mat X = J(1,7,.)
forvalues j = 1/7	{
	egen mR`j' = mode(R`j')
	count if R`j' == mR`j'
	mat X[1,`j'] = r(N)
}
mat coln X = ll p1 p2 p3 p4 p5 p6
mat list X
restore

* final model, again
traj, var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) order(0 1 2) drop(0 0 0) obsmar(can_mar) risk(sex ses) weight(sampling) detail // what if we remove an order to the second group?
matrix plot = e(plot1)
trajplot, xtitle("Age") ytitle("Frequency of cannabis use") ci
summary_table_procTraj

* labeling trajectory groups
label variable _traj_Group "Trajectories of cannabis use during adolescence"
label define traj 1 "Non-users" 2 "Late-onset users" 3 "Early-onset & frequent users"
label values _traj_Group traj

label variable _traj_ProbG1 "Predicted probability of 'never using cannabis'"
label variable _traj_ProbG2 "Predicted probability of 'using cannabis later'"
label variable _traj_ProbG3 "Predicted probability of 'using cannabis earlier'"

save TRAJECTORIES_all, replace

/* Creating a combined graph for trajectories
use TRAJECTORIES_all, clear

clear

svmat plot, names(col)

reshape long Avg Est L95 U95 Dropout, i(trajT) j(group)

rename trajT t

graph twoway scatter Avg t, by(group, xrescale legend(off) note(" ")) msize(medsmall) mcolor(midblue) xtitle("Age") ytitle("Frequency of cannabis use") || scatter Est t, c(L) msize(tiny) mcolor(black) lcolor(black) lwidth(med) || scatter L95 t, c(L) || scatter U95 t, c(L)
*/

* Creating a combined graph for trajectories
use TRAJECTORIES_all, clear

mean r_12m_thc_child, over(_traj_Group)

bysort _traj_Group: egen m_mean = mean(m_12m_thc_child)
bysort _traj_Group: egen n_mean = mean(n_12m_thc_child)
bysort _traj_Group: egen p_mean = mean(p_12m_thc_child)
bysort _traj_Group: egen r_mean = mean(r_12m_thc_child)

*preserve
rename m_12m_thc_child cann12
rename n_12m_thc_child cann13
rename p_12m_thc_child cann15
rename r_12m_thc_child cann17
rename m_mean mean12
rename n_mean mean13
rename p_mean mean15
rename r_mean mean17
reshape long cann mean, i(noindiv) j(t)
gen Est = exp(-6.54273) if _traj_Group == 1
replace Est = exp(-21.77370 + 1.31592 * t) if _traj_Group == 2
replace Est = exp(-64.80775 + 8.20355 * t + -0.25431 * t ^2) if _traj_Group == 3
gen U95 = .0049447 if _traj_Group == 1
replace U95 = .0064901 if _traj_Group == 2 & t == 12
replace U95 = .0212389 if _traj_Group == 2 & t == 13
replace U95 = .2135692 if _traj_Group == 2 & t == 15
replace U95 = 2.063193 if _traj_Group == 2 & t == 17
replace U95 = .0800915 if _traj_Group == 3 & t == 12
replace U95 = .4352965 if _traj_Group == 3 & t == 13
replace U95 = 3.128904 if _traj_Group == 3 & t == 15
replace U95 = 3.500793 if _traj_Group == 3 & t == 17
gen L95 = 0 if _traj_Group == 1
replace L95 = 0 if _traj_Group == 2 & t < 15
replace L95 = .0478025 if _traj_Group == 2 & t == 15
replace L95 = 1.569667 if _traj_Group == 2 & t == 17
replace L95 = .020915 if _traj_Group == 3 & t == 12
replace L95 = .204405 if _traj_Group == 3 & t == 13
replace L95 = 2.450178 if _traj_Group == 3 & t == 15
replace L95 = 2.861133 if _traj_Group == 3 & t == 17

graph twoway scatter cann t, by(_traj_Group, xrescale legend(off) note("")) c(L) msize(vtiny) mcolor(navy%35) lpattern(shortdash) lwidth(vthin) lcolor(navy%10) jitter(2) xtitle("Age") ytitle("Frequency of cannabis use") || scatter mean t, mcolor(dark) msize(medthick) || line Est t, c(L) lcolor(orange_red) lwidth(medthick) || line U95 t, c(L) lcolor(orange_red%50) lwidth(thin) lpattern(shortdash) || line L95 t, c(L) lcolor(orange_red%50) lwidth(thin) lpattern(shortdash)

graph export Figure1.png, as(png) replace