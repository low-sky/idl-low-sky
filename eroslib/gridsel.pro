pro gridsel, image, hd = hd, ra = ra, dec = dec, r_center = r_center, $
d_center = d_center, filename = filename, r_grid = ragrid, d_grid = decgrid, $
oplotx = oplotx, oploty = oploty, oplotps = oplotps, _extra =  extras
;+
; NAME:
;   GRIDSEL
; PURPOSE:
;   To generate a BIMA grid interactively.
;
; CALLING SEQUENCE:
;   GRIDSEL, image
;
; INPUTS:
;   IMAGE - An image (optimized for DSS, but should work with all)
;           which is the background on which the grid is plotted.
;
; KEYWORD PARAMETERS:
;   HD - The FITS header for the image.
;   RA - A matrix containing the RA values for every pixel in IMAGE
;   DEC - A matrix containing the DEC values for every pixel in IMAGE
;   R_CENTER - The RA of the center of THE GRID (Bima pointing center)
;              in decimal degrees
;   D_CENTER - Ditto for DEC
;   FILENAME - The name of a text file into which the grid is written.
;   R_GRID - The name of variables into which the RA offsets can be
;            stored.
;   D_GRID - Ditto for DEC.
;   OPLOTX / OPLOTY - keywords specifying positions in sky
;                     coordinates to overplot points on the displayed
;                     map.
;   OPLOTPS - The plotting symbol for overplotting.
;   All other keywords are passed to the display command for the map.
; OUTPUTS:
;   Keyword governed.
;
; MODIFICATION HISTORY:
;
;       Added keyword passing to display routine and overplotting-- 
;       Fri Jan 19 15:52:38 2001, Erik Rosolowsky < eros@cosmic > 
;
;       Took centers out of plot circles.
;       Sun Nov 26 23:32:44 2000, Erik Rosolowsky <eros@cosmic>
;
;       Fixed grid writing bug - Thu Nov 9 19:10:10 2000, Erik
;                                Rosolowsky <eros@cosmic>
;
;       Written - Fri Oct 20 01:46:16 2000, Erik Rosolowsky
;                 <eros@cosmic>
;-
if keyword_set(hd) then begin
extast, hd, astrom
naxis1 = sxpar(hd, 'NAXIS1')
naxis2 = sxpar(hd, 'NAXIS2')
cpix1 = sxpar(hd, 'CRPIX1')
cpix2 = sxpar(hd, 'CRPIX2')
if not keyword_set(r_center) then r_center = sxpar(hd, 'CRVAL1')
if not keyword_set(d_center) then d_center = sxpar(hd, 'CRVAL2')
;if not keyword_set(filename) then filename = ' ' & flag2 = 1
endif

if not (keyword_set(ra) and keyword_set(dec)) then begin
xy2ad, findgen(naxis1)#replicate(1., naxis2), $
replicate(1., naxis1)#findgen(naxis2), astrom, ra, dec
endif

if not ((keyword_set(ra) and keyword_set(dec)) or (keyword_set(hd))) then begin
message, 'Coordinate system not specified with Header or RA/DEC grids', /con
return
endif

ravec = ra[*, cpix2-1]    ;-1 because of FITS 1 indexing convention
decvec = dec[cpix1-1, *]

disp, image, reform(ravec), reform(decvec), xtickformat = 'raticks',$
 ytickformat = 'decticks', xtitle = '!4 a !3(2000)', $
ytitle = '!4 d!3 (2000)', charsize = 1.,$
 position = [0.15, 0.15, 0.99, 0.99], _extra = extras

if keyword_set(oplotx)*keyword_set(oploty) then begin
if not keyword_set(oplotps) then oplotps = 2
  oplot, oplotx, oploty, ps = oplotps
