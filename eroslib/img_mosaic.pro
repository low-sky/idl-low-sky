function img_mosaic, filelist, template_hdr

; Mosaics a series of images into a template header.  FITS/2D.




  runimg = dblarr(sxpar(template_hdr, 'NAXIS1'), sxpar(template_hdr, 'NAXIS2'))
  runmask = fix(runimg)
  for k = 0, n_elements(filelist)-1 do begin
    img = readfits(filelist[k], hdr)
    hastrom, img, hdr, template_hdr, missing = !values.f_nan, interp = 1
    ind = where(img eq img)
    runmask[ind]++
    runimg[ind] = img[ind]+runimg[ind]


  endfor 
  imout = runimg/runmask
  ind = where(runmask eq 0, ct)
  if ct gt 0 then imout[ind] = !values.f_nan
  return, imout
end
