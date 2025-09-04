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

**# Hospitalizations (MED-ECHO): 1. diagnoses file, then 2. merge w/services file

use me_diag_40056, clear

rename NO_SEQ_SYS_CLA NO_SEQ_SYS_CLA_diag // Classification system used for diagnoses

merge m:m NO_SEQ_SEJ_BAN using me_sejours_40056

rename NO_SEQ_SYS_CLA NO_SEQ_SYS_CLA_accid // Classification system used for accidents

rename diag COD_DIAG

// for hospitalizations, we will focus on primary and secondary diagnoses, the rest need to be dropped
drop if TYP_DIAG!="P" & TYP_DIAG!="S"

sort noindiv DAT_ADMIS

save HOSPITAL, replace

******

******

use HOSPITAL, clear

**# Exploration of MED-ECHO ICD codes.

/* note:
In the MED-ECHO data linked to the ELDEQ, all diagnostic codes (ICD 9 or 10) are merged into a couple of variables - each one for "accidents" and "diagnostics".
There are a couple of variables classifying whether the ICD9 or 10 codes were used.
*/

* Check times each classification was used per first digit of the code: first diagnostics, then accidents
gen diag_digit = substr(COD_DIAG, 1, 1)
tab diag_digit NO_SEQ_SYS_CLA_diag
gen accid_digit = substr(diag_cause_accid, 1, 1)
tab accid_digit NO_SEQ_SYS_CLA_accid

* When using ICD-10 codes for diagnoses ("diag" variable), we would need to add the condition that NO_SEQ_SYS_CLA_diag == "1" (i.e., this is indeed an ICD-10 code) when extracting V codes.

* In the case of accidents, this will not be needed.

******

******

**# Basic definition of locals: diseases, names, and age groups

**# Definition of mental & substance-related disorders

local depression `"((substr(COD_DIAG,1,4)=="3004") | (substr(COD_DIAG,1,3)=="311") | (substr(COD_DIAG,1,3)=="F32") | (substr(COD_DIAG,1,3)=="F33") | (substr(COD_DIAG,1,4)=="F341") | (substr(COD_DIAG,1,4)=="F348") | (substr(COD_DIAG,1,4)=="F349") | (substr(COD_DIAG,1,3)=="F38") | (substr(COD_DIAG,1,3)=="F39") | (substr(COD_DIAG,1,4)=="F412"))"'

local anxiety `"((substr(COD_DIAG,1,3)=="300" & substr(COD_DIAG,1,4)!="3004") | (substr(COD_DIAG,1,3)=="F40") | (substr(COD_DIAG,1,3)=="F41" & substr(COD_DIAG,1,4)!="F412") | (substr(COD_DIAG,1,3)=="F42") | (substr(COD_DIAG,1,3)=="F45") | (substr(COD_DIAG,1,3)=="F48"))"'

local adjustment `"((substr(COD_DIAG,1,3)=="309") | (substr(COD_DIAG,1,3)=="F43"))"'

local common `"(`depression' | `anxiety' | `adjustment')"'

local adhd `"((substr(COD_DIAG,1,3)=="314") | (substr(COD_DIAG,1,3)=="F90"))"'

local bipolar `"((substr(COD_DIAG,1,3)=="296") | (substr(COD_DIAG,1,3)=="F30") | (substr(COD_DIAG,1,3)=="F31") | (substr(COD_DIAG,1,4)=="F340"))"'

local psychotic `"((substr(COD_DIAG,1,3)=="295") | (substr(COD_DIAG,1,3)=="297") | (substr(COD_DIAG,1,3)=="298" & substr(COD_DIAG,1,4)!="2982") | (substr(COD_DIAG,1,3)=="F20") | (substr(COD_DIAG,1,3)=="F21") | (substr(COD_DIAG,1,3)=="F22") | (substr(COD_DIAG,1,3)=="F23") | (substr(COD_DIAG,1,3)=="F24") | (substr(COD_DIAG,1,3)=="F25") | (substr(COD_DIAG,1,3)=="F28") | (substr(COD_DIAG,1,3)=="F29"))"'

local severe `"(`bipolar' | `psychotic')"'

