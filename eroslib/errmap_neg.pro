function errmap_neg, cube
;+
; NAME:
;  ERRMAP_NEG
; PURPOSE:
;  Calculate the RMS at each position in a data cube by using the
;  standard deviation of the negative values of the data.
;
; CALLING SEQUENCE:
;  error_map = ERRMAP_NEG(datacube)
;
; INPUTS:
;  DATACUBE -- Data cube to be analyzed, position in x and y axes,
;              velocity in the z axis.
;
; KEYWORD PARAMETERS:
;  NONE
;
; OUTPUTS:
;  ERROR_MAP -- A M x N array for a datacube with M x N spatial
;               positions and P velocity channels.
;
; MODIFICATION HISTORY:
;       Documented.
;       Wed Nov 21 11:44:47 2001, Erik Rosolowsky <eros@cosmic>
;-

  sz = size(cube)
  map = fltarr(sz[1], sz[2])
  meanmap = total(cube, 3)/sz[3]
  meancube = fltarr(sz[1], sz[2], sz[3])
  for k = 0, sz[3]-1 do meancube[*, *, k] = meanmap
  mask = cube lt 0
  map = total(((cube-meancube)^2)*mask, 3)/(total(mask, 3)-1)
  for i = 0, sz[1]-1 do begin
    for j = 0, sz[2]-1 do begin
      spec = cube[i, j, *]
      goodind = where(finite(spec))
      if total(goodind) lt 0 then goto, skipout
      negind = where(spec lt 0)
      if total(negind) gt -1 then map[i, j] = mad(spec[negind])
      skipout:
    endfor
;  print,i
  endfor
  return, map
end
