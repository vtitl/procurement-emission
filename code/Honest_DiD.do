*** Variables
* label var STot "Total CO2e Emission Volume (M Tons)"
* label var STot_i_TA "Total CO2e Emission Intensity (TA) (Tons/M\\$)"




reghdfe l_STot_i_TA i.year, absorb(gpp_yfc_bpp firm_id) cluster(firm_id) noconstant

honestdid, pre(1/5) post(7/13) mvec(0.5(0.5)2)
* For example, setting M to 1 assumes post-treatment violations are, at most, the same size as pre-treatment violations, while 
* M = 2 allows the post-treatment violations to be up to twice the size of the pre-treatment violations.
 
*** better specification 
reghdfe l_STot_i_TA i.year, absorb(gpp_yfc_bpp firm_id) cluster(firm_id) noconstant
honestdid, pre(1/5) post(7/13) mvec(0.5(0.5)2)
 
honestdid, numpre(5) mvec(0.5(0.5)2)
local plotopts xtitle(M) ytitle(95% Robust CI)
honestdid, pre(1/5) post(6/7) mvec(0(0.01)0.05) delta(sd) omit coefplot `plotopts'
 
 ** staggered
*csdid dins, time(year) ivar(stfips) gvar(yexp2) long2 notyet
global treatment "epadpc"
global controls "l_no_gpp_amount_$treatment"
global csdid_options "time(year) gvar(gpp_yfc_$treatment) cluster(firm_id)" // method(stdipw)"


* only the rest works; not l_STot_i_TA

csdid l_STot_i_TA_res, $csdid_options 
estat simple, estore(est_`y'_2)
/*title (Event-Study)*/
csdid_estat event,  window(-5, +11) estore(csdid)
*csdid_estat event, window(-4 5) estore(csdid)
estimates restore csdid

csdid_plot, graphregion(color(white)) yscale(range(-0.25 0.25)) saving(`y'_res , replace)

*-.0996997    -.006316
local plotopts xtitle(Mbar) ytitle(95% Robust CI)
honestdid, pre(1/5) post(7/13) mvec(0.5(0.5)2) coefplot `plotopts'
** this doesnt look great

**** other options
matrix l_vec = 0.5 \ 0.5
local plotopts xtitle(Mbar) ytitle(95% Robust CI)
honestdid, l_vec(l_vec) pre(1/5) post(6/7) mvec(0(0.5)2) omit coefplot `plotopts'


*** with total
reghdfe l_STot i.year, absorb(gpp_yfc_bpp firm_id) cluster(firm_id) noconstant
honestdid, pre(1/5) post(7/13) mvec(0.5(0.5)2)
