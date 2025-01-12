
////////////////// GPP_EMISSIONS PROJECT: MASTER DO FILE//////////////

clear all

cd "$EMISSIONPROC_DROPBOX_PATH"


global dir "`dropboxdir'/Alex/Xinghong/Supplementary Materials/Data" //Leo's directory
global path "`dropboxdir'/Olga_Ambrogio_Leo"



///////////////////////////////
*** dataset creation (IMPORTANT! RUN ONLY FOR DATA GENERATION FROM RAW DATA!)***
//// from excel raw to dta raw // 

do "`dropboxdir'\codes\v01072024\fromCSVtoDTA_v01072024.do"

/// from dta raw to firm-level 

do "`dropboxdir'\codes\v01072024\FromFPDStoFirmData_v01072024.do"

*** only consider contracts open to competition ***
*do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\FromFPDStoFirmData_CT.do"

*** only consider contracts with actual competition (i.e., 2 or more bids) ***
*do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\FromFPDStoFirmData_M2B.do"

*** only consider contracts open to competition and with actual competition (i.e., 2 or more bids)
*do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\FromFPDStoFirmData_M2B_CT.do"

*** only consider contracts above 100k --  not used at the moment ***
*do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\FromFPDStoFirmData_M100K.do"


*** clean dataset (import merged data and create dataset ready for the descriptive stats)

***Data preparation for the baseline analysis, mechanism, rob. checks and other outcomes
*do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DataPreparation_v18062024.do"


***CREATE THE WORKING SAMPLE

do "$EMISSIONPROC_PROJECT_PATH\code\DiD_DataPreparation_v01072024.do"

//// ANALYSES

*** summary stats (Note: Ambrogio makes other summary stats on this working sample using Matlab.)

do "$EMISSIONPROC_PROJECT_PATH\code\summStats_v01072024.do"

*** baseline tables and event-study figures

do "$EMISSIONPROC_PROJECT_PATH\code\DiD_baseline_v01072024.do"

*** robustness check tables

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DiD_robChecks_v01072024.do"

*** heterogeneity tables

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DiD_heteroAnalysis_v01072024.do"

*** mechanims correlations

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\channels_v01072024.do"

*** Other environmental outcomes

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DiD_othOutcomes.do"

////////// AUXILIARY EXERCISES


*** time series for Figure 1 (sector-level time series)

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\timeseries.do"


*** contract-level analysis (not using the working sample but the whole cleaned FPDS contract data)

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\ContractLevel_analysis.do"


/*
//// DiD, alternative datasets

*** Data preparation and analysis: datasets of competed tenders

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DiD_robChecks_CT.do"

*** Data preparation and analysis: datasets of more than 2 bids tenders

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DiD_robChecks_M2B.do"

*** Data preparation and analysis: datasets of more than 100k USD tenders

do "C:\Users\lgi\Dropbox\Procurement Emissions\codes\DiD_robChecks_M100K.do"

*/








