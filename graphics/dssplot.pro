pro dssplot, fitsfile, dms = dms, minval = minval, maxval = maxval, $
title = title, position = position
;+
; NAME:
;    dssplot
; PURPOSE:
;    Plot a DSS image with RA and DEC scales.  Depricated (5/04).  Use
;    RDHD and DISP instead.
;
; CALLING SEQUENCE:
;    DSSPLOT, fitsfile
;
; INPUTS:
;    FITSFILE - name of a FITS file containing astrometry information.
;
; KEYWORD PARAMETERS:
;    DMS - set keyword to plot image with Degree Minute Second axes
;    MINVAL - value for bottom of color table
;    MAXVAL - value for top of color table
;    TITLE - Title of plot
;    POSITION - Position in normal coordinates of plot device for the
;               plot.  This is useful in conjunction with the DMS keyword.
; REQUIRED ROUTINES:
;    raticks.pro -- Formats tickmarks in RA DMS format
;    decticks.pro -- Formats tickmarks in DEC DMS format
;    disp.pro -- Display program for large arrays.
; OUTPUTS:
;    none
;
; MODIFICATION HISTORY:
;
;       Added File not found Catch -- Thu Oct 5 23:27:57 2000, Erik
;                                     Rosolowsky <eros@cosmic>
;       Initial writing - Thu Oct 5 22:46:59 2000, Erik Rosolowsky
;                         <eros@cosmic>
;
;		
;
;-
 
nulval = findfile(fitsfile, count = ct)
if ct eq 0 then begin
  message, 'File '+fitsfile+' not found.', /con
  return
endif
map = readfits(fitsfile, hd)
naxis1 = sxpar(hd, 'NAXIS1')
naxis2 = sxpar(hd, 'NAXIS2')

; Extract astrometry information and create RA and DEC arrays
extast, hd, astrom
nelts = max([naxis1, naxis2])
xy2ad, findgen(nelts), findgen(nelts), astrom, ra, dec
ra = ra[0:naxis1-1]
dec = dec[0:naxis2-1]

if keyword_set(minval) then map[where(map lt minval)] = minval
if keyword_set(maxval) then map[where(map gt maxval)] = maxval

if keyword_set(DMS) then begin
  disp, map, ra, dec, xtickformat = 'raticks', ytickformat = 'decticks', $
    position = position, xtitle = '!4 a !3 (2000)', $
    ytitle = '!4 d!3 (2000)', charsize = 1., title = title
endif else begin
   disp, map, ra, dec, position = position, xtitle = '!4 a !3 (2000)', $
    ytitle = '!4 d!3 (2000)', charsize = 1., title = title
endelse
  return
end

