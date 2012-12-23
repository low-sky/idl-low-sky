function derivative, x, fname, itmax = itmax, $
                     tolerance = tolerance, _extra = extra, double = double, $
                     factor = factor
;+
; NAME:
;    derivative
; PURPOSE:
;    To rigorously calculate the one dimensional 
;    derivative of a named function at a specified point.
;
; CALLING SEQUENCE:
;    deriv = DERIVATIVE(x, FNAME [, itmax = itmax, tolerance =
;    tolerance, extra])
;
; INPUTS:
;    X -- The point at which the derivative is to be calulated
;    FNAME -- Named function to calculate the derivative.
; KEYWORD PARAMETERS:
;    TOLERANCE -- Fractional precision to calculate the derivative.
;    ITMAX -- Maximum number of iterations.   
;    FACTOR -- Factor by which step decreases each iteration.
; OUTPUTS:
;    DERIV -- The value of the derivative at the desired point.
;
; MODIFICATION HISTORY:
;       Written, cause IDL just don't do it.
;       Tue Oct 23 20:10:35 2001, Erik Rosolowsky <eros@cosmic>
;-


if not keyword_set(itmax) then itmax = 50
if not keyword_set(tolerance) then tolerance = 1d-4
if not keyword_set(factor) then factor = 1.4d

h = sqrt(abs(double(x))) > 0.2
tol = 1

if n_elements(extra) gt 0 then begin 
  
  deriv = (call_function(fname, x+h, _extra = extra)-$
           call_function(fname, x-h, _extra = extra))/(2*h)
  while tol gt tolerance do begin
    deriv_old = deriv
    h = h/factor
    deriv = (call_function(fname, x+h, _extra = extra)-$
             call_function(fname, x-h, _extra = extra))/(2*h)
    tol = abs((deriv-deriv_old)/deriv)
  endwhile
endif else begin
  deriv = (call_function(fname, x+h)-$
           call_function(fname, x-h))/(2*h)
  while tol gt tolerance do begin
    deriv_old = deriv
    h = h/factor
    deriv = (call_function(fname, x+h)-$
             call_function(fname, x-h))/(2*h)
    tol = abs((deriv-deriv_old)/deriv)
  endwhile
endelse

if not keyword_set(double) then deriv = float(deriv)
  return, deriv
end
