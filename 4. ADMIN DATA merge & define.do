cd // this line sets the working directory to where this do-file is stored!

**# Merging FIPA + RAMQ + MED-ECHO + BDCU to create final set of variable in data analysis plan

use RAMQ_ALL, clear

merge 1:1 noindiv using HOSPITAL_ALL
drop _merge COD_DIAG DAT_SERV death NO_SEQ_SEJ_BAN NO_SEQ_SYS_CLA_diag DAT_ADMIS diag_cause_accid

merge 1:1 noindiv using BDCU_ALL
drop _merge NO_EPISO_SOIN_DURG_BAN COD_DIAG COD_RAIS_VISIT death DAT_SERV

*** AGE DEFINITIONS ***
local agroups "t a b c ab"
local alabels ""lifetime" "childhood" "adolescence" "adulthood" "before 18 years""

*** COMMON MENTAL DISORDERS ***
local names "depression anxiety adjustment common"
local labels ""Depressive disorders" "Anxiety disorders" "Adjustment disorders" "Common mental disorders""
local nnames : word count `names'
local nlabels : word count `agroups'
label define yesno 0 "No" 1 "Yes"

forvalues i = 1/`nnames' {
	forvalues j = 1/`nlabels'	{
		local w: word `i' of `names'
		local x: word `i' of `labels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		gen `w'_1_`y' = cond(twov_`w'_`y'==1 | oneh_`w'_`y'==1 | er1_`w'_`y'==1,1,0)
		label variable `w'_1_`y' "`x' - 1 HOSP/ER OR 2 VISITS - `z'"
		label values `w'_1_`y' yesno
	}
}

local vis "vis_"
local hosp "hosp_"
local er "er"

forvalues i = 1/`nnames' {
	forvalues j = 1/`nlabels' {
		local w: word `i' of `names'
		local x: word `i' of `labels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		rename `vis'`w'_`y' `w'_`vis'`y'
		rename `hosp'`w'_`y' `w'_`hosp'`y'
		rename `er'1_`w'_`y' `w'_`er'_`y'
		label variable `w'_`vis'`y' "`x' - N VISITS - `z'"
		label variable `w'_`hosp'`y' "`x' - N HOSP - `z'"
		label variable `w'_`er'_`y' "`x' - N ER VISITS - `z'"
		order `w'_`vis'`y' `w'_`hosp'`y' `w'_`er'_`y', last
	}
}

*** SERIOUS MENTAL DISORDERS, SUBSTANCE-RELATED DISORDERS & SUICIDE-RELATED BEHAVIORS ***
local names "bipolar psychotic severe alcohol drug cannabis substance suicide_attempt"
local labels ""Bipolar disorders" "Psychotic disorders" "Severe mental disorders" "Alcohol-related disorders" "Drug-related disorders" "Cannabis-related disorders" "Any substance-related disorder" "Suicide-related behaviors""
local nnames : word count `names'
local nlabels : word count `agroups'

forvalues i = 1/`nnames' {
	forvalues j = 1/`nlabels'	{
		local w: word `i' of `names'
		local x: word `i' of `labels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		gen `w'_1_`y' = cond(onev_`w'_`y'==1 | oneh_`w'_`y'==1 | er1_`w'_`y'==1,1,0)
		label variable `w'_1_`y' "`x' - 1 HOSP/ER/VISITS - `z'"
		label values `w'_1_`y' yesno
	}
}

forvalues i = 1/`nnames' {
	forvalues j = 1/`nlabels' {
		local w: word `i' of `names'
		local x: word `i' of `labels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		rename `vis'`w'_`y' `w'_`vis'`y'
		rename `hosp'`w'_`y' `w'_`hosp'`y'
		rename `er'1_`w'_`y' `w'_`er'_`y'
		label variable `w'_`vis'`y' "`x' - N VISITS - `z'"
		label variable `w'_`hosp'`y' "`x' - N HOSP - `z'"
		label variable `w'_`er'_`y' "`x' - N ER VISITS - `z'"
		order `w'_`vis'`y' `w'_`hosp'`y' `w'_`er'_`y', last
	}
}

