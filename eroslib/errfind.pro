function errfind, cube, verbose = verbose, reject = reject
;+
; NAME:
;   errfind
; PURPOSE:
;   Accurate determine of the error in a distribution by measuring the
;   width of the negative portion of the gaussian distribution of noise.
;
; CALLING SEQUENCE:
;   SIGMA = ERRFIND(cube)
;
; INPUTS:
;   CUBE - Datacube for which the error should be determined.
;
; KEYWORD PARAMETERS:
;   VERBOSE - Set this keyword for text display of relevant noise
;             parameters. 
;   REJECT - Set this keyword to values to ignore in the statistical
;            analysis of the data cube
;
; OUTPUTS:
;   SIGMA - The deviation of the noise.
;
; MODIFICATION HISTORY:
;
;       Stupid bugs caught by Karin Sandstrom
;	Tue Jan 17 21:09:53 2006, Erik 
;
;       Added REJECT keyword - Wed Oct 18 10:10:05 2000, Erik
;                              Rosolowsky <eros@cosmic>
;       Written - Fri Oct 6 15:36:13 2000, Erik Rosolowsky
;                 <eros@cosmic>
;
;-

newcube = cube[where(finite(cube) eq 1)]
if total(size(reject)) ne 0 then newcube = newcube[where(newcube ne reject)]

moments = moment(newcube, /nan, sdev = width)

binsz = width/20
range = 3*(max(newcube))
;if n_elements(pr) eq 0 then pr = 5.

hist = histogram(newcube, min = -range-0.5*binsz, max = range+0.5*binsz,$
 binsize = binsz)
x = binsz*(findgen(2*ceil(range/binsz)+1)-range/binsz)
zloc = where(abs(x) lt 0.5*binsz) ; location of zero in the hist.
zloc = zloc[0]

bothalf = hist[0:zloc]
xbot = x[0:zloc]
uphalf = hist[zloc:*]
xtop = x[zloc:*]

sigma_start = width ; initial width estimate
amp_start = max(hist)
offset_start = 0.                      ; Peak assumed at T=0
;const = 0.                             ; No constant offset.
modhist = [bothalf[0:zloc-1], reverse(bothalf)]
weights = replicate(1., n_elements(x)) 
A = [amp_start, offset_start, sigma_start/sqrt(2)];, const]
;print, a
xmod = [xbot, -reverse(xbot[0:n_elements(xbot)-2])]
fit = gaussfit(xmod, modhist, a, estimates = a, nterms = 3)

if keyword_set(verbose) then begin
  print, 'Number of Valid Data points: ', long(total(hist))
  print, 'Mean of Data Points: ', moments[0]
  print, 'Std. Deviation of Data Points: ', width
  print, 'Fit Width of Noise Gaussian: ', a[2]
  print, 'Skewness of Distribution: ', moments[2]
  print, 'Kurtotsis of Distribution - 3',  moments[3]
endif
  return, a[2]
end
