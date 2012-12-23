function firstguess, v,t
  

  p = 0
  
  ckms = 2.99792458d5
  nelts = n_elements(v) 
  
  voff_lines = [19.8513, $
                19.3159, $
                7.88669, $
                7.46967, $
                7.35132, $
                0.460409, $
                0.322042, $
                -0.0751680, $
                -0.213003, $ 
                0.311034, $
                0.192266, $
                -0.132382, $
                -0.250923, $
                -7.23349, $
                -7.37280, $
                -7.81526, $
                -19.4117, $
                -19.5500]

  tau_wts = [0.0740740, $
             0.148148, $
             0.0925930, $
             0.166667, $
             0.0185190, $
             0.0370370, $
             0.0185190, $
             0.0185190, $
             0.0925930, $
             0.0333330, $
             0.300000, $
             0.466667, $
             0.0333330, $
             0.0925930, $
             0.0185190, $
             0.166667, $
             0.0740740, $
             0.148148]

;  lines = (1-voff_lines/ckms)*23.6944955d0

  kernel = fltarr(n_elements(t))
  xax = findgen(n_elements(t)) 
  width = 15
  for k = 0,n_elements(voff_lines)-1 do begin
     kernel = kernel+exp(-(v-voff_lines[k])^2/(2*1.0^2))*tau_wts[k]
  endfor
  
  lags = convolve(t,kernel,/correl)
  lags = c_correlate(t,kernel,findgen(nelts)-nelts/2)

  null = max(lags,hitlag)
  shift = hitlag - nelts/2

  null = min(abs(v),v0)
  vobj = v[v0-shift]
;  nuobj = nu[v0-shift]-23.6944955d0
  tautex = t[v0-shift]*2 > mad(t)
  
  ind = where(abs(xax-v0+shift) lt 30)
  dx =xax[ind]-v0+shift
  sigv = sqrt(total((dx)^2*t[ind])/total(t[ind])>0.1^2)
  dv = abs(median(v-shift(v,1)))
  sigv = sigv*dv

  p = double([20.0, tautex, sigv>0.08, vobj])

  return, p
end
