pro oplotgrid, gridra, griddec, linestyle = linestyle, degrees = degrees, $
               pbeamsize = pbeamsize, ra_center = ra_center, $
               dec_center = dec_center, $
               color = color, ravals = ravals, decvals = decvals, $
               fill = fill, _extra = ex, line_fill = line_fill
;+
; NAME:
;   oplotgrid
; PURPOSE:
;   Plots BIMA grid onto an existing image of a galaxy.
;
; CALLING SEQUENCE:
;   OPLOTGRID, gridra, griddec
;
; INPUTS:
;   GRIDRA - Vector of RAs for a grid.  Assumed to be in arcminutes.
;   GRIDDEC - Vector of DECs for a grid.  Assumed to be in arcminutes.
; KEYWORD PARAMETERS:
;   LINESTYLE - linestyle for circle
;   DEGREES - indicates grid vectors are in decimal degrees
;   PBEAMSIZE - Size of the Primary beam in arc minutes.
;   RA_CENTER - RA of center of grid in decimal degrees
;   DEC_CENTER - DEC of center of grid in decimal degrees
;   COLOR - Color of plot points.
;   RAVALS, DECVALS - Vectors to contain the values of the RA and DEC
;                     plotted in the grid.
; OUTPUTS:
;   none
;
; MODIFICATION HISTORY:
;
;       Added Color keyword and made /degrees work. Fri Oct 20
;       00:21:50 2000, Erik Rosolowsky <eros@cosmic> 
;       Initial Documentation - Thu Oct 5 22:36:53 2000, Erik
;       Rosolowsky <eros@cosmic>
;
;-

  if NOT keyword_set(linestyle) then linestyle = 0
  if NOT keyword_set(ra_center) then ra_center = 0
  if NOT keyword_set(dec_center) then dec_center = 0
  if NOT keyword_set(pbeamsize) then pbeamsize = 0.8565
  if NOT keyword_set(color) then color = !p.color
  if keyword_set(degrees) then sfac = 60. else sfac = 1.
  xcirc = pbeamsize/(60.*cos(dec_center*!dtor))*cos(2*!pi*findgen(101)/100)*sfac
  ycirc = pbeamsize/60.*sin(2*!pi*findgen(101)/100)*sfac
  ngpts = n_elements(gridra) 

  skyra = gridra/(60.*cos(dec_center*!dtor))*sfac+ra_center
  skydec = griddec/60.*sfac+dec_center

  for i = 0, ngpts-1 do begin
    if keyword_set(fill) then begin
      polyfill,  skyra[i]+xcirc, skydec[i]+ycirc, _extra = ex, $
                 line_fill = line_fill
    endif
    plots, skyra[i]+xcirc[0], skydec[i]+ycirc[0], linestyle = linestyle, $
           color = color, _extra = ex
    plots, skyra[i]+xcirc, skydec[i]+ycirc, $
           /continue, linestyle = linestyle, $
           color = color, _extra = ex
  endfor

  ravals = skyra
  decvals = skydec
  return
end



