function tpl_errinvar, x, y, sigma_x, sigma_y, convfail = convfail


  gain = 0.5

; First get an initial guess.
  fit = bces(alog(x), alog(y), xerr = alog(1+sigma_x/x), $
             yerr = alog(1+sigma_y/y))
  convfail = 1b

; Initialized parameters
; theta = [N_0, M_0, gamma]

  theta = [1, exp(fit[0]), fit[1]]
  vec = [transpose(x), transpose(y)]
  true_vec = vec
  v = [transpose(sigma_x), transpose(sigma_y)]^2
 for outer = 0L, 100000 do begin
    for inner = 0, 100 do begin
; First partials of fcn w.r.t. to variables
;      B = [(theta[2]+1)*theta[0]/theta[1]*(true_vec[0, *]/theta[1])^(theta[2]), $
 ;          transpose(dblarr(n_elements(x) )-1)]

;      fofx = theta[0]*((true_vec[0, *]/theta[1])^(theta[2]+1)-1)

      B = [theta[1]*theta[2]*(true_vec[0, *])^(theta[2]-1), $
           transpose(dblarr(n_elements(x) )-1)]
      fofx = theta[1]*(true_vec[0, *])^(theta[2])-theta[0]

      true_2 = vec-v*b/(total(v*b^2, 1)##[1, 1])*$
               (((fofx-true_vec[1, *])+$
                 transpose(total(B*(vec-true_vec), 1)))##[1, 1])
      delta = abs((true_2-true_vec)/true_vec)
      if total(delta gt 1e-6) eq 0 then goto, endinner
      true_vec = true_2
;      oplot, true_vec[0, *], true_vec[1, *]
    endfor
    print, 'Warning -- Inner loop failed to converge'
    endinner:
; Then, with the iterated "true_vec" calculate next step of parameter
; refinement. 

; Z is the matrix of partials w.r.t the parameters

;    Z = [(true_vec[0, *]/theta[1])^(theta[2]+1)-1, $
;         -theta[0]*(theta[2]+1)/theta[1]*(true_vec[0, *]/theta[1])^(theta[2]+1), $
;         theta[0]*(true_vec[0, *]/theta[1])^(theta[2]+1)*alog(true_vec[0, *]/theta[1])]

    null = true_vec[0, *]
    null[*] = -1

    Z = [null, (true_vec[0, *])^(theta[2]), $
         (theta[1]*(true_vec[0, *])^(theta[2])*alog(true_vec[0, *]))]
;    Z = [true_vec[0, *]^theta[1], theta[0]*true_vec[0, *]^theta[1]*$
;         alog(true_vec[0, *])]

    q =  total(Z*((transpose(total(B*(vec-true_vec), 1)))##[1, 1, 1])/$
               (total(V*B^2, 1)##[1, 1, 1]), 2)
  
    quotient = [1, 1, 1]#sqrt(total(v*b^2, 1))
    zmod = z/quotient
    G = zmod#transpose(zmod)

;    G = dblarr(2, 2)
    
;    G[0, 0] = total(z[0, *]^2/(total(v*b^2, 1)))
;    G[1, 0] = total(z[0, *]*z[1, *]/(total(v*b^2, 1)))
;    G[0, 1] = total(z[0, *]*z[1, *]/(total(v*b^2, 1)))
;    G[1, 1] = total(z[1, *]^2/(total(v*b^2, 1)))
    ginv = invert(g)
    newtheta = theta-ginv#q*gain
    delta_theta = abs((newtheta-theta)/theta)
    if total(delta_theta ge 0.5) gt 0 then begin
      gain = gain*0.5
    endif else begin
      if total(delta_theta gt 1e-6) eq 0 then goto, endouter
      theta = newtheta
      convfail = 0b
    endelse
  endfor
 print, 'Warning -- outer loop failed to converge'
  endouter:
  return, newtheta
end
