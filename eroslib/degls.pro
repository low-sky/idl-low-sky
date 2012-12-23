function degls, hd
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
