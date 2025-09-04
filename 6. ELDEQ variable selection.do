cd // this line sets the working directory to where this do-file is stored!

* Variable selection

**# Reported by children (QIE, QELJ, ENFAN files): ID, age, substance use

// comment: sex (at birth) will be extracted from the FIPA

use qie1301, clear

keep noindiv MHDNQ1 MHDNQ4 MHDNQ6 MHDNQ7 MHDNQ9 MHDNQ10A MHDNQ10B MHDNQ10C MHDNQ10D MHDNQ10E MHDNQ10F MHDNQ10G

save ELDEQ, replace

//

use enfan1301, clear

keep noindiv MAGED02

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use qie1401, clear

keep noindiv NHDNQ1 NHDNQ4 NHDNQ6 NHDNQ7 NHDNQ9 NHDNQ10A NHDNQ10B NHDNQ10C NHDNQ10D NHDNQ10E NHDNQ10F NHDNQ10G

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use enfan1401, clear

keep noindiv NAGED02

merge 1:1 noindiv using ELDEQ

drop _merge

order N*, last

save ELDEQ, replace

//

use qelj1601, clear

keep noindiv PHDNQ1 PHDNQ4 PHDNQ6 PHDNQ7 PHDNQ9 PHDNQ10A PHDNQ10B PHDN10CA PHDN10DA PHDN10EA PHDN10FA PHDN10GA

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use enfan1601, clear

keep noindiv PAGED02

merge 1:1 noindiv using ELDEQ

drop _merge

order P*, last

save ELDEQ, replace

//

use qelj1801f, clear

keep noindiv RHDNQ1 RHDNQ4 RHDNQ6 RHDNQ7 RHDNQ9 RHDNQ10A RHDNQ10B RHDN10CA RHDN10DA RHDN10EA RHDN10FA RHDN10GA

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use enfan1801, clear

keep noindiv RAGED02

merge 1:1 noindiv using ELDEQ

drop _merge

order R*, last

save ELDEQ, replace

**# Derived variables (INDI files): parental practices, mom/dad/family characteristics, infant behavior

use indi101, clear

keep noindiv APRET01 aagmd01 ASDMD4AA ADPMT01 ASDJD4AA ADPJT01 AINFD09 afafd02 AFNFT01 ASFFL01A ASFFL01B

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use indi201, clear

keep noindiv BPRET01 BDPMT01 BINFD09 BFNFT01

merge 1:1 noindiv using ELDEQ

drop _merge

order B*, after(AINFD09)

save ELDEQ, replace

//

use indi301, clear

keep noindiv CPRET01 CPRET01C CPRET01B CINFD09 CSFFL01A CSFFL01B

merge 1:1 noindiv using ELDEQ

drop _merge

order C*, after(BINFD09)

save ELDEQ, replace

//

use indi401, clear

keep noindiv DPRET01 DPRET01C DPRET01B DDPMT01 DINFD09

merge 1:1 noindiv using ELDEQ

drop _merge

order D*, after(CINFD09)

save ELDEQ, replace

//

use indi501, clear

keep noindiv EPRET01 EPRET01C EPRET01B ESFFL01A ESFFL01B

merge 1:1 noindiv using ELDEQ

drop _merge

order E*, after(DINFD09)

save ELDEQ, replace

//

use indi601, clear

keep noindiv FPRET01 FPRET01C FPRET01B FDPMT01 FQMMT06 FQPJT06 FINFD09

merge 1:1 noindiv using ELDEQ

drop _merge

order F*, after(ESFFL01B)

save ELDEQ, replace

//

use indi701, clear

keep noindiv GPRET01 GPRET01C GPRET01B GINFD09 GFNFT01 GSFFL01A GSFFL01B

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use indi711, clear

keep noindiv GBEET05C GBEET05D GBEET05F GBEET05H GBEET05O GBEET05Q GAEET04 GQEET01

merge 1:1 noindiv using ELDEQ

drop _merge

order G*, after(FINFD09)

save ELDEQ, replace

//

use indi801, clear

keep noindiv HDPMT01 HINFD09

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use indi811, clear

keep noindiv HBEET05C HBEET05D HBEET05F HBEET05H HBEET05O HBEET05Q HAEET04 HQEET01

merge 1:1 noindiv using ELDEQ

drop _merge

order H*, after(GINFD09)

save ELDEQ, replace

//

use indi901, clear

keep noindiv IPRET01 IPRET01C IPRET01B IINFD09 ISFFL01A ISFFL01B

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use indi911, clear

keep noindiv IBEET05C IBEET05D IBEET05F IBEET05H IBEET05O IBEET05Q IAEET04 IQEET01

merge 1:1 noindiv using ELDEQ

drop _merge

order I*, after(HINFD09)

save ELDEQ, replace

//

use indi1101, clear

keep noindiv KPRET01 KPRET01C KPRET01B KDPMT01 KINFD09 KSFFL01A KSFFL01B

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use enfan1101, clear

