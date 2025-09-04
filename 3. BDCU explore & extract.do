cd // this line sets the working directory to where this do-file is stored!

**# Syntax to merge FIPA + RAMQ + MED-ECHO + BDCU, identifying diagnoses × individuals

**# Selection of ELDEQ participants matched with RAMQ (n = 2082) (FIPA file)

use fipa_40056, clear

// formating dates of births: for births the 1st day of the month was assumed, for deaths the last day of the month //
gen birth = date(NAISS_AAAAMM, "YM")
format birth %td
gen death = date(DECES_AAAAMM, "YM")
replace death = lastdayofmonth(death)
format death %td

// sex
encode sexe, gen(sex)

drop NAISS_AAAAMM-DECES_AAAAMM

save FIPA, replace

******

******

**# Emergency visits (BDCU): merge w/FIPA

use bdcu_episo_soins_40056, clear

keep noindiv NO_EPISO_SOIN_DURG_BAN DHD_EPISO_SOIN COD_DIAGN_MDCAL_CLINQ COD_RAIS_VISIT
merge m:m noindiv using FIPA
drop _merge

gen DAT_SERV = dofc(DHD_EPISO_SOIN)
format DAT_SERV %td

sort noindiv DAT_SERV
drop DHD_EPISO_SOIN
rename COD_DIAGN_MDCAL_CLINQ COD_DIAG

* QUICK CHECK FOR DIAGNOSTIC CODES USED
gen diag_digit = substr(COD_DIAG , 1, 1)
tab diag_digit if substr(COD_DIAG , 1, 3)!="XXX" // all good but NOTE BELOW (limitation)
drop diag_digit

**********
** NOTE **
**********
* V, W, X & Y Codes not used, therefore, unintentional injuries could not be categorized and therefore, are severely underestimated!

save BDCU, replace

******

******

**# Basic definition of locals: diseases (ICD-10 codes only), names, and age groups

**# Definition of mental & substance-related disorders

local depression `"((substr(COD_DIAG,1,3)=="F32") | (substr(COD_DIAG,1,3)=="F33") | (substr(COD_DIAG,1,4)=="F341") | (substr(COD_DIAG,1,4)=="F348") | (substr(COD_DIAG,1,4)=="F349") | (substr(COD_DIAG,1,3)=="F38") | (substr(COD_DIAG,1,3)=="F39") | (substr(COD_DIAG,1,4)=="F412"))"'

local anxiety `"((substr(COD_DIAG,1,3)=="F40") | (substr(COD_DIAG,1,3)=="F41" & substr(COD_DIAG,1,4)!="F412") | (substr(COD_DIAG,1,3)=="F42") | (substr(COD_DIAG,1,3)=="F45") | (substr(COD_DIAG,1,3)=="F48"))"'

local adjustment `"((substr(COD_DIAG,1,3)=="F43"))"'

local common `"(`depression' | `anxiety' | `adjustment')"'

local adhd `"((substr(COD_DIAG,1,3)=="F90"))"'

local bipolar `"((substr(COD_DIAG,1,3)=="F30") | (substr(COD_DIAG,1,3)=="F31") | (substr(COD_DIAG,1,4)=="F340"))"'

local psychotic `"((substr(COD_DIAG,1,3)=="F20") | (substr(COD_DIAG,1,3)=="F21") | (substr(COD_DIAG,1,3)=="F22") | (substr(COD_DIAG,1,3)=="F23") | (substr(COD_DIAG,1,3)=="F24") | (substr(COD_DIAG,1,3)=="F25") | (substr(COD_DIAG,1,3)=="F28") | (substr(COD_DIAG,1,3)=="F29"))"'

local severe `"(`bipolar' | `psychotic')"'

