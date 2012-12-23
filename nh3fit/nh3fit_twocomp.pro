pro nh3fit_twocomp, nu, tmb, parinfo = parinfoin, s1 = s1, rms = rmsin, $
                    bestfit = bestfit, quiet = quiet, s2 = s2, s0 = s
;+
; NAME:
;   NH3FIT
; PURPOSE:
;   Fit a two-temperature temperature ammonia slab model to spectrum.
; CALLING SEQUENCE:
;   
;   NH3FIT, nu, tmb, s = s[, parinfo = parinfo, rms = rms, /quiet, $
;           bestfit = bestfit]
;
; INPUTS:
;   NU -- frequency axis in GHz
;   Tmb -- Main-beam temperature (opacity and beam efficiency corrected)
; KEYWORD PARAMETERS:
;   PARINFO -- MPFIT parameter info structure.  Default parameter structure
;              returned by NH3DEFAULT.pro
;   RMS -- RMS of the spectrum either element-wise or a scalar.  If missing,
;          estimated from the data.
;   QUIET -- Suppress output for MPFIT.
; OUTPUTS:
;   S -- BOLONH3 structure with all the fit parameters and derived data.  Only
;        some fields will be populated by this routine.
;   BESTFIT -- Set keyword to contain the best model spectrum.
;
; SIDE EFFECTS:
;   Nausea, vomitting, apotheosis.
;
; MODIFICATION HISTORY:
;
;       Fri Mar 4 11:29:54 2011, Erik Rosolowsky <erosolo@>
;                 -- Hacked together the code into a "package"
;-


  defsysv,'!NH3',exists = exists
  if not exists then defsysv,'!NH3',{DATA_DIR:'',$
                                     PLOT_DIR:'',REDUCED_DIR:'',ROOT:'',FREQSW:[!values.f_nan,!values.f_nan],$
                                     FREQSWTHROW:!values.f_nan}


  ckms = 2.99792458d5
  if n_elements(vrange) eq 0 then vrange = [-250,250] ; Chosen to keep line complexes from hitting each other too badly 

  if n_elements(parinfoin) eq 0 then pm = nh3parinfo() $
  else pm = parinfoin

  if n_elements(rmsin) eq 0 then rmsin = mad(tastar)
  if n_elements(rmsin) ne n_elements(tmb) then rms = replicate(rmsin[0],n_elements(tmb)) else rms = rmsin

  if n_elements(s) eq 0 then begin 
     nh3fit,nu,tmb, parinfo = pm, s = s, rms = rms, $
            bestfit = bestfit
  endif
  
  p = [pm[0].value,pm[6].value,pm[2:3].value]
  s1 = s
  s2 = s
  fullmodel = s.model[0:5]
; --------------------  TWO COMPONENT FITTING HERE! --------------

  parinfo = replicate({limits:fltarr(2), limited:fltarr(2), $
                       fixed:0b, value:0d0}, 12)                

  parinfo[0].limited[0] = 1b                    
  parinfo[0].limits[0] = 2.73                   
  parinfo[1].limited[0] = 1b                    
  parinfo[1].limits[0] = 0.0                    
  
  parinfo[2].limited[0] = 1b
  parinfo[2].limits[0] = 0.08   ; Channel width
  
