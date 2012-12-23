pro sky2grid, rasky, decsky, ragal, decgal, ragrid, decgrid, $
              minutes = minutes, seconds = seconds, degrees = degrees
;+
; NAME:
;   sky2grid
; PURPOSE:
;   Converts sky coordinates to a grid in specified units given the
;   pointing center of the galaxy.
;
; CALLING SEQUENCE:
;   SKY2GRID, rasky, decsky, ragal, decgal, ragrid, decgrid
;
; INPUTS:
;    RASKY, DECSKY - RA and DEC of positions in the sky.
;    RAGAL, DECGAL - RA and DEC of the pointing
;                    center for the grid in decimal degrees
;    RASKY, DECSKY - RA and DEC variable names to contain the 
;                    output grid values.
; KEYWORD PARAMETERS:
;    MINUTES - set for grid units in minutes of arc
;    SECONDS - set for grid units in seconds of arc
;    DEGREES - set for grid units in degrees of arc
; OUTPUTS:
;   RASKY and DECSKY
;
; MODIFICATION HISTORY:
;
;       Written - Thu Nov 9 18:41:18 2000, Erik Rosolowsky
;                 <eros@cosmic>
;
;-
if keyword_set(minutes) then sfac = 1/(1/60.*!dtor)
if keyword_set(seconds) then sfac = 1/(1/3600.*!dtor)
if keyword_set(degrees) then sfac = 1/(!dtor)
if n_elements(sfac) eq 0 then sfac = 1/(1/60.*!dtor)


  rp = rasky*!dtor
  dp = decsky*!dtor
  rc = ragal*!dtor
  dc = decgal*!dtor
  theta = acos(sin(dc)*sin(dp)+cos(dc)*cos(dp)*cos(rp-rc))
  phi = asin(sin(rp-rc)*cos(dp)/sin(theta))
  c1 = (rp gt rc)*(dp lt dc)
  phi = phi*(1-c1)+(!pi-phi)*c1
  c2 = (rp lt rc)*(dp lt dc)
  phi = phi*(1-c2)+(!pi-phi)*c2
  offrad = theta*sfac
  ragrid = offrad*sin(phi)
  decgrid = offrad*cos(phi)

  return
end