local alcohol `"((substr(COD_DIAG,1,4)>="F101" & substr(COD_DIAG,1,4)<="F109") | (substr(COD_DIAG,1,4)>="K700" & substr(COD_DIAG,1,4)<="K704") | (substr(COD_DIAG,1,4)=="K709") | (substr(COD_DIAG,1,4)=="G621") | (substr(COD_DIAG,1,4)=="I426") | (substr(COD_DIAG,1,4)=="K292") | (substr(COD_DIAG,1,4)=="K852") | (substr(COD_DIAG,1,4)=="K860") | (substr(COD_DIAG,1,4)=="E244") | (substr(COD_DIAG,1,4)=="G312") | (substr(COD_DIAG,1,4)=="G721") | (substr(COD_DIAG,1,4)=="O354") | (substr(COD_DIAG,1,4)=="F100") | (substr(COD_DIAG,1,4)=="T510") | (substr(COD_DIAG,1,4)=="T511") | (substr(COD_DIAG,1,4)=="T518") | (substr(COD_DIAG,1,4)=="T519"))"'

local drug `"((substr(COD_DIAG,1,4)>="F111" & substr(COD_DIAG,1,4)<="F114") | (substr(COD_DIAG,1,4)=="F116") | (substr(COD_DIAG,1,4)=="F118") | (substr(COD_DIAG,1,4)=="F119") | (substr(COD_DIAG,1,4)>="F131" & substr(COD_DIAG,1,4)<="F134") | (substr(COD_DIAG,1,4)=="F136") | (substr(COD_DIAG,1,4)=="F138") | (substr(COD_DIAG,1,4)=="F139") | (substr(COD_DIAG,1,4)>="F141" & substr(COD_DIAG,1,4)<="F144") | (substr(COD_DIAG,1,4)=="F146") | (substr(COD_DIAG,1,4)=="F148") | (substr(COD_DIAG,1,4)=="F149") | (substr(COD_DIAG,1,4)>="F151" & substr(COD_DIAG,1,4)<="F154") | (substr(COD_DIAG,1,4)=="F156") | (substr(COD_DIAG,1,4)=="F158") | (substr(COD_DIAG,1,4)=="F159") | (substr(COD_DIAG,1,4)>="F161" & substr(COD_DIAG,1,4)<="F164") | (substr(COD_DIAG,1,4)=="F166") | (substr(COD_DIAG,1,4)=="F168") | (substr(COD_DIAG,1,4)=="F169") | (substr(COD_DIAG,1,4)>="F181" & substr(COD_DIAG,1,4)<="F184") | (substr(COD_DIAG,1,4)=="F186") | (substr(COD_DIAG,1,4)=="F188") | (substr(COD_DIAG,1,4)=="F189") | (substr(COD_DIAG,1,4)>="F191" & substr(COD_DIAG,1,4)<="F194") | (substr(COD_DIAG,1,4)=="F196") | (substr(COD_DIAG,1,4)=="F198") | (substr(COD_DIAG,1,4)=="F199") | (substr(COD_DIAG,1,4)>="T400" & substr(COD_DIAG,1,4)<="T409" & substr(COD_DIAG,1,4)!="T407") | (substr(COD_DIAG,1,4)=="T423") | (substr(COD_DIAG,1,4)=="T424") | (substr(COD_DIAG,1,4)=="T426") | (substr(COD_DIAG,1,4)=="T427") | (substr(COD_DIAG,1,4)=="T435") | (substr(COD_DIAG,1,4)=="T436") | (substr(COD_DIAG,1,4)=="T438") | (substr(COD_DIAG,1,4)=="T439") | (substr(COD_DIAG,1,4)=="T509") | (substr(COD_DIAG,1,4)=="T528") | (substr(COD_DIAG,1,4)=="T529") | (substr(COD_DIAG,1,4)=="F115") | (substr(COD_DIAG,1,4)=="F117") | (substr(COD_DIAG,1,4)=="F135") | (substr(COD_DIAG,1,4)=="F137") | (substr(COD_DIAG,1,4)=="F145") | (substr(COD_DIAG,1,4)=="F147") | (substr(COD_DIAG,1,4)=="F155") | (substr(COD_DIAG,1,4)=="F157") | (substr(COD_DIAG,1,4)=="F165") | (substr(COD_DIAG,1,4)=="F167") | (substr(COD_DIAG,1,4)=="F185") | (substr(COD_DIAG,1,4)=="F187") | (substr(COD_DIAG,1,4)=="F195") | (substr(COD_DIAG,1,4)=="F197"))"'

local cannabis `"((substr(COD_DIAG,1,3)=="F12") | (substr(COD_DIAG,1,4)=="T407"))"'

local substance `"(`alcohol' | `drug' | `cannabis')"'

local suicide_attempt `"((substr(COD_DIAG,1,3)>="X60" & substr(COD_DIAG,1,3)<="X84") | (substr(COD_DIAG,1,4)=="Y870") | (substr(COD_RAIS_VISIT,1,3)=="068"))"' // COD RAIS VISIT = TRIAGE CODE NURSE

local any_mental `"(`common' | `severe' | `substance')"'

local retardation `"((substr(COD_DIAG,1,3)=="F70") | (substr(COD_DIAG,1,3)=="F71") | (substr(COD_DIAG,1,3)=="F72") | (substr(COD_DIAG,1,3)=="F73") | (substr(COD_DIAG,1,3)=="F78") | (substr(COD_DIAG,1,3)=="F79"))"'

local delays `"((substr(COD_DIAG,1,3)=="F80") | (substr(COD_DIAG,1,3)=="F81") | (substr(COD_DIAG,1,3)=="F82") | (substr(COD_DIAG,1,3)=="F83") | (substr(COD_DIAG,1,3)=="F84") | (substr(COD_DIAG,1,3)=="F88") | (substr(COD_DIAG,1,3)=="F89"))"'