local alcohol `"((substr(COD_DIAG,1,3)=="303") | (substr(COD_DIAG,1,4)=="3050") | (substr(COD_DIAG,1,3)=="291") | (substr(COD_DIAG,1,4)=="3575") | (substr(COD_DIAG,1,4)=="4255") | (substr(COD_DIAG,1,4)=="5353") | (substr(COD_DIAG,1,4)>="5710" & substr(COD_DIAG,1,4)<="5713") | (substr(COD_DIAG,1,4)=="9800") | (substr(COD_DIAG,1,4)=="9801") | (substr(COD_DIAG,1,4)=="9808") | (substr(COD_DIAG,1,4)=="9809") | (substr(COD_DIAG,1,4)>="F101" & substr(COD_DIAG,1,4)<="F109") | (substr(COD_DIAG,1,4)>="K700" & substr(COD_DIAG,1,4)<="K704") | (substr(COD_DIAG,1,4)=="K709") | (substr(COD_DIAG,1,4)=="G621") | (substr(COD_DIAG,1,4)=="I426") | (substr(COD_DIAG,1,4)=="K292") | (substr(COD_DIAG,1,4)=="K852") | (substr(COD_DIAG,1,4)=="K860") | (substr(COD_DIAG,1,4)=="E244") | (substr(COD_DIAG,1,4)=="G312") | (substr(COD_DIAG,1,4)=="G721") | (substr(COD_DIAG,1,4)=="O354") | (substr(COD_DIAG,1,4)=="F100") | (substr(COD_DIAG,1,4)=="T510") | (substr(COD_DIAG,1,4)=="T511") | (substr(COD_DIAG,1,4)=="T518") | (substr(COD_DIAG,1,4)=="T519"))"'

local drug `"((substr(COD_DIAG,1,3)=="292") | (substr(COD_DIAG,1,3)=="304" & substr(COD_DIAG,1,4)!="3043") | (substr(COD_DIAG,1,4)>="3053" & substr(COD_DIAG,1,4)<="3057") | (substr(COD_DIAG,1,4)=="9650") | (substr(COD_DIAG,1,4)=="9658") | (substr(COD_DIAG,1,4)=="9670") | (substr(COD_DIAG,1,4)=="9676") | (substr(COD_DIAG,1,4)=="9678") | (substr(COD_DIAG,1,4)=="9679") | (substr(COD_DIAG,1,4)=="9694") | (substr(COD_DIAG,1,4)=="9695") | (substr(COD_DIAG,1,4)=="9697") | (substr(COD_DIAG,1,4)=="9699") | (substr(COD_DIAG,1,4)=="9708") | (substr(COD_DIAG,1,4)=="9820") | (substr(COD_DIAG,1,4)=="9828") | (substr(COD_DIAG,1,4)>="F111" & substr(COD_DIAG,1,4)<="F114") | (substr(COD_DIAG,1,4)=="F116") | (substr(COD_DIAG,1,4)=="F118") | (substr(COD_DIAG,1,4)=="F119") | (substr(COD_DIAG,1,4)>="F131" & substr(COD_DIAG,1,4)<="F134") | (substr(COD_DIAG,1,4)=="F136") | (substr(COD_DIAG,1,4)=="F138") | (substr(COD_DIAG,1,4)=="F139") | (substr(COD_DIAG,1,4)>="F141" & substr(COD_DIAG,1,4)<="F144") | (substr(COD_DIAG,1,4)=="F146") | (substr(COD_DIAG,1,4)=="F148") | (substr(COD_DIAG,1,4)=="F149") | (substr(COD_DIAG,1,4)>="F151" & substr(COD_DIAG,1,4)<="F154") | (substr(COD_DIAG,1,4)=="F156") | (substr(COD_DIAG,1,4)=="F158") | (substr(COD_DIAG,1,4)=="F159") | (substr(COD_DIAG,1,4)>="F161" & substr(COD_DIAG,1,4)<="F164") | (substr(COD_DIAG,1,4)=="F166") | (substr(COD_DIAG,1,4)=="F168") | (substr(COD_DIAG,1,4)=="F169") | (substr(COD_DIAG,1,4)>="F181" & substr(COD_DIAG,1,4)<="F184") | (substr(COD_DIAG,1,4)=="F186") | (substr(COD_DIAG,1,4)=="F188") | (substr(COD_DIAG,1,4)=="F189") | (substr(COD_DIAG,1,4)>="F191" & substr(COD_DIAG,1,4)<="F194") | (substr(COD_DIAG,1,4)=="F196") | (substr(COD_DIAG,1,4)=="F198") | (substr(COD_DIAG,1,4)=="F199") | (substr(COD_DIAG,1,4)>="T400" & substr(COD_DIAG,1,4)<="T409" & substr(COD_DIAG,1,4)!="T407") | (substr(COD_DIAG,1,4)=="T423") | (substr(COD_DIAG,1,4)=="T424") | (substr(COD_DIAG,1,4)=="T426") | (substr(COD_DIAG,1,4)=="T427") | (substr(COD_DIAG,1,4)=="T435") | (substr(COD_DIAG,1,4)=="T436") | (substr(COD_DIAG,1,4)=="T438") | (substr(COD_DIAG,1,4)=="T439") | (substr(COD_DIAG,1,4)=="T509") | (substr(COD_DIAG,1,4)=="T528") | (substr(COD_DIAG,1,4)=="T529") | (substr(COD_DIAG,1,4)=="F115") | (substr(COD_DIAG,1,4)=="F117") | (substr(COD_DIAG,1,4)=="F135") | (substr(COD_DIAG,1,4)=="F137") | (substr(COD_DIAG,1,4)=="F145") | (substr(COD_DIAG,1,4)=="F147") | (substr(COD_DIAG,1,4)=="F155") | (substr(COD_DIAG,1,4)=="F157") | (substr(COD_DIAG,1,4)=="F165") | (substr(COD_DIAG,1,4)=="F167") | (substr(COD_DIAG,1,4)=="F185") | (substr(COD_DIAG,1,4)=="F187") | (substr(COD_DIAG,1,4)=="F195") | (substr(COD_DIAG,1,4)=="F197"))"'

