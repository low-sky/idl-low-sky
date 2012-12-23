pro hborder, data, hd, dataout, hdout, npixels = npixels, value = value

;+
; NAME:
;   HBORDER
; PURPOSE:
;   To add a border of NPIXELS of to an image and update the
;   astrometry appropriately.
;
; CALLING SEQUENCE:
;   HBORDER, data, hd, [newdata, newhd, npixels = npixels, value = value]
;
; INPUTS:
;   DATA -- The image in question
;   HD -- The header to be update.
;   NEWDATA -- The new image, else the substitution is performed in
;              place
;   HDOUT -- The output header.
; KEYWORD PARAMETERS:
;   NPIXELS -- The number of pixels in the border.
;   VALUE -- The value to fill the pixels with.  Defaults to 0
; OUTPUTS:
;   
;
; MODIFICATION HISTORY:
;
;       Wed Mar 30 17:22:52 2005, <eros@master>
;		Written
;
;-

  np = n_params() 
  if n_elements(value) eq 0 then value = 0

  sz = size(data)
  if n_elements(npixels) eq 0 then npixels = 0

  dataout = make_array(sz[1]+2*npixels, $
                       sz[2]+2*npixels, type = size(data, /type), value = value)
 
  dataout[(npixels):(npixels+sz[1]-1), (npixels):(npixels+sz[2]-1)] = data
  hdout = hd

  sxaddpar, hdout, 'NAXIS1', sxpar(hd, 'NAXIS1')+2*npixels
  sxaddpar, hdout, 'NAXIS2', sxpar(hd, 'NAXIS2')+2*npixels
  sxaddpar, hdout, 'CRPIX1', sxpar(hd, 'CRPIX1')+npixels
  sxaddpar, hdout, 'CRPIX2', sxpar(hd, 'CRPIX2')+npixels
  
  if np eq 2 then begin
    data = dataout
    hd = hdout
  endif

  return
end
