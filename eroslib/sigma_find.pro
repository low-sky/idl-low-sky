function sigma_find, prob

; Finds the value of a normal deviate which has a given
; probability of occuring.
  nil = fx_root([-1, 0, 1], 'pfunk', targprob = prob)  
  return, nil
end