keep noindiv KPREQ28B KPREQ33A KPREQ33B KPREQ33C KPREQ33D

merge 1:1 noindiv using ELDEQ

drop _merge

save ELDEQ, replace

//

use indi1111, clear

keep noindiv KBEET05C KBEET05D KBEET05F KBEET05H KBEET05O KBEET05Q KAEET04 KQEET10 KQEET14 KQEET01

merge 1:1 noindiv using ELDEQ

drop _merge

order K*, after(IINFD09)

save ELDEQ, replace

**# Tests applied to children (JEUX files): Child's cognitive skills

use enfan401, clear

keep noindiv deves01

merge 1:1 noindiv using ELDEQ

drop _merge

order D* d*, after(CINFD09)

save ELDEQ, replace

//

use jeux601, clear

keep noindiv FEVES01

merge 1:1 noindiv using ELDEQ

drop _merge

order FEVES01, after(FINFD09)

save ELDEQ, replace

//

use jeux701, clear

keep noindiv GEVES01

merge 1:1 noindiv using ELDEQ

drop _merge

order GEVES01, after(GINFD09)

save ELDEQ, replace

//

use jeux1101, clear

keep noindiv KEVES01

merge 1:1 noindiv using ELDEQ

drop _merge

order KEVES01, after(KINFD09)

save ELDEQ, replace

**# Reported by mom/dad/PCM (ENFAN, PERE, MERE, PCM files): substance use in parents

use enfan101, clear

keep noindiv amdeq03 amdeq06 amdeq11a

merge 1:1 noindiv using ELDEQ

drop _merge

order amd*, after(AINFD09)

save ELDEQ, replace

//

use mere101, clear

keep noindiv ahlmq02 ahlmq04 ahlmq05 ahlmq07a

merge 1:1 noindiv using ELDEQ

drop _merge

order ahlmq*, after(amdeq11a)

save ELDEQ, replace

//

use mere201, clear

keep noindiv BHLMQ02 BHLMQ04 BHLMQ05 BHLMQ07A

merge 1:1 noindiv using ELDEQ

drop _merge

order BHLM*, after(BINFD09)

save ELDEQ, replace

//

use mere301, clear

keep noindiv CHLMQ02 CHLMQ04 CHLMQ05 CHLMQ07A

merge 1:1 noindiv using ELDEQ

drop _merge

order CHLM*, after(CINFD09)

save ELDEQ, replace

//

use mere401, clear

keep noindiv DHLMQ02 DHLMQ05 DHLMQ07A

merge 1:1 noindiv using ELDEQ

drop _merge

order DHLM*, after(DINFD09)

save ELDEQ, replace

//

use pere101, clear

keep noindiv ahljq02 ahljq04 ahljq05 ahljq07a

merge 1:1 noindiv using ELDEQ

drop _merge

order ahljq*, after(ahlmq07a)

save ELDEQ, replace

//

use pere201, clear

keep noindiv BHLJQ02 BHLJQ04 BHLJQ05 BHLJQ07A

merge 1:1 noindiv using ELDEQ

drop _merge

order BHLJ*, after(BHLMQ07A)

save ELDEQ, replace

//

use pere301, clear

keep noindiv CHLJQ02 CHLJQ04 CHLJQ05 CHLJQ07A

merge 1:1 noindiv using ELDEQ

drop _merge

order CHLJ*, after(CHLMQ07A)

save ELDEQ, replace

//

use pere401, clear

keep noindiv DHLJQ02 DHLJQ05 DHLJQ07A

merge 1:1 noindiv using ELDEQ

drop _merge

order DHLJ*, after(DHLMQ07A)

save ELDEQ, replace

//

use pcm501, clear

keep noindiv EHLFQ2A3 EHLFQ2A4

merge 1:1 noindiv using ELDEQ

drop _merge

order EHLF*, after(ESFFL01B)

save ELDEQ, replace

//

use pcm701, clear

keep noindiv GHLFQ2A3 GHLFQ2A4

merge 1:1 noindiv using ELDEQ

drop _merge

order GHLF*, after(GEVES01)

save ELDEQ, replace

//

use pcm901, clear

keep noindiv IHLFQ2A3 IHLFQ2A4

merge 1:1 noindiv using ELDEQ

drop _merge

order IHLF*, after(IINFD09)

save ELDEQ, replace

//

**# Reported by teacher (QAAENS file): academic performance

use qaaens801, clear

keep noindiv HAEIQ04

merge 1:1 noindiv using ELDEQ

drop _merge

order HAEIQ04, after(HINFD09)

save ELDEQ, replace

//

use qaaens901, clear

keep noindiv IAEIQ04

merge 1:1 noindiv using ELDEQ

drop _merge

order IAEIQ04, after(IHLFQ2A4)

save ELDEQ, replace

//

use qaaens1101, clear

keep noindiv KAEIQ04

merge 1:1 noindiv using ELDEQ

drop _merge

order KAEIQ04, after(KEVES01)

save ELDEQ, replace
