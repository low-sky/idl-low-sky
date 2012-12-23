pro histcorners, data, _extra = ex, x = x, y = y, $
                 histogram = histogram, binsize = binsize, min = min, $
                 max = max, omin = omin, omax = omax, $
                 close = close, clip = clip, bars = bars
;+
; NAME:
;   HISTCORNERS
; PURPOSE:
;   Return, in DATA coordinates, the corners of a histogram (PS=10)
;
; CALLING SEQUENCE:
;   HISTCORNERS, data, x = x, y = y, [ histogram = histogram, 
;               histogram keywords]
;
; INPUTS:
;   DATA -- a vector of data values.
;
; KEYWORD PARAMETERS:
;   HISTOGRAM -- The results of the IDL histogram function.
;   CLOSE -- Close the histogram along the bottom.  The default is to
;            leave it open.
;   CLIP -- Clip the plot points to the current plotting window
;           (esp. useful with POLYFILL)  
;   BARS -- Instead of the 2 corners of each bin, include 4 corners,
;           which draws bars on the histogram when plot.
; OUTPUTS:
;   X, Y -- The X and Y values of a PS=10 histogram for overplotting.
;
; MODIFICATION HISTORY:
;
;       Fri Sep 3 13:39:39 2004, <eros@master>
;		Written
;
;-


  histogram = histogram(data, min = min, max = max, binsize = binsize, $
                        omin = omin, omax = omax)
  
  x0 = findgen(n_elements(histogram))*binsize+omin < omax
  x1 = x0+binsize < omax
  
  

  x = [x0, x0]
  ind = lindgen(n_elements(x0))
  x[2*ind] = x0
  x[2*ind+1] = x1
  y = [histogram, histogram]
  y[2*ind] = histogram
  y[2*ind+1] = histogram
  x = [x[0], x, x[n_elements(x)-1]]
  y = [0, y, 0]
  if keyword_set(close) then begin
    x = [x, x[0]]
    y = [y, 0]
  endif

  if keyword_set(bars) then begin
    x = dblarr(n_elements(x0)*6)
    y = lonarr(n_elements(x0)*6)
    x[6*ind] = x0
    y[6*ind] = histogram
    x[6*ind+1] = x1
    y[6*ind+1] = histogram
    x[6*ind+2] = x1
    y[6*ind+2] = 0
    x[6*ind+3] = x0
    y[6*ind+3] = 0
    x[6*ind+4] = x0
    y[6*ind+4] = histogram
    x[6*ind+5] = x1
    y[6*ind+5] = histogram
  endif

  if keyword_set(clip) then begin
    x = (x > (!x.crange[0] < !x.crange[1])) < (!x.crange[0] > !x.crange[1])
    y = (y > (!y.crange[0] < !y.crange[1])) < (!y.crange[0] > !y.crange[1])
  endif



  return
end
