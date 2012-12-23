pro plot3d, x, y, z, ax = ax, az = az, xrange = xrange, yrange = yrange, $
            zrange = zrange, _extra = ex, psym = psym, pcolor = pcolor
;+
; NAME:
;    PLOT3D
; PURPOSE:
;    Plot three vectors of points against each other.
;
; CALLING SEQUENCE:
;   PLOT3D, x, y, z [, ax=ax, az=az, xrange=xrange, yrange=yrange,
;                    zrange=zrange, psym = psym]
;
; INPUTS:
;   X, Y, Z -- Three vectors to be plotted against each other.
;
; KEYWORD PARAMETERS:
;   AX, AZ -- Angle of perspective rotation around the X and Z axes
;             respectively, in decimal degrees
;   [XYZ]RANGE -- Set the range of the specified axis.
;   PSYM -- Plot symbol to be used.  Defaults to PSYM = 3 (points)
;   PCOLOR -- Plot color to be used in points.
;   All extra keywords are passed to the axes commands.
; OUTPUTS:
;   Plots.
;
; MODIFICATION HISTORY:
;       Written
;       Wed Jul 31 16:16:17 2002, Erik Rosolowsky <eros@cosmic>
;-
  


  erase
  if n_elements(xrange) eq 0 then xrange = [min(x), max(x)]
  if n_elements(yrange) eq 0 then yrange = [min(y), max(y)]
  if n_elements(zrange) eq 0 then zrange = [min(z), max(z)]
  if n_elements(ax) eq 0 then ax = 30
  if n_elements(az) eq 0 then az = 30
  if not keyword_set(psym) then psym = 3
  if not keyword_set(pcolor) then pcolor = !p.color

  scale3, xrange = xrange, yrange = yrange, zrange = zrange, $
    ax = ax, az = az
  for i = 0, n_elements(x)-1 do begin
    plots, x[i], y[i], z[i], /t3d, psym = psym, color = pcolor
  endfor
  
  axis, xax = 0, /t3d, /data, _extra = ex, xrange = xrange
  axis, yax = 0, /t3d, /data, _extra = ex, yrange = yrange
  axis, zax = 2, /t3d, /data, _extra = ex, zrange = zrange
  
  return
end
