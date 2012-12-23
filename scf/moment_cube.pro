function moment_cube, data, h, mask = mask, emap = emap
;+
; NAME:
;    MOMENT_CUBE
; PURPOSE:
;    To take the 0th, 1st and 2nd moments of cubes.
;
; CALLING SEQUENCE:
;    moment_str = moment_cube( data, hd_structure ) 
;
; INPUTS:
;    DATA -- Data cube to be analyzed
;    HD_STRUCTURE -- Structure from RDHD.pro containing header information.
; KEYWORD PARAMETERS:
;    NOMASK -- Does not mask to include emission in moment.
;
; OUTPUTS:
;    MOMENT_STR -- Structure containing moments of the emission in the
;                  cube.  
;
; MODIFICATION HISTORY:
;       Written
;       Fri Nov 15 13:10:37 2002, Erik Rosolowsky <eros@cosmic>
;
;		
;    
;-

  sz = size(data)

  if n_elements(mask) eq 0 then mask = bytarr(sz[1], sz[2], sz[3])+1b
  if n_elements(emap) eq 0 then emap = fltarr(sz[1], sz[2])
  if n_elements(h) gt 0 then vel = h.v else vel = indgen(sz[3])
  

  m0 = fltarr(sz[1], sz[2])
  em0 = fltarr(sz[1], sz[2])
  m1 = fltarr(sz[1], sz[2])
  em1 = fltarr(sz[1], sz[2])
  m2 = fltarr(sz[1], sz[2])
  em2 = fltarr(sz[1], sz[2])

  for i = 0, sz[1]-1 do begin
    for j = 0, sz[2]-1 do begin
      spectrum = data[i, j, *]
      ind = where(mask[i, j, *])
      mom = wt_moment(vel, spectrum[ind], errors = emap[i, j])
      m0[i, j] = total(spectrum[ind])
      m1[i, j] = mom.mean
      m2[i, j] = mom.stdev
      em1[i, j] = mom.errmn
      em2[i, j] = mom.errsd
      em0[i, j] = sqrt(n_elements(ind))*emap[i, j]
    endfor
  endfor
  return, {mom0:m0, mom1:m1, mom2:m2, err_mom0:em0, $
           err_mom1:em1, err_mom2:em2}
end
