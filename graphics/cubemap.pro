pro cubemap, cube,  ra = ra, dec = dec, cutoff = cutoff,  contour = contour
;+
; NAME:
;   cubemap
; PURPOSE:
;   To map a cube in order maximize perception of the structure of
;   signals contained in the cube.
;
; CALLING SEQUENCE:
;   CUBEMAP, cube
;
; INPUTS:
;   CUBE - a data cube containing the data to be plotted.
;
; KEYWORD PARAMETERS:
;   RA - The right ascension of the data in the cube.  Assumed to be
;        along first axis of cube.
;   DEC - The declination of the data.  Assumed to be along the second
;         axis of the cube.
; OUTPUTS:
;
;
; MODIFICATION HISTORY:
;
;       Written -- Fri Oct 6 15:27:44 2000, Erik Rosolowsky <eros@cosmic>
;
;		
;
;-
;ind = where(finite(cube) ne 1)
;if ind[0] ne -1 then cube[ind] = -99999.

if NOT keyword_set(cutoff) then cutoff = 2
sigma = errfind(cube)

mask = (cube gt cutoff*sigma)
mask = (mask*(shift(mask, 0, 0, -1)+shift(mask, 0, 0, 1)) ge 1)
mask = (mask*(shift(mask, 1, 0, 0)+shift(mask, -1, 0, 0)+$
              shift(mask, 0, 1, 0)+shift(mask, 0, -1, 0)) ge 1)
map = total(mask*cube, 3)

if keyword_set(contour) then begin
print, sigma
nplanes = float((size(cube))[3])
  contour, map, levels = (findgen(20)+1.5)*sigma*sqrt(nplanes)
  return
endif
sz = size(map)
if keyword_set(ra) and keyword_set(dec) then begin
  disp, map, ra, dec
endif else begin
  disp, map, indgen(sz[1]), indgen(sz[2])
endelse
  return
end
