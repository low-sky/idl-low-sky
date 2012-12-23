function cuberot, data, angle, x0, y0, missing = missing
;+
; NAME:
;   CUBEROT
; PURPOSE:
;   Rotate a datacube around a position by a specified angle (in
;   degrees CCW from x-axis).  Useful for PV-cuts.
;
; CALLING SEQUENCE:
;   output = CUBEROT( data, angle [x0, y0])
;
; INPUTS:
;   DATA -- cube to be rotated.  Pad if emission will run off the edge.
;   ANGLE -- angle of rotation.
;   X0, Y0 -- center position.  Defaults to center of the cube.
; KEYWORD PARAMETERS:
;   MISSING -- If data are missing in the rotation, fill with these
;              values. Defaults to NaN
;
; OUTPUTS:
;   A rotated data cube of the SAME size as the input. 
;
; MODIFICATION HISTORY:
;
;       Tue Oct 26 12:35:11 2004, <eros@master>
;		Written
;
;-

  sz = size(data)
  if n_elements(x0) eq 0 then x0 = float(sz[1])/2
  if n_elements(y0) eq 0 then y0 = float(sz[2])/2
  if n_elements(missing) eq 0 then missing = !values.f_nan
  
  rotcube = data
  rotcube[*] = 0.

  for k = 0, sz[3]-1 do begin
    rotcube[*, *, k] = rot(data[*, *, k], -angle, 1.0, x0, y0, missing = missing, $
                           /cubic, /pivot)

  endfor


  return, rotcube
end
