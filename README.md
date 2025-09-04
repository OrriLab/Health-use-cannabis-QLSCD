# Health-use-cannabis-QLSCD

Stata syntax (do-files) and programs used in the article:
**Martinez et al. Health service use among young adults with a history of adolescent cannabis use: a population-based birth cohort study**

The file **2. ICD codes v.2.xlsx** serves as a coding dictionary for identifying mental and behavioral disorders across administrative datasets, ensuring consistency between ICD-9 and ICD-10 eras.

In the **Do-files** you will find:
1. RAMQ explore & extract.do – Explores RAMQ health insurance data and extracts variables of interest.
2. MED-ECHO explore & extract.do – Processes hospitalization (MED-ECHO) data and extracts relevant measures.
3. BDCU explore & extract.do – Explores and extracts data from BDCU records (emergency visits).
4. ADMIN DATA merge & define.do – Merges administrative datasets and defines analytic variables.
5. ADMIN DATA exploration.do – Conducts exploratory analyses and consistency checks of merged administrative data.
6. ELDEQ variable selection.do – Selects relevant variables from the ELDEQ dataset for analysis.
7. ELDEQ definition of variables.do – Defines and labels analytic variables within the ELDEQ dataset.
8. ELDEQ sample selection.do – Applies inclusion criteria and constructs the analytic sample from ELDEQ.
9. ELDEQ exposure & trajectories.do – Derives cannabis exposure measures and trajectory groups from ELDEQ data.
10. ELDEQ-ADMIN selection & descriptives.do – Links ELDEQ to administrative data and produces descriptive statistics.
11. MI impute.do – Performs multiple imputation for missing data across analytic variables.

In the **Stata-Programs** folder you will find:
**P. auto\_traj\_initial.do**

Performs group selection for group-based trajectory modeling based on the Bayesian Information Criterion (BIC).

Example usage:
    auto_traj_initial, trajopts("var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) drop(0) obsmar(can_mar) weight(sampling)") groups(5) initpoly(2)

→ Fits models with 1–5 groups, each with quadratic polynomials, and compares them on BIC.

Created by Pablo Martínez

**P. auto\_traj\_final.do**

Performs polynomial selection for trajectory models, also based on BIC.

Example usage:
    auto_traj_final, trajopts("var(m_12m_thc_child n_12m_thc_child p_12m_thc_child r_12m_thc_child) indep(mage-rage) model(zip) drop(0) obsmar(can_mar) weight(sampling)") random(groups(3) polynom(3) maxmod(all))

→ Tests all possible 3-group ZIP models, with polynomial orders ranging from 0 to 3 across classes.

Created by Pablo Martínez

**P. covbalance.do**

Evaluates covariate balance across groups (supports binary or multi-valued treatments, overlap weights and ASD checks).

Example usage:
    covbalance2, treatment(_traj_Group) covariates($impnameglobdich) weights(overlap) balance(asd) savewgt(overlap)

→ Assesses balance of dichotomous covariates across trajectory groups using overlap weights and ASD diagnostics, saving the weights for later analyses.

Created by Pablo Martínez

**P. micheckimputed.do**

Diagnostic program for inspecting multiply imputed datasets by comparing distributions of imputed vs observed values.

Example usage:
    micheckimputed, noncat(o_a_famfunc p_internalizing p_externalizing p_socialskills p_cognitiveskills)
    micheckimputed, cat(ethnicitymom ethnicitydad tobaccopregnant lifetobaccochild lifealcoholchild alcoholpregnant)

→ Produces checks for continuous and categorical imputed variables.

Created by Pablo Martínez

**P. miconverge.do**

Monitors and saves convergence diagnostics for multiple imputation routines.

Example usage:
    miconverge, missvar(o_a_famfunc p_internalizing p_externalizing p_socialskills p_cognitiveskills o_a_tob_mom o_a_oh_mom o_a_dr_mom) tracename(trace)

→ Generates trace plots for convergence of imputed variables.

Originally described in the Stata Manual.

**P. mivif.do**

Calculates multicollinearity diagnostics (variance inflation factors, VIF) in multiply imputed datasets.

Created by **Daniel Klein**

**P. Summary_table_procTraj.do**

Produces summary tables of trajectory models, including group proportions and posterior probabilities.

Created by **Andrew Wheeler**
