pro hswitch, hd
;+
; NAME:
;   HSWITCH
;
; PURPOSE:
;   Switch between FREQ and VLSR for the third axis of a header.  Use
;   HTRANSPOSE to set the axis to the third
;
; CALLING SEQUENCE:
;   HSWITCH, hd
;
; INPUTS:
;   HD -- A fits header
;
; KEYWORD PARAMETERS:
;   
;
; OUTPUTS:
;   None. (Header modified in place).
;
; MODIFICATION HISTORY:
;
;       Thu Sep 1 09:14:07 2005, Erik Rosolowsky
;       <erosolow@asgard.cfa.harvard.edu>
;
;		Written
;
;-

  type = sxpar(hd, 'CTYPE3')
  
  isfreq = stregex(type, 'FREQ', /bool)
  isvel = stregex(type, 'ELO', /bool)

  if not (isvel or isfreq) then begin
  endif

  if isfreq then begin
    sxaddpar, hd, 'CTYPE3', 'FELO-LSR'
    restfreq = sxpar(hd, 'RESTFREQ')
    crvel = (restfreq-sxpar(hd, 'CRVAL3'))*3d8/restfreq
    cdelt = sxpar(hd, 'CDELT3')
    dvel = -3d8*cdelt/restfreq
    sxaddpar, hd, 'CRVAL3', crvel
    sxaddpar, hd, 'CDELT3', dvel
    return
  endif 


  if isvel then begin
    message, 'Coming soon!', /con
    return
  endif 

  message, "Header doesn't appear to be either FREQUENCY or VELOCITY", /con


  return
end
