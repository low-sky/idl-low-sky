;+
; NAME:
;   NH3MODEL
; PURPOSE:
;   Generate an ammonia spectrum given input parameters
; CATEGORY:
;   Plotting 
; CALLING SEQUENCE:
;   spectrum = NH3MODEL(v, [nu = nu, keywords])
; INPUTS:
;   V -- The velocity axis of the plot (in km/s) OR
;   NU -- The frequency axis of the plot (in Hz)
; KEYWORD PARAMETERS:
;   /N11, /N22, /N33, /N44 -- Lines to include in the plot (NH3(1,1) etc.)
;   TKIN -- Kinetic Temperature (K)
;   TEX -- Excitation temperature (K)
;   LogN -- Log of total ammonia column density in units of cm^(-2)
;   SIGV -- RMS line width in km/s
;   V0 -- Centroid velocity of the object in km/s
;   FORTHO -- Fraction of total column found in ortho-NH3 (between 0-1)
;   TAUTEX -- Tau*(Tex-Tbg) for low opacity spectra (K).
; OUTPUTS:
;   SPECTRUM -- Spectrum sampled at points given by V / NU axes.
; MODIFICATION HISTORY:
;
;       Fri Dec 17 14:44:07 2010, erosolo <erosolo@>
;-
function nh3model, v, nu = nu, n11 = n11, n22 = n22, n33 = n33, n44 = n44, $
             str = s, tkin = tkin, logn = logn, v0 = v0, sigv = sigv, $
             tautex = tautex, fortho = fortho, tex = tex

  ckms = 2.99792458d5
 
  if n_elements(s) gt 0 then model = s.model
  
  if n_elements(v) eq 0 and n_elements(nu) eq 0 then begin
     message,'One of V or NU must be set',/con
     return,!values.f_nan
  endif  


  if n_elements(nu) gt 0 and n_elements(v) eq 0 then begin  
     if keyword_set(n11) then v = (1-nu/23.6944955d9)*ckms
     if keyword_set(n22) then v = (1-nu/23.722633335d9)*ckms
     if keyword_set(n33) then v = (1-nu/23.8701296d9)*ckms
     if keyword_set(n44) then v = (1-nu/24.1394169d9)*ckms
     if n_elements(v) eq 0 then v = (1-nu/23.6944955d9)*ckms
  endif else begin 
     if n_elements(v) gt 0 and n_elements(nu) eq 0 then begin
        if keyword_set(n11) then nu = (1-v/ckms)*23.6944955d9
        if keyword_set(n22) then nu = (1-v/ckms)*23.722633335d9
        if keyword_set(n33) then nu = (1-v/ckms)*23.8701296d9
        if keyword_set(n44) then nu = (1-v/ckms)*24.1394169d9
        if n_elements(nu) eq 0 then nu = (1-v/ckms)*23.6944955d9
     endif 
  endelse

  sp = dblarr(n_elements(v)) 

  if n_elements(s) gt 0 then begin
     if s.tau11 eq s.tau11 then begin 
        p = s.model
        tkin = p[0]
        tex = p[4]*tkin
        logn = p[1]
        sigv = p[2]
        v0 = p[3]
        fortho = p[5]
        tautex = !values.f_nan
        stop
        return, modelspec(nu/1d9,model) 
     endif else begin
        p = s.model
        tkin = p[0]
        tautex = p[1]
        sigv = p[2]
        v0 = p[3]
        return, modelspec_lowop(nu/1d9,model)
     endelse
  endif

  if n_elements(tkin) eq 0 then begin
     message,'Kinetic Temperature defaulting to 15 K',/con
     tkin = 15.0
  endif 

  if n_elements(sigv) eq 0 then begin
     message,'Line width defaulting to 1 km/s',/con
     sigv = 1.0
  endif 

  if n_elements(v0) eq 0 then begin
     message,'Line centroid defaulting to 0 km/s',/con
     v0 = 0.0
  endif 

  if n_elements(tautex) gt 0 then begin 
     model = [tkin, tautex, sigv, v0]
     return,modelspec_lowop(nu/1d9,model)
  endif

  if n_elements(LogN) eq 0 then begin
     message,'Column density defaulting to 10^14 cm^-2',/con
     logn = 14.0
  endif 


  if n_elements(tex) eq 0 then begin
     message,'Excitation temperature defaulting to kinetic temperature',/con
     Tex = tkin
  endif 

  if n_elements(fortho) eq 0 then begin
     message,'Ortho-fraction defaulting to 0.5',/con
     fortho = 0.5
  endif 
  model = [tkin, logn, sigv, v0, tex/tkin, fortho]
  return, modelspec(nu/1d9,model)
end
