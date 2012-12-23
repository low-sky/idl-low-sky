pro grid2sky, ragrid, decgrid, ragal, decgal, rasky, decsky, $
              minutes = minutes, seconds = seconds, degrees = degrees
;+
; NAME:
;    grid2sky
; PURPOSE:
;    To convert coordinates in a grid to coordinates on the sky.
;
; CALLING SEQUENCE:
;    GRID2SKY, ragrid, decgrid, ragal, decgal, rasky, decsky
;
; INPUTS:
;
;    RAGRID, DECGRID - RA and DEC of positions in the grid.
;    RAGAL, DECGAL - RA and DEC of the pointing
;                    center for the grid in decimal degrees
;    RASKY, DECSKY - RA and DEC variable names to contain the 
;                    output coordinates in decimal degrees
; KEYWORD PARAMETERS:
;    MINUTES - set for grid units in minutes of arc
;    SECONDS - set for grid units in seconds of arc
;    DEGREES - set for grid units in degrees of arc
; OUTPUTS:
;    RASKY and DECSKY
; MODIFICATION HISTORY:
;
;       Written -- Thu Nov 9 18:27:26 2000, Erik Rosolowsky
;                  <eros@cosmic>
;
;-
if keyword_set(minutes) then sfac = 1/60.*!dtor
if keyword_set(seconds) then sfac = 1/3600.*!dtor
if keyword_set(degrees) then sfac = !dtor
if n_elements(sfac) eq 0 then sfac = 1/60.*!dtor

rg = ragal*!dtor
dg = decgal*!dtor

  phi = atan(ragrid, decgrid)
  offrad = sqrt(ragrid^2+decgrid^2)*sfac
  dp = asin(cos(offrad)*sin(dg)+cos(dg)*sin(offrad)*cos(phi))
  delra = asin(sin(offrad)*sin(phi)/cos(dp))
  rasky = (rg+delra)*!radeg
  decsky = dp*!radeg
  return
end
