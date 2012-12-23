pro binplot, xin, yin, _extra = ex, nbins = nbins, binsize = binsize, $
             xlog = xlog, ylog = ylog, xaxis = xaxis, yaxis = yaxis, $
             hist = hist, minlevel = minlevel, psym = psym, lowind = lowind, $
             logstretch = logstretch, xstyle = xstyle, ystyle = ystyle, $
             xrange = xrange, yrange = yrange, zvalues = zvalues, $
             zavg = zavg, title = title
;+
; NAME:
;    BINPLOT
; PURPOSE:
;    For scatter plots with large numbers of data, this creates a
;    grayscale histogram for the data and plots it on the plot axes
;    with the option of plotting individual points for low density points.
;
; CALLING SEQUENCE:
;    BINPLOT, x, y [,nbins = nbins, binsize = binsize, hist = hist, $
;                   minlevel = minlevel, lowind = lowind, /logstretch,
;                   xaxis = xaxis, yaxis = yaxis]
;                  
; INPUTS:
;    X, Y -- The X and Y values of the plot.
;
; KEYWORD PARAMETERS:
;    NBINS -- A 1 or 2 element vector giving the number of bins along
;             each direction.
;    BINSIZE -- A 1 or 2 element vector giving the binsize.
;    MINLEVEL -- The minimum number of points to include in the
;                histogram.  Binst with fewer points than this are
;                plotted individually.
;    LOGSTRETCH -- Plot the grayscale histogram on a log stretch.
;    Should accept all DISP.pro and PLOT keywords as well.
; OUTPUTS:
;    Pretty Pictures.
;
; OPTIONAL OUTPUTS:
;    HIST -- Named valiable to contain the histogram used for 
;            the plot (helpful for contouring the data).
;    XAXIS, YAXIS -- the X and Y axes of HIST.
;    LOWIND -- inidices of points in low-density bins within the
;              original X and Y vectors.
; MODIFICATION HISTORY:
;       
;       Straightened out some axis issues.  Passed more keywords
;       around to make stuff flexible.
;	Thu Mar  2 15:22:27 2006, Erik R. 
;       
;       Documented.
;	Sat Feb 18 12:20:52 2006, Erik R.
;-


  if n_elements(xstyle) eq 0 then xstyle = 0
  if n_elements(ystyle) eq 0 then ystyle = 0
  if n_elements(minlevel) eq 0 then minlevel = 0
  if n_elements(psym) eq 0 then psym = 3

  if n_elements(xin) eq 0 or n_elements(yin) eq 0 then begin
   message, 'BINPLOT, x, y, [keywords]', /con
   return
 endif

  if n_elements(xin) ne n_elements(yin) then begin
    message, 'Number of elements in X and Y vectors must be equal!', /con
    return
  endif

; Bins points in a plot

  x = reform(xin, n_elements(xin))
  y = reform(yin, n_elements(yin))


  if n_elements(nbins) eq 0 then nbins = [100., 100.]

  if n_elements(title) gt 0 then titledumb = ' ' else titledumb = ''
  plot, x, y, /nodata, _extra = ex, xstyle = (xstyle or 4), $
        ystyle = (ystyle or 4), $
        xlog = xlog, ylog = ylog, xrange = xrange, yrange = yrange, $
        /noerase, title = titledumb

  minvec = [!x.crange[0], !y.crange[0]]
  maxvec = [!x.crange[1], !y.crange[1]]

  if keyword_set(xlog) then x = alog10(x)
  if keyword_set(ylog) then y = alog10(y)

  goodindex = where(x ge minvec[0] and x le maxvec[0] and $
                    y ge minvec[1] and y le maxvec[1], ctr)

   if n_elements(binsize) gt 0 then $
      nbins = [(maxvec[0]-minvec[0])/binsize[0], $
               (maxvec[1]-minvec[1])/binsize[1]] else begin
      binsize = [(maxvec[0]-minvec[0])/nbins[0], $
                (maxvec[1]-minvec[1])/nbins[1]]
   endelse
   nbins = floor(nbins)-1
   if ctr eq 0 then return
   v = [transpose(x[goodindex]), transpose(y[goodindex])]
   hist = hist_nd(v, binsize, nbins=nbins, rev = ri, min = minvec,max=maxvec)
   sz=size(hist)
   xaxis = findgen(sz[1])*binsize[0]+minvec[0]+binsize[0]/2
   yaxis = findgen(sz[2])*binsize[1]+minvec[1]+binsize[1]/2
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

  if keyword_set(logstretch) then begin
    disp, alog(hist/(float(minlevel) > 1)) > 0, xaxis, yaxis, xlog = xlog, $
          ylog = ylog, $
          min = 0,  _extra = ex, /half, title = title
; xrange = [minvec[0],, maxvec[0]] , $
;          yrange = [minvec[1], maxvec[1]], 
  endif else begin
    disp, hist, xaxis, yaxis, xlog = xlog, $
          ylog = ylog, _extra = ex, $
          min = minlevel, /half, title = title
;, xrange = [minvec[0], maxvec[0]], $
;          yrange = [minvec[1], maxvec[1]]
  endelse

  if minlevel gt 0 then begin
    ind = where(hist le minlevel and hist gt 0, ctr)
    if ctr gt 0 then begin
      lowind = [-1]
      for k = 0L, ctr-1 do begin
        lowind = [lowind, ri[ri[ind[k]]:ri[ind[k]+1]-1]]
      endfor
      lowind = goodindex[lowind[1:*]]
      oplot, x[lowind], y[lowind], psym = psym, _extra = ex
    endif
  endif

;   xaxis = findgen(sz[1]+2)*binsize[0]+minvec[0]-binsize[0]/2
;   yaxis = findgen(sz[2]+2)*binsize[1]+minvec[1]-binsize[1]/2
  

; ;   xaxis = findgen(sz[1])*binsize[0]+minvec[0]
; ;   yaxis = findgen(sz[2])*binsize[1]+minvec[1]
;    histout = fltarr(sz[1]+2, sz[2]+2)+0
;    histout[1:sz[1], 1:sz[2]] = hist
;    hist = histout
  return
end
