capture program drop covbalance2
program covbalance2, eclass
	version 15.1
	syntax , treatment(varname) covariates(varlist fv) weights(string) balance(string) [control(integer 1) savewgt(string) threshold(real 0) sampling(varname)]
	
	* error checks
	
	** for `treatment'
	quietly levelsof `treatment', local(all_levels)
	local values `r(r)'
	if `values' == 2	{
		capture numlist "`all_levels'", range(>=0 <=1)
		if _rc != 0	{
			display as error "levels of dichotomous treatment variable must be 0 (control) or 1 (treated)"
			exit 198
		}
	}
	if `values' > 2	{
		numlist "1(1)`values'"
		local testorder "`r(numlist)'"
		if "`: list local all_levels - testorder'" != ""	{
			display as error "levels of multivalued treatment variable must have consecutive positive integer values starting from 1"
			exit 198
		}
	}
		
	** for `covariates'
	foreach var in varlist `varlist'	{
		if strpos("`treatment'","`var'") != 0	{
			display as error "the same variable must not be in different categories"
			exit 198		
		}
	}
	
	** for `weights'
	if "`weights'" != "inverse" & "`weights'" != "trimming" & "`weights'" != "overlap"	{
		display as error "option {bf:weights} must be {bf:inverse} OR {bf:trimming} OR {bf:overlap}"
		exit 198
	}
	
	** for `balance'
	if `values' == 2	{
		if "`balance'" != "asd"	{
			display as error "for dichotomous treatment {bf:asd} is the only valid option available for {bf:balance} check"
			exit 198
		}
	}
	if `values' > 2	{
		if "`balance'" != "asd" & "`balance'" != "psd"	{
			display as error "{bf:balance} check must be {bf:asd} or {bf:psd}"
			exit 198
		}
	}
	
	** for `control'
	if "`control'" != ""	{
		if strpos("`all_levels'","`control'") == 0	{
			display as error "level of treatment variable defined as control misspecified"
			exit 198
		}
	}
	if `values' == 2 & `control' != 0	{
		display as error "check the {bf:control} option to declare control level of dichotomous treatment variable as 0"
		exit 198
	}

	* for `threshold'
	if "`weights'" != "trimming" & `threshold' != 0	{
		display as error "{bf:threshold} option only available when {bf:trimming} is specified"
		exit 198
	}
	if "`weights'" == "trimming"	{
		capture numlist `threshold', range(>=`=10^-5' <=`=1/`values'')
		if _rc != 0	{
			display as error "{bf:threshold} option not specified or incorrectly specified (invalid range)"
			exit 198
		}
	}
	
	* for `sampling'
	if "`sampling'" != ""	{
		quietly inspect `sampling'
		if `r(N_neg)' > 0	{
			display as error "`sampw' cannot have negative values"
			exit 402
		}
	}
	
	* if sampling specified, add as a covariate
	if "`sampling'" != ""	{
		local covariates "`covariates' `sampling'"
	}
		
	* managing factor variables
	fvrevar `covariates'
	local covlist `r(varlist)'
	local rowcount : word count `covlist'
	fvexpand `covariates'
	local covnames `r(varlist)'
	
	* defining the estimation method as per the levels of the treatment variable
	tempfile estimations
	if `values' == 2	{
		local estimator "logit `treatment' `covariates'"
		local treatment_levels : subinstr local all_levels "0" ""
	}
	if `values' > 2	{
		local estimator "mlogit `treatment' `covariates'"
		local treatment_levels : subinstr local all_levels "`control'" ""
		if strpos("`0'","control(") == 0	{
			display as text " {break}level {bf:{ul:1}} of treatment variable defined as control"
		}
	}
	
	* defining the matrix to store final results
	tempname results
	matrix `results' = J(`=`=`values'-1'*`rowcount'',2,.)
	matrix colnames `results' = "Raw" "Weighted"
	if "`balance'" == "asd"	{
		matrix coleq `results' = "ASD" "ASD"
	}
	if "`balance'" == "psd"	{
		matrix coleq `results' = "PSD" "PSD"
	}
	foreach i in `treatment_levels'	{
		foreach j in `covnames'	{
			local rownames "`rownames' `j'"
			local roweq "`roweq' "`: label (`treatment') `i''""
		}
	}
	matrix rownames `results' = `rownames'
	matrix roweq `results' = `roweq'
	
	quietly	{
	
	* setting the estimation sample
	tempvar sample
	`estimator'
	generate `sample' = e(sample)

	* checking if estimations need to be conducted within the MI framework
	mi query
	
	* defining some temporary names and variable for later use
	tempname ql qh
	tempvar pr_ wgt osum
	
	* estimation for non-imputed datasets
	if "`r(style)'" == ""	{
		
		* estimating raw absolute & population standardized differences
		local j 1
		foreach i in `treatment_levels'	{
			foreach var of varlist `covlist'	{
				if "`balance'" == "asd"	{
					summarize `var' if `sample' == 1 & `treatment' == `control'
					local Mean_c = r(mean)
					local Var_c = r(Var)
					summarize `var' if `sample' == 1 & `treatment' == `i'
					local Mean_e = r(mean)
					local Var_e = r(Var)
					matrix `results'[`j',1] = abs(`Mean_e'-`Mean_c')/sqrt((`Var_e'+`Var_c')/2)
				}
				if "`balance'" == "psd"	{
					summarize `var' if `sample' == 1 & `treatment' == `i'
					local Mean_e = r(mean)
					summarize `var' if `sample' == 1
					local Mean0 = r(mean)
					local VarP = 0
					foreach level of local all_levels	{
						summarize `var' if `sample' == 1 & `treatment' == `level'
						local VarP = r(Var) + `VarP'
					}
					local Var_p = `Var_p'/`values'
					matrix `results'[`j',1] = abs(`Mean_e'-`Mean0')/sqrt(`VarP')
				}
				local `++j'
			}
		}
		
		`estimator' if `sample' == 1

		* estimating inverse probability weights
		if "`weights'" == "inverse"	{
			if `values' == 2	{
				predict `pr_' if `sample' == 1, pr
				generate `wgt' = 1/`pr_' if `treatment' != `control'
				replace `wgt' = 1/(1-`pr_') if `treatment' == `control'
			}
			if `values' > 2	{
				foreach i in `all_levels'	{
					predict `pr_'`i' if `sample' == 1, pr outcome(#`i')
					if `i' == 1	{
						generate `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
					else	{
						replace `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
				}
			}
		}
		
		* estimating trimming weights		
		if "`weights'" == "trimming"	{
			if `values' == 2	{
				predict `pr_' if `sample' == 1, pr
				count if `pr_' > (1 - `threshold')
				local changed `r(N)'
				count if `pr_' < `threshold'
				local changed `=`changed'+`r(N)''
				replace `pr_' = 1 - `threshold' if `pr_' > (1 - `threshold') & `pr_' != .
				replace `pr_' = `threshold' if `pr_' < `threshold' & `pr_' != .
				generate `wgt' = 1/`pr_' if `treatment' != `control'
				replace `wgt' = 1/(1-`pr_') if `treatment' == `control'
			}
			if `values' > 2	{
				local changed 0
				foreach i in `all_levels'	{
					predict `pr_'`i' if `sample' == 1, pr outcome(#`i')
					count if `pr_'`i' < `threshold' & `treatment' == `i'
					local changed `=`changed' + `r(N)''
					replace `pr_'`i' = `threshold' if `pr_'`i' < `threshold' & `treatment' == `i' & `pr_'`i' != .
					if `i' == 1	{
						generate `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
					else	{
						replace `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
				}
			}
		}
		
		* estimating overlap weights
		if "`weights'" == "overlap"	{
			if `values' == 2	{
				predict `pr_' if `sample' == 1, pr
				generate `wgt' = 1 - `pr_' if `treatment' != `control'
				replace `wgt' = `pr_' if `treatment' == `control'
			}
			if `values' > 2	{
				foreach i in `all_levels'	{
					predict `pr_'`i' if `sample' == 1, pr outcome(#`i')
					replace `pr_'`i' = 1/`pr_'`i'
				}
				egen `osum' = rowtotal(`pr_'*)
				replace `osum' = 1/`osum'
				local j 1
				foreach var of varlist `pr_'*	{
					generate `wgt'`j' = `var' * `osum'
					local `++j'
				}
				foreach i in `all_levels'	{
					if `i' == 1	{
						generate `wgt' = `wgt'`i' if `treatment' == `i'
						}
					else	{
						replace `wgt' = `wgt'`i' if `treatment' == `i'
					}
				}
			}
		}	
		
		* normalize weights
		summarize `wgt' if `sample' == 1, meanonly
		replace `wgt' = `wgt'/r(mean) if `sample' == 1
		
		* estimating weighted absolute & population standardized differences
		local j 1
		foreach i in `treatment_levels'	{
			foreach var of varlist `covlist'	{
				if "`balance'" == "asd"	{
					summarize `var' if `sample' == 1 & `treatment' == `control' [iweight = `wgt']
					local Mean_c = r(mean)
					local Var_c = r(Var)
					summarize `var' if `sample' == 1 & `treatment' == `i' [iweight = `wgt']
					local Mean_e = r(mean)
					local Var_e = r(Var)					
					matrix `results'[`j',2] = abs(`Mean_e'-`Mean_c')/sqrt((`Var_e'+`Var_c')/2)
				}
				if "`balance'" == "psd"	{
					summarize `var' if `sample' == 1 & `treatment' == `i' [iweight = `wgt']
					local Mean_e = r(mean)
					summarize `var' if `sample' == 1 [iweight = `wgt']
					local Mean0 = r(mean)
					local VarP = 0
					foreach level of local all_levels	{
						summarize `var' if `sample' == 1 & `treatment' == `level'
						local VarP = r(Var) + `VarP'
					}
					local Var_p = `Var_p'/`values'
					matrix `results'[`j',2] = abs(`Mean_e'-`Mean0')/sqrt(`VarP')
				}
				local `++j'
			}
		}
	}
	
	* estimation for imputed datasets
	if "`r(style)'" != ""	{
		local M = r(M)
		
		if "`r(style)'" != "flong"	{
			display as error "style of mi data is not {bf:flong}, change style as required (i.e., mi convert flong)"
			exit 498
		}
		
		* estimating raw absolute & population standardized differences
		local j 1
		foreach i in `treatment_levels'	{
			foreach var of varlist `covlist'	{
				if "`balance'" == "asd"	{
					local Mean_c = 0
					local Var_c = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' & `treatment' == `control'
						local Mean_c = `Mean_c' + r(mean)
						local Var_c = `Var_c' + r(Var)
					}
					local Mean_c = `Mean_c'/`M'
					local Var_c = `Var_c'/`M'	
					local Mean_e = 0
					local Var_e = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' & `treatment' == `i'
						local Mean_e = `Mean_e' + r(mean)
						local Var_e = `Var_e' + r(Var)
					}
					local Mean_e = `Mean_e'/`M'
					local Var_e = `Var_e'/`M'
					matrix `results'[`j',1] = abs(`Mean_e'-`Mean_c')/sqrt((`Var_e'+`Var_c')/2)
				}
				if "`balance'" == "psd"	{
					local Mean_p = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l'
						local Mean_p = `Mean_p' + r(mean)
					}
					local Mean_p = `Mean_p'/`M'
					local Mean_e = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' & `treatment' == `i'
						local Mean_e = `Mean_e' + r(mean)
					}
					local Mean_e = `Mean_e'/`M'
					local Var_j = 0
					local Var_p = 0
					foreach level of local all_levels	{
						forvalues l = 1/`M'	{
							summarize `var' if _mi_m == `l' & `treatment' == `level'
							local Var_j = `Var_j' + r(Var)
						}
						local Var_p = `Var_p' + (`Var_j'/`M')
					}
					local Var_p = `Var_p'/`values'
					matrix `results'[`j',1] = abs(`Mean_e'-`Mean_p')/sqrt(`Var_p')						
				}
				local `++j'
			}
		}
		
		* estimating inverse probability weights
		if "`weights'" == "inverse"	{
			if `values' == 2	{
				forvalues l = 1/`M'	{
					`estimator' if _mi_m == `l'
					predict `pr_'`l' if _mi_m == `l'
				}
				generate `pr_' = .
				forvalues l = 1/`M'	{
					replace `pr_' = `pr_'`l' if `pr_' == .
				}
				generate `wgt' = 1/`pr_' if `treatment' != `control'
				replace `wgt' = 1/(1-`pr_') if `treatment' == `control'
			}
			if `values' > 2	{
				foreach i in `all_levels'	{
					forvalues l = 1/`M'	{
						`estimator' if _mi_m == `l', baseoutcome(`control')
						predict `pr_'`i'`l' if _mi_m == `l', equation(#`i')
					}
					generate `pr_'`i' = .
					forvalues l = 1/`M'	{
						replace `pr_'`i' = `pr_'`i'`l' if `pr_'`i' == .
					}
					if `i' == 1	{
						generate `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
					else	{
						replace `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
				}
			}
		}
				
		* estimating trimming weights		
		if "`weights'" == "trimming"	{
			if `values' == 2	{
				forvalues l = 1/`M'	{
					`estimator' if _mi_m == `l'
					predict `pr_' if _mi_m == `l'
				}
				generate `pr_' = .
				forvalues l = 1/`M'	{
					replace `pr_' = `pr_'`l' if `pr_' == .
				}
				replace `pr_' = 1 - `threshold' if `pr_' > (1 - `threshold')
				replace `pr_' = `threshold' if `pr_' < `threshold'
				generate `wgt' = 1/`pr_' if `treatment' != `control'
				replace `wgt' = 1/(1-`pr_') if `treatment' == `control'
			}
			if `values' > 2	{
				foreach i in `all_levels'	{
					forvalues l = 1/`M'	{
						`estimator' if _mi_m == `l', baseoutcome(`control')
						predict `pr_'`i'`l' if _mi_m == `l', equation(#`i')
					}
					generate `pr_'`i' = .
					forvalues l = 1/`M'	{
						replace `pr_'`i' = `pr_'`i'`l' if `pr_'`i' == .
					}
					replace `pr_'`i' = `threshold' if `pr_'`i' < `threshold' & `treatment' == `i'
					if `i' == 1	{
						generate `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
					else	{
						replace `wgt' = 1/`pr_'`i' if `treatment' == `i'
					}
				}
			}
		}

		* estimating overlap weights
		if "`weights'" == "overlap"	{
			if `values' == 2	{
				forvalues l = 1/`M'	{
					`estimator' if _mi_m == `l'
					predict `pr_' if _mi_m == `l'
				}
				generate `pr_' = .
				forvalues l = 1/`M'	{
					replace `pr_' = `pr_'`l' if `pr_' == .
				}
				generate `wgt' = 1 - `pr_' if `treatment' != `control'
				replace `wgt' = `pr_' if `treatment' == `control'
			}
			if `values' > 2	{
				foreach i in `all_levels'	{
					forvalues l = 1/`M'	{
						`estimator' if _mi_m == `l', baseoutcome(`control')
						predict `pr_'`i'`l' if _mi_m == `l', equation(#`i')
					}
					generate `pr_'`i' = .
					forvalues l = 1/`M'	{
						replace `pr_'`i' = `pr_'`i'`l' if `pr_'`i' == .
						drop `pr_'`i'`l'
					}
					replace `pr_'`i' = 1/`pr_'`i'
				}
				egen `osum' = rowtotal(`pr_'*)
				replace `osum' = 1/`osum'
				local j 1
				foreach var of varlist `pr_'*	{
					generate `wgt'`j' = `var' * `osum'
					local `++j'
				}
				generate `wgt' = .
				foreach i in `all_levels'	{
					replace `wgt' = `wgt'`i' if `treatment' == `i'
				}
			}
		}
			
		* normalizing weights
		forvalues l = 1/`M'	{
			summarize `wgt' if _mi_m == `l'
			replace `wgt' = `wgt'/r(mean) if _mi_m == `l'
		}
			
		* estimating weighted absolute & population standardized differences
		local j 1
		foreach i in `treatment_levels'	{
			foreach var of varlist `covlist'	{
				if "`balance'" == "asd"	{
					local Mean_c = 0
					local Var_c = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' & `treatment' == `control' [iweight = `wgt']
						local Mean_c = `Mean_c' + r(mean)
						local Var_c = `Var_c' + r(Var)
					}
					local Mean_c = `Mean_c'/`M'
					local Var_c = `Var_c'/`M'
					local Mean_e = 0
					local Var_e = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' & `treatment' == `i' [iweight = `wgt']
						local Mean_e = `Mean_e' + r(mean)
						local Var_e = `Var_e' + r(Var)
					}
					local Mean_e = `Mean_e'/`M'
					local Var_e = `Var_e'/`M'
					matrix `results'[`j',2] = abs(`Mean_e'-`Mean_c')/sqrt((`Var_e'+`Var_c')/2)
				}
				if "`balance'" == "psd"	{
					local Mean_p = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' [iweight = `wgt']
						local Mean_p = `Mean_p' + r(mean)
					}
					local Mean_p = `Mean_p'/`M'
					local Mean_e = 0
					forvalues l = 1/`M'	{
						summarize `var' if _mi_m == `l' & `treatment' == `i' [iweight = `wgt']
						local Mean_e = `Mean_e' + r(mean)
					}
					local Mean_e = `Mean_e'/`M'
					local Var_j = 0
					local Var_p = 0
					foreach level of local all_levels	{
						forvalues l = 1/`M'	{
							summarize `var' if _mi_m == `l' & `treatment' == `level'
							local Var_j = `Var_j' + r(Var)
						}
						local Var_p = `Var_p' + (`Var_j'/`M')
						}
					local Var_p = `Var_p'/`values'
					matrix `results'[`j',2] = abs(`Mean_e'-`Mean_p')/sqrt(`Var_p')						
				}
				local `++j'
			}
		}
	}
	
	* end of quietly
	}
	
	* storing weights
	if "`savewgt'" != ""	{
		capture drop `savewgt'
		if "`r(style)'" == ""	{
			quietly gen `savewgt' = `wgt'
			display as text "weights are now stored in variable {bf:`savewgt'}"
		}
		if "`r(style)'" != ""	{
			quietly mi passive: gen `savewgt' = `wgt'
			display as text "weights are now stored in passive variable {bf:`savewgt'}"
		}
	}
	
	* presenting results
	matrix `results' = `results'[1...,1..2]
	foreach k in `treatment_levels'	{
		forvalues l = 1/`=`: word count `covnames''-1'	{
			local rspec "`rspec' &"
		}
		local rspec "`rspec' |"
	}
	local rspec "| |`rspec'"
	if "`weights'" == "trimming"	{
		if `values' == 2	{
			display " {break}{bf:`changed'} subjects had their propensity scores replaced to `threshold' because they were outside of the range [`threshold', 1 - `threshold']"
		}
		if `values' > 2	{
			display " {break}{bf:`changed'} subjects had their propensity scores replaced to `threshold' because they were outside of the range [`threshold', 1]"
		}
	}		
	matlist `results', title({bf:Balance of {ul:covariates} over {ul:`treatment'} levels}) tindent(16) cspec(o12 | t %24s | o0 C t %9.3f o2 & o0 C t %9.3f o2 |) rspec("`rspec'") showcoleq(combined) keepcoleq aligncolnames(center)
	if "`balance'" == "asd"	{
		display "	     {bf:ASD} = absolute standardized differences."
	}
	if "`balance'" == "psd"	{
		display "	     {bf:PSD} = population standardized differences."
	}
	
	* storing results
	ereturn post
	ereturn matrix table			= `results'
	ereturn scalar N_treatment		= `values'
	ereturn local cmdline			"`0'"
	ereturn local treatment			"`treatment'"
	ereturn local covariates		"`covariates'"
	ereturn local weight			"`weights'"
	ereturn local balance			"`balance'"
	ereturn local control			"`control'"
	ereturn local treatment_levels	"`treatment_levels'"
	ereturn local saved_weight		"`savewgt'"
	ereturn hidden local rownames	"`rownames'"
	ereturn hidden local rowcount	"`rowcount'"
	ereturn hidden local covnames	"`covnames'"
	ereturn local cmd				"covbalance2"
