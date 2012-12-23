pro cbar, min = minval, max = maxval, _ref_extra = ex, reserve = reserve

; Assume on the side
  defsysv, '!red', exists = exists
  if exists then reserve = 12
  if n_elements(reserve) eq 0 then reserve = 0

  startx = !x.window[1]
  starty = !y.window[0]
  finy = !y.window[1]
  dx = 0.95-!x.window[1]


  tn = replicatE(' ', 20)

  vector = ((findgen(256-reserve))/(256-reserve-1)*$
                          (maxval-minval)+minval)

  mat = replicate(1, 10)#vector
  disp, mat, findgen(10), vector, $
        pos = [startx+0.1*dx, starty, startx+0.6*dx, finy], /noerase, $
        min = minval, max = maxval, xticklen = 1e-6, xtickname = tn, $
        ytickname = tn
  axis, yaxis = 1, _extra = ex, yst = 1
  

  

  return
end
