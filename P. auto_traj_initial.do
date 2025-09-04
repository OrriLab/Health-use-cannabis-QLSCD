* Note, lines 35-46 have been commented out of the program because they seem to refer to the problematic _ent_row variable; need to explore this further

capture program drop auto_traj_initial
program auto_traj_initial
	version 15.0
	syntax , groups(numlist integer min=1 max=1 >=1 <=10) initpoly(numlist integer min=1 max=1 >=1 <=5) trajopts(string)

	* defining some temporary names, files, variables, etc., for later use
	tempname matinitial results
	tempfile templog
	
	quietly	{
		
		* checking if traj options are well specified
		local order "order(`initpoly')"
		traj, `trajopts' `order'
		
		* defining a mata matrix to temporally store and run analyses
		mata: `matinitial' = J(`groups',4,.)
		
		* iterating per groups
		forvalues i = 1/`groups'	{
		
			* storing any output appearing in the results window
			log using `templog', replace smcl
			capture noisily quietly traj, `trajopts' `order'
			log close
			capture confirm variable _ent_row, exact
			
			* dropping the problematic variable ent_row
			if !_rc	{
				drop _ent_row
			}
			
			/* error checks and storing results for that model as missing
			if _rc	{
				local order: subinstr local order "`initpoly'" "`initpoly' `initpoly'"
				mata: `matinitial'[`i',1]= st_numscalar("e(numGroups1)")
				if `i' == `groups'	{
					mata: `matinitial'[.,3]= exp(`matinitial'[.,2] :- colmax(`matinitial')[1,2]) :/ colsum(exp(`matinitial'[.,2] :- colmax(`matinitial')[1,2]))
				}
				di as error "Warning observed for estimations involving `i' groups"
				di as error "Results from those estimations set to missing"
				continue
			}
			*/

			* warning checks and storing results for that model as missing
			local warning = strpos(fileread("`templog'"), "Warning") | strpos(fileread("`templog'"), "WARNING") | strpos(fileread("`templog'"), "Unable to calculate standard errors")	
			else if `warning' != 0	{
				local order: subinstr local order "`initpoly'" "`initpoly' `initpoly'"
				mata: `matinitial'[`i',1]= st_numscalar("e(numGroups1)")
				if `i' == `groups'	{
					mata: `matinitial'[.,3]= exp(`matinitial'[.,2] :- colmax(`matinitial')[1,2]) :/ colsum(exp(`matinitial'[.,2] :- colmax(`matinitial')[1,2]))
				}
				di as error "Warning observed for estimations involving `i' groups"
				di as error "Results from those estimations set to missing"
				continue
			}
			
			* if no errors nor warnings, store results
			else	{
				local order: subinstr local order "`initpoly'" "`initpoly' `initpoly'"
				mata: `matinitial'[`i',1]= st_numscalar("e(numGroups1)")
				mata: `matinitial'[`i',2]= st_numscalar("e(BIC_n_subjects)")
				mata: `matinitial'[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
				if `i' == `groups'	{
					mata: `matinitial'[.,3]= exp(`matinitial'[.,2] :- colmax(`matinitial')[1,2]) :/ colsum(exp(`matinitial'[.,2] :- colmax(`matinitial')[1,2]))
				}
			}
		}
		
		* obtain matrix from Mata and put it in Stata
		mata: st_matrix("`results'", sort(`matinitial',-3))
		matrix colnames `results' = "N Groups" "BIC subj." "P (corr.)" "Group n>5%"
	}
	
	* presenting results
	matlist `results', title({bf:BIC-based group selection}) tindent(12) names(col) border(rows) left(4)
	di "	{bf:Notes.}"
	di "	{it:BIC subj.} = Sample size-based BIC."
	di "	{it:P (corr.)} = Probability correct model."
	di "	{it:Group n > 5%} = 0 if at least 1 group with less than 5% of subjects assigned; otherwise, 1."
	di "	{error:{bf:Warning messages}} may appear if iterations had convergence issues."
end
