pro htranspose, image, header, transpose_vector
;+
; NAME:
;   HTRANSPOSE 
;
; PURPOSE:
;   Transpose an image and update FITS header.
;
; CALLING SEQUENCE:
;   HTRANSPOSE, image, header, transpose_vector
;
; INPUTS:
;
;   IMAGE, HEADER -- Input image and header
;   TRANSPOSE_VECTOR -- Vector of final dimensions. See TRANSPOSE for
;                       details.  
;
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   Transposes IMAGE and HEADER in place
;
; MODIFICATION HISTORY:
;
;       Mon Jul 18 11:48:34 2005, Erik Rosolowsky
;       <erosolow@zeus.cfa.harvard.edu>
;
;		Written.
;
;-


; First transpose the data
  image = transpose(image, transpose_vector)

  namevec = strcompress(string(transpose_vector+1), /rem)
  header_out = header

  for k = 0, n_elements(namevec)-1 do begin 
    newname = strcompress(string(k+1), /rem)

    null = sxpar(header, 'NAXIS'+namevec[k], count = ct)
    if ct then sxaddpar, header_out, 'NAXIS'+newname, $
                         sxpar(header, 'NAXIS'+namevec[k])


    null = sxpar(header, 'CTYPE'+namevec[k], count = ct)
    if ct then sxaddpar, header_out, 'CTYPE'+newname, $
                         sxpar(header, 'CTYPE'+namevec[k])

    null = sxpar(header, 'CRVAL'+namevec[k],  count = ct)
    if ct then sxaddpar, header_out, 'CRVAL'+newname, $
                         sxpar(header, 'CRVAL'+namevec[k])

    null = sxpar(header, 'CRPIX'+namevec[k],  count = ct)
    if ct then sxaddpar, header_out, 'CRPIX'+newname, $
                         sxpar(header, 'CRPIX'+namevec[k])
    
    null = sxpar(header, 'CDELT'+namevec[k],  count = ct)
    if ct then sxaddpar, header_out, 'CDELT'+newname, $
                         sxpar(header, 'CDELT'+namevec[k])


  endfor

  header = header_out

  return
end
