cd // this line sets the working directory to where this do-file is stored!

* QUICK EXPLORATION OF MERGED AGGREGATED ADMIN DATA

use ADMIN_FINAL_DETAILED, clear

drop accidental*
drop nonintentional* assault* unintentional*
drop any_physical_*
drop driver*
drop *driver*
drop land_transport*

tab1 *_1_a *_1_c *_1_t *_ao

tab1 *_1_b 

**# A syntax to check data as a time series - aggregated per date (age)

use RAMQ_ALL_DISAGGREGATED, clear

sort noindiv DAT_SERV

gen age = DAT_SERV-birth

drop *accidental*
drop *nonintentional* *assault* *unintentional*
drop *any_physical_*

collapse (sum) tag_*_t, by(age)

rename tag_*_t *

tsset age

foreach var of varlist depression-any_physical2 {
                gen `var'_sum = sum(`var')
}		
		
drop depression-any_physical2

rename *_sum *

tsline depression anxiety adjustment, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for common mental disorders}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Depressive disorders") label(2 "Anxiety disorders") label(3 "Adjustment disorders") span)

tsline bipolar psychotic, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for severe mental disorders}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Bipolar disorders") label(2 "Schizophrenia spectrum and other psychotic disorders") span)

tsline alcohol drug cannabis, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for substance-related disorders}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Alcohol-related disorders") label(2 "Other drugs-related disorders") label(3 "Cannabis-related disorders") span)

tsline suicide, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for suicide-related behaviors}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(off)

tsline retardation delays adhd movement tic, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for neurodevelopmental disorders}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Mental retardation") label(2 "Disorders of psychological development") label(3 "ADHD") label(4 "Stereotyped movement disorders") label(5 "Tic disorders") span)

tsline respiratory injuries_g infectious neoplasms blood metabolic, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for physical conditions (1)}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Respiratory diseases") label(2 "Injuries and poisoning") label(3 "Infectious diseases") label(4 "Neoplasms") label(5 "Blood/immune diseases") label(6 "Endocrine/metabolic diseases") span)

tsline nervous circulatory digestive genitourinary skin musculoskeletal, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Medical visits for physical conditions (2)}" " ", span) ytitle("Accumulation of medical visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Nervous system/sense organs diseases") label(2 "Circulatory diseases") label(3 "Digestive diseases") label(4 "Genitourinary diseases") label(5 "Skin/subcutaneous diseases") label(6 "Musculoskeletal diseases") span)

use HOSP_ALL_DISAGGREGATED, clear

sort noindiv DAT_ADMIS

gen age = DAT_ADMIS-birth

drop *accidental*
drop *nonintentional* *assault* *unintentional*
drop *any_physical_*
drop *driver*

collapse (sum) tag_*_t, by(age)

rename tag_*_t *

tsset age

foreach var of varlist depression-any_physical2 {
                gen `var'_sum = sum(`var')
}		
		
drop depression-any_physical2

rename *_sum *

tsline depression anxiety adjustment, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for common mental disorders}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Depressive disorders") label(2 "Anxiety disorders") label(3 "Adjustment disorders") span)

tsline bipolar psychotic, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for severe mental disorders}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Bipolar disorders") label(2 "Schizophrenia spectrum and other psychotic disorders") span)

tsline alcohol drug cannabis, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for substance-related disorders}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Alcohol-related disorders") label(2 "Other drugs-related disorders") label(3 "Cannabis-related disorders") span)

tsline suicide, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for suicide-related behaviors}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(off)

tsline retardation delays adhd movement tic, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for neurodevelopmental disorders}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Mental retardation") label(2 "Disorders of psychological development") label(3 "ADHD") label(4 "Stereotyped movement disorders") label(5 "Tic disorders") span)

tsline respiratory injuries_g infectious neoplasms blood metabolic, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for physical conditions (1)}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Respiratory diseases") label(2 "Injuries and poisoning") label(3 "Infectious diseases") label(4 "Neoplasms") label(5 "Blood/immune diseases") label(6 "Endocrine/metabolic diseases") span)

tsline nervous circulatory digestive genitourinary skin musculoskeletal, tlabel(0 "0" 730 "2" 1460 "4" 2190 "6" 2920 "8" 3650 "10" 4380 "12" 5110 "14" 5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(4380 6570) title("{bf:Hospitalizations for physical conditions (2)}" " ", span) ytitle("Accumulation of Hospitalizations") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Nervous system/sense organs diseases") label(2 "Circulatory diseases") label(3 "Digestive diseases") label(4 "Genitourinary diseases") label(5 "Skin/subcutaneous diseases") label(6 "Musculoskeletal diseases") span)

use BDCU_ALL_DISAGGREGATED, clear

sort noindiv DAT_SERV

gen age = DAT_SERV-birth

drop *accidental*
drop *nonintentional* *assault* *unintentional*
drop *any_physical_*
drop *driver*

collapse (sum) tag_*_t, by(age)

rename tag_*_t *

tsset age

foreach var of varlist depression-any_physical2 {
                gen `var'_sum = sum(`var')
}	
   		
drop depression-any_physical2

rename *_sum *

tsline depression anxiety adjustment, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for common mental disorders}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Depressive disorders") label(2 "Anxiety disorders") label(3 "Adjustment disorders") span)

tsline bipolar psychotic, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for severe mental disorders}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Bipolar disorders") label(2 "Schizophrenia spectrum and other psychotic disorders") span)

tsline alcohol drug cannabis, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for substance-related disorders}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Alcohol-related disorders") label(2 "Other drugs-related disorders") label(3 "Cannabis-related disorders") span)

tsline suicide, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for suicide-related behaviors}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(off)

tsline retardation delays adhd movement tic, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for neurodevelopmental disorders}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Mental retardation") label(2 "Disorders of psychological development") label(3 "ADHD") label(4 "Stereotyped movement disorders") label(5 "Tic disorders") span)

tsline respiratory injuries_g infectious neoplasms blood metabolic, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for physical conditions (1)}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Respiratory diseases") label(2 "Injuries and poisoning") label(3 "Infectious diseases") label(4 "Neoplasms") label(5 "Blood/immune diseases") label(6 "Endocrine/metabolic diseases") span)

tsline nervous circulatory digestive genitourinary skin musculoskeletal, tlabel(5840 "16" 6570 "18" 7300 "20" 8030 "22") tline(6570) title("{bf:Emergency visits for physical conditions (2)}" " ", span) ytitle("Accumulation of Emergency visits") xtitle("Age (in years)") ysize(8cm) xsize(11.8cm) legend(label(1 "Nervous system/sense organs diseases") label(2 "Circulatory diseases") label(3 "Digestive diseases") label(4 "Genitourinary diseases") label(5 "Skin/subcutaneous diseases") label(6 "Musculoskeletal diseases") span)