function p, x
  
; Normal probability distribution function.  Calculates probability of
; a normal deviate being X sigma or higher.

  x = double(x)
  px = (0.5*cgamma(0.5, x^2/2))
  return, px
end
