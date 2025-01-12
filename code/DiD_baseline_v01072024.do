
preserve

/// staggared DiD -- baseline 
local y "l_STot_i_TA"
*qui csdid `y'_res, $csdid_options
*keep if e(sample)


estimates clear




qui csdid `y', $csdid_options 
count if e(sample)
estat simple, estore(est_`y'_1)

qui csdid `y'_res, $csdid_options 
count if e(sample)

estat simple, estore(est_`y'_2) 

qui estat pretrend
estat event,  window(-5, +11)
csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) yscale(range(-0.25 0.25)) saving(`y'_res , replace) 
graph export "$EMISSIONPROC_PROJECT_PATH/output/leadlags_`y'_res_v2.png", replace



esttab est_* using "$EMISSIONPROC_PROJECT_PATH/output/csdid_att_`y'_res_v2.tex", ///
    replace tex cells(b(fmt(%9.3f) star pvalue(p)) se(par) . r2_a(fmt(%9.3f))) stats(N, ///
    labels("N") fmt(%9.3g)) collabels(none) noobs nonumbers ///
    mlabels("(1)" "(2)") star(* 0.1 ** 0.05 *** 0.01) label

	
	
/// only emissions

estimates clear

local y = "l_STot"
qui reghdfe `y', abs(firm_sector) residuals(`y'_res)
*csdid `y'_res $controls, $csdid_options
*keep if e(sample)


qui csdid `y', $csdid_options 
count if e(sample)
estat simple, estore(est_`y'_1)
qui csdid `y'_res, $csdid_options 
count if e(sample)
estat simple, estore(est_`y'_2) 

qui estat pretrend
estat event,  window(-5, +11)
csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) yscale(range(-0.5 0.5)) saving(`y'_res , replace) 
graph export "$EMISSIONPROC_PROJECT_PATH/output/leadlags_`y'_res_v2.png", replace






esttab est_* using "$EMISSIONPROC_PROJECT_PATH/output/csdid_att_`y'_res_v2.tex", ///
    replace tex cells(b(fmt(%9.3f) star pvalue(p)) se(par) . r2_a(fmt(%9.3f))) stats(N, ///
    labels("N") fmt(%9.3g)) collabels(none) noobs nonumbers ///
    mlabels("(1)" "(2)") star(* 0.1 ** 0.05 *** 0.01) label

	
	
	restore
	
	/*
	
preserve

*** stdnardize first

gen RD_i = RD/VA_RE
	
regress RD_i  i.year i.sector

predict res_e, residuals

regress STot_i i.year i.sector

predict res_r, residuals

* Plot the residuals
twoway (scatter res_e res_r) (lfit res_e res_r)

graph export "$EMISSIONPROC_PROJECT_PATH/matching/GHGE_R&D_visualcorr.png", replace
restore
	
*/

preserve 
// placebo: using first bpp as treament idientifiers

qui csdid l_STot_i_TA_res, time(year) gvar(gpp_yfc_bpp) cluster(firm_id)
estat simple
qui estat pretrend
estat event,  window(-5, +11)
csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) yscale(range(-0.1 0.1)) saving(bpp_res , replace) 

graph export "$EMISSIONPROC_PROJECT_PATH/output/leadlags_bpp_v2.png", replace

/*
csdid l_STot_i_TA_res if gpp_firm_epadpc == 0, time(year) gvar(gpp_yfc_bpp) cluster(firm_id)
estat simple

csdid l_STot_i_TA_res if gpp_firm_epadpc == 1, time(year) gvar(gpp_yfc_bpp) cluster(firm_id)
estat simple

qui estat pretrend
estat event,  window(-5, +11)
csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) yscale(range(-0.1 0.1)) saving(bpp_res , replace) 
graph export "$EMISSIONPROC_PROJECT_PATH/output/leadlags_bpp_v2.png", replace
*/
restore

preserve 
// placebo: using first bpp as treament idientifiers

qui csdid l_STot_i_TA_res, time(year) gvar(gpp_yfc_$treatment) cluster(firm_id) notyet
estat simple
qui estat pretrend
estat event,  window(-5, +11)
csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) yscale(range(-0.1 0.1)) saving(bpp_res , replace) 

graph export "$EMISSIONPROC_PROJECT_PATH/output/leadlags_notyet_v2.png", replace

/*
csdid l_STot_i_TA_res if gpp_firm_epadpc == 0, time(year) gvar(gpp_yfc_bpp) cluster(firm_id)
estat simple

csdid l_STot_i_TA_res if gpp_firm_epadpc == 1, time(year) gvar(gpp_yfc_bpp) cluster(firm_id)
estat simple

qui estat pretrend
estat event,  window(-5, +11)
csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) yscale(range(-0.1 0.1)) saving(bpp_res , replace) 
graph export "$EMISSIONPROC_PROJECT_PATH/output/leadlags_bpp_v2.png", replace
*/
restore

	