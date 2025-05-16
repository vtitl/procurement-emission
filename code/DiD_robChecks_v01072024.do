
/// robustness checks

preserve





estimates clear


foreach y in l_STot_i_TA_res{
    
	// baseline
	
	qui csdid `y', $csdid_options
	count if e(sample)
	estat simple, estore(est_`y') 

    
	// never treated procurement firms as control
	
	qui csdid `y' if ppsales>0, $csdid_options
	count if e(sample)
	estat simple, estore(est_`y'_onlypp) 
	
	
	// including PP control with dripw
	qui csdid `y' $controls,  $csdid_options method(stdipw) // baseline method in csdid
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'covmeth1) 
	
	/// not yet treated as control group
	qui csdid `y',  $csdid_options notyet
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace
	estat simple, estore(est_`y'_nyt) 
	
	/*
	// including PP control with stdipw
	qui csdid `y' $controls,  $csdid_options method(stdipw) 
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'covmeth2) 
	*/


	/*
	/// excluding recession years
	qui csdid `y' $controls if year >=2009,  $csdid_options
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'_from2009)
	*/
	

	/*
	// other covariates: other gpp revenues
	qui csdid `y' $controls l_gpp_amount_other,  $csdid_options
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'_cov) 
	*/
	/*
	// wboot standard errors
	
	qui csdid `y',  $csdid_options wboot reps(1000)  rseed(1969619696)
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'_bootse) 
	*/
	/*
	// also state FEs

	qui csdid l_STot_i_TA_resstate, $csdid_options
 	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'StateFEs) 
	*/
	/*
	// industry FEs

	qui csdid l_STot_i_TA_resind, $csdid_options
 	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'_indFEs) 
	*/
	// us firms
	
	qui csdid `y' if US_ISIN == 1, $csdid_options
	count if e(sample)
	estat simple, estore(est_`y'_US) 
	
	// relevant sectors only
	qui csdid `y' if irr_sector == 0,  $csdid_options //90% of gpp spending here and 15% Emissions //FIX THIS
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'Rel) 
	
	// alternative intensity variable
	
	local Y "l_STot_i_VA_RE"
	cap drop `Y'_res
	qui areg `Y', abs(firm_sector)
	qui predict `Y'_res, res
	qui csdid `Y'_res,  $csdid_options 
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'_alt) 
	
	//alternative did
    qui jwdid  `y', ivar(firm_id) tvar(year) gvar(gpp_yfc_$treatment) cluster(firm_id) group never //method(logit) if the outocome is binary. 
	count if e(sample)
	local N = r(N)
	estadd local N "N", replace	
	estat simple, estore(est_`y'otherDiD) 

	*stop
	esttab est_* using "$EMISSIONPROC_PROJECT_PATH/output/csdid_att_rcs_`y'_v2.tex", replace tex  cells(b(fmt(a2) star pvalue(p)) se(par) . r2_a(fmt(a2))) stats(N,     labels("N") fmt(%9.3g %9.3f))  collabels(none) noobs nonumbers mlabels("(1)""(2)""(3)""(4)""(5)""(6)""(7)""(8)") star(* .1 ** .05 *** .01) /*keep(did_coeff_`x' )*/ label
	

}

restore

/*


/// regressions in log 

estimates clear

foreach y in /*l_S1 l_S2*/ l_STot{
	
	cap drop res_`y'
	qui reg `y' i.sector EM
	predict res_`y', res
	qui csdid `y' res_`y', $csdid_options

	
	estat simple, estore(est_`y') 



}

esttab est_* using "$path/DiD_tables/csdid_att_loglev.tex", ///
    replace tex cells(b(fmt(a2) star pvalue(p)) se(par) . r2_a(fmt(a2))) stats(N, ///
    labels("N") fmt(%9.0g)) collabels(none) noobs nonumbers ///
    mlabels("(Log Scope 1 GHGE)" "(Log Scope 2 GHGE)" "(Log Total GHGE)") star(* 0.1 ** 0.05 *** 0.01) label
*/


/// for the visual version
/*
matrix input A = (0, 0.018, 0.06, -0.009 \ 0, 0.020, 0.1, 0.054) 
*matrix input sigA = (.z, .z, -0.063, .z \ .z, .z, 0.038, .z) 
set scheme s1color
coefplot mat(A) /*mat(sigA)*/, se(2) vertical yline(0, lcolor(gray)) ///
xlab(1 "Base" 2 "Pre" 3 "Post1" 4 "Post2", labsize(small)) ///
title("Real income", size(*0.80) color(navy)) ///
ylabel(-0.10 "-0.10" -0.05 "-0.05" 0.00 "0.00" 0.05 "0.05", labsize(vsmall)) ///
ciopts(recast(rcap)) format(%9.2f) mlabposition(12) mlabgap(*4) ///
mlabel(cond(@pval<.01, string(@b, "%9.3fc") + "***", cond(@pval<.05, string(@b, "%9.3fc") ///
 + "**", cond(@pval<.10, string(@b, "%9.3fc") + "*", string(@b, "%9.3fc"))))) ///
 graphregion(col(white)) bgcol(white) xlab(, nogrid) ylab(, nogrid)   nooffset nokey
*/
