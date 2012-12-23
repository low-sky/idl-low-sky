function beamfit, fitscube,  degrees = degrees, minutes = minutes,  $
                  header = header,  structure = structure, planes = planes

;+
; NAME:
;    beamfit
; PURPOSE:
;    To determine the size of the beam in a BIMA observation.
;
; CALLING SEQUENCE:
;    result=BEAMFIT(bcube)
;
; INPUTS:
;    FITSCUBE - the name of a fits cube of beam sizes or a cube of
;               beam sizes
;
; KEYWORD PARAMETERS:
;    DEGREES - print output in degrees
;    MINUTES - print output in minutes
;    HEADER - Name of a variable containing FITS header
;                       information for FITSCUBE input
;    STRUCTURE - Returns a structure containing beam information with
;                appropriate labels.
;    PLANES - Writes out a structure analyzing each plane of the data
;             individually.  Only functions 
; OUTPUTS:
;    A three element array containing the FWHM of the beam in the semi
;    major and the semi-minor directions and the position angle of the
;    semi-major axis from the x-direction in degrees ccw.
;    OR - A structure containing the information with appropriate tags.
;
; MODIFICATION HISTORY:
;
;       Implemented cube passing to function and included orientation
;       angle of ellipse. -- Thu Oct 12 18:08:29 2000, Erik Rosolowsky
;       <eros@cosmic>
;       Begin writing -- Sun Oct 8 23:07:49 2000, Erik Rosolowsky
;                        <eros@cosmic>
;
;		
;
;-
if keyword_set(degrees) and keyword_set(minutes) then begin
  message, 'Only one of DEGREES and MINUTES may be used', /con
  message, 'Using MINUTES', /con
  degrees = 0
end

if size(fitscube, /type) eq 7 then begin
  cube = readfits(fitscube, hdr)
  cdelt1 = sxpar(hdr, 'CDELT1')
  cdelt2 = sxpar(hdr, 'CDELT2')
endif else begin
  cube = fitscube
  if not keyword_set(header) then begin
    message, 'No header info specified. Returning values in pixel spacing.',$
      /con
    degrees = 1
    cdelt1 = 1. & cdelt2 = 1. 
    endif else begin
    cdelt1 = sxpar(header, 'CDELT1')
    cdelt2 = sxpar(header, 'CDELT2')    
  endelse
endelse

sz = size(cube)

if sz[0] eq 3 then plane = cube[*, *, 0]
if sz[0] eq 2 then plane = cube
if sz[0] ne 3 and sz[0] ne 2 then begin
  message, 'Inappropriate Beam Array!!', /con
  return, [0., 0.]
endif

if n_elements(planes) eq 0 then begin

fit = gauss2dfit(plane, a, findgen(sz[1])*cdelt1,$
                 findgen(sz[2])*cdelt2, /tilt)
sfac = sqrt(8*alog(2))*3600
result =[a[2], a[3]]*sfac


if keyword_set(degrees) then result = result/3600.
if keyword_set(minutes) then result = result/60.
if keyword_set(structure) then begin
  if keyword_set(degrees) then utype = 'DEGREES'
  if keyword_set(minutes) then utype = 'ARCMIN'
  if (size(utype))[0] eq 0 then utype = 'ARCSEC'
  return, {beam:plane, fwhm_maj:result[0], $
           fwhm_min:result[1], posn_ang:a[6]*!radeg, units:utype}
endif else begin
  return, [result, a[6]*!radeg]
endelse
endif 

if sz[0] eq 3 and n_elements(planes) ne 0 then begin

  template = {beam:dblarr(sz[1], sz[2]), fwhm_maj:0.d, $
              fwhm_min:0.d, posn_ang:0.d, units:''}
  rslt = [template]
  for i = 0, sz[3]-1 do begin
    plane = cube[*, *, i]
    fit = gauss2dfit(plane, a, findgen(sz[1])*cdelt1, $
                     findgen(sz[2])*cdelt2, /tilt)
    sfac = sqrt(8*alog(2))*3600
    result = [a[2], a[3]]*sfac
    
    
    if keyword_set(degrees) then result = result/3600.
    if keyword_set(minutes) then result = result/60.
;    if keyword_set(structure) then begin
    if keyword_set(degrees) then utype = 'DEGREES'
    if keyword_set(minutes) then utype = 'ARCMIN'
    if (size(utype))[0] eq 0 then utype = 'ARCSEC'
    rs = {beam:fit, fwhm_maj:result[0], $
              fwhm_min:result[1], posn_ang:a[6]*!radeg, units:utype}
    rslt = [rslt,rs]
;    endif else begin
;      return, [result, a[6]*!radeg]
;    endelse
    endfor 
    return, rslt[1:*]
  endif 
end



