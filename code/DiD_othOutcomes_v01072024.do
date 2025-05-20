
/// other outcomes 

preserve


*qui csdid l_STot_i_TA_res, $csdid_options
*drop if e(sample)
*drop if mi(l_STot_i_TA)


estimates clear

foreach y in l_S1_i_TA l_S2_i_TA /*l_WT_i_TA l_WR_i_TA*/ WR_s{
	
	cap drop `y'_res
	qui reghdfe `y' if !mi(l_STot_i_TA), abs(firm_sector) resid(`y'_res)
	qui csdid `y'_res, $csdid_options
	count if e(sample)
	estat simple, estore(est_`y') 

}

esttab est_* using "$path\OverleafInput\\csdid_att_other_v2.tex", /*
	*/replace tex  cells(b(fmt(a2) star pvalue(p)) se(par) . r2_a(fmt(a2))) stats(N,/*
	*/ label("N") fmt(%9.2g %9.2f))  collabels(none) noobs nonumbers/*  
	*/ mlabels("(S1_i)""(S2_i)"/*"(lWTi)""(lWRi)"*/"(WRs)") star(* .1 ** .05 *** .01) /*keep(did_coeff_`x' )*/ label
	

estimates clear



foreach y in /*l_TA l_ME l_RE l_EM l_brown_PP_amount l_private_RE l_VA_RE l_lab_prod_RE*/  RDint EREint   /*l_ERE*/{ /* l_RDE*/

	
	/*
	bys firm_id (year): gen `y'_lag = `y'[_n-1]

	gen `y'_diff = (`y' - `y'_lag)/`y'_lag
	*/
	cap drop `y'_res
	qui reghdfe `y', abs(firm_sector) resid(`y'_res)
		*foreach method in drimp dripw reg stdipw ipw{

		qui csdid `y'_res l_RE, $csdid_options /*method(`method')*/
		count if e(sample)
		estat simple, estore(est_`y'_res) 
		estat pretrend
		estat event,  window(-4, +11)
		csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) /*yscale(range(-1.5 1)) saving(`y' , replace) */
		graph export "$path/OverleafInput/leadlags_`y'_res_v2.png", replace
	

}



esttab est_l_VA_RE_res est_l_lab_prod_RE_res est_RDint_res est_EREint_res using "$path\OverleafInput\\csdid_att_econOut_v2.tex", /*
	*/replace tex  cells(b(fmt(a2) star pvalue(p)) se(par) . r2_a(fmt(a2))) stats(N,/*
	*/ label("N") fmt(%9.2g %9.2f))  collabels(none) noobs nonumbers/*  
	*/ mlabels("Log Value Added""Log Lab. Prod.""Log R\&D Int.""Log Env. Int.") star(* .1 ** .05 *** .01) /*keep(did_coeff_`x' )*/ label
	
	estimates clear




restore
/*
foreach y in l_RE l_brown_PP_amount l_private_RE l_gpp_amount_other { /*** before treatment no evidence of pretreands effect only on RD and LEV ***/
	
	
	qui csdid `y' $controls, $csdid_options

	count if e(sample)
	estat simple, window(-5 5) estore(est_`y') 
	*estat pretrend
	estat event,  window(-5, +5)
	csdid_plot, /*title (Event-Study)*/ graphregion(color(white)) /*yscale(range(-1.5 1))*/ saving(`y' , replace) 
	graph export "$path/matching/leadlags_`y'_v2.png", replace


*/