*** ANY MENTAL DISORDER - THIS DEFINITION DOES NOT CONSIDER SUICIDE-RELATED BEHAVIORS, NOR NEURODEVELOPMENTAL DISORDERS ***

forvalues j = 1/`nlabels'	{
	local y: word `j' of `agroups'
	local z: word `j' of `alabels'
	gen any_mental_1_`y' = cond(common_1_`y'==1 | severe_1_`y'==1 | substance_1_`y'==1,1,0)
	label variable any_mental_1_`y' "ANY MENTAL DISORDER [COMMON/SERIOUS/SUBSTANCE] - `z'"
	label values any_mental_1_`y' yesno
}

forvalues j = 1/`nlabels' {
	local y: word `j' of `agroups'
	local z: word `j' of `alabels'
	rename `vis'any_mental_`y' any_mental_`vis'`y'
	rename `hosp'any_mental_`y' any_mental_`hosp'`y'
	rename `er'1_any_mental_`y' any_mental_`er'_`y'
	label variable any_mental_`vis'`y' "ANY MENTAL DISORDER [COMMON/SERIOUS/SUBSTANCE] - N VISITS - `z'"
	label variable any_mental_`hosp'`y' "ANY MENTAL DISORDER [COMMON/SERIOUS/SUBSTANCE] - N HOSP - `z'"
	label variable any_mental_`er'_`y' "ANY MENTAL DISORDER [COMMON/SERIOUS/SUBSTANCE] - N ER VISITS - `z'"
	order any_mental_`vis'`y' any_mental_`hosp'`y' any_mental_`er'_`y', last
}

*** NEURODEVELOPMENTAL DISORDERS AND DISTURBANCES OF CONDUCT/EMOTION (ONLY IN CHILDHOOD AND ADOLESCENCE)
local names "retardation delays adhd movement tic neurodevelopmental conduct_emotion"
local labels ""Mental retardation" "Disorders of psychological development" "ADHD" "Stereotyped movement disorders" "Tic disorders" "Neurodevelopmental disorders" "Disturbances of conduct and emotions""
local nnames : word count `names'
local nlabels : word count `agroups'

forvalues i = 1/`nnames' {
	forvalues j = 1/`nlabels'	{
		local w: word `i' of `names'
		local x: word `i' of `labels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		gen `w'_1_`y' = cond(twov_`w'_`y'==1 | oneh_`w'_`y'==1 | er1_`w'_`y'==1,1,0)
		label variable `w'_1_`y' "`x' - 1 HOSP/ER OR 2 VISITS - `z'"
		label values `w'_1_`y' yesno
	}
}

forvalues i = 1/`nnames' {
	forvalues j = 1/`nlabels' {
		local w: word `i' of `names'
		local x: word `i' of `labels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		rename `vis'`w'_`y' `w'_`vis'`y'
		rename `hosp'`w'_`y' `w'_`hosp'`y'
		rename `er'1_`w'_`y' `w'_`er'_`y'
		label variable `w'_`vis'`y' "`x' - N VISITS - `z'"
		label variable `w'_`hosp'`y' "`x' - N HOSP - `z'"
		label variable `w'_`er'_`y' "`x' - N ER VISITS - `z'"
		order `w'_`vis'`y' `w'_`hosp'`y' `w'_`er'_`y', last
	}
}

