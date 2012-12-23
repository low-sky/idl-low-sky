function bolocam_emap2, data, box = box, single = single
;+
; NAME:
;   BOLOCAM_EMAP2
; PURPOSE:
;   Generates error map for bolocam NOISEMAP, i.e., signal free map
; CALLING SEQUENCE:
;   errmap =BOLOCAM_EMAP2(data [,box = box, /single]
;
; INPUTS:
;   DATA -- A bolocam noise map or signal free map
;
; KEYWORD PARAMETERS:
;   BOX -- Size of box over which to estimate error [15 pixels]
;   /SINGLE -- Return a single value at all positions
; OUTPUTS:
;   ERRORMAP -- an error estimate
;
; MODIFICATION HISTORY:
;
;       Thu Dec 17 23:46:34 2009, Erik <eros@orthanc.local>
;
;		Documented.
;
;-

  if n_elements(box) eq 0 then box = 3
  sz = size(DatA)

  emap = fltarr(sz[1], sz[2])+!values.f_nan
  if keyword_set(single) then begin
    global = mad(data)+fltarr(sz[1], sz[2])
    return, global
  endif


  for i = 0, sz[1]-1 do begin
    for j = 0, sz[2]-1 do begin
      vals = data[(i-box) > 0 : (i+box) < (sz[1]-1), $
                  (j-box) > 0 : (j+box) < (sz[2]-1)]
      testerr = mad(vals)
      emap[i, j] = testerr
    endfor
  endfor
  
  global = mad(data)
  badind = where((emap eq 0), ct)
  if ct gt 0 then emap[badind] = global

  return, emap
end
