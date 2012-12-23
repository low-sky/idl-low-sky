function powerlaw, x, guess

; POWERLAW.pro 
; Fit function for LMFIT to fit a powerlaw (x/a[0])^(a[1])

  fcn = (x/guess[0])^(guess[1])
  partial0 = (-guess[1]/guess[0]*fcn)
  partial1 = fcn*(alog(x/guess[0]))

  return, [[fcn], [partial0], [partial1]]
end

function powerlaw_fit, x, y, errors = errors, sigma = sigma, guess = guess, $
                       _extra = ex, chisq = chisq


;+
; NAME:
;    POWERLAW_FIT
; PURPOSE:
;    Fit a powerlaw to a given set of data with errors.  Returns error
;    matrix to judge errors in parameters. Function fit is y=(x/a)^b
;    Wrapper to LMFIT
; CALLING SEQUENCE:
;   coeffs = POWERLAW_FIT(x,y,y_err [,guess=guess, covar=covar])
;
; INPUTS:
;   X, Y -- X and Y values to be fit.
; KEYWORD PARAMETERS:
;   GUESS -- vector containing the guess values [a,b] in y=(x/a)^b
;   COVAR -- name of variable to contain the covariance matrix 
;   ERRORS -- error in the y_values
; 
; REQUIRES:
;   POWERLAW.pro -- See FITFCNS
; OUTPUTS:
;   COEFFS -- Coefficients of the powerlaw fit in vector form [a,b]
;
; MODIFICATION HISTORY:
;       Written and Documented --
;       Fri Jul 6 09:04:19 2001, Erik Rosolowsky <eros@cosmic>
;-

if n_elements(errors) eq 0 then errors = fltarr(n_elements(y))+0.01*min(y, /nan)
if not keyword_set(guess) then begin
  ind = where(x gt 0 and y gt 0)
  g = linear_fit(alog(x[ind]), alog(y[ind]), errors = errors[ind])
  a = [10e1^(-g[0]/g[1]), g[1]]
endif else a = guess

 for i = 0, 3 do begin
  fit = lmfit(x, y, a, $
            measure_errors = errors, /double, sigma = sigma, $
           function_name = 'powerlaw', conv = conv, chisq = chisq)
  if conv eq 1 then break
 endfor

  return, a
end
