capture program drop micheckimputed
program define micheckimputed
	version 15.0
	quietly	{
		syntax , [cat(string) noncat(string)]
		if "`cat'" == "" & "`noncat'" == ""	{
			di as error "options {bf:cat} or {bf:noncat} are required"
			exit 198
		}	
		foreach j of local noncat	{
			kdensity `j' if _mi_m==0, lcolor(black) addplot(kdensity `j' if _mi_m!=0, lcolor(black) lpattern(dash) || kdensity `j', lcolor(black) lpattern(dot)) legend(label(1 "Original") label(2 "Imputed") label(3 "Completed")) note("") title("") name(d`j', replace) nodraw
			local density "`density' d`j'"
		}		
		tempvar imp
		tempname label
		gen `imp' = cond(_mi_m!=0,1,0)
		label define `label' 0 "Original" 1 "Imputed"
		label values `imp' `label'
		foreach k of local cat	{
			sum `k'
			twoway (hist `k' if `imp', discrete gap(25) by(`imp', leg(off) note("") title(`k')) bcolor(red%30)) (hist `k' if !`imp', discrete gap(25) by(`imp', note("")) bcolor(blue%30)), xlabel(`r(min)'(1)`r(max)') name(h`k', replace) nodraw			
			local histo "`histo' h`k'"
		}
	}
	if "`cat'" != ""	{
		graph combine `histo', title(Comparing imputed to observed values)
	}
	if "`noncat'" != ""	{
		graph combine `density', title(Comparing imputed to observed values)
	}
end