function dpa, x, y

; Compute the difference between angles, ignoring the wrap.


  dpa = atan(sin(x)*cos(y)-cos(x)*sin(y), $
             cos(x)*cos(y)+sin(x)*sin(y))

  return, dpa
end
