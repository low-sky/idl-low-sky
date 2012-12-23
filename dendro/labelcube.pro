pro labelcube, ptr, root, _extra = ex, ps = ps

  sz = (*ptr).szdata
  if sz[0] eq 3 then out = intarr(sz[1], sz[2], sz[3])-1 $
    else out = intarr(sz[1], sz[2])
  out[(*ptr).cubeindex] = (*ptr).cluster_label
  
  hd = headfits(root+'.fits')
  sxaddpar, hd, 'BUNIT', 'CLUSTER'
  writefits, root+'.cll.fits', out, hd

  clusters = (*ptr).clusters
  ht = (*ptr).height
  merger = (*ptr).merger
  szmerger = size(merger)
  order = (*ptr).order

  openw, lun, root+'.cluster.xml', /get_lun
  printf, lun, '<?xml version="1.0" encoding="UTF-8"?>'
  printf, lun, '<LabelDescription>'
  for k = 0, szmerger[1]-1 do begin
    val = strcompress(string(merger[k, k]), /rem)
    kval = strcompress(string(k), /rem)
    printf, lun, '<Label value="'+kval+'" >'
    printf, lun, '     <Parameter name="intensity" value="'+val+'" />'
    printf, lun, '</Label>'
  endfor
  for k = 0, n_elements(clusters)/2-1 do begin
    val = strcompress(ht[k+szmerger[1]], /rem)
    kval = strcompress(string(k+szmerger[1]), /rem)
    cl1 = strcompress(string(clusters[0, k]), /rem)
    cl2 = strcompress(string(clusters[1, k]), /rem)
    printf, lun, '<Label value="'+kval+'" >'
    printf, lun, '     <Parameter name="intensity" value="'+val+'" />'
    printf, lun, '     <IncludesLabels>'
    printf, lun, '          <Label value="'+cl1+'" />'
    printf, lun, '          <Label value="'+cl2+'" />'
    printf, lun, '     </IncludesLabels>'
    printf, lun, '</Label>'    
  endfor 
  printf, lun, '</LabelDescription>'
  close, lun
  free_lun, lun
  
  if keyword_set(ps) then $
    ps, /def, /jour, /color, /land, $
        xsize = 9, ysize = 7, /ps, file = root+'.clusters.ps', yoff = 10.5
  dpl, ptr, _extra = ex
  xloc = (*ptr).xlocation

  for k = 0, n_elements(xloc)-1 do begin
    xyouts, xloc[k], ht[k], align = 0.5, strcompress(string(k), /rem)

  endfor
  if keyword_set(ps) then ps, /x, /jour


  return
end
