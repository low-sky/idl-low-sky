function pcorr, r2in, nn

; Evaluate probablilty of correlation coefficient being larger than
; R^2 given N data points


  prob = fltarr(n_elements(r2in), n_elements(nn)) 

  for ii = 0, n_elements(r2in)-1 do begin 
    for j = 0, n_elements(nn)-1 do begin 
      n = double(nn[j])
      r2 = r2in[ii]
      i = floor(0.5*(n-2))
      k = dindgen(i+1)
      vec = (-1)^k*exp(lngamma(i+1)-lngamma(i-k+1)-lngamma(k+1))*$
            sqrt(r2)^(2*k+1)/(2*k+1)  
      prob[ii, j] = 1-2/sqrt(!pi)*exp(lngamma((n+1)/2)-$
                                      lngamma(n/2))*total(vec)
      
    endfor
  endfor
    return, prob
end
