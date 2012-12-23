pro oplotscale, length, hstr = hstr, dist = dist, color = color, $
                charsize = charsize, ypos = ypos, xpos = xpos, $
                nolabel = nolabel, label = label, _extra = ex, scale = scale
;+
; NAME:
;  OPLOTSCALE
; PURPOSE:
;  Plots a distance scale bar onto an existing plot.
;
; CALLING SEQUENCE:
;   OPLOTSCALE, length, hstr=hstr [, dist = dist, color=color,
;               charsize=charsize, pfrac=pfrac, ypos=ypos]
;
; INPUTS:
;   LENGTH -- Length in parsecs of the scale bar.
;   HSTR -- Header structure extracted by the RDHD program.
; KEYWORD PARAMETERS:
;   DIST -- Distance to target, defaults to M33.
;   COLOR -- plot color of scale.
;   CHARSIZE -- Character size to plot legend in.
;   YPOS -- Y position of the scale bar.  Defaults to 0.1 along the plot.
;   NOLABEL -- Don't print the label
; OUTPUTS:
;   None.
;
; MODIFICATION HISTORY:
;       Added character size scale padding
;       Wed Jan 15 13:38:06 2003, Erik Rosolowsky <eros@cosmic>
;
;       Added XPOS keyword.
;       Fri Jan 10 16:26:25 2003, <eros@master>
;
;        Documented.  Tue Oct 16 14:10:51 2001, Erik Rosolowsky
;        <eros@cosmic> -



if not keyword_set(pfrac) then pfrac = 1
if not keyword_set(ypos) then ypos = 0.1
if not keyword_set(xpos) then xpos = 1
if not keyword_set(charsize) then charsize = 1
if n_elements(scale) eq 0 then scale = 1

; Calculate angular scale of 1 pixel
;ang_scale = (max(!y.crange)-min(!y.crange))/n_elements(hstr.dec)/57.3*dist
if not keyword_set(dist) then dist = float(getenv('M33DIST'))
if not keyword_set(charsize) then charsize = 1
; Length of bar in normal coordinates.
subtend = float(length)/(dist)*!radeg*abs((!x.s)[1])*scale
if n_elements(color) ne 0 then begin
  bangp = !p
  !p.color = color
endif

endx = !x.window[1]-0.02-((1.0-xpos))*(!x.window[1]-!x.window[0])
stx = endx-subtend
midx = (endx+stx)/2
yv = !y.window[0]+ypos*(!y.window[1]-!y.window[0])
plots, [stx, yv], /normal, _extra = ex
plots, [stx, endx], [yv, yv], /continue, /normal, _extra = ex

if n_elements(label) eq 0 then $
  label =  strcompress(string(length), /rem)+' pc'
xyouts, midx, yv+0.01*charsize, label,$
 align = 0.5, /normal, charsize = charsize, _extra = ex, color = color

if n_elements(color) ne 0 then begin
  !p = bangp
endif
  return
end
