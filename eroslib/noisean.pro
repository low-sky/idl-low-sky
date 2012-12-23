function gaussian2, X, A;, F, pder
  z = (x-a[1])/(a[2])
  bx = exp(-z^2/2)
  F = A[0]*bx
  sub1 = a[0]/a[2]*z*bx
  sub2 = a[0]/a[2]*z^2*bx
  if N_PARAMS() GE 4 THEN $
    pder = [[bx], [sub1], [sub2], [replicate(1.0, N_ELEMENTS(X))]]
  return, [[f], [bx], [sub1], [sub2]]
end

pro noisean, cube, name = name, pr = pr, psname = psname
;+
; NAME:
;  NOISEAN
; PURPOSE:
;  To display the properties of noise in 4 plots:
;    1) Basic Histogram.
;    2) Residual of a Gaussian fit to the histogram.
;    3) Negative half of the histogram subtracted from the positive
;    half (Smoothed).
;    4) As 3 but not smoothed.
; CALLING SEQUENCE:
;   NOISEAN, datacube [, name=name, pr = pr, psname = psname]
;
; INPUTS:
;   DATACUBE -- the data cube to be analyzed.
;
; KEYWORD PARAMETERS:
;   NAME -- Name of the data cube.
;   PR -- Plot range to consider.
;   PSNAME -- Name of PostScript plot to output.  Otherwise, the plot
;             goes to the current device.
; OUTPUTS:
;   None.
;
; MODIFICATION HISTORY:
;       Documented.
;       Wed Nov 21 12:16:17 2001, Erik Rosolowsky <eros@cosmic>
;-
  newcube = cube[where(finite(cube))]
  if keyword_set(psname) then begin
    set_plot, 'ps'
    device, file = psname, xsize = 7, ysize = 10, /inches, yoffset = 0.5
  endif


  if n_elements(name) eq 0 then name = 'Data Cube'
  range = 60
  if n_elements(pr) eq 0 then pr = ceil(1.5*max(newcube))
  bnsz = 0.01
  hist = histogram(newcube, min = -range-0.5*bnsz, max = range+0.5*bnsz, $
                   binsize = bnsz)
  x = bnsz*(findgen(2*range/bnsz+1)-range/bnsz)
  !p.multi = [0, 1, 2]

  plot, x, hist, psym = 10, xtitle = 'Jy/Beam', ytitle = 'N', $
    title = 'Histogram of Data in '+name, charsize = 1, xrange = [-pr, pr]

  xz = findgen(21)-10
  yz = fltarr(21)
  zloc = where(abs(x) lt 0.5*bnsz) ; location of zero in the hist.
  zloc = zloc[0]
  bothalf = hist[0:zloc]
  xbot = x[0:zloc]
  uphalf = hist[zloc:*]
  xtop = x[zloc:*]
;plot, xtop, uphalf-reverse(bothalf), psym = 10

  sigma_start = stdev(hist*x)/mean(hist) ; initial width estimate
  amp_start = max(hist)
  offset_start = 0.             ; Peak assumed at T=0
  const = 0.                    ; No constant offset.

  modhist = [bothalf[0:zloc-1], reverse(bothalf)]
;weights = sqrt(hist)
;weights = x^2+5
  weights = replicate(1., n_elements(x)) 
  A = [amp_start, offset_start, sigma_start/sqrt(2)]
  print, a

;modhist = a[0]*exp(-(x-a[1])^2/(2*a[2]^2))
;fit = curvefit(x,modhist, weights, A, sigma, function_name = 'gaussian')
;
  fit = gaussfit(x, modhist, a, estimates = a, nterms = 3)

;fit = lmfit(x, modhist, a, covar = cv, /double, meas = sqrt(abs(modhist)), $
;            func = 'gaussian2')
;oplot, x, a[0]*exp(-(x-a[1])^2/(2*a[2]^2))
  print, a
  sig = abs(A[2])
  print, sig

  fcn1 = smooth(hist-fit, 7)
  mini = min(fcn1)
  plot, x, fcn1, psym = 10, xtitle = 'Jy/Beam', ytitle = 'N', $
    title = 'Residual of Gaussian Fit to Histogram (Data-Fit, Smoothed)', $
    charsize = 1., xrange = [-pr, pr]
  xyouts, -0.95*pr, 0.9*mini, 'Amplitude='+string(A[0]), charsize = 0.75
  xyouts, -0.95*pr, 0.7*mini, 'Dispersion ='+string(sig), charsize = 0.75
  xyouts, -0.95*pr, 0.5*mini, 'Peak Shift='+string(A[1]), charsize = 0.75
;  xyouts, -0.95*pr, 0.3*mini, 'Const. Offset='+string(A[3]), charsize = 0.75
  oplot, xz, yz, linestyle = 2
  if not keyword_set(psname) then begin
    message, 'Press any key to continue', /con
    null = get_kbrd(1)
  endif
  erase
  fcn = smooth(uphalf-reverse(bothalf), 7)
  plot, x[zloc:*], fcn, $
    psym = 10, xtitle = 'Jy/Beam', $
    ytitle = 'N', title = 'Upper Half - Lower Half (Smoothed)', $
    charsize = 1., xrange = [0, pr]
  oplot, xz, yz, linestyle = 2
  for i = 1, 5 do begin
    oplot, [i*sig, i*sig], [-1000, 1000], linestyle = 1
    xyouts, i*sig, 0.9*max(fcn), strtrim(string(i), 2)+'!4r!3'
  endfor
  fcn = uphalf-reverse(bothalf)
  start = min(where((x gt 3*sig), ct))
  stop = min(where(x gt 10*sig))
  roi = fcn[start-n_elements(uphalf) :stop-n_elements(uphalf) ]
  if ct gt 0 then plot, x[start:stop], roi, $
    psym = 10,  xtitle = 'Jy/Beam', $
    ytitle = 'N', title = 'Upper Half - Lower Half', $
    charsize = 1., xrange = [x[start], x[stop]], xstyle = 1
  oplot, xz, yz, linestyle = 2

  for i = 3, 9 do begin
    oplot, [i*sig, i*sig], [-1000, 1000], linestyle = 1
    xyouts, i*sig, 0.9*max(roi), strtrim(string(i), 2)+'!4r!3'
  endfor

  if keyword_set(psname) then begin
    device, /close
    set_plot, 'x'
  endif
  !p.multi = 0
  return
end







