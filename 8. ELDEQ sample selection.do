cd // this line sets the working directory to where this do-file is stored!

**# Sample selection

use ELDEQ_CLEANED, clear

* checking missing data for exposure (cannabis use)
misstable patterns m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child, asis frequency

* tagging non missing observations
egen can_tag = rownonmiss(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child)
gen include = cond(can_tag == 0,0,1,.)

* checking for baseline variables with full information
misstable summarize sex ses agemom ethnicitymom ethnicitydad familytype tobaccopregnant alcoholpregnant drugpregnant, all
misstable summarize o_a_*, all

* ses & sex as a predictors of exclusion (i.e., completely missed exposure data), only baseline variables with full information
* those from higher ses & females were more likely to have complete data for exposure
logistic include ses sex

* estimating inverse probability weights & checking balance to account for sampling differences
predict pr_, pr
gen sampling = include / pr_

* alternative specification (+ agemom, and substance use in mom at baseline) = same results
logistic include ses sex i.agemom i.o_a_tob_mom i.o_a_oh_mom i.o_a_dr_mom

* individuals with no data for cannabis use were dropped
drop if can_tag == 0

save ELDEQ_CLEANED_SAMPLED, replace

