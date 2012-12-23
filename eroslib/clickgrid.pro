pro clickgrid, image, hd = hd, ra = ra, dec = dec, r_center = r_center, $
d_center = d_center, filename = filename, $
pbeam = pbeam
;+
; NAME:
;    clickgrid
; PURPOSE:
;    To generate a grid file by adding a point to the grid one primary
;    beam width away from the last grid point. 
;
; CALLING SEQUENCE:
;    CLICKGRID, image
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
;   PBEAM - The size of the primary beam in decimal degrees.
; OUTPUTS:
;   Keyword governed.
;
; COMMENTS: 
;    Assumes grids are output in arcminutes.  Use parsegrid and
;    writegrid to change to different uints.
; MODIFICATION HISTORY:
;       Written -
;       Mon Nov 27 00:01:47 2000, Erik Rosolowsky <eros@cosmic>
;
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
if not (keyword_set(filename)) then filename = 'grid.txt'
if not (keyword_set(pbeam)) then pbeam = 0.8563
pstep = 60*pbeam
if not (keyword_set(ra) and keyword_set(dec)) then begin
xy2ad, findgen(naxis1)#replicate(1., naxis2), $
replicate(1., naxis1)#findgen(naxis2), astrom, ra, dec
endif

if not ((keyword_set(ra) and keyword_set(dec)) or (keyword_set(hd))) $
  then begin
  message, 'Coordinate system not specified with Header or RA/DEC grids', /con
  return
endif

ravec = ra[*, cpix2-1]    ;-1 because of FITS 1 indexing convention
decvec = dec[cpix1-1, *]

disp, image, reform(ravec), reform(decvec), xtickformat = 'raticks',$
 ytickformat = 'decticks', xtitle = '!4 a !3(2000)', $
ytitle = '!4 d!3 (2000)', charsize = 1., position = [0.15, 0.15, 0.99, 0.99]

ct = 0
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
  sky2grid, raposn, decposn, r_center, d_center, ra_offset, dec_offset
  if ct eq 0. then begin
   gridra = ra_offset
   griddec = dec_offset
  endif else begin 
    uvec = [(ra_offset-gridra[ct-1]), dec_offset-griddec[ct-1]]
    uvec = uvec/sqrt((total(uvec^2)))*pbeam
    ra_offset = gridra[ct-1]+uvec[0]
    dec_offset = griddec[ct-1]+uvec[1]
    gridra = [gridra, ra_offset]
    griddec = [griddec, dec_offset]
  endelse
  ct = ct+1  
  oplotgrid, gridra[ct-1], griddec[ct-1], color = !p.color, $
    ra_center = r_center, dec_center = d_center
endif  

if !mouse.button eq 2 then begin

  hold = min(abs(xcl-ravec), raind)
  hold = min(abs(ycl-decvec), decind)
  raposn = ra[raind, decind]
  decposn = dec[raind, decind]
  sky2grid, raposn, decposn, r_center, d_center, ra_offset, dec_offset
  dvec = sqrt((ra_offset-gridra)^2+(dec_offset - griddec)^2)
  distance = min(dvec, ind)
  oplotgrid, gridra[ind], griddec[ind], color = 1, $
    ra_center = r_center, dec_center = d_center
  if ct gt 1 then begin
    ct = ct-1
    gridra = gridra[where(indgen(n_elements(gridra)) ne ind)]
    griddec = griddec[where(indgen(n_elements(griddec)) ne ind)]
  endif else begin
    ct = 0
    girddec = 0
    gridra = 0
    print, 'WARNING!! Grid Empty'
  endelse
endif
endwhile

list = findfile(filename, count = fcount)
if fcount gt 0 then begin
  print, 'Overwrite GRID file '+filename+' (y/n)?'
  resp = get_kbrd(1)
  if (resp eq 'n') or (resp eq 'N') then return
endif

if (keyword_set(filename)) then begin
  print, 'Writing Grid file '+filename
  writegrid, gridra, griddec, name = filename
endif  

  return
end