local cannabis `"((substr(COD_DIAG,1,4)=="3043") | (substr(COD_DIAG,1,4)=="3052") | (substr(COD_DIAG,1,3)=="F12") | (substr(COD_DIAG,1,4)=="T407"))"'

local substance `"(`alcohol' | `drug' | `cannabis')"'

local suicide_attempt `"((substr(COD_DIAG,1,3)>="X60" & substr(COD_DIAG,1,3)<="X84") | (substr(COD_DIAG,1,4)=="Y870") | (substr(diag_cause_accid,1,3)=="950"))"' // diag_cause_accid stores information on external causes of traumatisms, the letter E has been removed.

local any_mental `"(`common' | `severe' | `substance')"'

local retardation `"((substr(COD_DIAG,1,3)=="317") | (substr(COD_DIAG,1,3)=="318") | (substr(COD_DIAG,1,3)=="319") | (substr(COD_DIAG,1,3)=="F70") | (substr(COD_DIAG,1,3)=="F71") | (substr(COD_DIAG,1,3)=="F72") | (substr(COD_DIAG,1,3)=="F73") | (substr(COD_DIAG,1,3)=="F78") | (substr(COD_DIAG,1,3)=="F79"))"'

local delays `"((substr(COD_DIAG,1,3)=="315") | (substr(COD_DIAG,1,3)=="299") | (substr(COD_DIAG,1,3)=="F80") | (substr(COD_DIAG,1,3)=="F81") | (substr(COD_DIAG,1,3)=="F82") | (substr(COD_DIAG,1,3)=="F83") | (substr(COD_DIAG,1,3)=="F84") | (substr(COD_DIAG,1,3)=="F88") | (substr(COD_DIAG,1,3)=="F89"))"'

local movement `"((substr(COD_DIAG,1,4)=="3073") | (substr(COD_DIAG,1,4)=="F984"))"'

local tic `"((substr(COD_DIAG,1,4)=="3072") | (substr(COD_DIAG,1,3)=="F95"))"'

