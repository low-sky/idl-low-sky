function dilator, image, kernel, constraint = constraint, $
                  loop = loop

  if keyword_set(loop) then looper = 1 else looper = 0

; Input image with pixel assignments and indices of valid maxima
; Output: dilation with conflicts assigned to nearest kernels.

; Generate 1D pixel distance dilator
  structure = bytarr(3, 3)
  structure[1, *] = 1b
  structure[*, 1] = 1b
  if n_elements(constraint) eq 0 then  imout = image else $
    imout = image*constraint
  sz = size(image)
;  m = (image gt 0)

  repeat begin
    if n_elements(new_m) eq 0 then m = (image gt 0) else m = imout gt 0
    new_m = dilate(m, structure)
    if n_elements(constraint) gt 0 then new_m = new_m*constraint
    additions = new_m-m
    ind_adds = where(additions eq 1, break_ct)
    if break_ct gt 0 then begin
      nbrs_adds = replicate(1, 4)#ind_adds+$
                  [1, -1, -sz[1], sz[1]]#replicate(1, n_elements(ind_adds))

      vals = imout[nbrs_adds]
      nbval = lonarr(1, n_elements(ind_adds)) 
      nnbrs = intarr(1, n_elements(ind_adds))
      for k = 0, 3 do begin
        nnbrs = nnbrs+(vals[k, *] ne nbval and vals[k, *] ne 0)
        nbval = nbval > vals[k, *]
      endfor
      if n_elements(kernels) gt 0 then begin
        ind = where(nnbrs gt 1, ct)
        if ct gt 0 then begin
          xpos = ind_adds[ind] mod sz[1]
          ypos = ind_adds[ind] / sz[1]
          x_kernel = kernel mod sz[1]
          y_kernel = kernel / sz[1]
          for k = 0, ct-1 do begin
            possible = vals[*, ind[k]]
            possible = possible[where(possible gt 0)]
            possible = possible[uniq(possible, sort(possible))]
            darr = sqrt((xpos[k]-x_kernel[possible])^2+$
                        (ypos[k]-y_kernel[possible])^2)
            null = min(darr, winner)
            imout[ind_adds[ind[k]]] = possible[winner]
          endfor
        endif
        ind = where(nnbrs eq 1, ct)
        if ct gt 0 then imout[ind_adds[ind]] = nbval[ind]
      endif else begin
        imout[ind_adds] = nbval
      endelse
    endif
  endrep until (break_ct eq 0 or looper eq 0)
  if n_elements(constraint) eq n_elements(imout) then imout = imout*constraint
  return, imout
end
