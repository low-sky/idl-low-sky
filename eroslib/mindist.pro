function mindist, ra, dec, ralist, declist, distance = distance
;+
; NAME:
;   MINDIST
; PURPOSE:
;   To find which element in a list a given RA and DEC is closest to
;   using the standard spherical trigonometry.
;
; CALLING SEQUENCE:
;   INDEX = MINDIST(ra, dec, ra_list, dec_list [, distance = distance])
;
; INPUTS:
;   RA, DEC -- RA and DEC of a source in decimal degrees.
;   RA_LIST, DEC_LIST -- A list of RA and DEC to be compared in
;                        decimal degrees.
; KEYWORD PARAMETERS:
;   DISTANCE -- The distance in decimal degrees between the element
;               and the closest element of the list.
; OUTPUTS:
;
;   INDEX -- The index (IDL 0 indexed) indicating which of the
;            elements in RA_LIST and DEC_LIST the given RA and DEC is
;            closest to.
;
; MODIFICATION HISTORY:
;       Written -- 
;       Tue Apr 2 09:36:14 2002, Erik Rosolowsky <eros@cosmic>
;
;-

if n_elements(ralist) ne n_elements(declist) then begin
  message, 'RA_LIST and DEC_LIST must have the same number of elements', /con
  return, 0
endif

ra_obj = ra*!dtor
dec_obj = dec*!dtor
ra_list = ralist*!dtor
dec_list = declist*!dtor

cosdist = sin(dec_list)*sin(dec_obj)+cos(dec_list)*cos(dec_obj)*$
  cos(ra_obj-ra_list)

dist = acos(cosdist)*!radeg
distance = min(dist, index)
  return, index
end