* ADULT-ONSET NEURODEVELOPMENTAL DISORDERS
forvalues i = 1/`nnames' {
		local w: word `i' of `names'
		local x: word `i' of `labels'
		gen `w'_1_ao = cond(`w'_1_c == 1 & `w'_1_ab == 0,1,0)
		label variable `w'_1_ao "ADULT ONSET `x' (1 HOSP/ER OR 2 VISITS)"
		label values `w'_1_ao yesno
}

*** PHYSICAL DISEASES (EXCEPT UNINTENTIONAL INJURIES)***
local pnames "respiratory asthma accidental_falls nonintentional_firearm accidental_drowning accidental_breathing accidental_poissoning assault unintentional_injuries injuries_g infectious neoplasms blood metabolic nervous circulatory digestive genitourinary skin musculoskeletal other_physical any_physical any_physical2"
local plabels ""Respiratory diseases" "Asthma" "Accidental falls" "Nonintentional firearm discharge" "Accidental drowning and submersion" "Accidental threats to breathing" "Accidental poissoning" "Assault" "Unintentional injuries" "Injuries & poisoning" "Infectious diseases" "Neoplasms" "Blood diseases (...)" "Metabolic diseases" "Nervous system diseases" "Circulatory diseases" "Digestive diseases" "Genitourinary diseases"  "Skin diseases" "Musculoskeletal diseases" "Other physical diseases" "Any physical disease (w/Unintentional injuries)" "Any physical disease (w/Injuries & poisoning)""
local npnames : word count `pnames'
local nlabels : word count `agroups'

forvalues i = 1/`npnames' {
	forvalues j = 1/`nlabels'	{
		local w: word `i' of `pnames'
		local x: word `i' of `plabels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		gen `w'_1_`y' = cond(twov_`w'_`y'==1 | oneh_`w'_`y'==1 | er1_`w'_`y'==1,1,0)
		label variable `w'_1_`y' "`x' - 1 HOSP/ER OR 2 VISITS - `z'"
		label values `w'_1_`y' yesno
	}
}

forvalues i = 1/`npnames' {
	forvalues j = 1/`nlabels' {
		local w: word `i' of `pnames'
		local x: word `i' of `plabels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		rename `vis'`w'_`y' `w'_`vis'`y'
		rename `hosp'`w'_`y' `w'_`hosp'`y'
		rename `er'1_`w'_`y' `w'_`er'_`y'
		label variable `w'_`vis'`y' "`x' - N VISITS - `z'"
		label variable `w'_`hosp'`y' "`x' - N HOSP - `z'"
		label variable `w'_`er'_`y' "`x' - N ER VISITS - `z'"
		order `w'_`vis'`y' `w'_`hosp'`y' `w'_`er'_`y', last
	}
}

* REMAINING INJURIES (LAND TRANSPORT, THEY WERE NOT CODIFIED IN RAMQ, THEREFORE NO VISITS)
local pnames "driver_accident non_driver_accident land_transport_accidents"
local plabels ""Land transport accidents: drive" "Land transport accidents: non-driver" "Land transport accidents""
local npnames : word count `pnames'
local nlabels : word count `agroups'

forvalues i = 1/`npnames' {
	forvalues j = 1/`nlabels'	{
		local w: word `i' of `pnames'
		local x: word `i' of `plabels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		gen `w'_1_`y' = cond(oneh_`w'_`y'==1 | er1_`w'_`y'==1,1,0)
		label variable `w'_1_`y' "`x' - 1 HOSP/ER - `z'"
		label values `w'_1_`y' yesno
	}
}

forvalues i = 1/`npnames' {
	forvalues j = 1/`nlabels' {
		local w: word `i' of `pnames'
		local x: word `i' of `plabels'
		local y: word `j' of `agroups'
		local z: word `j' of `alabels'
		rename `hosp'`w'_`y' `w'_`hosp'`y'
		rename `er'1_`w'_`y' `w'_`er'_`y'
		label variable `w'_`hosp'`y' "`x' - N HOSP - `z'"
		label variable `w'_`er'_`y' "`x' - N ER VISITS - `z'"
		order `w'_`hosp'`y' `w'_`er'_`y', last
	}
}

**# DROP UNUSED VARIABLES
drop onev_depression_t-er_any_physical2_ab

**# FORMAT OF VARIABLES
format %9.2f *_hosp_* *_vis_*

save ADMIN_FINAL_DETAILED, replace