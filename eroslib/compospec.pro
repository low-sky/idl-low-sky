function compospec, cube, mask = mask, image = image, $
               _extra = ex, x_border = x_border, y_border = y_border, $
               oversample = oversample
;+
; NAME:
;    COMPOSPEC
; PURPOSE:
;    Selects a region of a data cube and returns the composite (sum)
;    of the spectra in that region.
; CALLING SEQUENCE:
;
;    spectrum = COMPOSPEC( cube [, mask = mask, image = image, $
;                          x_border = x_border, y_border = y_border, $
;                          oversample = oversample])
;
; INPUTS:
;    CUBE -- A data cube with velocity on third axis (not the first).
;
; OPTIONAL INPUTS:
;    MASK -- A binary mask, same size as CUBE used to generate an
;            integrated intensity (0th moment) map of the data.  Used
;            to produce a reliable guide for selecting regions.  The
;            mask ONLY determines the image; it doesn't affect the
;            generation of a spectrum.  If you want a masked spectrum,
;            apply the mask to the data before using COMPOSPEC.
;    IMAGE -- A 2 dimensional image of the data cube, i.e. a 0th
;             moment map, used to select regions.  Defaults to the
;             sub of the cube along the v-axis if MASK isn't set,
;             otherwise defaults to the masked sum of the cube along
;             the v-axis.  If unset, named variable will contain image
;             when done.
;    OVERSAMPLE -- Factor by which the result should be scaled down by
;                  to account for oversampling. Defaults to 1.
;    X_BORDER, Y_BORDER -- the x,y positions of the
;    vertices of the border in units of the data cube.  If these are
;    passed to the routine, they are used to calculate the spectrum.
;    Otherwise, they are returned to the user.  Used to keep track of
;    what's involved in the region.
;
; KEYWORD PARAMETERS:
;    All extra keywords passed to DISP.pro.
;
;
; OUTPUTS:
;    SPECTRUM -- the sum of all spectra in the region of interest,
;                scaled down by OVERSAMPLE.
;
;
; OPTIONAL OUTPUTS: 
;    
; MODIFICATION HISTORY:
;       Frankencode!
;	Tue Dec 13 17:00:06 2005, Erik Rosolowsky
;
;-


    sz = size(cube)


    if sz[0] ne 3 then begin
      message, 'Input data cube must have 3 dimensions!', /con
      return, !values.f_nan
    endif 

; Set keywords  
  if n_elements(oversample) eq 0 then os = 1 else os = oversample

  if n_elements(x_border) eq 0 or $
    (n_elements(x_border) ne n_elements(y_border)) then begin
; Establish a sampling image.
    if n_elements(image) eq 0 then begin 
      if n_elements(mask) gt 0 then image = total(mask*cube, 3, /nan) else $
        image = total(cube, 3, /nan)
    endif
    
; Show it to the user.
    disp, image, _extra = ex, /sq
    
; Use RSI's selection routine.
    null = defroi(!d.x_size, !d.y_size, xverts, yverts, /noregion)
; Convert DEFROI output border to DATA coordinates.
    x_border = (float(xverts)/!d.x_size-!x.s[0])/!x.s[1]
    y_border = (float(yverts)/!d.y_size-!y.s[0])/!y.s[1]
  endif
; Lasso what's inside the border.
  indices = (polyfillv(x_border, y_border, sz[1], sz[2]))
  
; Get spectra for these points.
  indices = indices#(replicate(1, sz[3]))+$
            replicate(1, n_elements(indices))#(indgen(sz[3]))*sz[1]*sz[2]
; Add together.  
  spectrum = total(cube[indices], /nan, 1)/os

; bye-bye.
  return, spectrum
end
