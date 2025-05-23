** data preparation for DiD analyses
clear all
/*
set scheme s1color, perm
ssc install jwdid
ssc install hdfe
ssc install csdid
/*
 * Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")    
 * Install reghdfe 6.x
cap ado uninstall reghdfe
*/
ssc install reghdfe, replace 
ssc install ftools, replace
*/

use "$EMISSIONPROC_DROPBOX_PATH/Data/Final/Panel_final.dta", clear 

// set the panel and sort variables by id/year
sort firm_id year
xtset firm_id year


// globals

global treatment "epadpc"
global controls "l_no_gpp_amount_$treatment"
global csdid_options "time(year) gvar(gpp_yfc_$treatment) cluster(firm_id)" // method(stdipw)"


/*
// normalizing environmental variables, i.e. creating intensity measures (we need to decide the baseline)///

foreach var in WT WR S1 S2 STot{
	
	foreach x in VA_RE VA_GI RE TA ME PP{
	
	replace `var'_i_`x' = ((`var')/(`x'/1000))
	}
}
*/

// first bpp contract?

generate byte bpp_flag = no_gpp_amount_epadpc > 0
generate fyear_flag = year if bpp_flag
by firm_id: egen gpp_yfc_bpp =  min(fyear_flag)
replace gpp_yfc_bpp = 0 if mi( gpp_yfc_bpp)


// is it a us firm?
gen tmp_ISIN = substr(ISIN,1,2)
gen byte US_ISIN = tmp_ISIN == "US"
drop tmp_ISIN

// labor productivity based on revenues

gen lab_prod_RE = RE/EM

// R&D intensity variables

foreach var in RD ERE{
	
	gen `var'int = `var'/RE if `var' >=0 & RE >0
	gen l_`var'int = ln(1+`var'int )
}

*gen l_RDint = ln(1+ (RD/VA_RE)) if RD >=0
*gen l_EREint = ln(1+(ERE/VA_RE)) if ERE >=0

// total procurement revenues
by firm_id: egen ppsales = total(gpp_amount_$treatment + no_gpp_amount_$treatment)


// gen a dummy for no communication services, financials, health care, real estate: both intesnity and gpp spending very low
gen irr_sector = inlist(firm_sector, 1, 5,11) 
gen rel_sector = inlist(firm_sector, 6,7,8,9)




// log vars (exclude negatives)
foreach var in private_RE brown_PP_amount no_gpp_amount_epadpc gpp_amount_other STot lab_prod_VA_GI lab_prod_VA_RE VA_GI VA_RE ERE RDE PP OP RD GI EM S2 S1 EN WR WT DE BE ME RE TA WT_i_VA_RE WT_i_VA_GI WT_i_RE WT_i_TA WT_i_ME WT_i_PP WR_i_VA_RE WR_i_VA_GI WR_i_RE WR_i_TA WR_i_ME WR_i_PP S1_i_VA_RE S1_i_VA_GI S1_i_RE S1_i_TA S1_i_ME S1_i_PP S2_i_VA_RE S2_i_VA_GI S2_i_RE S2_i_TA S2_i_ME S2_i_PP STot_i_VA_RE STot_i_VA_GI STot_i_RE STot_i_TA STot_i_ME STot_i_PP lab_prod_RE{

   // Generate the logarithm of the variable
    qui gen l_`var' = ln(1+ `var')
    
    // Get the original label of the variable
    local original_label: variable label `var'
    
    // Create the new label by appending "Log"
    local new_label = "Log " + "`original_label'"
    
    // Apply the new label to the new variable
    label variable l_`var' "`new_label'"

}



/// data preparation for mechanisms

// large gpp firm
bys firm_id: egen firm_size = mean(TA) if gpp_firm_$treatment == 1 
egen size =  median(TA) if gpp_firm_$treatment == 1
gen byte large = (firm_size > size) if gpp_firm_$treatment == 1
drop firm_size size

/*
// gpp firm with multiple awards
bys firm_id: egen firm_awards = total(gpp_awards_$treatment) if gpp_firm_$treatment == 1 
gen byte multiawards = (firm_awards > 1) if gpp_firm_$treatment == 1
drop firm_awards
*/

// gpp firm with many awards
bys firm_id: egen firm_awards = total(gpp_awards_$treatment) if gpp_firm_$treatment == 1 
egen size_awards =  median(firm_awards) if gpp_firm_$treatment == 1
gen byte multiawards = (firm_awards > size_awards) if gpp_firm_$treatment == 1
drop firm_awards size_awards

// gpp firm with gpp revenues over median
bys firm_id: egen firm_ratiogpp = median(gpp_amount_$treatment) if gpp_firm_$treatment == 1 
egen ratiogpp =  median(gpp_amount_$treatment) if gpp_firm_$treatment == 1
gen byte hratiogpp = (firm_ratiogpp > ratiogpp) if gpp_firm_$treatment == 1
drop firm_ratiogpp ratiogpp

// gpp firms winning in 2007 vs others
gen byte incumbent = gpp_yfc_epadpc == 2008 if gpp_firm_$treatment == 1
replace incumbent = . if gpp_yfc_epadpc == 2007

// financial constraints
bys firm_id: egen firm_finconstraint = median(DE/RE) if gpp_firm_$treatment == 1 
egen finconstraint =  median(DE/RE) if gpp_firm_$treatment == 1
gen byte hfinconstraint = (firm_finconstraint > finconstraint) if gpp_firm_$treatment == 1
drop firm_finconstraint finconstraint

// R\&D intensity
bys firm_id: egen firm_RDint = median(RDint) if gpp_firm_$treatment == 1 
egen totRDint =  median(RDint) if gpp_firm_$treatment == 1
gen byte hRDint = (firm_RDint > totRDint) if gpp_firm_$treatment == 1
drop firm_RDint totRDint

// high-tech sectors
gen hightech = inlist(firm_sector, 1, 6, 7, 8, 9, 1) if firm_sector != 10



/*
egen median_ratio_gpp = median(gpp_amount_$treatment /RE) if gpp_firm_$treatment == 1
egen median_ratio_pp = median((gpp_amount_$treatment + no_gpp_amount_$treatment )/RE) if gpp_firm_$treatment == 1


* For firm size
gen large = (ME > median_ME) if gpp_firm_$treatment == 1

* For number of procurement awards
gen multiawards = (gpp_awards_$treatment > 1) if gpp_firm_$treatment == 1

* For the ratio calculation
gen ratio_gpp = (gpp_amount_$treatment) / RE
gen himportance_gpp = (ratio_gpp > median_ratio_gpp) if gpp_firm_$treatment == 1

gen ratio_pp = (gpp_amount_$treatment  +no_gpp_amount_$treatment ) / RE
gen himportance_pp = (ratio_pp > median_ratio_pp) if gpp_firm_$treatment == 1
drop ratio_* median_*
*/

//// intensity residuals

local y "l_STot_i_TA"
qui reghdfe `y', abs(firm_sector) residuals(`y'_res)
qui reghdfe `y', abs(firm_industry) residuals(`y'_resind)
qui reghdfe `y', abs(firm_sector firm_state) residuals(`y'_resstate)


compress