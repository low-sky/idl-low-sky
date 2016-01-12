pro adsplit, inarr1, inarr2, ra = ra, dec = dec, delimiter = delimiter
;+
; NAME:
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;
;
; OUTPUTS:
;
;
; MODIFICATION HISTORY:
;
;	Fri Sep  1 15:08:40 2006, Erik, Finally written.
;
;-


  if n_elements(delimiter) eq 0 then begin
    if strpos(inarr1[0], ':') gt 0 then delimiter = ':' else delimiter = ' '
  endif 

  sign = strpos(inarr2, '+') > strpos(inarr2, '-')
  ind = where(sign eq -1, ct)
  if ct gt 0 then inarr2[ind] = '+'+inarr2[ind]

  if n_elements(inarr2) gt 0 then inarr = inarr1+' '+inarr2 else inarr = inarr1


  outra = dblarr(n_elements(inarr))
  outdec = dblarr(n_elements(inarr)) 
  for i = 0, n_elements(inarr)-1 do begin
    signpos = strpos(inarr[i], '+') > strpos(inarr[i], '-')
    rastring = strcompress(strmid(inarr[i], 0, signpos))
    decstring = strcompress(strmid(inarr[i], signpos, 40))
    rasplit = float(strsplit(rastring, delimiter, /extract))
    outra[i] = (rasplit[0]+rasplit[1]/6d1+rasplit[2]/3.6d3)*15
    rasplit = float(strsplit(decstring, delimiter, /extract))
    if rasplit[0] lt 0 then sign = -1 else sign = 1
    rasplit = abs(rasplit)
    outdec[i] = sign*(rasplit[0]+rasplit[1]/6d1+rasplit[2]/3.6d3)
  endfor
  ra = outra
  dec = outdec

  return
end
