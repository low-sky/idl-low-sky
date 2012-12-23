pro bgps2kvis, bgps_in, file = file
;+
; NAME:
;   bgps2kvis
; PURPOSE:
;   Converts a Bolocat property structure into KVIS region files
; CALLING SEQUENCE:
;   BGPS2KVIS, props
;
; INPUTS:
;   PROPS -- Bolcoat output property structure
;
; KEYWORD PARAMETERS:
;   None that work. 
;
; OUTPUTS:
;   Region files output to karma directory
;
; MODIFICATION HISTORY:
;
;       Thu Dec 17 23:34:52 2009, Erik <eros@orthanc.local>
;
;		Documented
;
;-
  
  dx = 0.0047079999
  fn = bgps_in.filename
  fn = fn[uniq(fn, sort(fn))]
  spawn,'mkdir karma'

  for j = 0, n_elements(fn)-1 do begin 
    
    hits = where(fn[j] eq bgps_in.filename, ct)
    if ct eq 0 then continue
        
    slashpos=strpos(fn[j],'/',/reverse_search)
    startpos = strpos(strmid(fn[j],slashpos+1,50), '_')+slashpos
    root = strmid(fn[j], startpos+2, 50)
    endpos = strpos(root, '_')
    root = strmid(root, 0, endpos)

    file='./karma/'+root+'.ann'
    bgps=bgps_in[hits]
    if max(bgps.glon_max)-min(bgps.glon_max) gt 180 then begin
      wrapped = wherE(bgps.glon_max gt 180)
      bgps[wrapped].glon_max = bgps[wrapped].glon_max-360
      bgps[wrapped].glon= bgps[wrapped].glon-360
      
    endif
    colprint, file = 'null3.ann', replicatE('ELLIPSE W ', n_elements(bgps)), $
              bgps.glon, bgps.glat, bgps.mommajpix*dx, $
              bgps.momminpix*dx, bgps.posang*!radeg+90

    colprint, file = 'null.ann', replicatE('CROSS', n_elements(bgps)), $
              bgps.glon_max, bgps.glat_max, replicate(0.01, n_elements(bgps)), $
              replicate(0.01, n_elements(bgps))

    colprint, file = 'null2.ann', replicatE('TEXT', n_elements(bgps)), $
              bgps.glon_max, bgps.glat_max,decimals(bgps.cloudnum,0)
            
    spawn, 'echo PA SKY >>'+file
    spawn, 'cat null3.ann >>'+file
    spawn, 'echo COLOR RED >> '+file
    spawn, 'cat null.ann >> '+file
    spawn, 'cat null2.ann >> '+file
    spawn, 'rm -rf null.ann null2.ann null3.ann'
  endfor
  return
end
