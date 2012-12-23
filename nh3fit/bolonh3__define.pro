pro bolonh3__define

  nan = !values.f_nan
  dnan = !values.d_nan
  s = {BOLONH3, $
       object:'', $
       filename:strarr(6), $
       datadir:'', $
       lines:strarr(6), $
       component:0, $
       glon:dnan, glat:dnan, $
       ra:dnan, dec: dnan, $
       nurest:dblarr(6)+dnan, $
       tkin:nan, tkin_err:nan, $
       tau11:nan, tau11_err:nan, $
       sigmav:nan, sigmav_err:nan, $
       vlsr:nan, vlsr_err:nan, $
       tex:nan, tex_err:nan, $
       fillfrac:nan, fillfrac_err:nan, $
       ampalt:nan, ampalt_err:nan, $
       voff:nan, voff_err:nan, $
       sigmaalt:nan, sigmaalt_err:nan, $
       chisq:nan, $
       model:dblarr(8)+dnan, modelerr:dblarr(8)+dnan, $
       model3:dblarr(8)+dnan, model3err:dblarr(8)+dnan, $
       detection:0b, dof:-1L, $
       w11:nan, w11_err:nan, $
       pk11:nan, noise11:nan, dv11:nan, $
       w22:nan, w22_err:nan, $
       pk22:nan, noise22:nan, dv22:nan, $
       w33:nan, w33_err:nan, $
       pk33:nan, noise33:nan, dv33:nan, $
       w44:nan, w44_err:nan, $
       pk44:nan, noise44:nan, dv44:nan, $
       wccs:nan, wccs_err:nan, $
       pkccs:nan, noiseccs:nan, dvccs:nan, $
       wh2o:nan, wh2o_err:nan, $
       pkh2o:nan, noiseh2o:nan, dvh2o:nan, $
       tautex:nan, tautex_err:nan, $
       chisq11:nan, chisq22:nan, chisq33:nan, chisq44:nan, $
       flags:'', kindist_near:0.0, kindist_far:0.0, $
       rgal:0.0, n_nh3:nan, err_nh3:nan,$
       n_nh3_lte:nan,eerr_nh3_lte:nan,$
       ortho_Frac:0.0}
  return
end 
