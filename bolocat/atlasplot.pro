pro atlasplot, props_in, file = file
;+
; NAME:
;   ATLASPLOT
; PURPOSE:
;   Plots an atlas of Bolocam files with identified sources overlaid.
;   Requires many backup plotting routines from graphics library.
; CALLING SEQUENCE:
;   ATLASPLOT, props
;
; INPUTS:
;   PROPS -- property output structure from Bolocat
;
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   Pretty pictures.
;
; MODIFICATION HISTORY:
;
;       Thu Dec 17 23:29:28 2009, Erik <eros@orthanc.local>
;
;		Documented.
;
;-


  ps, /ps, /def, /jour, file = 'bgps.atlas.ps', $
      xsize = 10.5, ysize = 7.5, xoff = 0.5, yoff = 10.5, $
      /color, /landscape
  loadct, 3
  reversect
  setcolors, /sys, /curr
  !p.color = !black
  
  fn = props_in.filename
  fn = fn[uniq(fn, sort(fn))]
  
  for i = 0, n_elements(fn)-1 do begin


    data = mrdfits(fn[i], 0, hd)
    rdhd, hd, s = h
    l = h.ra
    b = h.dec
    diff = max(abs(shift(l, 1)-l))
    if diff gt 180 then begin
      ind = wherE(l gt 180)
      l[ind] = l[ind]-360.0
      df = 1b
    endif else df = 0b
    ind = where(props_in.filename eq fn[i], ct)
    if ct eq 0 then return
    props = props_in[ind]
    tn = replicatE(' ', 20)
    titlestr = strmid(fn[i], strpos(fn[i], '/')+1, 50)
    disp, sqrt(data), min = 0, max = 1, /sq, $
          title = titlestr, l, b, xtitle = '!6l (degrees)', $
        ytitle = '!6b (degrees)'
    mask = boundary_mask(fn[i], bdr = 0, file = file)
    contour, mask,l, b, level = 0.5, /over, c_color = !forest, c_line = 2

    rms2rad = 2.354
; oplot, props.xdata, props.ydata, ps = 1
    p = props
    ct = n_elements(p) 
    phi = findgen(61)/60*2*!pi
    x = cos(phi)
    y = sin(phi)
 dx = abs(h.cdelt[1])
 for k = 0, ct-1 do begin
   posang = p[[k]].posang
   xrot = dx*rms2rad*(p[[k]].mommajpix*x*cos(posang)+p[[k]].momminpix*y*sin(posang))
   yrot = dx*rms2rad*(-p[[k]].mommajpix*x*sin(posang)+p[[k]].momminpix*y*cos(posang))
   oplot, xrot+p[k].glon-360*(df eq 1b)*(p[k].glon gt 180), yrot+p[k].glat, color = !blue

 endfor
 plots, props.glon_max-360*(df eq 1b)*(props.glon_max gt 180), props.glat_max, color = !cyan, ps = 4, symsize = 0.5
 ind = where(props_in.filename ne fn[i], ct)
 if ct eq 0 then return
 props = props_in[ind]
 
    rms2rad = 2.354
; oplot, props.xdata, props.ydata, ps = 1
    p = props
    ct = n_elements(p) 
    phi = findgen(61)/60*2*!pi
    x = cos(phi)
    y = sin(phi)
 dx = abs(h.cdelt[1])
 for k = 0, ct-1 do begin
   posang = p[[k]].posang
   xrot = dx*rms2rad*(p[[k]].mommajpix*x*cos(posang)+p[[k]].momminpix*y*sin(posang))
   yrot = dx*rms2rad*(-p[[k]].mommajpix*x*sin(posang)+p[[k]].momminpix*y*cos(posang))
   oplot, xrot+p[k].glon-360*(df eq 1b)*(p[k].glon gt 180), yrot+p[k].glat, color = !green
;   plots, p[k].glon_max-360*(df eq 1b)*(p[k].glon_max gt 180), p[k].glat_max, color = !cyan, ps = 4, symsize = 0.5
 endfor

 
;  shade_hist, props.flux_40, min = 0, max = 10, binsize = 0.5, position = [0.1, 0.65, 0.35, 0.95], color = !blue, /noerase, xtitle = 'Flux (40", Jy)'
;  xyouts, 0.34,0.9, align = 1, 'N='+decimals(n_elements(p), 0), /normal


endfor
 
    ps, /x



  return
end
