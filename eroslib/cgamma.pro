;$Id: cgamma.pro,v 1.1.1.1 2002/12/13 21:32:37 eros Exp $
;
; Copyright (c) 1994-2000, Research Systems, Inc.  All rights reserved.
; Except the part where I inserted a "1-"  that's all me.
;+
; NAME:
;       CGAMMA
;
; PURPOSE: 
;       This function computes the incomplete complementary gamma
;       function, Qx(a).
;
; CATEGORY:
;       Special Functions.
;
; CALLING SEQUENCE:
;       Result = cgamma(a, x)
;
; INPUTS:
;       A:    A positive scalar or array of type integer, float or double that
;             specifies the parametric exponent of the integrand.
;
;       X:    A positive scalar or array of type integer, float or double that
;             specifies the upper limit of integration.
;
; KEYWORD PARAMETERS:
;
;   DOUBLE = Set this keyword to force the computation to be done
;            in double precision.
;
;	EPS = relative accuracy, or tolerance.  The default tolerance
;	      is 3.0e-7 for single precision, and 3.0d-12 for double
;	      precision.
;
;   ITER = Set this keyword equal to a named variable that will contain
;          the actual number of iterations performed.
;
;   ITMAX = Set this keyword to specify the maximum number of iterations.
;           The default value is 100.
;
;   METHOD:  Use this keyword to specify a named variable which returns
;            the method used to compute the incomplete gamma function.
;            A value of 0 indicates that a power series representation
;            was used. A value of 1 indicates that a continued fractions
;            method was used.
;
; REFERENCE:
;       Numerical Recipes, The Art of Scientific Computing (Second Edition)
;       Cambridge University Press
;       ISBN 0-521-43108-5
;
; MODIFICATION HISTORY:
;       Hacked from IGAMMA to CGAMMA
;       Fri Jun 22 14:43:54 2001, Erik Rosolowsky <eros@cosmic>
;       Written by:  GGS, RSI, September 1994
;                    IGAMMA is based on the routines: gser.c, gcf.c, and
;                    gammln.c described in section 6.2 of Numerical Recipes,
;                    The Art of Scientific Computing (Second Edition), and is
;                    used by permission.
;       Modified:    GGS, RSI, January 1996
;                    Corrected the case of IGAMMA(a, 0) for a > 0.
;		     DMS, Sept, 1999, Added arrays, and more accurate
;			results for double.
;            CT, March 2000, added DOUBLE, ITER keywords.
;-

FUNCTION cgamma, a, x, $
	DOUBLE = double, $
	EPS = eps, $
	ITER = iter, $
	ITMAX = itmax, $
	METHOD = method

  on_error, 2

  iter = 0 ; zero iterations so far
  if min(a, /NAN) le 0 then message, 'A must be positive.'
  if min(x, /NAN) lt 0 then message, 'X must be greater than or equal to zero.'

  na = n_elements(a)
  nx = n_elements(x)
  n = na > nx  ; find largest
  dim = 0  ; assume scalar
  ; now find smallest nonscalar dimensions
  IF (SIZE(x,/N_DIMENSION) GT 0) AND (nx LE n) THEN BEGIN
	dim = SIZE(x,/DIMENSIONS)
	n = nx
  ENDIF
  IF (SIZE(a,/N_DIMENSION) GT 0) AND (na LE n) THEN BEGIN
	dim = SIZE(a,/DIMENSIONS)
	n = na
  ENDIF


  IF (N_ELEMENTS(double) LT 1) THEN $
	double = size(x,/type) eq 5 or size(a,/type) eq 5 $
  ELSE $
	double = KEYWORD_SET(double)

  one = double ? 1.0d0 : 1.0
  bad = double ? !values.d_nan : !values.f_nan
  y = n eq 1 ? bad : replicate(bad, n)
  method = n eq 1 ? 0 : intarr(n)
  ap = 0L
  xp = 0L

  if n_elements(eps) eq 0 then eps = double ? 3.0d-12 : 3.0e-7
  fpmin = double ? 1.0d-300 : 1.0e-30 ;Something really small
  if keyword_set(itmax) eq 0 then itmax = 100

  for i=0L, n-1 do begin        ;Each element
      xx = (double) ? DOUBLE(x[xp]) : x[xp]
      aa = (double) ? DOUBLE(a[ap]) : a[ap]
      IF (xx EQ 0) THEN BEGIN  ; avoid underflow
      	k = 0
      	y[i] = 0
      	GOTO, skip
      ENDIF
      if xx le (aa + one) then begin ;Series Representation.
          ap1 = aa
          sum = one / aa
          del = sum
          for k = 1L, itmax do begin
              ap1 = ap1 + one
              del = del * xx / ap1
              sum = sum + del
              if abs(del) lt abs(sum)*eps then begin
                  y[i] = one - sum * exp(-xx + aa * alog(xx) - lngamma(aa))
                  goto, skip
              endif
          endfor
      endif else begin          ;Continued Fractions.
          method[i] = 1
          b = xx + one - aa
          c = one / fpmin
          d = one / b
          h = d
          for k = 1L, itmax do begin
              an1 = -k * (k - aa)
              b = b + 2
              d = an1 * d + b
              if abs(d) lt fpmin then d = fpmin
              c = b + an1 / c
              if abs(c) lt fpmin then c = fpmin
              d = one / d
              del = d * c
              h = h * del
              if abs(del - 1) lt eps then begin
                  y[i] = (exp(-xx + aa * alog(xx) - lngamma(aa)) * h)
                  goto, skip
              endif
          endfor                ;Itmax
      endelse

; if we reach here, then it never converged...
      iter = itmax
      MESSAGE,'Failed to converge within given parameters.'

skip:
      iter = iter > k   ; keep largest # of iterations
      xp = (xp + 1) < (nx - 1)
      ap = (ap + 1) < (na - 1)
  endfor

  IF (dim[0] NE 0) THEN y = REFORM([y], dim, /OVERWRITE)
  return, y
end
