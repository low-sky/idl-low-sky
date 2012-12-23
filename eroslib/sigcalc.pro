function erf0, x, erftarg = erftarg
; ERF0: Subroutine used by SIGCALC.pro 
; to find where error function equals a given value.
  return, errorf(x)-erftarg
end

function sigcalc, prob, tol = tol
;+
; NAME:
;   SIGCALC
; PURPOSE:
;   Returns the argument of P(x) that gives the input probability.
;
; CALLING SEQUENCE:
;   sigma = SIGCALC(probability)
;
; INPUTS:
;   PROBABILITY -- A probability for which a "sigma" is calculated.
;
; KEYWORD PARAMETERS:
;   TOL -- Tolerance to which SIGMA should be calculated.  Defaults to 0.01.
;
; REQUIRES:
;   ERF0.pro
; OUTPUTS:
;   SIGMA -- the length out to which you must integrate a Gaussian to
;            give the desired proability.
;
; MODIFICATION HISTORY:
;       Written --
;       Fri Jun 8 17:53:21 2001, Erik Rosolowsky <eros@cosmic>
;-

if prob gt 1 or prob lt 0 then begin
  message, 'Invalid Probability.  Must be 0 <= prob <= 1.', /con
  return, 0
endif

erftarg = 2*prob-1
erf = 0.d
sig = 0.d
while erf lt erftarg do begin
  sig = sig+1
  erf = errorf(sig)
endwhile 

sigma_out = transcend2(sig-1, sig, fname = 'erf0', erftarg = erftarg)

  return, sqrt(2.)*sigma_out
end
