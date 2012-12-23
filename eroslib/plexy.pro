function plexy, x, y, sigma_x, sigma_y, $
                guess = fit, xout = xout, yout = yout, $
                error = error, bootiter = bootiter

  gain = 0.1

; First get an initial guess.
  if n_elements(fit) eq 0 then begin 
    fit = bces(alog(x), alog(y), xerr = alog(1+sigma_x/x), $
               yerr = alog(1+sigma_y/y))
    theta = [exp(fit[0]), fit[1]]
    endif else theta = fit
  vec = [transpose(x), transpose(y)]
  true_vec = vec
  v = [transpose(sigma_x), transpose(sigma_y)]

 for outer = 0, 1000 do begin

    for inner = 0, 100 do begin
; First partials of fcn w.r.t. to variables
      B = [theta[1]*theta[0]*(true_vec[0, *])^(theta[1]-1), $
           transpose(dblarr(n_elements(x) )-1)]
      fofx = theta[0]*(true_vec[0, *])^(theta[1])
      true_2 = vec-v*b/(total(v*b^2, 1)##[1, 1])*$
               (((fofx-true_vec[1, *])+$
                 transpose(total(B*(vec-true_vec), 1)))##[1, 1])
      delta = abs((true_2-true_vec)/true_vec)
      if total(delta gt 1e-6) eq 0 then goto, endinner
      true_vec = true_2


    endfor


    endinner:
;      oplot, true_vec[0, *], true_vec[1, *], ps = 8, color = !red

; Then, with the iterated "true_vec" calculate next step of parameter
; refinement. 


; Z is the matrix of partials w.r.t the parameters

    Z = [(true_vec[0, *])^(theta[1]), $
         (theta[0]*(true_vec[0, *])^(theta[1])*alog(true_vec[0, *]))]

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
  endouter:
 xout = true_vec[0, *]
 yout = true_vec[1, *]

 if n_elements(bootiter) gt 0 then begin
   trialfit = fltarr(2, bootiter)
   for zzz = 0, bootiter-1 do begin
     nelts = n_elements(x) 
     trial_index = floor(randomu(seed, nelts)*nelts)
     trial_x = x[trial_index]
     trial_y = y[trial_index]
     trial_sigx = sigma_x[trial_index]
     trial_sigy = sigma_y[trial_index]
     trialfit[*, zzz] = plexy(trial_x, trial_y, $
                              trial_sigx, trial_sigy)

   endfor
   error = [mad(trialfit[0, *]), mad(trialfit[1, *])]
 endif


 return, newtheta
end
