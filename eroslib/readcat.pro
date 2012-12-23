function readcat, file

  if n_elements(file) eq 0 then file = 'catalog.txt' 
readcol, file, index, ra, dec, vlsr, mass,$
 peak, fwhm, widths, prob, format = 'I,D,D,F,F,F,F,F,F'

  return, {index:index, ra:ra, dec:dec, v:vlsr, mass:mass, peak:peak,$
         fwhm:fwhm, widths:widths, prob:prob}
end