local movement `"((substr(COD_DIAG,1,4)=="F984"))"'

local tic `"((substr(COD_DIAG,1,3)=="F95"))"'

local conduct_emotion `"((substr(COD_DIAG,1,3)=="F91") | (substr(COD_DIAG,1,3)=="F92") | (substr(COD_DIAG,1,3)=="F93") | (substr(COD_DIAG,1,4)=="F941") | (substr(COD_DIAG,1,4)=="F942") | (substr(COD_DIAG,1,4)=="F948") | (substr(COD_DIAG,1,4)=="F949"))"'

local neurodevelopmental `"(`retardation' | `delays' | `movement' | `tic' | `adhd')"'

**# Definition of physical diseases

local respiratory `"((substr(COD_DIAG,1,1)=="J"))"'

local asthma `"((substr(COD_DIAG,1,3)=="J45"))"'

local driver_accident `"((substr(COD_DIAG,1,3)>="V10" & substr(COD_DIAG,1,3)<="V79" & (substr(COD_DIAG,4,1)=="0" | substr(COD_DIAG,4,1)=="4")) | (substr(COD_DIAG,1,3)>="V83" & substr(COD_DIAG,1,3)<="V86" & (substr(COD_DIAG,4,1)=="0" | substr(COD_DIAG,4,1)=="5")))"'

local non_driver_accident `"((substr(COD_DIAG,1,3)>="V01" & substr(COD_DIAG,1,3)<="V09") | (substr(COD_DIAG,1,3)>="V80" & substr(COD_DIAG,1,3)<="V82") | (substr(COD_DIAG,1,3)>="V10" & substr(COD_DIAG,1,3)<="V79" & (substr(COD_DIAG,4,1)!="0" | substr(COD_DIAG,4,1)!="4")) | (substr(COD_DIAG,1,3)>="V83" & substr(COD_DIAG,1,3)<="V86" & (substr(COD_DIAG,4,1)!="0" | substr(COD_DIAG,4,1)!="5")))"'

local land_transport_accidents `"(`driver_accident' | `non_driver_accident')"'

local accidental_falls `"((substr(COD_DIAG,1,3)>="W00" & substr(COD_DIAG,1,3)<="W19"))"'

local nonintentional_firearm `"((substr(COD_DIAG,1,3)>="W32" & substr(COD_DIAG,1,3)<="W34"))"'

local accidental_drowning `"((substr(COD_DIAG,1,3)>="W65" & substr(COD_DIAG,1,3)<="W74") | (substr(COD_DIAG,1,3)>="V90" & substr(COD_DIAG,1,3)<="V92"))"'

local accidental_breathing `"((substr(COD_DIAG,1,3)>="W44" & substr(COD_DIAG,1,3)<="W45") | (substr(COD_DIAG,1,3)>="W75" & substr(COD_DIAG,1,3)<="W84"))"'

local accidental_poissoning `"((substr(COD_DIAG,1,3)>="X40" & substr(COD_DIAG,1,3)<="X49"))"'

local assault `"((substr(COD_DIAG,1,3)>="X85" & substr(COD_DIAG,1,3)<="Y09" & substr(COD_DIAG,1,3)!="XXX"))"'

local unintentional_injuries `"(`land_transport_accidents' | `accidental_falls' | `nonintentional_firearm' | `accidental_drowning' | `accidental_breathing' | `accidental_poissoning' | `assault')"'

local injuries_g `"((((substr(COD_DIAG,1,3)>="S00" & substr(COD_DIAG,1,3)<="T79" & substr(COD_DIAG,1,4)!="T510" & substr(COD_DIAG,1,4)!="T511" & substr(COD_DIAG,1,4)!="T518" & substr(COD_DIAG,1,4)!="T519" & substr(COD_DIAG,1,3)!="T40" & substr(COD_DIAG,1,4)!="T423" & substr(COD_DIAG,1,4)!="T424" & substr(COD_DIAG,1,4)!="T426" & substr(COD_DIAG,1,4)!="T427" & substr(COD_DIAG,1,4)!="T435" & substr(COD_DIAG,1,4)!="T436" & substr(COD_DIAG,1,4)!="T438" & substr(COD_DIAG,1,4)!="T439" & substr(COD_DIAG,1,4)!="T509" & substr(COD_DIAG,1,4)!="T528" & substr(COD_DIAG,1,4)!="T529") | (substr(COD_DIAG,1,3)>="T90" & substr(COD_DIAG,1,3)<="T98")) & ! ((substr(COD_DIAG,1,3)>="X60" & substr(COD_DIAG,1,3)<="X84") | (substr(COD_DIAG,1,4)=="Y870") | (substr(COD_RAIS_VISIT,1,3)=="068"))))"'

local infectious `"((substr(COD_DIAG,1,1)=="A") | (substr(COD_DIAG,1,1)=="B") | (substr(COD_DIAG,1,3)=="U04"))"'

