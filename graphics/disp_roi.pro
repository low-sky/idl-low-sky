pro disp_roi, image, x, y, _extra = ex, xoplot = xop, yoplot = yop, $
psoplot = psop, ssoplot = ssop, svoplot = svoplot, svcolor = svcol
;+
; NAME:
;   DISP_ROI
; PURPOSE:
;   To interactively selection regions of interest in an image using
;   the DISP engine.
;
; CALLING SEQUENCE:
;   DISP_ROI, image, x, y [, xoplot = xoplot, yoplot = yoplot, psoplot
;   = psoplot, ssoplot = ssoplot]
;
; INPUTS:
;   IMAGE -- Image to be displayed.
;   X -- x coordinates of the image
;   Y -- y coordinates of the image
; KEYWORD PARAMETERS:
;   XOPLOT -- A vector containing x-coordinates of
;             points to overplot on the image.
;   YOPLOT -- A vector containing y-coordinates of points to overplot
;             on the image.
;   PSOPLOT -- Plot symbol to be overlaid.
;   SSOPLOT -- Symbol size to be overplotted.
;   SVOPLOT -- String vector to be overplotted at XOPLOT,YOPLOT coords.
;   SVCOLOR -- Color of string to write over.
; OUTPUTS:
;   NONE
;
; MODIFICATION HISTORY:
;   Written -- 
;       Wed Jun 13 12:23:24 2001, Erik Rosolowsky <eros@cosmic>
;-

sz = size(image)
if not keyword_set(x) then x = indegen(sz[1])
if not keyword_set(y) then y = indegen(sz[2])

if not keyword_set(psop) then psop = 1
if not keyword_set(ssop) then ssop = 2
if not keyword_set(svcol) then svcol = !d.n_colors

disp, image, x, y, _extra = ex
 if keyword_set(svoplot) then begin
     xyouts, xop, yop, svoplot, charsize = 2, color = svcol
     goto, skip
   endif
if keyword_set(xop) and keyword_set(yop) then $
  oplot, xop, yop, psym = psop, symsize = ssop
skip:
!mouse.button = 0

while (!mouse.button ne 4)  do begin

print, 'Define ROI (UL Corner) -- Left Button'
print, 'Original Image -- Middle Button'
print, 'Quit -- Right Button'

cursor, x_ul, y_ul,4, /data
;bangy = !y
 if !mouse.button eq 1 then begin
;   print, 'Left Click on Upper Left Corner'
;   cursor, x_ul, y_ul, 4, /data
   plots, x_ul, y_ul, ps = 1
   print, 'Right Click on Lower Right Corner'
   cursor, x_lr, y_lr, 4, /data
   plots, x_lr, y_lr, ps = 1
   null = min(abs(x_ul-x), x0)
   null = min(abs(x_lr-x), x1)
   null = min(abs(y_ul-y), y1)
   null = min(abs(y_lr-y), y0)
   disp, image[x0:x1, y0:y1], x[x0:x1], y[y0:y1], _extra = ex
   if keyword_set(svoplot) then begin
     xyouts, xop, yop, svoplot, charsize = 2, color = svcol
     goto, skipout
   endif
   if keyword_set(xop) and keyword_set(yop) then $
     oplot, xop, yop, psym = psop, symsize = ssop
   skipout:
 endif

 if !mouse.button eq 2 then begin
   disp, image, x, y, _extra = ex
   if keyword_set(svoplot) then begin
     xyouts, xop, yop, svoplot, charsize = 2, color = svcol
     goto, skip2
   endif
   if keyword_set(xop) and keyword_set(yop) then $
     oplot, xop, yop, psym = psop, symsize = ssop
   skip2:
 endif

endwhile
  return
end
