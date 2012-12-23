pro mossplit, file = file, gra = gra, gdec = gdec, title = title

  if n_elements(file) gt 0 then begin
    parsegrid, file, gra, gdec
  endif else begin
    if n_elements(gra) eq 0 then message, $
      'Grid elements or grid file must be specified', /con
    if n_elements(gra) eq 0 then return
    if n_elements(gra) ne n_elements(gdec) then begin
      message, 'Grid arrays must have the same length', /con
      return
    endif
  endelse 
  if n_elements(title) eq 0 then leadstr = '' else leadstr = title
  ra = gra*60
  dec = gdec*60
  openw, lun, 'mosspilt.log', /get_lun
  printf, lun, 'mossplit.pro run on'+systime()
  cd, current = path

  for i = 0, n_elements(ra)-1 do begin 
    filename = strcompress(leadstr+'.'+string(i+1)+'.gcal', /remove)
    ura = strtrim(string(ra[i]+1), 2)
    lra = strtrim(string(ra[i]-1), 2)
    udec = strtrim(string(dec[i]+1), 2)
    ldec = strtrim(string(dec[i]-1), 2)
    spawn, 'rm -rf '+filename
    spawn, 'uvcat vis=m31.gcal out='+filename+$
      ' select=dra\('+lra+','+ura+$
      '\),ddec\('+ldec+','+udec+'\)'
    printf, lun, 'File '+filename+' written at '+systime()
    printf, lun, ra[i]/60, dec[i]/60, i
  endfor
  close, lun
  free_lun, lun

  return
end