;     parinfo[3].limited = [1b, 1b]
;     parinfo[3].limits = v_permitted ; Limit the VLSR range
  parinfo[4].limited = [1b,1b]
  parinfo[4].limits = [0,1.0]
  
  parinfo[5].limited = [1b,1b]
  parinfo[5].limits = [0.0,1.0]
  parinfo[5].fixed = 1b
  parinfo[6:11] = parinfo[0:5]
  
  p = [fullmodel,fullmodel]
  p[0] = p[0]*1.2
  p[6]= p[6]*0.8
  p[1] = p[1] - 0.3
  p[7] = p[7] - 0.3
  p[3] = p[3] + p[2]*1.2        ; Split lines by the width of the original line
  p[9] = p[9] - p[2]*1.2
  p[2] = p[2]/2.4>0.08
  p[8] = p[8]/2.4>0.08

  p[0] = p[0]*0.7
  p[6]= p[6]*1.5
  p[1] = p[1] - 0.3
  p[7] = p[7] - 0.6
  p[3] = p[3] ;+ p[2]*1.2        ; Split lines by the width of the original line
  p[9] = p[9] ;- p[2]*1.2
  p[2] = p[2]/2.4>0.08
  p[8] = p[8] >0.08


  ;; rms = [replicate(mad(sp.ta11),n_elements(sp.ta11)),$
  ;;        replicate(mad(sp.ta22),n_elements(sp.ta22)),$
  ;;        replicate(mad(sp.ta33),n_elements(sp.ta33))]
  ;; spec = [sp.ta11,sp.ta22,sp.ta33]
  ;; nu = [sp.nu11,sp.nu22,sp.nu33]

  ind = where(tmb eq tmb)
