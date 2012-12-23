pro cull, bgps, file = file
;+
; NAME:
;   CULL
; PURPOSE:
;   Culls a catalog based on a given set of boundary files.
;
; CALLING SEQUENCE:
;   CULL, props [,file = file]
;
; INPUTS:
;   PROPS -- A bolocat property structure
;
; KEYWORD PARAMETERS:
;   FILE -- a boundary file
;
; OUTPUTS: 
;   PROPS is shortened in place
;
; MODIFICATION HISTORY:
;
;       Fri Dec 18 01:32:50 2009, Erik <eros@orthanc.local>
;
;		Docd.
;
;-


  if n_elements(file) eq 0 then file = 'bounds.txt'
  readcol, file, filename, lmin, lmax, bmin, bmax, format = 'A,F,F,F,F'
  
; Trim to the root filename

  slashpos = strpos(filename, '/', /reverse_search)
  root = strmid(filename, slashpos[0]+1, 40)
  
  catroots = (bgps.filename)
  slashpos = strpos(catroots, '/', /reverse_search)
  catroots = strmid(catroots, slashpos[0]+1, 40)
  catroots = catroots[uniq(catroots, sort(catroots))]


  keep=bytarr(n_elements(bgps)) 
  for i = 0, n_elements(catroots)-1 do begin
    ind = where(root eq catroots[i], ct)

    if ct eq 0 then continue
    for j = 0, ct-1 do begin
      if lmin[ind[j]] eq -1 then continue
      keepind = where(strpos(bgps.filename, catroots[i]) ge 0 and $
                   bgps.glon_max ge lmin[ind[j]] and $
                   bgps.glon_max lt lmax[ind[j]] and $
                   bgps.glat_max ge bmin[ind[j]] and $
                   bgps.glat_max lt bmax[ind[j]], ct)
      if ct gt 0 then keep[keepind]=(keep[keepind] or 1b)
;    filk = where(strpos(bgps.filename, catroots[i]) ge 0)
;    print, catroots[i], root[ind], lmin[ind[0]], lmax[ind[0]]
;    stop
    endfor
  endfor
  bgps = bgps[where(keep)]



  return
end
