function pl_errinvar, x, y, sigma_x, sigma_y

; This fcn fits a power law function to a set of points.  Idealized
; for use in mass spectra, the index is defined to be 1 lower than the
; index of the fit distribution.  That is the algorithm fits the fcn
; y = p[0]*x^(p[1]+1)
; for parameters p.

  gain = 0.1

; First get an initial guess.
  fit = bces(alog(x), alog(y), xerr = alog(1+sigma_x/x), $
             yerr = alog(1+sigma_y/y))


; Initialized parameters
; theta = [M_0, gamma]

  theta = [exp(fit[0])^(-1/fit[1]), fit[1]-1]
  vec = [transpose(x), transpose(y)]
  true_vec = vec
; Covariance matrix for all points here.
  v = [transpose(sigma_x), transpose(sigma_y)]^2.


 for outer = 0, 1000 do begin
    for inner = 0, 100 do begin
; First partials of fcn w.r.t. to variables
      B = [(theta[1]+1)/theta[0]*(true_vec[0, *]/theta[0])^(theta[1]), $
           transpose(dblarr(n_elements(x) )-1)]
      fofx = ((true_vec[0, *]/theta[0])^(theta[1]+1))
      true_2 = vec-v*b/(total(v*b^2, 1)##[1, 1])*$
               (((fofx-true_vec[1, *])+$
                 transpose(total(B*(vec-true_vec), 1)))##[1, 1])
      delta = abs((true_2-true_vec)/true_vec)
      if total(delta gt 1e-6) eq 0 then goto, endinner
      true_vec = true_2
    endfor
    print, 'Warning -- Inner loop failed to converge'

    endinner:


; Then, with the iterated "true_vec" calculate next step of parameter
; refinement. 


; Z is the matrix of partials w.r.t the parameters

    Z = [-(theta[1]+1)/theta[0]*(true_vec[0, *]/theta[0])^(theta[1]+1), $
         (true_vec[0, *]/theta[0])^(theta[1]+1)*alog(true_vec[0, *]/theta[0])]

    q =  total(Z*((transpose(total(B*(vec-true_vec), 1)))##[1, 1])/$
               (total(V*B^2, 1)##[1, 1]), 2)
  
    quotient = [1, 1]#sqrt(total(v*b^2, 1))
    zmod = z/quotient
    G = zmod#transpose(zmod)

    ginv = invert(g)
    newtheta = theta-ginv#q*gain
    delta_theta = abs((newtheta-theta)/theta)
    if total(delta_theta ge 0.5) gt 0 then begin
      gain = gain*0.5
    endif else begin
      if total(delta_theta gt 1e-6) eq 0 then goto, endouter
      theta = newtheta
    endelse
  endfor
  print, 'Warning -- Outer loop failed to converge.'
  endouter:

  return, newtheta
end