;     tmb = tmb[ind]
;     nu = nu[ind]
;     rms = rms[ind]
  
  fullmodel = mpfitfun('model_twocomp',nu[ind],tmb[ind],rms[ind],p,$
                       parinfo = parinfo, perror = perror, maxiter = 200)
  if n_elements(perror) ne n_elements(p) then return
  
  s1.n_nh3 = 1d1^fullmodel[1]
  s1.err_nh3 = 1d1^(fullmodel[1]+perror[1])-1d1^(fullmodel[1])
  s1.tex = fullmodel[4]*fullmodel[0]
  s1.tex_err = perror[4]*fullmodel[0]
  s1.tau11 = s.tau11
  s1.tau11_err = !values.f_nan
  s1.model = fullmodel[0:5]  
  s1.tkin = fullmodel[0]
  s1.tkin_err = perror[0]
  s1.sigmav = fullmodel[2]
  s1.sigmav_err = perror[2]
  s1.vlsr = fullmodel[3]
  s1.vlsr_err = perror[3]
  s1.modelerr = perror[0:5]

  s2.n_nh3 = 1d1^fullmodel[7]
  s2.err_nh3 = 1d1^(fullmodel[7]+perror[7])-1d1^(fullmodel[7])
  s2.tex = fullmodel[10]*fullmodel[6]
  s2.tex_err = perror[10]*fullmodel[6]
  s2.tau11 = s.tau11
  s2.tau11_err = !values.f_nan
  s2.model = fullmodel[6:11]  
  s2.tkin = fullmodel[6]
  s2.tkin_err = perror[6]
  s2.sigmav = fullmodel[8]
  s2.sigmav_err = perror[8]
  s2.vlsr = fullmodel[9]
  s2.vlsr_err = perror[9]
  s2.modelerr = perror[6:11]

  yfit = model_twocomp(nu,fullmodel)
  voff = fullmodel[3]
  n11fit = yfit
  vel11 = (-(nu-23.694506d0)/23.694506d0)*ckms
  vmatch = where(vel11 gt vrange[0] and vel11 lt vrange[1],ct)
  if ct gt 0 then begin
     ta11 = tmb[vmatch]
     n11fit = yfit[vmatch]
     on = where(n11fit gt 0 or abs(vel11-voff) lt 2.0,comp = off,ct)
     offarr = bytarr(n_elements(n11fit))
     offarr[off]=1b
     off = where(offarr)
     s.noise11 = mad(ta11[off])
     meanval = median(ta11[off])
     s.dv11 = median(vel11-shift(vel11,-1))
     s.W11 = total(ta11[on]-meanval,/nan)*abs(s.dv11)
     s.W11_err = sqrt(ct)*s.noise11*abs(s.dv11)
     s.pk11 = max(ta11[on], null,/nan)
     s1.chisq11 = total((ta11[on]-n11fit[on])^2/s.noise11^2)/(ct-10) >0
     s2.chisq11 = total((ta11[on]-n11fit[on])^2/s.noise11^2)/(ct-10) >0
  endif

  vel22 = (-(nu-23.722633335d0)/23.722633335d0)*ckms
  vmatch = where(vel22 gt vrange[0] and vel22 lt vrange[1],ct)
  if ct gt 0 then begin
     ta22 = tmb[vmatch]
     n22fit = yfit[vmatch]
     on = where(n22fit gt 0 or abs(vel22-voff) lt 2.0,comp = off,ct)
     offarr = bytarr(n_elements(n22fit))
     offarr[off]=1b
     off = where(offarr)
     s.dv22 = median(vel22-shift(vel22, -1))  
     s.noise22 = mad(ta22[off])
     meanval = median(ta22[off])
     s.W22 = total(ta22[on]-meanval,/nan)*abs(s.dv22)
     s.W22_err = sqrt(ct)*s.noise22*abs(s.dv22)
     s.pk22 = max(ta22[on], null,/nan)
     s1.chisq22 = total((ta22[on]-n22fit[on])^2/s.noise22^2)/(ct-10) >0
     s2.chisq22 = total((ta22[on]-n22fit[on])^2/s.noise22^2)/(ct-10) >0
  endif

  vel33 = (-(nu-23.8701296d0)/23.8701296d0)*ckms
  vmatch = where(vel33 gt vrange[0] and vel33 lt vrange[1],ct)
  if ct gt 0 then begin
     ta33 = tmb[vmatch]
     n33fit = yfit[vmatch]
     on = where(n33fit gt 0 or abs(vel33-voff) lt 2.0,comp = off,ct)
     offarr = bytarr(n_elements(n33fit))
     offarr[off]=1b
     off = where(offarr)
     s.dv33 = median(vel33-shift(vel33, -1))
     s.noise33 = mad(ta33[off])
     meanval = median(ta33[off])
     s.W33 = total(ta33[on]-meanval,/nan)*abs(s.dv33)
     s.W33_err = sqrt(ct)*s.noise33*abs(s.dv33)
     s.pk33 = max(ta33[on], null,/nan)
     s1.chisq33 = total((ta33[on]-n33fit[on])^2/s.noise33^2)/(ct-10)>0
     s2.chisq33 = total((ta33[on]-n33fit[on])^2/s.noise33^2)/(ct-10)>0
  endif

  vel44 = (-(nu-24.1394169d0)/24.1394169d0)*ckms
  vmatch = where(vel44 gt vrange[0] and vel44 lt vrange[1],ct)
  if ct gt 0 then begin
     n44fit = yfit[vmatch]
     ta44=tmb[vmatch]
     on = where(n44fit gt 0 or abs(vel44-voff) lt 2.0,comp = off,ct)
     offarr = bytarr(n_elements(n44fit))
     offarr[off]=1b
     off = where(offarr)
     s.dv44 = median(vel44-shift(vel44, -1))
     s.noise44 = mad(ta44[off])
     meanval = median(ta44[off])
     s.W44 = total(ta44[on]-meanval,/nan)*abs(s.dv44)
     s.W44_err = sqrt(ct)*s.noise44*abs(s.dv44)
     s.pk44 = max(ta44[on], null,/nan)
     s1.chisq44 = total((ta44[on]-n44fit[on])^2/s.noise44^2)/(ct-10)>0
     s2.chisq44 = total((ta44[on]-n44fit[on])^2/s.noise44^2)/(ct-10)>0
  endif

; -----------------------  END TWO COMPONENT FITTING -----------


;  endif

  ;; s.model = model
  ;; s.chisq = chisq_out
  ;; s.tkin = model[0]
  ;; s.tkin_err = modelerr[0]
  ;; s.sigmav = model[2]
  ;; s.sigmav_err = modelerr[2]
  ;; s.vlsr = model[3]
  ;; s.vlsr_err = modelerr[3]

;; s.ampalt = model[5]
;; s.ampalt_err = modelerr[5]
;; s.voff = model[6]
;; s.voff_err = modelerr[6]
;; s.sigmaalt = model[7]
;; s.sigmaalt_err = modelerr[7]
;  s.modelerr = modelerr

;  s.dof = dof_out
  bestfit = yfit


  parinfoin = pm

  return
end
