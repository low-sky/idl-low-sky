function binavg2d, xin, yin, zin, $
                   _extra = ex, nbins = nbins, binsize = binsize, $
                   histogram = hist, median = median, $
                   xaxis = xaxis, yaxis = yaxis, xlog = xlog, ylog = ylog

  x = reform(xin, n_elements(xin))
  y = reform(yin, n_elements(yin))
  z = reform(zin, n_elements(zin))




  if n_elements(nbins) eq 0 then nbins = 100.

  if keyword_set(xlog) then x = alog10(x)
  if keyword_set(ylog) then y = alog10(y)
  
  minvec = [min(x, /nan), min(y, /nan)]
  maxvec = [max(x, /nan), max(y, /nan)]

  goodindex = where(x ge minvec[0] and x le maxvec[0] and $
                    y ge minvec[1] and y le maxvec[1], ctr)

  v = ([transpose(x[goodindex]), transpose(y[goodindex])])
  hist = hist_nd(v, binsize, min = minvec, max = maxvec, $
                 nbins = nbins, rev = ri)
                    
  if ctr eq 0 then return, !values.f_nan

  v = ([transpose(x[goodindex]), transpose(y[goodindex])])
  hist = hist_nd(v, binsize, min = minvec, max = maxvec, $
                 nbins = nbins, rev = ri)
  sz = size(hist)
  xaxis = findgen(sz[1])*binsize[0]+minvec[0]
  yaxis = findgen(sz[2])*binsize[1]+minvec[1]

  if keyword_set(xlog) then begin
    xaxis = 1e1^xaxis
    x = 1e1^x
    minvec[0] = 1e1^minvec[0]
    maxvec[0] = 1e1^maxvec[0]
  endif

  if keyword_set(ylog) then begin
    yaxis = 1e1^yaxis
    y = 1e1^y
    minvec[1] = 1e1^minvec[1]
    maxvec[1] = 1e1^maxvec[1]
  endif
  sz = size(hist)
  map = fltarr(sz[1], sz[2])+!values.f_nan
  ind = where(hist gt 0, ctr)
  if ctr gt 0 then begin
    for k = 0L, ctr-1 do begin
      if keyword_set(median) then $
        map[ind[k]] = median(z[ri[ri[ind[k]]:ri[ind[k]+1]-1]]) else $
          map[ind[k]] = mean(z[ri[ri[ind[k]]:ri[ind[k]+1]-1]])
    endfor
  endif
  
  


  return, map
end
