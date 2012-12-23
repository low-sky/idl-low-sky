function kdist, l, b, v, near = near, far = far, rc = rc, $
                  r0 = r0, v0 = v0, rgal = rgal, clemens = clemens
;+
; NAME:
;   KINDIST 
; PURPOSE:
;   To return the distance to an object given l,b,v
;
; CALLING SEQUENCE:
;   dist = KINDIST (L, B, V)
;
; INPUTS:
;   
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;   DIST -- the kinematic distance in units of R0 (defaults to pc).
;
; MODIFICATION HISTORY:
;
;-


  if n_elements(r0) eq 0 then r0 = 8.4d3
  if n_elements(v0) eq 0 then v0 = 2.54d2
  
  if (not keyword_set(dynamical)) or (keyword_set(kinematic)) then begin
    solarmotion_ra = ((18+03/6d1+50.29/3.6d3)*15)
    solarmotion_dec = (30+0/6d1+16.8/3.6d3)
    solarmotion_mag = 20.0
  endif else begin
    solarmotion_ra = ((17+49/6d1+58.667/3.6d3)*15)
    solarmotion_dec = (28+7/6d1+3.96/3.6d3)
    solarmotion_mag = 16.55294
  endelse
  
  euler, l, b, ra, dec, 2
  gcirc, 2, solarmotion_ra, solarmotion_dec, ra, dec, theta
  vhelio = v-solarmotion_mag*cos(theta)
  
  bigu = 2.3
  bigv = -14.7
  bigw = 3.0

  solarmotion_mag = sqrt(bigu^2+bigv^2+bigw^2)
  towards_l = atan(bigv, bigu)
  towards_b = atan(bigw, sqrt(bigv^2+bigu^2))

  null = 1/(1+v/(v0*sin(l*!dtor)*cos(b*!dtor)))

;  The > 0 traps things near the tangent point and sets them to the
;  tangent distance.  So quietly.  Perhaps this should pitch a flag?
  radical = sqrt(((cos(l*!dtor))^2-(1-null^2)) > 0)
  
  fardist = r0*(cos(l*!dtor)+radical)/(cos(b*!dtor))
  
  neardist = r0*(cos(l*!dtor)-radical)/(cos(b*!dtor))
  rgal = null*r0
  ind = where(abs(l-180) lt 90, ct)
  if ct gt 0 then neardist[ind] = !values.f_nan

  if (not keyword_set(near)) then dist = fardist else dist = neardist


  return, abs(dist)
end


  return
end
