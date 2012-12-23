pro disp3, rim, gim, bim, xin, yin, min = mn, max = mx, position = pos, $
          _ref_extra = ex, noerase = noerase, noplot = noplot, $
          radec = radec, n_ticks = n_ticks, aspect = aspect, $
          reserve = reserve, squarepix = squarepix, $
          nodisplay = nodisplay, title = title, half = half, $
          xtv = xtv, ytv = ytv
;+
; NAME:
;   disp3
; PURPOSE:
;   Display 3-color pixel images using TVSCL with PLOT-like features. Note:
;   pixel registration is to the lower, lefthand corner of pixels to
;   match array indexing conventions in IDL. Use the /HALF keyword for
;   bin center registration.
;
; CALLING SEQUENCE:
;   DISP, r, g, b [, xin, yin, ... graphics keywords]
;
; INPUTS:
;   R,G,B - The three channels of the image array to be displayed.  
;   XIN - Vector containing the x-values correponding to the array's
;         first axis
;   YIN - Vector containing the y-values correponding to the array's
;         second axis
;
; KEYWORD PARAMETERS:
;   MIN/MAX - Minimum and maximum values for color scale. Either 1-
;             element (same for all channels) or 3-element vectors
;             (for each channel in R,G,B order). Defaults to min and
;             max of data.
;   NOPLOT - Doesn't plot anything, just passes back axis setup
;            through the keywords.
;   NOERASE -- Do not clear draw window before displaying.
;   NODISPLAY -- Draw axes, but do not display image.
;   RADEC -- Set this keyword to plot RA and DEC axes with good
;            formatting for the axis labelling.  The plotting routine
;            assumes that the RA is on the X axis and the DEC is on
;            the Y axis.
;   ASPECT -- Force aspect ratio (Y_SIZE/X_SIZE) to be a given value.
;             For a square plot, regardless of device size use ASPECT=1
;   SQUAREPIX -- Forces pixels to be square.  Overrides use of ASPECT keyword.
;   RESERVE -- Reserve the top N colors of the table for plotting.
;   HALF -- Set /HALF if the vectors refer to the centers of the
;           pixels and not the lower lefthand corner.
;   
;   Passed to PLOT command:
;   POSITION, XTICKFORMAT, YTICKFORMAT, XTITLE, YTITLE,
;   XCHARSIZE, YCHARSIZE, TITLE, CHARSIZE, CHARTHICK, COLOR, FONT,
;   SUBTITLE, THICK, THICKLEN, [XYZ]THICK, [XYZ]TICKLEN,
;   [XYZ]TICKS
;
; OUTPUTS:
;   NONE (pretty pictures!)
;
; MODIFICATION HISTORY:
;
;	Sat Feb 18 12:24:23 2006, Erik Rosolowsky
;       Converted from DISP.pro to do 3 color images.
;
;       Tue Dec 14 12:09:07 2004, Erik Rosolowsky <eros@cosmic>
;		Added /HALF because it's good for me.
;
;       Tue Dec 14 11:35:55 2004, Erik Rosolowsky <eros@cosmic>
;		Fixed 1 pixel loss in case where the X and Y are
;		passed to the routine.
;
;       Fri Apr 18 14:53:24 2003, Adam Leroy <aleroy@astrop>
;       Improved ASPECT keyword.		
;
;       Added
;       RESERVE keyword Sun Oct 20 17:45:38 2002, <eros@master>
;
;       Introduced ASPECT keyword.
;       Wed Sep 18 15:46:43 2002, Adam Leroy <aleroy@astro>
;
;       Added in /NOPLOT keyword.
;       Attempted compatability with !P.MULTI array
;       Mon Jun 10 14:45:15 2002, Erik Rosolowsky <eros@cosmic>
;
;       Trapped passing non 2-d arrays and complex variables.
;       Wed Jul 25 10:13:26 2001, Erik Rosolowsky <eros@cosmic>
;		
;       Allowed min and max values outside data range with appropriate
;       Color table stretches.
;       Tue Jul 10 13:36:55 2001, Erik Rosolowsky <eros@cosmic>
;
;       Added Color Compatibility with PS device. --
;       Thu Jan 25 17:48:46 2001, Erik Rosolowsky <eros@cosmic>
;
;       Initial Documentation -- Thu Oct 5 22:06:32 2000, Erik
;                                Rosolowsky <eros@cosmic>
;
;-

  if n_elements(rim) eq 0 and $
    n_elements(gim) eq 0 and $
    n_elements(bim) eq 0 $
  then begin
    message, 'No Image to display.  Returning...', /continue
    return
  endif

  if n_elements(size(rim, /dim)) ne 2 then begin
    message, 'Image not two dimensions.  Returning...', /continue
    return
  endif

