pro xy2sky, x, y, output = output
;+
; NAME:
;   XY2SKY
; PURPOSE:
;   Convert X and Y into RA and DEC coordinates as defined in the
;   paper with +X axis on the major axis with units of seconds of arc.
;
; CALLING SEQUENCE:
;  XY2SKY, x,y
;
; INPUTS:
;  X, Y -- coordinates of source.
;
; KEYWORD PARAMETERS:
;  NONE
;
; OUTPUTS:
;  X and Y vectors returned in RA and DEC
;
; MODIFICATION HISTORY:
;       Written --
;       Wed Aug 15 11:20:59 2001, Erik Rosolowsky <eros@cosmic>
;
;-


;; ra_gc = double([01, 33, 50.8])
;; dec_gc = double([30, 39, 36.7])
;; rg = convang(ra_gc, /ra) & dg = convang(dec_gc)

if n_elements(g) eq 0 then g = galaxies('M33')
rg = g.ra_gc
dg = g.dec_gc
rg = rg*!dtor & dg = dg*!dtor

r = sqrt(x^2+y^2)/3600*!dtor
phi = atan(y, x)+g.posang*!dtor



dec = asin(sin(dg)*cos(r)+cos(dg)*sin(r)*cos(phi))
ra = rg+asin(sin(phi)*sin(r)/cos(dg))

x = ra*!radeg
y = dec*!radeg
if keyword_set(output) then print, x, y
  return
end
