pro hexplot, xin, yin, z, min = mn, max = mx, _ref_extra = ex,$
             radec = radec, hexgap = hexgap, $
             reserve = reserve, outline = outline, $
             overplot = overplot,xtickname = xtn_in, $
             ytickname = ytn_in, xtitle=xtitle, ytitle=ytitle,title=title

  if n_elements(hexgap) eq 0 then hexgap = 0.2


; Establish the color scale.  Save space at the top of the color table
  if n_elements(reserve) eq 0  then reserve = 0

  defsysv, '!RED', exists = setcolors
  if (setcolors) then reserve = 12
  reserve = reserve+2 < !d.table_size-2

  ptcolor = bytscl(z, top = 255b-reserve, min = mn, max= mx)

  
  tn = replicate(' ',20)

; Set up a dummy plot to find out plotting range.


  if not keyword_set(overplot) then begin 
     if keyword_set(radec) then begin 

        if keyword_set(pos) ne 1 then begin
           plot, [0.01, 1], /noerase, /nodata, xst = 4, yst = 4, _extra = ex,$
                 title=' '
           pos = [!x.window[0], !y.window[0], !x.window[1], !y.window[1]]
        endif
        
        dra = (xin-median(xin))*cos(median(yin)*!dtor)
        xinterval = max(dra)-min(dra)
        yinterval = max(yin)-min(yin)
        
        aspect = yinterval/xinterval
        
        x0 = !d.x_size*pos[0]
        y0 = !d.y_size*pos[1]
        x1 = !d.x_size*pos[2]
        y1 = !d.y_size*pos[3]
        

        deltay = y1 - y0        ; Y SPACE AVAILABLE
        deltax = x1 - x0        ; X SPACE AVAILABLE
        
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

        plot, xin, yin, /ynozero, /nodata, _extra = ex, $
              xticklen = 1e-6,yticklen = 1e-6,ytickname=tn,$
              xtickname = tn, pos = pos,xtick_get=xtks,ytick_get = ytks,$
              xrange = [max(xin),min(xin)],xtitle='',ytitle='',title=title

        ra_names, xtks, tick_name = xtn, tick_value = xtv, $
                  n_ticks = n_ticks, incr = incrx
        dec_names, ytks, tick_name = ytn, tick_value = ytv, $
                   n_ticks = n_ticks, incr = incry
        if n_elements(xtn_in) gt 0 then xtn = xtn_in
        if n_elements(ytn_in) gt 0 then ytn = xtn_in
;     xtks = ceil(abs(xin[n_elements(xin)-1]-xin[0])/abs(incrx)+1)
;     ytks = ceil(abs(yin[n_elements(yin)-1]-yin[0])/abs(incry)+1)
        
        axis,xaxis = 0,xtickname = xtn, xtickv = xtv,$
             xticks = n_elements(xtv)-2,xminor = 4,xtitle=xtitle
        axis,xaxis = 1, xtickv = xtv,$
             xticks = n_elements(xtv)-2, xminor =4,xtickname = tn
        axis,yaxis = 0,ytickname = ytn, $
             ytickv = ytv,yticks = n_elements(ytv)-2 ,yminor =4,ytitle=ytitle
        axis,yaxis = 1, ytickv = ytv,yticks = n_elements(ytv)-2, $
             yminor =4 ,ytickname = tn
     endif else begin
        plot, xin, yin, /nodata, _extra = ex, /iso,$
              xtitle=xtitle,ytitle=ytitle,$
              xtickname = xtn_in,ytickname=ytn_in
     endelse
  endif



  if keyword_set(radec) then begin
     gind = where(xin le !x.crange[0] and $
                  xin ge !x.crange[1] and $
                  yin ge !y.crange[0] and $
                  yin le !y.crange[1],ct)
  endif else begin
     gind = where(xin ge !x.crange[0] and $
                  xin le !x.crange[1] and $
                  yin ge !y.crange[0] and $
                  yin le !y.crange[1],ct)
     
  endelse
  
  if ct eq 0 then return

  x = xin[gind]
  y = yin[gind]

  triangulate, x, y, triangles, bounds, connectivity = cnex

  mndist = dblarr(n_elements(x)) 
  for i = 0L,n_elements(x)-1 do begin
     nbrs = (cnex[cnex[i]:(cnex[i+1]-1)])[1:*]
     mndist[i] = min(sqrt((x[nbrs]-x[i])^2 + $
                          (y[nbrs]-y[i])^2),ind)
     phis = atan((y[nbrs]-y), (x[nbrs]-x))     
  endfor 
  gsp = (min(mndist)*(1-hexgap))/sqrt(3)
  
  phi = 2*!pi*findgen(7)/6+!pi/6
  xv = cos(phi)
  yv = sin(phi)
  if keyword_set(radec) then begin
     xv = xv / cos(median(yin)*!dtor)
     gind = where(xin le !x.crange[0]+gsp and $
                  xin ge !x.crange[1]-gsp and $
                  yin ge !y.crange[0]+gsp and $
                  yin le !y.crange[1]-gsp,ct)
  endif else begin
     
     gind = where(xin ge !x.crange[0]+gsp and $
                  xin le !x.crange[1]-gsp and $
                  yin ge !y.crange[0]+gsp and $
                  yin le !y.crange[1]-gsp,ct)
     
  endelse
  x = xin[gind]
  y = yin[gind]
  
  

  for i = 0L,n_elements(x)-1 do begin
     polyfill, x[i] + xv*gsp, y[i] + yv*gsp, $
               color = ptcolor[i]
     if keyword_set(outline) then $
        oplot,x[i] + xv*gsp, y[i] + yv*gsp
  endfor 
  
  return
end