local conduct_emotion `"((substr(COD_DIAG,1,3)=="312") | (substr(COD_DIAG,1,3)=="313") | (substr(COD_DIAG,1,3)=="F91") | (substr(COD_DIAG,1,3)=="F92") | (substr(COD_DIAG,1,3)=="F93") | (substr(COD_DIAG,1,4)=="F941") | (substr(COD_DIAG,1,4)=="F942") | (substr(COD_DIAG,1,4)=="F948") | (substr(COD_DIAG,1,4)=="F949"))"'

local neurodevelopmental `"(`retardation' | `delays' | `movement' | `tic' | `adhd')"'

**# Definition of physical diseases

local respiratory `"((substr(COD_DIAG,1,2)>="46" & substr(COD_DIAG,1,2)<="51") | (substr(COD_DIAG,1,1)=="J"))"'

local asthma `"((substr(COD_DIAG,1,3)=="493") | (substr(COD_DIAG,1,3)=="J45"))"'

local driver_accident `"((substr(diag_cause_accid,1,3)>="800" & substr(diag_cause_accid,1,3)<="807" & (substr(diag_cause_accid,4,1)=="0" | substr(diag_cause_accid,4,1)=="3")) | (substr(diag_cause_accid,1,3)>="810" & substr(diag_cause_accid,1,3)<="826" & (substr(diag_cause_accid,4,1)=="0" | substr(diag_cause_accid,4,1)=="2" | substr(diag_cause_accid,4,1)=="6")) | (substr(diag_cause_accid,1,3)>="827" & substr(diag_cause_accid,1,3)<="829" & (substr(diag_cause_accid,4,1)=="1" | substr(diag_cause_accid,4,1)=="2")) | (((substr(COD_DIAG,1,3)>="V10" & substr(COD_DIAG,1,3)<="V79" & (substr(COD_DIAG,4,1)=="0" | substr(COD_DIAG,4,1)=="4")) | (substr(COD_DIAG,1,3)>="V83" & substr(COD_DIAG,1,3)<="V86" & (substr(COD_DIAG,4,1)=="0" | substr(COD_DIAG,4,1)=="5"))) & NO_SEQ_SYS_CLA_diag=="1") | (((substr(diag_cause_accid,1,3)>="V10" & substr(diag_cause_accid,1,3)<="V79" & (substr(diag_cause_accid,4,1)=="0" | substr(diag_cause_accid,4,1)=="4")) | (substr(diag_cause_accid,1,3)>="V83" & substr(diag_cause_accid,1,3)<="V86" & (substr(diag_cause_accid,4,1)=="0" | substr(diag_cause_accid,4,1)=="5"))) & NO_SEQ_SYS_CLA_accid=="1"))"' // diag_cause_accid stores information on external causes of traumatisms, the letter E has been removed.

local non_driver_accident `"((substr(diag_cause_accid,1,3)>="800" & substr(diag_cause_accid,1,3)<="807" & (substr(diag_cause_accid,4,1)!="0" | substr(diag_cause_accid,4,1)!="3")) | (substr(diag_cause_accid,1,3)>="810" & substr(diag_cause_accid,1,3)<="826" & (substr(diag_cause_accid,4,1)!="0" | substr(diag_cause_accid,4,1)!="2" | substr(diag_cause_accid,4,1)!="6")) | (substr(diag_cause_accid,1,3)>="827" & substr(diag_cause_accid,1,3)<="829" & (substr(diag_cause_accid,4,1)!="1" | substr(diag_cause_accid,4,1)!="2")) | (((substr(COD_DIAG,1,3)>="V01" & substr(COD_DIAG,1,3)<="V09") | (substr(COD_DIAG,1,3)>="V80" & substr(COD_DIAG,1,3)<="V82") | (substr(COD_DIAG,1,3)>="V10" & substr(COD_DIAG,1,3)<="V79" & (substr(COD_DIAG,4,1)!="0" | substr(COD_DIAG,4,1)!="4")) | (substr(COD_DIAG,1,3)>="V83" & substr(COD_DIAG,1,3)<="V86" & (substr(COD_DIAG,4,1)!="0" | substr(COD_DIAG,4,1)!="5"))) & NO_SEQ_SYS_CLA_diag=="1") | (((substr(diag_cause_accid,1,3)>="V01" & substr(diag_cause_accid,1,3)<="V09") | (substr(diag_cause_accid,1,3)>="V80" & substr(diag_cause_accid,1,3)<="V82") | (substr(diag_cause_accid,1,3)>="V10" & substr(diag_cause_accid,1,3)<="V79" & (substr(diag_cause_accid,4,1)!="0" | substr(diag_cause_accid,4,1)!="4")) | (substr(diag_cause_accid,1,3)>="V83" & substr(diag_cause_accid,1,3)<="V86" & (substr(diag_cause_accid,4,1)!="0" | substr(diag_cause_accid,4,1)!="5"))) & NO_SEQ_SYS_CLA_accid=="1"))"' // diag_cause_accid stores information on external causes of traumatisms, the letter E has been removed.

