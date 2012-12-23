function gauss2dfun, x, y, p

; 2 D gaussian function for MPFIT 
 widx  = abs(p[2]) > 1e-20
 widy  = abs(p[3]) > 1e-20 
 xp    = x-p[4]          
 yp    = y-p[5]
 theta = p[6]
 c = cos(theta)
 s = sin(theta)
 u = ( (xp * (c/widx) - yp * (s/widx))^2 + $
       (xp * (s/widy) + yp * (c/widy))^2 )
 
  return,  p[0] + p[1] * exp(-0.5 * u )
end
