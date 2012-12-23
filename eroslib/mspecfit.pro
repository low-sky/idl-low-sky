function mspecfit, m_in, merror_in, error = error, $
                   bootiter = bootiter, covar = covar, $
                   notrunc = notrunc, trialfit = trialfit
;+
; NAME:
;   MSPECFIT
; PURPOSE:
;   Error-in-variables fit to a mass distribution or others.
;
; CALLING SEQUENCE:
;   fit = MSPECFIT( mass, mass_error [, error = error, bootiter =
;   bootiter, covar = covar, /notrunc, trialfit = trialfit])
;
;
; INPUTS:
;   MASS -- a vector representing the masses
;   MASS_ERROR -- the 1-sigma uncertainties in the masses
;
; KEYWORD PARAMETERS:
;   /NOTRUNC -- Fit a normal power law, not a truncated power law.
;   BOOTITER -- number of bootstrap iterations to run.  Defaults to
;               zero which results in no uncertainties.
; OUTPUTS:
;   fit -- the parameters of the fit: [N_0, M_0, gamma] for a
;          truncated power law, [0.0 , N_0, gamma] for a power law.
;
; OPTIONAL OUTPUTS:
;   ERROR -- the 1 sigma uncertainties in the fit
;   TRIALFIT -- A 3 X bootiter array representing the derived fits for
;               each bootstrap iterations (see FIT for ordering).
;
; MODIFICATION HISTORY:
;
;	Tue Apr 18 17:17:51 2006, Erik Rosolowsky
;       Documented.
;-

  if n_elements(bootiter) eq 0 then bootiter = 0
  
  m = m_in
  merror = merror_in

  sind = sort(m)
  m = m[sind]
  merror = merror[sind]
  n = n_elements(m)-findgen(n_elements(m))
  nerror = sqrt(n > 1)
  if keyword_set(notrunc) then begin
      fit = pl_errinvar(m, n, merror, nerror)
      if bootiter gt 0 then begin
        trialfit = fltarr(2, bootiter)
         for k = 0, bootiter-1 do begin
           trialindices = floor(randomu(seed, n_elements(m))*n_elements(m))
           trialindices = trialindices[sort(trialindices)]
           m_sample = m[trialindices]
           merror_sample = merror[trialindices]
           trialfit[*, k] = pl_errinvar(m_sample, n, merror_sample, nerror)
         endfor

         mean0 = mean(trialfit[0, *])
         mean1 = mean(trialfit[1, *])
         tf = trialfit
         tf[0, *] = tf[0, *]-mean0
         tf[1, *] = tf[1, *]-mean1
         covar = tf#transpose(tf)/n_elements(n) 
         errs = sqrt(covar[indgen(2), indgen(2)]#replicate(1, 2))
         covar = covar/(errs*transpose(errs))
         error = [mad(trialfit[0, *]), mad(trialfit[1, *])]
         trialfit = [transpose(fltarr(bootiter)), trialfit[0, *], trialfit[1, *]]
         error = [0., error]
       endif
      fit = [0., fit]
      
      
    endif else begin
      fit = tpl_errinvar(m, n, merror, nerror)
      
      if bootiter gt 0 then begin
        trialfit = fltarr(3, bootiter)
        for k = 0, bootiter-1 do begin
          trialindices = floor(randomu(seed, n_elements(m))*n_elements(m))
          trialindices = trialindices[sort(trialindices)]
          m_sample = m[trialindices]
          merror_sample = merror[trialindices]
          trialfit[*, k] = tpl_errinvar(m_sample, n, merror_sample, nerror, $
                                        convfail = convfail)
          if (trialfit[0, k]) lt 1e-3 or trialfit[0, k] gt n_elements(m) or $
             convfail eq 1b then k = k-1
        endfor

        mean0 = mean(trialfit[0, *])
        mean1 = mean(trialfit[1, *])
        mean2 = mean(trialfit[2, *])
        tf = trialfit
        tf[0, *] = tf[0, *]-mean0
        tf[1, *] = tf[1, *]-mean1
        tf[2, *] = tf[2, *]-mean2
        covar = tf#transpose(tf)/n_elements(n) 
        errs = sqrt(covar[indgen(3), indgen(3)]#replicate(1, 3))
        covar = covar/(errs*transpose(errs))
;    m0 = (trialfit[1, *])^(-1/trialfit[2, *])
      
        m0 = (trialfit[0, *]/trialfit[1, *])^(1/trialfit[2, *])
        error = [mad(trialfit[0, *]), mad(m0), mad(trialfit[2, *])]
        trialfit[1, *] = m0
    endif
      fit = [fit[0], (fit[0]/fit[1])^(1/fit[2]), fit[2]-1]
    endelse
    return, fit
end
