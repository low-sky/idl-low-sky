function seeded_watershed, data, kernels, levels = levels, $
                           nlevels = nlevels, $
                           all_neighbors = all_neighbors
;+
; NAME:
;   SEEDED_WATERSHED
; PURPOSE:
;   Decompose a region using a watershed algorithm using fixed seed points.
; CALLING SEQUENCE:
;   objects = SEEDED_WATERSHED(data, seeds[, levels = level, nlevels =
;   nlevels, /all_neighbors])
;
; INPUTS:
;    DATA -- A map
;    SEED -- 1D index of locations to start
; KEYWORD PARAMETERS:
;    LEVELS, NLEVELS -- Either a vector of contour levels or a number
;                       of levels to threshold the data at.  Not needed
;    /ALL_NEIGHBORS -- passes to LABEL_REGION
; OUTPUTS:
;    OBJECT -- A label map with objects labeled with integers
;
; MODIFICATION HISTORY:
;
;       Fri Dec 18 03:02:29 2009, Erik <eros@orthanc.local>
;
;		Docd.
;
;-

  if n_elements(levels) eq 0 then $
    levels = contour_values(data, nlevels = nlevels)

  sz = size(data)
  object = ulonarr(sz[1], sz[2])
  object[kernels] = indgen(n_elements(kernels))+1
  levels=levels[reverse(sort(levels))]
  for k = 0, n_elements(levels)-1 do begin
    mask = data ge levels[k] ; GT vs GE?
    object[kernels] = indgen(n_elements(kernels))+1
    object = dilator(object, [-1, kernels], constraint = mask, /loop)
  endfor 
  l = label_region(data eq data, all_neighbors = all_neighbors)
  ctr = max(object)+1

  for k = 1,  max(l)-1 do begin
    ind = where(l eq k)
    assigns = object[ind]
    if max(assigns) eq 0 then begin
      object[ind] = ctr
      ctr = ctr+1
    endif
  endfor
  
;  stop
; Reject unconnected pixels
  ind = where(object gt n_elements(kernels), ct)
  if ct gt 0 then object[ind] = 0

  return, object
end
