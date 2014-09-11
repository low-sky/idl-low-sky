pro bootstrap_nh3errors, nu, tmb, s, niters= niters, parinfo = parinfo


;+
; NAME:
;   BOOTSTRAP_NH3ERRORS, nu, tmb, bolonh3 
; PURPOSE:
;   To evaluate the stabilitiy of the local minimum identified in the
;   NH3FIT routine.  This redistributes the starting parameters vector 
;   within the derived errors and evaluates whether it converges back
;   to the same local minimum.  
; CALLING SEQUENCE:
;   
;   BOOTSTRAP_NH3ERRORS, nu, tmb, bolonh3 [, niters = niters, parinfo = parinfo]
;
; INPUTS:
;   NU -- frequency axis in GHz
;   Tmb -- Opacity and beam efficiency corrected antenna temperature, i.e.,
;          main-beam temperature scale.  
;   BOLONH3 -- A BOLONH3 structure, which is the output of
;              the NH3FIT routine.  
; KEYWORD PARAMETERS:
;   PARINFO -- MPFIT parameter info structure.  Default parameter structure
;              returned by NH3DEFAULT.pro
;   NITERS -- Number of checks to run.  Default = 100
; OUTPUTS:
;   Screen Output
; SIDE EFFECTS:
;   A false sense of security.
;
; MODIFICATION HISTORY:
;
;       Wed Sep 10 07:50:56 2014, <erosolo@noise.siglab.ok.ubc.ca>
;
;            First commit.		
;
;-

  if not keyword_set(niters) then  niters = 100

  pvec = s.model[0:6]
  perrvec = s.modelerr[0:6]

  pvec_out = fltarr(n_elements(pvec),niters) 
  perrvec_out = fltarr(n_elements(pvec),niters) 
  if n_elements(parinfo) eq 0 then parinfo = nh3parinfo() 
  for i = 0,niters -1 do begin
     rms = median(abs(tmb-median(tmb)))/0.67+fltarr(n_elements(tmb))
 
     p = pvec + 10* randomn(seed,n_elements(pvec)) * perrvec
     fullmodel = mpfitfun('modelspec',nu,tmb,rms,p,$
                          parinfo = parinfo, perror = perror,$
                          maxiter = 200, quiet = quiet)
; If the error puts the values outside of allowable ranges, the fit
; will barf gracefully and not iterate.  
     if total(fullmodel eq p) eq n_elements(p) then begin
        pvec_out[*,i] = fullmodel*!values.f_nan
        continue
     endif
     yfit = modelspec(nu,fullmodel,tau11 = tau11)        
     if n_elements(mask) le 1 then $
        mask = where(dilate(yfit gt 0,fltarr(31)+1),ct)
     if ct gt 30 then begin
        fullmodel = mpfitfun('modelspec',nu[mask],tmb[mask],$
                             rms[mask],p,$
                             parinfo = parinfo, perror = perror, $
                             maxiter = 200, dof = dof_out,quiet = quiet)


     endif
     pvec_out[*,i] = fullmodel
     perrvec_out[*,i] = perror

  endfor

  for jj = 0,n_elements(p)-1 do begin
     print,'Checking '+string(jj)+'th parameter: '+parinfo[jj].name
     rets = pvec_out[jj,*] 
     idx = where(rets eq rets,ct)
     if ct gt 0 then begin
        rets = rets[idx]
        zscore = (s.model[jj]-rets)/(s.modelerr[jj])
        bad = where(abs(zscore) gt 1,ctbad,complement=okay)
        print,string(ctbad/float(ct)*100)+$
              ' % of bootstrap > 1 sigma from fit values'
     endif

  endfor 

  return
end
