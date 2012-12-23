function notind, index, nelts
;+
; NAME:
;   NOTIND
; PURPOSE:
;   To generate the complementary indices to an array of index values
;   up to a given maximum.
;
; CALLING SEQUENCE:
;   not = NOTIND(index, n_elements)
;
; INPUTS:
;   INDEX -- Array of indices to generate the complement for.
;   N_ELEMENTS -- Number of elements out of which the inidices are coming.
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   NOT -- The complementary indices.
;
; MODIFICATION HISTORY:
;       Documented.
;       Wed Nov 21 12:18:52 2001, Erik Rosolowsky <eros@cosmic>
;
;		
;
;-


x = bytarr(nelts)+1b
x[index] = 0
  return, where(x)
end
