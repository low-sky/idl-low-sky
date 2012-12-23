function sanitize, hd
  hdout = hd
  naxis = sxpar(hd, 'NAXIS')
  s = strcompress(string(indgen(naxis)+1), /rem)
  if naxis gt 2 then begin
    sxaddpar, hdout, 'NAXIS', 2
    for k = 3, naxis do begin
      sxdelpar, hdout, 'NAXIS'+s[k-1]
      sxdelpar, hdout, 'CRPIX'+s[k-1]
      sxdelpar, hdout, 'CRVAL'+s[k-1]
      sxdelpar, hdout, 'CDELT'+s[k-1]
      sxdelpar, hdout, 'CTYPE'+s[k-1]
      sxdelpar, hdout, 'CROTA'+s[k-1]
    endfor
  endif 

  return, hdout
end
