capture program drop summary_table_procTraj
program summary_table_procTraj
    preserve
	** 
	drop if missing(_traj_Group) 
    *now lets look at the average posterior probability
    gen Mp = 0
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    sort _traj_Group
    *and the odds of correct classification
    by _traj_Group: gen countG = _N
    by _traj_Group: egen groupAPP = mean(Mp)
    by _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d
    *Estimated proportion for each group
    scalar c = 0
    gen TotProb = 0
    foreach i of varlist _traj_ProbG* {
       scalar c = c + 1
       quietly summarize `i'
       replace TotProb = r(sum)/ _N if _traj_Group == c 
    }
    *This displays the group number, the count per group, the average posterior probability for each group,
    *the odds of correct classification, and the observed probability of groups versus the probability 
    *based on the posterior probabilities
	gen GROUP_APP = round(groupAPP*100,.1)
	gen OCC = round(occ,.1)
	gen Probab = round(p*100,.1)
	gen Prob_post = round(TotProb*100,.1)
    list _traj_Group countG GROUP_APP OCC Probab Prob_post if counter == 1
    restore
end