local neoplasms `"((substr(COD_DIAG,1,1)=="C") | (substr(COD_DIAG,1,2)=="D0") | (substr(COD_DIAG,1,2)=="D1") | (substr(COD_DIAG,1,2)=="D2") | (substr(COD_DIAG,1,2)=="D3") | (substr(COD_DIAG,1,2)=="D4"))"'

local blood `"((substr(COD_DIAG,1,3)>="D50" & substr(COD_DIAG,1,3)<="D89"))"'

local metabolic `"((substr(COD_DIAG,1,3)>="E00" & substr(COD_DIAG,1,3)<="E90" & substr(COD_DIAG,1,4)!="E244"))"'

local nervous `"((substr(COD_DIAG,1,3)>="G00" & substr(COD_DIAG,1,3)<="G99" & substr(COD_DIAG,1,4)!="G621" & substr(COD_DIAG,1,4)!="G312" & substr(COD_DIAG,1,4)!="G721") | (substr(COD_DIAG,1,3)>="H00" & substr(COD_DIAG,1,3)<="H95"))"'

local circulatory `"((substr(COD_DIAG,1,1)=="I" & substr(COD_DIAG,1,4)!="I426"))"'

local digestive `"((substr(COD_DIAG,1,1)=="K" & substr(COD_DIAG,1,4)!="K292" & substr(COD_DIAG,1,4)!="K700" & substr(COD_DIAG,1,4)!="K701" & substr(COD_DIAG,1,4)!="K702" & substr(COD_DIAG,1,4)!="K703" & substr(COD_DIAG,1,4)!="K704" & substr(COD_DIAG,1,4)!="K709" & substr(COD_DIAG,1,4)!="K852" & substr(COD_DIAG,1,4)!="K860"))"'

local genitourinary `"((substr(COD_DIAG,1,1)=="N"))"'

local skin `"((substr(COD_DIAG,1,1)=="L"))"'

local musculoskeletal `"((substr(COD_DIAG,1,1)=="M"))"'

local other_physical `"(`infectious' | `neoplasms' | `blood' | `metabolic' | `nervous' | `circulatory' | `digestive' | `genitourinary' | `skin' | `musculoskeletal')"'

local any_physical `"(`respiratory' | `unintentional_injuries' | `other_physical')"'

local any_physical2 `"(`respiratory' | `injuries_g' | `other_physical')"'


**# Naming diseases

local dnames `"depression anxiety adjustment adhd common bipolar psychotic severe alcohol drug cannabis substance suicide_attempt any_mental retardation delays movement tic conduct_emotion neurodevelopmental respiratory asthma driver_accident non_driver_accident land_transport_accidents  accidental_falls nonintentional_firearm accidental_drowning accidental_breathing accidental_poissoning assault unintentional_injuries injuries_g infectious neoplasms blood metabolic nervous circulatory digestive genitourinary skin musculoskeletal other_physical any_physical any_physical2"'

**# Definition of age groups: all ages, childhood, adolescence, adulthood
local group `"t a b c ab"'
local t `"(DAT_SERV>=birth)"'
local a `"((DAT_SERV-birth)/365.25<12)"' 
local b `"((DAT_SERV-birth)/365.25>=12 & (DAT_SERV-birth)/365.25<18)"'
local c `"((DAT_SERV-birth)/365.25>=18)"'
local ab `"((DAT_SERV-birth)/365.25<18)"'

******

******

**# Searching cases in BDCU

use BDCU, clear

merge m:m noindiv using FIPA
drop _merge

**# STEP 1. A loop to tag diagnoses × ER visit, by age groups (NOTE: NO_EPISO_SOIN_DURG_BAN uniquely identifies the ER visit within individuals)
foreach i of local dnames	{
	foreach j of local group {
		egen tag_`i'_`j' = tag(NO_EPISO_SOIN_DURG_BAN) if ``i'' & ``j''
	}
}

save BDCU_ALL_DISAGGREGATED, replace // saved this file to explore data as time-series (other do file)

**# STEP 2. A loop to count the total number of ER visits made on different dates × diagnoses × person, by age grogups

foreach i of local dnames {
	foreach j of local group {
		by noindiv, sort: egen er_`i'_`j' = total(tag_`i'_`j')
	}		
}

**# STEP 3. A loop to tag individuals who had at least one ER visit × diagnoses, by age groups
foreach i of local dnames {
	foreach j of local group {
		by noindiv, sort: gen er1_`i'_`j' = cond(missing(er_`i'_`j'), ., cond(er_`i'_`j'>0,1,0))
	}
}


// drop tags
drop tag_*

// keep the final line per person
by noindiv, sort: drop if _n != _N

save BDCU_ALL, replace