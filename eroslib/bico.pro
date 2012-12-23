function bico, n, k
;+
; NAME:
;   BICO
; PURPOSE:
;   Return the binomial coefficient n choose k
;
; CALLING SEQUENCE:
;   result=bico(n,k)
;
; INPUTS:
;   N,K -- arrays of integers.  Works for all values up to N=1029
;
; KEYWORD PARAMETERS:
;   none
;
; OUTPUTS:
;   N choose K with data type corresponding to the smallest that can
;   hold the value.
;
; MODIFICATION HISTORY:
;       Adapted from Numerical Recipes --
;       Fri Jun 22 10:57:21 2001, Erik Rosolowsky <eros@cosmic>
;-
on_error, 2
if n_elements(n) ne n_elements(k) then message, $
  'Input vectors must be the same size'

if total(k gt n) gt 0 then message, $
  'Elements in second vector must be smaller than those in first.'

L64 = 0b
result = (lngamma(n+1)-lngamma(k+1)-lngamma(n-k+1))

if max(result, /nan) gt 21 then L64 = 1b
if max(result, /nan) gt 88 then return, exp(double(result))
if max(result, /nan) gt 43 then return, exp(result)

  return, floor(0.5+exp(result), L64 = L64)
end
