pro bgps2ds9, bgps
;+
; NAME:
;   bgps2ds9
; PURPOSE:
;   Converts a Bolocat property structure into DS9 region files
; CALLING SEQUENCE:
;   BGPS2DS9, props
;
; INPUTS:
;   PROPS -- Property structure from Bolcat
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   Text region files written to ds9reg directory
;
; MODIFICATION HISTORY:
;
;       Thu Dec 17 23:33:04 2009, Erik <eros@orthanc.local>
;
;		Documented.
;
;-

  fn = bgps.filename
  fn = fn[uniq(fn, sort(fn))]


  spawn, 'mkdir ds9reg'
  spawn, 'rm ds9reg/*', /sh
  for j = 0, n_elements(fn)-1 do begin 
    
    hits = where(fn[j] eq bgps.filename, ct)
    if ct eq 0 then continue
    
    slashpos=strpos(fn[j],'/',/reverse_search)
    startpos = strpos(strmid(fn[j],slashpos+1,50), '_')+slashpos
    root = strmid(fn[j], startpos+2, 50)
    endpos = strpos(root, '_')
    root = strmid(root, 0, endpos)
    openw, lun, './ds9reg/'+root+'.reg', /get_lun    
    printf, lun, '# Region file format: DS9 version 3.0'
    printf, lun, 'GALACTIC'
    for i = 0, ct-1 do begin
      b = bgps[hits[i]]
      printf, lun, 'ellipse '+string(b.glon)+' '+string(b.glat)+' '+decimals(1.91*b.mommaj_as/3600, 5)+' '+decimals(1.91*b.mommin_as/3600., 5)+' '+decimals(b.posang*180/!pi, 0)+' # text={'+decimals(b.cloudnum,0)+'}'
      printf, lun, 'cross point '+string(b.glon_max)+' '+string(b.glat_max)
;      printf, lun, 'text '+string(b.glon_max)+' '+$
;              string(b.glat_max)+' {'+decimals(b.cloudnum,0)+'}'
    endfor
    
    close, lun
    free_lun, lun

endfor

  return
end
