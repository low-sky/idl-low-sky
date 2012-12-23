function pfunk, x, targprob = targprob

; Make my FUNC the PFUNK
; I wants to get FUNKED up.
  x = double(x)

  px = 0.5*cgamma(replicate(0.5, n_elements(x)) , x^2/2)-targprob
  return, px
end


