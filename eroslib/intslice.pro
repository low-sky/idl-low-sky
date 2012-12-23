function intslice, datacube, angle, center, cutlength = cl, $
                   ncuts = nc, inerror = inerror, outerror = outerror
;+
; NAME:
;   INTSLICE
; PURPOSE:
;   Generates a data cube with axes rotated with respect to the
;   original data cube by a given angle.  
;
; CALLING SEQUENCE:
;   cube = INTSLICE(cube, angle, center [, cutlength=cutlength,
;                   ncuts=ncuts, inerror=inerror, outerror=outerror])
;
; INPUTS:
;   CUBE -- data cube to slice.
;   ANGLE -- Angle of the slice (relative to the X and Y of the cube.
;   CENTER -- vector of pixel position of the center of the cut.
; KEYWORD PARAMETERS:
;   CUTLENGTH -- Number of pixels long to make the cut. 
;   INERROR -- Map of errors in in the data cube.
;   OUTERROR -- Map containing the rotated data cube errors.
;   NCUTS -- Number of cuts to make through the data cube.
; OUTPUTS:
;   CUBE -- Rotated cube.
;
; MODIFICATION HISTORY:
;       Exported and documented.
;       Tue Oct 16 13:51:00 2001, Erik Rosolowsky <eros@cosmic>
;-


  if n_elements(nc) eq 0 then nc = 15
  angle = angle*!dtor
  sz = size(datacube)
  if sz[0] eq 2 then begin
    datacube = reform(datacube, sz[1], sz[2], 1)
    sz = size(datacube)
  endif
  if not keyword_set(inerror) then inerror = fltarr(sz[1], sz[2])
  out = fltarr(nc, cl, sz[3])
  outerror = fltarr(nc, cl)
  uvec = [cos(angle), sin(angle)]
  pvec = [sin(angle), -cos(angle)]
;  plot, [0, 60], [0, 60], /nodata
  for i = 0, nc-1 do begin
    stpix = (i-nc/2)*pvec-cl/2*uvec+center
    endpix = (i-nc/2)*pvec+(cl-cl/2)*uvec+center
    out[i, *, *] = pvcut(datacube, start = stpix, stop = endpix, $
                         inerror = inerror,  outerror = eout, length = cl)
    outerror[i, *] = eout
;  plots, stpix[0], stpix[1]
;  plots, endpix[0], endpix[1], /con  
  endfor
  datacube = reform(datacube)
  return, out
end
