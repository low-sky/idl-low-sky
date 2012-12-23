function moment_angle, theta, nan = nan,  degrees = degrees
;+
; NAME:
;   MOMENT_ANGLE
; PURPOSE:
;   Calculates the mean and standard deviation of a distribution of angles.
;
; CALLING SEQUENCE:
;   vector = MOMENT_ANGLE(theta)
;
; INPUTS:
;   THETA -- An array of angles in radians
;
; KEYWORD PARAMETERS:
;   NAN -- Ignore NAN values.
;   DEGREES -- The input angle is in degrees.
;
; OUTPUTS:
;   VECTOR -- Element 1 contains the mean and element 2 contains the
;             standard deviation.
;
; RESTRICTIONS:  STANDARD DEVIATION NOT IMPLEMENTED CORRECTLY YET!
;
; MODIFICATION HISTORY:
;       Developed DUMB version (doesn't do SD correctly).
;       Thu Jun 20 10:43:44 2002, Erik Rosolowsky <eros@cosmic>
;-


  if n_elements(theta) le 1 then begin
    message, 'Cannot Compute moment for fewer than 2 elements', /con
    return, theta
  endif

  if keyword_set(nan) then begin
    v = theta[where(theta eq theta)]
  endif else v = theta

  if keyword_set(degrees) then v = v*!dtor
  x = cos(v)
  y = sin(v)
  mn = atan(mean(y), mean(x))
  diff = (v-mn+!pi mod (2*!pi))
  diff = diff+(2*!pi)*(diff lt 0)-!pi
  sd = sqrt(total((diff)^2)/(n_elements(v)-1))
  
  if keyword_set(degrees) then begin
    mn = mn*!radeg
    sd = sd*!radeg
  endif

  return, [mn, sd]
end
