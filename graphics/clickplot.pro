pro clickplot, cube, nomask = nomask, mask = mask
;+
; NAME:
;   CLICKPLOT
; PURPOSE:
;   To interactively view the spectra in a data cube by clicking on an
;   intensity (0th moment) map and returning the plot of the spectrum
;   in another window.
;
; CALLING SEQUENCE:
;   CLICKPLOT, cube [, nomask=nomask, mask=mask]
;
; INPUTS:
;   CUBE -- Data cube to analyze
; REQUIRES:
;   CUBEMAP.PRO
; KEYWORD PARAMETERS:
;   NOMASK -- Don't mask the data in anyway.  By default the routine
;             looks for contiguous regions of high signal emission to
;             plot in the intensity.
;   MASK --  Use a given mask instead of the one derived from CUBEMAP.PRO
; OUTPUTS:
;   Pretty pictures, as always.
;
; MODIFICATION HISTORY:
;       Documented.
;       Wed Nov 21 11:32:15 2001, Erik Rosolowsky <eros@cosmic>
;-

if keyword_set(nomask) then disp, total(cube, 3, /nan) else begin
  if keyword_set(mask) then disp, total(cube*mask, 3, /nan) else cubemap, cube
endelse

!mouse.button= 0
print, 'Left Click view a spectrum.'
print, 'Right Click to finish'
window, 1, title = 'Spectrum Plot'
wset, 0
ymn = min(cube, /nan)
ymx = max(cube, /nan)
sz = size(cube)

while (!mouse.button ne 4)  do begin

cursor, xcl, ycl,4, /data
bangp = !p
bangx = !x
bangy = !y
 if !mouse.button eq 1 then begin
   wset, 1
   x = floor(xcl)
   y = floor(ycl)
   if (x lt 0) or x ge sz[1] then goto, break
   if (y lt 0) or y ge sz[2] then goto, break
   print, x, y
   plot, cube[x, y, *], psym = 10, yrange = [ymn, ymx], ystyle = 1;, $
;     title = 'Spectrum at ('+strcompress(string(x), /rem)+', '+$
;     strcompress(string(y), /rem)+')'
   break:
   wset,0

   !p = bangp
   !x = bangx
   !y = bangy
endif 

endwhile
wdelete, 1
  return
end



