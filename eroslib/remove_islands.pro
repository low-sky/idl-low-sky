function remove_islands, mask, minsize, all_neighbors = all_neighbors
;+
; NAME:
;   REMOVE_ISLANDS
;
; PURPOSE:
;   Removes islands in a (arbitrary dimensional) mask with number of
;   pixels < MINSIZE.   
;
; CALLING SEQUENCE:
;   newmask = REMOVE_ISLANDS(mask, minsize [, all_neighbors = all_neighbors])
;
; INPUTS:
;   MASK -- Input binary mask
;   MINSIZE -- Threshold size of object to return
;
; KEYWORD PARAMETERS:
;   ALL_NEIGHBORS -- Set this keyword allow diagonal pixels.
;
; OUTPUTS:
;   NEWMASK -- decimated mask
;
; MODIFICATION HISTORY:
;
;	Tue Apr 25 21:36:00 2006, Erik 
;               Trapped empty mask passage.
;
;       Mon Aug 8 10:54:56 2005, Erik Rosolowsky
;       <erosolow@asgard.cfa.harvard.edu>
;
;		Made it faster.  Much faster.
;
;       Mon Jul 18 11:41:26 2005, Erik Rosolowsky
;       <erosolow@zeus.cfa.harvard.edu>
;
;		Documented.
;
;-

  dims = size(mask, /dimensions)

  if total(mask) eq 0 then begin
    message, 'Mask contains no elements.', /con
    return, mask
  endif

; Removes islands of < MINSIZE pixels from masks
  mask_out = bytarr(dims+2)
  

  case n_elements(dims) of
    1:mask_out[1] = mask
    2:mask_out[1, 1] = mask
    3:mask_out[1, 1, 1] = mask
    4:mask_out[1, 1, 1, 1] = mask
    5:mask_out[1, 1, 1, 1, 1] = mask
    6:mask_out[1, 1, 1, 1, 1, 1] = mask
    7:mask_out[1, 1, 1, 1, 1, 1, 1] = mask
    8:mask_out[1, 1, 1, 1, 1, 1, 1, 1] = mask
  endcase

  regions = label_region(mask_out, all_neighbors = all_neighbors, /ulong)
  h = histogram(regions, binsize = 1, min = 1, rev = ri)
  ind = where(h lt minsize, ct)
  if ct gt 0 then begin
    for k = 0L, ct-1 do begin
      kill_inds = ri[ri[ind[k]]:(ri[ind[k]+1])-1]
      mask_out[kill_inds] = 0b
    endfor
  endif
  case n_elements(dims) of
    1:mask_out = mask_out[1:dims[0]] 
    2:mask_out = mask_out[1:dims[0], 1:dims[1]] 
    3:mask_out = mask_out[1:dims[0], 1:dims[1], 1:dims[2]] 
    4:mask_out = mask_out[1:dims[0], 1:dims[1], 1:dims[2], $
                          1:dims[3]] 
    5:mask_out = mask_out[1:dims[0], 1:dims[1], 1:dims[2], $
                          1:dims[3], 1:dims[4]] 
    6:mask_out = mask_out[1:dims[0], 1:dims[1], 1:dims[2], $
                          1:dims[3], 1:dims[4], 1:dims[5]]
    7:mask_out = mask_out[1:dims[0], 1:dims[1], 1:dims[2], $
                          1:dims[3], 1:dims[4], 1:dims[5], $
                          1:dims[6]]
    8:mask_out = mask_out[1:dims[0], 1:dims[1], 1:dims[2], $
                          1:dims[3], 1:dims[4], 1:dims[5], $
                          1:dims[6], 1:dims[7]]
  endcase 

  return, mask_out
end
