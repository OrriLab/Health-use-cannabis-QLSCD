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

**# Medical services (RAMQ): 1. diagnoses file, then 2. merge w/services file

use serv_med_diag_40056, clear

// merge w/RAMQ services file
// the id is the billing number
merge m:m NO_FACT_BAN using serv_medicaux_40056

sort noindiv DAT_SERV

save RAMQ, replace

******

******

use RAMQ, clear

**# Detailed exploration of RAMQ ICD codes.

/* note:
In the RAMQ data linked to the ELDEQ, all diagnostic codes (ICD 9 or 10) are merged into a single variable.
There is no other variable classifying whether the ICD9 or 10 codes were used.
As such, this presents problems to properly classify E or V codes.
The following is a potential solution for this issue
*/

* Look for the first time codes starting with any letter were used:
matrix time = J(26, 1, .)
quietly {
	local j 1
	foreach i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z	{
		gen tag`i' = 1 if substr(COD_DIAG, 1, 1) == "`i'"
		sort tag DAT_SERV
		list DAT_SERV in 1
		if tag[1] != . {
			matrix time[`j', 1] = DAT_SERV[1]
		}
		local `++j'
		local rownames "`rownames' "`i'""
		drop tag*
	}
matrix rownames time = `rownames'
}
matrix list time, format(%td)

/* According to the document "Infolettre 049 / 1er mai 2020":
" Depuis juillet 2019, la RAMQ accepte les codes de diagnostic de la CIM-10 (version canadienne) lors de
la facturation de services rendus à une personne assurée."
*/

* In the ELDEQ sample, E codes were introduced in Dec 8th 2019, after the passage to the ICD-10, therefore, it is highly likely that these are indeed ICD-10 codes.

* V codes have been used since inception of the cohort. Therefore, any V code used before july 2019, will be deemed as an ICD-9 code. Further exploration of the V codes used after that date should be made.

tab COD_DIAG if substr(COD_DIAG, 1, 1) == "V" & DAT_SERV >= date("7/1/2019","MDY")

* Exclusively in ICD9: V016, V017, V018, V048, V058, V071, V157, V22, V23, V238, V24, V25, V258, V28, V40, V45, V658, V70, V708, V72, V728, V73, V788, V82, V999.

gen tag = .
foreach i in V01 V05 V016 V017 V018 V048 V058 V071 V14 V157 V22 V23 V238 V24 V25 V258 V28 V40 V45 V658 V67 V70 V708 V72 V728 V73 V75 V788 V79 V82 V999 {
	quietly replace tag = 1 if substr(COD_DIAG, 1, 4) == "`i'"
}

gen after = DAT_SERV >= date("7/1/2019","MDY")

* It can be seen that the rate of use of V codes per year increased a bit after july 2019:
tab COD_DIAG after if substr(COD_DIAG, 1, 1) == "V", matcell(V)
display 37715/((date("7/1/2019","MDY") - date("1/1/1997","MDY"))/365)
display 3867/((date("9/1/2021","MDY") - date("7/1/2019","MDY"))/365)

* V codes that were "newly" used after july 2019:
tab COD_DIAG after if substr(COD_DIAG, 1, 1) == "V" & tag == .
* V011, V163, V190, V241, V283, V420, V489, V673, V811

**# We will assume that "V" codes are only used for ICD-9. A closer look at individuals registries and cross-tabs (not shown here), where the different variables listed here: U:\40056C00\Travail\Commun\ELDEQ\Documentation ISQ\RAMQ\Services médicaux; where explored, suggests that it is very unlikely that ICD 10 V codes were used.

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

local suicide_attempt `"((substr(COD_DIAG,1,3)>="X60" & substr(COD_DIAG,1,3)<="X84") | (substr(COD_DIAG,1,4)=="Y870"))"'

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

* As ICD-9 E codes and ICD-10 V codes are not used in the RAMQ, land transport accidents will not be searched, the same with ICD-9 E codes used to define unintentional injuries.

local accidental_falls `"((substr(COD_DIAG,1,3)>="W00" & substr(COD_DIAG,1,3)<="W19"))"'

local nonintentional_firearm `"((substr(COD_DIAG,1,3)>="W32" & substr(COD_DIAG,1,3)<="W34"))"'

local accidental_drowning `"((substr(COD_DIAG,1,3)>="W65" & substr(COD_DIAG,1,3)<="W74"))"'

local accidental_breathing `"((substr(COD_DIAG,1,3)>="W44" & substr(COD_DIAG,1,3)<="W45") | (substr(COD_DIAG,1,3)>="W75" & substr(COD_DIAG,1,3)<="W84"))"'

local accidental_poissoning `"((substr(COD_DIAG,1,3)>="X40" & substr(COD_DIAG,1,3)<="X49"))"'

local assault `"((substr(COD_DIAG,1,3)>="X85" & substr(COD_DIAG,1,3)<="Y09"))"'

local unintentional_injuries `"(`accidental_falls' | `nonintentional_firearm' | `accidental_drowning' | `accidental_breathing' | `accidental_poissoning' | `assault')"'

local injuries_g `"((substr(COD_DIAG,1,3)>="800" & substr(COD_DIAG,1,3)<="995" & substr(COD_DIAG,1,4)!="9800" & substr(COD_DIAG,1,4)!="9801" & substr(COD_DIAG,1,4)!="9808" & substr(COD_DIAG,1,4)!="9809" & substr(COD_DIAG,1,4)!="9650" & substr(COD_DIAG,1,4)!="9658" & substr(COD_DIAG,1,4)!="9670" & substr(COD_DIAG,1,4)!="9676" & substr(COD_DIAG,1,4)!="9678" & substr(COD_DIAG,1,4)!="9679" & substr(COD_DIAG,1,4)!="9694" & substr(COD_DIAG,1,4)!="9695" & substr(COD_DIAG,1,4)!="9697" & substr(COD_DIAG,1,4)!="9699" & substr(COD_DIAG,1,4)!="9708" & substr(COD_DIAG,1,4)!="9820" & substr(COD_DIAG,1,4)!="9828") | (((substr(COD_DIAG,1,3)>="S00" & substr(COD_DIAG,1,3)<="T79" & substr(COD_DIAG,1,4)!="T510" & substr(COD_DIAG,1,4)!="T511" & substr(COD_DIAG,1,4)!="T518" & substr(COD_DIAG,1,4)!="T519" & substr(COD_DIAG,1,3)!="T40" & substr(COD_DIAG,1,4)!="T423" & substr(COD_DIAG,1,4)!="T424" & substr(COD_DIAG,1,4)!="T426" & substr(COD_DIAG,1,4)!="T427" & substr(COD_DIAG,1,4)!="T435" & substr(COD_DIAG,1,4)!="T436" & substr(COD_DIAG,1,4)!="T438" & substr(COD_DIAG,1,4)!="T439" & substr(COD_DIAG,1,4)!="T509" & substr(COD_DIAG,1,4)!="T528" & substr(COD_DIAG,1,4)!="T529") | (substr(COD_DIAG,1,3)>="T90" & substr(COD_DIAG,1,3)<="T98")) & ! ((substr(COD_DIAG,1,3)>="X60" & substr(COD_DIAG,1,3)<="X84") | (substr(COD_DIAG,1,4)=="Y870"))))"'

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

local dnames `"depression anxiety adjustment adhd common bipolar psychotic severe alcohol drug cannabis substance suicide_attempt any_mental retardation delays movement tic conduct_emotion neurodevelopmental respiratory asthma accidental_falls nonintentional_firearm accidental_drowning accidental_breathing accidental_poissoning assault unintentional_injuries injuries_g infectious neoplasms blood metabolic nervous circulatory digestive genitourinary skin musculoskeletal other_physical any_physical any_physical2"'

**# Definition of age groups: all ages, childhood, adolescence, adulthood
local group `"t a b c ab"'
local t `"(DAT_SERV>=birth)"'
local a `"((DAT_SERV-birth)/365.25<12)"' 
local b `"((DAT_SERV-birth)/365.25>=12 & (DAT_SERV-birth)/365.25<18)"'
local c `"((DAT_SERV-birth)/365.25>=18)"'
local ab `"((DAT_SERV-birth)/365.25<18)"'

******

******

**# Searching cases in RAMQ

use RAMQ, clear

keep noindiv COD_DIAG DAT_SERV

merge m:m noindiv using FIPA
drop _merge

/* Logic of the loop as follows:
1. for each disease, &
2. for each age group:
3. tag once per individual and date observations with selected diseases in the pre-defined age groups
*/

**# STEP 1. A loop to tag diagnoses × date of visit × person, by age groups
foreach i of local dnames	{
	foreach j of local group {
		egen tag_`i'_`j' = tag(noindiv DAT_SERV) if ``i'' & ``j''
	}
}

save RAMQ_ALL_DISAGGREGATED, replace // saved this file to explore data as time-series (other do file)

/* Logic of the loop as follows:
1. for each disease, &
2. for each age group:
3. count the total number of `tags' per individual...
Such is the definition of a "visit" - note that, therefore, visits for a given disease are counted only if they occurred on different dates
*/

* Take into account the previous explanations to understand the rest of the loops in the do-file.

**# STEP 2. A loop to count the total number of visits made on different dates × diagnoses × person, by age grogups
foreach i of local dnames {
	foreach j of local group {
		by noindiv, sort: egen vis_`i'_`j' = total(tag_`i'_`j')
	}		
}

**# STEP 3. A loop to tag individuals who had at least one visit × diagnoses, by age groups
foreach i of local dnames {
	foreach j of local group {
		by noindiv, sort: gen onev_`i'_`j' = cond(missing(vis_`i'_`j'), ., cond(vis_`i'_`j'>0,1,0))
	}
}

**# STEP 4. A loop to tag individuals who had at least two visits × selected diagnoses, by age groups
local snames `"depression anxiety adjustment adhd common retardation delays movement tic conduct_emotion neurodevelopmental respiratory asthma accidental_falls nonintentional_firearm accidental_drowning accidental_breathing accidental_poissoning assault unintentional_injuries injuries_g infectious neoplasms blood metabolic nervous circulatory digestive genitourinary skin musculoskeletal other_physical any_physical any_physical2"'
foreach i of local snames {
	foreach j of local group {
		by noindiv, sort: gen twov_`i'_`j' = cond(missing(vis_`i'_`j'), ., cond(vis_`i'_`j'>1,1,0))
	}
}

// drop tags
drop tag_*

// keep the final line per person
by noindiv, sort: drop if _n != _N

save RAMQ_ALL, replace
