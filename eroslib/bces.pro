function bces, x1, x2, xerror = ex1, yerror = ex2, $
               covar = covar, error = errab, bootstrap = bootstrap, $
               weight = weight
;+
; NAME:
;   BCES
; PURPOSE:
;   Implements linear regression for correlated errors and intrinsic
;   scatter in the data (see 1996 ApJ 470, 706).
;
; CALLING SEQUENCE:
;   params = BCES(x, y, [xerror = xerror, yerror = yerror, covar =
;                        covar, error = errab, bootstrap = bootstrap])
;
;
; INPUTS:
;   X, Y -- Vectors containing measured points.
;
; KEYWORD PARAMETERS:
;   XERROR, YERROR -- the 1-sigma errors in those points
;   COVAR -- the covariance between the errors FOR EACH POINT
;   BOOTSTRAP -- Calculate the errors using the bootstrap method as
;                opposed to the covariance matrix.  Set this keyword
;                to the number of Monte Carlo Iterations to perform.
;                If =1 then N_data * 10 trials will be performed.
; OUTPUTS:
;   PARAMS -- 2 elt. vector containing y-intercept and slope.
;   ERROR -- 2 elt. vector containing the error in PARAMS.
;
; NOTES: This code only implements the least-squares bisector method
; for determining the best fit slope of the line.  See Isobe et
; al. (1992, ApJ, 364, 104) for more details.  This corresponds to
; BETA_3 in their discussion.
;
; MODIFICATION HISTORY:
;
;       Tue Mar 27 09:06:08 2007, Erik <eros@yggdrasil.local>
;           Fixed bug in variances.  Someone pointed this out and I've
;           lost their email.  Sorry!
;
;       Fri Aug 27 10:00:05 2004, <eros@master>
;		Added BOOTSTRAPping 
;
;       Thu Jul 29 13:23:25 2004, <eros@master>
;		Written.
;
;-

  


  if n_elements(x1) ne n_elements(x2) then begin
    message, 'Inputs must be the same size.', /con
    return, !values.f_nan
  endif

  if n_elements(covar) eq 0 then covar = fltarr(n_elements(x1))
  if n_elements(ex1) eq 0 then ex1 = fltarr(n_elements(x1))
  if n_elements(ex2) eq 0 then ex2 = fltarr(n_elements(x1))



  mx1 = mean(x1)
  mx2 = mean(x2)

  sxx =  (total((x1-mx1)^2)-total(ex1^2))
  syy =  (total((x2-mx2)^2)-total(ex2^2))
  sxy =  (total((x1-mx1)*(x2-mx2))-total(covar))

  if keyword_set(weight) and n_elements(ex1) eq n_elements(x1) and $
  n_elements(ex2) eq n_elements(x2) then begin
    mx1 = total(x1/ex1^2)/total(1/ex1^2)
    mx2 = total(x2/ex2^2)/total(1/ex2^2)
    mx1 = mean(x1)
    mx2 = mean(x2)
    sxx = total((x1-mx1)^2/ex1^2)/total(1/ex1^2);-total(ex1^2)
    syy = total((x2-mx2)^2/ex2^2)/total(1/ex2^2);-total(ex2^2)
    sxy = total((x1-mx1)*(x2-mx2)/(ex1*ex2))/total(1/(ex1*ex2));-total(covar)
    stop
  endif

; If the weight keyword is set, the then error weighted covariances
; are calculated instead.

  b1 = sxy/sxx

  varb1 = (total((x1-mx1)^2*(x2-b1*x1-mx2+b1*mx1)^2))/sxx^2

  b2 = syy/sxy

  varb2 = (total((x2-mx2)^2*(x2-b2*x1-mx2+b2*mx1)^2))/sxy^2         

  covb1b2 = (total(((x1-mx1)*(x2-mx2)*(x2-mx2-b1*(x1-mx1)))*$
                   (x2-mx2-b2*(x1-mx1))))/(b1*sxx^2)

  b3 = (b1*b2-1+sqrt((1+b1^2)*(1+b2^2)))/(b1+b2)
  varb3 = (b3^2/(b1+b2)^2/(1+b1^2)/(1+b2^2))*$
          ((1+b2^2)^2*varb1+2*(1+b1^2)*(1+b2^2)*covb1b2+$
           (1+b1^2)^2*varb2)


  a3 = (mx2-b3*mx1)
  
  g1 = b3/((b1+b2)*sqrt(1+b1^2)*sqrt(1+b2^2))

  vara3 = float(n_elements(x1))^(-2)*(total((x2-mx2-b3*(x1-mx1)-$
                                             n_elements(x1)*mx1*$
                                             (g1*(1+b2^2)/sxx*(x1-mx1)*$
                                              (x2-mx2-b1*(x1-mx1))+$
                                              (g1*(1+b1^2)/sxy*(x2-mx2)*$
                                               (x2-mx2-b2*(x1-mx1)))))^2))


  errab = sqrt([vara3, varb3])

  if keyword_set(bootstrap) then begin
    ntrials =  bootstrap eq 1 ? 10*n_elements(x1)-1 : bootstrap

    params = fltarr(ntrials, 2) 
    for k = 0, ntrials-1 do begin
      index = floor(randomu(seed, n_elements(x1))*n_elements(x1))
      params[k, *] = bces(x1[index], x2[index], $
                          xerror = ex1[index], yerror = ex2[index], $
                          weight = weight)
      
    endfor
    errab = [stdev(params[*, 0]), stdev(params[*, 1])]
    errab = [mad(params[*, 0]), mad(params[*, 1])]

  endif

  return, [a3, b3]
end
