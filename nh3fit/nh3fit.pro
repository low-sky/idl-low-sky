pro nh3fit, nu, tmb, parinfo = parinfoin, s = s, rms = rmsin, $
            bestfit = bestfit, quiet = quiet, mask = mask
;+
; NAME:
;   NH3FIT
; PURPOSE:
;   Fit a single temperature ammonia slab model to an ammonia spectrum. (no
;   longer GBT specific).  
; CALLING SEQUENCE:
;   
;   NH3FIT, nu, tmb, s = s[, parinfo = parinfo, rms = rms, /quiet, $
;           bestfit = bestfit]
;
; INPUTS:
;   NU -- frequency axis in GHz
;   Tmb -- Opacity and beam efficiency corrected antenna temperature, i.e.,
;          main-beam temperature scale.  
; KEYWORD PARAMETERS:
;   PARINFO -- MPFIT parameter info structure.  Default parameter structure
;              returned by NH3DEFAULT.pro
;   RMS -- RMS of the spectrum either element-wise or a scalar.  If missing,
;          estimated from the data.
;   QUIET -- Suppress output for MPFIT.
;   MASK -- index array indicating channels to include in fit
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

  if n_elements(rmsin) eq 0 then rmsin = mad(tmb)
  if n_elements(rmsin) ne n_elements(tmb) then rms = replicate(rmsin[0],n_elements(tmb)) else rms = rmsin

  if n_elements(s) eq 0 then s = {bolonh3}


  p = [pm[0].value,pm[6].value,pm[2:3].value]
  
  ind = where(abs(nu - 23.694506d0) lt 0.016,ct)
  blank = nh3parinfo()
  if total(blank.value ne pm.value) gt 0 then guess = 0b else guess=1b
  if ct gt 0 and guess then begin
     tmb11 = tmb[ind]
     v11 = (-(nu[ind]-23.694506d0)/23.694506d0)*ckms
     p = firstguess(v11,tmb11)           
  endif

  parinfo = [pm[0],pm[6],pm[2:3]]
  model = mpfitfun('modelspec_lowop',nu,tmb,rms,p,$
                   parinfo = parinfo,perror = perror, $
                   maxiter = 200, dof = dof_out, quiet = quiet)
  voff = model[3]
  s.tautex = model[1] 
  s.tautex_err = perror[1]
  modelerr = perror
  
  yfit = modelspec_lowop(nu,model) 
  chisq_out = total((tmb-yfit)^2)/(dof_out)

  pm[6].value = model[1]
  pm[0].value = model[0]>2.73
  pm[2].value = model[2]>0.08
  pm[3].value = model[3]
  if model[1]/perror[1] gt 3 then begin



; p = [Tkin,log(Ntot),sigv,vlsr,Tex,fortho]
     p = pm[0:5].value
     parinfo = pm[0:5]
     fullmodel = mpfitfun('modelspec',nu,tmb,rms,p,$
                          parinfo = parinfo, perror = perror, maxiter = 200, quiet = quiet)

     yfit = modelspec(nu,fullmodel,tau11 = tau11)        
     if n_elements(mask) le 1 then mask = where(dilate(yfit gt 0,fltarr(31)+1),ct)
     voff = fullmodel[3]
     modelerr = perror
     model = fullmodel
     
     pm[0:5].value=model

     if ct gt 30 then begin
        parinfo = pm[0:5]
        fullmodel = mpfitfun('modelspec',nu[mask],tmb[mask],$
                             rms[mask],p,$
                             parinfo = parinfo, perror = perror, $
                             maxiter = 200, dof = dof_out,quiet = quiet)
        pm[0:5].value=fullmodel
        parinfo = pm[0:5]
        yfit = modelspec(nu,fullmodel,tau11 = tau11)
        ffmodel = mpfitfun('modelspec_ff',nu[mask],tmb[mask],$
                           rms[mask],fullmodel,$
                           parinfo = parinfo, perror = ffmodelerr, $
                           maxiter = 50, quiet = quiet)
;        pm[5].fixed=0b
;        parinfo = pm[0:5]
;           opmodel = mpfitfun('modelspec_op',nu[mask],tmb[mask],$
;                              rms[mask],ffmodel,$
;                              parinfo = parinfo, perror = opmodelerr, $
;                              maxiter = 50)

        voff = fullmodel[3]
        modelerr = perror
        model = fullmodel
     endif

     chisq_out = total((tmb-yfit)^2)/(dof_out)


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
        s.chisq11 = total((ta11[on]-n11fit[on])^2/s.noise11^2)/(ct-5) >0
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
        s.chisq22 = total((ta22[on]-n22fit[on])^2/s.noise22^2)/(ct-5)>0
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
        s.chisq33 = total((ta33[on]-n33fit[on])^2/s.noise33^2)/(ct-5)>0
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
        s.chisq44 = total((ta44[on]-n44fit[on])^2/s.noise44^2)/(ct-5)>0
     endif

; (5,5) and (6,6)??    

     s.n_nh3 = 1d1^model[1]
     s.err_nh3 = 1d1^(model[1]+modelerr[1])-1d1^(model[1])
     if n_elements(ffmodel) gt 1 and n_elements(ffmodelerr) gt 1 then begin 
        s.fillfrac = ffmodel[4]
        s.fillfrac_err = ffmodelerr[4]
;        s.n_nh3_lte = 1d1^ffmodel[1]
;        s.err_nh3_lte = 1d1^(ffmodel[1]+ffmodelerr[1])-1d1^(ffmodel[1])
;        s.orthofrac = opmodel[4]
     endif
     s.tex = model[4]*model[0]
     s.tex_err = modelerr[4]*model[0]
     s.tau11 = tau11
     s.tau11_err = !values.f_nan
  endif

  s.model = model  
  s.chisq = chisq_out
  s.tkin = model[0]
  s.tkin_err = modelerr[0]
  s.sigmav = model[2]
  s.sigmav_err = modelerr[2]
  s.vlsr = model[3]
  s.vlsr_err = modelerr[3]

;; s.ampalt = model[5]
;; s.ampalt_err = modelerr[5]
;; s.voff = model[6]
;; s.voff_err = modelerr[6]
;; s.sigmaalt = model[7]
;; s.sigmaalt_err = modelerr[7]
  s.modelerr = modelerr

  s.dof = dof_out
  bestfit = yfit


  parinfoin = pm

;     sp = getspec(s)

;  modelplot, s, /anno, /ps,spectrum = sp
;  save,file=!nh3.root+'_fitcheckpt.sav',s

  

  return
end