local land_transport_accidents `"(`driver_accident' | `non_driver_accident')"'

local accidental_falls `"((substr(diag_cause_accid,1,3)>="880" & substr(diag_cause_accid,1,3)<="888") | (substr(COD_DIAG,1,3)>="W00" & substr(COD_DIAG,1,3)<="W19") | (substr(diag_cause_accid,1,3)>="W00" & substr(diag_cause_accid,1,3)<="W19"))"'

local nonintentional_firearm `"((substr(diag_cause_accid,1,3)=="922") | (substr(COD_DIAG,1,3)>="W32" & substr(COD_DIAG,1,3)<="W34") | (substr(diag_cause_accid,1,3)>="W32" & substr(diag_cause_accid,1,3)<="W34"))"'

local accidental_drowning `"((substr(diag_cause_accid,1,3)=="830") | (substr(diag_cause_accid,1,3)=="832") | (substr(diag_cause_accid,1,3)=="910") | (substr(COD_DIAG,1,3)>="W65" & substr(COD_DIAG,1,3)<="W74") | ((substr(COD_DIAG,1,3)>="V90" & substr(COD_DIAG,1,3)<="V92") & NO_SEQ_SYS_CLA_diag=="1") | (substr(diag_cause_accid,1,3)>="W65" & substr(diag_cause_accid,1,3)<="W74") | ((substr(diag_cause_accid,1,3)>="V90" & substr(diag_cause_accid,1,3)<="V92") & NO_SEQ_SYS_CLA_diag=="1"))"'

local accidental_breathing `"((substr(diag_cause_accid,1,3)>="911" & substr(diag_cause_accid,1,3)<="915") | (substr(COD_DIAG,1,3)>="W44" & substr(COD_DIAG,1,3)<="W45") | (substr(COD_DIAG,1,3)>="W75" & substr(COD_DIAG,1,3)<="W84") | (substr(diag_cause_accid,1,3)>="W44" & substr(diag_cause_accid,1,3)<="W45") | (substr(diag_cause_accid,1,3)>="W75" & substr(diag_cause_accid,1,3)<="W84"))"'

local accidental_poissoning `"((substr(diag_cause_accid,1,3)>="850" & substr(diag_cause_accid,1,3)<="869") | (substr(COD_DIAG,1,3)>="X40" & substr(COD_DIAG,1,3)<="X49") | (substr(diag_cause_accid,1,3)>="X40" & substr(diag_cause_accid,1,3)<="X49"))"'

local assault `"((substr(diag_cause_accid,1,3)>="960" & substr(diag_cause_accid,1,3)<="969") | (substr(COD_DIAG,1,3)>="X85" & substr(COD_DIAG,1,3)<="Y09") | (substr(diag_cause_accid,1,3)>="X85" & substr(diag_cause_accid,1,3)<="Y09"))"'

local unintentional_injuries `"(`land_transport_accidents' | `accidental_falls' | `nonintentional_firearm' | `accidental_drowning' | `accidental_breathing' | `accidental_poissoning' | `assault')"'