endif
if keyword_set(filename) then path = findfile(filename, count = fct) else $
fct = 0
flag = 0
rc = r_center*!dtor
dc = d_center*!dtor
sfac = 1.
ct = 0
if fct gt 0 then begin
  parsegrid, filename, gridra, griddec
  oplotgrid, gridra, griddec, $
    ra_center = r_center, dec_center = d_center
  phi = atan(gridra, griddec)
  offrad = sqrt(gridra^2+griddec^2)/60*!dtor
  dp = asin(cos(offrad)*sin(dc)+cos(dc)*sin(offrad)*cos(phi))
  delra = asin(sin(offrad)*sin(phi)/cos(dp))
  ra_pos_array = (rc+delra)*!radeg
  dec_pos_array = dp*!radeg
;  plots, ra_pos_array, dec_pos_array,$
;   color = !p.color, psym = 2
  ct = n_elements(gridra)
  flag = 1
endif

!mouse.button= 0
print, 'Left Click to add a grid point'
print, 'Middle Click to eliminate nearest gridpoint'
print, 'Right Click to finish'


while (!mouse.button ne 4)  do begin

cursor, xcl, ycl,4,/data

if !mouse.button eq 1 then begin
 
  hold = min(abs(xcl-ravec), raind)
  hold = min(abs(ycl-decvec), decind)
  raposn = ra[raind, decind]
  decposn = dec[raind, decind]
  rp = raposn*!dtor
  dp = decposn*!dtor
  
  theta = acos(sin(dc)*sin(dp)+cos(dc)*cos(dp)*cos(rp-rc))
  phi = asin(sin(rp-rc)*cos(dp)/sin(theta))
  if (rp gt rc)*(dp lt dc) then phi = !pi-phi
  if (rp lt rc)*(dp lt dc) then phi = !pi-phi
  offrad = theta*!radeg*60.*sfac
  ra_offset = offrad*sin(phi)
  dec_offset = offrad*cos(phi)
  if ct eq 0. then begin
   gridra = ra_offset
   griddec = dec_offset
   ra_pos_array = raposn
   dec_pos_array = decposn
  endif else begin 
    gridra = [gridra, ra_offset]
    griddec = [griddec, dec_offset]
    ra_pos_array = [ra_pos_array, raposn]
    dec_pos_array = [dec_pos_array, decposn]
  endelse
  ct = ct+1  
;  print,  ra_pos_array[ct-1], dec_pos_array[ct-1], ' added to grid.', ct
;  plots, ra_pos_array[ct-1], dec_pos_array[ct-1],$
;    color = !d.n_colors-1, psym = 2
  oplotgrid, gridra[ct-1], griddec[ct-1], color = !p.color, $
    ra_center = r_center, dec_center = d_center
endif  

if !mouse.button eq 2 then begin

  distance = min((xcl - ra_pos_array)^2+(ycl-dec_pos_array)^2, ind)
;  plots, ra_pos_array[ind], dec_pos_array[ind],$
;    color = 0, psym = 2
  oplotgrid, gridra[ind], griddec[ind], color = 1, $
    ra_center = r_center, dec_center = d_center
  if ct gt 1 then begin
    ct = ct-1
    ra_pos_array = ra_pos_array[where(indgen(n_elements(ra_pos_array)) ne ind)]
    dec_pos_array = $
      dec_pos_array[where(indgen(n_elements(dec_pos_array)) ne ind)] 
    gridra = gridra[where(indgen(n_elements(gridra)) ne ind)]
    griddec = griddec[where(indgen(n_elements(griddec)) ne ind)]
  endif else begin
    ct = ct-1
    ra_pos_array = 0
    dec_pos_array = 0
    girddec = 0
    gridra = 0
    print, 'WARNING!! Grid Empty'
  endelse
endif
endwhile
if flag eq 1 then begin
  print, 'Overwrite GRID file '+filename+' (y/n)?'
  resp = get_kbrd(1)
  if (resp eq 'y') or (resp eq 'Y') then flag = 0
endif
if (keyword_set(filename)) and (flag eq 0) then begin
  print, 'Writing Grid file '+filename
  writegrid, gridra, griddec, name = filename
endif  
return
end
