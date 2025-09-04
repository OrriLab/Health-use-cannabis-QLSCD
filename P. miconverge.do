capture program drop miconverge
program define miconverge
	version 15.0
	quietly	{
		syntax , missvar(string) tracename(string)
		preserve
		use "`tracename'", clear
		sum m
		local m `r(max)'
		local stats `"mean sd"'
		qui	{
			foreach j of local missvar	{
				foreach k of local stats	{
					sum `j'_`k'
					capture scalar `j'_`k' = `r(mean)'
					if _rc !=0	{
						scalar `j'_`k' = 0
						display as error "`j'_`k' not found, trace plot will be empty for this estimate"
					}
				}
			}
		}
		reshape wide *mean *sd, i(iter) j(m)
		tsset iter
		foreach j of local missvar	{
			foreach k of local stats	{
				forvalues l = 1/`m'{
					local g`j'_`k' "`g`j'_`k'' `j'_`k'`l'"
				}
			}
		}
		local i 1
		foreach j of local missvar	{
			foreach k of local stats	{
				tsline `g`j'_`k'', yline(`=`j'_`k'') title(`j'_`k', size(medsmall)) ylabel(, labsize(small)) xlabel(, labsize(small)) xtitle(, size(small)) legend(off) name(gr`i', replace) nodraw
				local graph "`graph' gr`i'"
				local `++i'
			}
		}
	}
graph combine `graph', title(Trace plots of summaries of imputed values)
end