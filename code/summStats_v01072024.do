preserve



foreach var in STot S1 S2 gpp_amount_epadpc no_gpp_amount_epadpc RE TA VA_RE RD lab_prod_RE WT WR private_RE{ //
	
 replace `var' = `var'/1000000
}





foreach var in EM{
	
 replace `var' = `var'/1000
 
 
 
}

foreach var in STot_i_TA{
	
 replace `var' = `var'*1000
 
 
 
}



// label variables

label var gpp_amount_epadpc "GPP Revenues (\\$ M)"
label var no_gpp_amount_epadpc "BPP Revenues (\\$ M)"
label var gpp_awards_epadpc "GPP Awards (count)"
label var US_ISIN "US"
label var TA "Total Assets (\\$ M)"
label var RE "Total Revenues (\\$ M)"
label var private_RE "Other Revenues (\\$ M)"
label var S1 "Direct CO2e Emission Volume (M Tons)"
label var S2 "Indirect CO2e Emission Volume (M Tons)"
label var EN "Renewable energy (supplied? purchased? produced?)"
label var WT "Total Waste Volume (M Tons)"
label var WR "Recycled Waste Volume (M Tons)"
label var WR_s "Recycled Waste Share"

label var EM "\# Employees (K)"

label var RDint "R\&D Intensity"

label var VA_RE "Value Added (Revenues) (\\$ M)"

label var STot "Total CO2e Emission Volume (M Tons)"

label var STot_i_TA "Total CO2e Emission Intensity (TA) (Tons/M\\$)"

label var lab_prod_RE "Labor Productivity (M \\$ Rev./Empl.)"

label var EREint "Environmental Intensity"

global vars =  "STot_i_TA STot S1 S2 WT WR WR_s gpp_awards_epadpc gpp_amount_epadpc no_gpp_amount_epadpc private_RE RE TA EM VA_RE RDint EREint lab_prod_RE US_ISIN "


summ $vars ,d
* Loop over each group to summarize and export the results
**** treatment vs control

foreach g of numlist 0 1 {
    * Summarize variables conditioned on gpp_firm_epadpc
	qui estpost summarize $vars  if gpp_firm_epadpc == `g' & !mi(STot_i_TA) , d
	esttab using "$EMISSIONPROC_PROJECT_PATH/output//summary_group`g'_EmissData.tex", cells("mean(fmt(2)) p50(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2)) count(fmt(0))")  label noobs collabels("Mean" "Median" "Std. Dev." "Min" "Max" "N*T") replace
	unique firm_id if gpp_firm_epadpc == `g' & !mi(STot_i_TA) 

}

/*

foreach g of numlist 0 1 {
    // Summarize variables conditioned on gpp_firm_epadpc
    qui estpost summarize $vars if gpp_firm_epadpc == `g' & !mi(STot_i), detail

    // Count the number of unique firms
	cap drop firm_count
    egen firm_count = group(firm_id) if gpp_firm_epadpc == `g' & !mi(STot_i)
    qui count if firm_count >= 1
    local num_firms = r(N)
    drop firm_count

    // Add custom statistic to estpost results
    qui estadd scalar uniq_firms = `num_firms'

    // Output table with additional statistic
    esttab using "$path/matching//summary_group`g'_EmissData_aug.tex", ///
        cells("mean p50 sd min max count uniq_firms") ///
        collabels("Mean" "Median" "Std. Dev." "Min" "Max" "N" "\# Unique Firms") ///
        label noobs replace
}
*/

****treatment pre vs. post_epadpc

foreach t of numlist 0 1 {

 estpost summarize $vars  if gpp_firm_epadpc == 1 & !mi(STot_i_TA) & post_epadpc == `t', d
*esttab using "$path/matching//summary_group1`t'_EmissData.tex", cells("mean p50 sd min max count")  label noobs replace
esttab using "$EMISSIONPROC_PROJECT_PATH/output//summary_group1`t'_EmissData.tex", cells("mean(fmt(2)) p50(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2)) count(fmt(0))")  label noobs collabels("Mean" "Median" "Std. Dev." "Min" "Max" "N*T") replace

}

/*
global vars =  "gpp_amount_epadpc RE RD VA_RE EM"




foreach g of numlist 0 1 {
    * Summarize variables conditioned on gpp_firm_epadpc
	qui estpost summarize $vars  if gpp_firm_epadpc == `g' , d
	esttab using "$path/matching//summary_group`g'_Full.tex", cells("mean p50 sd min max count")  label noobs replace

}


*/
restore



