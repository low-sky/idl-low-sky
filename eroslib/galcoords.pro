pro galcoords, name, ra, dec, vlsr
;+
; NAME:
;    GALCOORDS
; PURPOSE:
;    To display the NED coordinates of a galaxy.
;
; CALLING SEQUENCE:
;    GALCOORDS, name[, ra, dec, vlsr, /SILENT]
;
; INPUTS:
;    NAME -- Required input, forms the query to NED.
;    RA, DEC -- named variables to accept the RA and DEC of a galaxy
; KEYWORD PARAMETERS:
;    /SILENT -- Don't print coordinates to screen.
;
; OUTPUTS:
;    None but what are listed above.
;
; MODIFICATION HISTORY:
;
;       Fri Apr 9 10:33:58 2004, Erik Rosolowsky <eros@cosmic>
;		Written.
;
;-

  querysimbad, name, ra, dec, /ned, found = found, vlsr = vlsr
  if found eq 0 then begin
    message, 'Object '+name+' not found!'
    return
  endif

  if not keyword_set(silent) then begin
    string = adstring(ra, dec)
    print, string+'   VLSR: '+string(vlsr)
  endif
  return
end