local injuries_g `"(((substr(COD_DIAG,1,3)>="800" & substr(COD_DIAG,1,3)<="995" & substr(COD_DIAG,1,4)!="9800" & substr(COD_DIAG,1,4)!="9801" & substr(COD_DIAG,1,4)!="9808" & substr(COD_DIAG,1,4)!="9809" & substr(COD_DIAG,1,4)!="9650" & substr(COD_DIAG,1,4)!="9658" & substr(COD_DIAG,1,4)!="9670" & substr(COD_DIAG,1,4)!="9676" & substr(COD_DIAG,1,4)!="9678" & substr(COD_DIAG,1,4)!="9679" & substr(COD_DIAG,1,4)!="9694" & substr(COD_DIAG,1,4)!="9695" & substr(COD_DIAG,1,4)!="9697" & substr(COD_DIAG,1,4)!="9699" & substr(COD_DIAG,1,4)!="9708" & substr(COD_DIAG,1,4)!="9820" & substr(COD_DIAG,1,4)!="9828") & (substr(diag_cause_accid,1,3)!="950")) | (((substr(COD_DIAG,1,3)>="S00" & substr(COD_DIAG,1,3)<="T79" & substr(COD_DIAG,1,4)!="T510" & substr(COD_DIAG,1,4)!="T511" & substr(COD_DIAG,1,4)!="T518" & substr(COD_DIAG,1,4)!="T519" & substr(COD_DIAG,1,3)!="T40" & substr(COD_DIAG,1,4)!="T423" & substr(COD_DIAG,1,4)!="T424" & substr(COD_DIAG,1,4)!="T426" & substr(COD_DIAG,1,4)!="T427" & substr(COD_DIAG,1,4)!="T435" & substr(COD_DIAG,1,4)!="T436" & substr(COD_DIAG,1,4)!="T438" & substr(COD_DIAG,1,4)!="T439" & substr(COD_DIAG,1,4)!="T509" & substr(COD_DIAG,1,4)!="T528" & substr(COD_DIAG,1,4)!="T529") | (substr(COD_DIAG,1,3)>="T90" & substr(COD_DIAG,1,3)<="T98")) & ! ((substr(COD_DIAG,1,3)>="X60" & substr(COD_DIAG,1,3)<="X84") | (substr(COD_DIAG,1,4)=="Y870"))))"'

local infectious `"((substr(COD_DIAG,1,3)>="000" & substr(COD_DIAG,1,3)<="139") | (substr(COD_DIAG,1,1)=="A") | (substr(COD_DIAG,1,1)=="B") | (substr(COD_DIAG,1,3)=="U04"))"'

local neoplasms `"((substr(COD_DIAG,1,2)>="14" & substr(COD_DIAG,1,2)<="23") | (substr(COD_DIAG,1,1)=="C") | (substr(COD_DIAG,1,2)=="D0") | (substr(COD_DIAG,1,2)=="D1") | (substr(COD_DIAG,1,2)=="D2") | (substr(COD_DIAG,1,2)=="D3") | (substr(COD_DIAG,1,2)=="D4"))"'

local blood `"((substr(COD_DIAG,1,3)>="279" & substr(COD_DIAG,1,3)<="289") | (substr(COD_DIAG,1,3)>="D50" & substr(COD_DIAG,1,3)<="D89"))"'

local metabolic `"((substr(COD_DIAG,1,2)>="24" & substr(COD_DIAG,1,3)<="278") | (substr(COD_DIAG,1,3)>="E00" & substr(COD_DIAG,1,3)<="E90" & substr(COD_DIAG,1,4)!="E244"))"'

local nervous `"((substr(COD_DIAG,1,3)>="320" & substr(COD_DIAG,1,3)<="389" & substr(COD_DIAG,1,4)!="3575") | (substr(COD_DIAG,1,3)>="G00" & substr(COD_DIAG,1,3)<="G99" & substr(COD_DIAG,1,4)!="G621" & substr(COD_DIAG,1,4)!="G312" & substr(COD_DIAG,1,4)!="G721") | (substr(COD_DIAG,1,3)>="H00" & substr(COD_DIAG,1,3)<="H95"))"'