end

* plot option
capture program drop plotbalance
program plotbalance
	version 15.1
	syntax , treatments(string) labels(string asis) [plotopts(string)]
	
		quietly	{
		
			* defining the treatment variable
			local treatment_label : value label `e(treatment)'
			tempname treatment_indicator
			gen `treatment_indicator' = .
			label values `treatment_indicator' `treatment_label'
			local j 1
			foreach k in `e(treatment_levels)'	{
				foreach l in `e(covnames)'	{
					replace `treatment_indicator' = `k' if _n == `j'
					local `++j'
				}
			}
			
			* defining the categorical axis
			* default suboption
			if `"`labels'"' == "default"	{
				local j 1
				foreach k in `e(rownames)'	{
					local label "`label' `j' "`k'""
					local `++j'
				}
				tempname covariate_label
				label define `covariate_label' `label'
			}
			* manual suboption
			if `"`labels'"' != "default"	{
				if `: word count `e(covnames)'' != `: word count `labels''	{
					display as error "{bf:manual} labelling incorrectly specified}"
					display as error "the number of labels and variables must match"
					exit 198
				}
				else {
					foreach k in `e(treatment_levels)'	{
						foreach l in `" `labels' "'	{
							local names "`names' `l'"
						}
					}
					local j 1
					foreach k in `names'	{
						local label "`label' `j' "`k'""
						local `++j'
					}
					if `: word count `e(rownames)'' != `=`j'-1'	{
						display as error "{bf:manual} labelling incorrectly specified}"
						display as error "the number of labels and variables must match"
						exit 198
					}
					else	{	
						tempname covariate_label
						label define `covariate_label' `label'
					}
				}
			}

			* extracting data from the results matrix
			tempname results stub
			matrix `results' = e(table)
			svmat `results', names(`stub')
			
			* creating `c' to present results
			tempname c
			gen `c' = _n if _n <= `=`=`e(N_treatment)'-1'*`e(rowcount)''
			label values `c' `covariate_label'

		}

		* plotting
		if "`treatments'" == "all"	{
			graph dot `stub'1 `stub'2, over(`c', label(labsize(vsmall)) sort(2)) nofill marker(1, msymbol(D) mcolor(red%35) msize(small)) marker(2, msymbol(D) mcolor(blue%35) msize(small)) linetype(line) lines(lpattern(shortdash) lwidth(vvthin) lcolor(black)) legend(label(1 "Raw") label(2 "Weighted") size(small) region(lstyle(none)) span) ytitle("Standardized Mean Differences", margin(medsmall) size(small)) yline(0.1, lcolor(maroon%90) lpattern(dash) lwidth(medthick)) by(`treatment_indicator', rows(1) title("Covariate balance", margin(medsmall) size(medium) color(black) span) note("{it:Notes:} Covariate balance by categories of exposure.", size(vsmall)) graphregion(color(white))) `plotopts'
		}
		else	{
			graph dot `stub'1 `stub'2 if `treatment_indicator' == `treatments', over(`c', label(labsize(vsmall)) sort(2)) nofill marker(1, msymbol(D) mcolor(red%35) msize(small)) marker(2, msymbol(D) mcolor(blue%35) msize(small)) linetype(line) lines(lpattern(shortdash) lwidth(vvthin) lcolor(black)) legend(label(1 "Raw") label(2 "Weighted") size(small) region(lstyle(none)) span) ytitle("Standardized Mean Differences", margin(medsmall) size(small)) yline(0.1, lcolor(maroon%90) lpattern(dash) lwidth(medthick)) by(`treatment_indicator', rows(1) title("Covariate balance", margin(medsmall) size(medium) color(black) span) note("{it:Notes:} Covariate balance by categories of exposure.", size(vsmall)) graphregion(color(white))) `plotopts'
		}
		
end