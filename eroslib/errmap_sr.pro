function errmap_sr, cube
;+
; NAME:
;    errmap_sr
; PURPOSE:
;    To generate a map of the errors pixel-wise in a data cube by
;    taking the RMS along a pixel and then rejecting anything over 3-sigma.
;    Note: The 3-sigma clipping should be valid to ~500 channels per
;    spectrum.
; CALLING SEQUENCE:
;    ERRMAP_SR, cube
;
; INPUTS:
;    CUBE - A three dimensional data cube
;
; KEYWORD PARAMETERS:
;    None
;
; OUTPUTS:
;    MAP - A map of the RMS values at each pixel.
;
; MODIFICATION HISTORY:
;       Added feature that grows the mask of excluded pixels to
;       elminate anything around a spike greater than 3 sigma.
;       Wed Aug 8 10:01:09 2001, Erik Rosolowsky <eros@cosmic>
;
;-

sz = size(cube)
map = fltarr(sz[1], sz[2])
meanmap = total(cube, 3)/sz[3]
meancube = fltarr(sz[1], sz[2], sz[3])
for k = 0, sz[3]-1 do meancube[*, *, k] = meanmap

sdevmap = sqrt(total((cube-meancube)^2,3)/(sz[3]-1))

mask = bytarr(sz[1], sz[2], sz[3])
for k = 0, sz[3]-1 do mask[*, *, k] = cube[*, *, k] ge 3*sdevmap
mask = (mask+shift(mask, 0, 0, -1)+shift(mask, 0, 0, 1)) gt 0
mask = 1b-mask
map = sqrt(total((cube-meancube)^2*mask, 3)/(total(mask, 3)-1))

  return, map
end
