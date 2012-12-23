function newt, xinit, fname, itmax = itmax, tol = tol, _extra = extra

;+
; NAME:
;  NEWT
; PURPOSE:
;   This mostly finds roots by Newton's method.  Mostly.
;
; CALLING SEQUENCE:
;  root = NEWT(x0, FNAME [, itmax=itmax, tol=tol])
;
; INPUTS:
;  x0 -- Guess at initial x value
;  FNAME -- Name of function to get a root for.
; KEYWORD PARAMETERS:
;   ITMAX -- max number of iterations to search for a root
;   TOL -- tolerance for error in root value
;   Extra keywords passed to function FNAME
; OUTPUTS:
;  ROOT -- the root.  We hope.
;
; MODIFICATION HISTORY:
;       Written
;       Wed Oct 24 10:10:03 2001, Erik Rosolowsky <eros@cosmic>
;-

if not keyword_set(itmax) then itmax = 50
if not keyword_set(tol) then tol = 1e-4

iter = 0
toler = 0.5
x = xinit

if n_elements(extra) gt 0 then begin  
  y = call_function(fname, xinit, _extra = extra)
  while (toler gt tol) do begin
    xold = x    
    x = x-y/derivative(x, fname, _extra = extra)
    if y gt derivative(x, fname, _extra = extra) then begin
      message, "Newton's method failed.  Restorting to Bisection.",/con
      return, bisection(xinit, fname, _extra = extra) 
    endif
    y = call_function(fname, x, _extra = extra)
    toler = abs(xold-x)
    iter = iter+1
  endwhile
endif else begin
  y = call_function(fname, xinit)
  while (toler gt tol) do begin
    xold = x
    x = x-y/derivative(x, fname)
    if y gt derivative(x, fname) then begin
      message, "Newton's method failed.  Restorting to Bisection.",/con
      return, bisection(xinit, fname)
    endif
    y = call_function(fname, x)
    toler = abs(xold-x)
    iter = iter+1
  endwhile
endelse
  return, x
end

