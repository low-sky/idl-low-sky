function lasso_sub, cube, hdr, mask = mask, image = image, $
               _extra = ex, x_border = x_border, y_border = y_border, $
                    newheader = hd, pad = pad
;+
; NAME:
;   LASSO_SUB
; PURPOSE:
;   Extracts a subcube from a cube in memory using a lasso of the
;   region in question.  FITS astrometry is updated if a header is passed.
;
; CALLING SEQUENCE:
;   minicube = LASSO_SUB( cube, hdr, [, mask = mask, image = image, $
;                          x_border = x_border, y_border = y_border, $
;                          newheader = newheader, pad = pad])
; INPUTS:
;    CUBE -- A data cube with velocity on third axis (not the first).
;
; OPTIONAL INPUTS:
;    HDR -- FITS header
;    NEWHEADER -- named variable to contain updated header information.
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
;    PAD -- Size of pixel border around the extracted region.  PAD is
;           NOT applied to the velocity direction.
;    
;
; OUTPUTS:
;    MINICUBE -- an extracted subcube of the region.
;
;
; MODIFICATION HISTORY:
;       Written
;	Fri Dec 16 10:58:30 2005, Erik Rosolowsky <erosolow@cfa>
;
;-


    sz = size(cube)
    if n_elements(pad) eq 0 then pad = 1

    if sz[0] ne 3 then begin
      message, 'Input data cube must have 3 dimensions!', /con
      return, !values.f_nan
    endif 

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

  xposn = indices mod sz[1]
  yposn = indices / sz[1]

; Generate the MINICUBE
  xsize = max(xposn)-min(xposn)+1+2*pad
  xoffset = min(xposn)-pad > 0
  ysize = max(yposn)-min(yposn)+1+2*pad
  yoffset = min(yposn)-pad > 0
  newsz = sz
  newsz[1] = xsize
  newsz[2] = ysize
  minicube = make_array(size = newsz)+!values.f_nan
  
; Get spectra for these points.
  indices_3d = indices#(replicate(1, sz[3]))+$
               replicate(1, n_elements(indices))#(indgen(sz[3]))*sz[1]*sz[2]
  newindices = (xposn-xoffset)+(yposn-yoffset)*newsz[1]
  newindices_3d = newindices#(replicate(1, sz[3]))+$
                  replicate(1, n_elements(newindices))#$
                  (indgen(sz[3]))*newsz[1]*newsz[2]
  minicube[newindices_3d] = cube[indices_3d]

; Update FITS feader information about region if provided.
  if n_elements(hdr) gt 0 then begin
    hd = hdr
    sxaddpar, hd, 'NAXIS1', newsz[1]
    sxaddpar, hd, 'NAXIS2', newsz[2]
    sxaddpar, hd, 'CRPIX1', sxpar(hd, 'CRPIX1')-xoffset 
    sxaddpar, hd, 'CRPIX2', sxpar(hd, 'CRPIX2')-yoffset 
  endif

  return, minicube
end
