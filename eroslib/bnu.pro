function bnu, T, nu, cgs = cgs, lam = lam, ang = ang
;+
; NAME:
;   BNU
; PURPOSE:
;   Return the specific intenisty of a blackbody at a given input
;   temperature and frequency
;
; CALLING SEQUENCE:
;   intensity = BNU(T, nu [, cgs = cgs, lam = lam, ang = ang])
;
; INPUTS:
;   T -- Temperature in Kelvins
;   NU -- Frequency in Hz
; KEYWORD PARAMETERS:
;   LAM -- Input NU is in wavelength (meters) and return is per unit
;          wavelength not per unit frequency
;   CGS -- Assume input wavelength is in cm and output in CGS units.
;   ANG -- Assumes input wavelength is in Angstroms.  Returns in MKS.
; OUTPUTS:
;   INTENSITY -- Specific intensity.
;
; MODIFICATION HISTORY:
;       Added documentation.
;       Wed Nov 21 11:20:53 2001, Erik Rosolowsky <eros@cosmic>
;-

if (n_params() lt 2) then print, 'Usage: bnu(Temp,Wavelength)'
if keyword_set(ang) then begin
  lam = 1
  nu = 1e-10*nu
endif
if keyword_set(cgs) and keyword_set(lam) then begin
  nu = nu*0.01
endif
if keyword_set(lam) then begin
  nu = 3.0e8/nu
endif

lexpon=-23.7595+alog(nu)-alog(T)
log_inten=-114.7423156+3*alog(nu)+alog(exp(exp(lexpon))-1)

inten=exp(log_inten)
if keyword_set(cgs) then inten=inten*1.e3
return,inten
end