preserve

drop if firm_sector == 10

replace firm_sector = 10 if firm_sector == 11
replace firm_sector = 11 if firm_sector == 12



collapse (sum) gpp_amount_epadpc gpp_awards_epadpc no_gpp_amount_epadpc RE STot TA, by(firm_sector)

gen gpp_importance = (gpp_amount_epadpc/RE) 
gen bpp_importance = (no_gpp_amount_epadpc/RE)
gen emis_int = (STot/TA)*1000000

egen gpp_tot = total(gpp_amount_epadpc)
gen gpp_share = (gpp_amount_epadpc/gpp_tot)

egen emis_tot =  total(STot)
gen emis_share = (STot/emis_tot) 

egen award_tot = total(gpp_awards_epadpc)
gen award_share = gpp_awards_epadpc / award_tot

bys firm_sector: tab gpp_importance
bys firm_sector: tab emis_share
bys firm_sector: tab award_share

bys firm_sector: tab award_share


twoway ///
    (scatter award_share firm_sector, msymbol(D)  mcolor(green) ytitle("GPP Award Share", axis(1))) ///
    (scatter emis_int firm_sector, msymbol(D)  mcolor(orange) yaxis(2) ytitle("tCO2e Emissions/\$ M Total Assets", axis(2))), ///
    legend(label(1 "GPP Award %") label(2 "GHGE Intensity")) xtitle("Sector") xlab(1 "Commun. Services" ///
    2 "Consumer Discr." 3 "Consumer Staples" 4 "Energy" 5 "Financials" 6 "Health Care" ///
    7 "Industrials" 8 "Information Tech." 9 "Materials" /*10 "NA"*/ 10"Real Estate" 11 "Utilities" ///
    , angle(vertical)) graphregion(color(white))


	graph export "$EMISSIONPROC_PROJECT_PATH/output//baselinecomparison_graph.png", replace
	
	/*

twoway ///
    (scatter gpp_share firm_sector, msymbol(D)  mcolor(green) ytitle("GPP Revenues Share", axis(1))) ///
    (scatter award_share firm_sector, msymbol(D)  mcolor(orange) yaxis(2) ytitle("GPP Award Share", axis(2))), ///
    legend(label(1 "GPP Revenues Share") label(2 "GPP Award Share")) xtitle("Sector") xlab(1 "Commun. Services" ///
    2 "Consumer Discr." 3 "Consumer Staples" 4 "Energy" 5 "Financials" 6 "Health Care" ///
    7 "Industrials" 8 "Information Tech." 9 "Materials" /*10 "NA"*/ 10"Real Estate" 11 "Utilities" ///
    , angle(vertical)) graphregion(color(white))




graph export "$path/OverleafInput//comparison_graph.png", replace

twoway ///
    (scatter emis_share firm_sector, msymbol(T)  mcolor(green) ytitle("GHGE Share", axis(1))) ///
	(scatter emis_int firm_sector, msymbol(T)  mcolor(orange) yaxis(2) ytitle("GHGE (Tons)/Total Assets (\$ M)", axis(2))), ///
    legend(label(1 "GHGE Share") label(2 "GHGE Intensity")) xtitle("Sector") xlab(1 "Commun. Services" ///
    2 "Consumer Discr." 3 "Consumer Staples" 4 "Energy" 5 "Financials" 6 "Health Care" ///
    7 "Industrials" 8 "Information Tech." 9 "Materials" /*10 "NA"*/ 10"Real Estate" 11 "Utilities" ///
    , angle(vertical)) graphregion(color(white))




graph export "$path/OverleafInput//importance_graph.png", replace

twoway ///
    (scatter gpp_importance firm_sector, msymbol(S)  mcolor(green) ytitle("GPP Relevance", axis(1))) ///
	(scatter bpp_importance firm_sector, msymbol(S)  mcolor(orange) yaxis(2) ytitle("BPP Relevance", axis(2))), ///
    legend(label(1 "GPP") label(2 "BPP")) xtitle("Sector") xlab(1 "Commun. Services" ///
    2 "Consumer Discr." 3 "Consumer Staples" 4 "Energy" 5 "Financials" 6 "Health Care" ///
    7 "Industrials" 8 "Information Tech." 9 "Materials" /*10 "NA"*/ 10"Real Estate" 11 "Utilities" ///
    , angle(vertical)) graphregion(color(white))




graph export "$path/OverleafInput//emissions_graph.png", replace

*/


restore