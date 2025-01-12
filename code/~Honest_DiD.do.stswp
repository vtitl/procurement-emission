

reg l_STot_i_TA_res i.year i.gpp_yfc_bpp, r cluster(firm_id)

reghdfe l_STot_i_TA_res i.year, absorb(gpp_yfc_bpp year) cluster(firm_id) noconstant

 honestdid, pre(1/5) post(7/13) mvec(0.5(0.5)2)