pro writechunk, filename, data, header, x0, x1, y0, y1, v0, v1
;+
; NAME:
;  WRITECHUNK
; PURPOSE:
;  To export a section of data cube maintaining the appropriate header
;  information so astrometry is well behaved.
;
; CALLING SEQUENCE:
;  WRITECHUNK, filename, data, header, x0, x1, y0, y1 [, v0, v1]
;
; INPUTS:
;  FILENAME -- Name of fits file to export.
;  DATA -- The data cube
;  HEADER -- String array containing header information.
;  X0,Y0 -- The x and y coordinates of the Lower Left corner of the
;           chunk.
;  X1, Y1 -- The x and y coordinates of the Upper Right corner of the
;            chunk.
;  V0, V1 -- Minimum and maximum velocity channels to include.
; KEYWORD PARAMETERS:
;  NONE
;
; REQUIRES:
;  HEXTRACT.pro -- Goddard library.
; OUTPUTS:
;  File is written.
;
; MODIFICATION HISTORY:
;       Wrote in FITS header information extraction by HEXTRACT.pro
;       since I trust Goddard astrometry more than mine.
;       Wed Nov 21 12:40:10 2001, Erik Rosolowsky <eros@cosmic>
;
;       Written --
;       Wed Jun 27 11:23:00 2001, Erik Rosolowsky <eros@cosmic>
;
;		
;-
  x0 = x0[0] & y0 = y0[0] & x1 = x1[0] & y1 = y1[0]

  sz = size(data)
  if n_elements(v0) eq 0 then begin
    v0 = 0 
    v1 = sz[3]-1
  endif
  newhd = header
  chunk = data[x0:x1, y0:y1, v0:v1]
;  cpix_x = sxpar(header, 'CRPIX1')
;  cpix_y = sxpar(header, 'CRPIX2')
  
;  cpix_x_new = cpix_x-x0
;  cpix_y_new = cpix_y-y0

  szchunk = size(chunk)
  cpix_v = sxpar(header, 'CRPIX3')
  cpix_v_new = cpix_v-v0

; Update header information!
  hdhold = header
  sxdelpar, hdhold, 'NAXIS3'
  sxdelpar, hdhold, 'NAXIS4'
  sxaddpar, hdhold, 'NAXIS', 2
  hextract, data[*, *, 0], hdhold, newim, newhd, x0, x1, y0, y1, /silent
  sxaddpar, newhd, 'NAXIS3', sxpar(header, 'NAXIS3')
  sxaddpar, newhd, 'NAXIS4', sxpar(header, 'NAXIS4')
  sxaddpar, newhd, 'NAXIS', sxpar(header, 'NAXIS')
  sxaddpar, newhd, 'CRPIX3', cpix_v_new
  writefits, filename, chunk, newhd
  return
end
