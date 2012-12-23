function desanitize, hd, hdtemplate
  hdout = hd
  naxis = sxpar(hdtemplate, 'NAXIS')
  s = strcompress(string(indgen(naxis)+1), /rem)
  if naxis gt 2 then begin
    sxaddpar, hdout, 'NAXIS', naxis
    for k = 3, naxis do begin
      sxaddpar, hdout, 'NAXIS'+s[k-1], sxpar(hdtemplate, 'NAXIS'+s[k-1])
      sxaddpar, hdout, 'CRPIX'+s[k-1], sxpar(hdtemplate, 'CRPIX'+s[k-1])
      sxaddpar, hdout, 'CRVAL'+s[k-1], sxpar(hdtemplate, 'CRVAL'+s[k-1])
      sxaddpar, hdout, 'CDELT'+s[k-1], sxpar(hdtemplate, 'CDELT'+s[k-1])
      sxaddpar, hdout, 'CTYPE'+s[k-1], sxpar(hdtemplate, 'CTYPE'+s[k-1])
      sxaddpar, hdout, 'CROTA'+s[k-1], sxpar(hdtemplate, 'CROTA'+s[k-1])
    endfor
  endif 



  return, hdout
end
