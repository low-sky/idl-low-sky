pro corners, filename, ravec = ravec, decvec = decvec, exten = exten
;+
; NAME:
;   CORNERS
; PURPOSE:
;   Returns the RA/DEC vectors of the corners of a FITS image (first 2
;   dimensions).
;
; CALLING SEQUENCE:
;   CORNERS, filename, ravec = ravec, decvec = decvec
;
; INPUTS:
;   FILENAME -- String containing a relative path and FITS filename
;
; KEYWORD PARAMETERS:
;   EXTEN -- The extension number to use for the header.
;   RAVEC / DECVEC -- name these to vectors to contain outputs.  These
;                     are the RA/DEC values of the corners, listed
;                     counter-clockwise with the first one repeated to
;                     facilitate plotting
;
; OUTPUTS:
;   See Keywords.
;
; MODIFICATION HISTORY:
;
;       Wed Aug 4 11:04:48 2004, <eros@master>
;		Written
;
;-


  hd = headfits(filename)
  extast, hd, astrom
  if n_elements(astrom) eq 0 then begin
    hd = headfits(filename, exten = 1)
    extast, hd, astrom
    if n_elements(astrom) eq 0 then begin
      message, 'No Valid FITS info found.  Try specifying extensions.', /con
      return
    endif
  endif
  rdhd, hd, s = h


  x0 = [0, h.naxis1-1, h.naxis1-1, 0, 0]
  y0 = [0, 0, h.naxis2-1, h.naxis2-1, 0]
  xy2ad, x0, y0, astrom, ravec, decvec

  return
end
