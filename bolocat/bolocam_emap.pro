function bolocam_emap, data, box = box, single = single, niter = niter, $
                       chauv = chauv
;+
; NAME:
;   BOLOCAM_EMAP
; PURPOSE:
;   Generates an error estimate at every position of a bolocam map
;   with no assumption of source models or RMS
; CALLING SEQUENCE:
;   errmap = BOLCAM_EMAP(data [, box = box, /single, niter = niter,
;   chauv =chauv])
;
; INPUTS:
;   DATA -- A 2D bolocam map
;
; KEYWORD PARAMETERS:
;   BOX -- Size of box over which to estimate error [15 pixels]
;   /SINGLE -- Return a single value at all positions
;   NITER -- Number of iterations for outlier rejection [3]
;   CHAUV -- Magnitude of outliers to reject in units of rms [3]
; OUTPUTS:
;   ERRMAP -- an error map
;
; MODIFICATION HISTORY:
;
;       Thu Dec 17 23:44:20 2009, Erik <eros@orthanc.local>
;
;		documented.
;
;-



  if n_elements(niter) eq 0 then niter = 3
  if n_elements(chauv) eq 0 then chauv = 3

  if n_elements(box) eq 0 then box = 15
  sz = size(DatA)

  negs = fltarr(sz[1], sz[2])+!values.f_nan
  negs[where(data lt 0)] = data[where(data lt 0)]
  emap = fltarr(sz[1], sz[2])+!values.f_nan
  if keyword_set(single) then begin
    global = mad(data)+fltarr(sz[1], sz[2])
    return, global
  endif


  for i = 0, sz[1]-1 do begin
    for j = 0, sz[2]-1 do begin
      negvals = negs[(i-box) > 0 : (i+box) < (sz[1]-1), $
                  (j-box) > 0 : (j+box) < (sz[2]-1)]
      vals = data[(i-box) > 0 : (i+box) < (sz[1]-1), $
                  (j-box) > 0 : (j+box) < (sz[2]-1)]
      testerr = mad([negvals, -negvals])
      if testerr eq testerr then begin
        for k = 0, niter-1 do begin
          goodind = where(abs(vals) lt testerr*chauv, ct)
          if ct eq 0 then continue
          testvals = vals[goodind]
          testerr = mad(testvals)
        endfor
      endif  
      emap[i, j] = testerr
    endfor
  endfor
  
  global = mad(data)
  badind = where((emap eq 0), ct)
  if ct gt 0 then emap[badind] = global

  return, emap
end