;  if size(im, /tname) eq 'COMPLEX' then begin
;    message, 'Complex array! Plotting norm.', /con
;    im = float(sqrt(conj(im)*im))
;  endif
  if not keyword_set(noplot) then $ 
    if ((not keyword_set(noerase)) and (!p.multi[1]*!p.multi[2] le 0)) or $
      ((!p.multi[0] eq 0) and not keyword_set(noerase)) then erase
  if not keyword_set(reserve) then reserve = 0

  if n_elements(mn) eq 1 then mn = rebin([mn], 3)
  if n_elements(mx) eq 1 then mx = rebin([mx], 3)



  reserve = reserve+2 < !d.table_size-2

  r = rim
  g = gim
  b = bim

  imsize = size(r)

  if keyword_set(squarepix) then aspect = float(imsize[2])/imsize[1]

  if n_elements(xin) eq imsize[1] then begin
    xpix = findgen(imsize[1]+1)
    x = interpol(xin, xpix[0:imsize[1]-1], xpix)
  endif
  if n_elements(yin) eq imsize[2] then begin
    ypix = findgen(imsize[2]+1)
    y = interpol(yin, ypix[0:imsize[2]-1], ypix)
  endif

  if (n_elements(xin) eq 0) then x = findgen(imsize[1]+1)
  if (n_elements(yin) eq 0) then y = findgen(imsize[2]+1)
;  x = xin
 ; y = yin

; Put in a half pixel shift if you do that sort of thing.
  if keyword_set(half) then begin
    x = interpol(x, findgen(n_elements(x)), findgen(n_elements(x))-0.5)
    y = interpol(y, findgen(n_elements(y)), findgen(n_elements(y))-0.5)
  endif

; Eliminate pathological pixels, set to background color.
  err_pix = where(finite(r) ne 1)
  if err_pix[0] ne -1 then r[err_pix] = min(r, /nan)

  err_pix = where(finite(g) ne 1)
  if err_pix[0] ne -1 then g[err_pix] = min(g, /nan)

  err_pix = where(finite(b) ne 1)
  if err_pix[0] ne -1 then b[err_pix] = min(b, /nan)


  if keyword_set(pos) ne 1 then begin
    plot, [0.01, 1], /noerase, /nodata, xst = 4, yst = 4, _extra = ex
    pos = [!x.window[0], !y.window[0], !x.window[1], !y.window[1]]
  endif
  if (n_elements(x) eq 0) then x = findgen(imsize[1]+1)
  if (n_elements(y) eq 0) then y = findgen(imsize[2]+1)
  if n_elements(mn) eq 3 then begin
    subs = where(r le mn[0])
    if subs[0] ne -1 then r(subs) = mn[0]
    subs = where(g le mn[1])
    if subs[0] ne -1 then g(subs) = mn[1]
    subs = where(b le mn[2])
    if subs[0] ne -1 then b(subs) = mn[2]
  endif else mn = [min(r, /nan), min(g, /nan), min(b, /nan)]

  if n_elements(mx) eq 3 then begin
    subs = where(r ge mx[0])
    if subs[0] ne -1 then r(subs) = mx[0]
    subs = where(g ge mx[1])
    if subs[0] ne -1 then g(subs) = mx[1]
    subs = where(b ge mx[2])
    if subs[0] ne -1 then b(subs) = mx[2]
  endif else mx = [max(r, /nan), max(g, /nan), max(b, /nan)]

  sfac = 1

  x0 = !d.x_size*pos[0]
  y0 = !d.y_size*pos[1]
  x1 = !d.x_size*pos[2]
  y1 = !d.y_size*pos[3]

  if n_elements(aspect) gt 0 then begin
    deltay = y1 - y0            ; Y SPACE AVAILABLE
    deltax = x1 - x0            ; X SPACE AVAILABLE

    if (aspect ge 1.) then begin
      x1 = x0 + deltay/aspect
      new_deltax = deltay/aspect ; NEW X SIZE
      if (new_deltax gt deltax) then begin
        scaledown = deltax/new_deltax
        x1 = x0 + deltay/aspect*scaledown
        y1 = y0 + deltay*scaledown
      endif
    endif else begin
      y1 = y0 + deltax*aspect
      new_deltay = deltax*aspect
      if (new_deltay gt deltay) then begin
        scaledown = deltay/new_deltay
        y1 = y0 + deltax*aspect*scaledown
        x1 = x0 + deltax*scaledown
      endif
    endelse

    pos = [x0/!d.x_size, y0/!d.y_size $
           , x1/!d.x_size, y1/!d.y_size]

  endif


  scale = (!d.table_size-reserve)
  rbytim = floor((r-mn[0])*(!d.table_size-reserve)/(mx[0]-mn[0]))
  rind = where(rbytim ge (!d.table_size-reserve))

  gbytim = floor((g-mn[1])*(!d.table_size-reserve)/(mx[1]-mn[1]))
  gind = where(gbytim ge (!d.table_size-reserve))

  bbytim = floor((b-mn[2])*(!d.table_size-reserve)/(mx[2]-mn[2]))
  bind = where(bbytim ge (!d.table_size-reserve))

  if total(rind) gt -1 then rbytim[rind] = !d.table_size-reserve-1
  rind = where(rbytim lt 0, ct)
  if ct then rbytim[rind] = 0
  rbytim = byte(rbytim)

  if total(gind) gt -1 then gbytim[gind] = !d.table_size-reserve-1
  gind = where(gbytim lt 0, ct)
  if ct then gbytim[gind] = 0
  gbytim = byte(gbytim)

  if total(bind) gt -1 then bbytim[bind] = !d.table_size-reserve-1
  bind = where(bbytim lt 0, ct)
  if ct then bbytim[bind] = 0
  bbytim = byte(bbytim)

  
  
  bytim = bytarr(imsize[1], imsize[2], 3)
  bytim[*, *, 0] = rbytim
  bytim[*, *, 1] = gbytim
  bytim[*, *, 2] = bbytim


  if (!d.name eq 'PS') then begin