local circulatory `"((substr(COD_DIAG,1,2)>="39" & substr(COD_DIAG,1,2)<="45" & substr(COD_DIAG,1,4)!="4255") | (substr(COD_DIAG,1,1)=="I" & substr(COD_DIAG,1,4)!="I426"))"'

local digestive `"((substr(COD_DIAG,1,2)>="52" & substr(COD_DIAG,1,2)<="57" & substr(COD_DIAG,1,4)!="5353" & substr(COD_DIAG,1,4)!="5710" & substr(COD_DIAG,1,4)!="5711" & substr(COD_DIAG,1,4)!="5712" & substr(COD_DIAG,1,4)!="5713") | (substr(COD_DIAG,1,1)=="K" & substr(COD_DIAG,1,4)!="K292" & substr(COD_DIAG,1,4)!="K700" & substr(COD_DIAG,1,4)!="K701" & substr(COD_DIAG,1,4)!="K702" & substr(COD_DIAG,1,4)!="K703" & substr(COD_DIAG,1,4)!="K704" & substr(COD_DIAG,1,4)!="K709" & substr(COD_DIAG,1,4)!="K852" & substr(COD_DIAG,1,4)!="K860"))"'

local genitourinary `"((substr(COD_DIAG,1,2)>="58" & substr(COD_DIAG,1,2)<="62") | (substr(COD_DIAG,1,1)=="N"))"'

local skin `"((substr(COD_DIAG,1,2)>="68" & substr(COD_DIAG,1,2)<="70") | (substr(COD_DIAG,1,1)=="L"))"'

local musculoskeletal `"((substr(COD_DIAG,1,2)>="71" & substr(COD_DIAG,1,2)<="73") | (substr(COD_DIAG,1,1)=="M"))"'

local other_physical `"(`infectious' | `neoplasms' | `blood' | `metabolic' | `nervous' | `circulatory' | `digestive' | `genitourinary' | `skin' | `musculoskeletal')"'

local any_physical `"(`respiratory' | `unintentional_injuries' | `other_physical')"'

local any_physical2 `"(`respiratory' | `injuries_g' | `other_physical')"'


**# Naming diseases

local dnames `"depression anxiety adjustment adhd common bipolar psychotic severe alcohol drug cannabis substance suicide_attempt any_mental retardation delays movement tic conduct_emotion neurodevelopmental respiratory asthma driver_accident non_driver_accident land_transport_accidents  accidental_falls nonintentional_firearm accidental_drowning accidental_breathing accidental_poissoning assault unintentional_injuries injuries_g infectious neoplasms blood metabolic nervous circulatory digestive genitourinary skin musculoskeletal other_physical any_physical any_physical2"'

**# Definition of age groups: all ages, childhood, adolescence, adulthood
local group `"t a b c ab"'
local t `"(DAT_ADMIS>=birth)"'
local a `"((DAT_ADMIS-birth)/365.25<12)"' 
local b `"((DAT_ADMIS-birth)/365.25>=12 & (DAT_ADMIS-birth)/365.25<18)"'
local c `"((DAT_ADMIS-birth)/365.25>=18)"'
local ab `"((DAT_ADMIS-birth)/365.25<18)"'

******

******

**# Searching cases in MED-ECHO

use HOSPITAL, clear

keep noindiv NO_SEQ_SEJ_BAN COD_DIAG DAT_ADMIS NO_SEQ_SYS_CLA_diag diag_cause_accid NO_SEQ_SYS_CLA_accid

merge m:m noindiv using FIPA
drop _merge

**# STEP 1. A loop to tag diagnoses × hospital stay, by age groups (NOTE: NO_SEQ_SEJ_BAN uniquely identifies the hospital stay within individuals)
foreach i of local dnames	{
	foreach j of local group {
		egen tag_`i'_`j' = tag(NO_SEQ_SEJ_BAN) if ``i'' & ``j''
	}
}

save HOSP_ALL_DISAGGREGATED, replace // saved this file to explore data as time-series (other do file)

**# STEP 2. A loop to count the total number of hospitalizations made on different dates × diagnoses × person, by age grogups

foreach i of local dnames {
	foreach j of local group {
		by noindiv, sort: egen hosp_`i'_`j' = total(tag_`i'_`j')
	}		
}


**# STEP 3. A loop to tag individuals who had at least one visit × diagnoses, by age groups
foreach i of local dnames {
	foreach j of local group {
		by noindiv, sort: gen oneh_`i'_`j' = cond(missing(hosp_`i'_`j'), ., cond(hosp_`i'_`j'>0,1,0))
	}
}


// drop tags
drop tag_*

// keep the final line per person
by noindiv, sort: drop if _n != _N

save HOSPITAL_ALL, replace
