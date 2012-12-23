function lasso_bigsub, filename, image, hdr, $
               _extra = ex, x_border = x_border, y_border = y_border, $
                    newheader = hd, pad = pad
;+
; NAME:
;   LASSO_BIGSUB
; PURPOSE:
;   Extracts a subcube from a cube ON DISK using a lasso of the
;   region in question from a moment map is provided.  
;   FITS astrometry is updated if a header is passed.
;
; CALLING SEQUENCE:
;   minicube = LASSO_BIGSUB(filename, image, [hdr, $
;                          mask = mask, image = image, $
;                          x_border = x_border, y_border = y_border, $
;                          newheader = newheader, pad = pad])
; INPUTS:
;    FILENAME -- the name (including relative path information) of a
;                FITS file to extract a subcube from.
;    IMAGE -- A 2 dimensional image of the data cube, i.e. a 0th
;             moment map, used to select regions. 
;
; OPTIONAL INPUTS:
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



  if n_elements(pad) eq 0 then pad = 1
  sz = size(image)

  
  hdr = headfits(filename)
  if string(hdr[0]) eq '-1' then begin
    message, 'FILENAME must reference a valid FITS image.', /con
    return, !values.f_nan
  endif 


  if sz[0] ne 2 then begin
    message, 'Input image must be 2 dimensional.', /con
    return, !values.f_nan
  endif 

  if sz[1] ne sxpar(hdr, 'NAXIS1') or sz[2] ne sxpar(hdr, 'NAXIS2') then begin
    message, "Input image's dimensions must agree with FIRST 2 dimesions of FITS file.", /con
    return, !values.f_nan
  endif 

  happy = 'z'
  repeat begin
    
    if n_elements(x_border) eq 0 or $
      (n_elements(x_border) ne n_elements(y_border)) or $
      happy eq 'n' then begin
; Show sampling image to the user.
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
; Izzat okay?
    print, 'Generate a cube containing this region [[y]nq]?
    happy = get_kbrd(1)
    if happy eq 'Q' or happy eq 'q' then return, !values.f_nan
  endrep until happy eq 'y' or happy eq 'Y' or happy eq string(10B)

; Generate the MINICUBE
  xsize = max(xposn)-min(xposn)+1+2*pad
  xoffset = min(xposn)-pad > 0
  ysize = max(yposn)-min(yposn)+1+2*pad
  yoffset = min(yposn)-pad > 0
  newsz = sz
  newsz[1] = xsize
  newsz[2] = ysize
  minicube = make_array(newsz[1], newsz[2], sxpar(hdr, 'NAXIS3'), $
                        type = size(image, /type))+!values.f_nan
  plane = minicube[*, *, 0]

  newindices = (xposn-xoffset)+(yposn-yoffset)*newsz[1]

  print, 'Beginning Extraction...'
  for k = 0, sxpar(hdr, 'NAXIS3')-1 do begin
    bigplane = mrdfits(filename, range = [k, k], /silent)
    plane[newindices] = bigplane[indices]
    minicube[*, *, k] = plane
  endfor

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
