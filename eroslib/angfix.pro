function angfix, angle, radians = radians
;+
; NAME:
;   FIXANG
; PURPOSE:
;   To bring an array of angles to range (-180,180] by phase wrapping
;
; CALLING SEQUENCE:
;   fix = FIXANG( angle [, /radians)
;
; INPUTS:
;   ANGLE -- An array of angles to be made better
;
; KEYWORD PARAMETERS:
;   RADIANS -- Set this keyword to assume angles are in radians
;
; OUTPUTS:
;   FIX -- The fixed and all made better angles.
;
; MODIFICATION HISTORY:
;       Busted some serious code.  Boo-yah.
;       Thu Sep 6 11:24:20 2001, Erik Rosolowsky <eros@cosmic>
;-

ang = angle
if n_elements(radian) ne 0 then cf = !dtor else cf = 1
i1 = where(ang le -180*cf)
i2 = where(ang gt 180*cf)
while (i1[0] ne -1) do begin
  ang[i1] = ang[i1]+360*cf
  i1 = where(ang le -180*cf)
endwhile

while (i2[0] ne -1) do begin
  ang[i2] = ang[i2]-360*cf
  i2 = where(ang gt 180*cf)
endwhile

  return, ang
end
