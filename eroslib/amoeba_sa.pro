Function amotry_sa, p, y, psum, func, ihi, fac, temperature = temperature, $
                    upper = p_u, lower = p_l
; Extrapolates by a factor fac through the face of the simplex, across
; from the high point, tries it and replaces the high point if the new
; point is better.

  compile_opt hidden
  fac1 = (1.0 - fac) / n_elements(psum)
  fac2 = fac1  - fac
  ptry = psum * fac1 - p[*, ihi] * fac2 > p_l < p_u
  ytry = call_function(func, ptry)
  ytry = ytry+temperature*alog(randomu(seed, 1)) 
; Subtract a deviate of scale Temp

;Eval fcn at trial point
  if (ytry lt y[ihi])[0] then begin  ;If its better than highest, replace highest
    y[ihi] = ytry
    psum = psum + ptry - p[*, ihi]
    p[0, ihi] = ptry
  endif
  return, ytry
end


Function Amoeba_sa, ftol, FUNCTION_NAME = func, FUNCTION_VALUE = y, $
                    NCALLS = ncalls, NMAX = nmax, P0 = p0, $
                    SCALE = scale, SIMPLEX = p, $
                    temperature = temperature, upper = p_u, lower = p_l
;+
; NAME:
;	AMOEBA_SA
;
; PURPOSE:
;	Multidimensional minimization of a function FUNC(X), where
;	X is an N-dimensional vector, using the downhill simplex
;	method with simulated annealing.
;
;	This routine is based on the AMOEBA routine, Numerical
;	Recipes in C: The Art of Scientific Computing (Second Edition), Page
;	411.  Simluated Annealing added by EWR from p. 444ff in NR.
;	RSI likely retains rights to this code.
;
; CALLING SEQUENCE:
;	Result = AMOEBA_SA(Ftol, ....)
; INPUTS:
;    FTOL:  the fractional tolerance to be achieved in the function
;	value.  e.g. the fractional decrease in the function value in the
;	terminating step.  This should never be less than the
;	machine's single or double precision.
; KEYWORD PARAMETERS:
;    As per AMOEBA.PRO from RSI with additional keywords as follows:
;    TEMPERATURE -- Numerical value for the temperature.
;    P_L, P_U -- Lower and Upper bounds for string of
;                parameter values if desired to bound the search space
;                (often desirable in simulated annealing)
;
; PROCEDURE:
;    AMOEBA_SA is meant to be called in succession for a range of
;    values of TEMPERATURE (see NR for more detailed discussion) and
;    the results of each minimization passed to the next iteration
;    with a lower value of temperature.
;
; MODIFICATION HISTORY:
;
;       Mon Feb 27 12:17:47 2006, Erik Rosolowsky
;<erosolow@asgard.cfa.harvard.edu>
;       Documented the simulated annealing.
;
;		 DMS, May, 1996. Written.  -
;
;-


  if n_elements(p_u) eq 0 then p_u = $
    replicate(!values.f_infinity, n_elements(p0)) 
  if n_elements(p_l) eq 0 then p_l = $
    replicate(-!values.f_infinity, n_elements(p0)) 

  if keyword_set(scale) then begin ;If set, then p0 is initial starting pnt
    ndim = n_elements(p0)
    p = p0 # replicate(1.0, ndim+1)
    for i = 0, ndim-1 do p[i, i+1] = p0[i] + scale[i < (n_elements(scale)-1)]
  endif

  s = size(p)
  if s[0] ne 2 then message, 'Either (SCALE,P0) or SIMPLEX must be initialized'
  ndim = s[1]			;Dimensionality of simplex
  mpts = ndim+1			;# of points in simplex
  if n_elements(func) eq 0 then func = 'FUNC'
  if n_elements(nmax) eq 0 then nmax = 5000L

  y = replicate(call_function(func, p[*, 0]), mpts) ;Init Y to proper type
  for i = 1, ndim do y[i] = call_function(func, p[*, i]) ;Fill in rest of the vals
  ncalls = 0L
  psum = total(p, 2)

  while ncalls le nmax do begin ;Each iteration
    y = y-temperature*alog(randomu(seed, n_elements(y)))
    s = sort(y)
    ilo = s[0]                  ;Lowest point
    ihi = s[ndim]		;Highest point
    inhi = s[ndim-1]            ;Next highest point
    d = abs(y[ihi]) + abs(y[ilo]) ;Denominator = interval
    if d ne 0.0 then rtol = 2.0 * abs(y[ihi]-y[ilo])/d $
    else rtol = ftol / 2.       ;Terminate if interval is 0

    if rtol lt ftol or ncalls eq nmax then begin ;Done?
      t = y[0] & y[0] = y[ilo] & y[ilo] = t ;Sort so fcn min is 0th elem
      t = p[*, ilo] & p[*, ilo] = p[*, 0] & p[*, 0] = t
      print, ncalls
      return, t                 ;params for fcn min
    endif
    
    ncalls = ncalls + 2
    ytry = amotry_sa(p, y, psum, func, ihi, -1.0, temperature = temperature, $
                     upper = p_u, lower = p_l)
    if ytry le y[ilo] then ytry = amotry_sa(p, y, psum, func, ihi, $
                                            2.0, temperature = temperature, $
                                           upper = p_u, lower = p_l) $
    else if ytry ge y[inhi] then begin
      ysave = y[ihi]
      ytry = amotry_sa(p, y, psum, func, ihi, 0.5, $
                       temperature = temperature, $
                       upper = p_u, lower = p_l)
      if ytry ge ysave then begin
        for i = 0, ndim do if i ne ilo then begin
          psum = 0.5 * (p[*, i] + p[*, ilo])
          p[*, i] = psum
          y[i] = call_function(func, psum)
        endif
        ncalls = ncalls + ndim
        psum = total(p, 2)
      endif                     ;ytry ge ysave
    endif else ncalls = ncalls  - 1
  endwhile
  t = y[0] & y[0] = y[ilo] & y[ilo] = t ;Sort so fcn min is 0th elem
  t = p[*, ilo] & p[*, ilo] = p[*, 0] & p[*, 0] = t
  print, ncalls
  return, t                 
end
