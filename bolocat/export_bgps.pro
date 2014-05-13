pro export_bgps, dolabel = dolabel, catalog = bgps
  
; This routine makes final adjustments to the catalog including sorting, text dumps
; and the like.  This is the code developed by Erik Rosolowsky for work 
; on his very own personal export.  As such, things are hardwired to non-general 
; directory paths and such.  The code is largely here so the snippets 
; can be snipped out and pasted into other code.
  
  fl = file_search('~/bgps/catalogs/*dat')
  for i = 0, n_elements(fl)-1 do begin
    restore, file = fl[i]
    if n_elements(bgps) eq 0 then bgps = props else bgps = [bgps, props]
  endfor 
  
  cull, bgps

  bgps.glon = (bgps.glon+360) mod 360
  bgps.glon_max = (bgps.glon_max+360) mod 360
  
  nameregen, bgps
;  renumerate, bgps

  bgps = bgps[sort(bgps.glon_max)]
  
  num = lindgen(n_elements(bgps))+1
  oldnum = bgps.cloudnum
  bgps.cloudnum = num
  save, file = 'bgps.v10.dat', bgps
  ipacdump, bgps
  spawn, 'cat ipachdr.txt > bgps_catalog_ipac.tbl', /sh
  spawn, 'cat bgps_ipac.txt >> bgps_catalog_ipac.tbl', /sh
  bgps2kvis, bgps
  bgps2ds9, bgps
  

  if keyword_set(dolabel) then begin 
;  bgps_stamps, bgps


    save, file = 'bgps.v10.dat', bgps
  mwrfits, bgps, 'bgps.fits', /create


  fl = bgps.filename
  fl = fl[uniq(fl, sort(fl))]
  for i = 0, n_elements(fl)-1 do begin

    filename = strmid(fl[i], strpos(fl[i], '/', /reverse_search), strlen(fl[i]))
    char = stregex(filename, '_map50')
    labelname = strmid(filename, 0, char+1)+'label'+strmid(filename, char+1, 30)
    startpos = strpos(fl[i], 'v1.0.2_')

    root = strmid(fl[i], startpos+7, 50)
    endpos = strpos(root, '_')
    root = strmid(root, 0, endpos)
    file=root+'.obj.dat'
    restore, file = '~/bgps/obj/'+file
    hd = headfits(fl[i])
    ind = where(bgps.filename eq fl[i], ct)
    objout = long(obj)
    objout[*] = 0
    for j = 0, ct-1 do begin
      b = bgps[ind[j]]
      num = oldnum[ind[j]]
      objout[where(obj eq num)] = b.cloudnum
    endfor
    sxaddpar, hd, 'BUNIT', 'Label Map'
    sxaddpar, hd, 'COMMENT', 'Label Map of Bolocat Object'
    writefits, '~/bgps/label/'+labelname, objout, hd
    spawn, /sh, 'rm '+'~/bgps/label/'+labelname+'.gz'
    spawn, 'gzip '+'~/bgps/label'+labelname
  endfor 
  endif
  return
end
