function degls, hd
;+
; NAME:
;   DEGLS
; PURPOSE:
;   Replace GLS astrometry with SFL
; CALLING SEQUENCE:
;   DEGLS, hdr
;
; INPUTS:
;   HDR -- A FITS header
;
; OUTPUTS:
;   HDR is cleaned up in place
;
; MODIFICATION HISTORY:
;
;       Fri Dec 18 01:34:47 2009, Erik <eros@orthanc.local>
;
;		Docd.
;
;-

  hdout = hd
  naxis = sxpar(hd, 'NAXIS')
  s = strcompress(string(indgen(naxis)+1), /rem)
  for k = 1, naxis do begin
    type = sxpar(hdout, 'CTYPE'+s[k-1])
    glshit = stregex(type, 'GLS')
    if glshit ge 0 then begin
      type = strmid(type, 0, glshit)+'SFL'
      sxaddpar, hdout, 'CTYPE'+s[k-1], type
    endif 
  endfor


  return, hdout
end
