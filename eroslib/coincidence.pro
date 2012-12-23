pro coincidence, catalog, parent, union = union, disjoint = disjoint, $
                 tol = tol, member = member, nonmember = nonmember
;+
; NAME:
;   COINCIDENCE
; PURPOSE:
;   To locate the set of clouds that appears in two different
;   catalogs.
;   This only works on D-array catalog source.
;
; CALLING SEQUENCE:
;   COINCIDENCE, catalog, parent_catalog [, union=union, disjoint=disjoint]
;
; INPUTS:
;   CATALOG -- The catalog containing the data.
;   PARENT_CATALOG -- Catalog to be compared to.
; KEYWORD PARAMETERS:
;   TOL -- distance (in pixels) to cm
;
; OUTPUTS:
;   UNION -- Indices of catalog that appear in both catalogs.
;   DISJOINT -- Indices of catalog that do not appear in parent.
; MODIFICATION HISTORY:
;
;-

  if n_elements(tol) eq 0 then tol = 1.5
  union = [-1]
  disjoint = [-1]
  member = [-1]
  nonmember = [-1]
  for i = 0, n_elements(catalog)-1 do begin
    dist = sqrt(min((catalog[i].x-parent.x)^2+$
                    (catalog[i].y-parent.y)^2+$
                    ((catalog[i].v-parent.v)/2.0138)^2, ind))
    if dist lt tol then begin
      union = [union, i] 
      member = [member, ind]
    endif else begin
      disjoint = [disjoint, i]
      nonmember = [nonmember, ind]
    endelse
  endfor 
  if n_elements(union) gt 1 then union = union[1:*]
  if n_elements(disjoint) gt 1 then disjoint = disjoint[1:*]
  if n_elements(member) gt 1 then member = member[1:*]
  if n_elements(nonmember) gt 1 then nonmember = nonmember[1:*]
  return
end

