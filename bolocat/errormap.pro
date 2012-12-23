function errormap, noise, nh, weight

;  noise = mrdfits(errormap, 0, hd)
  
;  em = bolocam_emap2(noise, box = 1)

  wterr = median(1/sqrt(weight), 11)
  em = median(abs(noise), 11)/0.6745

  ratio = em/wterr
  use = where(ratio ne 0, ct)
  ratio = median(ratio[use])

  flag = em gt wterr*ratio*1.5
  flagind = where(flag, ct)
  if ct gt 0 then em[flagind] =  (wterr*ratio*2)[flagind]

  bad = where(nh le 3 or (nh ne nh), ct)
  rind = where(nh le 5)
  if ct gt 0 then em[bad] = median(em[rind])

  filter = savgol2d(nx = 101, ny = 101)
  error = convol(em, filter, /edge_trun, invalid = 0, /nan)
  
  if keyword_set(nh) then begin
    edge = nh le 3
    edge = remove_islands(edge, 10)
    relt = 3
    elt = shift(dist(2*relt+1, 2*relt+1), relt, relt) le relt
    edge = 1b-(erode(1b-edge, elt)) or (nh ne nh)
    badind2 = where(edge, ct2)
    if ct2 gt 0 then error[badind2] = !values.f_nan
    error[bad] = !values.f_nan
  endif
  return, error
end