;  loadct, 0, /silent
;  tvlct, r, g, b, /get
;  r = reverse(r)
;  g = reverse(g)
;  b = reverse(b)
;  tvlct, r, g, b
    if not keyword_set(noplot) and not keyword_set(nodisplay)  then $
      tv, bytim, x0/!d.x_px_cm, y0/!d.y_px_cm, xsize = (x1-x0)/!d.x_px_cm, $ 
          ysize = (y1-y0)/!d.y_px_cm, /centimeters, true = 3
;  loadct, 0, /silent
  endif else begin
;    x = congrid(x, (x1-x0))
;    y = congrid(y, (y1-y0))
    bytim = congrid(bytim, ((x1-x0)/sfac), ((y1-y0)/sfac), 3)
    if not keyword_set(noplot) and not keyword_set(nodisplay) then tv, bytim, x0, y0, true = 3
  endelse

  if keyword_set(radec) then begin
    ra_names, x, tick_name = xtn, tick_value = xtv, $
              n_ticks = n_ticks, incr = incrx
    dec_names, y, tick_name = ytn, tick_value = ytv, $
               n_ticks = n_ticks, incr = incry
    xtks = ceil(abs(x[n_elements(x)-1]-x[0])/abs(incrx)+1)
    ytks = ceil(abs(y[n_elements(y)-1]-y[0])/abs(incry)+1)
    plot, x, y, /noerase, /nodata, position = pos, $
          xstyle = 1+4*keyword_set(noplot), ystyle = 1+4*keyword_set(noplot), $
          _extra = ex, xrange = [x[0], x[n_elements(x)-1]], $
          yrange = [y[0], y[n_elements(y)-1]], xtickname = xtn, ytickname = ytn, $
          xticks = n_elements(xtv)-2, $
          yticks = n_elements(ytv)-2, xminor = 4, yminor = 4, ytickv = ytv, $
          xtickv = xtv, title = title 

  endif else begin
    plot, x, y, /noerase, /nodata, position = pos, $
          xstyle = 1+4*keyword_set(noplot), ystyle = 1+4*keyword_set(noplot), $
          _extra = ex, xrange = [x[0], x[n_elements(x)-1]], $
          yrange = [y[0], y[n_elements(y)-1]], title = title
  endelse

  if keyword_set(noplot) then return 
  if total(!p.multi[1:2]) gt 0 then begin
    if !p.multi[0] le 0 then !p.multi[0] = (!p.multi[1]*!p.multi[2])
    !p.multi[0] = !p.multi[0]-1
  endif
  return
end


