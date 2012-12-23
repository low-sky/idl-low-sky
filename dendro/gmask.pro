function gmask, data, sig, grow, nonuniform = nonuniform, $
                error = err, width = width

  if n_elements(sig) eq 0 then sig = 3
  if n_elements(grow) eq 0 then grow = 2

  if n_elements(err) eq 0 then begin 
    if keyword_set(nonuniform) then err = sigma_cube(data, width = width) $
    else err = mad(data)
  endif
  mask = data gt sig*err
  mask = (mask*(shift(mask, 0, 0, -1)+shift(mask, 0, 0, 1)) gt 0)
  growmask = data gt grow*err
  growmask = (growmask*(shift(growmask, 0, 0, -1)+shift(growmask, 0, 0, 1)) gt 0)
  mask = dilate_mask(mask, constraint = growmask)

  return, mask
end
