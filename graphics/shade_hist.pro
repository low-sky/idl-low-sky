pro shade_hist, data, min = min, max = max, binsize = binsize, $
                color = color, _extra = ex, log = log, histogram = h, $
                centers = centers, nofill = nofill, $
                overplot = overplot, line_fill = line_fill
;+
; NAME:
;     SHADE_HIST
; PURPOSE:
;     plot a histogram with each bar filled in with specified color.
;
; CALLING SEQUENCE:
;   shade_hist, data
;
; INPUTS:
;   DATA -- a dataset for the histogramming.
;
; KEYWORD PARAMETERS:
;   MIN -- The minimum value of the data to be included.
;   MAX -- The maximum value of the data to be included.
;   BINSIZE -- Size of the bins for the histogram.  Defaults to 10
;              bins across the data range.
;   COLOR -- Color in current color table to use for the histogram.
;   HISTOGRAM -- Named variable to contain the histogram information
;                when returned.
;   LOG -- 
;   CENTERS -- Set to a variable to contain the values of the bin centers.
; OUTPUTS:
;   Plot in current plot device.
;
; MODIFICATION HISTORY:
;       Documented --
;       Wed May 30 13:20:37 2001, Erik Rosolowsky <eros@cosmic>
;-

  if not n_elements(min) eq 0 then min = min(data)
  if not n_elements(max) eq 0 then max = max(data)
  if not keyword_set(binsize) then binsize = (max-min)/10.
  if n_elements(color) eq 0  then color = !d.table_size*0.66

  dx = binsize
  h = histogram(data, min = min, max = max, binsize = binsize)
  if keyword_set(log) then begin
    h = alog10(h)
    ind = where((finite(h) ne 1), ct)
    if ct gt 0 then h[ind] = 0
  endif
  
  nbins = (max-min)/binsize
  x= (findgen(nbins+1))*dx+min 
  if n_elements(h) lt n_elements(x) then h = [h, 0]
  centers = (x+dx/2)[indgen(n_elements(h))]

  bottom = 0

  xvals = [x[0], reform([transpose(x), $
                         transpose(x+dx)], 2*n_elements(x)), max(x+dx), x[0]]
  yvals = [0, reform(transpose(h#[1, 1]), 2*n_elements(h)), bottom, bottom]


;xvals = fltarr(n_elements(h)*2+3)
  if not keyword_set(xrange) then xrange = [min(xvals), max(xvals)]

  if not keyword_set(overplot) then  $
     plot, x, h, ps = 10, /nodata, _extra = ex, xrange = xrange

  bottom = !y.crange[0]
  if !y.type then bottom = 1d1^bottom
  yvals = [0, reform(transpose(h#[1, 1]), 2*n_elements(h)), bottom, bottom]


  if not keyword_set(nofill) then begin
    polyfill, xvals, yvals, color = color, _extra = ex, line_fill = line_fill
    oplot, xvals, yvals
  endif else begin
    oplot, xvals, yvals, color = color
  endelse

  for i = 0, n_elements(xvals)-1 do begin
    plots, xvals[i], bottom, _extra = ex
    plots, xvals[i], yvals[i], /continue, _extra = ex
  endfor



  return
end
